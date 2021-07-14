//
//  FeeDelegatedChainDataAnchoringWithRatioWithRatio.swift
//  CaverSwift
//
//  Created by won on 2021/07/13.
//

import Foundation

open class FeeDelegatedChainDataAnchoringWithRatio: AbstractFeeDelegatedWithRatioTransaction {
    private(set) public var input: String?
    
    public class Builder: AbstractFeeDelegatedWithRatioTransaction.Builder {
        private(set) public var input: String?
        
        init() {
            super.init(TransactionType.TxTypeFeeDelegatedChainDataAnchoringWithRatio.string)
        }
        
        public override func build() throws -> FeeDelegatedChainDataAnchoringWithRatio {
            return try FeeDelegatedChainDataAnchoringWithRatio(self)
        }
        
        public func setInput(_ input: String) -> Self {
            self.input = input
            return self
        }
    }
    
    init(_ builder: Builder) throws {
        try super.init(builder)
        try setInput(builder.input)
    }
    
    init(_ klaytnCall: Klay?, _ from: String, _ nonce: String = "0x", _ gas: String, _ gasPrice: String = "0x", _ chainId: String = "0x", _ signatures: [SignatureData]?, _ feePayer: String, _ feePayerSignatures: [SignatureData]?, _ feeRatio: String, _ input: String) throws {
        try super.init(klaytnCall, TransactionType.TxTypeFeeDelegatedCancelWithRatio.string, from, nonce, gas, gasPrice, chainId, signatures, feePayer, feePayerSignatures, feeRatio)
        try setInput(input)
    }
    
    public static func decode(_ rlpEncoded: String) throws -> FeeDelegatedChainDataAnchoringWithRatio {
        guard let data = rlpEncoded.bytesFromHex else {
            throw CaverError.unexpectedReturnValue
        }
        return try decode(data)
    }
    
    public static func decode(_ rlpEncoded: [UInt8]) throws -> FeeDelegatedChainDataAnchoringWithRatio {
        if rlpEncoded[0] != TransactionType.TxTypeFeeDelegatedChainDataAnchoringWithRatio.rawValue {
            throw CaverError.IllegalArgumentException("Invalid RLP-encoded tag - \(TransactionType.TxTypeFeeDelegatedChainDataAnchoringWithRatio)")
        }
        
        let rlpList = Rlp.decode(Array(rlpEncoded[1..<rlpEncoded.count]))
        guard let values = rlpList as? [Any],
              let nonce = values[0] as? String,
              let gasPrice = values[1] as? String,
              let gas = values[2] as? String,
              let from = values[3] as? String,
              let input = values[4] as? String,
              let feeRatio = values[5] as? String,
              let senderSignatures = values[6] as? [[String]],
              let feePayer = values[7] as? String,
              let feePayerSignatures = values[8] as? [[String]] else {
            throw CaverError.RuntimeException("There is an error while decoding process.")
        }
        
        let senderSignList = SignatureData.decodeSignatures(senderSignatures)
        let feePayerSignList = SignatureData.decodeSignatures(feePayerSignatures)
        let feeDelegatedChainDataAnchoringWithRatio = try FeeDelegatedChainDataAnchoringWithRatio.Builder()
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setGas(gas)
            .setFrom(from.addHexPrefix)
            .setInput(input.addHexPrefix)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignList)
            .setFeePayer(feePayer)
            .setFeePayerSignatures(feePayerSignList)
            .build()
        
        return feeDelegatedChainDataAnchoringWithRatio
    }
    
    public override func getRLPEncoding() throws -> String {
        guard let input = input else { throw CaverError.invalidValue }
        
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
            input,
            BigInt(hex: feeRatio)!,
            senderSignatureRLPList,
            feePayer,
            feePayerSignatureRLPList
        ]
        
        guard let encoded = Rlp.encode(rlpTypeList),
              var type = TransactionType.TxTypeFeeDelegatedChainDataAnchoringWithRatio.rawValue.hexa.hexData else { throw CaverError.invalidValue }
        type.append(encoded)
        let encodedStr = type.hexString
        return encodedStr
    }
    
    public override func getCommonRLPEncodingForSignature() throws -> String {
        guard let input = input else { throw CaverError.invalidValue }
        
        try validateOptionalValues(true)
        
        let type = TransactionType.TxTypeFeeDelegatedChainDataAnchoringWithRatio.rawValue.hexa.hexData!
        
        let rlpTypeList: [Any] = [
            type,
            BigInt(hex: nonce)!,
            BigInt(hex: gasPrice)!,
            BigInt(hex: gas)!,
            from,
            input,
            BigInt(hex: feeRatio)!
        ]

        guard let encoded = Rlp.encode(rlpTypeList) else { throw CaverError.invalidValue }
        let encodedStr = encoded.hexString
        return encodedStr
    }
    
    public override func getSenderTxHash() throws -> String {
        guard let input = input else { throw CaverError.invalidValue }
        
        try validateOptionalValues(false)
        
        let signatureRLPList = signatures.map {
            $0.toRlpList()
        }
                
        let rlpTypeList: [Any] = [
            BigInt(hex: nonce)!,
            BigInt(hex: gasPrice)!,
            BigInt(hex: gas)!,
            from,
            input,
            BigInt(hex: feeRatio)!,
            signatureRLPList
        ]
        
        guard let encoded = Rlp.encode(rlpTypeList),
              var type = TransactionType.TxTypeFeeDelegatedChainDataAnchoringWithRatio.rawValue.hexa.hexData else { throw CaverError.invalidValue }
        type.append(encoded)
        let encodedStr = type.keccak256.hexString
        return encodedStr
    }

    public override func compareTxField(_ txObj: AbstractFeeDelegatedWithRatioTransaction, _ checkSig: Bool) -> Bool {
        if !super.compareTxField(txObj, checkSig) { return false }
        guard let txObj = txObj as? FeeDelegatedChainDataAnchoringWithRatio else { return false }
        if input != txObj.input { return false }
        
        return true
    }
    
    public func setInput(_ input: String?) throws {
        guard let input = input,
              !input.isEmpty else {
            throw CaverError.IllegalArgumentException("input is missing.")
        }
        if !Utils.isHex(input) {
            throw CaverError.IllegalArgumentException("Invalid input : \(input)")
        }
        
        self.input = input
    }
}
