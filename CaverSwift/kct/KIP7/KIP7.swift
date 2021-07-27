//
//  KIP7.swift
//  CaverSwift
//
//  Created by won on 2021/07/26.
//

import Foundation

open class KIP7: Contract {
    static let FUNCTION_ADD_MINTER = "addMinter"
    static let FUNCTION_ADD_PAUSER = "addPauser"
    static let FUNCTION_ALLOWANCE = "allowance"
    static let FUNCTION_APPROVE = "approve"
    static let FUNCTION_BALANCE_OF = "balanceOf"
    static let FUNCTION_BURN = "burn"
    static let FUNCTION_BURN_FROM = "burnFrom"
    static let FUNCTION_DECIMALS = "decimals"
    static let FUNCTION_IS_MINTER = "isMinter"
    static let FUNCTION_IS_PAUSER = "isPauser"
    static let FUNCTION_MINT = "mint"
    static let FUNCTION_NAME = "name"
    static let FUNCTION_PAUSE = "pause"
    static let FUNCTION_PAUSED = "paused"
    static let FUNCTION_RENOUNCE_MINTER = "renounceMinter"
    static let FUNCTION_RENOUNCE_PAUSER = "renouncePauser"
    static let FUNCTION_SAFE_TRANSFER = "safeTransfer"
    static let FUNCTION_SAFE_TRANSFER_FROM = "safeTransferFrom"
    static let FUNCTION_SUPPORTS_INTERFACE = "supportsInterface"
    static let FUNCTION_SYMBOL = "symbol"
    static let FUNCTION_TOTAL_SUPPLY = "totalSupply"
    static let FUNCTION_TRANSFER = "transfer"
    static let FUNCTION_TRANSFER_FROM = "transferFrom"
    static let FUNCTION_UNPAUSE = "unpause"
    
    public enum INTERFACE: String, CaseIterable {
        case IKIP7 = "IKIP7"
        case IKIP7_METADATA = "IKIP7Metatdata"
        case IKIP7_MINTABLE = "IKIP7Mintable"
        case IKIP7_BURNABLE = "IKIP7Burnable"
        case IKIP7_PAUSABLE = "IKIP7Pausable"
        
        func getName() -> String {
            return self.rawValue
        }
        
        func getId() -> String {
            switch self {
            case .IKIP7: return "0x65787371"
            case .IKIP7_METADATA: return "0xa219a025"
            case .IKIP7_MINTABLE: return "0xeab83e20"
            case .IKIP7_BURNABLE: return "0x3b5a0bf8"
            case .IKIP7_PAUSABLE: return "0x4d5507ff"
            }
        }
    }
    
    public init(_ caver: Caver, _ contractAddress: String? = nil) throws {
        _ = KIP7ConstantData()
        try super.init(caver, KIP7ConstantData.ABI, contractAddress)
    }
    
    public static func deploy(_ caver: Caver, _ deployer: String, _ name: String, _ symbol: String, _ decimals: Int, _ initialSupply: BigUInt, _ wallet: IWallet? = nil) throws -> KIP7 {
        let params = KIP7DeployParams(name, symbol, decimals, initialSupply)
        return try KIP7.deploy(caver, params, deployer, wallet ?? caver.wallet)
    }
    
    public static func deploy(_ caver: Caver, _ tokenInfo: KIP7DeployParams, _ deployer: String) throws -> KIP7 {
        return try KIP7.deploy(caver, tokenInfo, deployer, caver.wallet)
    }
    
