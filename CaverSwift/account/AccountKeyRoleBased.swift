//
//  AccountKeyRoleBased.swift
//  CaverSwift
//
//  Created by won on 2021/06/25.
//

import Foundation

open class AccountKeyRoleBased: IAccountKey {
    
    
    private static let TYPE = "0x05"
    
    public enum RoleGroup: Int, CaseIterable {
        case TRANSACTION = 0
        case ACCOUNT_UPDATE = 1
        case FEE_PAYER = 2
    }
    
    public static let ROLE_GROUP_COUNT = RoleGroup.allCases.count
    
    public func getRLPEncoding() -> String {
        ""
    }
}
