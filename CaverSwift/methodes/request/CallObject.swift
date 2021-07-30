//
//  CallObject.swift
//  CaverSwift
//
//  Created by won on 2021/05/10.
//

import Foundation
import BigInt

public struct CallObject: Codable {
    var from: String?
    var to: String?
    var gasLimit: BigInt?
    var gasPrice: BigInt?
    var value: BigInt?
    var data: String?
    var block: String?
    
    enum CodingKeys: String, CodingKey {
        case from
        case to
        case gasLimit
        case gasPrice
        case value
        case data
        case block
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        var nested = container.nestedContainer(keyedBy: CodingKeys.self)
        if let from = from {
            try nested.encode(from, forKey: .from)
        }
        if let to = to {
            try nested.encode(to, forKey: .to)
        }
        if let gasLimit = gasLimit {
            try nested.encode(gasLimit.hexa, forKey: .gasLimit)
        }
        if let gasPrice = gasPrice {
            try nested.encode(gasPrice.hexa, forKey: .gasPrice)
        }
        if let value = value {
            try nested.encode(value.hexa, forKey: .value)
        }
        if let data = data {
            try nested.encode(data, forKey: .data)
        }
        if let block = block {
            try container.encode(block)
        }
    }
    
    public init(_ from: String? = nil, _ to: String? = nil, _ gasLimit: BigInt? = nil, _ gasPrice: BigInt? = nil, _ value: BigInt? = nil, _ data: String? = nil) {
        self.from = from
        self.to = to
        self.gasLimit = gasLimit
        self.gasPrice = gasPrice
        self.value = value
        self.data = data
    }
    
    public static func createCallObject(_ from: String? = nil, _ to: String? = nil, _ gasLimit: BigInt? = nil, _ gasPrice: BigInt? = nil, _ value: BigInt? = nil, _ data: String? = nil) -> CallObject {
        return CallObject(from, to, gasLimit, gasPrice, value, data)
    }
    
    public func getGasLimit() -> String? {
        return convert(gasLimit)
    }
    
    public func getGasPrice() -> String? {
        return convert(gasPrice)
    }
    
    public func getValue() -> String? {
        return convert(value)
    }
    
    private func convert(_ value: BigInt?) -> String? {
        guard let value = value else {
            return nil
        }
        
        return Rlp.encode(value)?.hexString
    }
}
