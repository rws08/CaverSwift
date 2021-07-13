//
//  AbstractFeeDelegatedWithRatioTransaction.swift
//  CaverSwift
//
//  Created by won on 2021/07/12.
//

import Foundation

open class AbstractFeeDelegatedWithRatioTransaction: AbstractFeeDelegatedTransaction {
    private(set) public var feeRatio = ""
    
    public class Builder: AbstractFeeDelegatedTransaction.Builder {
        private(set) public var feeRatio = ""
        
        override init(_ type: String) {
            super.init(type)
        }
        
        public override func build() throws -> AbstractFeeDelegatedWithRatioTransaction {
            return try AbstractFeeDelegatedWithRatioTransaction(self)
        }
        
        public func setFeeRatio(_ feeRatio: String) -> Self {
            self.feeRatio = feeRatio
            return self
        }
        
        public func setFeeRatio(_ feeRatio: BigInt) -> Self {
            return setFeeRatio(feeRatio.hexa)
        }
    }
    
    init(_ builder: Builder) throws {
        try super.init(builder)
        try setFeeRatio(builder.feeRatio)
    }
    
    init(_ klaytnCall: Klay?, _ type: String, _ from: String, _ nonce: String = "0x", _ gas: String, _ gasPrice: String = "0x", _ chainId: String = "0x", _ signatures: [SignatureData]?, _ feePayer: String, _ feePayerSignatures: [SignatureData]?, _ feeRatio: String) throws {
        try super.init(klaytnCall, type, from, nonce, gas, gasPrice, chainId, signatures, feePayer, feePayerSignatures)
        try setFeeRatio(feeRatio)
    }
    
    public func compareTxField(_ txObj: AbstractFeeDelegatedWithRatioTransaction, _ checkSig: Bool) -> Bool {
        if !super.compareTxField(txObj, checkSig) { return false }
        if BigInt(hex: feeRatio) != BigInt(hex: txObj.feeRatio) { return false }
        
        return true
    }
    
    public func setFeeRatio(_ feeRatio: String) throws {
        if feeRatio.isEmpty {
            throw CaverError.IllegalArgumentException("feeRatio is missing.")
        }
        
        if !Utils.isNumber(feeRatio) || !Utils.isHex(feeRatio) {
            throw CaverError.IllegalArgumentException("Invalid type of feeRatio: feeRatio should be number type or hex number string")
        }
    
        guard let feeRatioVal = BigInt(feeRatio) else { throw CaverError.invalidValue }
        if feeRatioVal <= 0 || feeRatioVal >= 100 {
            throw CaverError.IllegalArgumentException("Invalid feeRatio: feeRatio is out of range. [1,99]")
        }
        
        self.feeRatio = feeRatio
    }
    
    public func setFeeRatio(_ feeRatio: BigInt) throws {
        try setFeeRatio(feeRatio.hexa)
    }
}
