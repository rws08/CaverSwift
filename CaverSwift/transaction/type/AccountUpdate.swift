//
//  AccountUpdate.swift
//  CaverSwift
//
//  Created by won on 2021/07/12.
//

import Foundation

open class AccountUpdate: AbstractTransaction {
    private(set) public var account: Account?
    
    public class Builder: AbstractTransaction.Builder {
        private(set) public var account: Account?
        
        public init() {
            super.init(TransactionType.TxTypeAccountUpdate.string)
        }
        public override func build() throws -> AccountUpdate {
            return try AccountUpdate(self)
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
    
    public init(_ klaytnCall: Klay?, _ from: String, _ nonce: String = "0x", _ gas: String, _ gasPrice: String = "0x", _ chainId: String = "0x", _ signatures: [SignatureData]?, _ account: Account) throws {
        try super.init(klaytnCall, TransactionType.TxTypeAccountUpdate.string, from, nonce, gas, gasPrice, chainId, signatures)
        try setAccount(account)
    }    
    
    public static func decode(_ rlpEncoded: String) throws -> AccountUpdate {
        guard let data = rlpEncoded.bytesFromHex else {
            throw CaverError.unexpectedReturnValue
        }
        return try decode(data)
    }
    
    public static func decode(_ rlpEncoded: [UInt8]) throws -> AccountUpdate {
        if rlpEncoded[0] != TransactionType.TxTypeAccountUpdate.rawValue {
            throw CaverError.IllegalArgumentException("Invalid RLP-encoded tag - \(TransactionType.TxTypeAccountUpdate)")
        }
        
        let rlpList = Rlp.decode(Array(rlpEncoded[1..<rlpEncoded.count]))
        guard let values = rlpList as? [Any],
              let nonce = values[0] as? String,
              let gasPrice = values[1] as? String,
              let gas = values[2] as? String,
              let from = values[3] as? String,
              let accountStr = values[4] as? String,
              let account = try? Account.createFromRLPEncoding(from, accountStr),
              let senderSignatures = values[5] as? [[String]] else {
            throw CaverError.RuntimeException("There is an error while decoding process.")
        }
        
        let signatureDataList = SignatureData.decodeSignatures(senderSignatures)
        let accountUpdate = try AccountUpdate.Builder()
            .setAccount(account)
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setGas(gas)
            .setFrom(from.addHexPrefix)
            .setSignatures(signatureDataList)
            .build()
        
        return accountUpdate
    }
    
    public override func getRLPEncoding() throws -> String {
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
            signatureRLPList
        ]
        
        guard let encoded = Rlp.encode(rlpTypeList),
              var type = TransactionType.TxTypeAccountUpdate.rawValue.hexa.hexData else { throw CaverError.invalidValue }
        type.append(encoded)
        let encodedStr = type.hexString
        return encodedStr
    }
    
    public override func getCommonRLPEncodingForSignature() throws -> String {
        guard let account = account else { throw CaverError.invalidValue }
        
        try validateOptionalValues(true)
        
        let type = TransactionType.TxTypeAccountUpdate.rawValue.hexa.hexData!
        
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

    public override func compareTxField(_ txObj: AbstractTransaction, _ checkSig: Bool) -> Bool {
        if !super.compareTxField(txObj, checkSig) { return false }
        guard let txObj = txObj as? AccountUpdate else { return false }
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
