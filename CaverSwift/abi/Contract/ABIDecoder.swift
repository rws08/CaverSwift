//
//  ABIDecoder.swift
//  web3swift
//
//  Created by Matt Marshall on 16/03/2018.
//  Copyright © 2018 Argent Labs Limited. All rights reserved.
//

import Foundation
import BigInt

public class ABIDecoder {
    typealias RawParsedABI = [[String]]
    
    static func decodeData(_ data: RawABI, types: [ABIRawType], asArray: Bool = false) throws -> RawParsedABI {
        var result = RawParsedABI()
        var offset = 0
        
        let expectingArray = asArray || types.count > 1
        if data == "0x" && expectingArray {
            return []
        }
        
        for type in types {
            if data == "0x" && type.isArray {
                result.append([])
            } else {
                guard let bytes = data.bytesFromHex else { throw ABIError.invalidValue }
                let decoded = try decode(bytes, forType: type, offset: offset)
                result.append(decoded)
            }
            offset += type.memory
        }
        return result
    }
    
    static func decode(_ data: [UInt8], forType type: ABIRawType, offset: Int = 0) throws -> ABIEntry {
        switch type {
        case .FixedBool:
            guard data.count > 0 else {
                throw ABIError.invalidValue
            }
            return try decode(data, forType: ABIRawType.FixedUInt(type.size), offset: offset)
        case .FixedAddress:
            guard data.count > 0 else {
                throw ABIError.invalidValue
            }
            return try decode(data, forType: ABIRawType.FixedUInt(type.size), offset: offset)
        case .DynamicString:
            return try decode(data, forType: ABIRawType.DynamicBytes, offset: offset)
        case .DynamicBytes:
            guard data.count > 0 else {
                return [""]
            }
            guard let offsetHex = (try decode(data, forType: ABIRawType.FixedUInt(256), offset: offset)).first,
                  let newOffset = Int(hex: offsetHex) else {
                throw ABIError.invalidValue
            }
            guard let sizeHex = (try decode(data, forType: ABIRawType.FixedUInt(256), offset: newOffset)).first,
                  let bint = BigInt(hex: sizeHex.cleanHexPrefix) else {
                throw ABIError.invalidValue
            }
            let size = Int(bint)
            guard size > 0 else {
                return [""]
            }
            let lowerRange = newOffset + 32
            let upperRange = newOffset + 32 + size - 1
            guard lowerRange <= upperRange else { throw ABIError.invalidValue }
            guard data.count > upperRange else { throw ABIError.invalidValue }
            let hex = String(bytes: Array(data[lowerRange...upperRange]))
            return [hex]
        case .FixedInt(_):
            guard data.count > 0 else {
                return [""]
            }
            let startIndex = offset + 32 - type.size
            let endIndex = offset + 31
            guard data.count > endIndex else { throw ABIError.invalidValue }
            let buf = Data( Array(data[startIndex...endIndex]))
            let bint = BigInt(twosComplement: buf)
            return [String(bytes: bint.bytes)]
        case .FixedUInt(_):
            guard data.count > 0 else {
                return [""]
            }
            let startIndex = offset + 32 - type.size
            let endIndex = offset + 31
            guard data.count > endIndex else { throw ABIError.invalidValue }
            let hex = String(bytes: Array(data[startIndex...endIndex])) // Do not use BInt because address is treated as uint160 and BInt is based on 64 bits (160/64 = 2.5)
            return [hex]
        case .FixedBytes(let size):
            guard data.count > 0 else {
                return [""]
            }
            let startIndex = offset
            let endIndex = offset + size - 1
            guard data.count > endIndex else { throw ABIError.invalidValue }
            let hex = String(bytes: Array(data[startIndex...endIndex]))
            return [hex]
        case .FixedArray(let arrayType, _):
            var result: [String] = []
            var size = type.size
            var newOffset = offset
            
            try deepDecode(data: data, type: arrayType, result: &result, offset: &newOffset, size: &size)
            return result
        // NOTE: Needs analysis to confirm it can handle an inner `DynamicArray` too
        case .DynamicArray(let arrayType) where arrayType.isDynamic:
            var result: [String] = []
            var currentOffset = offset

            guard let offsetHex = (try decode(data, forType: ABIRawType.FixedUInt(256), offset: currentOffset)).first else {
                throw ABIError.invalidValue
            }

            currentOffset = Int(hex: offsetHex) ?? currentOffset

            guard let lengthHex = (try decode(data, forType: ABIRawType.FixedUInt(256), offset: currentOffset)).first else {
                throw ABIError.invalidValue
            }
            guard let length = Int(hex: lengthHex) else {
                throw ABIError.invalidValue
            }

            currentOffset += 32

            for instanceOffset in 0 ..< length {
                result += try decode(Array(data.dropFirst(currentOffset)), forType: arrayType, offset: instanceOffset * 32)
            }

            return result
        case .DynamicArray(let arrayType):
            var result: [String] = []
            var newOffset = offset
            
            guard let offsetHex = (try decode(data, forType: ABIRawType.FixedUInt(256), offset: newOffset)).first else {
                throw ABIError.invalidValue
            }
            newOffset = Int(hex: offsetHex) ?? newOffset
            
            guard let sizeHex = (try decode(data, forType: ABIRawType.FixedUInt(256), offset: newOffset)).first else {
                throw ABIError.invalidValue
            }
            guard var size = Int(hex: sizeHex) else {
                throw ABIError.invalidValue
            }
            newOffset += 32
            
            try deepDecode(data: data, type: arrayType, result: &result, offset: &newOffset, size: &size)
            return result
        case .Tuple:
            throw ABIError.notCurrentlySupported
        }
    }
    
    private static func deepDecode(data: [UInt8], type: ABIRawType, result: inout [String], offset: inout Int, size: inout Int) throws -> Void {
        if size < 1 { return }
        
        guard let stringValue = (try decode(data, forType: type, offset: offset)).first else {
            throw ABIError.invalidValue
        }
        result.append(stringValue)
        offset += type.memory
        size -= 1
        
        try deepDecode(data: data, type: type, result: &result, offset: &offset, size: &size)
    }
    
    public static func decode(_ data: String, to: Address.Type) throws -> Address {
        let address = Address(data)
        guard address.toValue.hasPrefix("0x") else {
            throw ABIError.invalidValue
        }
        
        return address
    }
    
    public static func decode(_ data: String, to: Uint.Type) throws -> Uint {
        guard let val = BigUInt(hex: data) else {
            throw ABIError.invalidValue
        }
        return Uint(val)
    }
}
