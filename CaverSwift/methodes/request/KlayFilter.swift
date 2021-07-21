//
//  KlayFilter.swift
//  CaverSwift
//
//  Created by won on 2021/07/21.
//

import Foundation

public class KlayFilter: Filter {
    private(set) public var fromBlock = DefaultBlockParameterName.Latest
    private(set) public var toBlock = DefaultBlockParameterName.Latest
    private(set) public var address: [String] = []
    
    internal init(_ fromBlock: DefaultBlockParameterName = DefaultBlockParameterName.Latest, _ toBlock: DefaultBlockParameterName = DefaultBlockParameterName.Latest, _ address: [String] = []) {
        super.init()
        self.fromBlock = fromBlock
        self.toBlock = toBlock
        self.address = address
    }
    
    internal init(_ fromBlock: DefaultBlockParameterName = DefaultBlockParameterName.Latest, _ toBlock: DefaultBlockParameterName = DefaultBlockParameterName.Latest, _ address: String) {
        super.init()
        self.fromBlock = fromBlock
        self.toBlock = toBlock
        self.address.append(address)
    }
        
    enum CodingKeys: String, CodingKey {
        case fromBlock
        case toBlock
        case address
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let fromBlock = try? container.decode(String.self, forKey: .fromBlock) {
            self.fromBlock = DefaultBlockParameterName(rawValue: fromBlock)
        }
        if let toBlock = try? container.decode(String.self, forKey: .toBlock) {
            self.toBlock = DefaultBlockParameterName(rawValue: toBlock)
        }
        if let address = try? container.decode([String].self, forKey: .address) {
            self.address = address
        }
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.unkeyedContainer()
        var nested = container.nestedContainer(keyedBy: CodingKeys.self)
        try nested.encode(self.fromBlock.stringValue, forKey: .fromBlock)
        try nested.encode(self.toBlock.stringValue, forKey: .toBlock)
        if !self.address.isEmpty {
            try nested.encode(self.address, forKey: .address)
        }        
    }
    
    public override func getThis() -> Filter {
        return self
    }
}
