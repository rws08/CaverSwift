//
//  Type.swift
//  CaverSwift
//
//  Created by won on 2021/05/10.
//

import Foundation
import BigInt

let MAX_BIT_LENGTH = 256
let MAX_BYTE_LENGTH = MAX_BIT_LENGTH / 8
let MAX_BYTE_LENGTH_FOR_HEX_STRING = MAX_BYTE_LENGTH << 1
func MAX_INT(_ x: Int) -> BigInt { return (BigInt(Data((0...(x/8)).map{ _ in 0xff })) - 1) }

public class Type: Any, Equatable {
    public static func == (lhs: Type, rhs: Type) -> Bool {
        var ret = false
        if lhs.rawType == rhs.rawType {
            switch lhs.rawType {
            case .FixedUInt(_):
                ret = (lhs.value as? BigUInt) == (rhs.value as? BigUInt)
            case .FixedInt(_):
                ret = (lhs.value as? BigInt) == (rhs.value as? BigInt)
            case .FixedAddress:
                ret = (lhs.value as? Address) == (rhs.value as? Address)
            case .FixedBool:
                ret = (lhs.value as? Bool) == (rhs.value as? Bool)
            case .DynamicBytes, .FixedBytes(_):
                ret = (lhs.value as? Data) == (rhs.value as? Data)
            case .DynamicString:
                ret = (lhs.value as? String) == (rhs.value as? String)
            case .DynamicArray(_), .FixedArray(_, _):
                ret = (lhs.value as? TypeArray) == (rhs.value as? TypeArray)
            case .Tuple(_):
                ret = (lhs.value as? TypeStruct) == (rhs.value as? TypeStruct)
            }
        }
        return ret
    }
    
    var value: ABIType
    var rawType: ABIRawType
    static var typeName: String { return String(describing: self).lowercased() }
    var typeName: String { return String(describing: type(of: self)).lowercased() }
    var size: Int { Int(self.typeName.filter { "0"..."9" ~= $0 }) ?? 0 }
    
    public init(_ value: ABIType, _ rawType: ABIRawType? = nil) {
        if value is TypeArray {
            self.value = value
            guard let rawType = rawType else {
                self.rawType = (value as! TypeArray).rawType
                return
            }
            self.rawType = rawType
        } else if value is TypeStruct {
            self.value = value
            guard let rawType = rawType else {
                self.rawType = (value as! TypeStruct).rawType
                return
            }
            self.rawType = rawType
        } else {
            self.value = value
            guard let rawType = rawType else {
                self.rawType = type(of: value).rawType
                return
            }
            self.rawType = rawType
        }
    }
}

extension Int: ABIType {
    public static var rawType: ABIRawType { .FixedUInt(256) }
    public static var parser: ParserFunction {
        return { data in
            let first = data.first ?? ""
            guard let value = BigUInt(hex: first) else { throw ABIError.invalidValue }
            guard value.bitWidth <= 256 else { throw ABIError.invalidValue }
            return Int(value)
        }
    }
}

extension UInt: ABIType {
    public static var rawType: ABIRawType { .FixedUInt(256) }
    public static var parser: ParserFunction {
        return { data in
            let first = data.first ?? ""
            guard let value = BigUInt(hex: first) else { throw ABIError.invalidValue }
            guard value.bitWidth <= 256 else { throw ABIError.invalidValue }
            return UInt(value)
        }
    }
}

extension Address: ABIType {
    public var value: ABIType { self.val }
    public static var typeAsString: String { return String(describing: self) }
    public static var rawType: ABIRawType { .FixedAddress }
    public static var parser: ParserFunction {
        return { data in
            let first = data.first ?? ""
            return try ABIDecoder.decode(first, to: EthereumAddress.self)
        }
    }
}

public struct TypeStruct: Equatable {
    public static func == (lhs: TypeStruct, rhs: TypeStruct) -> Bool {
        return lhs.values.elementsEqual(rhs.values) { lhsItem, rhsItem in
            Type(lhsItem) == Type(rhsItem)
        }
    }
    
    public var values: [ABIType]
    
    public init(_ values: [ABIType], _ subRawType:[ABIRawType]) {
        self.values = values
        self.subRawType = subRawType
    }
    public var subRawType: [ABIRawType] = []
    var subParser: ParserFunction = String.parser
}

extension TypeStruct: ABIType {
    public static var rawType: ABIRawType {
        .Tuple([])
    }
    
    public static var parser: ParserFunction {
        String.parser
    }
    
    public var value: ABIType { self }
    public var rawType: ABIRawType { .Tuple(self.subRawType) }
    public var parser: ParserFunction {
        return self.subParser
    }
}

public struct TypeArray: Equatable {
    public static func == (lhs: TypeArray, rhs: TypeArray) -> Bool {
        return lhs.values.elementsEqual(rhs.values) { lhsItem, rhsItem in
            Type(lhsItem) == Type(rhsItem)
        }
    }
    
    public var rawType = ABIRawType.DynamicArray(.DynamicString)
    public var values: [ABIType]
    
    public init(_ values: [ABIType], _ solidityType: String? = nil) {
        self.values = values
        if solidityType != nil {
            self.rawType = ABIRawType(rawValue: solidityType!) ?? .DynamicArray(.DynamicString)
            guard let components = solidityType?.components(separatedBy: CharacterSet(charactersIn: "[]")) else { return }
            self.subRawType = ABIRawType(rawValue: String(describing: components[0])) ?? .DynamicString
            if components.count > 3 {
                let sub = solidityType?[solidityType!.startIndex..<solidityType!.lastIndex(of: "[")!]
                self.subRawType = ABIRawType(rawValue: String(describing: String(sub!))) ?? .DynamicString
            }
        }
    }
    
    public init(_ values: [ABIType], _ rawType: ABIRawType) {
        self.init(values, rawType.rawValue)
    }
    
    public var subRawType: ABIRawType = .DynamicString
    var subParser: ParserFunction = String.parser
}

extension TypeArray: ABIType {
    public static var rawType: ABIRawType {
        .DynamicArray(.DynamicString)
    }
    
    public static var parser: ParserFunction {
        String.parser
    }
    
    public var value: ABIType { self }
    public var parser: ParserFunction {
        return self.subParser
    }
}
