//
//  LegacyTransaction.swift
//  CaverSwift
//
//  Created by won on 2021/07/09.
//

import Foundation

open class LegacyTransaction: AbstractTransaction {
    public class Builder: AbstractTransaction.Builder {
        init() {
            super.init(TransactionType.TxTypeLegacyTransaction.string)
        }
        public override func build() throws -> AbstractTransaction {
            return try LegacyTransaction(self)
        }
    }
}
