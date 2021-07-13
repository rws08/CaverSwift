//
//  TransactionDecoder.swift
//  CaverSwift
//
//  Created by won on 2021/07/09.
//

import Foundation
open class TransactionDecoder {
    public static func decode(_ rlpEncoded: String) throws -> AbstractTransaction {
        guard let rlpBytes = rlpEncoded.bytesFromHex else { throw CaverError.invalidValue }        
        guard let type = TransactionType(rawValue: Int(rlpBytes[0]))
        else { return try LegacyTransaction.decode(rlpBytes)  }
        
        switch type {
        case TransactionType.TxTypeValueTransfer:
            return try LegacyTransaction.decode(rlpBytes)
        case TransactionType.TxTypeValueTransferMemo:
            return try ValueTransferMemo.decode(rlpBytes)
        case TransactionType.TxTypeSmartContractDeploy:
            return try SmartContractDeploy.decode(rlpBytes)
        case TransactionType.TxTypeSmartContractExecution:
            return try SmartContractExecution.decode(rlpBytes)
        case TransactionType.TxTypeAccountUpdate:
            return try AccountUpdate.decode(rlpBytes)
        case TransactionType.TxTypeCancel:
            return try Cancel.decode(rlpBytes)
        case TransactionType.TxTypeChainDataAnchoring:
            return try ChainDataAnchoring.decode(rlpBytes)
        case TransactionType.TxTypeFeeDelegatedValueTransfer:
            return try FeeDelegatedValueTransfer.decode(rlpBytes)
        case TransactionType.TxTypeFeeDelegatedValueTransferMemo:
            return try FeeDelegatedValueTransferMemo.decode(rlpBytes)
        case TransactionType.TxTypeFeeDelegatedSmartContractDeploy:
            return try FeeDelegatedSmartContractDeploy.decode(rlpBytes)
        case TransactionType.TxTypeFeeDelegatedSmartContractExecution:
            return try FeeDelegatedSmartContractExecution.decode(rlpBytes)
        case TransactionType.TxTypeFeeDelegatedAccountUpdate:
            return try FeeDelegatedAccountUpdate.decode(rlpBytes)
        case TransactionType.TxTypeFeeDelegatedCancel:
            return try FeeDelegatedCancel.decode(rlpBytes)
        case TransactionType.TxTypeFeeDelegatedChainDataAnchoring:
            return try FeeDelegatedChainDataAnchoring.decode(rlpBytes)
        case TransactionType.TxTypeFeeDelegatedCancelWithRatio:
            return try FeeDelegatedCancelWithRatio.decode(rlpBytes)
        case TransactionType.TxTypeFeeDelegatedChainDataAnchoringWithRatio:
            return try FeeDelegatedChainDataAnchoringWithRatio.decode(rlpBytes)
        case TransactionType.TxTypeFeeDelegatedAccountUpdateWithRatio:
            return try FeeDelegatedAccountUpdateWithRatio.decode(rlpBytes)
        case TransactionType.TxTypeFeeDelegatedValueTransferWithRatio:
            return try FeeDelegatedValueTransferWithRatio.decode(rlpBytes)
        case TransactionType.TxTypeFeeDelegatedSmartContractExecutionWithRatio:
            return try FeeDelegatedSmartContractExecutionWithRatio.decode(rlpBytes)
        case TransactionType.TxTypeFeeDelegatedValueTransferMemoWithRatio:
            return try FeeDelegatedValueTransferMemoWithRatio.decode(rlpBytes)
        case TransactionType.TxTypeFeeDelegatedSmartContractDeployWithRatio:
            return try FeeDelegatedSmartContractDeployWithRatio.decode(rlpBytes)
        default:
            return try LegacyTransaction.decode(rlpBytes)
        }        
    }
}
