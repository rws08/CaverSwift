//
//  LegacyTransaction.swift
//  CaverSwift
//
//  Created by won on 2021/07/09.
//

import Foundation

open class LegacyTransaction: AbstractTransaction {
    private(set) public var to = "0x"
    private(set) public var input = "0x"
    private(set) public var value = ""
    
    public class Builder: AbstractTransaction.Builder {
        public var to = "0x"
        public var input = "0x"
        public var value = ""
        
        init() {
            super.init(TransactionType.TxTypeLegacyTransaction.string)
        }
        
        public override func build() throws -> LegacyTransaction {
            return try LegacyTransaction(self)
        }
        
        public func setValue(_ value: String) -> Self {
            self.value = value
            return self
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
    
    init(_ klaytnCall: Klay?, _ from: String, _ nonce: String = "0x", _ gas: String, _ gasPrice: String = "0x", _ chainId: String = "0x", _ signatures: [SignatureData]?, _ to: String, _ input: String, _ value: String) throws {
        try super.init(klaytnCall, TransactionType.TxTypeLegacyTransaction.string, from, nonce, gas, gasPrice, chainId, signatures)
        try setTo(to)
        try setValue(value)
        try setInput(input)
    }
    
    public static func decode(_ rlpEncoded: String) throws -> LegacyTransaction {
        guard let data = rlpEncoded.bytesFromHex else {
            throw CaverError.unexpectedReturnValue
        }
        return try decode(data)
    }
    
    public static func decode(_ rlpEncoded: [UInt8]) throws -> LegacyTransaction {
        guard let values = Rlp.decode(rlpEncoded) as? [Any],
              let nonce = values[0] as? String,
              let gasPrice = values[1] as? String,
              let gas = values[2] as? String,
              let to = values[3] as? String,
              let value = values[4] as? String,
              let input = values[5] as? String else {
            throw CaverError.RuntimeException("There is an error while decoding process.")
        }
        
        let legacyTransaction = try LegacyTransaction.Builder()            
            .setInput(input.addHexPrefix)
            .setValue(value.addHexPrefix)
            .setTo(to.addHexPrefix)
            .setNonce(nonce.addHexPrefix)
            .setGas(gas.addHexPrefix)
            .setGasPrice(gasPrice.addHexPrefix)
            .build()
        
        guard let v = values[6] as? String,
              let r = values[7] as? String,
              let s = values[8] as? String else {
            throw CaverError.RuntimeException("There is an error while decoding process.")
        }
        
        let signatureData = SignatureData(v, r, s)
        try legacyTransaction.appendSignatures(signatureData)
        return legacyTransaction
    }
    
    public override func appendSignatures(_ signatureData: SignatureData) throws {
        if !signatures.isEmpty && !Utils.isEmptySig(signatures[0]) {
            throw CaverError.RuntimeException("Signatures already defined. \(TransactionType.TxTypeLegacyTransaction.string) cannot include more than one signature.")
        }
        try super.appendSignatures(signatureData)
    }
    
    public override func appendSignatures(_ signatureDataList: [SignatureData]) throws {
        if !signatures.isEmpty && !Utils.isEmptySig(signatures[0]) {
            throw CaverError.RuntimeException("Signatures already defined. \(TransactionType.TxTypeLegacyTransaction.string) cannot include more than one signature.")
        }
        
        if signatureDataList.count != 1 {
            throw CaverError.RuntimeException("Signatures are too long \(TransactionType.TxTypeLegacyTransaction.string) cannot include more than one signature.")
        }
        try super.appendSignatures(signatureDataList)
    }
    
    public override func getRLPEncoding() throws -> String {
        try validateOptionalValues(false)
        
        var rlpTypeList: [Any] = [
            nonce,
            gasPrice,
            gas,
            to,
            value,
            input
        ]
        rlpTypeList.append(contentsOf: signatures[0].toRlpList())
        
        guard let encoded = Rlp.encode(rlpTypeList) else { throw CaverError.invalidValue }
        let encodedStr = encoded.hexString
        return encodedStr
    }
    
    public override func getRLPEncodingForSignature() throws -> String {
        return try getRLPEncodingForSignature()
    }
    
    public override func getCommonRLPEncodingForSignature() throws -> String {
        try validateOptionalValues(false)
        
        let rlpTypeList: [Any] = [
            nonce,
            gasPrice,
            gas,
            to,
            value,
            input,
            chainId,
            0,
            0
        ]
        
        guard let encoded = Rlp.encode(rlpTypeList) else { throw CaverError.invalidValue }
        let encodedStr = encoded.hexString
        return encodedStr
    }
    
    public override func compareTxField(_ txObj: AbstractTransaction, _ checkSig: Bool) -> Bool {
        if !super.compareTxField(txObj, checkSig) { return false }
        guard let txObj = txObj as? LegacyTransaction else { return false }
        if to.lowercased() != txObj.to.lowercased() { return false }
        if BigInt(hex: value) != BigInt(hex: txObj.value) { return false }
        if input != txObj.input { return false }
        
        return true
    }
    
    public func setValue(_ value: String) throws {
        if !Utils.isNumber(value) {
            throw CaverError.IllegalArgumentException("Invalid value : \(value)")
        }
        self.value = value
    }
    
    public func setInput(_ input: String) throws {
        if !Utils.isHex(input) {
            throw CaverError.IllegalArgumentException("Invalid input : \(input)")
        }
        self.input = input
    }
    
    public func setTo(_ to: String) throws {
        var to = to
        if to.isEmpty {
            to = "0x"
        }
        if to != "0x" && !Utils.isAddress(to) {
            throw CaverError.IllegalArgumentException("Invalid address. : \(to)")
        }
        self.to = to
    }
}
