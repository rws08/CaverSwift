//
//  AccountKeyPublic.swift
//  CaverSwift
//
//  Created by won on 2021/06/23.
//

import Foundation

open class AccountKeyPublic: IAccountKey {
    private static let TYPE = "0x02"
    
    private var publicKey = ""
    
    public static let OFFSET_X_POINT = 0
    public static let OFFSET_Y_POINT = 1
    
    init(_ publicKey: String) {
        try? self.setPublicKey(publicKey)
    }
    
    public func setPublicKey(_ publicKey: String) throws {
        if !Utils.isValidPublicKey(publicKey) {
            throw CaverError.RuntimeException("Invalid Public Key format")
        }
        self.publicKey = publicKey
    }
        
    public func getType() -> String {
        return AccountKeyPublic.TYPE
    }
    
    public func getRLPEncoding() -> String {
        return ""
    }
    
    
}
