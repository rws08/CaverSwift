//
//  KeyStoreOption.swift
//  CaverSwift
//
//  Created by won on 2021/07/07.
//

import Foundation

open class KeyStoreOption {
    var cipherParams: KeyStore.CipherParams
    let kdfParams: KeyStore.IKdfParams
    let address: String?
    
    init(_ cipherParams: KeyStore.CipherParams, _ kdfParams: KeyStore.IKdfParams, _ address: String?) {
        self.cipherParams = cipherParams
        self.kdfParams = kdfParams
        self.address = address
    }
    
    public static func getDefaultOptionWithKDF(_ kdfName: String) throws -> KeyStoreOption {
        return try getDefaultOptionWithKDF(kdfName, nil)
    }
    
    public static func getDefaultOptionWithKDF(_ kdfName: String, _ address: String?) throws -> KeyStoreOption {
        var kdfParams: KeyStore.IKdfParams
        if kdfName == KeyStore.ScryptKdfParams.NAME {
            kdfParams = KeyStore.ScryptKdfParams()
        } else if kdfName == KeyStore.Pbkdf2KdfParams.NAME {
            kdfParams = KeyStore.Pbkdf2KdfParams()
        } else {
            throw CaverError.IllegalArgumentException("Not supported kdf method.")
        }
        
        return KeyStoreOption(KeyStore.CipherParams(), kdfParams, address)
    }
}
