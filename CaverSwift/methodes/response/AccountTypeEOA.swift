//
//  AccountTypeEOA.swift
//  CaverSwift
//
//  Created by won on 2021/07/30.
//

import Foundation

open class AccountTypeEOA: IAccountType {
    public var balance: String
    public var humanReadable: Bool
    public var key: AccountData
    public var nonce: String
    
    private enum CodingKeys: String, CodingKey {
        case balance, humanReadable, key, nonce
    }
    
    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(balance, forKey: .balance)
        try container.encode(humanReadable, forKey: .humanReadable)
        try container.encode(key, forKey: .key)
        try container.encode(nonce, forKey: .nonce)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.balance = (try? container.decode(String.self, forKey: .balance)) ?? ""
        self.humanReadable = (try? container.decode(Bool.self, forKey: .humanReadable)) ?? false
        self.key = (try? container.decode(AccountData.self, forKey: .key)) ?? AccountData()
        self.nonce = (try? container.decode(String.self, forKey: .nonce)) ?? ""
        try super.init(from: decoder)
    }
    
    internal init(_ balance: String, _ humanReadable: Bool, _ key: AccountData, _ nonce: String) {
        self.balance = balance
        self.humanReadable = humanReadable
        self.key = key
        self.nonce = nonce
        super.init()
    }
}

