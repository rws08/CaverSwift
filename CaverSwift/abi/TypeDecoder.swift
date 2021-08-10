//
//  TypeDecoder.swift
//  CaverSwift
//
//  Created by won on 2021/05/14.
//

import Foundation
import BigInt

public class TypeDecoder {
    static func makeTypeReference(_ solidityType: String) throws -> Type {
        guard let abiType = ABIRawType(rawValue: solidityType) else {
            throw CaverError.UnsupportedOperationException("Unsupported TypeReference: \(solidityType)")
        }
        
        var param: ABIType
        switch abiType {
        case .Tuple(let values):
            var types:[ABIType] = []
            var subRawType:[ABIRawType] = []
            try values.forEach {
                let type = try makeTypeReference($0.rawValue)
                types.append(type.value)
                subRawType.append(type.rawType)
            }
            if abiType.isDynamic {
                param = DynamicStruct(types, subRawType)
            } else {
                param = StaticStruct(types, subRawType)
            }
        case .FixedArray(let type, _):
            let types:[ABIType] = [try makeTypeReference(type.rawValue).value]
            param = StaticArray(types, solidityType)
        case .DynamicArray(let type):
            let types:[ABIType] = [try makeTypeReference(type.rawValue).value]
            param = DynamicArray(types, solidityType)
        case .DynamicBytes, .FixedBytes(_):
            param = Data()
        case .FixedAddress:
            param = Address.zero
        case .FixedUInt(_):
            param = BigUInt.zero
        case .FixedInt(_):
            param = BigInt.zero
        case .FixedBool:
            param = false
        case .DynamicString:
            return Utf8String("")
        }
        
        return Type(param, abiType)
    }
    
    static func instantiateType(_ solidityType: String, _ param: Any?) throws -> Type {
        guard let abiType = ABIRawType(rawValue: solidityType) else {
            throw CaverError.UnsupportedOperationException("Unsupported TypeReference: \(solidityType)")
        }
        return try instantiateType(abiType, param)
    }
    
    static func instantiateType(_ abiType: ABIRawType, _ param: Any?) throws -> Type {
        if param is [Any] {
            guard let paramArray = param as? [Any] else { throw CaverError.UnsupportedOperationException("Unsupported TypeReference: \(abiType.rawValue)") }
            
            switch abiType {
            case .Tuple(_):
                return try instantiateStructType(abiType, paramArray)
            case .DynamicArray(_), .FixedArray(_, _):
                return try instantiateArrayType(abiType, paramArray)
            default:
                throw CaverError.invalidValue
            }
        } else {
            return try instantiateAtomicType(abiType, param)
        }
    }
    
    static func instantiateStructType(_ abiType: ABIRawType, _ param: [Any]) throws -> Type {
        var typeStruct: TypeStruct
        switch abiType {
        case .Tuple(let values):
            var types:[ABIType] = []
            var subRawType:[ABIRawType] = []
            for (idx, item) in param.enumerated() {
                let type = try instantiateType(values[idx].rawValue, item)
                types.append(type.value)
                subRawType.append(type.rawType)
            }
            
            if abiType.isDynamic {
                typeStruct = DynamicStruct(types, subRawType)
            } else {
                typeStruct = StaticStruct(types, subRawType)
            }
        default:
            throw CaverError.invalidValue
        }
        
        return Type(typeStruct, abiType)
    }
    
    static func instantiateArrayType(_ abiType: ABIRawType, _ param: [Any]) throws -> Type {
        var typeArray: TypeArray
        switch abiType {
        case .DynamicArray(let type), .FixedArray(let type, _):
            let types:[ABIType] = try param.map {
                let type = try instantiateType(type.rawValue, $0)
                return type.value
            }
            
            typeArray = TypeArray(types, abiType)
        default:
            throw CaverError.invalidValue
        }
        
        return Type(typeArray, abiType)
    }
    
    static func instantiateAtomicType(_ abiType: ABIRawType, _ param: Any?) throws -> Type {
        var param = param
        if !(param is ABIType) {
            switch param {
            case is Int:
                param = BigInt(param as! Int)
            case is UInt:
                param = BigInt(param as! UInt)
            default:
                throw CaverError.invalidValue
            }
        } else {
            switch abiType {
            case .DynamicBytes, .FixedBytes(_):
                if let paramStr = param as? String {
                    param = paramStr.hexData ?? Data()
                } else if let paramInt = param as? BigInt {
                    param = Data.init(hex: paramInt.hexa) ?? Data()
                }
            case .FixedAddress:
                if let paramStr = param as? String {
                    param = Address(paramStr)
                }
            default:
                break
            }
        }
        
        guard let param = param as? ABIType else { throw CaverError.invalidValue }
        
        return Type(param, abiType)
    }
    
    static func decode() {
        
    }
}
