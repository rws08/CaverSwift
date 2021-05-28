//
//  KeyringContainer.swift
//  CaverSwift
//
//  Created by won on 2021/05/10.
//

import Foundation

public class KeyringContainer: IWallet {
    var addressKeyringMap = [String:AbstractKeyring].self
    
    public init() {
        
    }
}
