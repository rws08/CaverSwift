//
//  FeeDelegatedSmartContractDeploy.swift
//  CaverSwift
//
//  Created by won on 2021/07/13.
//

import Foundation

open class FeeDelegatedSmartContractDeploy: AbstractFeeDelegatedTransaction {
    private(set) public var to = "0x"
    private(set) public var input = ""
    private(set) public var value = "0x00"
    private(set) public var humanReadable = false
    private(set) public var codeFormat = CodeFormat.EVM.hexa
    
    public class Builder: AbstractFeeDelegatedTransaction.Builder {
        private(set) public var to = "0x"
        private(set) public var input = ""
        private(set) public var value = "0x00"
        private(set) public var humanReadable = false
        private(set) public var codeFormat = CodeFormat.EVM.hexa
        
        init() {
            super.init(TransactionType.TxTypeSmartContractDeploy.string)
        }
        
        public override func build() throws -> FeeDelegatedSmartContractDeploy {
            return try FeeDelegatedSmartContractDeploy(self)
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
        
        public func setHumanReadable(_ humanReadable: Bool) -> Self {
            self.humanReadable = humanReadable
            return self
        }
        
        public func setCodeFormat(_ codeFormat: String) -> Self {
            self.codeFormat = codeFormat
            return self
        }
        
        public func setCodeFormat(_ codeFormat: BigInt) -> Self {
            return setValue(codeFormat.hexa)
        }
    }
    
    init(_ builder: Builder) throws {
        try super.init(builder)
        try setTo(builder.to)
        try setValue(builder.value)
        try setInput(builder.input)
        try setHumanReadable(builder.humanReadable)
        try setCodeFormat(builder.codeFormat)
    }
    
    init(_ klaytnCall: Klay?, _ from: String, _ nonce: String = "0x", _ gas: String, _ gasPrice: String = "0x", _ chainId: String = "0x", _ signatures: [SignatureData]?, _ feePayer: String, _ feePayerSignatures:[SignatureData]?, _ to: String, _ value: String, _ input: String, _ humanReadable: Bool, _ codeFormat: String) throws {
        try super.init(klaytnCall, TransactionType.TxTypeSmartContractDeploy.string, from, nonce, gas, gasPrice, chainId, signatures, feePayer, feePayerSignatures)
        try setTo(to)
        try setValue(value)
        try setInput(input)
        try setHumanReadable(humanReadable)
        try setCodeFormat(codeFormat)
    }
    
    public static func decode(_ rlpEncoded: String) throws -> FeeDelegatedSmartContractDeploy {
        guard let data = rlpEncoded.bytesFromHex else {
            throw CaverError.unexpectedReturnValue
        }
        return try decode(data)
    }
    
    public static func decode(_ rlpEncoded: [UInt8]) throws -> FeeDelegatedSmartContractDeploy {
        if rlpEncoded[0] != TransactionType.TxTypeSmartContractDeploy.rawValue {
            throw CaverError.IllegalArgumentException("Invalid RLP-encoded tag - \(TransactionType.TxTypeSmartContractDeploy)")
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
              let humanReadable = values[7] as? String,
              let humanReadable = humanReadable.count == 0 ? false : Bool(humanReadable),
              let codeFormat = values[8] as? String,
              let senderSignatures = values[9] as? [[String]],
              let feePayer = values[10] as? String,
              let feePayerSignatures = values[11] as? [[String]] else {
            throw CaverError.RuntimeException("There is an error while decoding process.")
        }
        
        let senderSignList = SignatureData.decodeSignatures(senderSignatures)
        let feePayerSignList = SignatureData.decodeSignatures(feePayerSignatures)
        let feeDelegatedSmartContractDeploy = try FeeDelegatedSmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setGas(gas)
            .setTo(to)
            .setValue(BigInt(hex: value)!)
            .setFrom(from.addHexPrefix)
            .setInput(input.addHexPrefix)
            .setHumanReadable(humanReadable)
            .setCodeFormat(BigInt(hex: codeFormat)!)
            .setSignatures(senderSignList)
            .setFeePayer(feePayer.addHexPrefix)
            .setFeePayerSignatures(feePayerSignList)
            .build()
        
        return feeDelegatedSmartContractDeploy
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
            humanReadable ? 1 : 0,
            BigInt(hex: codeFormat)!,
            senderSignatureRLPList,
            feePayer,
            feePayerSignatureRLPList
        ]
        
        guard let encoded = Rlp.encode(rlpTypeList),
              var type = TransactionType.TxTypeSmartContractDeploy.rawValue.hexa.hexData else { throw CaverError.invalidValue }
        type.append(encoded)
        let encodedStr = type.hexString
        return encodedStr
    }
    
    public override func getCommonRLPEncodingForSignature() throws -> String {
        try validateOptionalValues(true)
        
        let type = TransactionType.TxTypeSmartContractDeploy.rawValue.hexa.hexData!
        
        let rlpTypeList: [Any] = [
            type,
            BigInt(hex: nonce)!,
            BigInt(hex: gasPrice)!,
            BigInt(hex: gas)!,
            to,
            BigInt(hex: value)!,
            from,
            input,
            humanReadable ? 1 : 0,
            BigInt(hex: codeFormat)!
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
            humanReadable ? 1 : 0,
            BigInt(hex: codeFormat)!,
            signatureRLPList
        ]
        
        guard let encoded = Rlp.encode(rlpTypeList),
              var type = TransactionType.TxTypeSmartContractDeploy.rawValue.hexa.hexData else { throw CaverError.invalidValue }
        type.append(encoded)
        let encodedStr = type.keccak256.hexString
        return encodedStr
    }

    public override func compareTxField(_ txObj: AbstractFeeDelegatedTransaction, _ checkSig: Bool) -> Bool {
        if !super.compareTxField(txObj, checkSig) { return false }
        guard let txObj = txObj as? FeeDelegatedSmartContractDeploy else { return false }
        if to.lowercased() != txObj.to.lowercased() { return false }
        if BigInt(hex: value) != BigInt(hex: txObj.value) { return false }
        if input != txObj.input { return false }
        if humanReadable != txObj.humanReadable { return false }
        if codeFormat != txObj.codeFormat { return false }
        
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
        var to = to
        if to.isEmpty {
            to = "0x"
        }
        if to != "0x" && !Utils.isAddress(to) {
            throw CaverError.IllegalArgumentException("'to' field must be nil('0x') : \(to)")
        }
        self.to = to
    }
    
    public func setHumanReadable(_ humanReadable: Bool) throws {
        if humanReadable {
            throw CaverError.IllegalArgumentException("HumanReadable attribute must set false")
        }
        self.humanReadable = false
    }
    
    public func setCodeFormat(_ codeFormat: String) throws {
        if codeFormat.isEmpty {
            throw CaverError.IllegalArgumentException("codeFormat is missing")
        }
        
        if BigInt(hex: codeFormat) != CodeFormat.EVM {
            throw CaverError.IllegalArgumentException("CodeFormat attribute only support EVM(0)")
        }
        self.codeFormat = codeFormat
    }
}
