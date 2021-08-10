//
//  AccountKeyPublicUtils.swift
//  CaverSwift
//
//  Created by won on 2021/08/06.
//

import Foundation
import secp256k1
import BigInt

public class AccountKeyPublicUtils {
    static let DOMAIN = Sign.DOMAIN
    
    public static func getECPoint(_ key: String) throws -> Point {
        var key = key
        if try isUncompressedPublicKey(key) {
            key = try compressPublicKey(key)
        }
        guard let bytes = key.bytesFromHex else { throw CaverError.invalidValue }
        return try DOMAIN.decodePoint(bytes)
    }
    
    public static func getECPoint(_ x: String, _ y: String) -> Point {
        return Point(BInt(x, radix: 16) ?? BInt.ZERO, BInt(y, radix: 16) ?? BInt.ZERO)
    }
    
    public static func validateXYPoint(_ compressedPubKey: String) -> Bool {
        guard let point = try? getECPoint(compressedPubKey) else { return false }
        return point.isValid
    }
    
    public static func validateXYPoint(_ x: String, _ y: String) -> Bool {
        let point = getECPoint(x, y)
        return point.isValid
    }
    
    public static func isValidPublicKey(_ publicKey: String) -> Bool {
        var noPrefixPubKey = publicKey.cleanHexPrefix
        if noPrefixPubKey.count == 130 && noPrefixPubKey.startsWith("04") {
            noPrefixPubKey = String(noPrefixPubKey.dropFirst(2))
        }
        
        if noPrefixPubKey.count != 66 && noPrefixPubKey.count != 128 {
            return false
        }
        
        // Compressed Format
        if noPrefixPubKey.count == 66 {
            if(!noPrefixPubKey.startsWith("02") && !noPrefixPubKey.startsWith("03")) {
                return false
            }
            return validateXYPoint(publicKey)
        } else { // Uncompressed Format
            let x = String(noPrefixPubKey[0..<64])
            let y = String(noPrefixPubKey[64..<noPrefixPubKey.count])
            
            return validateXYPoint(x, y)
        }
    }
    
    public static func decompressPublicKey(_ publicKey: String) throws -> String {
        if try isUncompressedPublicKey(publicKey) {
            return publicKey
        }
        
        guard let point = try? getECPoint(publicKey),
              let decompressPublicKey = try? DOMAIN.encodePoint(point) else { return "" }
        
        // remove tag(04)
        return String(bytes: Array(decompressPublicKey.dropFirst(1)))
    }
    
    public static func compressPublicKey(_ publicKey: String) throws -> String {
        if try isCompressedPublicKey(publicKey) {
            return publicKey
        }
        
        var noPrefixKey = publicKey.cleanHexPrefix
        if noPrefixKey.count == 130 && noPrefixKey.startsWith("04") {
            noPrefixKey = String(noPrefixKey.dropFirst(2))
        }
        
        guard let publicKeyBN = BInt(noPrefixKey, radix: 16) else { return "" }
        let publicKeyX = String(noPrefixKey[0..<64])
        let pubKeyYPrefix = publicKeyBN.testBit(0) ? "03" : "02"
        
        return pubKeyYPrefix + publicKeyX
    }
    
    private static func isVeryfyPublicKey(_ key: String) throws -> Bool {
        guard let bytes = key.bytesFromHex,
              let point = try? DOMAIN.decodePoint(bytes) else { throw CaverError.invalidValue }
        
        return DOMAIN.contains(point)
    }
    
    public static func isCompressedPublicKey(_ key: String) throws -> Bool {
        let noPrefixKey = key.cleanHexPrefix;
        
        if(noPrefixKey.count == 66 && (noPrefixKey.startsWith("02") || noPrefixKey.startsWith("03"))) {
            guard let isVeryfy = try? isVeryfyPublicKey(noPrefixKey) else {
                return false
            }
            if(!isVeryfy) {
                throw CaverError.RuntimeException("Invalid public key.")
            }
            return true;
        }
        return false;
    }
    
    public static func isUncompressedPublicKey(_ key: String) throws -> Bool {
        var noPrefixKey = key.cleanHexPrefix;
        
        if(noPrefixKey.count == 130 && noPrefixKey.startsWith("04")) {
            noPrefixKey = String(noPrefixKey[2..<noPrefixKey.count])
        }
        
        if(noPrefixKey.count == 128) {
            let x = String(noPrefixKey[0..<64])
            let y = String(noPrefixKey[64..<noPrefixKey.count])
            
            if(!validateXYPoint(x, y)) {
                throw CaverError.RuntimeException("Invalid public key.")
            }
            return true;
        }
        return false;
    }
}
