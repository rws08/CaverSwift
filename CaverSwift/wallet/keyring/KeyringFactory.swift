//
//  KeyringFactory.swift
//  CaverSwift
//
//  Created by won on 2021/06/25.
//

import Foundation

open class KeyringFactory {
    public static func generate() -> SingleKeyring? {
        return KeyringFactory.generate("")
    }
    
    public static func generate(_ entropy: String) -> SingleKeyring? {
        let privateKey = PrivateKey.generate(entropy)
        let address = privateKey.getDerivedAddress()
        
        return try? createWithSingleKey(address, privateKey.privateKey)
    }
    
    public static func create(_ address: String, _ key: String) throws -> SingleKeyring {
        return try createWithSingleKey(address, key)
    }
    
    public static func create(_ address: String, _ keys: [String]) throws -> MultipleKeyring {
        return try createWithMultipleKey(address, keys)
    }
    
    public static func create(_ address: String, _ keys: [[String]]) throws -> RoleBasedKeyring {
        return try createWithRoleBasedKey(address, keys)
    }
    
    public static func createWithSingleKey(_ address: String, _ key: String) throws -> SingleKeyring {
        if(Utils.isKlaytnWalletKey(key)) {
            throw CaverError.IllegalArgumentException("Invalid format of parameter. Use 'fromKlaytnWalletKey' to create Keyring from KlaytnWalletKey.")
        }

        let privateKey = try PrivateKey(key)
        return SingleKeyring(address, privateKey)
    }
    
    public static func createWithMultipleKey(_ address: String, _ multipleKey: [String]) throws -> MultipleKeyring {
        if(multipleKey.count > WeightedMultiSigOptions.MAX_COUNT_WEIGHTED_PUBLIC_KEY) {
            throw CaverError.IllegalArgumentException("MultipleKey has up to 10.")
        }

        let keyArr = try multipleKey.map {
            try PrivateKey($0)
        }
        return MultipleKeyring(address, keyArr)
    }
    
    public static func createWithRoleBasedKey(_ address: String, _ roleBasedKey: [[String]]) throws -> RoleBasedKeyring {
        if(roleBasedKey.count > AccountKeyRoleBased.ROLE_GROUP_COUNT) {
            throw CaverError.IllegalArgumentException("RoleBasedKey component must have 3.")
        }
        
        let isExceedKeyCount = roleBasedKey.first {
            $0.count > WeightedMultiSigOptions.MAX_COUNT_WEIGHTED_PUBLIC_KEY
        }
        
        if isExceedKeyCount?.isEmpty == false {
            throw CaverError.IllegalArgumentException("The keys in RoleBasedKey component has up to 10.")
        }
        
        let privateKeys = try roleBasedKey.map {
            try $0.map {
                try PrivateKey($0)
            }
        }
        return RoleBasedKeyring(address, privateKeys)
    }
    
    public static func createFromPrivateKey(_ key: String) throws -> SingleKeyring {
        if Utils.isKlaytnWalletKey(key) {
            return try KeyringFactory.createFromKlaytnWalletKey(key)
        }        
        
        let privateKey = try PrivateKey(key)
        let address = privateKey.getDerivedAddress()
        
        return try createWithSingleKey(address, privateKey.privateKey)
    }
    
    public static func createFromKlaytnWalletKey(_ key: String) throws -> SingleKeyring {
        let parsedKey = try Utils.parseKlaytnWalletKey(key)
        
        let privateKey = parsedKey[0]
        let address = parsedKey[2]
        
        return try createWithSingleKey(address, privateKey)
    }
}
