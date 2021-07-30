//
//  BlockWithConsensusInfo.swift
//  CaverSwift
//
//  Created by won on 2021/07/30.
//

import Foundation

open class BlockWithConsensusInfo: Codable {
    internal init(blockScore: String = "", totalBlockScore: String = "", committee: [String] = [], gasLimit: String = "", gasUsed: String = "", hash: String = "", miner: String = "", nonce: String = "", number: String = "", parentHash: String = "", proposer: String = "", receiptsRoot: String = "", size: String = "", stateRoot: String = "", timestamp: String = "", timestampFoS: String = "", transactions: [TransactionData] = [], transactionsRoot: String = "") {
        self.blockScore = blockScore
        self.totalBlockScore = totalBlockScore
        self.committee = committee
        self.gasLimit = gasLimit
        self.gasUsed = gasUsed
        self.hash = hash
        self.miner = miner
        self.nonce = nonce
        self.number = number
        self.parentHash = parentHash
        self.proposer = proposer
        self.receiptsRoot = receiptsRoot
        self.size = size
        self.stateRoot = stateRoot
        self.timestamp = timestamp
        self.timestampFoS = timestampFoS
        self.transactions = transactions
        self.transactionsRoot = transactionsRoot
    }
    
    private enum CodingKeys: String, CodingKey {
        case blockScore, totalBlockScore, committee, gasLimit, gasUsed, hash, miner, nonce, number, parentHash, proposer, receiptsRoot, size, stateRoot, timestamp, timestampFoS, transactions, transactionsRoot
    }
    
    open func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(blockScore, forKey: .blockScore)
        try container.encode(totalBlockScore, forKey: .totalBlockScore)
        try container.encode(committee, forKey: .committee)
        try container.encode(gasLimit, forKey: .gasLimit)
        try container.encode(gasUsed, forKey: .gasUsed)
        try container.encode(hash, forKey: .hash)
        try container.encode(miner, forKey: .miner)
        try container.encode(nonce, forKey: .nonce)
        try container.encode(number, forKey: .number)
        try container.encode(parentHash, forKey: .parentHash)
        try container.encode(proposer, forKey: .proposer)
        try container.encode(receiptsRoot, forKey: .receiptsRoot)
        try container.encode(size, forKey: .size)
        try container.encode(stateRoot, forKey: .stateRoot)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(timestampFoS, forKey: .timestampFoS)
        try container.encode(transactions, forKey: .transactions)
        try container.encode(transactionsRoot, forKey: .transactionsRoot)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.blockScore = (try? container.decode(String.self, forKey: .blockScore)) ?? ""
        self.totalBlockScore = (try? container.decode(String.self, forKey: .totalBlockScore)) ?? ""
        self.committee = (try? container.decode([String].self, forKey: .committee)) ?? []
        self.gasLimit = (try? container.decode(String.self, forKey: .gasLimit)) ?? ""
        self.gasUsed = (try? container.decode(String.self, forKey: .gasUsed)) ?? ""
        self.hash = (try? container.decode(String.self, forKey: .hash)) ?? ""
        self.miner = (try? container.decode(String.self, forKey: .miner)) ?? ""
        self.nonce = (try? container.decode(String.self, forKey: .nonce)) ?? ""
        self.number = (try? container.decode(String.self, forKey: .number)) ?? ""
        self.parentHash = (try? container.decode(String.self, forKey: .parentHash)) ?? ""
        self.proposer = (try? container.decode(String.self, forKey: .proposer)) ?? ""
        self.receiptsRoot = (try? container.decode(String.self, forKey: .receiptsRoot)) ?? ""
        self.size = (try? container.decode(String.self, forKey: .size)) ?? ""
        self.stateRoot = (try? container.decode(String.self, forKey: .stateRoot)) ?? ""
        self.timestamp = (try? container.decode(String.self, forKey: .timestamp)) ?? ""
        self.timestampFoS = (try? container.decode(String.self, forKey: .timestampFoS)) ?? ""
        self.transactions = (try? container.decode([TransactionData].self, forKey: .transactions)) ?? []
        self.transactionsRoot = (try? container.decode(String.self, forKey: .transactionsRoot)) ?? ""
    }
    
    /**
     * Former difficulty. Always 1 in the BFT consensus engine
     */
    var blockScore = ""

    /**
     * Integer of the total blockScore of the chain until this block.
     */
    var totalBlockScore = ""

    /**
     * Array of addresses of committee members of this block. The committee is a subset of
     * validators participated in the consensus protocol for this block
     */
    var committee: [String] = []

    /**
     * The maximum gas allowed in this block
     */
    var gasLimit = ""

    /**
     * The total used gas by all transactions in this block
     */
    var gasUsed = ""

    /**
     * Hash of the block. null when its pending block
     */
    var hash = ""

    /**
     * The address of the beneficiary to whom the mining rewards were given
     */
    var miner = ""

    /**
     * The number of transactions made by the sender prior to this one.
     */
    var nonce = ""

    /**
     * The block number. null when its pending block
     */
    var number = ""

    /**
     * Hash of the parent block
     */
    var parentHash = ""

    /**
     * The address of the block proposer
     */
    var proposer = ""

    /**
     * The root of the receipts trie of the block
     */
    var receiptsRoot = ""

    /**
     * Integer the size of this block in bytes
     */
    var size = ""

    /**
     * The root of the final state trie of the block
     */
    var stateRoot = ""

    /**
     * The Unix timestamp for when the block was collated
     */
    var timestamp = ""

    /**
     * The fraction of a second of the timestamp for when the block was collated
     */
    var timestampFoS = ""

    /**
     * Array of transaction objects
     */
    var transactions: [TransactionData] = []

    /**
     * The root of the transaction trie of the block
     */
    var transactionsRoot = ""
}

