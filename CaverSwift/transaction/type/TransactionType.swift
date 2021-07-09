//
//  TransactionType.swift
//  CaverSwift
//
//  Created by won on 2021/07/09.
//

import Foundation

public enum TransactionType: Int {
    case TxTypeLegacyTransaction = 0x00,

         TxTypeValueTransfer = 0x08,
         TxTypeFeeDelegatedValueTransfer = 0x09,
         TxTypeFeeDelegatedValueTransferWithRatio = 0x0a,

         TxTypeValueTransferMemo = 0x10,
         TxTypeFeeDelegatedValueTransferMemo = 0x11,
         TxTypeFeeDelegatedValueTransferMemoWithRatio = 0x12,

         TxTypeAccountUpdate = 0x20,
         TxTypeFeeDelegatedAccountUpdate = 0x21,
         TxTypeFeeDelegatedAccountUpdateWithRatio = 0x22,

         TxTypeSmartContractDeploy = 0x28,
         TxTypeFeeDelegatedSmartContractDeploy = 0x29,
         TxTypeFeeDelegatedSmartContractDeployWithRatio = 0x2a,

         TxTypeSmartContractExecution = 0x30,
         TxTypeFeeDelegatedSmartContractExecution = 0x31,
         TxTypeFeeDelegatedSmartContractExecutionWithRatio = 0x32,

         TxTypeCancel = 0x38,
         TxTypeFeeDelegatedCancel = 0x39,
         TxTypeFeeDelegatedCancelWithRatio = 0x3a,

         TxTypeChainDataAnchoring = 0x48,
         TxTypeFeeDelegatedChainDataAnchoring = 0x49,
         TxTypeFeeDelegatedChainDataAnchoringWithRatio = 0x4a
    
    var string: String {
        get{ String(rawValue) }
    }
}
