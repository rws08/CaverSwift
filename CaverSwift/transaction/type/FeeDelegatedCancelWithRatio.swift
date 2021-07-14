//
//  FeeDelegatedCancelWithRatio.swift
//  CaverSwift
//
//  Created by won on 2021/07/13.
//

import Foundation

open class FeeDelegatedCancelWithRatio: AbstractFeeDelegatedWithRatioTransaction {
    
    public class Builder: AbstractFeeDelegatedWithRatioTransaction.Builder {
        init() {
            super.init(TransactionType.TxTypeFeeDelegatedCancelWithRatio.string)
        }
        public override func build() throws -> FeeDelegatedCancelWithRatio {
            return try FeeDelegatedCancelWithRatio(self)
        }
    }
    
    init(_ builder: Builder) throws {
        try super.init(builder)
    }
    
    init(_ klaytnCall: Klay?, _ from: String, _ nonce: String = "0x", _ gas: String, _ gasPrice: String = "0x", _ chainId: String = "0x", _ signatures: [SignatureData]?, _ feePayer: String, _ feePayerSignatures: [SignatureData]?, _ feeRatio: String) throws {
        try super.init(klaytnCall, TransactionType.TxTypeFeeDelegatedCancelWithRatio.string, from, nonce, gas, gasPrice, chainId, signatures, feePayer, feePayerSignatures, feeRatio)
    }
    
    public static func decode(_ rlpEncoded: String) throws -> FeeDelegatedCancelWithRatio {
        guard let data = rlpEncoded.bytesFromHex else {
            throw CaverError.unexpectedReturnValue
        }
        return try decode(data)
    }
    
    public static func decode(_ rlpEncoded: [UInt8]) throws -> FeeDelegatedCancelWithRatio {
        if rlpEncoded[0] != TransactionType.TxTypeFeeDelegatedCancelWithRatio.rawValue {
            throw CaverError.IllegalArgumentException("Invalid RLP-encoded tag - \(TransactionType.TxTypeFeeDelegatedCancelWithRatio)")
        }
        
        let rlpList = Rlp.decode(Array(rlpEncoded[1..<rlpEncoded.count]))
        guard let values = rlpList as? [Any],
              let nonce = values[0] as? String,
              let gasPrice = values[1] as? String,
              let gas = values[2] as? String,
              let from = values[3] as? String,
              let feeRatio = values[4] as? String,
              let senderSignatures = values[5] as? [[String]],
              let feePayer = values[6] as? String,
              let feePayerSignatures = values[7] as? [[String]] else {
            throw CaverError.RuntimeException("There is an error while decoding process.")
        }
        
        let senderSignList = SignatureData.decodeSignatures(senderSignatures)
        let feePayerSignList = SignatureData.decodeSignatures(feePayerSignatures)
        let feeDelegatedCancelWithRatio = try FeeDelegatedCancelWithRatio.Builder()
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setGas(gas)
            .setFrom(from.addHexPrefix)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignList)
            .setFeePayer(feePayer)
            .setFeePayerSignatures(feePayerSignList)
            .build()
        
        return feeDelegatedCancelWithRatio
    }
    
    public override func getRLPEncoding() throws -> String {
        try validateOptionalValues(false)
        
        let senderSignatureRLPList = signatures.map {
            $0.toRlpList()
        }
        
        let feePayerSignatureRLPList = feePayerSignatures.map {
            $0.toRlpList()
        }
        
        let rlpTypeList: [Any] = [
            BigInt(hex: nonce)!,
            BigInt(hex: gasPrice)!,
            BigInt(hex: gas)!,
            from,
            BigInt(hex: feeRatio)!,
            senderSignatureRLPList,
            feePayer,
            feePayerSignatureRLPList
        ]
        
        guard let encoded = Rlp.encode(rlpTypeList),
              var type = TransactionType.TxTypeFeeDelegatedCancelWithRatio.rawValue.hexa.hexData else { throw CaverError.invalidValue }
        type.append(encoded)
        let encodedStr = type.hexString
        return encodedStr
    }
    
    public override func getCommonRLPEncodingForSignature() throws -> String {
        try validateOptionalValues(true)
        
        let type = TransactionType.TxTypeFeeDelegatedCancelWithRatio.rawValue.hexa.hexData!
        
        let rlpTypeList: [Any] = [
            type,
            BigInt(hex: nonce)!,
            BigInt(hex: gasPrice)!,
            BigInt(hex: gas)!,
            from,
            BigInt(hex: feeRatio)!
        ]

        guard let encoded = Rlp.encode(rlpTypeList) else { throw CaverError.invalidValue }
        let encodedStr = encoded.hexString
        return encodedStr
    }
    
    public override func getSenderTxHash() throws -> String {
        try validateOptionalValues(false)
        
        let signatureRLPList = signatures.map {
            $0.toRlpList()
        }
        
        let rlpTypeList: [Any] = [
            BigInt(hex: nonce)!,
            BigInt(hex: gasPrice)!,
            BigInt(hex: gas)!,
            from,
            BigInt(hex: feeRatio)!,
            signatureRLPList
        ]
        
        guard let encoded = Rlp.encode(rlpTypeList),
              var type = TransactionType.TxTypeFeeDelegatedCancelWithRatio.rawValue.hexa.hexData else { throw CaverError.invalidValue }
        type.append(encoded)
        let encodedStr = type.keccak256.hexString
        return encodedStr
    }

    public override func compareTxField(_ txObj: AbstractFeeDelegatedWithRatioTransaction, _ checkSig: Bool) -> Bool {
        if !super.compareTxField(txObj, checkSig) { return false }
        guard txObj is FeeDelegatedCancelWithRatio else { return false }
        
        return true
    }
}
