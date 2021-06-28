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
    
    override func sign(_ txHash: String, _ chinId: Int, _ role: Int) -> [SignatureData]? {
        return nil
    }
    
    public func getPublicKey(_ compressed: Bool) -> String {
        return key.getPublicKey(compressed)
    }
    
    public func getKeyByRole(_ role: Int) throws -> PrivateKey {
        if role < 0 || role >= AccountKeyRoleBased.ROLE_GROUP_COUNT {
            throw CaverError.IllegalAccessException("Invalid role index : \(role)")
        }
        return key
    }
}
