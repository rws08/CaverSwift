//
//  Cancel.swift
//  CaverSwift
//
//  Created by won on 2021/07/09.
//

import Foundation

open class Cancel: AbstractTransaction {
    public class Builder: AbstractTransaction.Builder {
        init() {
            super.init(TransactionType.TxTypeCancel.string)
        }
        public override func build() throws -> Cancel {
            return try Cancel(self)
        }
    }
    
    init(_ builder: Builder) throws {
        try super.init(builder)
    }
    
    init(_ klaytnCall: Klay?, _ from: String, _ nonce: String = "0x", _ gas: String, _ gasPrice: String = "0x", _ chainId: String = "0x", _ signatures: [SignatureData] = []) throws {
        try super.init(klaytnCall, TransactionType.TxTypeCancel.string, from, nonce, gas, gasPrice, chainId, signatures)
    }
    
    public static func decode(_ rlpEncoded: String) throws -> Cancel {
        guard let data = rlpEncoded.bytesFromHex else {
            throw CaverError.unexpectedReturnValue
        }
        return try decode(data)
    }
    
    public static func decode(_ rlpEncoded: [UInt8]) throws -> Cancel {
        if rlpEncoded[0] != TransactionType.TxTypeCancel.rawValue {
            throw CaverError.IllegalArgumentException("Invalid RLP-encoded tag - \(TransactionType.TxTypeCancel)")
        }
        
        let rlpList = Rlp.decode(Array(rlpEncoded[1..<rlpEncoded.count]))
        guard let values = rlpList as? [Any],
              let nonce = values[0] as? String,
              let gasPrice = values[1] as? String,
              let gas = values[2] as? String,
              let from = values[3] as? String,
              let senderSignatures = values[4] as? [[String]] else {
            throw CaverError.RuntimeException("There is an error while decoding process.")
        }
        
        let signatureDataList = SignatureData.decodeSignatures(senderSignatures)
        let cancel = try Cancel.Builder()
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setGas(gas)
            .setFrom(from)
            .setSignatures(signatureDataList)
            .build()
        
        return cancel
    }
    
    public override func getRLPEncoding() throws -> String {        
        try validateOptionalValues(false)
        
        let signatureRLPList = signatures.map {
            $0.toRlpList()
        }
        
        let rlpTypeList: [Any] = [
            nonce,
            gasPrice,
            gas,
            from,
            signatureRLPList
        ]
        
        guard let encoded = Rlp.encode(rlpTypeList),
              var type = TransactionType.TxTypeCancel.string.hexData else { throw CaverError.invalidValue }
        type.append(encoded)
        let encodedStr = type.hexString
        return encodedStr
    }
    
    public override func getCommonRLPEncodingForSignature() throws -> String {
        try validateOptionalValues(true)
        
        let type = TransactionType.TxTypeCancel.string
        
        let rlpTypeList: [Any] = [
            type,
            nonce,
            gasPrice,
            gas,
            from
        ]

        guard let encoded = Rlp.encode(rlpTypeList) else { throw CaverError.invalidValue }
        let encodedStr = encoded.hexString
        return encodedStr
    }

    public override func compareTxField(_ txObj: AbstractTransaction, _ checkSig: Bool) -> Bool {
        if !super.compareTxField(txObj, checkSig) { return false }
        guard txObj is Cancel else { return false }
                
        return true
    }
}
