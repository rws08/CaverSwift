//
//  AccountKeyLegacy.swift
//  CaverSwift
//
//  Created by won on 2021/06/23.
//

import Foundation

open class AccountKeyLegacy: IAccountKey {
    private static let RLP = Data([0x01, 0xc0])
    private static let TYPE = "0x01"
    
    public static func decode(_ rlpEncodedKey: String) throws -> AccountKeyLegacy {
        return try decode(rlpEncodedKey.web3.hexData ?? Data())
    }
    
    public static func decode(_ rlpEncodedKey: Data) throws -> AccountKeyLegacy {
        if rlpEncodedKey != RLP {
            throw CaverError.RuntimeException("Invalid RLP-encoded account key String")
        }
        return AccountKeyLegacy()
    }
    
    public func getType() -> String {
        return AccountKeyLegacy.TYPE
    }
    
    public func getRLPEncoding() -> String {
        return AccountKeyLegacy.RLP.web3.hexString
    }
    
    
}
