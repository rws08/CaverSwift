//
//  KlaySyncing.swift
//  CaverSwift
//
//  Created by won on 2021/07/30.
//

import Foundation

open class KlaySyncing: Codable, Equatable {
    public var isSyncing = true
    
    public var startingBlock = ""
    public var currentBlock = ""
    public var highestBlock = ""
    public var knownStates = ""
    public var pulledStates = ""
    
    private enum CodingKeys: String, CodingKey {
        case startingBlock, currentBlock, highestBlock, knownStates, pulledStates
    }
    
    open func encode(to encoder: Encoder) throws {
        if self.isSyncing {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(startingBlock, forKey: .startingBlock)
            try container.encode(currentBlock, forKey: .currentBlock)
            try container.encode(highestBlock, forKey: .highestBlock)
            try container.encode(knownStates, forKey: .knownStates)
            try container.encode(pulledStates, forKey: .pulledStates)
        } else {
            var container = encoder.singleValueContainer()
            try container.encode(isSyncing)
        }
    }
    
    public required init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer() {
            self.isSyncing = (try? container.decode(Bool.self)) ?? false
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.startingBlock = (try? container.decode(String.self, forKey: .startingBlock)) ?? ""
            self.currentBlock = (try? container.decode(String.self, forKey: .currentBlock)) ?? ""
            self.highestBlock = (try? container.decode(String.self, forKey: .highestBlock)) ?? ""
            self.knownStates = (try? container.decode(String.self, forKey: .knownStates)) ?? ""
            self.pulledStates = (try? container.decode(String.self, forKey: .pulledStates)) ?? ""
        }
    }
    
    init() {
    }
    
    public var hash: Int {
        var result = !startingBlock.isEmpty ? startingBlock.hash : 0
        result = 31 * result + isSyncing.hashValue
        result = 31 * result + (!currentBlock.isEmpty ? currentBlock.hash : 0)
        result = 31 * result + (!highestBlock.isEmpty ? highestBlock.hash : 0)
        result = 31 * result + (!knownStates.isEmpty ? knownStates.hash : 0)
        result = 31 * result + (!pulledStates.isEmpty ? pulledStates.hash : 0)
        return result
    }
    
    public static func == (lhs: KlaySyncing, rhs: KlaySyncing) -> Bool {
        return lhs.isSyncing == rhs.isSyncing &&
            lhs.startingBlock == rhs.startingBlock &&
            lhs.currentBlock == rhs.currentBlock &&
            lhs.highestBlock == rhs.highestBlock &&
            lhs.knownStates == rhs.knownStates &&
            lhs.pulledStates == rhs.pulledStates
    }
}

