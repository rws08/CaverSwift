//
//  AccountKeyPublic.swift
//  CaverSwift
//
//  Created by won on 2021/06/23.
//

import Foundation

open class AccountKeyPublic: IAccountKey {
    private static let RLP: UInt8 = 0x02
    static let TYPE = "0x02"
    
    private(set) public var publicKey = ""
    
    public static let OFFSET_X_POINT = 0
    public static let OFFSET_Y_POINT = 1
    
    init(_ publicKey: String) {
        super.init()
        try? self.setPublicKey(publicKey)
    }
    
    public func setPublicKey(_ publicKey: String) throws {
        if !Utils.isValidPublicKey(publicKey) {
            throw CaverError.RuntimeException("Invalid Public Key format")
        }
        self.publicKey = publicKey
    }
    
    public override func getRLPEncoding() throws -> String {
        let compressedKey = try Utils.compressPublicKey(publicKey)
        guard let encodedPubKey = Rlp.encode(compressedKey) else { return "" }        
        var type = Data([AccountKeyPublic.RLP])
        type.append(encodedPubKey)
        return type.hexString
    }
    
    public func getXYPoint() -> [String] {
        var key = publicKey
        do {
            if try Utils.isCompressedPublicKey(publicKey) {
                key = try Utils.decompressPublicKey(publicKey)
            }
            
            let noPrefixKeyStr = key.cleanHexPrefix
            return [String(noPrefixKeyStr[0..<64]), String(noPrefixKeyStr[64..<noPrefixKeyStr.count])]
        } catch {
            print(error.localizedDescription)
        }
        
        return []
    }
    
    public static func fromXYPoint(_ x: String, _ y: String) throws -> AccountKeyPublic {
        guard let xPoint = x.hexData?.hexString,
              let yPoint = y.hexData?.hexString
        else { throw CaverError.invalidValue }
        
        return AccountKeyPublic(xPoint + yPoint.cleanHexPrefix)
    }
    
    public static func fromPublicKey(_ publicKey: String) -> AccountKeyPublic {
        return AccountKeyPublic(publicKey)
    }
    
    public static func decode(_ rlpEncodedKey: String) throws -> AccountKeyPublic {
        guard let bytes = rlpEncodedKey.bytesFromHex else {
            throw CaverError.invalidValue
        }
        
        return try decode(bytes)
    }
    
    public static func decode(_ rlpEncodedKey: [UInt8]) throws -> AccountKeyPublic {
        if rlpEncodedKey[0] != RLP {
            throw CaverError.IllegalArgumentException("Invalid RLP-encoded AccountKeyPublic Tag")
        }
        
        //remove Tag
        let encodedPublicKey = rlpEncodedKey[1..<rlpEncodedKey.count]
        guard let compressedPubKey = Rlp.decode(Array(encodedPublicKey)) as? String,
              let publicKey = try? Utils.decompressPublicKey(compressedPubKey)
        else { throw CaverError.RuntimeException("There is an error while decoding process.")}
        
        
        return AccountKeyPublic(publicKey)
    }
}
