//
//  TransactionReceiptProcessor.swift
//  CaverSwift
//
//  Created by won on 2021/07/20.
//

import Foundation

open class TransactionReceiptProcessor {
    private let caver: Caver
    
    init(_ caver: Caver) {
        self.caver = caver
    }
    
    public func waitForTransactionReceipt(_ transactionHash: String) throws -> TransactionReceiptData {
        throw CaverError.unexpectedReturnValue
    }
    
    public func sendTransactionReceiptRequest(_ transactionHash: String) throws -> TransactionReceiptData {
        let (error, response) = caver.rpc.klay.getTransactionReceipt(transactionHash)
        if let response = response {
            return response
        } else if error != nil {
            throw CaverError.TransactionException("Error processing request: \(error.debugDescription)", transactionHash)
        }
        throw CaverError.unexpectedReturnValue
    }
}
