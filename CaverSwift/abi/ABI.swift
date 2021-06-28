//
//  ABI.swift
//  CaverSwift
//
//  Created by won on 2021/05/10.
//

import Foundation
import BigInt

public class ABI {
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
        let signature = String(bytes: data.keccak256.bytes)
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
        let signature = String(bytes: data.keccak256.bytes)
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
    
    static func decodeParameters(_ method: ContractMethod, _ encoded: String) -> [Type] {
        var params: [Type] = []
        try? method.outputs.forEach {
            let type = try TypeDecoder.makeTypeReference($0.getTypeAsString())
            params.append(type)
        }
        try? FunctionReturnDecoder.decode(encoded, &params)
        return params
    }
    
    static func decodeParameter(_ solidityType: String, _ encoded: String) throws -> Type? {
        return try decodeParameters([solidityType], encoded).first
    }
    
    static func decodeParameters(_ solidityTypeList: [String], _ encoded: String) throws -> [Type] {
        var params: [Type] = []
        try solidityTypeList.forEach {
            let type = try TypeDecoder.makeTypeReference($0)
            params.append(type)
        }
        try FunctionReturnDecoder.decode(encoded, &params)
        return params
    }
}
