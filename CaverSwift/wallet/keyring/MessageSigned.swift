//
//  MessageSigned.swift
//  CaverSwift
//
//  Created by won on 2021/06/25.
//

import Foundation

open class MessageSigned {
    private(set) public var messageHash: String = ""
    private(set) public var signatures: [SignatureData] = []
    private(set) public var message: String = ""
    
    public init(_ messageHash: String, _ signatures: [SignatureData], _ message: String) {
        self.messageHash = messageHash
        self.signatures = signatures
        self.message = message
    }
}
