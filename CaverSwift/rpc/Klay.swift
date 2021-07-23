//
//  Klay.swift
//  CaverSwift
//
//  Created by won on 2021/05/10.
//

import Foundation
import BigInt
import GenericJSON

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
        let(error, response) = rpc.request(url: url, method: "klay_accountCreated",
                    params: [address, blockTag.stringValue], receive: Bool.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getAccounts() -> (CaverError?, Addresses?) {
        let(error, response) = rpc.request(url: url, method: "klay_accounts",
                    params: Array<String>(), receive: Addresses.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getTransactionCount(_ address: String) -> (CaverError?, Quantity?) {
        getTransactionCount(address, DefaultBlockParameterName.Latest)
    }
    
    public func getTransactionCount(_ address: String, _ blockNumber: Int) -> (CaverError?, Quantity?) {
        getTransactionCount(address, DefaultBlockParameterName.Number(blockNumber))
    }
    
    public func getTransactionCount(_ address: String, _ blockTag: DefaultBlockParameterName = .Latest) -> (CaverError?, Quantity?) {
        let(error, response) = rpc.request(url: url, method: "klay_getTransactionCount",
                    params: [address, blockTag.stringValue], receive: Quantity.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getChainID() -> (CaverError?, Quantity?) {
        let(error, response) = rpc.request(url: url, method: "klay_chainID",
                    params: Array<String>(), receive: Quantity.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getGasPrice() -> (CaverError?, Quantity?) {
        let(error, response) = rpc.request(url: url, method: "klay_gasPrice",
                    params: Array<String>(), receive: Quantity.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getBlockNumber() -> (CaverError?, String?) {
        struct CallParams: Encodable {
            func encode(to encoder: Encoder) throws {
            }
        }
        let params = CallParams()
        let(error, response) = rpc.request(url: url, method: "klay_blockNumber", params: params, receive: String.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getBalance(_ address: String) -> (CaverError?, Quantity?) {
        let(error, response) = rpc.request(url: url, method: "klay_getBalance",
                            params: [address, DefaultBlockParameterName.Latest.stringValue], receive: Quantity.self)!.send()
        return parseReturn(error, response)
    }
    
    func call(_ callObject: CallObject, _ blockNumber: DefaultBlockParameterName = .Latest) throws -> (CaverError?, String?) {
        let params = CallParams(callObject, blockNumber.stringValue)
//        let te = rpc.request(url: url, method: "klay_call", params: [callObject, blockNumber.stringValue], receive: String.self)
        let(error, response) = rpc.request(url: url, method: "klay_call", params: params, receive: String.self)!.send()
        return parseReturn(error, response)
    }
    
    func estimateGas(_ callObject: CallObject) throws -> (CaverError?, Quantity?) {
        let params = CallParams(callObject)
        let(error, response) = rpc.request(url: url, method: "klay_estimateGas", params: params, receive: Quantity.self)!.send()
        return parseReturn(error, response)
    }
    
    public func sendRawTransaction(_ signedTransactionData: String) -> (CaverError?, Bytes32?) {
        let (error, response) = rpc.request(url: url, method: "klay_sendRawTransaction",
                    params: [signedTransactionData], receive: Bytes32.self)!.send()
        return parseReturn(error, response)
    }
    
    public func sendRawTransaction(_ transaction: AbstractTransaction) -> (CaverError?, Bytes32?) {
        let rawTransaction = try? transaction.getRLPEncoding()
        let (error, response) = rpc.request(url: url, method: "klay_sendRawTransaction",
                                            params: [rawTransaction], receive: Bytes32.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getTransactionReceipt(_ transactionHash: String) -> (CaverError?, TransactionReceiptData?) {
        let (error, response) = rpc.request(url: url, method: "klay_getTransactionReceipt",
                    params: [transactionHash], receive: TransactionReceiptData.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getLogs(_ filterOption: KlayLogFilter) -> (CaverError?, KlayLogs?) {
        let params = KlayLogFilterParams(filterOption)
        let (error, response) = rpc.request(url: url, method: "klay_getLogs",
                    params: params, receive: KlayLogs.self)!.send()
        
        return parseReturn(error, response)
    }
    
    private func parseReturn<T: Any>(_ error: JSONRPCError?, _ response: Any?) -> (CaverError?, T?) {
        if let resDataString = response as? T {
            return (nil, resDataString)
        } else if let error = error {
            switch error {
            case .executionError(let result):
                return (CaverError.JSONRPCError(result.error.message), nil)
            default:
                return (CaverError.JSONRPCError(error.localizedDescription), nil)
            }
        } else {
            return (CaverError.unexpectedReturnValue, nil)
        }
    }
    
    public struct Bytes32: Decodable {
        var val: String
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.val = (try? container.decode(String.self)) ?? ""
        }
    }
    
    public struct KlayLogFilterParams: Encodable {
        let fromBlock: String?
        let toBlock: String?
        let address: [String]?
        let topics: [String?]?
        let blockHash: String?
        
        init(_ filter: KlayLogFilter) {
            self.fromBlock = filter.fromBlock.stringValue
            self.toBlock = filter.toBlock.stringValue
            self.address = filter.address
            self.topics = filter.topics.map {
                $0.getValue()
            }
            self.blockHash = filter.blockHash
        }
        
        enum CodingKeys: String, CodingKey {
            case fromBlock
            case toBlock
            case address
            case topics
            case blockHash
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.unkeyedContainer()
            var nested = container.nestedContainer(keyedBy: CodingKeys.self)
            if let fromBlock = fromBlock {
                try nested.encode(fromBlock, forKey: .fromBlock)
            }
            if let toBlock = toBlock {
                try nested.encode(toBlock, forKey: .toBlock)
            }
            if let address = address {
                try nested.encode(address, forKey: .address)
            }
            if let topics = topics {
                try nested.encode(topics, forKey: .topics)
            }
            if let blockHash = blockHash {
                try nested.encode(blockHash, forKey: .blockHash)
            }
        }
    }
    
    struct CallParams: Encodable {
        let from: String?
        let to: String?
        let gasLimit: BigInt?
        let gasPrice: BigInt?
        let value: BigInt?
        let data: String?
        let block: String?
        
        init(_ callObject: CallObject, _ block: String? = nil) {
            self.from = callObject.from
            self.to = callObject.to
            self.gasLimit = callObject.gasLimit
            self.gasPrice = callObject.gasPrice
            self.value = callObject.value
            self.data = callObject.data
            self.block = block
        }
        
        enum CodingKeys: String, CodingKey {
            case from
            case to
            case gasLimit
            case gasPrice
            case value
            case data
            case block
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.unkeyedContainer()
            var nested = container.nestedContainer(keyedBy: CodingKeys.self)
            if let from = from {
                try nested.encode(from, forKey: .from)
            }
            if let to = to {
                try nested.encode(to, forKey: .to)
            }
            if let gasLimit = gasLimit {
                try nested.encode(gasLimit.hexa, forKey: .gasLimit)
            }
            if let gasPrice = gasPrice {
                try nested.encode(gasPrice.hexa, forKey: .gasPrice)
            }
            if let value = value {
                try nested.encode(value.hexa, forKey: .value)
            }
            if let data = data {
                try nested.encode(data, forKey: .data)
            }
            if let block = block {
                try container.encode(block)
            }
        }
    }
}
