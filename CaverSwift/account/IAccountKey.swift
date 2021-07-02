//
//  IAccountKey.swift
//  CaverSwift
//
//  Created by won on 2021/06/23.
//

import Foundation

public protocol IAccountKey {
    func getRLPEncoding() throws -> String
}
