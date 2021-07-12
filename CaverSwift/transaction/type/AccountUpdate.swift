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
        public var account: Account?
        
        init() {
            super.init(TransactionType.TxTypeAccountUpdate.string)
        }
        public override func build() throws -> AccountUpdate {
            return try AccountUpdate(self)
        }
        
        public func setAccount (_ account: Account) -> Self {
            self.account = account
            return self
        }
    }
    
    init(_ builder: Builder) throws {
        try super.init(builder)
        try setAccount(builder.account)
    }
    
    init(_ klaytnCall: Klay?, _ type: String, _ from: String, _ nonce: String = "0x", _ gas: String, _ gasPrice: String = "0x", _ chainId: String = "0x", _ signatures: [SignatureData] = [], _ account: Account) throws {
        try super.init(klaytnCall, type, from, nonce, gas, gasPrice, chainId, signatures)
        try setAccount(account)
    }    
    
    public static func decode(_ rlpEncoded: String) throws -> AccountUpdate {
        guard let data = rlpEncoded.bytesFromHex else {
            throw CaverError.unexpectedReturnValue
        }
        return try decode(data)
    }
    
    public static func decode(_ rlpEncoded: [UInt8]) throws -> AccountUpdate {
        let rlpList = Rlp.decode(rlpEncoded)
        guard let values = rlpList as? [Any],
              let nonce = values[0] as? String,
              let gasPrice = values[1] as? String,
              let gas = values[2] as? String,
              let from = values[3] as? String,
              let account = values[4] as? String,
              let account = try? Account.createFromRLPEncoding(from, account),
              let senderSignatures = values[5] as? [[String]] else {
            throw CaverError.RuntimeException("There is an error while decoding process.")
        }
        
        let signatureDataList = SignatureData.decodeSignatures(senderSignatures)
        let accountUpdate = try AccountUpdate.Builder()
            .setAccount(account)
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setGas(gas)
            .setFrom(from)
            .setSignatures(signatureDataList)
            .build()
        
        return accountUpdate
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
