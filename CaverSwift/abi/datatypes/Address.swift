//
//  Address.swift
//  CaverSwift
//
//  Created by won on 2021/05/12.
//

import Foundation
import BigInt

public struct Address: Codable, Hashable {
    public let val: BigUInt
    public static let zero = Address("0x0000000000000000000000000000000000000000")
    
    public init(_ hexValue: String) {
        self.val = BigUInt(hexValue.cleanHexPrefix, radix: 16) ?? Address.zero.val
    }

    public var toValue: String {
        get {
            self.val.hexa
        }
    }
    
    public static func == (lhs: Address, rhs: Address) -> Bool {
        return lhs.val == rhs.val
    }
}
