//
//  KlayLogs.swift
//  CaverSwift
//
//  Created by won on 2021/07/20.
//

import Foundation

public class KlayLogs: Codable {
    public var value: [KlayLogs.LogResult] = []
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let array = try? container.decode([KlayLogs.Log].self) {
            value = array
        } else if let val = try? container.decode(Hash.self) {
            value.append(val)
        }
    }
    
    public func getLogs() -> [KlayLogs.LogResult] {
        return value
    }
    
    public class LogResult: Codable {}
    
    public class LogObject: Log {}
    
    public class Hash: LogResult, Equatable {
        public var value: String?
        
        public static func == (lhs: KlayLogs.Hash, rhs: KlayLogs.Hash) -> Bool {
            return lhs.value != nil ? lhs.value == rhs.value : rhs.value == nil
        }
    }
    
    public class Log: LogResult, Equatable {
        var logIndex: String?
        var transactionIndex: String?
        var transactionHash: String?
        var blockHash: String?
        var blockNumber: String?
        var address: String?
        var data: String?
        var topics: [String]?
        
        internal init(logIndex: String? = nil, transactionIndex: String? = nil, transactionHash: String? = nil, blockHash: String? = nil, blockNumber: String? = nil, address: String? = nil, data: String? = nil, topics: [String]? = nil) {
            super.init()
            self.logIndex = logIndex
            self.transactionIndex = transactionIndex
            self.transactionHash = transactionHash
            self.blockHash = blockHash
            self.blockNumber = blockNumber
            self.address = address
            self.data = data
            self.topics = topics
        }
                
        enum CodingKeys: String, CodingKey {
            case logIndex
            case transactionIndex
            case transactionHash
            case blockHash
            case blockNumber
            case address
            case data
            case topics
        }
        
        required init(from decoder: Decoder) throws {
            super.init()
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.logIndex = try? container.decode(String.self, forKey: .logIndex)
            self.transactionIndex = try? container.decode(String.self, forKey: .transactionIndex)
            self.transactionHash = try? container.decode(String.self, forKey: .transactionHash)
            self.blockHash = try? container.decode(String.self, forKey: .blockHash)
            self.blockNumber = try? container.decode(String.self, forKey: .blockNumber)
            self.address = try? container.decode(String.self, forKey: .address)
            self.data = try? container.decode(String.self, forKey: .data)
            self.topics = try? container.decode([String].self, forKey: .topics)
        }
        
        private func convert(_ value: String?) -> BigInt? {
            guard let value = value else { return nil }
            if value.isHexa {
                return BigInt(value.cleanHexPrefix, radix: 16)
            }
            return BigInt(value)
        }
        
        public static func == (lhs: KlayLogs.Log, rhs: KlayLogs.Log) -> Bool {
            if lhs.logIndex != nil ? lhs.logIndex != rhs.logIndex : rhs.logIndex != nil {
                return false
            }
            if lhs.transactionIndex != nil ? lhs.transactionIndex != rhs.transactionIndex : rhs.transactionIndex != nil {
                return false
            }
            if lhs.transactionHash != nil ? lhs.transactionHash != rhs.transactionHash : rhs.transactionHash != nil {
                return false
            }
            if lhs.blockHash != nil ? lhs.blockHash != rhs.blockHash : rhs.blockHash != nil {
                return false
            }
            if lhs.blockNumber != nil ? lhs.blockNumber != rhs.blockNumber : rhs.blockNumber != nil {
                return false
            }
            if lhs.address != nil ? lhs.address != rhs.address : rhs.address != nil {
                return false
            }
            if lhs.data != nil ? lhs.data != rhs.data : rhs.data != nil {
                return false
            }
            return lhs.topics != nil ? lhs.topics != rhs.topics : rhs.topics != nil
        }
    }
}
