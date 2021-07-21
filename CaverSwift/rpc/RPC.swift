//
//  RPC.swift
//  CaverSwift
//
//  Created by won on 2021/05/10.
//

import Foundation

public class RPC {
    private var session: URLSession
    private var url: URL
    
    public lazy var klay = Klay(self, url)
    
    public init(_ session: URLSession, _ url: URL) {
        self.session = session
        self.url = url
    }
    
    deinit {
        self.session.invalidateAndCancel()
    }
    
    public func request<T: Encodable, U: Decodable>(url: URL, method: String, params: T, receive: U.Type, id: Int = 1) -> Request<U>? {
        RPC.request(session:session, url: url, method: method, params: params, receive: receive, id: id)
    }
    
    public static func request<T: Encodable, U: Decodable>(session: URLSession, url: URL, method: String, params: T, receive: U.Type, id: Int = 1) -> Request<U>? {
        if type(of: params) == [Any].self {
            // If params are passed in with Array<Any> and not caught, runtime fatal error
            return nil
        }

        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        print("network request : \(method) - \(params)")
        let rpcRequest = JSONRPCRequest(jsonrpc: "2.0", method: method, params: params, id: id)
        guard let encoded = try? JSONEncoder().encode(rpcRequest) else {
            return nil
        }
        request.httpBody = encoded
                
        return Request<U>(session, request)
    }
    
    public func send<U: Decodable>(request: URLRequest, receive: U) -> (Error?, Any?) {
        RPC.send(session: session, request: request, receive: receive)
    }
    
    public static func send<U: Decodable>(session: URLSession, request: URLRequest, receive: U) -> (Error?, Any?) {
               
        var result: (Error?, Any?) = (nil, nil)
                
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        session.dataTask(with: request) { (data, response, error) in
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
            
            dispatchGroup.leave()
        }.resume()
        
        dispatchGroup.wait()
        
        return result
    }
    
    public func execute<T: Encodable, U: Decodable>(url: URL, method: String, params: T, receive: U.Type, id: Int = 1) -> (Error?, Any?) {
        RPC.execute(session: session, url: url, method: method, params: params, receive: receive, id: id)
    }
    
    public static func execute<T: Encodable, U: Decodable>(session: URLSession, url: URL, method: String, params: T, receive: U.Type, id: Int = 1) -> (Error?, Any?) {
               
        var result: (Error?, Any?) = (nil, nil)
        
        if type(of: params) == [Any].self {
            // If params are passed in with Array<Any> and not caught, runtime fatal error
            return (JSONRPCError.encodingError, result)
        }

        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let rpcRequest = JSONRPCRequest(jsonrpc: "2.0", method: method, params: params, id: id)
        guard let encoded = try? JSONEncoder().encode(rpcRequest) else {
            return (JSONRPCError.encodingError, nil)
        }
        request.httpBody = encoded
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
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
            
            dispatchGroup.leave()
        }.resume()
        
        dispatchGroup.wait()
        
        return result
    }
    
    public struct Request<T: Decodable> {
        private var session: URLSession
        var urlRequest: URLRequest
        var receiveType: T?
        
        internal init(_ session: URLSession, _ urlRequest: URLRequest) {
            self.session = session
            self.urlRequest = urlRequest
        }

        public func send() -> (Error?, Any?) {
            RPC.send(session: session, request: urlRequest, receive: receiveType)
        }
    }
}
