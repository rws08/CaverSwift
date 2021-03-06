//
//  ABIEncoder.swift
//  web3swift
//
//  Created by Matt Marshall on 16/03/2018.
//  Copyright © 2018 Argent Labs Limited. All rights reserved.
//

import Foundation
import BigInt

public class ABIEncoder {
    public enum EncodedValue {
        case value(bytes: [UInt8], isDynamic: Bool, staticLength: Int)
        indirect case container(values: [EncodedValue], isDynamic: Bool, size: Int?)
        
        public var bytes: [UInt8] {
            switch self {
            case .value(bytes: let encoded, _, _):
                return encoded
            case .container(let values, _, _):
                return values.flatMap(\.bytes)
            }
        }
        
        public var isDynamic: Bool {
            switch self {
            case .value(_, let isDynamic, _):
                return isDynamic
            case .container(_, let isDynamic, _):
                return isDynamic
            }
        }
        
        var staticLength: Int {
            switch self {
            case .value(_, _, let staticLength):
                return staticLength
            case .container(let values, let isDynamic, _):
                if isDynamic {
                    return MAX_BYTE_LENGTH
                } else {
                    return values.map(\.staticLength).reduce(0, +)
                }
            }
        }
        
        public var hexString: String { String(bytes: bytes) }
    }
    
    static func encodeRaw(_ value: Data,
                          forType type: ABIRawType,
                          padded: Bool = true,
                          size: Int = 1) throws -> EncodedValue {
        return try encodeRaw(value.hexString, forType: type, padded: padded, size: size)
    }
    
    static func encodeRaw(_ value: String,
                          forType type: ABIRawType,
                          padded: Bool = true,
                          size: Int = 1) throws -> EncodedValue {
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
            let bytes = int.bytes // should be <= 32 bytes
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
            
            let bytes = int.bytes // should be <= 32 bytes
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
            guard let bytes = value.bytesFromHex else { throw ABIError.invalidValue } // Must be 20 bytes
            if padded  {
                encoded = [UInt8](repeating: 0x00, count: MAX_BYTE_LENGTH - bytes.count) + bytes
            } else {
                encoded = bytes
            }
        case .DynamicString:
            let bytes = [UInt8](value.utf8)
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
            let stringValue = value.cleanHexPrefix
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
        case .Tuple:
            throw ABIError.notCurrentlySupported
        case .FixedArray:
            throw ABIError.notCurrentlySupported
        }
        
        return encoded
    }
}

extension Array where Element == ABIEncoder.EncodedValue {
    func encoded(isDynamic: Bool) throws -> [UInt8] {
        var head = [UInt8]()
        var tail = [UInt8]()
        
        let offset = map { $0.staticLength }.reduce(0, +)
        
        let encode: ([UInt8], Bool, Int?) throws -> Void = { bytes, isDynamic, size in
            if isDynamic {
                let len: [UInt8] = try size.map { try ABIEncoder.encodeRaw(String($0), forType: ABIRawType.FixedUInt(256)).bytes } ?? []
                    
                let position = offset + (tail.count)
                head += try ABIEncoder.encodeRaw(String(position), forType: ABIRawType.FixedInt(256)).bytes
                tail += len + bytes
            } else {
                head += bytes
            }
        }
        
        try forEach { element in
            switch element {
            case .container(let values, let isDynamic, let size):
                try encode(try values.encoded(isDynamic: isDynamic), isDynamic, size)
            case .value(let bytes , let isDynamic, _):
                try encode(bytes, isDynamic, nil)
            }
        }
        
        return head + tail
    }
}
