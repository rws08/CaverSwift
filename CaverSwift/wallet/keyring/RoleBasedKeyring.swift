//
//  RoleBasedKeyring.swift
//  CaverSwift
//
//  Created by won on 2021/07/06.
//

import Foundation

open class RoleBasedKeyring: AbstractKeyring {
    private(set) public var keys: [[PrivateKey]]
    
    init(_ address: String, _ keys: [[PrivateKey]]) {
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
    
    public func getKeyByRole(_ role: Int) throws -> [PrivateKey] {
        if role < 0 || role >= AccountKeyRoleBased.ROLE_GROUP_COUNT {
            throw CaverError.IllegalArgumentException("Invalid role index : \(role)")
        }
        
        var keyArr = keys[role]
        if keyArr.isEmpty && role > AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue {
            if keys[AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue].isEmpty {
                throw CaverError.IllegalArgumentException("The Key with specified role group does not exists. The TRANSACTION role group is also empty")
            }
            keyArr = keys[AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue]
        }
        
        return keyArr
    }
    
    override func copy() -> AbstractKeyring {
        return RoleBasedKeyring(address, keys)
    }
}
