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
        if let val = try? container.decode(String.self) {
            self.val = BigInt(val.cleanHexPrefix, radix: 16) ?? BigInt.zero
        } else if let val = try? container.decode(Int.self) {
            self.val = BigInt(val) 
        }
    }
    
    public var toString: String {
        get {
            self.val.hexa
        }
    }
    
    public var intValue: Int {
        get {
            self.val.int
        }
    }
}
