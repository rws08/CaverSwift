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
        if param is Array<Any> {
            let components = solidityType.components(separatedBy: CharacterSet(charactersIn: "[]"))
            var array: TypeArray?
            if components.count > 3 {
                guard let paramArray = param as? Array<Any> else { throw CaverError.UnsupportedOperationException("Unsupported TypeReference: \(solidityType)") }
                let sub = solidityType[solidityType.startIndex..<solidityType.lastIndex(of: "[")!]
                var types:[ABIType] = []
                try paramArray.forEach {
                    let type = try instantiateType(String(sub), $0)
                    types.append(type.value as! TypeArray)
                }
                array = TypeArray(values: types)
                array!.subType = String(sub)
            } else {
                let types:[ABIType] = param as! [ABIType]
                array = TypeArray(values: types)
                array!.subType = components[0]
            }
            if array == nil { throw CaverError.UnsupportedOperationException("Unsupported TypeReference: \(solidityType)") }
            param = array!
        } else if !(param is ABIType) {
            switch param {
            case is Int:
                param = BigInt(param as! Int)
            case is UInt:
                param = BigInt(param as! UInt)
            default:
                throw CaverError.invalidValue
            }
        }
        
        guard let param = param as? ABIType else { throw CaverError.invalidValue }
        var value = Type(param)
        value.rawType = abiType
        
        return value
    }
}
