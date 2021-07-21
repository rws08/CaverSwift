//
//  Quantity.swift
//  CaverSwift
//
//  Created by won on 2021/05/11.
//

import Foundation

public class Quantity: Decodable {
    public var val = BigInt.zero
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let val = try container.decode(String.self)
        self.val = BigInt(val.cleanHexPrefix, radix: 16) ?? BigInt.zero        
    }
}
