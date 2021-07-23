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
                guard let lValues = (lhs.value as? TypeArray)?.values,
                      let rValues = (rhs.value as? TypeArray)?.values else {
                    return false
                }
                if lValues.count != rValues.count {
                    return false
                }
                
                ret = lValues.elementsEqual(rValues) {
                    Type($0) == Type($1)
                }
            case .Tuple(_):
                guard let lValues = (lhs.value as? TypeStruct)?.values,
                      let rValues = (rhs.value as? TypeStruct)?.values else {
                    return false
                }
                if lValues.count != rValues.count {
                    return false
                }                
                
                ret = lValues.elementsEqual(rValues) {
                    Type($0) == Type($1)
                }
            }
        }
        return ret
    }
    
    public var value: ABIType
    var rawType: ABIRawType
    var typeName: String {
        return self.rawType.rawValue
    }
    var size: Int {
        Int(String(describing: type(of: self)).lowercased().filter { "0"..."9" ~= $0 }) ?? MAX_BIT_LENGTH
    }
    
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
    
    public func getValue<T>() -> T? where T : ABIType {
        return value as? T
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
