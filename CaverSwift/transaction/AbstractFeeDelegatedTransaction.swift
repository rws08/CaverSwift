//
//  AbstractFeeDelegatedTransaction.swift
//  CaverSwift
//
//  Created by won on 2021/07/12.
//

import Foundation

open class AbstractFeeDelegatedTransaction: AbstractTransaction {
    private(set) public var feePayer = ""
    private(set) public var feePayerSignatures: [SignatureData] = []
    
    private enum CodingKeys: String, CodingKey {
        case feePayer
    }
    
    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(feePayer, forKey: .feePayer)
    }
    
    public class Builder: AbstractTransaction.Builder {
        private(set) public var feePayer = ""
        private(set) public var feePayerSignatures: [SignatureData] = []
        
        override init(_ type: String) {
            super.init(type)
        }
        
        public override func build() throws -> AbstractFeeDelegatedTransaction {
            return try AbstractFeeDelegatedTransaction(self)
        }
        
        public func setFeePayer(_ feePayer: String) -> Self {
            self.feePayer = feePayer
            return self
        }
        
        public func setFeePayerSignatures(_ feePayerSignatures: [SignatureData]) -> Self {
            self.feePayerSignatures = feePayerSignatures
            return self
        }
        
        public func setFeePayerSignatures(_ data: SignatureData?) -> Self {
            guard let data = data else {
                self.feePayerSignatures.append(SignatureData.getEmptySignature())
                return self
            }
            
            self.feePayerSignatures.append(data)
            return self
        }
    }
    
    public init(_ builder: Builder) throws {
        try super.init(builder)
        try setFeePayer(builder.feePayer)
        try setFeePayerSignatures(builder.feePayerSignatures)
    }
    
    public init(_ klaytnCall: Klay?, _ type: String, _ from: String, _ nonce: String = "0x", _ gas: String, _ gasPrice: String = "0x", _ chainId: String = "0x", _ signatures: [SignatureData]?, _ feePayer: String, _ feePayerSignatures: [SignatureData]?) throws {
        try super.init(klaytnCall, type, from, nonce, gas, gasPrice, chainId, signatures)
        try setFeePayer(feePayer)
        try setFeePayerSignatures(feePayerSignatures ?? [])
    }
    
    public func signAsFeePayer(_ keyString: String) throws -> AbstractFeeDelegatedTransaction {
        let keyring = try KeyringFactory.createFromPrivateKey(keyString);

        return try signAsFeePayer(keyring, TransactionHasher.getHashForFeePayerSignature)
    }
    
    public func signAsFeePayer(_ keyString: String, _ hasher: (AbstractFeeDelegatedTransaction) throws ->String) throws -> AbstractFeeDelegatedTransaction {
        let keyring = try KeyringFactory.createFromPrivateKey(keyString);

        return try signAsFeePayer(keyring, hasher)
    }
    
    public func signAsFeePayer(_ keyring: AbstractKeyring) throws -> AbstractFeeDelegatedTransaction {
        return try signAsFeePayer(keyring, TransactionHasher.getHashForFeePayerSignature)
    }
    
    public func signAsFeePayer(_ keyring: AbstractKeyring, _ index: Int) throws -> AbstractFeeDelegatedTransaction {
        return try signAsFeePayer(keyring, index, TransactionHasher.getHashForFeePayerSignature)
    }
    
    public func signAsFeePayer(_ keyring: AbstractKeyring, _ hasher: (AbstractFeeDelegatedTransaction) throws ->String) throws -> AbstractFeeDelegatedTransaction {
        if feePayer == "0x" || feePayer == Utils.DEFAULT_ZERO_ADDRESS {
            feePayer = keyring.address
        }
        
        if feePayer.lowercased() != keyring.address.lowercased() {
            throw CaverError.IllegalArgumentException("The feePayer address of the transaction is different with the address of the keyring to use.")
        }
        
        try fillTransaction()
        let role = AccountKeyRoleBased.RoleGroup.FEE_PAYER.rawValue
        
        let hash = try hasher(self)
        guard let chainId = Int(hex: chainId),
              let sigList = try keyring.sign(hash, chainId, role) else { throw CaverError.IllegalArgumentException("Invalid chainId") }
        
        try appendFeePayerSignatures(sigList)
        return self
    }
    
    public func signAsFeePayer(_ keyring: AbstractKeyring, _ index: Int, _ hasher: (AbstractFeeDelegatedTransaction) throws ->String) throws -> AbstractFeeDelegatedTransaction {
        if feePayer == "0x" || feePayer == Utils.DEFAULT_ZERO_ADDRESS {
            feePayer = keyring.address
        }
        
        if feePayer.lowercased() != keyring.address.lowercased() {
            throw CaverError.IllegalArgumentException("The feePayer address of the transaction is different with the address of the keyring to use.")
        }
        
        try fillTransaction()
        let role = AccountKeyRoleBased.RoleGroup.FEE_PAYER.rawValue
        
        let hash = try hasher(self)
        guard let chainId = Int(hex: chainId),
              let sigList = try keyring.sign(hash, chainId, role, index) else { throw CaverError.IllegalArgumentException("Invalid chainId") }
        
        try appendFeePayerSignatures(sigList)
        return self
    }
    
    public func appendFeePayerSignatures(_ signatureData: SignatureData) throws {
        try appendFeePayerSignatures([signatureData]);
    }
    
    public func appendFeePayerSignatures(_ signatureData: [SignatureData]) throws {
        try setFeePayerSignatures(signatureData);
    }
    
    public override func combineSignedRawTransactions(_ rlpEncoded:[String]) throws -> String {
        var fillVariable = false
        
        if Utils.isEmptySig(feePayerSignatures) || Utils.isEmptySig(signatures) {
            fillVariable = true
        }
        
        try rlpEncoded.forEach {
            guard let txObj = try TransactionDecoder.decode($0) as? AbstractFeeDelegatedTransaction else {
                throw CaverError.invalidType
            }
            
            if fillVariable {
                if nonce == "0x" { try setNonce(txObj.nonce) }
                if gasPrice == "0x" { try setGasPrice(txObj.gasPrice) }
                if feePayer == "0x" || feePayer == Utils.DEFAULT_ZERO_ADDRESS {
                    if txObj.feePayer != "0x" && txObj.feePayer != Utils.DEFAULT_ZERO_ADDRESS {
                        try setFeePayer(txObj.feePayer)
                        fillVariable = false
                    }
                }
            }
            
            if !compareTxField(txObj, false) {
                throw CaverError.RuntimeException("Transactions containing different information cannot be combined.")
            }
            
            try appendSignatures(txObj.signatures)
            try appendFeePayerSignatures(txObj.feePayerSignatures)
        }
        
        return try getRLPEncoding()
    }
    
    public func getRLPEncodingForFeePayerSignature() throws -> String {
        guard let txRLP = try getCommonRLPEncodingForSignature().bytesFromHex else { throw CaverError.invalidValue }
        
        let rlpTypeList: [Any] = [
            Data(txRLP),
            feePayer,
            chainId,
            0,
            0
        ]
        
        guard let encoded = Rlp.encode(rlpTypeList) else { throw CaverError.invalidValue }
        return encoded.hexString
    }
    
    public func compareTxField(_ txObj: AbstractFeeDelegatedTransaction, _ checkSig: Bool) -> Bool {
        if !super.compareTxField(txObj, checkSig) { return false }
        if feePayer.lowercased() != txObj.feePayer.lowercased() { return false }
        
        if checkSig {
            let dataList = feePayerSignatures
            if dataList.count != txObj.feePayerSignatures.count { return false }
            if zip(dataList, txObj.feePayerSignatures).first(where: !=) != nil {
                return false
            }
        }
        
        return true
    }
    
    public func setFeePayer(_ feePayer: String) throws {
        var feePayer = feePayer
        
        if feePayer.isEmpty || feePayer == "0x" {
            feePayer = Utils.DEFAULT_ZERO_ADDRESS
        }
    
        if !Utils.isAddress(feePayer) {
            throw CaverError.IllegalArgumentException("Invalid address. : \(feePayer)")
        }
        
        self.feePayer = feePayer
    }
    
    public func setFeePayerSignatures(_ feePayerSignatures: [SignatureData]) throws {
        var feePayerSignatures = feePayerSignatures
        if feePayerSignatures.count == 0 {
            feePayerSignatures = [SignatureData.getEmptySignature()]
        }
        
        if !Utils.isEmptySig(feePayerSignatures) {
            if feePayer == "0x" || feePayer == Utils.DEFAULT_ZERO_ADDRESS {
                throw CaverError.IllegalArgumentException("feePayer is missing: feePayer must be defined with feePayerSignatures.")
            }
        }
        
        self.feePayerSignatures.append(contentsOf: feePayerSignatures)
        self.feePayerSignatures = try refineSignature(self.feePayerSignatures)
    }
}
