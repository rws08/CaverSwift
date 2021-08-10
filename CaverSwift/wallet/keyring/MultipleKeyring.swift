//
//  MultipleKeyring.swift
//  CaverSwift
//
//  Created by won on 2021/07/06.
//

import Foundation

open class MultipleKeyring: AbstractKeyring {
    private(set) public var keys: [PrivateKey]
    
    init(_ address: String, _ keys: [PrivateKey]) {
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
        _ = try validatedIndexWithKeys(index, keys.count)
        
        let key = try getKeyByRole(role)[index]
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
        _ = try validatedIndexWithKeys(index, keys.count)
        let key = try getKeyByRole(role)[index]
        let messageHash = Utils.hashMessage(message)
        let signatureData = try key.signMessage(messageHash)
        return MessageSigned(messageHash, [signatureData], message)
    }
    
    override func encrypt(_ password: String) throws -> KeyStore? {
        return try encrypt(password, KeyStoreOption.getDefaultOptionWithKDF(KeyStore.ScryptKdfParams.NAME))
    }
    
    override func encrypt(_ password: String, _ options: KeyStoreOption) throws -> KeyStore? {
        let crypto = try KeyStore.Crypto.createCrypto(keys, password, options)
        
        let keyStore = KeyStore()
        keyStore.address = address
        keyStore.version = KeyStore.KEY_STORE_VERSION_V4
        keyStore.id = UUID().uuidString
        keyStore.keyring = crypto
        
        return keyStore
    }
    
    public func getPublicKey(_ compressed: Bool = false) throws -> [String] {
        return try keys.map {
            try $0.getPublicKey(compressed)
        }
    }
    
    public func getKeyByRole(_ role: Int) throws -> [PrivateKey] {
        if role < 0 || role >= AccountKeyRoleBased.ROLE_GROUP_COUNT {
            throw CaverError.IllegalArgumentException("Invalid role index : \(role)")
        }
        
        return keys
    }
    
    override func copy() -> AbstractKeyring {
        return MultipleKeyring(address, keys)
    }
    
    public func toAccount() throws -> Account {
        return try toAccount(WeightedMultiSigOptions.getDefaultOptionsForWeightedMultiSig(try getPublicKey()))
    }
    
    public func toAccount(_ options: WeightedMultiSigOptions) throws -> Account {
        return try Account.createWithAccountKeyWeightedMultiSig(address, try getPublicKey(), options)
    }
}
