//
//  IWallet.swift
//  CaverSwift
//
//  Created by won on 2021/05/10.
//

import Foundation

public protocol IWallet {
    func generate(_ num: Int) throws -> [String]
    func isExisted(_ address: String) throws -> Bool
    func remove(_ address: String) throws -> Bool
    func sign(_ address: String, _ transaction: AbstractTransaction) throws -> AbstractTransaction
    func signAsFeePayer(_ address: String, _ transaction: AbstractFeeDelegatedTransaction) throws -> AbstractFeeDelegatedTransaction
}
