//
//  TypeDecoder.swift
//  Caver-swift
//
//  Created by won on 2021/05/14.
//

import Foundation
import BigInt

class TypeDecoder {
    static func instantiateType(_ solidityType: String, _ param: Any) throws -> Type {
        guard let abiType = ABIRawType(rawValue: solidityType) else {
            throw CaverError.UnsupportedOperationException("Unsupported TypeReference: \(solidityType)")
        }
        
        var param = param
        if param is [Any] {
            switch abiType {
            case .Tuple(let values):
                guard let paramArray = param as? [Any] else { throw CaverError.UnsupportedOperationException("Unsupported TypeReference: \(solidityType)") }
                var types:[ABIType] = []
                var subRawType:[ABIRawType] = []
                for (idx, item) in paramArray.enumerated() {
                    let type = try instantiateType(values[idx].rawValue, item)
                    types.append(type.value)
                    subRawType.append(type.rawType)
                }
                var structs = TypeStruct(values: types)
                structs.subRawType = subRawType
                param = structs
            case .DynamicArray(let type), .FixedArray(let type, _):
                guard let paramArray = param as? [Any] else { throw CaverError.UnsupportedOperationException("Unsupported TypeReference: \(solidityType)") }
                var types:[ABIType] = []
                try paramArray.forEach {
                    let type = try instantiateType(type.rawValue, $0)
                    types.append(type.value)
                }
                var array = TypeArray(values: types)
                
                let components = solidityType.components(separatedBy: CharacterSet(charactersIn: "[]"))
                if components.count > 3 {
                    array.subType = type.rawValue
                } else {
                    array.subType = components[0]
                }
                
                param = array
            default:
                break
            }
        } else if !(param is ABIType) {
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
                    param = paramStr.addHexaLength.web3.hexData ?? Data()
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
        var value = Type(param)
        value.rawType = abiType
        
        return value
    }
}
