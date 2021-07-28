//
//  KIP17.swift
//  CaverSwift
//
//  Created by won on 2021/07/27.
//

import Foundation

open class KIP17: Contract {
    static let FUNCTION_ADD_MINTER = "addMinter"
    static let FUNCTION_ADD_PAUSER = "addPauser"
    static let FUNCTION_APPROVE = "approve"
    static let FUNCTION_BALANCE_OF = "balanceOf"
    static let FUNCTION_BURN = "burn"
    static let FUNCTION_GET_APPROVED = "getApproved"
    static let FUNCTION_IS_APPROVED_FOR_ALL = "isApprovedForAll"
    static let FUNCTION_IS_MINTER = "isMinter"
    static let FUNCTION_IS_PAUSER = "isPauser"
    static let FUNCTION_MINT = "mint"
    static let FUNCTION_MINT_WITH_TOKEN_URI = "mintWithTokenURI"
    static let FUNCTION_NAME = "name"
    static let FUNCTION_OWNER_OF = "ownerOf"
    static let FUNCTION_PAUSE = "pause"
    static let FUNCTION_PAUSED = "paused"
    static let FUNCTION_RENOUNCE_MINTER = "renounceMinter"
    static let FUNCTION_RENOUNCE_PAUSER = "renouncePauser"
    static let FUNCTION_SAFE_TRANSFER_FROM = "safeTransferFrom"
    static let FUNCTION_SET_APPROVAL_FOR_ALL = "setApprovalForAll"
    static let FUNCTION_SUPPORTS_INTERFACE = "supportsInterface"
    static let FUNCTION_SYMBOL = "symbol"
    static let FUNCTION_TOKEN_BY_INDEX = "tokenByIndex"
    static let FUNCTION_TOKEN_OF_OWNER_BY_INDEX = "tokenOfOwnerByIndex"
    static let FUNCTION_TOKEN_URI = "tokenURI"
    static let FUNCTION_TOTAL_SUPPLY = "totalSupply"
    static let FUNCTION_TRANSFER_FROM = "transferFrom"
    static let FUNCTION_UNPAUSE = "unpause"
    
    public enum INTERFACE: String, CaseIterable {
        case IKIP17 = "IKIP17"
        case IKIP17_METADATA = "IKIP17Metatdata"
        case IKIP17_ENUMERABLE = "IKIP17Enumerable"
        case IKIP17_MINTABLE = "IKIP17Mintable"
        case IKIP17_METADATA_MINTABLE = "IKIP17MetadataMintable"
        case IKIP17_BURNABLE = "IKIP17Burnable"
        case IKIP17_PAUSABLE = "IKIP17Pausable"
        
        func getName() -> String {
            return self.rawValue
        }
        
        func getId() -> String {
            switch self {
            case .IKIP17: return "0x80ac58cd"
            case .IKIP17_METADATA: return "0x5b5e139f"
            case .IKIP17_ENUMERABLE: return "0x780e9d63"
            case .IKIP17_MINTABLE: return "0xeab83e20"
            case .IKIP17_METADATA_MINTABLE: return "0xfac27f46"
            case .IKIP17_BURNABLE: return "0x42966c68"
            case .IKIP17_PAUSABLE: return "0x4d5507ff"
            }
        }
    }
    
    public init(_ caver: Caver, _ contractAddress: String? = nil) throws {
        _ = KIP17ConstantData()
        try super.init(caver, KIP17ConstantData.ABI, contractAddress)
    }
    
    public static func deploy(_ caver: Caver, _ deployer: String, _ name: String, _ symbol: String, _ wallet: IWallet? = nil) throws -> KIP17 {
        let params = KIP17DeployParams(name, symbol)
        return try KIP17.deploy(caver, params, deployer, wallet ?? caver.wallet)
    }
    
    public static func deploy(_ caver: Caver, _ tokenInfo: KIP17DeployParams, _ deployer: String) throws -> KIP17 {
        return try KIP17.deploy(caver, tokenInfo, deployer, caver.wallet)
    }
    
