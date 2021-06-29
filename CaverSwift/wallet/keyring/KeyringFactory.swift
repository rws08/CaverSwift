//
//  KeyringFactory.swift
//  CaverSwift
//
//  Created by won on 2021/06/25.
//

import Foundation

open class KeyringFactory {
    public static func generate() throws -> SingleKeyring {
        return try KeyringFactory.generate("")
    }
    
    public static func generate(_ entropy: String) throws -> SingleKeyring {
        let privateKey = PrivateKey.generate(entropy)
        let address = privateKey.getDerivedAddress()
        
        return try createWithSingleKey(address, privateKey.privateKey)
    }
    
    public static func createWithSingleKey(_ address: String, _ key: String) throws -> SingleKeyring {
        if(Utils.isKlaytnWalletKey(key)) {
            throw CaverError.IllegalAccessException("Invalid format of parameter. Use 'fromKlaytnWalletKey' to create Keyring from KlaytnWalletKey.")
        }

        let privateKey = try PrivateKey(key)
        return SingleKeyring(address, privateKey)
    }
}
