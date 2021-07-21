//
//  KlayLogFilter.swift
//  CaverSwift
//
//  Created by won on 2021/07/21.
//

import Foundation

public class KlayLogFilter: KlayFilter {
    private(set) public var blockHash: String?
    
    internal init(_ fromBlock: DefaultBlockParameterName = DefaultBlockParameterName.Latest, toBlock: DefaultBlockParameterName = DefaultBlockParameterName.Latest, address: [String] = [], _ blockHash: String? = nil) {
        super.init(fromBlock, toBlock, address)
        self.blockHash = blockHash
    }
    
    internal init(_ fromBlock: DefaultBlockParameterName = DefaultBlockParameterName.Latest, _ toBlock: DefaultBlockParameterName = DefaultBlockParameterName.Latest, _ address: String, _ blockHash: String? = nil) {
        super.init(fromBlock, toBlock, address)
        self.blockHash = blockHash
    }
    
    enum CodingKeys: String, CodingKey {
        case blockHash
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.blockHash = try? container.decode(String.self, forKey: .blockHash)
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.unkeyedContainer()
        var nested = container.nestedContainer(keyedBy: CodingKeys.self)
        if self.blockHash != nil {
            try nested.encode(self.blockHash, forKey: .blockHash)
        }
    }
    
    public override func getThis() -> KlayLogFilter {
        return self
    }
}
