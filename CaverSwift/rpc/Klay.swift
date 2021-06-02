//
//  Klay.swift
//  CaverSwift
//
//  Created by won on 2021/05/10.
//

import Foundation
import BigInt

public class Klay {
    var session: URLSession
    var url: URL
    
    public init(_ web3jService: URLSession, _ url: URL) {
        self.session = web3jService
        self.url = url
    }
    
    public func getBlockNumber(completion: @escaping((CaverError?, String?) -> Void)) {
        struct CallParams: Encodable {
            func encode(to encoder: Encoder) throws {
            }
        }
        let params = CallParams()
        EthereumRPC.execute(session: session, url: url, method: "klay_blockNumber", params: params, receive: String.self) { (error, response) in
            if let resDataString = response as? String {
                return completion(nil, resDataString)
            } else if let error = error {
                return completion(CaverError.IOException(error.localizedDescription), nil)
            } else {
                return completion(CaverError.unexpectedReturnValue, nil)
            }
        }
    }
    
    public func getBalance(_ address: String, completion: @escaping((CaverError?, Quantity?) -> Void)) {
        EthereumRPC.execute(session: session, url: url, method: "klay_getBalance",
                            params: [address, EthereumBlock.Latest.stringValue], receive: Quantity.self) { (error, response) in
            if let resDataString = response as? Quantity {
                return completion(nil, resDataString)
            } else if let error = error {
                return completion(CaverError.IOException(error.localizedDescription), nil)
            } else {
                return completion(CaverError.unexpectedReturnValue, nil)
            }
        }
    }
    
    func call(_ callObject: CallObject, _ blockNumber: EthereumBlock = .Latest, completion: @escaping((CaverError?, String?) -> Void)) throws {
        guard let to = callObject.to,
              let data = callObject.data else {
            throw CaverError.ArgumentException("'to' and 'data' field in CallObject will overwrite.")
        }
        
        let params = CallParams(from: callObject.from, to: to, data: data, block: blockNumber.stringValue)
        EthereumRPC.execute(session: session, url: url, method: "klay_call", params: params, receive: String.self) { (error, response) in
            if let resDataString = response as? String {
                return completion(nil, resDataString)
            } else if let error = error {
                return completion(CaverError.IOException(error.localizedDescription), nil)
            } else {
                return completion(CaverError.unexpectedReturnValue, nil)
            }
        }
    }
    
    struct CallParams: Encodable {
        let from: String?
        let to: String
        let data: String
        let block: String
        
        enum TransactionCodingKeys: String, CodingKey {
            case from
            case to
            case data
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.unkeyedContainer()
            var nested = container.nestedContainer(keyedBy: TransactionCodingKeys.self)
            if let from = from {
                try nested.encode(from, forKey: .from)
            }
            try nested.encode(to, forKey: .to)
            try nested.encode(data, forKey: .data)
            try container.encode(block)
        }
    }
}
