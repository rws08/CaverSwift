//
//  AbstractTransaction.swift
//  CaverSwift
//
//  Created by won on 2021/07/09.
//

import Foundation

open class AbstractTransaction {
    public var klaytnCall: Klay?
    
    public var type: String?
    
    public var from: String?
    
    public var nonce = "0x"
    
    public var gas: String?
    
    public var gasPrice = "0x"
    
    public var chainId = "0x"
    
    public var signatures: [SignatureData] = []
    
    init(klaytnCall: Klay?, type: String?, from: String?, nonce: String = "0x", gas: String?, gasPrice: String = "0x", chainId: String = "0x", signatures: [SignatureData]) {
        self.klaytnCall = klaytnCall
        self.type = type
        self.from = from
        self.nonce = nonce
        self.gas = gas
        self.gasPrice = gasPrice
        self.chainId = chainId
        self.signatures.append(contentsOf: signatures)
    }
}
