//
//  ChainDataAnchoring.swift
//  CaverSwift
//
//  Created by won on 2021/07/12.
//

import Foundation

open class ChainDataAnchoring: AbstractTransaction {
    private(set) public var input: String?
    
    public class Builder: AbstractTransaction.Builder {
        private(set) public var input: String?
        
        init() {
            super.init(TransactionType.TxTypeChainDataAnchoring.string)
        }
        
        public override func build() throws -> ChainDataAnchoring {
            return try ChainDataAnchoring(self)
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
    
    init(_ klaytnCall: Klay?, _ from: String, _ nonce: String = "0x", _ gas: String, _ gasPrice: String = "0x", _ chainId: String = "0x", _ signatures: [SignatureData] = [], _ input: String) throws {
        try super.init(klaytnCall, TransactionType.TxTypeChainDataAnchoring.string, from, nonce, gas, gasPrice, chainId, signatures)
        try setInput(input)
    }
    
    public static func decode(_ rlpEncoded: String) throws -> ChainDataAnchoring {
        guard let data = rlpEncoded.bytesFromHex else {
            throw CaverError.unexpectedReturnValue
        }
        return try decode(data)
    }
    
    public static func decode(_ rlpEncoded: [UInt8]) throws -> ChainDataAnchoring {
        if rlpEncoded[0] != TransactionType.TxTypeChainDataAnchoring.rawValue {
            throw CaverError.IllegalArgumentException("Invalid RLP-encoded tag - \(TransactionType.TxTypeChainDataAnchoring)")
        }
        
        let rlpList = Rlp.decode(Array(rlpEncoded[1..<rlpEncoded.count]))
        guard let values = rlpList as? [Any],
              let nonce = values[0] as? String,
              let gasPrice = values[1] as? String,
              let gas = values[2] as? String,
              let from = values[3] as? String,
              let input = values[4] as? String,
              let senderSignatures = values[5] as? [[String]] else {
            throw CaverError.RuntimeException("There is an error while decoding process.")
        }
        
        let signatureDataList = SignatureData.decodeSignatures(senderSignatures)
        let chainDataAnchoring = try ChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setGas(gas)
            .setFrom(from)
            .setInput(input)
            .setSignatures(signatureDataList)
            .build()
        
        return chainDataAnchoring
    }
    
    public override func getRLPEncoding() throws -> String {
        guard let input = input else { throw CaverError.invalidValue }
        try validateOptionalValues(false)
        
        let signatureRLPList = signatures.map {
            $0.toRlpList()
        }
        
        let rlpTypeList: [Any] = [
            nonce,
            gasPrice,
            gas,
            from,
            input,
            signatureRLPList
        ]
        
        guard let encoded = Rlp.encode(rlpTypeList),
              var type = TransactionType.TxTypeChainDataAnchoring.string.hexData else { throw CaverError.invalidValue }
        type.append(encoded)
        let encodedStr = type.hexString
        return encodedStr
    }
    
    public override func getCommonRLPEncodingForSignature() throws -> String {
        guard let input = input else { throw CaverError.invalidValue }
        
        try validateOptionalValues(true)
        
        let type = TransactionType.TxTypeChainDataAnchoring.string
        
        let rlpTypeList: [Any] = [
            type,
            nonce,
            gasPrice,
            gas,
            from,
            input
        ]

        guard let encoded = Rlp.encode(rlpTypeList) else { throw CaverError.invalidValue }
        let encodedStr = encoded.hexString
        return encodedStr
    }

    public override func compareTxField(_ txObj: AbstractTransaction, _ checkSig: Bool) -> Bool {
        if !super.compareTxField(txObj, checkSig) { return false }
        guard let txObj = txObj as? ChainDataAnchoring else { return false }
        if input != txObj.input { return false }
        
        return true
    }
    
    public func setInput(_ input: String?) throws {
        guard let input = input else {
            throw CaverError.IllegalArgumentException("input is missing.")
        }
        if !Utils.isHex(input) {
            throw CaverError.IllegalArgumentException("Invalid input : \(input)")
        }
        
        self.input = input
    }
}
