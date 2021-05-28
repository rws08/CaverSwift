//
//  ContractMethod.swift
//  CaverSwift
//
//  Created by won on 2021/05/10.
//

import Foundation
import BigInt
import OSLog

public class ContractMethod: Codable {
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
    
    init(_ caver: Caver, _ type: String, _ name: String,
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
    
    public func call(_ arguments: [Any]?, _ callObject: CallObject, completion: @escaping(([Type]?) -> Void)) throws {
        var functionParams: [Any] = []
        if arguments != nil {
            functionParams.append(contentsOf: arguments!)
        }
        
        let matchedMethod = try findMatchedInstance(functionParams)
        let encodedFunction = try ABI.encodeFunctionCall(matchedMethod, functionParams)
        
        return try callFunction(matchedMethod, encodedFunction, callObject) {
            completion($0)
        }
    }
    
    private func callFunction(_ method: ContractMethod, _ encodedInput: String, _ callObject: CallObject, completion: @escaping(([Type]?) -> Void)) throws {
        if callObject.data != nil || callObject.to != nil {
            WARNING(message: "'to' and 'data' field in CallObject will overwrite.")
        }
        
        callObject.data = encodedInput
        callObject.to = method.contractAddress
        try caver?.rpc.klay.call(callObject, completion: { error, response in
            if error == nil {
                completion(ABI.decodeParameters(method, response!))
            } else {
//                let result = ABI.decodeParameters()
            }
        })
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
}
