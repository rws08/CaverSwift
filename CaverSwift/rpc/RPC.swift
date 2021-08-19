//
//  RPC.swift
//  CaverSwift
//
//  Created by won on 2021/05/10.
//

import Foundation

public class RPC {
    private(set) public var service: WebService
    private(set) public var url: URL
    public static var id: Int = 0
    
    public lazy var klay = Klay(self, url)
    public lazy var net = Net(self, url)
    
    public init(_ service: WebService) {
        self.service = service
        self.url = service.url
    }
    
    deinit {
        self.service.session.invalidateAndCancel()
    }
        
    public func send<U: Decodable>(_ request: URLRequest, _ receive: U) -> (JSONRPCError?, Any?) {
        RPC.send(service, request, receive)
    }
    
    public static func send<U: Decodable>(_ service: WebService, _ request: URLRequest, _ receive: U) -> (JSONRPCError?, Any?) {
               
        var result: (JSONRPCError?, Any?) = (nil, nil)
                
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        service.session.dataTask(with: request) { (data, response, error) in
            result = RPC.receiveData(U.self, data, response, error)
            dispatchGroup.leave()
        }.resume()
        
        dispatchGroup.wait()
        
        return result
    }
        
    private static func receiveData<U: Decodable>(_ receive: U.Type, _ data: Data?, _ response: URLResponse?, _ error: Error?) -> (JSONRPCError?, Any?) {
        var result: (JSONRPCError?, Any?) = (nil, nil)
        if let data = data {
            print("network raw data : \(String(describing: String(data: data, encoding: .utf8)))")
            if let resultData = try? JSONDecoder().decode(JSONRPCResult<U>.self, from: data) {
                result = (nil, resultData.result)
            } else if let resultData = try? JSONDecoder().decode([JSONRPCResult<U>].self, from: data) {
                let resultObjects = resultData.map{ return $0.result }
                result = (nil, resultObjects)
            } else if let errorResult = try? JSONDecoder().decode(JSONRPCErrorResult.self, from: data) {
                print("Caver response error: \(errorResult.error)")
                result = (JSONRPCError.executionError(errorResult), nil)
            } else if let response = response as? HTTPURLResponse, response.statusCode < 200 || response.statusCode > 299 {
                result = (JSONRPCError.requestRejected(data), nil)
            } else {
                result = (JSONRPCError.noResult, nil)
            }
        } else {
            result = (JSONRPCError.unknownError, nil)
        }
        return result
    }
    
    @available(iOS 13.0, *)
    public static func subscribe(_ service: WebSocketService, _ requestData: Data, _ callback: @escaping (KlayLogs?) -> ()) {
        service.subscribe(requestData, callback)
    }
    
    @available(iOS 13.0, *)
    public static func send<U: Decodable>(_ service: WebSocketService, _ requestData: Data, _ receive: U.Type) -> (JSONRPCError?, Any?) {
        service.send(requestData, U.self)
    }
    
    public struct Request<T: Encodable, U: Decodable> {
        private var rpc: RPC
        var urlRequest: URLRequest
        var requestData: Data
        var receiveType: U?
        
        internal init(_ rpc: RPC, _ urlRequest: URLRequest) {
            self.rpc = rpc
            self.urlRequest = urlRequest
            self.requestData = urlRequest.httpBody ?? Data()
        }
        
        init?(_ method: String, _ params: T, _ rpc: RPC, _ receive: U.Type) {
            self.rpc = rpc
            RPC.id += 1
            self.urlRequest = URLRequest(url: self.rpc.url, cachePolicy: .reloadIgnoringLocalCacheData)
            
            if type(of: params) == [Any].self {
                print(CaverError.invalidParam)
                return nil
            }

            self.urlRequest.httpMethod = "POST"
            self.urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            self.urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
            for key in self.rpc.service.headers.keys {
                self.urlRequest.addValue(self.rpc.service.headers[key] ?? "", forHTTPHeaderField: key)
            }
            
//            print("network request : \(method) - \(params)")
            let rpcRequest = JSONRPCRequest(jsonrpc: "2.0", method: method, params: params, id: RPC.id)
            guard let encoded = try? JSONEncoder().encode(rpcRequest) else {
                print(CaverError.encodingError)
                return nil
            }
            self.requestData = encoded
            print("network request : \(method) - \(String(describing: String(data: encoded, encoding: .utf8)))")
            self.urlRequest.httpBody = encoded
        }

        public func send() -> (JSONRPCError?, Any?) {
            if #available(iOS 13.0, *) {
                if let service = rpc.service as? WebSocketService,
                   let data = urlRequest.httpBody {
                    return RPC.send(service, data, U.self)
                } else {
                    return RPC.send(rpc.service, urlRequest, receiveType)
                }
            } else {
                return RPC.send(rpc.service, urlRequest, receiveType)
            }
        }
        
        @available(iOS 13.0, *)
        public func subscribe(_ callback: @escaping ((KlayLogs?)) -> Void) throws {
            guard let service = rpc.service as? WebSocketService else {
                throw CaverError.UnsupportedOperationException("Supported only on iOS 13 or later.")
            }
            RPC.subscribe(service, requestData, callback)
        }
    }
}
