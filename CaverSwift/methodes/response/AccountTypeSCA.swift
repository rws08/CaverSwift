//
//  AccountTypeSCA.swift
//  CaverSwift
//
//  Created by won on 2021/07/30.
//

import Foundation

open class AccountTypeSCA: IAccountType {
    public var balance: String
    public var codeFormat: String
    public var codeHash: String
    public var humanReadable: Bool
    public var key: AccountData
    public var nonce: String
    public var storageRoot: String
    
    private enum CodingKeys: String, CodingKey {
        case balance, codeFormat, codeHash, humanReadable, key, nonce, storageRoot
    }
    
    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(balance, forKey: .balance)
        try container.encode(codeFormat, forKey: .codeFormat)
        try container.encode(codeHash, forKey: .codeHash)
        try container.encode(humanReadable, forKey: .humanReadable)
        try container.encode(key, forKey: .key)
        try container.encode(nonce, forKey: .nonce)
        try container.encode(storageRoot, forKey: .storageRoot)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.balance = (try? container.decode(String.self, forKey: .balance)) ?? ""
        self.codeFormat = (try? container.decode(String.self, forKey: .codeFormat)) ?? ""
        self.codeHash = (try? container.decode(String.self, forKey: .codeHash)) ?? ""
        self.humanReadable = (try? container.decode(Bool.self, forKey: .humanReadable)) ?? false
        self.key = (try? container.decode(AccountData.self, forKey: .key)) ?? AccountData()
        self.nonce = (try? container.decode(String.self, forKey: .nonce)) ?? ""
        self.storageRoot = (try? container.decode(String.self, forKey: .storageRoot)) ?? ""
        try super.init(from: decoder)
    }
    
    internal init(_ balance: String, _ codeFormat: String, _ codeHash: String, _ humanReadable: Bool, _ key: AccountData, _ nonce: String, _ storageRoot: String) {
        self.balance = balance
        self.codeFormat = codeFormat
        self.codeHash = codeHash
        self.humanReadable = humanReadable
        self.key = key
        self.nonce = nonce
        self.storageRoot = storageRoot
        super.init()
    }
}
