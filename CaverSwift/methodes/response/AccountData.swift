//
//  AccountData.swift
//  CaverSwift
//
//  Created by won on 2021/07/30.
//

import Foundation

open class AccountData: Codable {
    public var accType = 1
    private var account = IAccountType()
    
    enum CodingKeys: String, CodingKey {
        case accType, account
    }
    
    init() {
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.accType = (try? container.decode(Int.self, forKey: .accType)) ?? 0
        
        if self.accType == IAccountType.AccType.EOA.rawValue {
            self.account = (try? container.decode(AccountTypeEOA.self, forKey: .account)) ?? IAccountType()
        } else if self.accType == IAccountType.AccType.SCA.rawValue {
            self.account = (try? container.decode(AccountTypeSCA.self, forKey: .account)) ?? IAccountType()
        } else {
            self.account = IAccountType()
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.accType, forKey: .accType)
        try container.encode(self.account, forKey: .account)
    }
}