    public static func deploy(_ caver: Caver, _ tokenInfo: KIP17DeployParams, _ deployer: String, _ wallet: IWallet? = nil) throws -> KIP17 {
        _ = KIP17ConstantData()
        
        let deployArgument: [Any] = [tokenInfo.name, tokenInfo.symbol]
        let contractDeployParams = try ContractDeployParams(KIP17ConstantData.BINARY, deployArgument)
        let sendOption = SendOptions(deployer, BigUInt(6500000))
        
        let kip17 = try KIP17(caver)
        kip17.wallet = wallet ?? caver.wallet
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
        
    public func clone(_ tokenAddress: String = "") -> KIP17? {
        var kip17: KIP17?
        if tokenAddress.isEmpty {
            kip17 = try? KIP17(caver, contractAddress)
        } else {
            kip17 = try? KIP17(caver, tokenAddress)
        }
        kip17?.wallet = wallet
        return kip17
    }
    
    public func detectInterface() throws -> [String:Bool] {
        guard let contractAddress = contractAddress else {
            throw CaverError.invalidValue
        }
        return try KIP17.detectInterface(caver, contractAddress)
    }
    
    public func supportInterface(_ interfaceId: String) throws -> Bool? {
        let callObject = CallObject.createCallObject()
        let result = try getMethod(KIP17.FUNCTION_SUPPORTS_INTERFACE).call([interfaceId], callObject)
        return result?[0].value as? Bool
    }
    
    public func name() throws -> String? {
        let callObject = CallObject.createCallObject()
        let result = try getMethod(KIP17.FUNCTION_NAME).call(nil, callObject)
        return result?[0].value as? String
    }
    
    public func symbol() throws -> String? {
        let callObject = CallObject.createCallObject()
        let result = try getMethod(KIP17.FUNCTION_SYMBOL).call(nil, callObject)
        return result?[0].value as? String
    }
    
    public func tokenURI(_ tokenId: BigUInt) throws -> String? {
        let callObject = CallObject.createCallObject()
        let result = try getMethod(KIP17.FUNCTION_TOKEN_URI).call([tokenId], callObject)
        return result?[0].value as? String
    }
    
    public func totalSupply() throws -> BigUInt? {
        let callObject = CallObject.createCallObject()
        let result = try getMethod(KIP17.FUNCTION_TOTAL_SUPPLY).call(nil, callObject)
        return result?[0].value as? BigUInt
    }
    
    public func tokenOwnerByIndex(_ owner: String, _ index: BigUInt) throws -> BigUInt? {
        let callObject = CallObject.createCallObject()
        let result = try getMethod(KIP17.FUNCTION_TOKEN_OF_OWNER_BY_INDEX).call([owner, index], callObject)
        return result?[0].value as? BigUInt
    }
    
    public func tokenByIndex(_ index: BigUInt) throws -> BigUInt? {
        let callObject = CallObject.createCallObject()
        let result = try getMethod(KIP17.FUNCTION_TOKEN_BY_INDEX).call([index], callObject)
        return result?[0].value as? BigUInt
    }
    
    public func balanceOf(_ account: String) throws -> BigUInt? {
        let callObject = CallObject.createCallObject()
        let result = try getMethod(KIP17.FUNCTION_BALANCE_OF).call([account], callObject)
        return result?[0].value as? BigUInt
    }
    
    public func ownerOf(_ tokenId: BigUInt) throws -> String? {
        let callObject = CallObject.createCallObject()
        let result = try getMethod(KIP17.FUNCTION_OWNER_OF).call([tokenId], callObject)
        return (result?[0].value as? Address)?.toValue
    }
    
    public func getApproved(_ tokenId: BigUInt) throws -> String? {
        let callObject = CallObject.createCallObject()
        let result = try getMethod(KIP17.FUNCTION_GET_APPROVED).call([tokenId], callObject)
        return (result?[0].value as? Address)?.toValue
    }
    
    public func isApprovedForAll(_ owner: String, _ operate: String) throws -> Bool? {
        let callObject = CallObject.createCallObject()
        let result = try getMethod(KIP17.FUNCTION_IS_APPROVED_FOR_ALL).call([owner, operate], callObject)
        return result?[0].value as? Bool
    }
    
    public func isMinter(_ account: String) throws -> Bool? {
        let callObject = CallObject.createCallObject()
        let result = try getMethod(KIP17.FUNCTION_IS_MINTER).call([account], callObject)
        return result?[0].value as? Bool
    }
    
    public func paused() throws -> Bool? {
        let callObject = CallObject.createCallObject()
        let result = try getMethod(KIP17.FUNCTION_PAUSED).call(nil, callObject)
        return result?[0].value as? Bool
    }
    
    public func isPauser(_ account: String) throws -> Bool? {
        let callObject = CallObject.createCallObject()
        let result = try getMethod(KIP17.FUNCTION_IS_PAUSER).call([account], callObject)
        return result?[0].value as? Bool
    }
    
    public func approve(_ to: String, _ tokenId: BigUInt, _ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        guard let sendParam = sendParam ?? defaultSendOptions else { throw CaverError.invalidValue }
        let sendOption = try KIP17.determineSendOptions(self, sendParam, KIP17.FUNCTION_APPROVE, [to, tokenId])
        
        let receiptData = try getMethod(KIP17.FUNCTION_APPROVE).send([to, tokenId], sendOption)
        return receiptData
    }
    
    public func setApproveForAll(_ to: String, _ approved: Bool, _ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        guard let sendParam = sendParam ?? defaultSendOptions else { throw CaverError.invalidValue }
        let sendOption = try KIP17.determineSendOptions(self, sendParam, KIP17.FUNCTION_SET_APPROVAL_FOR_ALL, [to, approved])
        
        let receiptData = try getMethod(KIP17.FUNCTION_SET_APPROVAL_FOR_ALL).send([to, approved], sendOption)
        return receiptData
    }
    
    public func transferFrom(_ from: String, _ to: String, _ tokenId: BigUInt, _ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        guard let sendParam = sendParam ?? defaultSendOptions else { throw CaverError.invalidValue }
        let sendOption = try KIP17.determineSendOptions(self, sendParam, KIP17.FUNCTION_TRANSFER_FROM, [from, to, tokenId])
        
        let receiptData = try getMethod(KIP17.FUNCTION_TRANSFER_FROM).send([from, to, tokenId], sendOption)
        return receiptData
    }
    
    public func safeTransferFrom(_ from: String, _ to: String, _ tokenId: BigUInt, _ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        guard let sendParam = sendParam ?? defaultSendOptions else { throw CaverError.invalidValue }
        let sendOption = try KIP17.determineSendOptions(self, sendParam, KIP17.FUNCTION_SAFE_TRANSFER_FROM, [from, to, tokenId])
        
        let receiptData = try getMethod(KIP17.FUNCTION_SAFE_TRANSFER_FROM).send([from, to, tokenId], sendOption)
        return receiptData
    }
    
    public func safeTransferFrom(_ from: String, _ to: String, _ tokenId: BigUInt, _ data: String, _ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        guard let sendParam = sendParam ?? defaultSendOptions else { throw CaverError.invalidValue }
        let sendOption = try KIP17.determineSendOptions(self, sendParam, KIP17.FUNCTION_SAFE_TRANSFER_FROM, [from, to, tokenId, data])
        
        let receiptData = try getMethod(KIP17.FUNCTION_SAFE_TRANSFER_FROM).send([from, to, tokenId, data], sendOption)
        return receiptData
    }
    
    public func addMinter(_ account: String, _ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        guard let sendParam = sendParam ?? defaultSendOptions else { throw CaverError.invalidValue }
        let sendOption = try KIP17.determineSendOptions(self, sendParam, KIP17.FUNCTION_ADD_MINTER, [account])
        
        let receiptData = try getMethod(KIP17.FUNCTION_ADD_MINTER).send([account], sendOption)
        return receiptData
    }
    
    public func renounceMinter(_ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        guard let sendParam = sendParam ?? defaultSendOptions else { throw CaverError.invalidValue }
        let sendOption = try KIP17.determineSendOptions(self, sendParam, KIP17.FUNCTION_RENOUNCE_MINTER)
        
        let receiptData = try getMethod(KIP17.FUNCTION_RENOUNCE_MINTER).send(nil, sendOption)
        return receiptData
    }
    
    public func mint(_ account: String, _ amount: BigUInt, _ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        guard let sendParam = sendParam ?? defaultSendOptions else { throw CaverError.invalidValue }
        let sendOption = try KIP17.determineSendOptions(self, sendParam, KIP17.FUNCTION_MINT, [account, amount])
        
        let receiptData = try getMethod(KIP17.FUNCTION_MINT).send([account, amount], sendOption)
        return receiptData
    }
    
    public func mintWithTokenURI(_ to: String, _ tokenId: BigUInt, _ tokenURI: String, _ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        guard let sendParam = sendParam ?? defaultSendOptions else { throw CaverError.invalidValue }
        let sendOption = try KIP17.determineSendOptions(self, sendParam, KIP17.FUNCTION_MINT_WITH_TOKEN_URI, [to, tokenId, tokenURI])
        
        let receiptData = try getMethod(KIP17.FUNCTION_MINT_WITH_TOKEN_URI).send([to, tokenId, tokenURI], sendOption)
        return receiptData
    }
    
    public func burn(_ amount: BigUInt, _ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        guard let sendParam = sendParam ?? defaultSendOptions else { throw CaverError.invalidValue }
        let sendOption = try KIP17.determineSendOptions(self, sendParam, KIP17.FUNCTION_BURN, [amount])
        
        let receiptData = try getMethod(KIP17.FUNCTION_BURN).send([amount], sendOption)
        return receiptData
    }
    
    public func pause(_ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        guard let sendParam = sendParam ?? defaultSendOptions else { throw CaverError.invalidValue }
        let sendOption = try KIP17.determineSendOptions(self, sendParam, KIP17.FUNCTION_PAUSE)
        
        let receiptData = try getMethod(KIP17.FUNCTION_PAUSE).send(nil, sendOption)
        return receiptData
    }
    
    public func unpause(_ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        guard let sendParam = sendParam ?? defaultSendOptions else { throw CaverError.invalidValue }
        let sendOption = try KIP17.determineSendOptions(self, sendParam, KIP17.FUNCTION_UNPAUSE)
        
        let receiptData = try getMethod(KIP17.FUNCTION_UNPAUSE).send(nil, sendOption)
        return receiptData
    }
    
    public func addPauser(_ account: String, _ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        guard let sendParam = sendParam ?? defaultSendOptions else { throw CaverError.invalidValue }
        let sendOption = try KIP17.determineSendOptions(self, sendParam, KIP17.FUNCTION_ADD_PAUSER, [account])
        
        let receiptData = try getMethod(KIP17.FUNCTION_ADD_PAUSER).send([account], sendOption)
        return receiptData
    }
    
    public func renouncePauser(_ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        guard let sendParam = sendParam ?? defaultSendOptions else { throw CaverError.invalidValue }
        let sendOption = try KIP17.determineSendOptions(self, sendParam, KIP17.FUNCTION_RENOUNCE_PAUSER)
        
        let receiptData = try getMethod(KIP17.FUNCTION_RENOUNCE_PAUSER).send(nil, sendOption)
        return receiptData
    }
    
    private static func determineSendOptions(_ kip17: KIP17, _ sendOptions: SendOptions, _ functionName: String, _ argument: [Any] = []) throws -> SendOptions {
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
    
    private static func estimateGas(_ kip17: KIP17, _ functionName: String, _ callObject: CallObject, _ argument: [Any]) throws -> BigUInt {
        guard let gas = try? kip17.getMethod(functionName).estimateGas(argument, callObject),
              let gas = BigUInt(hex: gas),
              let bigDecimal = BDouble(gas.decimal),
              let result = BigUInt((bigDecimal * 1.5).rounded().description) else {
            throw CaverError.invalidValue
        }
        
        return result
    }
}
