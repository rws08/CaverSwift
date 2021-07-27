//
//  Contract.swift
//  CaverSwift
//
//  Created by won on 2021/05/10.
//

import Foundation
import GenericJSON

open class Contract {
    var caver: Caver
    private(set) public var abi: String = ""
    var _contractAddress: String? = nil
    private(set) public var contractAddress: String? {
        get { _contractAddress }
        set(v) {
            _contractAddress = v
            methods.values.forEach {
                $0.contractAddress = v ?? ""
            }
        }
    }
    private(set) public var methods: [String:ContractMethod] = [:]
    private(set) public var events: [String:ContractEvent] = [:]
    private(set) public var constructor: ContractMethod?
    private(set) public var defaultSendOptions: SendOptions?
    var _wallet: IWallet?
    var wallet: IWallet? {
        get { _wallet }
        set(v) {
            _wallet = v
            methods.values.forEach {
                $0.wallet = wallet
            }
        }
    }
    
    public init(_ caver: Caver, _ abi: String, _ contractAddress: String? = nil) throws {
        self.caver = caver
        
        try setAbi(abi)
        setCaver(caver)
        self.contractAddress = contractAddress
        setDefaultSendOptions(SendOptions())
        self.wallet = caver.wallet
    }
    
    public func deploy(_ sendOptions: SendOptions, _ contractBinaryData: String, _ constructorParams: Any...) throws -> Contract {
        let deployParams = try ContractDeployParams(contractBinaryData, constructorParams.flatCompactMapForVariadicParameters())
        return try deploy(deployParams, sendOptions)
    }
    
    public func deploy(_ deployParam: ContractDeployParams, _ sendOptions: SendOptions) throws -> Contract {
        return try deploy(deployParam, sendOptions, PollingTransactionReceiptProcessor(caver, 1000, 15))
    }
    
    public func deploy(_ deployParam: ContractDeployParams, _ sendOptions: SendOptions, _ processor: TransactionReceiptProcessor) throws -> Contract {
        let input = try ABI.encodeContractDeploy(constructor, deployParam.bytecode, deployParam.deployParams)
        guard let from = sendOptions.from,
              let gas = sendOptions.gas
        else {
            throw CaverError.invalidValue
        }
        let smartContractDeploy = try SmartContractDeploy.Builder()
            .setKlaytnCall(caver.rpc.klay)
            .setFrom(from)
            .setInput(input)
            .setCodeFormat(CodeFormat.EVM)
            .setHumanReadable(false)
            .setGas(gas)
            .build()
        
        _ = try wallet?.sign(from, smartContractDeploy)
        let (error, response) = caver.rpc.klay.sendRawTransaction(try smartContractDeploy.getRawTransaction())
        if let resDataString = response {
            let receipt = try processor.waitForTransactionReceipt(resDataString.val)
            self.contractAddress = receipt.contractAddress
            return self
        } else if let error = error {
            throw error
        }
        throw CaverError.unexpectedReturnValue
    }
    
    func setCaver(_ caver: Caver) {
        self.caver = caver
        methods.values.forEach {
            $0.caver = caver
        }
    }
    
    func setAbi(_ abi: String) throws {
        self.abi = abi
        try initAbi()
    }
    
    func setDefaultSendOptions(_ defaultSendOptions: SendOptions) {
        self.defaultSendOptions = defaultSendOptions
        methods.values.forEach {
            $0.defaultSendOptions = defaultSendOptions
        }
    }
    
    func getWallet() -> IWallet? {
        return self.wallet
    }
    
    public func getMethod(_ methodName: String) throws -> ContractMethod {
        guard let method = methods[methodName] else {
            throw CaverError.NullPointerException("\(methodName) method is not exist.")
        }
        return method
    }
    
    public func getEvent(_ eventName: String) throws -> ContractEvent {
        guard let event = events[eventName] else {
            throw CaverError.NullPointerException("\(eventName) event is not exist.")
        }
        return event
    }
    
    public func getPastEvent(_ eventName: String, _ filterOption: KlayLogFilter) throws -> KlayLogs {
        guard let event = events[eventName] else {
            throw CaverError.NullPointerException("\(eventName) event is not exist.")
        }
        _ = filterOption.addSingleTopic(try ABI.encodeEventSignature(event))
        
        let (error, response) = caver.rpc.klay.getLogs(filterOption)
        if let resDataString = response {
            return resDataString
        } else if let error = error {
            throw error
        }
        throw CaverError.unexpectedReturnValue
    }
    
    public func call(_ methodName: String, _ methodArguments: Any...) -> [Type]? {
        return call(CallObject.init(), methodName, methodArguments.flatCompactMapForVariadicParameters())
    }
    
    public func call(_ callObject: CallObject, _ methodName: String, _ methodArguments: Any...) -> [Type]? {
        guard let contractMethod = try? getMethod(methodName) else { return nil }
        return try? contractMethod.call(methodArguments.flatCompactMapForVariadicParameters(), callObject)
    }
    
    public func call(_ callObject: CallObject, _ methodName: String, _ methodArguments: [Any]? = nil) -> [Type]? {
        guard let contractMethod = try? getMethod(methodName) else { return nil }
        return try? contractMethod.call(methodArguments, callObject)
    }
    
    public func callWithSolidityType(_ methodName: String, _ methodArguments: Type...) -> [Type]? {
        return callWithSolidityType(CallObject.createCallObject(), methodName, methodArguments)
    }
    
