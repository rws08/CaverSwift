//
//  RoleBasedKeyring.swift
//  CaverSwift
//
//  Created by won on 2021/07/06.
//

import Foundation

open class RoleBasedKeyring: AbstractKeyring {
    private(set) public var keys: [[PrivateKey]]
    
    public init(_ address: String, _ keys: [[PrivateKey]]) {
        self.keys = keys
        super.init(address)
    }
    
    public override func sign(_ txHash: String, _ chainId: Int, _ role: Int) throws -> [SignatureData]? {
        let keyArr = try getKeyByRole(role)
        
        return try keyArr.map({
            return try $0.sign(txHash, chainId)
        })
    }
    
    override func sign(_ txHash: String, _ chainId: Int, _ role: Int, _ index: Int) throws -> SignatureData? {
        let keyArr = try getKeyByRole(role)
        _ = try validatedIndexWithKeys(index, keyArr.count)
        
        let key = keyArr[index]
        return try key.sign(txHash, chainId)
    }
    
    override func signMessage(_ message: String, _ role: Int) throws -> MessageSigned? {
        let keyArr = try getKeyByRole(role)
        let messageHash = Utils.hashMessage(message)
        let signatureDataList = try keyArr.map({
            return try $0.signMessage(messageHash)
        })
        return MessageSigned(messageHash, signatureDataList, message)
    }
    
    override func signMessage(_ message: String, _ role: Int, _ index: Int) throws -> MessageSigned? {
        let keyArr = try getKeyByRole(role)
        _ = try validatedIndexWithKeys(index, keyArr.count)
        let key = keyArr[index]
        let messageHash = Utils.hashMessage(message)
        let signatureData = try key.signMessage(messageHash)
        return MessageSigned(messageHash, [signatureData], message)
    }
    
    override func encrypt(_ password: String) throws -> KeyStore? {
        return try encrypt(password, KeyStoreOption.getDefaultOptionWithKDF(KeyStore.ScryptKdfParams.NAME))
    }
    
    override func encrypt(_ password: String, _ options: KeyStoreOption) throws -> KeyStore? {
        var cryptoList: [[KeyStore.Crypto]] = []
        for i in (0..<AccountKeyRoleBased.ROLE_GROUP_COUNT) {
            let crypto = try KeyStore.Crypto.createCrypto(keys[i], password, options)
            cryptoList.append(crypto)
        }
        
        let keyStore = KeyStore()
        keyStore.address = address
        keyStore.version = KeyStore.KEY_STORE_VERSION_V4
        keyStore.id = UUID().uuidString
        keyStore.keyring = cryptoList
        
        return keyStore
    }
    
    public func getPublicKey(_ compressed: Bool = false) throws -> [[String]] {
        return try keys.map {
            try $0.map {
                try $0.getPublicKey(compressed)
            }
        }
    }
    
    public func getKeyByRole(_ role: Int) throws -> [PrivateKey] {
        if role < 0 || role >= AccountKeyRoleBased.ROLE_GROUP_COUNT {
            throw CaverError.IllegalArgumentException("Invalid role index : \(role)")
        }
        
        var keyArr = keys[role]
        if keyArr.isEmpty && role > AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue {
            if keys[AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue].isEmpty {
                throw CaverError.RuntimeException("The Key with specified role group does not exists. The TRANSACTION role group is also empty")
            }
            keyArr = keys[AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue]
        }
        
        return keyArr
    }
    
    override func copy() -> AbstractKeyring {
        return RoleBasedKeyring(address, keys)
    }
    
    public func toAccount() throws -> Account {
        return try toAccount(WeightedMultiSigOptions.getDefaultOptionsForRoleBased(try getPublicKey()))
    }
    
    public func toAccount(_ options: [WeightedMultiSigOptions]) throws -> Account {
        return try Account.createWithAccountKeyRoleBased(address, try getPublicKey(), options)
    }
}
