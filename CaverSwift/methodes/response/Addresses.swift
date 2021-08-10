//
//  Addresses.swift
//  CaverSwift
//
//  Created by won on 2021/07/13.
//

import Foundation

public class Addresses: Decodable {
    public var val: [String] = []
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let val = try container.decode([String].self)
        self.val = val
    }
}
