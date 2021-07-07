//
//  AbstractKeyring.swift
//  CaverSwift
//
//  Created by won on 2021/05/10.
//

import Foundation

open class AbstractKeyring {
    var address: String = ""
    
    init(_ address: String) {
        self.address = address
    }
    
    func sign(_ txHash: String, _ chainId: Int, _ role: Int) throws -> [SignatureData]? { return nil }
    
    func sign(_ txHash: String, _ chainId: Int, _ role: Int, _ index: Int) throws -> SignatureData? { return nil }
    
    func signMessage(_ message: String, _ role: Int) throws -> MessageSigned? { return nil }
    
    func signMessage(_ message: String, _ role: Int, _ index: Int) throws -> MessageSigned? { return nil }
    
    func copy() -> AbstractKeyring { return AbstractKeyring("") }
    
    var isDecoupled: Bool {
        get{ true }
    }
        
    func validatedIndexWithKeys(_ index: Int, _ keyLength: Int) throws -> Bool {
        if index < 0 { throw CaverError.IllegalArgumentException("Invalid index : index cannot be negative") }
        if index >= keyLength { throw CaverError.IllegalArgumentException("Invalid index : index must be less than the length of the key.") }
        
        return true
    }
}
