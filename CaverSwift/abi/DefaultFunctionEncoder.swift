//
//  DefaultFunctionEncoder.swift
//  CaverSwift
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
                result += encodedDataOffset.hexString.cleanHexPrefix
                dynamicData += encodedValue.hexString.cleanHexPrefix
                dynamicDataOffset += encodedValue.hexString.cleanHexPrefix.count >> 1
            } else {
                result += encodedValue.hexString.cleanHexPrefix
            }
        }
        result += dynamicData
        
        return result
    }
    
    private static func getLength(_ parameters: [Type]) -> Int {
        var count = 0
        parameters.forEach {
            let type = $0.rawType
            if ($0.value is TypeStruct && !type.isDynamic) {
                count += Utils.getStaticStructComponentSize($0.value as! TypeStruct)
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
        var staticSize: Int? = nil
        if (!value.rawType.isDynamic) {
            staticSize = value.rawType.size
        }
        
        switch value.value {
        case let value as Address:
            let encoded: [UInt8] = try encodeRaw(value.val.hexa, forType: type, padded: !packed, size: 1)
            return .value(bytes: encoded,
                              isDynamic: false,
                              staticLength: MAX_BYTE_LENGTH)
        case let value as TypeArray:
            var encodedValues: [ABIEncoder.EncodedValue] = []
            switch type {
            case .FixedArray(_, _):
                if type.isDynamic {
                    try encodeStructsArraysOffsets(value, &encodedValues)
                }
            default:
                let encodedLength = try encode(Type(BigInt(value.values.count)))
                encodedValues.append(encodedLength)
                try encodeArrayValuesOffsets(value, &encodedValues)
            }
            try encodeArrayValues(value, type.size, &encodedValues)
            return .container(values: encodedValues, isDynamic: type.isDynamic, size: nil)
        case let value as TypeStruct:
            let encodedValues = try encodeDynamicStructValues(value)
            return .container(values: encodedValues, isDynamic: type.isDynamic, size: nil)
        case let value as Int:
            return try encodeRaw(String(value), forType: type, padded: !packed)
        case let value as UInt:
            return try encodeRaw(String(value), forType: type, padded: !packed)
        case let value as String:
            return try encodeRaw(value, forType: type, padded: !packed)
        case let value as Bool:
            return try encodeRaw(value ? "true" : "false", forType: type, padded: !packed)
        case let value as BigInt:
            return try encodeRaw(String(value), forType: type, padded: !packed)
        case let value as BigUInt:
            return try encodeRaw(String(value), forType: type, padded: !packed)
        case let value as UInt8:
            return try encodeRaw(String(value), forType: type, padded: !packed)
        case let value as UInt16:
            return try encodeRaw(String(value), forType: type, padded: !packed)
        case let value as UInt32:
            return try encodeRaw(String(value), forType: type, padded: !packed)
        case let value as UInt64:
            return try encodeRaw(String(value), forType: type, padded: !packed)
        case let data as Data:
            if let staticSize = staticSize {
                return try encodeRaw(String(bytes: data.bytes), forType: .FixedBytes(staticSize), padded: !packed)
            } else {
                return try encodeRaw(String(bytes: data.bytes), forType: type, padded: !packed)
            }
        default:
            throw ABIError.notCurrentlySupported
        }
    }
    
    static func encodeRaw(_ value: String,
                          forType type: ABIRawType,
                          padded: Bool = true,
                          size: Int = 1) throws -> ABIEncoder.EncodedValue {
        let encoded: [UInt8] = try encodeRaw(value, forType: type, padded: padded, size: size)
        return .value(bytes: encoded,
                      isDynamic: type.isDynamic,
                      staticLength: type.isDynamic ? MAX_BYTE_LENGTH : MAX_BYTE_LENGTH * size)
    }
    
    private static func encodeRaw(_ value: String,
                                  forType type: ABIRawType,
                                  padded: Bool = true,
                                  size: Int = 1) throws -> [UInt8] {
        var encoded: [UInt8] = [UInt8]()
        
        switch type {
        case .FixedUInt(let typeSize):
            let bytesSize = typeSize / 8
            guard let int = value.isNumeric ? BigUInt(value) : BigUInt(hex: value) else {
                throw ABIError.invalidValue
            }
            let bytes = int.bytes // should be <= MAX_BYTE_LENGTH bytes
            guard bytes.count <= MAX_BYTE_LENGTH, bytesSize <= MAX_BYTE_LENGTH else {
                throw ABIError.invalidValue
            }
            if padded {
                encoded = [UInt8](repeating: 0x00, count: MAX_BYTE_LENGTH - bytes.count) + bytes
            } else {
                encoded = [UInt8](repeating: 0x00, count: bytesSize - bytes.count) + bytes
            }
        case .FixedInt(_):
            guard let int = value.isNumeric ? BigInt(value) : BigInt(hex: value) else {
                throw ABIError.invalidType
            }
            
            let bytes = int.bytes // should be <= MAX_BYTE_LENGTH bytes
            guard bytes.count <= MAX_BYTE_LENGTH else {
                throw ABIError.invalidValue
            }
            
            if int < 0 {
                encoded = [UInt8](repeating: 0xff, count: MAX_BYTE_LENGTH - bytes.count) + bytes
            } else {
                encoded = [UInt8](repeating: 0, count: MAX_BYTE_LENGTH - bytes.count) + bytes
            }
            
            if !padded {
                encoded = bytes
            }
        case .FixedBool:
            encoded = try encodeRaw(value == "true" ? "1":"0", forType: ABIRawType.FixedUInt(8), padded: padded)
        case .FixedAddress:
            guard let bytes = value.bytesFromHex else { throw CaverError.invalidValue } // Must be 20 bytes
            if padded  {
                encoded = [UInt8](repeating: 0x00, count: MAX_BYTE_LENGTH - bytes.count) + bytes
            } else {
                encoded = bytes
            }
        case .DynamicString:
            let bytes = value.bytes
            let len = try encodeRaw(String(bytes.count), forType: ABIRawType.FixedUInt(256)).bytes
            let pack: Int
            if bytes.count == 0 {
                pack = 0
            } else if bytes.count % MAX_BYTE_LENGTH == 0 {
                pack = 1
            }else {
                pack = (bytes.count - (bytes.count % MAX_BYTE_LENGTH)) / MAX_BYTE_LENGTH + 1
            }
            
            if padded {
                encoded = len + bytes + [UInt8](repeating: 0x00, count: pack * MAX_BYTE_LENGTH - bytes.count)
            } else {
                encoded = bytes
            }
        case .DynamicBytes:
            // Bytes are hex encoded
            guard let bytes = value.bytesFromHex else { throw ABIError.invalidValue }
            let len = try encodeRaw(String(bytes.count), forType: ABIRawType.FixedUInt(256)).bytes
            let pack: Int
            if bytes.count == 0 {
                pack = 0
            } else if bytes.count % MAX_BYTE_LENGTH == 0 {
                pack = 1
            }else {
                pack = (bytes.count - (bytes.count % MAX_BYTE_LENGTH)) / MAX_BYTE_LENGTH + 1
            }
            
            if padded {
                encoded = len + bytes + [UInt8](repeating: 0x00, count: pack * MAX_BYTE_LENGTH - bytes.count)
            } else {
                encoded = bytes
            }
        case .FixedBytes(_):
            // Bytes are hex encoded
            guard let bytes = value.bytesFromHex else { throw ABIError.invalidValue }
            if padded {
                encoded = bytes + [UInt8](repeating: 0x00, count: MAX_BYTE_LENGTH - bytes.count)
            } else {
                encoded = bytes
            }
        case .DynamicArray(let type):
            let unitSize = type.size * 2
            let stringValue = value.noHexPrefix
            let size = stringValue.count / unitSize
            
            let padUnits = type.isPaddedInDynamic
            var bytes = [UInt8]()
            for i in (0..<size) {
                let start =  stringValue.index(stringValue.startIndex, offsetBy: i * unitSize)
                let end = stringValue.index(start, offsetBy: unitSize)
                let unitValue = String(stringValue[start..<end])
                let unitBytes = try encodeRaw(unitValue, forType: type, padded: padUnits).bytes
                bytes.append(contentsOf: unitBytes)
            }
            let len = try encodeRaw(String(size), forType: ABIRawType.FixedUInt(256)).bytes
            
            let pack: Int
            if bytes.count == 0 {
                pack = 0
            } else {
                pack = (bytes.count - (bytes.count % MAX_BYTE_LENGTH)) / MAX_BYTE_LENGTH + 1
            }
            
            encoded = len + bytes + [UInt8](repeating: 0x00, count: pack * MAX_BYTE_LENGTH - bytes.count)
        default: throw CaverError.invalidType
        }
        
        return encoded
    }
    
    private static func encodeArrayValues(_ value: TypeArray, _ size: Int?, _ encodedValues: inout [ABIEncoder.EncodedValue]) throws {
        try value.values.forEach {
            let item = Type($0, value.subRawType)
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
            let item = Type(v, value.subRawType)
            return try encode(item).hexString.cleanHexPrefix
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
    
    private static func encodeDynamicStructValues(_ value: TypeStruct) throws -> [ABIEncoder.EncodedValue] {
        var dynamicOffset = 0
        value.subRawType.forEach {
            if $0.isDynamic {
                dynamicOffset += MAX_BYTE_LENGTH
            } else {
                dynamicOffset += $0.memory
            }
        }
        
        var offsetsAndStaticValues: [ABIEncoder.EncodedValue] = []
        var dynamicValues: [ABIEncoder.EncodedValue] = []
        
        for (idx, item) in value.values.enumerated() {
            let subRawType = value.subRawType[idx]
            if subRawType.isDynamic {
                offsetsAndStaticValues.append(try encode(Type(BigInt(dynamicOffset))))
                let type = Type(item, subRawType)
                let encodedValue = try encode(type)
                dynamicValues.append(encodedValue)
                dynamicOffset += encodedValue.hexString.cleanHexPrefix.count >> 1
            } else {
                let type = Type(item, subRawType)
                offsetsAndStaticValues.append(try encode(type))
            }
        }
        offsetsAndStaticValues.append(contentsOf: dynamicValues)
        return offsetsAndStaticValues
    }
}
