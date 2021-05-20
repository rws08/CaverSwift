//
//  Type.swift
//  Caver-swift
//
//  Created by won on 2021/05/10.
//

import Foundation
import BigInt

var MAX_BIT_LENGTH = 256
var MAX_BYTE_LENGTH = MAX_BIT_LENGTH / 8

public struct Type: Any {
    var value: ABIType
    var rawType: ABIRawType
    var typeAsString: String { return String(describing: value) }
    init(_ value: ABIType) {
        if value is TypeArray {
            self.value = value
            self.rawType = (value as! TypeArray).rawType
        } else {
            self.value = value
            self.rawType = type(of: value).rawType
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

//extension Array: ABIType {
//    public static var rawType: ABIRawType { .FixedAddress }
//    public static var parser: ParserFunction {
//        return { data in
//            let first = data.first ?? ""
//            guard let value = BigUInt(hex: first) else { throw ABIError.invalidValue }
//            guard value.bitWidth <= 256 else { throw ABIError.invalidValue }
//            return Int(value)
//        }
//    }
//}

public struct TypeArray {
    public var values: [ABIType]
    
    public init(values: [ABIType]) {
        self.values = values
    }
    public var subType: String = ""
    var subRawType: ABIRawType {
        guard let abiType = ABIRawType(rawValue: String(describing: subType)) else {
            return .DynamicString
        }
        return abiType
    }
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
    public var rawType: ABIRawType { .DynamicArray(self.subRawType) }
    public var parser: ParserFunction {
        return self.subParser
    }
}

//public protocol Type: ABIType {
//    var value: Type { get }
//    static var typeAsString: String { get }
//}
//
//extension String: Type {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//}
//
//extension Bool: Type {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//}
//
//extension Address: Type {
//    public var value: Type { self.val }
//    public static var typeAsString: String { return String(describing: self) }
//    public static var rawType: ABIRawType { .FixedAddress }
//    public static var parser: ParserFunction {
//        return { data in
//            let first = data.first ?? ""
//            return try ABIDecoder.decode(first, to: EthereumAddress.self)
//        }
//      }
//}
//
//extension BigInt: Type {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//}
//
//extension BigUInt: Type {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//}
//
//extension UInt8: Type {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//}
//
//extension UInt16: Type {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//}
//
//extension UInt32: Type {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//}
//
//extension UInt64: Type {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//}
//
//extension Int8: Type {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//    public static var rawType: ABIRawType { .FixedInt(8) }
//    public static var parser: ParserFunction {
//        return { data in
//            let first = data.first ?? ""
//            guard let value = BigInt(hex: first) else { throw ABIError.invalidValue }
//            guard value.bitWidth <= 8 else { throw ABIError.invalidValue }
//            return Int8(value)
//        }
//    }
//}
//
//extension Int16: Type {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//    public static var rawType: ABIRawType { .FixedInt(16) }
//    public static var parser: ParserFunction {
//        return { data in
//            let first = data.first ?? ""
//            guard let value = BigInt(hex: first) else { throw ABIError.invalidValue }
//            guard value.bitWidth <= 16 else { throw ABIError.invalidValue }
//            return Int16(value)
//        }
//    }
//}
//
//extension Int32: Type {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//    public static var rawType: ABIRawType { .FixedInt(32) }
//    public static var parser: ParserFunction {
//        return { data in
//            let first = data.first ?? ""
//            guard let value = BigInt(hex: first) else { throw ABIError.invalidValue }
//            guard value.bitWidth <= 32 else { throw ABIError.invalidValue }
//            return Int32(value)
//        }
//    }
//}
//
//extension Int64: Type {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//    public static var rawType: ABIRawType { .FixedInt(64) }
//    public static var parser: ParserFunction {
//        return { data in
//            let first = data.first ?? ""
//            guard let value = BigInt(hex: first) else { throw ABIError.invalidValue }
//            guard value.bitWidth <= 64 else { throw ABIError.invalidValue }
//            return Int64(value)
//        }
//    }
//}
//
//extension URL : Type {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//}
//
//extension ABITuple {
//    public static var rawType: ABIRawType {
//        .Tuple(Self.types.map { $0.rawType })
//    }
//    public static var parser: ParserFunction {
//        return { data in
//            let first = data.first ?? ""
//            return try ABIDecoder.decode(first, to: String.self)
//        }
//    }
//}
//
//// TODO: Other Int sizes
//
//fileprivate let DataParser: Type.ParserFunction = { data in
//    let first = data.first ?? ""
//    return try ABIDecoder.decode(first, to: Data.self)
//}
//
//extension Data: Type {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//}
//
//// When decoding it's easier to specify a type, instead of type + static size
//public protocol ABIStaticSizeDataType: Type {}
//
//public struct Data1: ABIStaticSizeDataType {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//    public static var rawType: ABIRawType {
//        .FixedBytes(1)
//    }
//
//    public static var parser: ParserFunction = DataParser
//}
//
//public struct Data2: ABIStaticSizeDataType {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//    public static var rawType: ABIRawType {
//        .FixedBytes(2)
//    }
//
//    public static var parser: ParserFunction = DataParser
//}
//
//public struct Data3: ABIStaticSizeDataType {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//    public static var rawType: ABIRawType {
//        .FixedBytes(3)
//    }
//
//    public static var parser: ParserFunction = DataParser
//}
//
//public struct Data4: ABIStaticSizeDataType {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//    public static var rawType: ABIRawType {
//        .FixedBytes(4)
//    }
//
//    public static var parser: ParserFunction = DataParser
//}
//
//public struct Data5: ABIStaticSizeDataType {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//    public static var rawType: ABIRawType {
//        .FixedBytes(5)
//    }
//
//    public static var parser: ParserFunction = DataParser
//}
//
//public struct Data6: ABIStaticSizeDataType {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//    public static var rawType: ABIRawType {
//        .FixedBytes(6)
//    }
//
//    public static var parser: ParserFunction = DataParser
//}
//
//public struct Data7: ABIStaticSizeDataType {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//    public static var rawType: ABIRawType {
//        .FixedBytes(7)
//    }
//
//    public static var parser: ParserFunction = DataParser
//}
//
//public struct Data8: ABIStaticSizeDataType {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//    public static var rawType: ABIRawType {
//        .FixedBytes(8)
//    }
//
//    public static var parser: ParserFunction = DataParser
//}
//
//public struct Data9: ABIStaticSizeDataType {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//    public static var rawType: ABIRawType {
//        .FixedBytes(9)
//    }
//
//    public static var parser: ParserFunction = DataParser
//}
//
//public struct Data10: ABIStaticSizeDataType {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//    public static var rawType: ABIRawType {
//        .FixedBytes(10)
//    }
//
//    public static var parser: ParserFunction = DataParser
//}
//
//public struct Data11: ABIStaticSizeDataType {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//    public static var rawType: ABIRawType {
//        .FixedBytes(11)
//    }
//
//    public static var parser: ParserFunction = DataParser
//}
//
//public struct Data12: ABIStaticSizeDataType {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//    public static var rawType: ABIRawType {
//        .FixedBytes(12)
//    }
//
//    public static var parser: ParserFunction = DataParser
//}
//
//public struct Data13: ABIStaticSizeDataType {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//    public static var rawType: ABIRawType {
//        .FixedBytes(13)
//    }
//
//    public static var parser: ParserFunction = DataParser
//}
//
//public struct Data14: ABIStaticSizeDataType {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//    public static var rawType: ABIRawType {
//        .FixedBytes(14)
//    }
//
//    public static var parser: ParserFunction = DataParser
//}
//
//public struct Data15: ABIStaticSizeDataType {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//    public static var rawType: ABIRawType {
//        .FixedBytes(15)
//    }
//
//    public static var parser: ParserFunction = DataParser
//}
//
//public struct Data16: ABIStaticSizeDataType {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//    public static var rawType: ABIRawType {
//        .FixedBytes(16)
//    }
//
//    public static var parser: ParserFunction = DataParser
//}
//
//public struct Data17: ABIStaticSizeDataType {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//    public static var rawType: ABIRawType {
//        .FixedBytes(17)
//    }
//
//    public static var parser: ParserFunction = DataParser
//}
//
//public struct Data18: ABIStaticSizeDataType {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//    public static var rawType: ABIRawType {
//        .FixedBytes(18)
//    }
//
//    public static var parser: ParserFunction = DataParser
//}
//
//public struct Data19: ABIStaticSizeDataType {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//    public static var rawType: ABIRawType {
//        .FixedBytes(19)
//    }
//
//    public static var parser: ParserFunction = DataParser
//}
//
//public struct Data20: ABIStaticSizeDataType {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//    public static var rawType: ABIRawType {
//        .FixedBytes(20)
//    }
//
//    public static var parser: ParserFunction = DataParser
//}
//
//public struct Data21: ABIStaticSizeDataType {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//    public static var rawType: ABIRawType {
//        .FixedBytes(21)
//    }
//
//    public static var parser: ParserFunction = DataParser
//}
//
//public struct Data22: ABIStaticSizeDataType {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//    public static var rawType: ABIRawType {
//        .FixedBytes(22)
//    }
//
//    public static var parser: ParserFunction = DataParser
//}
//
//public struct Data23: ABIStaticSizeDataType {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//    public static var rawType: ABIRawType {
//        .FixedBytes(23)
//    }
//
//    public static var parser: ParserFunction = DataParser
//}
//
//public struct Data24: ABIStaticSizeDataType {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//    public static var rawType: ABIRawType {
//        .FixedBytes(24)
//    }
//
//    public static var parser: ParserFunction = DataParser
//}
//
//public struct Data25: ABIStaticSizeDataType {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//    public static var rawType: ABIRawType {
//        .FixedBytes(25)
//    }
//
//    public static var parser: ParserFunction = DataParser
//}
//
//public struct Data26: ABIStaticSizeDataType {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//    public static var rawType: ABIRawType {
//        .FixedBytes(26)
//    }
//
//    public static var parser: ParserFunction = DataParser
//}
//
//public struct Data27: ABIStaticSizeDataType {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//    public static var rawType: ABIRawType {
//        .FixedBytes(27)
//    }
//
//    public static var parser: ParserFunction = DataParser
//}
//
//public struct Data28: ABIStaticSizeDataType {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//    public static var rawType: ABIRawType {
//        .FixedBytes(28)
//    }
//
//    public static var parser: ParserFunction = DataParser
//}
//
//public struct Data29: ABIStaticSizeDataType {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//    public static var rawType: ABIRawType {
//        .FixedBytes(29)
//    }
//
//    public static var parser: ParserFunction = DataParser
//}
//
//public struct Data30: ABIStaticSizeDataType {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//    public static var rawType: ABIRawType {
//        .FixedBytes(30)
//    }
//
//    public static var parser: ParserFunction = DataParser
//}
//
//public struct Data31: ABIStaticSizeDataType {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//    public static var rawType: ABIRawType {
//        .FixedBytes(31)
//    }
//
//    public static var parser: ParserFunction = DataParser
//}
//
//public struct Data32: ABIStaticSizeDataType {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//    public static var rawType: ABIRawType {
//        .FixedBytes(32)
//    }
//
//    public static var parser: ParserFunction = DataParser
//}
//
//public struct ABIArray<T: Type>: Type {
//    public var value: Type { self }
//    public static var typeAsString: String { return String(describing: self) }
//
//    let values: [T]
//
//    public init(values: [T]) {
//        self.values = values
//    }
//    public static var rawType: ABIRawType {
//        .DynamicArray(T.rawType)
//    }
//
//    public static var parser: ParserFunction {
//        return T.parser
//    }
//}
