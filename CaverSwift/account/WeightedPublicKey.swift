//
//  WeightedPublicKey.swift
//  CaverSwift
//
//  Created by won on 2021/06/30.
//

import Foundation

open class WeightedPublicKey: Codable {
    private(set) public var publicKey = ""
    
    var weight: BigInt?
    
    init(_ publicKey: String, _ weight: BigInt?) throws {
        try setPublicKey(publicKey)
        self.weight = weight
    }
    
    public func setPublicKey(_ publicKey: String) throws {
        if !AccountKeyPublicUtils.isValidPublicKey(publicKey) {
            throw CaverError.IllegalArgumentException("Invalid Public key format")
        }
        
        self.publicKey = publicKey
    }
    
    public func encodeToBytes() throws -> [String] {
        if publicKey.isEmpty {
            throw CaverError.RuntimeException("public key should be specified for a multisig account")
        }
        
        guard let weight = weight else {
            throw CaverError.RuntimeException("weight should be specified for a multisig account")
        }
        
        guard let compressedKey = try? AccountKeyPublicUtils.compressPublicKey(publicKey) else { return [] }
        return [weight.hexa, compressedKey]
    }
    
    enum CodingKeys: String, CodingKey {
        case weight
        case key
        case x
        case y
    }
    
    public func encode(to encoder: Encoder) throws {
        let decompressedKey = try AccountKeyPublicUtils.decompressPublicKey(publicKey).cleanHexPrefix
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Int(weight!.decimal), forKey: .weight)
        
        var sub = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .key)
        try sub.encode(String(decompressedKey[0..<64]).addHexPrefix, forKey: .x)
        try sub.encode(String(decompressedKey[64..<decompressedKey.count]).addHexPrefix, forKey: .y)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        weight = BigInt((try? container.decode(Int.self, forKey: .weight)) ?? 0)
        
        let sub = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .key)
        let x = (try? sub.decode(String.self, forKey: .x)) ?? ""
        let y = (try? sub.decode(String.self, forKey: .y)) ?? ""
        
        self.publicKey = x.hexData!.hexString + y.hexData!.hexString.cleanHexPrefix
    }
}
