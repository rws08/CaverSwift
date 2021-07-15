//
//  FeeDelegatedValueTransfer.swift
//  CaverSwift
//
//  Created by won on 2021/07/13.
//

import Foundation

open class FeeDelegatedValueTransfer: AbstractFeeDelegatedTransaction {
    private(set) public var to = ""
    private(set) public var value = ""
    
    public class Builder: AbstractFeeDelegatedTransaction.Builder {
        private(set) public var to = ""
        private(set) public var value = ""
        
        init() {
            super.init(TransactionType.TxTypeFeeDelegatedValueTransfer.string)
        }
        
        public override func build() throws -> FeeDelegatedValueTransfer {
            return try FeeDelegatedValueTransfer(self)
        }
        
        public func setValue(_ value: String) -> Self {
            self.value = value
            return self
        }
        
        public func setValue(_ value: BigInt) -> Self {
            return setValue(value.hexa)
        }
        
        public func setTo(_ to: String) -> Self {
            self.to = to
            return self
        }
    }
    
    init(_ builder: Builder) throws {
        try super.init(builder)
        try setTo(builder.to)
        try setValue(builder.value)
    }
    
    init(_ klaytnCall: Klay?, _ from: String, _ nonce: String = "0x", _ gas: String, _ gasPrice: String = "0x", _ chainId: String = "0x", _ signatures: [SignatureData]?, _ feePayer: String, _ feePayerSignatures:[SignatureData]?, _ to: String, _ value: String) throws {
        try super.init(klaytnCall, TransactionType.TxTypeFeeDelegatedValueTransfer.string, from, nonce, gas, gasPrice, chainId, signatures, feePayer, feePayerSignatures)
        try setTo(to)
        try setValue(value)
    }
    
    public static func decode(_ rlpEncoded: String) throws -> FeeDelegatedValueTransfer {
        guard let data = rlpEncoded.bytesFromHex else {
            throw CaverError.unexpectedReturnValue
        }
        return try decode(data)
    }
    
    public static func decode(_ rlpEncoded: [UInt8]) throws -> FeeDelegatedValueTransfer {
        if rlpEncoded[0] != TransactionType.TxTypeFeeDelegatedValueTransfer.rawValue {
            throw CaverError.IllegalArgumentException("Invalid RLP-encoded tag - \(TransactionType.TxTypeFeeDelegatedValueTransfer)")
        }
        
        let rlpList = Rlp.decode(Array(rlpEncoded[1..<rlpEncoded.count]))
        guard let values = rlpList as? [Any],
              let nonce = values[0] as? String,
              let gasPrice = values[1] as? String,
              let gas = values[2] as? String,
              let to = values[3] as? String,
              let value = values[4] as? String,
              let from = values[5] as? String,
              let senderSignatures = values[6] as? [[String]],
              let feePayer = values[7] as? String,
              let feePayerSignatures = values[8] as? [[String]] else {
            throw CaverError.RuntimeException("There is an error while decoding process.")
        }
        
        let senderSignList = SignatureData.decodeSignatures(senderSignatures)
        let feePayerSignList = SignatureData.decodeSignatures(feePayerSignatures)
        let feeDelegatedValueTransfer = try FeeDelegatedValueTransfer.Builder()
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setGas(gas)
            .setTo(to.addHexPrefix)
            .setValue(BigInt(hex: value)!)
            .setFrom(from.addHexPrefix)
            .setSignatures(senderSignList)
            .setFeePayer(feePayer.addHexPrefix)
            .setFeePayerSignatures(feePayerSignList)
            .build()
        
        return feeDelegatedValueTransfer
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
            to,
            BigInt(hex: value)!,
            from,
            senderSignatureRLPList,
            feePayer,
            feePayerSignatureRLPList
        ]
        
        guard let encoded = Rlp.encode(rlpTypeList),
              var type = TransactionType.TxTypeFeeDelegatedValueTransfer.rawValue.hexa.hexData else { throw CaverError.invalidValue }
        type.append(encoded)
        let encodedStr = type.hexString
        return encodedStr
    }
    
    public override func getCommonRLPEncodingForSignature() throws -> String {
        try validateOptionalValues(true)
        
        let type = TransactionType.TxTypeFeeDelegatedValueTransfer.rawValue.hexa.hexData!
        
        let rlpTypeList: [Any] = [
            type,
            BigInt(hex: nonce)!,
            BigInt(hex: gasPrice)!,
            BigInt(hex: gas)!,
            to,
            BigInt(hex: value)!,
            from
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
            to,
            BigInt(hex: value)!,
            from,
            signatureRLPList
        ]
        
        guard let encoded = Rlp.encode(rlpTypeList),
              var type = TransactionType.TxTypeFeeDelegatedValueTransfer.rawValue.hexa.hexData else { throw CaverError.invalidValue }
        type.append(encoded)
        let encodedStr = type.keccak256.hexString
        return encodedStr
    }

    public override func compareTxField(_ txObj: AbstractFeeDelegatedTransaction, _ checkSig: Bool) -> Bool {
        if !super.compareTxField(txObj, checkSig) { return false }
        guard let txObj = txObj as? FeeDelegatedValueTransfer else { return false }
        if to.lowercased() != txObj.to.lowercased() { return false }
        if BigInt(hex: value) != BigInt(hex: txObj.value) { return false }
        
        return true
    }
    
    public func setValue(_ value: String) throws {
        if value.isEmpty {
            throw CaverError.IllegalArgumentException("value is missing.")
        }
        if !Utils.isNumber(value) {
            throw CaverError.IllegalArgumentException("Invalid value : \(value)")
        }
        self.value = value
    }
    
    public func setValue(_ value: BigInt) throws {
        try setValue(value.hexa)
    }
    
    public func setTo(_ to: String) throws {
        if to.isEmpty {
            throw CaverError.IllegalArgumentException("to is missing.")
        }
        if !Utils.isAddress(to) {
            throw CaverError.IllegalArgumentException("Invalid address. : \(to)")
        }
        self.to = to
    }
}
