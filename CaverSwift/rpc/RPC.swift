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
}
