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
    
    public static func decrypt(_ keystore: String, _ password: String) throws -> AbstractKeyring {
        let decoder = JSONDecoder()
        let data = try decoder.decode(KeyStore.self, from: keystore.data(using: .utf8)!)
        
        return try decrypt(data, password)
    }
    
    public static func decrypt(_ keystore: KeyStore, _ password: String) throws -> AbstractKeyring {
        if keystore.crypto != nil && keystore.keyring != nil {
            throw CaverError.IllegalArgumentException("Invalid key store format: 'crypto' and 'keyring' cannot be defined together.")
        }
        
        guard let address = keystore.address else {
            throw CaverError.IllegalArgumentException("Must have address")
        }
        
        if keystore.version == KeyStore.KEY_STORE_VERSION_V3 {
            guard let crypto = keystore.crypto else {
                throw CaverError.IllegalArgumentException("Invalid keystore V3 format: 'crypto' is not defined.")
            }
            let privateKey = try KeyStore.Crypto.decryptCrypto(crypto, password)
            return try KeyringFactory.create(address, privateKey)
        } else if keystore.version == KeyStore.KEY_STORE_VERSION_V4 {
            guard let keyring = keystore.keyring else {
                throw CaverError.IllegalArgumentException("Invalid keystore V4 format: 'keyring' is not defined.")
            }
            
            var privateKeyList: [[String]] = []
            if keyring[0] is KeyStore.Crypto {
                let privateKeyArr: [String] = try keyring.map {
                    guard let crypto = $0 as? KeyStore.Crypto else { return "" }
                    return try KeyStore.Crypto.decryptCrypto(crypto, password)
                }
                privateKeyList.append(privateKeyArr)
            } else {
                try keyring.forEach {
                    guard let multiKeying = $0 as? [KeyStore.Crypto] else { return }
                    let privateKeyArr: [String] = try multiKeying.map {
                        return try KeyStore.Crypto.decryptCrypto($0, password)
                    }
                    privateKeyList.append(privateKeyArr)
                }
            }
            
            let isRoleBased = !privateKeyList.filter {
                $0 != privateKeyList.first && $0.count > 0
            }.isEmpty
            
            if isRoleBased {
                return try KeyringFactory.createWithRoleBasedKey(address, privateKeyList)
            } else {
                if privateKeyList[0].count > 1 {
                    return try KeyringFactory.createWithMultipleKey(address, privateKeyList[0])
                } else {
                    return try KeyringFactory.createWithSingleKey(address, privateKeyList[0][0])
                }
            }
        }
        
        throw CaverError.IllegalArgumentException("Unsupported keystore")
    }
}
