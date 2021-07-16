//
//  FeeDelegatedSmartContractExecution.swift
//  CaverSwift
//
//  Created by won on 2021/07/13.
//

import Foundation

open class FeeDelegatedSmartContractExecution: AbstractFeeDelegatedTransaction {
    private(set) public var to = ""
    private(set) public var input = ""
    private(set) public var value = "0x00"
    
    public class Builder: AbstractFeeDelegatedTransaction.Builder {
        private(set) public var to = ""
        private(set) public var input = ""
        private(set) public var value = "0x00"
        
        init() {
            super.init(TransactionType.TxTypeFeeDelegatedSmartContractExecution.string)
        }
        
        public override func build() throws -> FeeDelegatedSmartContractExecution {
            return try FeeDelegatedSmartContractExecution(self)
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
    
    init(_ klaytnCall: Klay?, _ from: String, _ nonce: String = "0x", _ gas: String, _ gasPrice: String = "0x", _ chainId: String = "0x", _ signatures: [SignatureData]?, _ feePayer: String, _ feePayerSignatures:[SignatureData]?, _ to: String, _ value: String, _ input: String) throws {
        try super.init(klaytnCall, TransactionType.TxTypeFeeDelegatedSmartContractExecution.string, from, nonce, gas, gasPrice, chainId, signatures, feePayer, feePayerSignatures)
        try setTo(to)
        try setValue(value)
        try setInput(input)
    }
    
    public static func decode(_ rlpEncoded: String) throws -> FeeDelegatedSmartContractExecution {
        guard let data = rlpEncoded.bytesFromHex else {
            throw CaverError.unexpectedReturnValue
        }
        return try decode(data)
    }
    
    public static func decode(_ rlpEncoded: [UInt8]) throws -> FeeDelegatedSmartContractExecution {
        if rlpEncoded[0] != TransactionType.TxTypeFeeDelegatedSmartContractExecution.rawValue {
            throw CaverError.IllegalArgumentException("Invalid RLP-encoded tag - \(TransactionType.TxTypeFeeDelegatedSmartContractExecution)")
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
              let senderSignatures = values[7] as? [[String]],
              let feePayer = values[8] as? String,
              let feePayerSignatures = values[9] as? [[String]] else {
            throw CaverError.RuntimeException("There is an error while decoding process.")
        }
        
        let senderSignList = SignatureData.decodeSignatures(senderSignatures)
        let feePayerSignList = SignatureData.decodeSignatures(feePayerSignatures)
        let feeDelegatedSmartContractExecution = try FeeDelegatedSmartContractExecution.Builder()
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setGas(gas)
            .setTo(to.addHexPrefix)
            .setValue(BigInt(hex: value)!)
            .setFrom(from.addHexPrefix)
            .setInput(input.addHexPrefix)
            .setSignatures(senderSignList)
            .setFeePayer(feePayer.addHexPrefix)
            .setFeePayerSignatures(feePayerSignList)
            .build()
        
        return feeDelegatedSmartContractExecution
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
            senderSignatureRLPList,
            feePayer,
            feePayerSignatureRLPList
        ]
        
        guard let encoded = Rlp.encode(rlpTypeList),
              var type = TransactionType.TxTypeFeeDelegatedSmartContractExecution.rawValue.hexa.hexData else { throw CaverError.invalidValue }
        type.append(encoded)
        let encodedStr = type.hexString
        return encodedStr
    }
    
    public override func getCommonRLPEncodingForSignature() throws -> String {
        try validateOptionalValues(true)
        
        let type = TransactionType.TxTypeFeeDelegatedSmartContractExecution.rawValue.hexa.hexData!
        
        let rlpTypeList: [Any] = [
            type,
            BigInt(hex: nonce)!,
            BigInt(hex: gasPrice)!,
            BigInt(hex: gas)!,
            to,
            BigInt(hex: value)!,
            from,
            input
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
            signatureRLPList
        ]
        
        guard let encoded = Rlp.encode(rlpTypeList),
              var type = TransactionType.TxTypeFeeDelegatedSmartContractExecution.rawValue.hexa.hexData else { throw CaverError.invalidValue }
        type.append(encoded)
        let encodedStr = type.keccak256.hexString
        return encodedStr
    }

    public override func compareTxField(_ txObj: AbstractFeeDelegatedTransaction, _ checkSig: Bool) -> Bool {
        if !super.compareTxField(txObj, checkSig) { return false }
        guard let txObj = txObj as? FeeDelegatedSmartContractExecution else { return false }
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
        self.input = input
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
