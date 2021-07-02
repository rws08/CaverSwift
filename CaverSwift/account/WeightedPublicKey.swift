//
//  WeightedPublicKey.swift
//  CaverSwift
//
//  Created by won on 2021/06/30.
//

import Foundation

open class WeightedPublicKey {
    private(set) public var publicKey = ""
    
    var weight: BigInt?
    
    init(_ publicKey: String, _ weight: BigInt?) throws {
        try setPublicKey(publicKey)
        self.weight = weight
    }
    
    public func setPublicKey(_ publicKey: String) throws {
        if !Utils.isValidPublicKey(publicKey) {
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
        
        guard let compressedKey = try? Utils.compressPublicKey(publicKey) else { return [] }
        return [weight.hexa, compressedKey]
    }
}
