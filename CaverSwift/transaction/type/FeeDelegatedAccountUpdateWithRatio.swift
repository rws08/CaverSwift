//
//  FeeDelegatedAccountUpdateWithRatio.swift
//  CaverSwift
//
//  Created by won on 2021/07/12.
//

import Foundation

open class FeeDelegatedAccountUpdateWithRatio: AbstractFeeDelegatedWithRatioTransaction {
    private(set) public var account: Account?
    
    public class Builder: AbstractFeeDelegatedWithRatioTransaction.Builder {
        private(set) public var account: Account?
        
        public init() {
            super.init(TransactionType.TxTypeFeeDelegatedAccountUpdate.string)
        }
        public override func build() throws -> FeeDelegatedAccountUpdateWithRatio {
            return try FeeDelegatedAccountUpdateWithRatio(self)
        }
        
        public func setAccount(_ account: Account?) -> Self {
            self.account = account
            return self
        }
    }
    
    public init(_ builder: Builder) throws {
        try super.init(builder)
        try setAccount(builder.account)
    }
    
    public init(_ klaytnCall: Klay?, _ from: String, _ nonce: String = "0x", _ gas: String, _ gasPrice: String = "0x", _ chainId: String = "0x", _ signatures: [SignatureData]?, _ feePayer: String, _ feePayerSignatures: [SignatureData]?, _ feeRatio: String, _ account: Account?) throws {
        try super.init(klaytnCall, TransactionType.TxTypeFeeDelegatedAccountUpdateWithRatio.string, from, nonce, gas, gasPrice, chainId, signatures, feePayer, feePayerSignatures, feeRatio)
        try setAccount(account)
    }
    
    public static func decode(_ rlpEncoded: String) throws -> FeeDelegatedAccountUpdateWithRatio {
        guard let data = rlpEncoded.bytesFromHex else {
            throw CaverError.unexpectedReturnValue
        }
        return try decode(data)
    }
    
    public static func decode(_ rlpEncoded: [UInt8]) throws -> FeeDelegatedAccountUpdateWithRatio {
        if rlpEncoded[0] != TransactionType.TxTypeFeeDelegatedAccountUpdateWithRatio.rawValue {
            throw CaverError.IllegalArgumentException("Invalid RLP-encoded tag - \(TransactionType.TxTypeFeeDelegatedAccountUpdateWithRatio)")
        }
        
        let rlpList = Rlp.decode(Array(rlpEncoded[1..<rlpEncoded.count]))
        guard let values = rlpList as? [Any],
              let nonce = values[0] as? String,
              let gasPrice = values[1] as? String,
              let gas = values[2] as? String,
              let from = values[3] as? String,
              let accountStr = values[4] as? String,
              let account = try? Account.createFromRLPEncoding(from, accountStr),
              let feeRatio = values[5] as? String,
              let senderSignatures = values[6] as? [[String]],
              let feePayer = values[7] as? String,
              let feePayerSignatures = values[8] as? [[String]] else {
            throw CaverError.RuntimeException("There is an error while decoding process.")
        }
        
        let senderSignList = SignatureData.decodeSignatures(senderSignatures)
        let feePayerSignList = SignatureData.decodeSignatures(feePayerSignatures)
        let feeDelegatedAccountUpdateWithRatio = try FeeDelegatedAccountUpdateWithRatio.Builder()
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setGas(gas)
            .setFrom(from.addHexPrefix)
            .setAccount(account)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignList)
            .setFeePayer(feePayer.addHexPrefix)
            .setFeePayerSignatures(feePayerSignList)
            .build()
        
        return feeDelegatedAccountUpdateWithRatio
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
            BigInt(hex: feeRatio)!,
            senderSignatureRLPList,
            feePayer,
            feePayerSignatureRLPList
        ]
        
        guard let encoded = Rlp.encode(rlpTypeList),
              var type = TransactionType.TxTypeFeeDelegatedAccountUpdateWithRatio.rawValue.hexa.hexData else { throw CaverError.invalidValue }
        type.append(encoded)
        let encodedStr = type.hexString
        return encodedStr
    }
    
    public override func getCommonRLPEncodingForSignature() throws -> String {
        guard let account = account else { throw CaverError.invalidValue }
        
        try validateOptionalValues(true)
        
        let type = TransactionType.TxTypeFeeDelegatedAccountUpdateWithRatio.rawValue.hexa.hexData!
        
        let rlpTypeList: [Any] = [
            type,
            BigInt(hex: nonce)!,
            BigInt(hex: gasPrice)!,
            BigInt(hex: gas)!,
            from,
            try account.getRLPEncodingAccountKey(),
            BigInt(hex: feeRatio)!
        ]

        guard let encoded = Rlp.encode(rlpTypeList) else { throw CaverError.invalidValue }
        let encodedStr = encoded.hexString
        return encodedStr
    }
    
    public override func getSenderTxHash() throws -> String {
        guard let account = account else { throw CaverError.invalidValue }
        
        try validateOptionalValues(false)
        
        let signatureRLPList = signatures.map {
            $0.toRlpList()
        }
        
        let rlpTypeList: [Any] = [
            BigInt(hex: nonce)!,
            BigInt(hex: gasPrice)!,
            BigInt(hex: gas)!,
            from,
            try account.getRLPEncodingAccountKey(),
            BigInt(hex: feeRatio)!,
            signatureRLPList
        ]
        
        guard let encoded = Rlp.encode(rlpTypeList),
              var type = TransactionType.TxTypeFeeDelegatedAccountUpdateWithRatio.rawValue.hexa.hexData else { throw CaverError.invalidValue }
        type.append(encoded)
        let encodedStr = type.keccak256.hexString
        return encodedStr
    }

    public override func compareTxField(_ txObj: AbstractFeeDelegatedWithRatioTransaction, _ checkSig: Bool) -> Bool {
        if !super.compareTxField(txObj, checkSig) { return false }
        guard let txObj = txObj as? FeeDelegatedAccountUpdateWithRatio else { return false }
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
