//
//  KIP17DeployParams.swift
//  CaverSwift
//
//  Created by won on 2021/07/27.
//

import Foundation

public struct KIP17DeployParams: Codable {
    var name = ""
    var symbol = ""
    
    internal init(_ name: String = "", _ symbol: String = "") {
        self.name = name
        self.symbol = symbol
    }
}
