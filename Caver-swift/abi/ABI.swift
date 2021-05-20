//
//  ABI.swift
//  Caver-swift
//
//  Created by won on 2021/05/10.
//

import Foundation
import BigInt

class ABI {
    private static let TUPLE = "tuple"
    
    static func encodeFunctionCall(_ method: ContractMethod, _ params: [Any]) throws -> String {
        let functionSignature = ABI.buildFunctionString(method)
        let solTypeList = method.inputs.map {
            $0.getTypeAsString()
        }
        return try encodeFunctionCall(functionSignature, solTypeList, params)
    }
    
    static func encodeFunctionCall(_ functionSig: String, _ solTypeList: [String], _ params: [Any]) throws -> String {
        let methodId = try encodeFunctionSignature(functionSig)
        let encodedParams = try encodeParameters(solTypeList, params)
        
        return methodId + encodedParams
    }
    
    static func encodeFunctionSignature(_ method: ContractMethod) throws -> String {
        return try encodeFunctionSignature(buildFunctionString(method))
    }
    
    static func encodeFunctionSignature(_ functionName: String) throws -> String {
        guard let data = functionName.data(using: .utf8) else { throw CaverError.invalidSignature }
        let signature = String(bytes: data.web3.keccak256.web3.bytes)
        return String(signature[..<signature.index(signature.startIndex, offsetBy: 10)])
    }
    
    static func encodeParameters(_ solTypeList: [String], _ params: [Any]) throws -> String {
        var typeList: [Type] = []
        for (idx, solidityType) in solTypeList.enumerated() {
            typeList.append(try TypeDecoder.instantiateType(solidityType, params[idx]))
        }
        
        return try encodeParameters(typeList)
    }
    
    static func encodeParameters(_ params: [Type]) throws -> String {
        return try DefaultFunctionEncoder.encodeParameters(params)
    }
    
    static func decodeParameters(_ solTypeList: [String], _ params: [Any]) throws -> [Type] {
        
        return []
    }
    
    static func encodeParameter(_ solidityType: String, _ param: Any) throws -> String {
        let type = try TypeDecoder.instantiateType(solidityType, param)
                
        switch type.rawType {
        case .DynamicString:
            return try encodeParameter(type)
        case .FixedInt, .FixedUInt:
            return try encodeParameter(type)
        case .FixedAddress:
            guard let value = param as? String else { throw CaverError.invalidValue }
            return try encodeParameter(Type(Address(value)))
        case .FixedBool:
            return try encodeParameter(type)
        case .FixedBytes(_):
            return try encodeParameter(type)
        case .DynamicBytes:
            return try encodeParameter(type)
        case .FixedArray(_, _):
            return try encodeParameter(type)
        case .DynamicArray(_):
            return try encodeParameter(type)
        case .Tuple(_):
            return try encodeParameter(type)
        }
    }
    
    static func encodeParameter(_ param: Type) throws -> String {
        return try DefaultFunctionEncoder.encodeParameters([param])
    }
    
    static func buildFunctionString(_ method: ContractMethod) -> String {
        let name = method.name
        let params = method.inputs.map {
            $0.getTypeAsString()
        }.joined(separator: ",")
        
        let retString = "\(name)(\(params))"
        
        return retString.replacingOccurrences(of: ABI.TUPLE, with: "")
    }
    
    static func encodeEventSignature(_ event: ContractEvent) throws -> String {
        return try encodeEventSignature(buildEventString(event))
    }
    
    static func encodeEventSignature(_ eventName: String) throws -> String {
        guard let data = eventName.data(using: .utf8) else { throw CaverError.invalidSignature }
        let signature = String(bytes: data.web3.keccak256.web3.bytes)
        return signature
    }
    
    static func buildEventString(_ event: ContractEvent) -> String {
        let name = event.name
        let params = event.inputs.map {
            $0.getTypeAsString()
        }.joined(separator: ",")
        
        let retString = "\(name)(\(params))"
        
        return retString.replacingOccurrences(of: ABI.TUPLE, with: "")
    }
    
    private func getLength(_ parameters: [Type]) -> Int {
        var count = 0
        parameters.forEach {
            let type = $0.rawType
            
            switch (type, $0) {
            case (_, is ABITuple):
                count += getStaticStructComponentSize($0 as! ABITuple)
            break
            case (.FixedArray(_, _), _):
                count += getStaticArrayElementSize($0)
            break
            case (.DynamicArray(_), _):
            break
            default: break
            }
        }
        return count
    }
    
    public func getStaticStructComponentSize(_ staticStruct: ABITuple) -> Int {
        var count = 0
        staticStruct.encodableValues.forEach {
            $0
        }
        return count
    }
    
    public func getStaticArrayElementSize(_ staticArray: Type) -> Int {
        var count = 0
        return count
    }
}
