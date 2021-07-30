//
//  NoOpTransactionReceiptProcessor.swift
//  CaverSwift
//
//  Created by won on 2021/07/20.
//

import Foundation

open class NoOpTransactionReceiptProcessor: TransactionReceiptProcessor {
    public override func waitForTransactionReceipt(_ transactionHash: String) throws -> TransactionReceipt {
        let transactionReceiptData = TransactionReceipt()
        transactionReceiptData.transactionHash = transactionHash
        return transactionReceiptData
    }
}
