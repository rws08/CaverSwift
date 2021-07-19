//
//  PrivateKey.swift
//  CaverSwift
//
//  Created by won on 2021/06/23.
//

import Foundation

open class PrivateKey {
    static let LEN_UNCOMPRESSED_PUBLIC_KEY_STRING = 128
    
    private(set) public var privateKey = ""
    
    public init(_ privateKey: String) throws {
        if !Utils.isValidPrivateKey(privateKey) {
            throw CaverError.IllegalArgumentException("Invalid private key.")
        }
        self.privateKey = privateKey.addHexPrefix
    }
    
    public static func generate(_ entropy: String? = "") -> PrivateKey {
        var entropy: String! = entropy
        if entropy == nil { entropy = "" }
        let random = Utils.generateRandomBytes(32)
        var entropyArr: Data
        if entropy.isEmpty {
            entropyArr = Utils.generateRandomBytes(32)
        } else {
            entropyArr = entropy.data(using: .utf8)!
        }
        
        var innerHex = Data(random)
        innerHex.append(entropyArr)
        innerHex = innerHex.keccak256
        var middleHex = Utils.generateRandomBytes(32)
        middleHex.append(innerHex)
        middleHex.append(Utils.generateRandomBytes(32))
        
        let outerHex = middleHex.keccak256.hexString
        
        return try! PrivateKey(outerHex)
    }
    
    public func sign(_ signHash: String, _ chainId: Int) throws -> SignatureData {
        let signatureData = try Sign.signMessage(signHash.bytesFromHex!, privateKey, false)
        try signatureData.makeEIP155Signature(chainId)
        return signatureData
    }
    
    public func signMessage(_ messageHash: String) throws -> SignatureData {
        let signatureData = try Sign.signMessage(messageHash.bytesFromHex!, privateKey, false)
        return signatureData
    }
    
    public func getPublicKey(_ compressed: Bool = false) throws -> String {
        let publicKey = Sign.publicKeyFromPrivate(privateKey)
        if compressed {
            return try Utils.compressPublicKey(publicKey)
        }
        
        return publicKey
    }
    
    public func getDerivedAddress() -> String {
        let publicKey = Sign.publicKeyFromPrivate(privateKey)
        return Utils.getAddress(publicKey).addHexPrefix
    }
}
