//
//  BlockData.swift
//  CaverSwift
//
//  Created by won on 2021/07/30.
//

import Foundation

open class BlockData: Codable {
    public init() {
    }
    
    internal init(_ number: String, _ hash: String, _ parentHash: String, _ logsBloom: String, _ transactionsRoot: String, _ stateRoot: String, _ receiptsRoot: String, _ reward: String, _ blockScore: String, _ totalBlockScore: String, _ extraData: String, _ size: String, _ gasUsed: String, _ timestamp: String, _ timestampFoS: String, _ governanceData: String, _ voteData: String) {
        self.number = number
        self.hash = hash
        self.parentHash = parentHash
        self.logsBloom = logsBloom
        self.transactionsRoot = transactionsRoot
        self.stateRoot = stateRoot
        self.receiptsRoot = receiptsRoot
        self.reward = reward
        self.blockScore = blockScore
        self.totalBlockScore = totalBlockScore
        self.extraData = extraData
        self.size = size
        self.gasUsed = gasUsed
        self.timestamp = timestamp
        self.timestampFoS = timestampFoS
        self.governanceData = governanceData
        self.voteData = voteData
    }
    
    /**
     * The block number. null when its pending block
     */
    var number = ""

    /**
     * Hash of the block. null when its pending block
     */
    var hash = ""

    /**
     * Hash of the parent block
     */
    var parentHash = ""

    /**
     * The bloom filter for the logs of the block. null when its pending block
     */
    var logsBloom = ""

    /**
     * The root of the transaction trie of the block
     */
    var transactionsRoot = ""

    /**
     * The root of the final state trie of the block
     */
    var stateRoot = ""

    /**
     * The root of the receipts trie of the block
     */
    var receiptsRoot = ""

    /**
     * The address of the beneficiary to whom the block rewards were given.
     */
    var reward = ""

    /**
     * Former difficulty. Always 1 in the BFT consensus engine
     */
    var blockScore = ""

    /**
     * Integer of the total blockScore of the chain until this block.
     */
    var totalBlockScore = ""

    /**
     * The "extra data" field of this block
     */
    var extraData = ""

    /**
     * Integer the size of this block in bytes
     */
    var size = ""

    /**
     * The total used gas by all transactions in this block
     */
    var gasUsed = ""

    /**
     * The Unix timestamp for when the block was collated
     */
    var timestamp = ""

    /**
     * The fraction of a second of the timestamp for when the block was collated
     */
    var timestampFoS = ""

    /**
     * Array of transaction objects, or 32-byte transaction hashes depending on the last given parameter
     */
    var transactions: [Any] = []

    /**
     * RLP encoded governance configuration
     */
    var governanceData = ""

    /**
     * RLP encoded governance vote of the proposer
     */
    var voteData = ""
    
    enum CodingKeys: String, CodingKey {
        case number, hash, parentHash, logsBloom, transactionsRoot, stateRoot, receiptsRoot, reward, blockScore, totalBlockScore, extraData, size, gasUsed, timestamp, timestampFoS, transactions, governanceData, voteData
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.number = (try? container.decode(String.self, forKey: .number)) ?? ""
        self.hash = (try? container.decode(String.self, forKey: .hash)) ?? ""
        self.parentHash = (try? container.decode(String.self, forKey: .parentHash)) ?? ""
        self.logsBloom = (try? container.decode(String.self, forKey: .logsBloom)) ?? ""
        self.transactionsRoot = (try? container.decode(String.self, forKey: .transactionsRoot)) ?? ""
        self.stateRoot = (try? container.decode(String.self, forKey: .stateRoot)) ?? ""
        self.receiptsRoot = (try? container.decode(String.self, forKey: .receiptsRoot)) ?? ""
        self.reward = (try? container.decode(String.self, forKey: .reward)) ?? ""
        self.blockScore = (try? container.decode(String.self, forKey: .blockScore)) ?? ""
        self.totalBlockScore = (try? container.decode(String.self, forKey: .totalBlockScore)) ?? ""
        self.extraData = (try? container.decode(String.self, forKey: .extraData)) ?? ""
        self.size = (try? container.decode(String.self, forKey: .size)) ?? ""
        self.gasUsed = (try? container.decode(String.self, forKey: .gasUsed)) ?? ""
        self.timestamp = (try? container.decode(String.self, forKey: .timestamp)) ?? ""
        self.timestampFoS = (try? container.decode(String.self, forKey: .timestampFoS)) ?? ""
        self.governanceData = (try? container.decode(String.self, forKey: .governanceData)) ?? ""
        self.voteData = (try? container.decode(String.self, forKey: .voteData)) ?? ""
        
        if let decode = try? container.decode([String].self, forKey: .transactions) {
            self.transactions = decode
        } else if let decode = try? container.decode([Transaction].self, forKey: .transactions) {
            self.transactions = decode
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.number, forKey: .number)
        try container.encode(self.hash, forKey: .hash)
        try container.encode(self.parentHash, forKey: .parentHash)
        try container.encode(self.logsBloom, forKey: .logsBloom)
        try container.encode(self.transactionsRoot, forKey: .transactionsRoot)
        try container.encode(self.stateRoot, forKey: .stateRoot)
        try container.encode(self.receiptsRoot, forKey: .receiptsRoot)
        try container.encode(self.reward, forKey: .reward)
        try container.encode(self.blockScore, forKey: .blockScore)
        try container.encode(self.totalBlockScore, forKey: .totalBlockScore)
        try container.encode(self.extraData, forKey: .extraData)
        try container.encode(self.size, forKey: .size)
        try container.encode(self.gasUsed, forKey: .gasUsed)
        try container.encode(self.timestamp, forKey: .timestamp)
        try container.encode(self.timestampFoS, forKey: .timestampFoS)
        try container.encode(self.governanceData, forKey: .governanceData)
        try container.encode(self.voteData, forKey: .voteData)
    }
}

