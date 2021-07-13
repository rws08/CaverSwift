//
//  Klay.swift
//  CaverSwift
//
//  Created by won on 2021/05/10.
//

import Foundation
import BigInt

public class Klay {
    var rpc: RPC
    var url: URL
    
    public init(_ rpc: RPC, _ url: URL) {
        self.rpc = rpc
        self.url = url
    }
    
    public func accountCreated(_ address: String) -> (CaverError?, Bool?) {
        accountCreated(address, DefaultBlockParameterName.Latest)
    }
    
    public func accountCreated(_ address: String, _ blockNumber: Int) -> (CaverError?, Bool?) {
        accountCreated(address, DefaultBlockParameterName.Number(blockNumber))
    }
    
    public func accountCreated(_ address: String, _ blockTag: DefaultBlockParameterName = .Latest) -> (CaverError?, Bool?) {
        let(error, response) = rpc.execute(url: url, method: "klay_accountCreated",
                    params: [address, blockTag.stringValue], receive: Bool.self)
        if let resDataString = response as? Bool {
            return (nil, resDataString)
        } else if let error = error {
            return (CaverError.IOException(error.localizedDescription), nil)
        } else {
            return (CaverError.unexpectedReturnValue, nil)
        }
    }
    
    public func getAccounts() -> (CaverError?, Addresses?) {
        let(error, response) = rpc.execute(url: url, method: "klay_accounts",
                    params: Array<String>(), receive: Addresses.self)
        if let resDataString = response as? Addresses {
            return (nil, resDataString)
        } else if let error = error {
            return (CaverError.IOException(error.localizedDescription), nil)
        } else {
            return (CaverError.unexpectedReturnValue, nil)
        }
    }
    
    public func getTransactionCount(_ address: String) -> (CaverError?, Quantity?) {
        getTransactionCount(address, DefaultBlockParameterName.Latest)
    }
    
    public func getTransactionCount(_ address: String, _ blockNumber: Int) -> (CaverError?, Quantity?) {
        getTransactionCount(address, DefaultBlockParameterName.Number(blockNumber))
    }
    
    public func getTransactionCount(_ address: String, _ blockTag: DefaultBlockParameterName = .Latest) -> (CaverError?, Quantity?) {
        let(error, response) = rpc.execute(url: url, method: "klay_getTransactionCount",
                    params: [address, blockTag.stringValue], receive: Quantity.self)
        if let resDataString = response as? Quantity {
            return (nil, resDataString)
        } else if let error = error {
            return (CaverError.IOException(error.localizedDescription), nil)
        } else {
            return (CaverError.unexpectedReturnValue, nil)
        }
    }
    
    public func getChainID() -> (CaverError?, Quantity?) {
        let(error, response) = rpc.execute(url: url, method: "klay_chainID",
                    params: Array<String>(), receive: Quantity.self)
        if let resDataString = response as? Quantity {
            return (nil, resDataString)
        } else if let error = error {
            return (CaverError.IOException(error.localizedDescription), nil)
        } else {
            return (CaverError.unexpectedReturnValue, nil)
        }
    }
    
    public func getGasPrice() -> (CaverError?, Quantity?) {
        let(error, response) = rpc.execute(url: url, method: "klay_gasPrice",
                    params: Array<String>(), receive: Quantity.self)
        if let resDataString = response as? Quantity {
            return (nil, resDataString)
        } else if let error = error {
            return (CaverError.IOException(error.localizedDescription), nil)
        } else {
            return (CaverError.unexpectedReturnValue, nil)
        }
    }
    
    public func getBlockNumber() -> (CaverError?, String?) {
        struct CallParams: Encodable {
            func encode(to encoder: Encoder) throws {
            }
        }
        let params = CallParams()
        let(error, response) = rpc.execute(url: url, method: "klay_blockNumber", params: params, receive: String.self)
        if let resDataString = response as? String {
            return (nil, resDataString)
        } else if let error = error {
            return (CaverError.IOException(error.localizedDescription), nil)
        } else {
            return (CaverError.unexpectedReturnValue, nil)
        }
    }
    
    public func getBalance(_ address: String) -> (CaverError?, Quantity?) {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        let(error, response) = rpc.execute(url: url, method: "klay_getBalance",
                            params: [address, DefaultBlockParameterName.Latest.stringValue], receive: Quantity.self)
        if let resDataString = response as? Quantity {
            return (nil, resDataString)
        } else if let error = error {
            return (CaverError.IOException(error.localizedDescription), nil)
        } else {
            return (CaverError.unexpectedReturnValue, nil)
        }
    }
    
    func call(_ callObject: CallObject, _ blockNumber: DefaultBlockParameterName = .Latest) throws -> (CaverError?, String?){
        guard let to = callObject.to,
              let data = callObject.data else {
            throw CaverError.ArgumentException("'to' and 'data' field in CallObject will overwrite.")
        }
        
        let params = CallParams(from: callObject.from, to: to, data: data, block: blockNumber.stringValue)
        let(error, response) = rpc.execute(url: url, method: "klay_call", params: params, receive: String.self)
        if let resDataString = response as? String {
            return (nil, resDataString)
        } else if let error = error {
            return (CaverError.IOException(error.localizedDescription), nil)
        } else {
            return (CaverError.unexpectedReturnValue, nil)
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
