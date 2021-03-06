//
//  FeeDelegatedAccountUpdate.swift
//  CaverSwift
//
//  Created by won on 2021/07/12.
//

import Foundation

open class FeeDelegatedAccountUpdate: AbstractFeeDelegatedTransaction {
    private(set) public var account: Account?
    
    public class Builder: AbstractFeeDelegatedTransaction.Builder {
        private(set) public var account: Account?
        
        init() {
            super.init(TransactionType.TxTypeFeeDelegatedAccountUpdate.string)
        }
        public override func build() throws -> FeeDelegatedAccountUpdate {
            return try FeeDelegatedAccountUpdate(self)
        }
        
        public func setAccount(_ account: Account?) -> Self {
            self.account = account
            return self
        }
    }
    
    init(_ builder: Builder) throws {
        try super.init(builder)
        try setAccount(builder.account)
    }
    
    init(_ klaytnCall: Klay?, _ from: String, _ nonce: String = "0x", _ gas: String, _ gasPrice: String = "0x", _ chainId: String = "0x", _ signatures: [SignatureData]?, _ feePayer: String, _ feePayerSignatures:[SignatureData]?, _ account: Account?) throws {
        try super.init(klaytnCall, TransactionType.TxTypeFeeDelegatedAccountUpdate.string, from, nonce, gas, gasPrice, chainId, signatures, feePayer, feePayerSignatures)
        try setAccount(account)
    }
    
    public static func decode(_ rlpEncoded: String) throws -> FeeDelegatedAccountUpdate {
        guard let data = rlpEncoded.bytesFromHex else {
            throw CaverError.unexpectedReturnValue
        }
        return try decode(data)
    }
    
    public static func decode(_ rlpEncoded: [UInt8]) throws -> FeeDelegatedAccountUpdate {
        if rlpEncoded[0] != TransactionType.TxTypeFeeDelegatedAccountUpdate.rawValue {
            throw CaverError.IllegalArgumentException("Invalid RLP-encoded tag - \(TransactionType.TxTypeFeeDelegatedAccountUpdate)")
        }
        
        let rlpList = Rlp.decode(Array(rlpEncoded[1..<rlpEncoded.count]))
        guard let values = rlpList as? [Any],
              let nonce = values[0] as? String,
              let gasPrice = values[1] as? String,
              let gas = values[2] as? String,
              let from = values[3] as? String,
              let account = values[4] as? String,
              let account = try? Account.createFromRLPEncoding(from, account),
              let senderSignatures = values[5] as? [[String]],
              let feePayer = values[6] as? String,
              let feePayerSignatures = values[7] as? [[String]] else {
            throw CaverError.RuntimeException("There is an error while decoding process.")
        }
        
        let senderSignList = SignatureData.decodeSignatures(senderSignatures)
        let feePayerSignList = SignatureData.decodeSignatures(feePayerSignatures)
        let feeDelegatedAccountUpdate = try FeeDelegatedAccountUpdate.Builder()
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setGas(gas)
            .setFrom(from.addHexPrefix)
            .setAccount(account)
            .setSignatures(senderSignList)
            .setFeePayer(feePayer.addHexPrefix)
            .setFeePayerSignatures(feePayerSignList)
            .build()
        
        return feeDelegatedAccountUpdate
    }
    
    public override func getRLPEncoding() throws -> String {
        guard let account = account else { throw CaverError.invalidValue }
        
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
            try account.getRLPEncodingAccountKey(),
            senderSignatureRLPList,
            feePayer,
            feePayerSignatureRLPList
        ]
        
        guard let encoded = Rlp.encode(rlpTypeList),
              var type = TransactionType.TxTypeFeeDelegatedAccountUpdate.rawValue.hexa.hexData else { throw CaverError.invalidValue }
        type.append(encoded)
        let encodedStr = type.hexString
        return encodedStr
    }
    
    public override func getCommonRLPEncodingForSignature() throws -> String {
        guard let account = account else { throw CaverError.invalidValue }
        
        try validateOptionalValues(true)
        
        let type = TransactionType.TxTypeFeeDelegatedAccountUpdate.rawValue.hexa.hexData!
        
        let rlpTypeList: [Any] = [
            type,
            BigInt(hex: nonce)!,
            BigInt(hex: gasPrice)!,
            BigInt(hex: gas)!,
            from,
            try account.getRLPEncodingAccountKey()
        ]

        guard let encoded = Rlp.encode(rlpTypeList) else { throw CaverError.invalidValue }
        let encodedStr = encoded.hexString
        return encodedStr
    }
    
    public override func getSenderTxHash() throws -> String {
        guard let account = account else { throw CaverError.invalidValue }
        
        try validateOptionalValues(false)
                
        let senderSignatureRLPList = signatures.map {
            $0.toRlpList()
        }
        
        let rlpTypeList: [Any] = [
            BigInt(hex: nonce)!,
            BigInt(hex: gasPrice)!,
            BigInt(hex: gas)!,
            from,
            try account.getRLPEncodingAccountKey(),
            senderSignatureRLPList
        ]
        
        guard let encoded = Rlp.encode(rlpTypeList),
              var type = TransactionType.TxTypeFeeDelegatedAccountUpdate.rawValue.hexa.hexData else { throw CaverError.invalidValue }
        type.append(encoded)
        let encodedStr = type.keccak256.hexString
        return encodedStr
    }

    public override func compareTxField(_ txObj: AbstractTransaction, _ checkSig: Bool) -> Bool {
        if !super.compareTxField(txObj, checkSig) { return false }
        guard let txObj = txObj as? FeeDelegatedAccountUpdate else { return false }
        if account?.address.lowercased() != txObj.account?.address.lowercased() { return false }
        if (try? account?.getRLPEncodingAccountKey()) != (try? txObj.account?.getRLPEncodingAccountKey()) { return false }
        
        return true
    }
    
    public func setAccount(_ account: Account?) throws {
        guard let account = account else {
            throw CaverError.IllegalArgumentException("account is missing.")
        }
        if from.lowercased() != account.address.lowercased() {
            throw CaverError.IllegalArgumentException("Transaction's 'from' address and 'account address' do not match.")
        }
        
        self.account = account
    }
}
