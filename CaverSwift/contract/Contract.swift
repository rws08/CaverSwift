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
    private(set) public var abi: String
    private(set) public var contractAddress: String? = nil
    private(set) public var methods: [String:ContractMethod] = [:]
    private(set) public var events: [String:ContractEvent] = [:]
    private(set) public var constructor: ContractMethod?
    private(set) public var defaultSendOptions: SendOptions?
    var wallet: IWallet?
    
    public init(_ caver: Caver, _ abi: String, _ contractAddress: String? = nil) throws {
        self.abi = abi
        self.caver = caver
        self.contractAddress = contractAddress
        
        try setAbi(abi)
        setCaver(caver)
        setContractAddress(contractAddress)
        setDefaultSendOptions(SendOptions())
        setWallet(caver.wallet)
    }
    
    public func deploy(_ sendOptions: SendOptions, _ contractBinaryData: String, _ constructorParams: Any...) throws -> Contract {
        let deployParams = try ContractDeployParams(contractBinaryData, [constructorParams])
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
            let contractAddress = receipt?.contractAddress
            setContractAddress(contractAddress)
            return self
        } else if let error = error {
            throw CaverError.IOException(error.localizedDescription)
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
    
    func setContractAddress(_ contractAddress: String?) {
        self.contractAddress = contractAddress
        methods.values.forEach {
            $0.contractAddress = contractAddress ?? ""
        }
    }
    
    func setDefaultSendOptions(_ defaultSendOptions: SendOptions) {
        self.defaultSendOptions = defaultSendOptions
        methods.values.forEach {
            $0.defaultSendOptions = defaultSendOptions
        }
    }
    
    func setWallet(_ wallet: IWallet) {
        self.wallet = wallet
        methods.values.forEach {
            $0.wallet = wallet
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
            throw CaverError.IOException(error.localizedDescription)
        }
        throw CaverError.unexpectedReturnValue
    }
    
    public func call(_ methodName: String, _ methodArguments:[Any]) -> [Type]? {
        return call(CallObject.init(), methodName, methodArguments)
    }
    
    public func call(_ callObject: CallObject, _ methodName: String, _ methodArguments:[Any]) -> [Type]?{
        guard let contractMethod = try? getMethod(methodName) else { return nil }
        return try? contractMethod.call(methodArguments, callObject)
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
