//
//  Address.swift
//  CaverSwift
//
//  Created by won on 2021/05/12.
//

import Foundation
import BigInt

public class Address: Type, ABIType {
    private static var MAX_BYTE_LENGTH = 20
    public let val: BigUInt
    public static let zero = Address("0x0000000000000000000000000000000000000000")
    
    public init(_ hexValue: String) {
        self.val = BigUInt(hexValue.cleanHexPrefix, radix: 16) ?? Address.zero.val
        super.init(val)
        
        self.value = self
        self.rawType = .FixedAddress
    }

    public var toValue: String {
        get {
            let bytes = self.val.bytes
            if Address.MAX_BYTE_LENGTH - bytes.count > 0 {
                let encoded = [UInt8](repeating: 0x00, count: Address.MAX_BYTE_LENGTH - bytes.count) + bytes
                return String(bytes: encoded).addHexPrefix
            }
            
            return self.val.hexa
        }
    }
    
    public static var typeAsString: String { return String(describing: self) }
    public static var rawType: ABIRawType { .FixedAddress }
    public static var parser: ParserFunction {
        return { data in
            let first = data.first ?? ""
            return try ABIDecoder.decode(first, to: Address.self)
        }
    }
}
