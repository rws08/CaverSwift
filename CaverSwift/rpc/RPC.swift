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
    
    public func execute<T: Encodable, U: Decodable>(url: URL, method: String, params: T, receive: U.Type, id: Int = 1, completion: @escaping ((Error?, Any?) -> Void)) -> Void {
        RPC.execute(session: session, url: url, method: method, params: params, receive: receive, id: id, completion: completion)
    }
    
    public static func execute<T: Encodable, U: Decodable>(session: URLSession, url: URL, method: String, params: T, receive: U.Type, id: Int = 1, completion: @escaping ((Error?, Any?) -> Void)) -> Void {
        
        if type(of: params) == [Any].self {
            // If params are passed in with Array<Any> and not caught, runtime fatal error
            completion(JSONRPCError.encodingError, nil)
            return
        }

        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let rpcRequest = JSONRPCRequest(jsonrpc: "2.0", method: method, params: params, id: id)
        guard let encoded = try? JSONEncoder().encode(rpcRequest) else {
            completion(JSONRPCError.encodingError, nil)
            return
        }
        request.httpBody = encoded
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                if let result = try? JSONDecoder().decode(JSONRPCResult<U>.self, from: data) {
                    return completion(nil, result.result)
                } else if let result = try? JSONDecoder().decode([JSONRPCResult<U>].self, from: data) {
                    let resultObjects = result.map{ return $0.result }
                    return completion(nil, resultObjects)
                } else if let errorResult = try? JSONDecoder().decode(JSONRPCErrorResult.self, from: data) {
                    print("Ethereum response error: \(errorResult.error)")
                    return completion(JSONRPCError.executionError(errorResult), nil)
                } else if let response = response as? HTTPURLResponse, response.statusCode < 200 || response.statusCode > 299 {
                    return completion(JSONRPCError.requestRejected(data), nil)
                } else {
                    return completion(JSONRPCError.noResult, nil)
                }
            }
            
            completion(JSONRPCError.unknownError, nil)
        }
        
        task.resume()
    }
}
