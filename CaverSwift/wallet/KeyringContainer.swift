//
//  KeyringContainer.swift
//  CaverSwift
//
//  Created by won on 2021/05/10.
//

import Foundation

public class KeyringContainer: IWallet {
    var addressKeyringMap: [String: AbstractKeyring] = [:]
    
    public init() {
        
    }
    
    public init(_ keyrings: [AbstractKeyring]) throws {
        try keyrings.forEach { _ = try add($0) }
    }
    
    public func generate(_ num: Int) throws -> [String] {
        return try generate(num, "")
    }
    
    public func generate(_ num: Int, _ entropy: String? = nil) throws -> [String] {
        return try (0..<num).map { _ in
            guard let keyring = KeyringFactory.generate(entropy)
            else { throw CaverError.invalidValue }
            _ = try add(keyring)
            return keyring.address
        }
    }
    
    public var count: Int { addressKeyringMap.count }
    
    public func newKeyring(_ address: String, _ key: String) throws -> AbstractKeyring {
        let keyring = try KeyringFactory.createWithSingleKey(address, key)
        return try add(keyring)
    }
    
    public func newKeyring(_ address: String, _ keys: [String]) throws -> AbstractKeyring {
        let keyring = try KeyringFactory.createWithMultipleKey(address, keys)
        return try add(keyring)
    }
    
    public func newKeyring(_ address: String, _ keys: [[String]]) throws -> AbstractKeyring {
        let keyring = try KeyringFactory.createWithRoleBasedKey(address, keys)
        return try add(keyring)
    }
    
    public func updateKeyring(_ keyring: AbstractKeyring) throws -> AbstractKeyring {
        guard let _ = try getKeyring(keyring.address) else {
            throw CaverError.IllegalArgumentException("Failed to find keyring to update.")
        }
        _ = try remove(keyring.address)
        return try add(keyring)
    }
    
    public func add(_ keyring: AbstractKeyring) throws -> AbstractKeyring {
        if try getKeyring(keyring.address) != nil {
            throw CaverError.IllegalArgumentException("Duplicated Account. Please use updateKeyring() instead")
        }
        
        let added = keyring.copy()
        addressKeyringMap[keyring.address.lowercased()] = added
        
        return added
    }
    
    public func isExisted(_ address: String) throws -> Bool {
        return try getKeyring(address) != nil
    }
    
    public func remove(_ address: String) throws -> Bool {
        if !Utils.isAddress(address) {
            throw CaverError.IllegalArgumentException("To remove keyring, the first parameter should be an address string")
        }
        
        if !(try isExisted(address)) {
            return false
        }
        
        addressKeyringMap.removeValue(forKey: address)
        return true
    }
    
    func signMessage(_ address: String, _ data: String, _ role: Int = 0, _ index: Int = 0) throws -> MessageSigned? {
        if !(try isExisted(address)) {
            throw CaverError.NullPointerException("Failed to find keyring from wallet with address")
        }
        return try getKeyring(address)?.signMessage(data, role, index)
    }
    
    public func sign(_ address: String, _ transaction: AbstractTransaction) throws -> AbstractTransaction {
        return try sign(address, transaction, TransactionHasher.getHashForSignature(_:))
    }
    
    func sign(_ address: String, _ transaction: AbstractTransaction, _ hasher: (AbstractTransaction) throws ->String) throws -> AbstractTransaction {
        if !(try isExisted(address)) {
            throw CaverError.NullPointerException("Failed to find keyring from wallet with address")
        }
        
        return try transaction.sign(try getKeyring(address)!, hasher)
    }
    
    func sign(_ address: String, _ transaction: AbstractTransaction, _ index: Int, _ hasher: ((AbstractTransaction) throws ->String) = TransactionHasher.getHashForSignature(_:)) throws -> AbstractTransaction {
        if !(try isExisted(address)) {
            throw CaverError.NullPointerException("Failed to find keyring from wallet with address")
        }
        
        return try transaction.sign(try getKeyring(address)!, index, hasher)
    }
    
    public func signAsFeePayer(_ address: String, _ transaction: AbstractFeeDelegatedTransaction) throws -> AbstractFeeDelegatedTransaction {
        return try signAsFeePayer(address, transaction, TransactionHasher.getHashForFeePayerSignature(_:))
    }
    
    func signAsFeePayer(_ address: String, _ transaction: AbstractFeeDelegatedTransaction, _ hasher: (AbstractFeeDelegatedTransaction) throws ->String) throws -> AbstractFeeDelegatedTransaction {
        if !(try isExisted(address)) {
            throw CaverError.NullPointerException("Failed to find keyring from wallet with address")
        }
        
        return try transaction.signAsFeePayer(try getKeyring(address)!, hasher)
    }
    
    func signAsFeePayer(_ address: String, _ transaction: AbstractFeeDelegatedTransaction, _ index: Int, _ hasher: ((AbstractFeeDelegatedTransaction) throws ->String) = TransactionHasher.getHashForFeePayerSignature(_:)) throws -> AbstractFeeDelegatedTransaction {
        if !(try isExisted(address)) {
            throw CaverError.NullPointerException("Failed to find keyring from wallet with address")
        }
        
        return try transaction.signAsFeePayer(try getKeyring(address)!, index, hasher)
    }
    
    public func getKeyring(_ address: String) throws -> AbstractKeyring? {
        if !Utils.isAddress(address) {
            throw CaverError.IllegalArgumentException("Invalid address. To get keyring from wallet, you need to pass a valid address string as a parameter.")
        }
        
        return addressKeyringMap[address.lowercased()]
    }
}
