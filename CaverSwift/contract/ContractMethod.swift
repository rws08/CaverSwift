//
//  ContractMethod.swift
//  CaverSwift
//
//  Created by won on 2021/05/10.
//

import Foundation
import BigInt
import OSLog

open class ContractMethod: Codable {
    var caver: Caver? = nil
    var type: String
    var name: String
    var inputs: [ContractIOType] = []
    var outputs: [ContractIOType] = []
    var signature: String = ""
    var contractAddress: String
    var defaultSendOptions = SendOptions(nil, BigInt.zero)
    var wallet: IWallet? = nil
    var nextContractMethods: Array<ContractMethod> = []
    
    enum CodingKeys: CodingKey {
        case type, name, inputs, outputs, signature, contractAddress
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(String.self, forKey: .type)
        self.name = (try? container.decode(String.self, forKey: .name)) ?? ""
        self.inputs = (try? container.decode([ContractIOType].self, forKey: .inputs)) ?? []
        self.outputs = (try? container.decode([ContractIOType].self, forKey: .outputs)) ?? []
        self.contractAddress = (try? container.decode(String.self, forKey: .contractAddress)) ?? ""
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(name, forKey: .name)
        try container.encode(inputs, forKey: .inputs)
        try container.encode(outputs, forKey: .outputs)
        try container.encode(signature, forKey: .signature)
        try container.encode(contractAddress, forKey: .contractAddress)
    }
    
    public init(_ caver: Caver, _ type: String, _ name: String,
         _ inputs: Array<ContractIOType>, _ outputs: Array<ContractIOType>,
         _ signature: String, _ contractAddress: String) {
        self.caver = caver
        self.type = type
        self.name = name
        self.inputs = inputs
        self.outputs = outputs
        self.signature = signature
        self.contractAddress = contractAddress
    }
    
    public func call(_ arguments: [Any]?, _ callObject: CallObject? = CallObject.createCallObject()) throws -> [Type]?{
        guard let callObject = callObject else {
            throw CaverError.invalidValue
        }
        var functionParams: [Any] = []
        if arguments != nil {
            functionParams.append(contentsOf: arguments!)
        }
        
        let matchedMethod = try findMatchedInstance(functionParams)
        let encodedFunction = try ABI.encodeFunctionCall(matchedMethod, functionParams)
        
        return try callFunction(matchedMethod, encodedFunction, callObject)
    }
    
    public func send(_ arguments: [Any]? = nil, _ options: SendOptions? = nil, _ processor: TransactionReceiptProcessor? = nil) throws -> TransactionReceiptData? {
        var functionParams: [Any] = []
        if arguments != nil {
            functionParams.append(contentsOf: arguments!)
        }
        
        let matchedMethod = try findMatchedInstance(functionParams)
        let encodedFunction = try ABI.encodeFunctionCall(matchedMethod, functionParams)
        
        return try sendTransaction(matchedMethod, options, encodedFunction, processor ?? PollingTransactionReceiptProcessor(caver!, 1000, 15))
    }
    
    public func encodeABI(_ arguments: [Any]?) throws -> String{
        var functionParams: [Any] = []
        if arguments != nil {
            functionParams.append(contentsOf: arguments!)
        }
        
        let matchedMethod = try findMatchedInstance(functionParams)
        return try ABI.encodeFunctionCall(matchedMethod, functionParams)
    }
    
    public func estimateGas(_ arguments: [Any], _ callObject: CallObject) throws -> String {
        let encodedFunctionCall = try encodeABI(arguments)
        return try estimateGas(encodedFunctionCall, callObject)
    }
    
    public func checkTypeValid(_ types: [Any]) throws {
        if types.count != inputs.count {
            throw CaverError.IllegalArgumentException("Not matched passed parameter count.")
        }
    }
    
