//
//  AccountKeyDecoder.swift
//  CaverSwift
//
//  Created by won on 2021/07/01.
//

import Foundation

open class AccountKeyDecoder {
    public static func decode(_ rlpEncodedKey: String) throws -> IAccountKey {
        let hexPrefixEncoded = rlpEncodedKey.addHexPrefix
        if hexPrefixEncoded.starts(with: AccountKeyFail.TYPE) {
            return try AccountKeyFail.decode(hexPrefixEncoded)
        } else if hexPrefixEncoded.starts(with: AccountKeyLegacy.TYPE) {
            return try AccountKeyLegacy.decode(hexPrefixEncoded)
        } else if hexPrefixEncoded.starts(with: AccountKeyPublic.TYPE) {
            return try AccountKeyPublic.decode(hexPrefixEncoded)
        } else if hexPrefixEncoded.starts(with: AccountKeyWeightedMultiSig.TYPE) {
            return try AccountKeyWeightedMultiSig.decode(hexPrefixEncoded)
        } else if hexPrefixEncoded.starts(with: AccountKeyRoleBased.TYPE) {
            return try AccountKeyRoleBased.decode(hexPrefixEncoded)
        } else if hexPrefixEncoded.starts(with: AccountKeyNil.TYPE) {
            return try AccountKeyNil.decode(hexPrefixEncoded)
        } else {
            throw CaverError.RuntimeException("Invalid RLP-encoded account key string")
        }
    }
}

