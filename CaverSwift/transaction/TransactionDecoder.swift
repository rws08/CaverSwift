//
//  TransactionDecoder.swift
//  CaverSwift
//
//  Created by won on 2021/07/09.
//

import Foundation
open class TransactionDecoder {
    public static func decode(_ rlpEncoded: String) throws -> AbstractTransaction {
        guard let rlpBytes = rlpEncoded.bytesFromHex,
              let type = TransactionType(rawValue: Int(rlpBytes[0])) else { throw CaverError.invalidValue }
        
        switch type {
        case TransactionType.TxTypeValueTransfer:
            return try LegacyTransaction.decode(rlpBytes)
        default:
            return try LegacyTransaction.decode(rlpBytes)
        }        
    }
}
