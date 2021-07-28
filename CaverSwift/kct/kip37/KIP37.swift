//
//  KIP37.swift
//  CaverSwift
//
//  Created by won on 2021/07/27.
//

import Foundation

open class KIP37: Contract {
    static let FUNCTION_URI = "uri"
    static let FUNCTION_BALANCE_OF = "balanceOf"
    static let FUNCTION_BALANCE_OF_BATCH = "balanceOfBatch"
    static let FUNCTION_SET_APPROVED_FOR_ALL = "setApprovalForAll"
    static let FUNCTION_IS_APPROVED_FOR_ALL = "isApprovedForAll"
    static let FUNCTION_TOTAL_SUPPLY = "totalSupply"
    static let FUNCTION_SAFE_TRANSFER_FROM = "safeTransferFrom"
    static let FUNCTION_SAFE_BATCH_TRANSFER_FROM = "safeBatchTransferFrom"
    static let FUNCTION_BURN = "burn"
    static let FUNCTION_BURN_BATCH = "burnBatch"
    static let FUNCTION_CREATE = "create"
    static let FUNCTION_MINT = "mint"
    static let FUNCTION_MINT_BATCH = "mintBatch"
    static let FUNCTION_PAUSED = "paused"
    static let FUNCTION_PAUSE = "pause"
    static let FUNCTION_UNPAUSE = "unpause"
    static let FUNCTION_IS_PAUSER = "isPauser"
    static let FUNCTION_ADD_PAUSER = "addPauser"
    static let FUNCTION_RENOUNCE_PAUSER = "renouncePauser"
    static let FUNCTION_IS_MINTER = "isMinter"
    static let FUNCTION_ADD_MINTER = "addMinter"
    static let FUNCTION_RENOUNCE_MINTER = "renounceMinter"
    static let FUNCTION_SUPPORTS_INTERFACE = "supportsInterface"
    
    public enum INTERFACE: String, CaseIterable {
        case IKIP37 = "IKIP37"
        case IKIP37_METADATA = "IKIP37Metatdata"
        case IKIP37_MINTABLE = "IKIP37Mintable"
        case IKIP37_BURNABLE = "IKIP37Burnable"
        case IKIP37_PAUSABLE = "IKIP37Pausable"
        
        func getName() -> String {
            return self.rawValue
        }
        
        func getId() -> String {
            switch self {
            case .IKIP37: return "0x6433ca1f"
            case .IKIP37_METADATA: return "0x0e89341c"
            case .IKIP37_MINTABLE: return "0xdfd9d9ec"
            case .IKIP37_BURNABLE: return "0x9e094e9e"
            case .IKIP37_PAUSABLE: return "0x0e8ffdb7"
            }
        }
    }
    
    public init(_ caver: Caver, _ contractAddress: String? = nil) throws {
        _ = KIP37ConstantData()
        try super.init(caver, KIP37ConstantData.ABI, contractAddress)
    }
    
    public static func deploy(_ caver: Caver, _ uri: String, _ deployer: String, _ wallet: IWallet? = nil) throws -> KIP37 {
        _ = KIP37ConstantData()
        
        let contractDeployParams = try ContractDeployParams(KIP37ConstantData.BINARY, uri)
        let sendOption = SendOptions(deployer, BigUInt(8000000))
        
        let kip17 = try KIP37(caver)
        kip17.wallet = wallet
        _ = try kip17.deploy(contractDeployParams, sendOption)
        return kip17
    }
    
    public static func detectInterface(_ caver: Caver, _ contractAddress: String) throws -> [String:Bool] {
        let kip13 = try KIP13(caver, contractAddress)
        
        if !kip13.isImplementedKIP13Interface() {
            throw CaverError.RuntimeException("This contract does not support KIP-13.")
        }
        
        var result: [String:Bool] = [:]
        INTERFACE.allCases.forEach {
            result[$0.getName()] = kip13.sendQuery($0.getId())
        }
        return result
    }
        
    public func clone(_ tokenAddress: String = "") -> KIP37? {
        var kip17: KIP37?
        if tokenAddress.isEmpty {
            kip17 = try? KIP37(caver, contractAddress)
        } else {
            kip17 = try? KIP37(caver, tokenAddress)
        }
        kip17?.wallet = wallet
        return kip17
    }
    
    public func detectInterface() throws -> [String:Bool] {
        guard let contractAddress = contractAddress else {
            throw CaverError.invalidValue
        }
        return try KIP37.detectInterface(caver, contractAddress)
    }
    
