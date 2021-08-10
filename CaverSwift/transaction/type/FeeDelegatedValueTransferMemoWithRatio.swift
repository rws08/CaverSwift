//
//  FeeDelegatedValueTransferMemoWithRatio.swift
//  CaverSwift
//
//  Created by won on 2021/07/13.
//

import Foundation

open class FeeDelegatedValueTransferMemoWithRatio: AbstractFeeDelegatedWithRatioTransaction {
    private(set) public var to = ""
    private(set) public var input = ""
    private(set) public var value = ""
    
    private enum CodingKeys: String, CodingKey {
        case to, input, value
    }
    
    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(to, forKey: .to)
        try container.encode(input, forKey: .input)
        try container.encode(value, forKey: .value)
    }
    
    public class Builder: AbstractFeeDelegatedWithRatioTransaction.Builder {
        private(set) public var to = ""
        private(set) public var input = ""
        private(set) public var value = ""
        
        init() {
            super.init(TransactionType.TxTypeFeeDelegatedValueTransferMemoWithRatio.string)
        }
        
        public override func build() throws -> FeeDelegatedValueTransferMemoWithRatio {
            return try FeeDelegatedValueTransferMemoWithRatio(self)
        }
        
        public func setValue(_ value: String) -> Self {
            self.value = value
            return self
        }
        
        public func setValue(_ value: BigInt) -> Self {
            return setValue(value.hexa)
        }
        
        public func setInput(_ input: String) -> Self {
            self.input = input
            return self
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
        try setInput(builder.input)
    }
    
    init(_ klaytnCall: Klay?, _ from: String, _ nonce: String = "0x", _ gas: String, _ gasPrice: String = "0x", _ chainId: String = "0x", _ signatures: [SignatureData]?, _ feePayer: String, _ feePayerSignatures:[SignatureData]?, _ feeRatio: String, _ to: String, _ value: String, _ input: String) throws {
        try super.init(klaytnCall, TransactionType.TxTypeFeeDelegatedValueTransferMemoWithRatio.string, from, nonce, gas, gasPrice, chainId, signatures, feePayer, feePayerSignatures, feeRatio)
        try setTo(to)
        try setValue(value)
        try setInput(input)
    }
    
    public static func decode(_ rlpEncoded: String) throws -> FeeDelegatedValueTransferMemoWithRatio {
        guard let data = rlpEncoded.bytesFromHex else {
            throw CaverError.unexpectedReturnValue
        }
        return try decode(data)
    }
    
    public static func decode(_ rlpEncoded: [UInt8]) throws -> FeeDelegatedValueTransferMemoWithRatio {
        if rlpEncoded[0] != TransactionType.TxTypeFeeDelegatedValueTransferMemoWithRatio.rawValue {
            throw CaverError.IllegalArgumentException("Invalid RLP-encoded tag - \(TransactionType.TxTypeFeeDelegatedValueTransferMemoWithRatio)")
        }
        
        let rlpList = Rlp.decode(Array(rlpEncoded[1..<rlpEncoded.count]))
        guard let values = rlpList as? [Any],
              let nonce = values[0] as? String,
              let gasPrice = values[1] as? String,
              let gas = values[2] as? String,
              let to = values[3] as? String,
              let value = values[4] as? String,
              let from = values[5] as? String,
              let input = values[6] as? String,
              let feeRatio = values[7] as? String,
              let senderSignatures = values[8] as? [[String]],
              let feePayer = values[9] as? String,
              let feePayerSignatures = values[10] as? [[String]] else {
            throw CaverError.RuntimeException("There is an error while decoding process.")
        }
        
        let senderSignList = SignatureData.decodeSignatures(senderSignatures)
        let feePayerSignList = SignatureData.decodeSignatures(feePayerSignatures)
        let feeDelegatedValueTransferMemoWithRatio = try FeeDelegatedValueTransferMemoWithRatio.Builder()
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setGas(gas)
            .setTo(to.addHexPrefix)
            .setValue(BigInt(hex: value)!)
            .setFrom(from.addHexPrefix)
            .setFeeRatio(feeRatio)
            .setInput(input.addHexPrefix)
            .setSignatures(senderSignList)
            .setFeePayer(feePayer.addHexPrefix)
            .setFeePayerSignatures(feePayerSignList)
            .build()
        
        return feeDelegatedValueTransferMemoWithRatio
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
            input,
            BigInt(hex: feeRatio)!,
            senderSignatureRLPList,
            feePayer,
            feePayerSignatureRLPList
        ]
        
        guard let encoded = Rlp.encode(rlpTypeList),
              var type = TransactionType.TxTypeFeeDelegatedValueTransferMemoWithRatio.rawValue.hexa.hexData else { throw CaverError.invalidValue }
        type.append(encoded)
        let encodedStr = type.hexString
        return encodedStr
    }
    
    public override func getCommonRLPEncodingForSignature() throws -> String {
        try validateOptionalValues(true)
        
        let type = TransactionType.TxTypeFeeDelegatedValueTransferMemoWithRatio.rawValue.hexa.hexData!
        
        let rlpTypeList: [Any] = [
            type,
            BigInt(hex: nonce)!,
            BigInt(hex: gasPrice)!,
            BigInt(hex: gas)!,
            to,
            BigInt(hex: value)!,
            from,
            input,
            BigInt(hex: feeRatio)!,
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
            input,
            BigInt(hex: feeRatio)!,
            signatureRLPList
        ]
        
        guard let encoded = Rlp.encode(rlpTypeList),
              var type = TransactionType.TxTypeFeeDelegatedValueTransferMemoWithRatio.rawValue.hexa.hexData else { throw CaverError.invalidValue }
        type.append(encoded)
        let encodedStr = type.keccak256.hexString
        return encodedStr
    }

    public override func compareTxField(_ txObj: AbstractFeeDelegatedWithRatioTransaction, _ checkSig: Bool) -> Bool {
        if !super.compareTxField(txObj, checkSig) { return false }
        guard let txObj = txObj as? FeeDelegatedValueTransferMemoWithRatio else { return false }
        if to.lowercased() != txObj.to.lowercased() { return false }
        if BigInt(hex: value) != BigInt(hex: txObj.value) { return false }
        if input != txObj.input { return false }
        
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
    
    public func setInput(_ input: String) throws {
        if input.isEmpty {
            throw CaverError.IllegalArgumentException("input is missing.")
        }
        if !Utils.isHex(input) {
            throw CaverError.IllegalArgumentException("Invalid input. : \(input)")
        }
        self.input = input.addHexPrefix
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
