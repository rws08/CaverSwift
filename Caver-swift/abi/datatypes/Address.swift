//
//  Address.swift
//  Caver-swift
//
//  Created by won on 2021/05/12.
//

import Foundation

public struct Address: Codable, Hashable {
    public let val: String
    public static let zero = Address("0x0000000000000000000000000000000000000000")
    
    public init(_ value: String) {
        self.val = value.lowercased()
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.val = try container.decode(String.self).lowercased()
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.val)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.val)
    }
    
    public static func == (lhs: Address, rhs: Address) -> Bool {
        return lhs.val == rhs.val
    }
}
