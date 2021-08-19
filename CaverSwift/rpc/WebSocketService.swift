//
//  WebSocketService.swift
//  CaverSwift
//
//  Created by won on 2021/08/03.
//

import Foundation
import Combine
import GenericJSON

open class WebService: NSObject {
    public var url: URL
    public var session = URLSession(configuration: .default)
    public var headers: [String:String] = [:]
    
    init(_ urlString: String) {
        self.url = URL(string: urlString)!
        super.init()
    }
    
    func addHeader(_ key: String, _ value: String) {
        headers[key] = value
    }
}

@available(iOS 13.0, *)
open class WebSocketService: WebService, URLSessionWebSocketDelegate {
    static let REQUEST_TIMEOUT: TimeInterval = 60
    var timeoutQueue: DispatchQueue
    
    private var _webSocketTask: URLSessionWebSocketTask?
    public var webSocketTask: URLSessionWebSocketTask {
        get{
            if let webSocketTask = self._webSocketTask {
                return webSocketTask
            } else {
                _webSocketTask = self.session.webSocketTask(with: self.url)
                return _webSocketTask!
            }
        }
    }
    var subscribeId = ""
    
    var callbacks: [((KlayLogs?) -> Void)] = []
    
    var receiveTasks: [String:Any] = [:]
    
    override init(_ urlString: String) {
        self.timeoutQueue = DispatchQueue(label: "timeout", attributes: .concurrent)
        super.init(urlString)
        self.session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
    }
    
    deinit {
        close()
    }
    
    public func close() {
        let reason = "Closing connection".data(using: .utf8)
        webSocketTask.cancel(with: .goingAway, reason: reason)
    }
    
    public func connect() {
        webSocketTask.resume()
    }
    
    public func unsubscribe() {
        let rpcRequest = JSONRPCRequest(jsonrpc: "2.0", method: "klay_unsubscribe", params: [self.subscribeId], id: RPC.id)
        guard let encoded = try? JSONEncoder().encode(rpcRequest) else {
            print(CaverError.encodingError)
            return
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            self.webSocketTask.send(.data(encoded)) { error in
                if let error = error {
                    print("Error when sending a message \(error)")
                    self.close()
                }
            }
        }
    }
        
    public func subscribe(_ requestData: Data, _ callback: @escaping (KlayLogs?) -> Void) {
        self.callbacks.append(callback)
        
        self.webSocketTask.send(.data(requestData)) { error in
            if let error = error {
                print("Error when sending a message \(error)")
                self.close()
                callback(nil)
            }
        }
        
        self.timeoutQueue.suspend()
        self.timeoutQueue.asyncAfter(deadline: .now() + WebSocketService.REQUEST_TIMEOUT) {
            WARNING(message: "WebSocket timeout")
            self.close()
            callback(nil)
        }
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        let reqestId = getRequestId(requestData)
        receiveTasks[reqestId] = ReceiveTask(reqestId, dispatchGroup)
        
        dispatchGroup.wait()
        
        if let receiveTask = receiveTasks[reqestId] as? ReceiveTask,
           let subscribeId = receiveTask.getResult(String.self).result as? String{
            receiveTasks.removeValue(forKey: reqestId)
            self.subscribeId = subscribeId
        }
    }
    
    public func send<T: Decodable>(_ requestData: Data, _ receiveType: T.Type) -> (JSONRPCError?, result: Any?) {
        var result: (JSONRPCError?, Any?)? = nil
        if self.subscribeId.isEmpty {
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                result = self.send(requestData, receiveType)
                dispatchGroup.leave()
            }
            
            dispatchGroup.wait()
        } else {
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                self.webSocketTask.send(.data(requestData)) { error in
                    if let error = error {
                        print("Error when sending a message \(error)")
                        self.close()
                    }
                }
            }
            
            self.timeoutQueue.suspend()
            self.timeoutQueue.asyncAfter(deadline: .now() + WebSocketService.REQUEST_TIMEOUT) {
                WARNING(message: "WebSocket timeout")
                self.close()
            }
            
