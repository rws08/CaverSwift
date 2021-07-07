//
//  AccountKeyLegacy.swift
//  CaverSwift
//
//  Created by won on 2021/06/23.
//

import Foundation

open class AccountKeyLegacy: IAccountKey {
    private static let RLP = Data([0x01, 0xc0])
    static let TYPE = "0x01"
    
    public static func decode(_ rlpEncodedKey: String) throws -> AccountKeyLegacy {
        guard let bytes = rlpEncodedKey.hexData else {
            throw CaverError.IllegalArgumentException("Invalid RLP-encoded key")
        }
        return try decode(bytes)
    }
    
    public static func decode(_ rlpEncodedKey: Data) throws -> AccountKeyLegacy {
        if rlpEncodedKey.bytes != RLP.bytes {
            throw CaverError.RuntimeException("Invalid RLP-encoded account key String")
        }
        
        return AccountKeyLegacy()
    }
    
    public func getRLPEncoding() -> String {
        return AccountKeyLegacy.RLP.hexString
    }
}
