//
//  Cancel.swift
//  CaverSwift
//
//  Created by won on 2021/07/09.
//

import Foundation

open class Cancel: AbstractTransaction {
    public class Builder: AbstractTransaction.Builder {
        init() {
            super.init(TransactionType.TxTypeCancel.string)
        }
        public override func build() throws -> AbstractTransaction {
            return try Cancel(self)
        }
    }
}
