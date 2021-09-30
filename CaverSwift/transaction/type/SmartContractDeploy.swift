//
//  SmartContractDeploy.swift
//  CaverSwift
//
//  Created by won on 2021/07/12.
//

import Foundation

open class SmartContractDeploy: AbstractTransaction {
    private(set) public var to = "0x"
    private(set) public var input = ""
    private(set) public var value = "0x00"
    private(set) public var humanReadable = false
    private(set) public var codeFormat = CodeFormat.EVM.hexa
    
    private enum CodingKeys: String, CodingKey {
        case to, input, value, humanReadable, codeFormat
    }
    
    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(to, forKey: .to)
        try container.encode(input, forKey: .input)
        try container.encode(value, forKey: .value)
        try container.encode(humanReadable, forKey: .humanReadable)
        try container.encode(codeFormat, forKey: .codeFormat)
    }
    
    public class Builder: AbstractTransaction.Builder {
        private(set) public var to = "0x"
        private(set) public var input = ""
        private(set) public var value = "0x00"
        private(set) public var humanReadable = false
        private(set) public var codeFormat = CodeFormat.EVM.hexa
        
        public init() {
            super.init(TransactionType.TxTypeSmartContractDeploy.string)
        }
        
        public override func build() throws -> SmartContractDeploy {
            return try SmartContractDeploy(self)
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
            return setCodeFormat(codeFormat.hexa)
        }
    }
    
    public init(_ builder: Builder) throws {
        try super.init(builder)
        try setTo(builder.to)
        try setValue(builder.value)
        try setInput(builder.input)
        try setHumanReadable(builder.humanReadable)
        try setCodeFormat(builder.codeFormat)
    }
    
    public init(_ klaytnCall: Klay?, _ from: String, _ nonce: String = "0x", _ gas: String, _ gasPrice: String = "0x", _ chainId: String = "0x", _ signatures: [SignatureData]?, _ to: String?, _ value: String, _ input: String, _ humanReadable: Bool, _ codeFormat: String) throws {
        try super.init(klaytnCall, TransactionType.TxTypeSmartContractDeploy.string, from, nonce, gas, gasPrice, chainId, signatures)
        try setTo(to ?? "0x")
        try setValue(value)
        try setInput(input)
        try setHumanReadable(humanReadable)
        try setCodeFormat(codeFormat)
    }
    
    public static func decode(_ rlpEncoded: String) throws -> SmartContractDeploy {
        guard let data = rlpEncoded.bytesFromHex else {
            throw CaverError.unexpectedReturnValue
        }
        return try decode(data)
    }
    
    public static func decode(_ rlpEncoded: [UInt8]) throws -> SmartContractDeploy {
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
              let humanReadableStr = values[7] as? String,
              let humanReadable = humanReadableStr.count == 0 ? false : Bool(humanReadableStr),
              let codeFormat = values[8] as? String,
              let senderSignatures = values[9] as? [[String]] else {
            throw CaverError.RuntimeException("There is an error while decoding process.")
        }
        
        let signatureDataList = SignatureData.decodeSignatures(senderSignatures)
        
        let smartContractDeploy = try SmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setGas(gas)
            .setTo(to.addHexPrefix)
            .setValue(BigInt(hex: value)!)
            .setFrom(from.addHexPrefix)
            .setInput(input.addHexPrefix)
            .setHumanReadable(humanReadable)
            .setCodeFormat(BigInt(hex: codeFormat)!)
            .setSignatures(signatureDataList)
            .build()

        return smartContractDeploy
    }
    
    public override func getRLPEncoding() throws -> String {
        try validateOptionalValues(false)
        
        let senderSignatureRLPList = signatures.map {
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
            senderSignatureRLPList
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
    
    public override func compareTxField(_ txObj: AbstractTransaction, _ checkSig: Bool) -> Bool {
        if !super.compareTxField(txObj, checkSig) { return false }
        guard let txObj = txObj as? SmartContractDeploy else { return false }
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
        self.input = input.addHexPrefix
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