    public func uri(_ tokenId: BigUInt) throws -> String? {
        guard let result = call(KIP37.FUNCTION_URI, tokenId),
              var uri = result[0].value as? String else {
            throw CaverError.invalidValue
        }
        
        if uri.contains("{id}") {
            let hexTokenID = Utils.toHexStringZeroPadded(tokenId, 64, false)
            uri = uri.replacingOccurrences(of: "{id}", with: hexTokenID)
        }
        return uri
    }
    
    public func balanceOf(_ account: String, _ tokenId: String) throws -> BigUInt? {
        guard let tokenId = BigUInt(hex: tokenId) else { throw CaverError.invalidValue }
        return try balanceOf(account, tokenId)
    }
    
    public func balanceOf(_ account: String, _ tokenId: BigUInt) throws -> BigUInt? {
        let result = call(KIP37.FUNCTION_BALANCE_OF, account, tokenId)
        return result?[0].value as? BigUInt
    }
    
    public func balanceOfBatch(_ accounts: [String], _ tokenIds: [String]) throws -> [BigUInt]? {
        let arr: [BigUInt] = try tokenIds.map {
            guard let val = BigUInt(hex: $0) else { throw CaverError.invalidValue }
            return val
        }
        return try balanceOfBatch(accounts, arr)
    }
    
    public func balanceOfBatch(_ accounts: [String], _ tokenIds: [BigUInt]) throws -> [BigUInt]? {
        guard let result = call(KIP37.FUNCTION_BALANCE_OF_BATCH, accounts, tokenIds),
              let batchList = result[0].value as? DynamicArray else {
            throw CaverError.invalidValue
        }
        return batchList.values as? [BigUInt]
    }
    
    public func safeTransferFrom(_ from: String, _ to: String, _ tokenId: String, _ value: BigUInt, _ data: String = "",_ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        guard let tokenId = BigUInt(hex: tokenId) else { throw CaverError.invalidValue }
        
        return try safeTransferFrom(from, to, tokenId, value, data, sendParam)
    }
    
    public func safeTransferFrom(_ from: String, _ to: String, _ tokenId: BigUInt, _ value: BigUInt, _ data: String = "",_ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        guard let sendParam = sendParam ?? defaultSendOptions else { throw CaverError.invalidValue }
        let sendOption = try KIP37.determineSendOptions(self, sendParam, KIP37.FUNCTION_SAFE_TRANSFER_FROM, [from, to, tokenId, value, data])
        
        let receiptData = try send(sendOption, KIP37.FUNCTION_SAFE_TRANSFER_FROM, from, to, tokenId, value, data)
        return receiptData
    }
    
    public func safeBatchTransferFrom(_ from: String, _ to: String, _ tokenIds: [String], _ amounts: [BigUInt], _ data: String = "", _ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        let tokenIdArr: [BigUInt] = try tokenIds.map {
            guard let val = BigUInt(hex: $0) else { throw CaverError.invalidValue }
            return val
        }
        return try safeBatchTransferFrom(from, to, tokenIdArr, amounts, data, sendParam)
    }
    
    public func safeBatchTransferFrom(_ from: String, _ to: String, _ tokenIds: [BigUInt], _ amounts: [BigUInt], _ data: String = "", _ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        guard let sendParam = sendParam ?? defaultSendOptions else { throw CaverError.invalidValue }
        let sendOption = try KIP37.determineSendOptions(self, sendParam, KIP37.FUNCTION_SAFE_BATCH_TRANSFER_FROM, [from, to, tokenIds, amounts, data])
        
        let receiptData = try send(sendOption, KIP37.FUNCTION_SAFE_BATCH_TRANSFER_FROM, from, to, tokenIds, amounts, data)
        return receiptData
    }
    
    public func setApprovalForAll(_ operate: String, _ approved: Bool, _ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        guard let sendParam = sendParam ?? defaultSendOptions else { throw CaverError.invalidValue }
        let sendOption = try KIP37.determineSendOptions(self, sendParam, KIP37.FUNCTION_SET_APPROVED_FOR_ALL, [operate, approved])
        
        let receiptData = try send(sendOption, KIP37.FUNCTION_SET_APPROVED_FOR_ALL, operate, approved)
        return receiptData
    }
    
    public func isApprovedForAll(_ owner: String, _ operate: String) throws -> Bool? {
        let result = call(KIP37.FUNCTION_IS_APPROVED_FOR_ALL, owner, operate)
        return result?[0].value as? Bool
    }
    
