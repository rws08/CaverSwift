//
//  FunctionReturnDecoder.swift
//  CaverSwift
//
//  Created by won on 2021/05/24.
//

import Foundation
import BigInt

public class FunctionReturnDecoder {
    static func decode(_ rawInput: String, _ outputParameters: inout [Type]) throws {
        if rawInput.drop0xPrefix.isEmpty {
            return
        }
        
        var offset = 0
        guard let bytes = rawInput.web3.bytesFromHex else { throw ABIError.invalidValue }
        for (idx, item) in outputParameters.enumerated() {
            let decoded = try FunctionReturnDecoder.decode(bytes, forType: item, offset: offset)
            
            outputParameters[idx].value = decoded
            offset += outputParameters[idx].rawType.memory
        }
    }
    
    static func decode(_ data: [UInt8], forType type: Type, offset: Int = 0) throws -> ABIType {
        let typeABI = type.rawType
        switch typeABI {
        case .FixedBool:
            guard data.count > 0 else {
                throw ABIError.invalidValue
            }
            
            guard let result = try decode(data, forType: Type(type.value, .FixedUInt(typeABI.size)), offset: offset) as? BigUInt else {
                throw ABIError.invalidValue
            }
            return result == BigUInt(1)
        case .FixedAddress:
            guard data.count > 0 else {
                throw ABIError.invalidValue
            }
            guard let result = try decode(data, forType: Type(type.value, .FixedUInt(typeABI.size)), offset: offset) as? BigUInt else {
                throw ABIError.invalidValue
            }
            return Address(result.web3.hexString)
        case .DynamicString:
            guard let result = try decode(data, forType: Type(type.value, .DynamicBytes), offset: offset) as? Data else {
                throw ABIError.invalidValue
            }
            return String(data: result, encoding: .utf8)!
        case .DynamicBytes:
            guard data.count > 0 else {
                return Data()
            }
            
            guard let offsetHex = (try decode(data, forType: Type(type.value, .FixedUInt(MAX_BIT_LENGTH)), offset: offset)) as? BigUInt,
                  let newOffset = Int(hex: offsetHex.hexa) else {
                throw ABIError.invalidValue
            }
            
            guard let sizeHex = (try decode(data, forType: Type(type.value, .FixedUInt(MAX_BIT_LENGTH)), offset: newOffset)) as? BigUInt,
                  let size = Int(hex: sizeHex.hexa) else {
                throw ABIError.invalidValue
            }
            
            guard size > 0 else {
                return Data()
            }
            let lowerRange = newOffset + MAX_BYTE_LENGTH
            let upperRange = newOffset + MAX_BYTE_LENGTH + size - 1
            guard lowerRange <= upperRange else { throw ABIError.invalidValue }
            guard data.count > upperRange else { throw ABIError.invalidValue }
            
            return Data(Array(data[lowerRange...upperRange]))
        case .FixedInt(let size):
            guard data.count > 0 else {
                return BigInt.zero
            }
            let startIndex = offset + MAX_BYTE_LENGTH - typeABI.size
            let endIndex = offset + MAX_BYTE_LENGTH - 1
            guard data.count > endIndex else { throw ABIError.invalidValue }
            let buf = Data( Array(data[startIndex...endIndex]))
            var value = BigInt(twosComplement: buf)
            if value.sign == .minus {
                // BigInt 라이브러리에 비트 단위 MAX가 없어서 음수에 대한 별도 처리
                value = MAX_INT(size) - value
            }
            return value
        case .FixedUInt(_):
            guard data.count > 0 else {
                return BigUInt.zero
            }
            let startIndex = offset + MAX_BYTE_LENGTH - typeABI.size
            let endIndex = offset + MAX_BYTE_LENGTH - 1
            guard data.count > endIndex else { throw ABIError.invalidValue }
            let buf = Data( Array(data[startIndex...endIndex]))
            // Do not use BInt because address is treated as uint160 and BInt is based on 64 bits (160/64 = 2.5)
            return BigUInt(buf)
        case .FixedBytes(let size):
            guard data.count > 0 else {
                return Data()
            }
            let startIndex = offset
            let endIndex = offset + size - 1
            guard data.count > endIndex else { throw ABIError.invalidValue }
            return Data( Array(data[startIndex...endIndex]))
        case .FixedArray(let arrayType, let size) where arrayType.isDynamic:
            var result: [ABIType] = []
            var currentOffset = offset
            
            guard let offsetHex = (try decode(data, forType: Type(type.value, .FixedUInt(MAX_BIT_LENGTH)), offset: currentOffset)) as? BigUInt else {
                throw ABIError.invalidValue
            }
            
            currentOffset = Int(hex: offsetHex.hexa) ?? currentOffset
            
            for instanceOffset in 0 ..< size {
                result.append(try decode(Array(data.dropFirst(currentOffset)), forType: Type(type.value, arrayType), offset: instanceOffset * MAX_BYTE_LENGTH))
            }
            
            return TypeArray(result, typeABI)
        case .FixedArray(let arrayType, let size):
            var result: [ABIType] = []
            var size = size
            var currentOffset = offset
            
            try deepDecode(data: data, type: Type(type.value, arrayType), result: &result, offset: &currentOffset, size: &size)
            
            return TypeArray(result, typeABI)
        // NOTE: Needs analysis to confirm it can handle an inner `DynamicArray` too
        case .DynamicArray(let arrayType) where arrayType.isDynamic:
            var result: [ABIType] = []
            var currentOffset = offset

            guard let offsetHex = (try decode(data, forType: Type(type.value, .FixedUInt(MAX_BIT_LENGTH)), offset: currentOffset)) as? BigUInt else {
                throw ABIError.invalidValue
            }
            
            currentOffset = Int(hex: offsetHex.hexa) ?? currentOffset

            guard let lengthHex = (try decode(data, forType: Type(type.value, .FixedUInt(MAX_BIT_LENGTH)), offset: currentOffset)) as? BigUInt else {
                throw ABIError.invalidValue
            }
            guard let length = Int(hex: lengthHex.hexa) else {
                throw ABIError.invalidValue
            }

            currentOffset += MAX_BYTE_LENGTH
            
            for instanceOffset in 0 ..< length {
                result.append(try decode(Array(data.dropFirst(currentOffset)), forType: Type(type.value, arrayType), offset: instanceOffset * MAX_BYTE_LENGTH))
            }

            return TypeArray(result, typeABI)
        case .DynamicArray(let arrayType):
            var result: [ABIType] = []
            var newOffset = offset
            
            guard let offsetHex = (try decode(data, forType: Type(type.value, .FixedUInt(MAX_BIT_LENGTH)), offset: newOffset)) as? BigUInt else {
                throw ABIError.invalidValue
            }
            
            newOffset = Int(hex: offsetHex.hexa) ?? newOffset
            
            guard let sizeHex = (try decode(data, forType: Type(type.value, .FixedUInt(MAX_BIT_LENGTH)), offset: newOffset)) as? BigUInt else {
                throw ABIError.invalidValue
            }
            var size = Int(hex: sizeHex.hexa) ?? newOffset
            newOffset += MAX_BYTE_LENGTH
            
            try deepDecode(data: data, type: Type(type.value, arrayType), result: &result, offset: &newOffset, size: &size)
            return TypeArray(result, typeABI)
        case .Tuple(let subTypes) where typeABI.isDynamic:
            var result: [ABIType] = []
            var currentOffset = offset
            
            guard let offsetHex = (try decode(data, forType: Type(type.value, .FixedUInt(MAX_BIT_LENGTH)), offset: currentOffset)) as? BigUInt else {
                throw ABIError.invalidValue
            }
            
            currentOffset = Int(hex: offsetHex.hexa) ?? currentOffset
            
            var newOffset = 0
            for (_, item) in subTypes.enumerated() {
                result.append(try decode(Array(data.dropFirst(currentOffset)), forType: Type(type.value, item), offset: newOffset))
                newOffset += item.memory
            }
            
            return TypeStruct(result, subTypes)
        case .Tuple(let subTypes):
            var result: [ABIType] = []
            var currentOffset = offset
            
            for (_, item) in subTypes.enumerated() {
                result.append(try decode(data, forType: Type(type.value, item), offset: currentOffset))
                currentOffset += item.memory
            }
            
            return TypeStruct(result, subTypes)
        }
    }
    
    private static func deepDecode(data: [UInt8], type: Type, result: inout [ABIType], offset: inout Int, size: inout Int) throws -> Void {
        if size < 1 { return }
        
        result.append((try decode(data, forType: type, offset: offset)))
        offset += type.rawType.memory
        size -= 1
        
        try deepDecode(data: data, type: type, result: &result, offset: &offset, size: &size)
    }
}
