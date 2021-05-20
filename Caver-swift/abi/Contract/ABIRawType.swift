//
//  ABIRawType.swift
//  web3swift
//
//  Created by Matt Marshall on 16/03/2018.
//  Copyright © 2018 Argent Labs Limited. All rights reserved.
//

import Foundation
import BigInt

public enum ABIError: Error {
    case invalidSignature
    case invalidType
    case invalidValue
    case incorrectParameterCount
    case notCurrentlySupported
}

public enum ABIRawType {
    case FixedUInt(Int)
    case FixedInt(Int)
    case FixedAddress
    case FixedBool
    case FixedBytes(Int)
    case DynamicBytes
    case DynamicString
    indirect case FixedArray(ABIRawType, Int)
    indirect case DynamicArray(ABIRawType)
    indirect case Tuple([ABIRawType])
}

extension ABIRawType: RawRepresentable {
    public init?(rawValue: String) {
        // Specific match
        if rawValue == "uint" {
            self = ABIRawType.FixedUInt(256)
            return
        } else if rawValue == "int" {
            self = ABIRawType.FixedInt(256)
            return
        } else if rawValue == "address" {
            self = ABIRawType.FixedAddress
            return
        } else if rawValue == "bool" {
            self = ABIRawType.FixedBool
            return
        } else if rawValue == "bytes" {
            self = ABIRawType.DynamicBytes
            return
        }  else if rawValue == "string" {
            self = ABIRawType.DynamicString
            return
        }
        
        // Arrays
        let components = rawValue.components(separatedBy: CharacterSet(charactersIn: "[]"))
        if components.count >= 3 {
            let sub = rawValue[rawValue.startIndex..<rawValue.lastIndex(of: "[")!]
            if components[components.count - 2].isEmpty {
                if let arrayType = ABIRawType(rawValue: String(sub)) {
                    self = ABIRawType.DynamicArray(arrayType)
                    return
                }
            } else {
                let num = String(components[components.count - 2].filter { "0"..."9" ~= $0 })
                guard let int = Int(num) else { return nil }
                if let arrayType = ABIRawType(rawValue: String(sub)) {
                    self = ABIRawType.FixedArray(arrayType, int)
                    return
                }
            }
        }
        
        // Variable sizes
        if rawValue.starts(with: "uint") {
            let num = String(rawValue.filter { "0"..."9" ~= $0 })
            guard let int = Int(num) else { return nil }
            self = ABIRawType.FixedUInt(int)
            return
        } else if rawValue.starts(with: "int") {
            let num = String(rawValue.filter { "0"..."9" ~= $0 })
            guard let int = Int(num) else { return nil }
            self = ABIRawType.FixedInt(int)
            return
        } else if rawValue.starts(with: "bytes") {
            let num = String(rawValue.filter { "0"..."9" ~= $0 })
            guard let int = Int(num) else { return nil }
            self = ABIRawType.FixedBytes(int)
            return
        }
        
        return nil
    }
    
    public var rawValue: String {
        switch self {
        case .FixedUInt(let size): return "uint\(size)"
        case .FixedInt(let size): return "int\(size)"
        case .FixedAddress: return "address"
        case .FixedBool: return "bool"
        case .FixedBytes(let size): return "bytes\(size)"
        case .DynamicBytes: return "bytes"
        case .DynamicString: return "string"
        case .FixedArray(let type, let size): return "\(type.rawValue)[\(size)]"
        case .DynamicArray(let type): return "\(type.rawValue)[]"
        case .Tuple(let types): return "(\(types.map(\.rawValue).joined(separator: ",")))"
        }
    }
    
    public var isDynamic: Bool {
        switch self {
        case .FixedArray(let type, _):
            return type.isDynamic
        case .DynamicBytes, .DynamicString, .DynamicArray(_):
            return true
        case .Tuple(let types):
            return types.filter(\.isDynamic).count > 0
        default:
            return false
        }
    }
    
    public var isArray: Bool {
        switch self {
        case .FixedArray(_, _), .DynamicArray(_):
            return true
        default:
            return false
        }
    }
    
    public var isPaddedInDynamic: Bool {
        switch self {
        case .FixedUInt, .FixedInt:
            return true
        default:
            return false
        }
    }
    
    public var size: Int {
        switch self {
        case .FixedBool:
            return 8
        case .FixedAddress:
            return 160
        case .FixedUInt(let size), .FixedInt(let size):
            return size / 8
        case .FixedBytes(let size), .FixedArray(_, let size):
            return size
        case .DynamicArray(_):
            return -1
        default:
            return 0
        }
    }
    
    public var memory: Int {
        switch self {
        case .FixedArray(let type, let size):
            return type.memory * size
        default:
            return 32
        }
    }
}
