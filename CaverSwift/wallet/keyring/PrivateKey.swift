//
//  PrivateKey.swift
//  CaverSwift
//
//  Created by won on 2021/06/23.
//

import Foundation

open class PrivateKey {
    static let LEN_UNCOMPRESSED_PUBLIC_KEY_STRING = 128
    
    private var privateKey = ""
    
    public init(_ privateKey: String) throws {
        if !Utils.isValidPrivateKey(privateKey) {
            throw CaverError.IllegalAccessException("Invalid private key")
        }
        self.privateKey = privateKey
    }
}
