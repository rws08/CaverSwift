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
    
    public func getAccount(_ address: String, _ blockNumber: Int) -> (CaverError?, result: AccountData?) {
        getAccount(address, DefaultBlockParameterName.Number(blockNumber))
    }
    
    public func getAccount(_ address: String, _ blockTag: DefaultBlockParameterName = .Latest) -> (CaverError?, result: AccountData?) {
        let(error, response) = RPC.Request("klay_getAccount", [address, blockTag.stringValue], rpc, AccountData.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getAccountKey(_ address: String, _ blockNumber: Int) -> (CaverError?, result: AccountKey?) {
        getAccountKey(address, DefaultBlockParameterName.Number(blockNumber))
    }
    
    public func getAccountKey(_ address: String, _ blockTag: DefaultBlockParameterName = .Latest) -> (CaverError?, result: AccountKey?) {
        let(error, response) = RPC.Request("klay_getAccountKey", [address, blockTag.stringValue], rpc, AccountKey.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getBalance(_ address: String) -> (CaverError?, result: Quantity?) {
        let(error, response) = RPC.Request("klay_getBalance", [address, DefaultBlockParameterName.Latest.stringValue], rpc, Quantity.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getBalance(_ address: String, _ blockNumber: Int) -> (CaverError?, result: Quantity?) {
        getBalance(address, DefaultBlockParameterName.Number(blockNumber))
    }
    
    public func getBalance(_ address: String, _ blockTag: DefaultBlockParameterName = .Latest) -> (CaverError?, result: Quantity?) {
        let(error, response) = RPC.Request("klay_getBalance", [address, blockTag.stringValue], rpc, Quantity.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getCode(_ address: String, _ blockNumber: Int) -> (CaverError?, result: Bytes?) {
        getCode(address, DefaultBlockParameterName.Number(blockNumber))
    }
    
    public func getCode(_ address: String, _ blockTag: DefaultBlockParameterName = .Latest) -> (CaverError?, result: Bytes?) {
        let(error, response) = RPC.Request("klay_getCode", [address, blockTag.stringValue], rpc, Bytes.self)!.send()
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
    
    public func isContractAccount(_ address: String, _ blockNumber: Int) -> (CaverError?, result: Bool?) {
        isContractAccount(address, DefaultBlockParameterName.Number(blockNumber))
    }
    
    public func isContractAccount(_ address: String, _ blockTag: DefaultBlockParameterName = .Latest) -> (CaverError?, result: Bool?) {
        let(error, response) = RPC.Request("klay_isContractAccount", [address, blockTag.stringValue], rpc, Bool.self)!.send()
        return parseReturn(error, response)
    }
    
    public func sign(_ address: String, _ message: String) -> (CaverError?, result: Bytes?) {
        let(error, response) = RPC.Request("klay_sign", [address, message], rpc, Bytes.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getBlockNumber() -> (CaverError?, result: Quantity?) {
        let(error, response) = RPC.Request("klay_blockNumber", Array<String>(), rpc, Quantity.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getBlockByNumber(_ blockNumber: Int, _ isFullTransaction: Bool = true) -> (CaverError?, result: BlockData?) {
        getBlockByNumber(DefaultBlockParameterName.Number(blockNumber), isFullTransaction)
    }
    
    public func getBlockByNumber(_ blockTag: DefaultBlockParameterName = .Latest, _ isFullTransaction: Bool = true) -> (CaverError?, result: BlockData?) {
        let params = BlockByNumber(blockTag.stringValue, isFullTransaction)
        let(error, response) = RPC.Request("klay_getBlockByNumber", params, rpc, BlockData.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getBlockByHash(_ blockHash: String, _ isFullTransaction: Bool = true) -> (CaverError?, result: BlockData?) {
        let params = BlockByHash(blockHash, isFullTransaction)
        let(error, response) = RPC.Request("klay_getBlockByHash", params, rpc, BlockData.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getBlockReceipts(_ blockHash: String) -> (CaverError?, result: [TransactionReceipt]?) {
        let(error, response) = RPC.Request("klay_getBlockReceipts", [blockHash], rpc, [TransactionReceipt].self)!.send()
        return parseReturn(error, response)
    }
    
    public func getBlockTransactionCountByNumber(_ blockNumber: Int) -> (CaverError?, result: Quantity?) {
        getBlockTransactionCountByNumber(DefaultBlockParameterName.Number(blockNumber))
    }
    
    public func getBlockTransactionCountByNumber(_ blockTag: DefaultBlockParameterName = .Latest) -> (CaverError?, result: Quantity?) {
        let(error, response) = RPC.Request("klay_getBlockTransactionCountByNumber", [blockTag.stringValue], rpc, Quantity.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getTransactionCountByNumber(_ blockNumber: Int) -> (CaverError?, result: Quantity?) {
        getBlockTransactionCountByNumber(DefaultBlockParameterName.Number(blockNumber))
    }
    
    public func getTransactionCountByNumber(_ blockTag: DefaultBlockParameterName = .Latest) -> (CaverError?, result: Quantity?) {
        getBlockTransactionCountByNumber(blockTag)
    }
    
    public func getBlockTransactionCountByHash(_ blockHash: String) -> (CaverError?, result: Quantity?) {
        let(error, response) = RPC.Request("klay_getBlockTransactionCountByHash", [blockHash], rpc, Quantity.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getTransactionCountByHash(_ blockHash: String) -> (CaverError?, result: Quantity?) {
        getBlockTransactionCountByHash(blockHash)
    }
    
    public func getBlockWithConsensusInfoByHash(_ blockHash: String) -> (CaverError?, result: BlockWithConsensusInfo?) {
        let(error, response) = RPC.Request("klay_getBlockWithConsensusInfoByHash", [blockHash], rpc, BlockWithConsensusInfo.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getBlockWithConsensusInfoByNumber(_ blockNumber: Int) -> (CaverError?, result: BlockWithConsensusInfo?) {
        getBlockWithConsensusInfoByNumber(DefaultBlockParameterName.Number(blockNumber))
    }
    
    public func getBlockWithConsensusInfoByNumber(_ blockTag: DefaultBlockParameterName = .Latest) -> (CaverError?, result: BlockWithConsensusInfo?) {
        let(error, response) = RPC.Request("klay_getBlockWithConsensusInfoByNumber", [blockTag.stringValue], rpc, BlockWithConsensusInfo.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getCommittee(_ blockNumber: Int) -> (CaverError?, result: Addresses?) {
        getCommittee(DefaultBlockParameterName.Number(blockNumber))
    }
    
    public func getCommittee(_ blockTag: DefaultBlockParameterName = .Latest) -> (CaverError?, result: Addresses?) {
        let(error, response) = RPC.Request("klay_getCommittee", [blockTag.stringValue], rpc, Addresses.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getCommitteeSize(_ blockNumber: Int) -> (CaverError?, result: Quantity?) {
        getCommitteeSize(DefaultBlockParameterName.Number(blockNumber))
    }
    
    public func getCommitteeSize(_ blockTag: DefaultBlockParameterName = .Latest) -> (CaverError?, result: Quantity?) {
        let(error, response) = RPC.Request("klay_getCommitteeSize", [blockTag.stringValue], rpc, Quantity.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getCouncil(_ blockNumber: Int) -> (CaverError?, result: Addresses?) {
        getCouncil(DefaultBlockParameterName.Number(blockNumber))
    }
    
    public func getCouncil(_ blockTag: DefaultBlockParameterName = .Latest) -> (CaverError?, result: Addresses?) {
        let(error, response) = RPC.Request("klay_getCouncil", [blockTag.stringValue], rpc, Addresses.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getCouncilSize(_ blockNumber: Int) -> (CaverError?, result: Quantity?) {
        getCouncilSize(DefaultBlockParameterName.Number(blockNumber))
    }
    
    public func getCouncilSize(_ blockTag: DefaultBlockParameterName = .Latest) -> (CaverError?, result: Quantity?) {
        let(error, response) = RPC.Request("klay_getCouncilSize", [blockTag.stringValue], rpc, Quantity.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getStorageAt(_ address: String, _ position: DefaultBlockParameterName, _ blockNumber: Int) -> (CaverError?, result: Quantity?) {
        getStorageAt(address, position, DefaultBlockParameterName.Number(blockNumber))
    }
    
    public func getStorageAt(_ address: String, _ position: DefaultBlockParameterName, _ blockTag: DefaultBlockParameterName = .Latest) -> (CaverError?, result: Quantity?) {
        let(error, response) = RPC.Request("klay_getStorageAt", [address, position.stringValue, blockTag.stringValue], rpc, Quantity.self)!.send()
        return parseReturn(error, response)
    }
    
    public func isSyncing() -> (CaverError?, result: KlaySyncing?) {
        let(error, response) = RPC.Request("klay_syncing", Array<String>(), rpc, KlaySyncing.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getChainID() -> (CaverError?, result: Quantity?) {
        let(error, response) = RPC.Request("klay_chainID", Array<String>(), rpc, Quantity.self)!.send()
        return parseReturn(error, response)
    }
    
    func call(_ callObject: CallObject, _ blockNumber: Quantity) throws -> (CaverError?, result: String?) {
        var callObject = callObject
        callObject.block = blockNumber.toString
        let(error, response) = RPC.Request("klay_call", callObject, rpc, String.self)!.send()
        return parseReturn(error, response)
    }
        
    func call(_ callObject: CallObject, _ blockTag: DefaultBlockParameterName = .Latest) throws -> (CaverError?, result: String?) {
        var callObject = callObject
        callObject.block = blockTag.stringValue
        let(error, response) = RPC.Request("klay_call", callObject, rpc, String.self)!.send()
        return parseReturn(error, response)
    }
    
    func estimateGas(_ callObject: CallObject) -> (CaverError?, result: Quantity?) {
        let(error, response) = RPC.Request("klay_estimateGas", callObject, rpc, Quantity.self)!.send()
        return parseReturn(error, response)
    }
    
    public func estimateComputationCost(_ callObject: CallObject, _ blockNumber: Int) -> (CaverError?, result: Quantity?) {
        estimateComputationCost(callObject, DefaultBlockParameterName.Number(blockNumber))
    }
    
    public func estimateComputationCost(_ callObject: CallObject, _ blockTag: DefaultBlockParameterName = .Latest) -> (CaverError?, result: Quantity?) {
        var callObject = callObject
        callObject.block = blockTag.stringValue
        let(error, response) = RPC.Request("klay_estimateComputationCost", callObject, rpc, Quantity.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getTransactionByBlockHashAndIndex(_ blockHash: String, _ index: Int) -> (CaverError?, result: Transaction?) {
        let(error, response) = RPC.Request("klay_getTransactionByBlockHashAndIndex", [blockHash, DefaultBlockParameterName.Number(index).stringValue], rpc, Transaction.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getTransactionByBlockNumberAndIndex(_ blockNumber: Int, _ index: Int) -> (CaverError?, result: Transaction?) {
        getTransactionByBlockNumberAndIndex(.Number(blockNumber), .Number(index))
    }
    
    public func getTransactionByBlockNumberAndIndex(_ blockTag: DefaultBlockParameterName, _ index: DefaultBlockParameterName) -> (CaverError?, result: Transaction?) {
        let(error, response) = RPC.Request("klay_getTransactionByBlockNumberAndIndex", [blockTag.stringValue, index.stringValue], rpc, Transaction.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getTransactionByHash(_ txHash: String) -> (CaverError?, result: Transaction?) {
        let(error, response) = RPC.Request("klay_getTransactionByHash", [txHash], rpc, Transaction.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getTransactionBySenderTxHash(_ senderTxHash: String) -> (CaverError?, result: Transaction?) {
        let(error, response) = RPC.Request("klay_getTransactionBySenderTxHash", [senderTxHash], rpc, Transaction.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getTransactionReceipt(_ transactionHash: String) -> (CaverError?, result: TransactionReceipt?) {
        let (error, response) = RPC.Request("klay_getTransactionReceipt", [transactionHash], rpc, TransactionReceipt.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getTransactionReceiptBySenderTxHash(_ transactionHash: String) -> (CaverError?, result: TransactionReceipt?) {
        let (error, response) = RPC.Request("klay_getTransactionReceiptBySenderTxHash", [transactionHash], rpc, TransactionReceipt.self)!.send()
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
    
    public func sendTransaction(_ transaction: AbstractTransaction) -> (CaverError?, result: Bytes32?) {
        let (error, response) = RPC.Request("klay_sendTransaction", [transaction], rpc, Bytes32.self)!.send()
        return parseReturn(error, response)
    }
    
    public func sendTransactionAsFeePayer(_ transaction: AbstractFeeDelegatedTransaction) -> (CaverError?, result: Bytes32?) {
        let (error, response) = RPC.Request("klay_sendTransactionAsFeePayer", [transaction], rpc, Bytes32.self)!.send()
        return parseReturn(error, response)
    }
    
    public func signTransaction(_ transaction: AbstractTransaction) -> (CaverError?, result: SignTransaction?) {
        if Utils.isEmptySig(transaction.signatures) {
            transaction.signatures.remove(at: 0)
        }
        
        let (error, response) = RPC.Request("klay_signTransaction", [transaction], rpc, SignTransaction.self)!.send()
        return parseReturn(error, response)
    }
    
    public func signTransactionAsFeePayer(_ transaction: AbstractFeeDelegatedTransaction) -> (CaverError?, result: SignTransaction?) {
        if Utils.isEmptySig(transaction.signatures) {
            transaction.signatures.remove(at: 0)
        }
        
        let (error, response) = RPC.Request("klay_signTransactionAsFeePayer", [transaction], rpc, SignTransaction.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getDecodedAnchoringTransaction(_ hash: String) -> (CaverError?, result: DecodeAnchoringTransaction?) {
        let (error, response) = RPC.Request("klay_getDecodedAnchoringTransactionByHash", [hash], rpc, DecodeAnchoringTransaction.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getClientVersion() -> (CaverError?, result: Bytes?) {
        let(error, response) = RPC.Request("klay_clientVersion", Array<String>(), rpc, Bytes.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getGasPrice() -> (CaverError?, result: Quantity?) {
        let(error, response) = RPC.Request("klay_gasPrice", Array<String>(), rpc, Quantity.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getGasPriceAt(_ blockNumber: Int) -> (CaverError?, result: Quantity?) {
        getGasPriceAt(DefaultBlockParameterName.Number(blockNumber))
    }
    
    public func getGasPriceAt(_ blockTag: DefaultBlockParameterName = .Latest) -> (CaverError?, result: Quantity?) {
        let(error, response) = RPC.Request("klay_gasPriceAt", [blockTag.stringValue], rpc, Quantity.self)!.send()
        return parseReturn(error, response)
    }
    
    public func isParallelDBWrite() -> (CaverError?, result: Bool?) {
        let(error, response) = RPC.Request("klay_isParallelDBWrite", Array<String>(), rpc, Bool.self)!.send()
        return parseReturn(error, response)
    }
    
    public func isSenderTxHashIndexingEnabled() -> (CaverError?, result: Bool?) {
        let(error, response) = RPC.Request("klay_isSenderTxHashIndexingEnabled", Array<String>(), rpc, Bool.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getProtocolVersion() -> (CaverError?, result: Bytes?) {
        let(error, response) = RPC.Request("klay_protocolVersion", Array<String>(), rpc, Bytes.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getRewardbase() -> (CaverError?, result: Bytes20?) {
        let(error, response) = RPC.Request("klay_rewardbase", Array<String>(), rpc, Bytes20.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getFilterChanges(_ filterId: String) -> (CaverError?, result: KlayLogs?) {
        let(error, response) = RPC.Request("klay_getFilterChanges", [filterId], rpc, KlayLogs.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getFilterLogs(_ filterId: String) -> (CaverError?, result: KlayLogs?) {
        let(error, response) = RPC.Request("klay_getFilterLogs", [filterId], rpc, KlayLogs.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getLogs(_ filterOption: KlayLogFilter) -> (CaverError?, result: KlayLogs?) {
        let (error, response) = RPC.Request("klay_getLogs", [filterOption], rpc, KlayLogs.self)!.send()
        
        return parseReturn(error, response)
    }
    
    public func newBlockFilter() -> (CaverError?, result: Quantity?) {
        let(error, response) = RPC.Request("klay_newBlockFilter", Array<String>(), rpc, Quantity.self)!.send()
        return parseReturn(error, response)
    }
    
    public func newFilter(_ filterOption: KlayFilter) -> (CaverError?, result: Quantity?) {
        let(error, response) = RPC.Request("klay_newFilter", [filterOption], rpc, Quantity.self)!.send()
        return parseReturn(error, response)
    }
    
    public func newPendingTransactionFilter() -> (CaverError?, result: Quantity?) {
        let(error, response) = RPC.Request("klay_newPendingTransactionFilter", Array<String>(), rpc, Quantity.self)!.send()
        return parseReturn(error, response)
    }
    
    public func uninstallFilter(_ filterId: String) -> (CaverError?, result: Bool?) {
        let(error, response) = RPC.Request("klay_uninstallFilter", [filterId], rpc, Bool.self)!.send()
        return parseReturn(error, response)
    }
    
    public func sha3(_ data: String) -> (CaverError?, result: Bytes?) {
        let(error, response) = RPC.Request("klay_sha3", [data], rpc, Bytes.self)!.send()
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
    
    struct BlockByNumber: Encodable {
        internal init(_ blockTag: String, _ isFullTransaction: Bool) {
            self.blockTag = blockTag
            self.isFullTransaction = isFullTransaction
        }
        
        let blockTag: String
        let isFullTransaction: Bool
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.unkeyedContainer()
            try container.encode(blockTag)
            try container.encode(isFullTransaction)
        }
    }
    
    struct BlockByHash: Encodable {
        internal init(_ blockHash: String, _ isFullTransaction: Bool) {
            self.blockHash = blockHash
            self.isFullTransaction = isFullTransaction
        }
        
        let blockHash: String
        let isFullTransaction: Bool
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.unkeyedContainer()
            try container.encode(blockHash)
            try container.encode(isFullTransaction)
        }
    }
}