            let reqestId = getRequestId(requestData)
            receiveTasks[reqestId] = ReceiveTask(reqestId, dispatchGroup)
            
            dispatchGroup.wait()
            
            if let receiveTask = receiveTasks[reqestId] as? ReceiveTask {
                receiveTasks.removeValue(forKey: reqestId)
                return receiveTask.getResult(T.self)
            }
        }
        
        return result ?? (nil, nil)
    }
    
    class ReceiveTask {
        internal init(_ id: String, _ dispatchGroup: DispatchGroup) {
            self.id = id
            self.dispatchGroup = dispatchGroup
        }
        
        public func setResult(_ result: String) {
            self.result = result
            self.dispatchGroup.leave()
        }
        
        public func getResult<T: Decodable>(_ type: T.Type) -> (JSONRPCError?, result: Any?) {
            var result: (JSONRPCError?, Any?) = (nil, nil)
            if let resultStr = self.result {
                if let data = resultStr.data(using: .utf8){
                    if let resultData = try? JSONDecoder().decode(JSONRPCResult<T>.self, from: data) {
                        result = (nil, resultData.result)
                    } else if let errorResult = try? JSONDecoder().decode(JSONRPCErrorResult.self, from: data) {
                        print("Caver response error: \(errorResult.error)")
                        result = (JSONRPCError.executionError(errorResult), nil)
                    }
                }
            }
            
            return result
        }
        
        public var id = ""
        public var dispatchGroup: DispatchGroup
        public var result: String?
    }
        
    private func receive() {
        self.webSocketTask.receive {
            var callbackData: KlayLogs? = nil
            
            self.timeoutQueue.suspend()
            
            switch $0 {
            case .success(let message):
                switch message {
                case .data(_): break
                case .string(let text):
                    print("WebSocket Received message \(text)")
                    if let data = text.data(using: .utf8){
                        if let json = try? JSONDecoder().decode(JSON.self, from:data) {
                            let reqestId = self.getRequestId(json)
                            if self.isReply(reqestId) {
                                let receiveTask = self.receiveTasks[reqestId] as? ReceiveTask
                                receiveTask?.setResult(text)
                            } else if self.isBatchReply(json) {
                                // TODO: not supported
                            } else if self.isSubscriptionEvent(json) {
                                if let resultData = try? JSONDecoder().decode(JSONRPCSubscribeResult<KlayLogs>.self, from: data) {
                                    callbackData = resultData.params.result
                                }
                            }
                        }
                    }
                @unknown default: break
                }
            case .failure(let error):
                print("Error when receiving \(error)")
            }
            
            if callbackData != nil {
                self.callbacks.forEach {
                    $0(callbackData)
                }
                if self.receiveTasks.isEmpty {
                    self.unsubscribe()
                }                
            }
            self.receive()
        }
    }
    
    private func getRequestId(_ data: Data) -> String {
        if let json = try? JSONDecoder().decode(JSON.self, from:data) {
            return getRequestId(json)
        }
        return "0"
    }
    
    private func getRequestId(_ json: JSON) -> String {
        return String(format: "%.0f", json["id"]?.doubleValue ?? 0)
    }
    
    private func isReply(_ id: String) -> Bool {
        return !id.isEmpty && id != "0"
    }
    
    private func isBatchReply(_ json: JSON) -> Bool {
        return json.arrayValue != nil
    }
    
    private func isSubscriptionEvent(_ json: JSON) -> Bool {
        return json["method"] != nil
    }
    
    private func ping() {
        webSocketTask.sendPing { error in
            if let error = error {
                print("Error when sending PING \(error)")
            } else {
                print("Web Socket connection is alive")
                DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
                    self.ping()
                }
            }
        }
    }
    
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Web Socket did connect")
        receive()
    }
    
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Web Socket did disconnect")
        if let data = reason,
           let str = String(data: data, encoding: .utf8) {
            print(str)
        }
    }
}

