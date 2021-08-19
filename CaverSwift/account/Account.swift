//
//  Account.swift
//  CaverSwift
//
//  Created by won on 2021/07/02.
//

import Foundation

open class Account {
    private(set) public var address: String
    private(set) public var accountKey: IAccountKey
    
    public init(_ address: String, _ accountKey: IAccountKey) {
        self.address = address.addHexPrefix
        self.accountKey = accountKey
    }
    
    public static func create(_ address: String, _ publicKey: String) -> Account {
        return createWithAccountKeyPublic(address, publicKey)
    }
    
    public static func create(_ address: String, _ publicKeys: [String]) throws -> Account {
        return try createWithAccountKeyWeightedMultiSig(address, publicKeys)
    }
    
    public static func create(_ address: String, _ publicKeys: [String], _ options: WeightedMultiSigOptions) throws -> Account {
        return try createWithAccountKeyWeightedMultiSig(address, publicKeys, options)
    }
    
    public static func create(_ address: String, _ publicKeyList: [[String]]) throws -> Account {
        return try createWithAccountKeyRoleBased(address, publicKeyList)
    }
    
    public static func create(_ address: String, _ publicKeyList: [[String]], _ optionsList: [WeightedMultiSigOptions]) throws -> Account {
        return try createWithAccountKeyRoleBased(address, publicKeyList, optionsList)
    }
    
    public static func createFromRLPEncoding(_ address: String, _ rlpEncodedKey: String) throws -> Account {
        let accountKey = try AccountKeyDecoder.decode(rlpEncodedKey)
        return Account(address, accountKey)
    }
    
    public static func createWithAccountKeyLegacy(_ address: String) -> Account {
        let accountKey = AccountKeyLegacy()
        return Account(address, accountKey)
    }
    
    public static func createWithAccountKeyFail(_ address: String) -> Account {
        let accountKey = AccountKeyFail()
        return Account(address, accountKey)
    }
    
    public static func createWithAccountKeyPublic(_ address: String, _ publicKey: String) -> Account {
        let accountKey = AccountKeyPublic.fromPublicKey(publicKey)
        return Account(address, accountKey)
    }
    
    public static func createWithAccountKeyWeightedMultiSig(_ address: String, _ publicKeys: [String]) throws -> Account {
        let options = WeightedMultiSigOptions.getDefaultOptionsForWeightedMultiSig(publicKeys)
        return try createWithAccountKeyWeightedMultiSig(address, publicKeys, options)
    }
    
    public static func createWithAccountKeyWeightedMultiSig(_ address: String, _ publicKeys: [String], _ options: WeightedMultiSigOptions) throws -> Account {
        let accountKey = try AccountKeyWeightedMultiSig.fromPublicKeysAndOptions(publicKeys, options)
        return Account(address, accountKey)
    }
    
    public static func createWithAccountKeyRoleBased(_ address: String, _ roleBasedPublicKey: [[String]]) throws -> Account {
        let optionList = WeightedMultiSigOptions.getDefaultOptionsForRoleBased(roleBasedPublicKey)
        return try createWithAccountKeyRoleBased(address, roleBasedPublicKey, optionList)
    }
    
    public static func createWithAccountKeyRoleBased(_ address: String, _ roleBasedPublicKey: [[String]], _ optionsList: [WeightedMultiSigOptions]) throws -> Account {
        let accountKey = try AccountKeyRoleBased.fromRoleBasedPublicKeysAndOptions(roleBasedPublicKey, optionsList)
        return Account(address, accountKey)
    }
    
    public func getRLPEncodingAccountKey() throws -> String {
        return try accountKey.getRLPEncoding()
    }
}