    private func checkSendOption(_ options: SendOptions?) throws {
        guard let options = options else { return }
        if options.from == nil || !Utils.isAddress((options.from)!) {
            throw CaverError.IllegalArgumentException("Invalid 'from' parameter : \(options.from ?? "")")
        }
        if options.gas == nil || !Utils.isNumber((options.gas)!) {
            throw CaverError.IllegalArgumentException("Invalid 'gas' parameter : \(options.gas ?? "")")
        }
        if options.value.isEmpty || !Utils.isNumber(options.value) {
            throw CaverError.IllegalArgumentException("Invalid 'value' parameter : \(options.value)")
        }
    }
    
    private func findMatchedInstance(_ arguments: [Any]) throws -> ContractMethod {
        var matchedMethod: Array<ContractMethod> = []
        if inputs.count != arguments.count {
            for item in nextContractMethods {
                if item.inputs.count == arguments.count {
                    matchedMethod.append(item)
                }
            }
        } else {
            matchedMethod.append(self)
        }
        
        if matchedMethod.isEmpty {
            throw CaverError.ArgumentException("Cannot find method with passed parameters.")
        }
        
        if matchedMethod.count != 1 {
            WARNING(message: "It found a two or more overloaded function that has same parameter counts. It may be abnormally executed. Please use *withSolidityWrapper().")
        }
        
        return matchedMethod[0]
    }
    
    private func sendTransaction(_ method: ContractMethod, _ options: SendOptions?, _ encodedInput: String, _ processor: TransactionReceiptProcessor) throws -> TransactionReceiptData? {
        guard let klay = caver?.rpc.klay else {
            throw CaverError.invalidValue
        }
        let sendOptions = makeSendOption(options)
        try checkSendOption(sendOptions)
        
        let smartContractExecution = try SmartContractExecution.Builder()
            .setKlaytnCall(klay)
            .setFrom(sendOptions.from!)
            .setTo(method.contractAddress)
            .setInput(encodedInput)
            .setGas(sendOptions.gas!)
            .setValue(sendOptions.value)
            .build()
        
        _ = try wallet?.sign(sendOptions.from!, smartContractExecution)
        let (error, response) = klay.sendRawTransaction(smartContractExecution)
        if let resDataString = response {
            let receipt = try processor.waitForTransactionReceipt(resDataString.val)
            return receipt
        } else if let error = error {
            throw CaverError.IOException(error.localizedDescription)
        }
        return nil
    }
    
    private func callFunction(_ method: ContractMethod, _ encodedInput: String, _ callObject: CallObject) throws -> [Type]? {
        var callObject = callObject
        if callObject.data != nil || callObject.to != nil {
            WARNING(message: "'to' and 'data' field in CallObject will overwrite.")
        }
        
        callObject.data = encodedInput
        callObject.to = method.contractAddress
        let(error, response) = try caver!.rpc.klay.call(callObject)
        if error == nil {
            return ABI.decodeParameters(method, response!)
        } else {
            throw CaverError.IOException(error.debugDescription)
        }
    }
    
    private func estimateGas(_ encodedFunctionCall: String, _ callObject: CallObject) throws -> String {
        var callObject = callObject
        if callObject.data != nil || callObject.to != nil {
            WARNING(message: "'to' and 'data' field in CallObject will overwrite.")
        }
        
        callObject.data = encodedFunctionCall
        callObject.to = contractAddress
        let(error, response) = try caver!.rpc.klay.estimateGas(callObject)
        if error == nil {
            return (response?.val.hexa)!
        } else {
            throw CaverError.IOException(error.debugDescription)
        }
    }
    
    public func makeSendOption(_ sendOption: SendOptions?) -> SendOptions {
        let defaultSendOption = defaultSendOptions
        var from = defaultSendOption.from
        var gas = defaultSendOption.gas
        var value = defaultSendOption.value
        
        guard let sendOption = sendOption else {
            return SendOptions(from, gas, value)
        }
        
        if sendOption.from != nil {
            from = sendOption.from
        }
        if sendOption.gas != nil {
            gas = sendOption.gas
        }
        if sendOption.value != "0x0" {
            value = sendOption.value
        }
        return SendOptions(from, gas, value)
    }
}
