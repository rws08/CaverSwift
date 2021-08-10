//
//  AccountKeyNil.swift
//  CaverSwift
//
//  Created by won on 2021/07/01.
//

import Foundation

open class AccountKeyNil: IAccountKey {
    private static let RLP: UInt8 = 0x80
    static let TYPE = "0x80"
    
    public static func decode(_ rlpEncodedKey: String) throws -> AccountKeyNil {
        return try decode(rlpEncodedKey.hexData ?? Data())
    }
    
    public static func decode(_ rlpEncodedKey: Data) throws -> AccountKeyNil {
        if rlpEncodedKey.count != 1 || rlpEncodedKey[0] != RLP {
            throw CaverError.RuntimeException("Invalid RLP-encoded AccountKeyNil")
        }
        return AccountKeyNil()
    }
    
    public override func getRLPEncoding() -> String {
        return Data([AccountKeyNil.RLP]).hexString
    }
    
    enum CodingKeys: String, CodingKey {
        case keyType
        case key
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)        
        try container.encode(0, forKey: .keyType)
        _ = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .key)
    }
}