    public func totalSupply(_ tokenId: String) throws -> BigUInt? {
        guard let tokenId = BigUInt(hex: tokenId) else { throw CaverError.invalidValue }
        return try totalSupply(tokenId)
    }
        
    public func totalSupply(_ tokenId: BigUInt) throws -> BigUInt? {
        let result = call(KIP37.FUNCTION_TOTAL_SUPPLY, tokenId)
        return result?[0].value as? BigUInt
    }
    
    public func create(_ tokenId: String, _ initialSupply: BigUInt, _ uri: String = "",_ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        guard let tokenId = BigUInt(hex: tokenId) else { throw CaverError.invalidValue }
        
        return try create(tokenId, initialSupply, uri, sendParam)
    }
    
    public func create(_ tokenId: BigUInt, _ initialSupply: BigUInt, _ uri: String = "",_ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        guard let sendParam = sendParam ?? defaultSendOptions else { throw CaverError.invalidValue }
        let sendOption = try KIP37.determineSendOptions(self, sendParam, KIP37.FUNCTION_CREATE, [tokenId, initialSupply, uri])
        
        let receiptData = try send(sendOption, KIP37.FUNCTION_CREATE, tokenId, initialSupply, uri)
        return receiptData
    }
    
    public func mint(_ to: String, _ tokenId: String, _ value: BigUInt, _ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        guard let tokenId = BigUInt(hex: tokenId) else { throw CaverError.invalidValue }
        return try mint(to, tokenId, value, sendParam)
    }
    
    public func mint(_ to: String, _ tokenId: BigUInt, _ value: BigUInt, _ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        guard let sendParam = sendParam ?? defaultSendOptions else { throw CaverError.invalidValue }
        let sendOption = try KIP37.determineSendOptionsWithSolidityType(self, sendParam, KIP37.FUNCTION_MINT, [Uint256(tokenId), Address(to), Uint256(value)])
        
        let receiptData = try sendWithSolidityType(sendOption, KIP37.FUNCTION_MINT, Uint256(tokenId), Address(to), Uint256(value))
        return receiptData
    }
    
    public func mint(_ toList: [String], _ tokenId: BigUInt, _ values: [BigUInt], _ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        let valueList = values.map { Uint256($0) }
        let addressList = toList.map { Address($0) }
        
        let tokenIdSol = Uint256(tokenId)
        let toListSol = DynamicArray(addressList)
        let valuesSol = DynamicArray(valueList)
        
        guard let sendParam = sendParam ?? defaultSendOptions else { throw CaverError.invalidValue }
        let sendOption = try KIP37.determineSendOptionsWithSolidityType(self, sendParam, KIP37.FUNCTION_MINT, [tokenIdSol, toListSol, valuesSol])
        
        let receiptData = try sendWithSolidityType(sendOption, KIP37.FUNCTION_MINT, tokenIdSol, toListSol, valuesSol)
        return receiptData
    }
    
    public func mintBatch(_ to: String, _ tokenIds: [String], _ values: [BigUInt], _ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        let tokenIdArr: [BigUInt] = try tokenIds.map {
            guard let val = BigUInt(hex: $0) else { throw CaverError.invalidValue }
            return val
        }
        return try mintBatch(to, tokenIdArr, values, sendParam)
    }
    
    public func mintBatch(_ to: String, _ tokenIds: [BigUInt], _ values: [BigUInt], _ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        let tokenIdList = tokenIds.map { Uint256($0) }
        let valueList = values.map { Uint256($0) }
        
        let toSol = Address(to)
        let tokenIdsSol = DynamicArray(tokenIdList)
        let valuesSol = DynamicArray(valueList)
        
        guard let sendParam = sendParam ?? defaultSendOptions else { throw CaverError.invalidValue }
        let sendOption = try KIP37.determineSendOptionsWithSolidityType(self, sendParam, KIP37.FUNCTION_MINT_BATCH, [toSol, tokenIdsSol, valuesSol])
        
        let receiptData = try sendWithSolidityType(sendOption, KIP37.FUNCTION_MINT_BATCH, toSol, tokenIdsSol, valuesSol)
        return receiptData
    }
    
    public func isMinter(_ account: String) throws -> Bool? {
        let callObject = CallObject.createCallObject()
        let result = call(callObject, KIP37.FUNCTION_IS_MINTER, account)
        return result?[0].value as? Bool
    }
    