    public func callWithSolidityType(_ callObject: CallObject, _ methodName: String, _ methodArguments: Type...) -> [Type]? {
        guard let contractMethod = try? getMethod(methodName) else { return nil }
        return try? contractMethod.callWithSolidityWrapper(methodArguments, callObject)
    }
    
    public func callWithSolidityType(_ callObject: CallObject, _ methodName: String, _ methodArguments: [Type]? = nil) -> [Type]? {
        guard let contractMethod = try? getMethod(methodName) else { return nil }
        return try? contractMethod.callWithSolidityWrapper(methodArguments, callObject)
    }
        
    public func send(_ methodName: String, _ methodArguments: Any...) throws -> TransactionReceiptData {
        return try send(nil, methodName, methodArguments.flatCompactMapForVariadicParameters())
    }
    
    public func send(_ options: SendOptions? = nil, _ methodName: String, _ methodArguments: Any...) throws -> TransactionReceiptData {
        return try send(options, PollingTransactionReceiptProcessor(caver, 1000, 15), methodName, methodArguments.flatCompactMapForVariadicParameters())
    }
    
    public func send(_ options: SendOptions? = nil, _ receiptProcessor: TransactionReceiptProcessor, _ methodName: String, _ methodArguments: Any...) throws -> TransactionReceiptData {
        let contractMethod = try getMethod(methodName)
        return try contractMethod.send(methodArguments.flatCompactMapForVariadicParameters(), options, receiptProcessor)
    }
    
    public func sendWithSolidityType(_ methodName: String, _ methodArguments: Type...) throws -> TransactionReceiptData {
        return try sendWithSolidityType(nil, PollingTransactionReceiptProcessor(caver, 1000, 15), methodName, methodArguments)
    }
    
    public func sendWithSolidityType(_ options: SendOptions? = nil, _ methodName: String, _ methodArguments: Type...) throws -> TransactionReceiptData {
        return try sendWithSolidityType(options, PollingTransactionReceiptProcessor(caver, 1000, 15), methodName, methodArguments)
    }
    
    public func sendWithSolidityType(_ options: SendOptions? = nil, _ receiptProcessor: TransactionReceiptProcessor, _ methodName: String, _ methodArguments: Type...) throws -> TransactionReceiptData {
        return try sendWithSolidityType(options, receiptProcessor, methodName, methodArguments)
    }
    
    public func sendWithSolidityType(_ options: SendOptions? = nil, _ receiptProcessor: TransactionReceiptProcessor, _ methodName: String, _ methodArguments: [Type]) throws -> TransactionReceiptData {
        let contractMethod = try getMethod(methodName)
        return try contractMethod.sendWithSolidityWrapper(methodArguments, options, receiptProcessor)
    }
    
    public func encodeABI(_ methodName: String, _ methodArguments: Any...) -> String? {
        guard let method = try? getMethod(methodName) else { return nil }
        return try? method.encodeABI(methodArguments.flatCompactMapForVariadicParameters())
    }
        
    public func encodeABIWithSolidityType(_ methodName: String, _ methodArguments: Type...) -> String? {
        guard let method = try? getMethod(methodName) else { return nil }
        return try? method.encodeABIWithSolidityWrapper(methodArguments)
    }
    
    public func estimateGas(_ callObject: CallObject, _ methodName: String, _ methodArguments: Any...) -> String? {
        guard let method = try? getMethod(methodName) else { return nil }
        return try? method.estimateGas(methodArguments.flatCompactMapForVariadicParameters(), callObject)
    }
    
    public func estimateGasWithSolidityType(_ callObject: CallObject, _ methodName: String, _ methodArguments: Type...) -> String? {
        guard let method = try? getMethod(methodName) else { return nil }
        return try? method.estimateGasWithSolidityWrapper(methodArguments, callObject)
    }
    
    private func initAbi() throws {
        methods.removeAll()
        let data = abi.data(using: .utf8, allowLossyConversion: false)!
        let json = try JSONDecoder().decode(JSON.self, from: data)
        try json.arrayValue?.forEach {
            guard let type = $0["type"]?.stringValue else { return }
            if type == "function" {
                let encoded = try JSONEncoder().encode($0)
                let newMethod = try JSONDecoder().decode(ContractMethod.self, from:encoded)
                newMethod.signature = try ABI.encodeFunctionSignature(newMethod)
                if let existedMethod = self.methods[newMethod.name] {
                    let isWarning = existedMethod.nextContractMethods.contains {
                        return $0.inputs.count == newMethod.inputs.count
                    }
                    if existedMethod.inputs.count == newMethod.inputs.count || isWarning {
                        WARNING(message: "An overloaded function with the same number of parameters may not be executed normally. Please use *withSolidityWrapper methods in ContractMethod class.")
                    }
                    
                    existedMethod.nextContractMethods.append(newMethod)
                } else {
                    self.methods[newMethod.name] = newMethod
                }
            } else if type == "event" {
                let encoded = try JSONEncoder().encode($0)
                let event = try JSONDecoder().decode(ContractEvent.self, from:encoded)
                event.signature = try ABI.encodeEventSignature(event)
                events[event.name] = event
            } else if type == "constructor" {
                let encoded = try JSONEncoder().encode($0)
                let method = try JSONDecoder().decode(ContractMethod.self, from:encoded)
                self.constructor = method
            }
        }
    }
}
