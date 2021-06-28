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
    
    func sign(_ txHash: String, _ chinId: Int, _ role: Int) -> [SignatureData]? { return nil }
    
    func sign(_ txHash: String, _ chinId: Int, _ role: Int, _ index: Int) -> SignatureData? { return nil }
    
    func signMessage(_ message: String, _ role: Int) -> MessageSigned? { return nil }
    
    func signMessage(_ message: String, _ role: Int, _ index: Int) -> MessageSigned? { return nil }
}