    public func addMinter(_ account: String, _ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        guard let sendParam = sendParam ?? defaultSendOptions else { throw CaverError.invalidValue }
        let sendOption = try KIP37.determineSendOptions(self, sendParam, KIP37.FUNCTION_ADD_MINTER, [account])
        
        let receiptData = try send(sendOption, KIP37.FUNCTION_ADD_MINTER, account)
        return receiptData
    }
    
    public func renounceMinter(_ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        guard let sendParam = sendParam ?? defaultSendOptions else { throw CaverError.invalidValue }
        let sendOption = try KIP37.determineSendOptions(self, sendParam, KIP37.FUNCTION_RENOUNCE_MINTER)
        
        let receiptData = try send(sendOption, KIP37.FUNCTION_RENOUNCE_MINTER)
        return receiptData
    }
    
    public func burn(_ address: String, _ tokenId: String, _ value: BigUInt,_ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        guard let tokenId = BigUInt(hex: tokenId) else { throw CaverError.invalidValue }
        
        return try burn(address, tokenId, value, sendParam)
    }
    
    public func burn(_ address: String, _ tokenId: BigUInt, _ value: BigUInt,_ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        guard let sendParam = sendParam ?? defaultSendOptions else { throw CaverError.invalidValue }
        let sendOption = try KIP37.determineSendOptions(self, sendParam, KIP37.FUNCTION_BURN, [address, tokenId, value])
        
        let receiptData = try send(sendOption, KIP37.FUNCTION_BURN, address, tokenId, value)
        return receiptData
    }
    
    public func burnBatch(_ address: String, _ tokenIds: [String], _ values: [BigUInt], _ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        let tokenIdArr: [BigUInt] = try tokenIds.map {
            guard let val = BigUInt(hex: $0) else { throw CaverError.invalidValue }
            return val
        }
        return try burnBatch(address, tokenIdArr, values, sendParam)
    }
    
    public func burnBatch(_ address: String, _ tokenIds: [BigUInt], _ values: [BigUInt], _ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        guard let sendParam = sendParam ?? defaultSendOptions else { throw CaverError.invalidValue }
        let sendOption = try KIP37.determineSendOptions(self, sendParam, KIP37.FUNCTION_BURN_BATCH, [address, tokenIds, values])
        
        let receiptData = try send(sendOption, KIP37.FUNCTION_BURN_BATCH, address, tokenIds, values)
        return receiptData
    }
    
    public func paused() throws -> Bool? {
        let callObject = CallObject.createCallObject()
        let result = try getMethod(KIP37.FUNCTION_PAUSED).call(nil, callObject)
        return result?[0].value as? Bool
    }
    
    public func paused(_ tokenId: String) throws -> Bool? {
        guard let tokenId = BigUInt(hex: tokenId) else { throw CaverError.invalidValue }
        return try paused(tokenId)
    }
    
    public func paused(_ tokenId: BigUInt) throws -> Bool? {
        let result = call(KIP37.FUNCTION_PAUSED, tokenId)
        return result?[0].value as? Bool
    }
    
    public func pause(_ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        guard let sendParam = sendParam ?? defaultSendOptions else { throw CaverError.invalidValue }
        let sendOption = try KIP37.determineSendOptions(self, sendParam, KIP37.FUNCTION_PAUSE)
        
        let receiptData = try send(sendOption, KIP37.FUNCTION_PAUSE)
        return receiptData
    }
    
    public func unpause(_ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        guard let sendParam = sendParam ?? defaultSendOptions else { throw CaverError.invalidValue }
        let sendOption = try KIP37.determineSendOptions(self, sendParam, KIP37.FUNCTION_UNPAUSE)
        
        let receiptData = try send(sendOption, KIP37.FUNCTION_UNPAUSE)
        return receiptData
    }
    
    public func pause(_ tokenId: String, _ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        guard let tokenId = BigUInt(hex: tokenId) else { throw CaverError.invalidValue }
        
        return try pause(tokenId, sendParam)
    }
    
    public func pause(_ tokenId: BigUInt, _ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        guard let sendParam = sendParam ?? defaultSendOptions else { throw CaverError.invalidValue }
        let sendOption = try KIP37.determineSendOptions(self, sendParam, KIP37.FUNCTION_PAUSE, [tokenId])
        
        let receiptData = try send(sendOption, KIP37.FUNCTION_PAUSE, tokenId)
        return receiptData
    }
    
    public func unpause(_ tokenId: String, _ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        guard let tokenId = BigUInt(hex: tokenId) else { throw CaverError.invalidValue }
        
        return try unpause(tokenId, sendParam)
    }
    
