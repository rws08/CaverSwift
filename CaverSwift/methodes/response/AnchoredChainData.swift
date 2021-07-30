//
//  AnchoredChainData.swift
//  CaverSwift
//
//  Created by won on 2021/07/30.
//

import Foundation

open class DecodeAnchoringTransaction: AnchoredChainData {
}

open class AnchoredChainData: Codable {
    public var txHash = ""
    public var txCount = 0
    public var stateRootHash = ""
    public var receiptHash = ""
    public var parentHash = ""
    public var blockNumber = 0
    public var blockHash = ""
    public var blockCount = 0
    
    private enum CodingKeys: String, CodingKey {
        case txHash, txCount, stateRootHash, receiptHash, parentHash, blockNumber, blockHash, blockCount
    }
    
    open func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(txHash, forKey: .txHash)
        try container.encode(txCount, forKey: .txCount)
        try container.encode(stateRootHash, forKey: .stateRootHash)
        try container.encode(receiptHash, forKey: .receiptHash)
        try container.encode(parentHash, forKey: .parentHash)
        try container.encode(blockNumber, forKey: .blockNumber)
        try container.encode(blockHash, forKey: .blockHash)
        try container.encode(blockCount, forKey: .blockCount)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.txHash = (try? container.decode(String.self, forKey: .txHash)) ?? ""
        self.txCount = (try? container.decode(Int.self, forKey: .txCount)) ?? 0
        self.stateRootHash = (try? container.decode(String.self, forKey: .stateRootHash)) ?? ""
        self.receiptHash = (try? container.decode(String.self, forKey: .receiptHash)) ?? ""
        self.parentHash = (try? container.decode(String.self, forKey: .parentHash)) ?? ""
        self.blockNumber = (try? container.decode(Int.self, forKey: .blockNumber)) ?? 0
        self.blockHash = (try? container.decode(String.self, forKey: .blockHash)) ?? ""
        self.blockCount = (try? container.decode(Int.self, forKey: .blockCount)) ?? 0
    }
}
