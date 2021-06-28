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
            throw CaverError.IllegalAccessException("Invalid private key")
        }
        self.privateKey = privateKey.addHexPrefix
    }
    
    public static func generate() -> PrivateKey {
        return PrivateKey.generate("")
    }
    
    public static func generate(_ entropy: String) -> PrivateKey {
        let random = Utils.generateRandomBytes(32)
        var entropyArr: Data
        if entropy.isEmpty {
            entropyArr = Utils.generateRandomBytes(32)
        } else {
            entropyArr = entropy.hexData!
        }
        
        var innerHex = Data(random)
        innerHex.append(entropyArr)
        innerHex = innerHex.sha3
        var middleHex = Utils.generateRandomBytes(32)
        middleHex.append(innerHex)
        middleHex.append(Utils.generateRandomBytes(32))
        
        let outerHex = middleHex.sha3.hexString
        
        return try! PrivateKey(outerHex)
    }
    
    public func getPublicKey(_ compressed: Bool) -> String {
        guard let publicKey = try? Sign.publicKeyFromPrivate(privateKey.cleanHexPrefix.data(using: .utf8)!) else { return "" }
        
        
        
        return ""
    }
}
