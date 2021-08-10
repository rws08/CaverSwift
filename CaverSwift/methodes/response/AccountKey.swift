//
//  AccountKey.swift
//  CaverSwift
//
//  Created by won on 2021/07/29.
//

import Foundation

public class AccountKey: Decodable {
    public var type: String = ""
    public var accountKey: IAccountKey
    
    enum CodingKeys: String, CodingKey {
        case keyType
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = (try? container.decode(UInt8.self, forKey: .keyType)) ?? 0
        self.type = Data([type]).hexString
        switch self.type {
        case AccountKeyLegacy.TYPE:
            accountKey = try AccountKeyLegacy.init(from: decoder)
        case AccountKeyPublic.TYPE:
            accountKey = try AccountKeyPublic.init(from: decoder)
        case AccountKeyWeightedMultiSig.TYPE:
            accountKey = try AccountKeyWeightedMultiSig.init(from: decoder)
        case AccountKeyRoleBased.TYPE:
            accountKey = try AccountKeyRoleBased.init(from: decoder)
        case AccountKeyFail.TYPE:
            accountKey = try AccountKeyFail.init(from: decoder)
        default:
            accountKey = AccountKeyNil()
        }
    }
}
