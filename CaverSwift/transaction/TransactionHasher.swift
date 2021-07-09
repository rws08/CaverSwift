//
//  TransactionHasher.swift
//  CaverSwift
//
//  Created by won on 2021/07/09.
//

import Foundation

open class TransactionHasher {
    public static func getHashForSignature(_ transaction: AbstractTransaction) throws -> String {
        let rlpEncoded = try transaction.getCommonRLPEncodingForSignature()
        return rlpEncoded.sha3String
    }
    
//    public static func getHashForFeePayerSignature(_ transaction: AbstractFeeDelegatedTransaction) throws -> String {
//        let rlpEncoded = try transaction.getRLPEncodingForFeePayerSignature()
//        return rlpEncoded.sha3String
//    }
}