    public static func deploy(_ caver: Caver, _ tokenInfo: KIP7DeployParams, _ deployer: String, _ wallet: IWallet? = nil) throws -> KIP7 {
        _ = KIP7ConstantData()
        
        let deployArgument: [Any] = [tokenInfo.name, tokenInfo.symbol, tokenInfo.decimals, tokenInfo.initialSupply]
        let contractDeployParams = try ContractDeployParams(KIP7ConstantData.BINARY, deployArgument)
        let sendOption = SendOptions(deployer, BigUInt(4000000))
        
        let kip7 = try KIP7(caver)
        kip7.wallet = wallet
        _ = try kip7.deploy(contractDeployParams, sendOption)
        return kip7
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
        
    public func clone(_ tokenAddress: String = "") -> KIP7? {
        var kip7: KIP7?
        if tokenAddress.isEmpty {
            kip7 = try? KIP7(caver, contractAddress)
        } else {
            kip7 = try? KIP7(caver, tokenAddress)
        }
        kip7?.wallet = wallet
        return kip7
    }
    
    public func detectInterface() throws -> [String:Bool] {
        guard let contractAddress = contractAddress else {
            throw CaverError.invalidValue
        }
        return try KIP7.detectInterface(caver, contractAddress)
    }
    
    public func supportInterface(_ interfaceId: String) throws -> Bool? {
        let callObject = CallObject.createCallObject()
        let result = try getMethod(KIP7.FUNCTION_SUPPORTS_INTERFACE).call([interfaceId], callObject)
        return result?[0].value as? Bool
    }
    
    public func name() throws -> String? {
        let callObject = CallObject.createCallObject()
        let result = try getMethod(KIP7.FUNCTION_NAME).call(nil, callObject)
        return result?[0].value as? String
    }
    
    public func symbol() throws -> String? {
        let callObject = CallObject.createCallObject()
        let result = try getMethod(KIP7.FUNCTION_SYMBOL).call(nil, callObject)
        return result?[0].value as? String
    }
    
    public func decimals() throws -> Int? {
        let callObject = CallObject.createCallObject()
        let result = try getMethod(KIP7.FUNCTION_DECIMALS).call(nil, callObject)
        return (result?[0].value as? BigUInt)?.int
    }
    
    public func totalSupply() throws -> BigUInt? {
        let callObject = CallObject.createCallObject()
        let result = try getMethod(KIP7.FUNCTION_TOTAL_SUPPLY).call(nil, callObject)
        return result?[0].value as? BigUInt
    }
    
    public func balanceOf(_ account: String) throws -> BigUInt? {
        let callObject = CallObject.createCallObject()
        let result = try getMethod(KIP7.FUNCTION_BALANCE_OF).call([account], callObject)
        return result?[0].value as? BigUInt
    }
    
    public func allowance(_ owner: String, _ spender: String) throws -> BigUInt? {
        let callObject = CallObject.createCallObject()
        let result = try getMethod(KIP7.FUNCTION_ALLOWANCE).call([owner, spender], callObject)
        return result?[0].value as? BigUInt
    }
    
    public func isMinter(_ account: String) throws -> Bool? {
        let callObject = CallObject.createCallObject()
        let result = try getMethod(KIP7.FUNCTION_IS_MINTER).call([account], callObject)
        return result?[0].value as? Bool
    }
    
    public func isPauser(_ account: String) throws -> Bool? {
        let callObject = CallObject.createCallObject()
        let result = try getMethod(KIP7.FUNCTION_IS_PAUSER).call([account], callObject)
        return result?[0].value as? Bool
    }
    
    public func paused() throws -> Bool? {
        let callObject = CallObject.createCallObject()
        let result = try getMethod(KIP7.FUNCTION_PAUSED).call(nil, callObject)
        return result?[0].value as? Bool
    }
    
    public func approve(_ spender: String, _ amount: BigUInt, _ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        let sendOption = try KIP7.determineSendOptions(self, sendParam ?? defaultSendOptions!, KIP7.FUNCTION_APPROVE, [spender, amount])
        
        let receiptData = try getMethod(KIP7.FUNCTION_APPROVE).send([spender, amount], sendOption)
        return receiptData
    }
    
    public func transfer(_ recipient: String, _ amount: BigUInt, _ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        let sendOption = try KIP7.determineSendOptions(self, sendParam ?? defaultSendOptions!, KIP7.FUNCTION_TRANSFER, [recipient, amount])
        
        let receiptData = try getMethod(KIP7.FUNCTION_TRANSFER).send([recipient, amount], sendOption)
        return receiptData
    }
    
    public func transferFrom(_ sender: String, _ recipient: String, _ amount: BigUInt, _ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        let sendOption = try KIP7.determineSendOptions(self, sendParam ?? defaultSendOptions!, KIP7.FUNCTION_TRANSFER_FROM, [sender, recipient, amount])
        
        let receiptData = try getMethod(KIP7.FUNCTION_TRANSFER_FROM).send([sender, recipient, amount], sendOption)
        return receiptData
    }
    
    public func safeTransfer(_ recipient: String, _ amount: BigUInt, _ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        let sendOption = try KIP7.determineSendOptions(self, sendParam ?? defaultSendOptions!, KIP7.FUNCTION_SAFE_TRANSFER, [recipient, amount])
        
        let receiptData = try getMethod(KIP7.FUNCTION_SAFE_TRANSFER).send([recipient, amount], sendOption)
        return receiptData
    }
    
    public func safeTransfer(_ recipient: String, _ amount: BigUInt, _ data: String, _ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        let sendOption = try KIP7.determineSendOptions(self, sendParam ?? defaultSendOptions!, KIP7.FUNCTION_SAFE_TRANSFER, [recipient, amount, data])
        
        let receiptData = try getMethod(KIP7.FUNCTION_SAFE_TRANSFER).send([recipient, amount, data], sendOption)
        return receiptData
    }
    
    public func safeTransferFrom(_ sender: String, _ recipient: String, _ amount: BigUInt, _ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        let sendOption = try KIP7.determineSendOptions(self, sendParam ?? defaultSendOptions!, KIP7.FUNCTION_SAFE_TRANSFER_FROM, [sender, recipient, amount])
        
        let receiptData = try getMethod(KIP7.FUNCTION_SAFE_TRANSFER_FROM).send([sender, recipient, amount], sendOption)
        return receiptData
    }
    
    public func safeTransferFrom(_ sender: String, _ recipient: String, _ amount: BigUInt, _ data: String, _ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        let sendOption = try KIP7.determineSendOptions(self, sendParam ?? defaultSendOptions!, KIP7.FUNCTION_SAFE_TRANSFER_FROM, [sender, recipient, amount, data])
        
        let receiptData = try getMethod(KIP7.FUNCTION_SAFE_TRANSFER_FROM).send([sender, recipient, amount, data], sendOption)
        return receiptData
    }
    
    public func mint(_ account: String, _ amount: BigUInt, _ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        let sendOption = try KIP7.determineSendOptions(self, sendParam ?? defaultSendOptions!, KIP7.FUNCTION_MINT, [account, amount])
        
        let receiptData = try getMethod(KIP7.FUNCTION_MINT).send([account, amount], sendOption)
        return receiptData
    }
    
    public func addMinter(_ account: String, _ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        let sendOption = try KIP7.determineSendOptions(self, sendParam ?? defaultSendOptions!, KIP7.FUNCTION_ADD_MINTER, [account])
        
        let receiptData = try getMethod(KIP7.FUNCTION_ADD_MINTER).send([account], sendOption)
        return receiptData
    }
    
    public func renounceMinter(_ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        let sendOption = try KIP7.determineSendOptions(self, sendParam ?? defaultSendOptions!, KIP7.FUNCTION_RENOUNCE_MINTER)
        
        let receiptData = try getMethod(KIP7.FUNCTION_RENOUNCE_MINTER).send(nil, sendOption)
        return receiptData
    }
    
    public func burn(_ amount: BigUInt, _ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        let sendOption = try KIP7.determineSendOptions(self, sendParam ?? defaultSendOptions!, KIP7.FUNCTION_BURN, [amount])
        
        let receiptData = try getMethod(KIP7.FUNCTION_BURN).send([amount], sendOption)
        return receiptData
    }
    
    public func burnFrom(_ account: String, _ amount: BigUInt, _ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        let sendOption = try KIP7.determineSendOptions(self, sendParam ?? defaultSendOptions!, KIP7.FUNCTION_BURN_FROM, [account, amount])
        
        let receiptData = try getMethod(KIP7.FUNCTION_BURN_FROM).send([account, amount], sendOption)
        return receiptData
    }
    
    public func addPauser(_ account: String, _ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        let sendOption = try KIP7.determineSendOptions(self, sendParam ?? defaultSendOptions!, KIP7.FUNCTION_ADD_PAUSER, [account])
        
        let receiptData = try getMethod(KIP7.FUNCTION_ADD_PAUSER).send([account], sendOption)
        return receiptData
    }
    
    public func pause(_ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        let sendOption = try KIP7.determineSendOptions(self, sendParam ?? defaultSendOptions!, KIP7.FUNCTION_PAUSE)
        
        let receiptData = try getMethod(KIP7.FUNCTION_PAUSE).send(nil, sendOption)
        return receiptData
    }
    
    public func unpause(_ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        let sendOption = try KIP7.determineSendOptions(self, sendParam ?? defaultSendOptions!, KIP7.FUNCTION_UNPAUSE)
        
        let receiptData = try getMethod(KIP7.FUNCTION_UNPAUSE).send(nil, sendOption)
        return receiptData
    }
    
    public func renouncePauser(_ sendParam: SendOptions? = nil) throws -> TransactionReceiptData {
        let sendOption = try KIP7.determineSendOptions(self, sendParam ?? defaultSendOptions!, KIP7.FUNCTION_RENOUNCE_PAUSER)
        
        let receiptData = try getMethod(KIP7.FUNCTION_RENOUNCE_PAUSER).send(nil, sendOption)
        return receiptData
    }
    
    private static func determineSendOptions(_ kip7: KIP7, _ sendOptions: SendOptions, _ functionName: String, _ argument: [Any] = []) throws -> SendOptions {
        var from = kip7.defaultSendOptions?.from
        var gas = kip7.defaultSendOptions?.gas
        var value = kip7.defaultSendOptions?.value
        
        if sendOptions.from != nil {
            from = sendOptions.from
        }
        
        if sendOptions.gas == nil {
            if gas == nil {
                let callObject = CallObject.createCallObject(sendOptions.from)
                let estimateGas = try estimateGas(kip7, functionName, callObject, argument)
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
    
    private static func estimateGas(_ kip7: KIP7, _ functionName: String, _ callObject: CallObject, _ argument: [Any]) throws -> BigUInt {
        guard let gas = try? kip7.getMethod(functionName).estimateGas(argument, callObject),
              let gas = BigUInt(hex: gas),
              let bigDecimal = BDouble(gas.decimal),
              let result = BigUInt((bigDecimal * 1.5).rounded().description) else {
            throw CaverError.invalidValue
        }
        
        return result
    }
}