    public func unpause(_ tokenId: BigUInt, _ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        guard let sendParam = sendParam ?? defaultSendOptions else { throw CaverError.invalidValue }
        let sendOption = try KIP37.determineSendOptions(self, sendParam, KIP37.FUNCTION_UNPAUSE, [tokenId])
        
        let receiptData = try send(sendOption, KIP37.FUNCTION_UNPAUSE, tokenId)
        return receiptData
    }
    
    public func isPauser(_ account: String) throws -> Bool? {
        let callObject = CallObject.createCallObject()
        let result = try getMethod(KIP37.FUNCTION_IS_PAUSER).call([account], callObject)
        return result?[0].value as? Bool
    }
    
    public func addPauser(_ account: String, _ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        guard let sendParam = sendParam ?? defaultSendOptions else { throw CaverError.invalidValue }
        let sendOption = try KIP37.determineSendOptions(self, sendParam, KIP37.FUNCTION_ADD_PAUSER, [account])
        
        let receiptData = try send(sendOption, KIP37.FUNCTION_ADD_PAUSER, account)
        return receiptData
    }
    
    public func renouncePauser(_ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        guard let sendParam = sendParam ?? defaultSendOptions else { throw CaverError.invalidValue }
        let sendOption = try KIP37.determineSendOptions(self, sendParam, KIP37.FUNCTION_RENOUNCE_PAUSER)
        
        let receiptData = try send(sendOption, KIP37.FUNCTION_RENOUNCE_PAUSER)
        return receiptData
    }
    
    public func supportsInterface(_ interfaceId: String) throws -> Bool? {
        let callObject = CallObject.createCallObject()
        let result = try getMethod(KIP37.FUNCTION_SUPPORTS_INTERFACE).call([interfaceId], callObject)
        return result?[0].value as? Bool
    }
        
    private static func determineSendOptions(_ kip17: KIP37, _ sendOptions: SendOptions, _ functionName: String, _ argument: [Any] = []) throws -> SendOptions {
        var from = kip17.defaultSendOptions?.from
        var gas = kip17.defaultSendOptions?.gas
        var value = kip17.defaultSendOptions?.value
        
        if sendOptions.from != nil {
            from = sendOptions.from
        }
        
        if sendOptions.gas == nil {
            if gas == nil {
                let callObject = CallObject.createCallObject(sendOptions.from)
                let estimateGas = try estimateGas(kip17, functionName, callObject, argument)
                gas = estimateGas.hexa
            }
        } else {
            gas = sendOptions.gas
        }
        
        if sendOptions.value != "0x0" {
            value = sendOptions.value
        }
        
        return SendOptions(from, gas, value!)
    }
    
    private static func determineSendOptionsWithSolidityType(_ kip17: KIP37, _ sendOptions: SendOptions, _ functionName: String, _ argument: [Type] = []) throws -> SendOptions {
        var from = kip17.defaultSendOptions?.from
        var gas = kip17.defaultSendOptions?.gas
        var value = kip17.defaultSendOptions?.value
        
        if sendOptions.from != nil {
            from = sendOptions.from
        }
        
        if sendOptions.gas == nil {
            if gas == nil {
                let callObject = CallObject.createCallObject(sendOptions.from)
                let estimateGas = try estimateGasWithSolidityType(kip17, functionName, callObject, argument)
                gas = estimateGas.hexa
            }
        } else {
            gas = sendOptions.gas
        }
        
        if sendOptions.value != "0x0" {
            value = sendOptions.value
        }
        
        return SendOptions(from, gas, value!)
    }
    
    private static func estimateGas(_ kip17: KIP37, _ functionName: String, _ callObject: CallObject, _ argument: [Any]) throws -> BigUInt {
        guard let gas = try? kip17.getMethod(functionName).estimateGas(argument, callObject),
              let gas = BigUInt(hex: gas),
              let bigDecimal = BDouble(gas.decimal),
              let result = BigUInt((bigDecimal * 1.7).rounded().description) else {
            throw CaverError.invalidValue
        }
        
        return result
    }
    
    private static func estimateGasWithSolidityType(_ kip17: KIP37, _ functionName: String, _ callObject: CallObject, _ argument: [Type]) throws -> BigUInt {
        guard let gas = try? kip17.getMethod(functionName).estimateGasWithSolidityWrapper(argument, callObject),
              let gas = BigUInt(hex: gas),
              let bigDecimal = BDouble(gas.decimal),
              let result = BigUInt((bigDecimal * 1.7).rounded().description) else {
            throw CaverError.invalidValue
        }
        
        return result
    }
}
