//
//  NoOpTransactionReceiptProcessor.swift
//  CaverSwift
//
//  Created by won on 2021/07/20.
//

import Foundation

open class NoOpTransactionReceiptProcessor: TransactionReceiptProcessor {
    public override func waitForTransactionReceipt(_ transactionHash: String) throws -> TransactionReceiptData {
        let transactionReceiptData = TransactionReceiptData()
        transactionReceiptData.transactionHash = transactionHash
        return transactionReceiptData
    }
}
