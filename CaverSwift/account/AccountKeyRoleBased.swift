//
//  AccountKeyRoleBased.swift
//  CaverSwift
//
//  Created by won on 2021/06/25.
//

import Foundation

open class AccountKeyRoleBased: IAccountKey {
    private static let RLP: UInt8 = 0x05
    static let TYPE = "0x05"
    
    public enum RoleGroup: Int, CaseIterable {
        case TRANSACTION = 0
        case ACCOUNT_UPDATE = 1
        case FEE_PAYER = 2
    }
    
    public static let ROLE_GROUP_COUNT = RoleGroup.allCases.count
    
    private(set) public var accountKeys: [IAccountKey] = []
    
    public init(_ accountKeys: [IAccountKey]) throws {
        super.init()
        try setAccountKeys(accountKeys)
    }
    
    public static func decode(_ rlpEncodedKey: String) throws -> AccountKeyRoleBased {
        guard let hex = rlpEncodedKey.bytesFromHex else {
            throw CaverError.invalidValue
        }
        return try decode(hex)
    }
    
    public static func decode(_ rlpEncodedKey: [UInt8]) throws -> AccountKeyRoleBased {
        //check tag
        if rlpEncodedKey[0] != RLP {
            throw CaverError.IllegalArgumentException("Invalid RLP-encoded AccountKeyRoleBased Tag")
        }
        
        //remove Tag
        let rlpList = Rlp.decode(Array(rlpEncodedKey[1..<rlpEncodedKey.count]))
        guard let values = rlpList as? [String] else {
            throw CaverError.RuntimeException("There is an error while decoding process.")
        }
                
        //get accountKeys
        let accountKeys: [IAccountKey] = try values.map {
            try AccountKeyDecoder.decode($0)
        }
        
        return try AccountKeyRoleBased(accountKeys)
    }
    
    public static func fromRoleBasedPublicKeysAndOptions(_ pubArray: [[String]], _ options: [WeightedMultiSigOptions]) throws -> AccountKeyRoleBased {
        
        if pubArray.count > ROLE_GROUP_COUNT {
            throw CaverError.IllegalArgumentException("pubArray must have up to three items")
        }
        
        if options.count != pubArray.count {
            throw CaverError.IllegalArgumentException("pubArray and options must have the same number of items.")
        }
        
        let accountKeys: [IAccountKey] = try zip(pubArray, options).map {
            let publicKeyArr = $0
            let weightedMultiSigOption = $1
                        
            if publicKeyArr.count == 0 { //Set AccountKeyNil
                if !weightedMultiSigOption.isEmpty {
                    throw CaverError.RuntimeException("Invalid options: AccountKeyNil cannot have options.")
                }
                return AccountKeyNil()
            } else if (publicKeyArr.count == 1 && weightedMultiSigOption.isEmpty ) { //Set AccountKeyPublic
                switch publicKeyArr[0] {
                case "legacy": return AccountKeyLegacy()
                case "fail": return AccountKeyFail()
                default: return AccountKeyPublic.fromPublicKey(publicKeyArr[0])
                }
            }
            
            if (weightedMultiSigOption.isEmpty) {
                throw CaverError.RuntimeException("Invalid options : AccountKeyWeightedMultiSig must have options")
            }
            
            return try AccountKeyWeightedMultiSig.fromPublicKeysAndOptions(publicKeyArr, weightedMultiSigOption)
        }
        
        return try AccountKeyRoleBased(accountKeys)
    }
    
    public func setAccountKeys(_ accountKeys: [IAccountKey]) throws {
        if accountKeys.count > AccountKeyRoleBased.ROLE_GROUP_COUNT {
            throw CaverError.RuntimeException("It exceeds maximum role based key count.")
        }
        self.accountKeys = accountKeys
    }
    
    public override func getRLPEncoding() throws -> String {
        let rlpTypeList = try accountKeys.map {
            try $0.getRLPEncoding()
        }
        
        guard let encodedRoleBasedKey = Rlp.encode(rlpTypeList) else {
            return ""
        }
        var type = Data([AccountKeyRoleBased.RLP])
        type.append(encodedRoleBasedKey)
        return type.hexString
    }
    
    public var roleTransactionKey: IAccountKey {
        accountKeys[RoleGroup.TRANSACTION.rawValue]
    }
    
    public var roleAccountUpdateKey: IAccountKey {
        accountKeys[RoleGroup.ACCOUNT_UPDATE.rawValue]
    }
    
    public var roleFeePayerKey: IAccountKey {
        accountKeys[RoleGroup.FEE_PAYER.rawValue]
    }
    
    enum CodingKeys: String, CodingKey {
        case keyType
        case key
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(Int(hex: AccountKeyRoleBased.TYPE), forKey: .keyType)
        try container.encode(accountKeys, forKey: .key)
    }
    
    public required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let keyType = (try? container.decode(UInt8.self, forKey: .keyType)) ?? 0
        let type = Data([keyType]).hexString
        if type != AccountKeyRoleBased.TYPE {
            throw CaverError.decodeIssue
        }
        var sub = try container.nestedUnkeyedContainer(forKey: .key)
        
        while !sub.isAtEnd {
            var accountKey: IAccountKey
            
            if let decode = try? sub.decode(AccountKeyPublic.self) {
                accountKey = decode
            } else if let decode = try? sub.decode(AccountKeyWeightedMultiSig.self) {
                accountKey = decode
            } else if let decode = try? sub.decode(AccountKeyRoleBased.self) {
                accountKey = decode
            } else {
                let subContainer = try sub.nestedContainer(keyedBy: CodingKeys.self)
                let keyType = (try? subContainer.decode(UInt8.self, forKey: .keyType)) ?? 0
                let type = Data([keyType]).hexString
                switch type {
                case AccountKeyLegacy.TYPE:
                    accountKey = AccountKeyLegacy()
                case AccountKeyFail.TYPE:
                    accountKey = AccountKeyFail()
                default:
                    accountKey = AccountKeyNil()
                }
            }
                        
            self.accountKeys.append(accountKey)
        }
    }
}
