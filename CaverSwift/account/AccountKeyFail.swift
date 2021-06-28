//
//  AccountKeyFail.swift
//  CaverSwift
//
//  Created by won on 2021/06/23.
//

import Foundation

open class AccountKeyFail: IAccountKey {
    private static let RLP = Data([0x03, 0xc0])
    private static let TYPE = "0x03"
    
    public static func decode(_ rlpEncodedKey: String) throws -> AccountKeyFail {
        return try decode(rlpEncodedKey.hexData ?? Data())
    }
    
    public static func decode(_ rlpEncodedKey: Data) throws -> AccountKeyFail {
        if rlpEncodedKey != RLP {
            throw CaverError.RuntimeException("Invalid RLP-encoded account key String")
        }
        return AccountKeyFail()
    }
    
    public func getType() -> String {
        return AccountKeyFail.TYPE
    }
    
    public func getRLPEncoding() -> String {
        return AccountKeyFail.RLP.hexString
    }
    
    
}
