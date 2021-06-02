//
//  Quantity.swift
//  CaverSwift
//
//  Created by won on 2021/05/11.
//

import Foundation
import BigInt

public class Quantity: Decodable {
    var val = BigInt.zero
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let val = try container.decode(String.self)
        self.val = BigInt(val.drop0xPrefix, radix: 16) ?? BigInt.zero        
    }
}
