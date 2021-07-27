//
//  KIP7DeployParams.swift
//  CaverSwift
//
//  Created by won on 2021/07/26.
//

import Foundation
import BigInt

public struct KIP7DeployParams: Codable {
    var name = ""
    var symbol = ""
    var decimals = 0
    var initialSupply = BigInt(0)
    
    internal init(_ name: String = "", _ symbol: String = "", _ decimals: Int = 0, _ initialSupply: BigInt = BigInt(0)) {
        self.name = name
        self.symbol = symbol
        self.decimals = decimals
        self.initialSupply = initialSupply
    }

}
