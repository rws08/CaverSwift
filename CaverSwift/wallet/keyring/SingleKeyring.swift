//
//  SingleKeyring.swift
//  CaverSwift
//
//  Created by won on 2021/06/25.
//

import Foundation

open class SingleKeyring: AbstractKeyring {
    private(set) public var key: PrivateKey
    
    init(_ address: String, _ key: PrivateKey) {
        self.key = key
        super.init(address)
    }
    
    override func sign(_ txHash: String, _ chainId: Int, _ role: Int) throws -> [SignatureData]? {
        let key = try getKeyByRole(role)
        return [try key.sign(txHash, chainId)]
    }
    
    override func sign(_ txHash: String, _ chainId: Int, _ role: Int, _ index: Int) throws -> SignatureData? {
        _ = try validatedIndexWithKeys(index, 1)
        let key = try getKeyByRole(role)
        return try key.sign(txHash, chainId)
    }
    
    override func signMessage(_ message: String, _ role: Int) throws -> MessageSigned? {
        let key = try getKeyByRole(role)
        let messageHash = Utils.hashMessage(message)
        let signatureData = try key.signMessage(messageHash)
        return MessageSigned(messageHash, [signatureData], message)
    }
    
    override func signMessage(_ message: String, _ role: Int, _ index: Int) throws -> MessageSigned? {
        _ = try validatedIndexWithKeys(index, 1)
        let messageHash = Utils.hashMessage(message)
        let signatureData = try key.signMessage(messageHash)
        return MessageSigned(messageHash, [signatureData], message)
    }
    
    public func getPublicKey(_ compressed: Bool = false) throws -> String {
        return try key.getPublicKey(compressed)
    }
    
    public func getKeyByRole(_ role: Int) throws -> PrivateKey {
        if role < 0 || role >= AccountKeyRoleBased.ROLE_GROUP_COUNT {
            throw CaverError.IllegalArgumentException("Invalid role index : \(role)")
        }
        return key
    }
    
    public func getKlaytnWalletKey() -> String {
        return "\(key.privateKey)0x00\(address)"
    }
    
    override func copy() -> AbstractKeyring {
        return SingleKeyring(address, key)
    }
    
    override var isDecoupled: Bool {
        get{
            self.address.lowercased() != self.key.getDerivedAddress().lowercased()
        }
    }
}
