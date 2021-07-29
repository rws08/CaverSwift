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
    
    public func accountCreated(_ address: String) -> (CaverError?, result: Bool?) {
        accountCreated(address, DefaultBlockParameterName.Latest)
    }
    
    public func accountCreated(_ address: String, _ blockNumber: Int) -> (CaverError?, result: Bool?) {
        accountCreated(address, DefaultBlockParameterName.Number(blockNumber))
    }
    
    public func accountCreated(_ address: String, _ blockTag: DefaultBlockParameterName = .Latest) -> (CaverError?, result: Bool?) {
        let(error, response) = RPC.Request("klay_accountCreated", [address, blockTag.stringValue], rpc, Bool.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getAccounts() -> (CaverError?, result: Addresses?) {
        let(error, response) = RPC.Request("klay_accounts", Array<String>(), rpc, Addresses.self)!.send()
        return parseReturn(error, response)
    }
    
    public func encodeAccountKey(_ accountKey: IAccountKey) -> (CaverError?, result: Bytes?) {
        let(error, response) = RPC.Request("klay_encodeAccountKey", [accountKey], rpc, Bytes.self)!.send()
        return parseReturn(error, response)
    }
    
    public func decodeAccountKey(_ encodedAccountKey: String) -> (CaverError?, result: AccountKey?) {
        let(error, response) = RPC.Request("klay_decodeAccountKey", [encodedAccountKey], rpc, AccountKey.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getTransactionCount(_ address: String) -> (CaverError?, result: Quantity?) {
        getTransactionCount(address, DefaultBlockParameterName.Latest)
    }
    
    public func getTransactionCount(_ address: String, _ blockNumber: Int) -> (CaverError?, result: Quantity?) {
        getTransactionCount(address, DefaultBlockParameterName.Number(blockNumber))
    }
    
    public func getTransactionCount(_ address: String, _ blockTag: DefaultBlockParameterName = .Latest) -> (CaverError?, result: Quantity?) {
        let(error, response) = RPC.Request("klay_getTransactionCount", [address, blockTag.stringValue], rpc, Quantity.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getChainID() -> (CaverError?, result: Quantity?) {
        let(error, response) = RPC.Request("klay_chainID", Array<String>(), rpc, Quantity.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getGasPrice() -> (CaverError?, result: Quantity?) {
        let(error, response) = RPC.Request("klay_gasPrice", Array<String>(), rpc, Quantity.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getBlockNumber() -> (CaverError?, result: String?) {
        struct CallParams: Encodable {
            func encode(to encoder: Encoder) throws {
            }
        }
        let params = CallParams()
        let(error, response) = RPC.Request("klay_blockNumber", params, rpc, String.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getBalance(_ address: String) -> (CaverError?, result: Quantity?) {
        let(error, response) = RPC.Request("klay_getBalance", [address, DefaultBlockParameterName.Latest.stringValue], rpc, Quantity.self)!.send()
        return parseReturn(error, response)
    }
    
    func call(_ callObject: CallObject, _ blockNumber: DefaultBlockParameterName = .Latest) throws -> (CaverError?, result: String?) {
        let params = CallParams(callObject, blockNumber.stringValue)
//        let te = rpc.request(url: url, method: "klay_call", params: [callObject, blockNumber.stringValue], receive: String.self)
        let(error, response) = RPC.Request("klay_call", params, rpc, String.self)!.send()
        return parseReturn(error, response)
    }
    
    func estimateGas(_ callObject: CallObject) throws -> (CaverError?, result: Quantity?) {
        let params = CallParams(callObject)
        let(error, response) = RPC.Request("klay_estimateGas", params, rpc, Quantity.self)!.send()
        return parseReturn(error, response)
    }
    
    public func sendRawTransaction(_ signedTransactionData: String) -> (CaverError?, result: Bytes32?) {
        let (error, response) = RPC.Request("klay_sendRawTransaction", [signedTransactionData], rpc, Bytes32.self)!.send()
        return parseReturn(error, response)
    }
    
    public func sendRawTransaction(_ transaction: AbstractTransaction) -> (CaverError?, result: Bytes32?) {
        let rawTransaction = try? transaction.getRLPEncoding()
        let (error, response) = RPC.Request("klay_sendRawTransaction", [rawTransaction], rpc, Bytes32.self)!.send()
        return parseReturn(error, response)
    }
    
    public func signTransaction(_ transaction: AbstractTransaction) -> (CaverError?, result: SignTransaction?) {
        if Utils.isEmptySig(transaction.signatures) {
            transaction.signatures.remove(at: 0)
        }
        
        let (error, response) = RPC.Request("klay_signTransaction", [transaction], rpc, SignTransaction.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getTransactionReceipt(_ transactionHash: String) -> (CaverError?, result: TransactionReceiptData?) {
        let (error, response) = RPC.Request("klay_getTransactionReceipt", [transactionHash], rpc, TransactionReceiptData.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getLogs(_ filterOption: KlayLogFilter) -> (CaverError?, result: KlayLogs?) {
        let params = KlayLogFilterParams(filterOption)
        let (error, response) = RPC.Request("klay_getLogs", params, rpc, KlayLogs.self)!.send()
        
        return parseReturn(error, response)
    }
    
    private func parseReturn<T: Any>(_ error: JSONRPCError?, _ response: Any?) -> (CaverError?, result: T?) {
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
