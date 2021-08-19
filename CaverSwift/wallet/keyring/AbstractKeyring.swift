//
//  AbstractKeyring.swift
//  CaverSwift
//
//  Created by won on 2021/05/10.
//

import Foundation

open class AbstractKeyring {
    var address: String = ""
    
    public init(_ address: String) {
        self.address = address
    }
    
    func sign(_ txHash: String, _ chainId: Int, _ role: Int) throws -> [SignatureData]? { return nil }
    
    func sign(_ txHash: String, _ chainId: Int, _ role: Int, _ index: Int) throws -> SignatureData? { return nil }
    
    func signMessage(_ message: String, _ role: Int) throws -> MessageSigned? { return nil }
    
    func signMessage(_ message: String, _ role: Int, _ index: Int) throws -> MessageSigned? { return nil }
    
    func encrypt(_ password: String) throws -> KeyStore? { return nil }
    
    func encrypt(_ password: String, _ options: KeyStoreOption) throws -> KeyStore? { return nil }
    
    func encryptV3(_ password: String, _ options: KeyStoreOption) throws -> KeyStore? {
        throw CaverError.RuntimeException("Not supported for this class. Use 'encrypt()' function")
    }
    
    func encryptV3(_ password: String) throws -> KeyStore? {
        throw CaverError.RuntimeException("Not supported for this class. Use 'encrypt()' function")
    }
    
    func getKlaytnWalletKey() throws -> String {
        throw CaverError.RuntimeException("Not supported for this class.")
    }
    
    func copy() -> AbstractKeyring { return AbstractKeyring("") }
    
    func sign(_ txHash: String, _ chainId: String, _ role: Int) throws -> [SignatureData]? {
        if !Utils.isNumber(chainId) {
            throw CaverError.IllegalArgumentException("Invalid chainId : ")
        }
        return try sign(txHash, chainId.hexaToDecimal, role)
    }
    
    func sign(_ txHash: String, _ chainId: String, _ role: Int, _ index: Int) throws -> SignatureData? {
        if !Utils.isNumber(chainId) {
            throw CaverError.IllegalArgumentException("Invalid chainId : ")
        }
        return try sign(txHash, chainId.hexaToDecimal, role, index)        
    }
    
    var isDecoupled: Bool {
        get{ true }
    }
        
    func validatedIndexWithKeys(_ index: Int, _ keyLength: Int) throws -> Bool {
        if index < 0 { throw CaverError.IllegalArgumentException("Invalid index : index cannot be negative") }
        if index >= keyLength { throw CaverError.IllegalArgumentException("Invalid index : index must be less than the length of the key.") }
        
        return true
    }
}
