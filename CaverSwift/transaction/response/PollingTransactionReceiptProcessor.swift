//
//  PollingTransactionReceiptProcessor.swift
//  CaverSwift
//
//  Created by won on 2021/07/20.
//

import Foundation

open class PollingTransactionReceiptProcessor: TransactionReceiptProcessor {
    let sleepDuration: Int // ms (1sec = 1000ms)
    let attempts: Int
    
    internal init(_ caver: Caver, _ sleepDuration: Int, _ attempts: Int) {
        self.sleepDuration = sleepDuration
        self.attempts = attempts
        super.init(caver)
    }
    
    public override func waitForTransactionReceipt(_ transactionHash: String) throws -> TransactionReceipt {
        return try getTransactionReceipt(transactionHash, sleepDuration, attempts)
    }
    
    private func getTransactionReceipt(_ transactionHash: String, _ sleepDuration: Int, _ attempts: Int) throws -> TransactionReceipt {
        var receiptOptional = try? sendTransactionReceiptRequest(transactionHash)
        
        for _ in (0..<attempts) {
            if let receiptOptional = receiptOptional {
                return receiptOptional
            } else {
                do {
                    usleep(useconds_t(sleepDuration * 1000))
                }
            
                receiptOptional = try? sendTransactionReceiptRequest(transactionHash)
            }
        }
        
        throw CaverError.TransactionException("Transaction receipt was not generated after \((sleepDuration * attempts) / 1000) seconds for transaction: \(transactionHash)", transactionHash)
    }
}
