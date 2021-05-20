//
//  DefaultFunctionEncoder.swift
//  Caver-swift
//
//  Created by won on 2021/05/11.
//

import Foundation
import BigInt

public class DefaultFunctionEncoder {
    public static func encodeParameters(_ parameters: [Type], _ result: String = "") throws -> String {
        var result = result
        var dynamicDataOffset = getLength(parameters) * MAX_BYTE_LENGTH;
        var dynamicData = ""
        try parameters.forEach {
            let encodedValue = try encode($0)
            if ($0.rawType.isDynamic) {
                let encodedDataOffset = try encode(Type(BigInt(dynamicDataOffset)))
                result += encodedDataOffset.hexString.drop0xPrefix
                dynamicData += encodedValue.hexString.drop0xPrefix
                dynamicDataOffset += encodedValue.hexString.drop0xPrefix.count >> 1
            } else {
                result += encodedValue.hexString.drop0xPrefix
            }
        }
        result += dynamicData
        
        return result
    }
    
    private static func getLength(_ parameters: [Type]) -> Int {
        var count = 0
        parameters.forEach {
            let type = $0.rawType
            if ($0 is ABITuple) {
                count += Utils.getStaticStructComponentSize($0.value as! ABITuple)
            } else if (type.isArray) {
                if type.isDynamic {
                    count += 1
                } else {
                    count += Utils.getStaticArrayElementSize($0.value as! TypeArray)
                }
            } else {
                count += 1
            }
        }
        
        return count
    }
    
    public static func encode(_ value: Type,
                              packed: Bool = false) throws -> ABIEncoder.EncodedValue {
        let type = value.rawType
        switch value.value {
        case is Address:
            let val = value.value as! Address
            let encoded: [UInt8] = try encodeRaw(val.val, forType: type, padded: !packed, size: 1)
            return .value(bytes: encoded,
                              isDynamic: false,
                              staticLength: 32)
        case is TypeArray:
            let val = value.value as! TypeArray
            var encodedValues: [ABIEncoder.EncodedValue] = []
            switch type {
            case .FixedArray(_, _):
                if type.isDynamic {
                    try encodeStructsArraysOffsets(val, &encodedValues)
                }
            default:
                let encodedLength = try encode(Type(BigInt(val.values.count)))
                encodedValues.append(encodedLength)
                try encodeArrayValuesOffsets(val, &encodedValues)
            }
            try encodeArrayValues(val, type.size, &encodedValues)
            return .container(values: encodedValues, isDynamic: type.isDynamic, size: nil)
        case is Int:
            return try encodeRaw(String(value.value as! Int), forType: type, padded: !packed)
        case is UInt:
            return try encodeRaw(String(value.value as! UInt), forType: type, padded: !packed)
        default:
            var staticSize: Int? = nil
            if (!value.rawType.isDynamic) {
                staticSize = value.rawType.size
            }
            return try ABIEncoder.encode(value.value, staticSize: staticSize, packed: packed)
        }
    }
    
    static func encodeRaw(_ value: String,
                          forType type: ABIRawType,
                          padded: Bool = true,
                          size: Int = 1) throws -> ABIEncoder.EncodedValue {
        let encoded: [UInt8] = try encodeRaw(value, forType: type, padded: padded, size: size)
        return .value(bytes: encoded,
                      isDynamic: type.isDynamic,
                      staticLength: type.isDynamic ? 32 : 32 * size)
    }
    
    private static func encodeRaw(_ value: String,
                                  forType type: ABIRawType,
                                  padded: Bool = true,
                                  size: Int = 1) throws -> [UInt8] {
        var encoded: [UInt8] = [UInt8]()
        
        switch type {
        case .FixedUInt(let typeSize):
            let bytesSize = typeSize / 8
            guard let int = value.web3.isNumeric ? BigUInt(value) : BigUInt(hex: value) else {
                throw ABIError.invalidValue
            }
            let bytes = int.web3.bytes // should be <= 32 bytes
            guard bytes.count <= 32, bytesSize <= 32 else {
                throw ABIError.invalidValue
            }
            if padded {
                encoded = [UInt8](repeating: 0x00, count: 32 - bytes.count) + bytes
            } else {
                encoded = [UInt8](repeating: 0x00, count: bytesSize - bytes.count) + bytes
            }
        case .FixedInt(_):
            guard let int = value.web3.isNumeric ? BigInt(value) : BigInt(hex: value) else {
                throw ABIError.invalidType
            }
            
            let bytes = int.web3.bytes // should be <= 32 bytes
            guard bytes.count <= 32 else {
                throw ABIError.invalidValue
            }
            
            if int < 0 {
                encoded = [UInt8](repeating: 0xff, count: 32 - bytes.count) + bytes
            } else {
                encoded = [UInt8](repeating: 0, count: 32 - bytes.count) + bytes
            }
            
            if !padded {
                encoded = bytes
            }
        case .FixedAddress:
            guard let bytes = value.web3.bytesFromHex else { throw CaverError.invalidValue } // Must be 20 bytes
            if padded  {
                encoded = [UInt8](repeating: 0x00, count: 32 - bytes.count) + bytes
            } else {
                encoded = bytes
            }
        default: throw CaverError.invalidType
        }
        
        return encoded
    }
    
    private static func encodeArrayValues(_ value: TypeArray, _ size: Int?, _ encodedValues: inout [ABIEncoder.EncodedValue]) throws {
        try value.values.forEach {
            var item = Type($0)
            item.rawType = value.subRawType
            encodedValues.append(try encode(item))
        }
    }
    
    private static func encodeArrayValuesOffsets(_ value: TypeArray, _ encodedValues: inout [ABIEncoder.EncodedValue]) throws {
        let isDynamic = value.subRawType.isDynamic
        if isDynamic {
            try encodeStructsArraysOffsets(value, &encodedValues)
        }
    }
    
    private static func encodeStructsArraysOffsets(_ value: TypeArray, _ encodedValues: inout [ABIEncoder.EncodedValue]) throws {
        var offset = value.values.count
        let tailsEncoding = try value.values.map { v -> String in
            var item = Type(v)
            item.rawType = value.subRawType
            return try encode(item).hexString.drop0xPrefix
        }
        
        for (idx, _) in value.values.enumerated() {
            if idx == 0 {
                offset = offset * MAX_BYTE_LENGTH
            } else {
                offset += tailsEncoding[idx-1].count / 2
            }
            
            let encodedDataOffset = try encode(Type(BigInt(offset)))
            encodedValues.append(encodedDataOffset)
        }
    }
}
