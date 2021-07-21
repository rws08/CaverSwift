//
//  AbstractTransaction.swift
//  CaverSwift
//
//  Created by won on 2021/07/09.
//

import Foundation

open class AbstractTransaction {
    private(set) public var klaytnCall: Klay?
    private(set) public var type = ""
    private(set) public var from = ""
    private(set) public var nonce = "0x"
    private(set) public var gas = ""
    private(set) public var gasPrice = "0x"
    private(set) public var chainId = "0x"
    private(set) public var signatures: [SignatureData] = []
    
    public class Builder {
        private(set) public var klaytnCall: Klay? = nil
        private(set) public var type = ""
        private(set) public var from = ""
        private(set) public var nonce = "0x"
        private(set) public var gas = ""
        private(set) public var gasPrice = "0x"
        private(set) public var chainId = "0x"
        private(set) public var signatures: [SignatureData] = []
        
        init(_ type: String) {
            self.type = type
        }
        
        public func setFrom(_ from: String) -> Self {
            self.from = from
            return self
        }
        
        public func setNonce(_ nonce: String) -> Self {
            self.nonce = nonce
            return self
        }
        
        public func setNonce(_ nonce: BigInt) -> Self {
            return setNonce(nonce.hexa)
        }
        
        public func setGas(_ gas: String) -> Self {
            self.gas = gas
            return self
        }
        
        public func setGas(_ gas: BigInt) -> Self {
            return setGas(gas.hexa)
        }
        
        public func setGasPrice(_ gasPrice: String) -> Self {
            self.gasPrice = gasPrice
            return self
        }
        
        public func setGasPrice(_ gasPrice: BigInt) -> Self {
            return setGasPrice(gasPrice.hexa)
        }
        
        public func setChainId(_ chainId: String) -> Self {
            self.chainId = chainId
            return self
        }
        
        public func setChainId(_ chainId: BigInt) -> Self {
            return setChainId(chainId.hexa)
        }
        
        public func setSignatures(_ signatures: [SignatureData]) -> Self {
            self.signatures.append(contentsOf: signatures)
            return self
        }
        
        public func setSignatures(_ sign: SignatureData?) -> Self {
            guard let sign = sign else {
                self.signatures.append(SignatureData.getEmptySignature())
                return self
            }
            
            self.signatures.append(sign)
            return self
        }
        
        public func setKlaytnCall(_ klaytnCall: Klay) -> Self {
            self.klaytnCall = klaytnCall
            return self
        }
        
        public func build() throws -> AbstractTransaction {
            return try AbstractTransaction(self)
        }
    }
    
    init(_ builder: Builder) throws {
        self.klaytnCall = builder.klaytnCall
        self.type = builder.type
        try setFrom(builder.from)
        try setNonce(builder.nonce)
        try setGas(builder.gas)
        try setGasPrice(builder.gasPrice)
        try setChainId(builder.chainId)
        try setSignatures(builder.signatures)
    }
    
    init(_ klaytnCall: Klay?, _ type: String, _ from: String, _ nonce: String = "0x", _ gas: String, _ gasPrice: String = "0x", _ chainId: String = "0x", _ signatures: [SignatureData]?) throws {
        self.klaytnCall = klaytnCall
        self.type = type
        try setFrom(from)
        try setNonce(nonce)
        try setGas(gas)
        try setGasPrice(gasPrice)
        try setChainId(chainId)
        try setSignatures(signatures ?? [])
    }
    
    public func getRLPEncoding() throws -> String { throw CaverError.unexpectedReturnValue }
    
    public func getCommonRLPEncodingForSignature() throws -> String { throw CaverError.unexpectedReturnValue }
        
    public func sign(_ keyString: String) throws -> AbstractTransaction {
        let keyring = try KeyringFactory.createFromPrivateKey(keyString)
        return try sign(keyring, TransactionHasher.getHashForSignature)
    }
    
    public func sign(_ keyString: String, _ signer: (AbstractTransaction) throws ->String) throws -> AbstractTransaction {
        let keyring = try KeyringFactory.createFromPrivateKey(keyString)
        return try sign(keyring, signer)
    }
    
    public func sign(_ keyring: AbstractKeyring) throws -> AbstractTransaction {
        return try sign(keyring, TransactionHasher.getHashForSignature)
    }
    
    public func sign(_ keyring: AbstractKeyring, _ signer: (AbstractTransaction) throws ->String) throws -> AbstractTransaction {
        if type == TransactionType.TxTypeLegacyTransaction.string && keyring.isDecoupled {
            throw CaverError.IllegalArgumentException("A legacy transaction cannot be signed with a decoupled keyring.")
        }
        
        if from == "0x" || from == Utils.DEFAULT_ZERO_ADDRESS {
            from = keyring.address
        }
        
        if from.lowercased() != keyring.address.lowercased() {
            throw CaverError.IllegalArgumentException("The from address of the transaction is different with the address of the keyring to use")
        }
        
        try fillTransaction()
        let role = type == TransactionType.TxTypeAccountUpdate.string ? AccountKeyRoleBased.RoleGroup.ACCOUNT_UPDATE.rawValue : AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue
        
        let hash = try signer(self)
        guard let chainId = Int(hex: chainId),
              let sigList = try keyring.sign(hash, chainId, role) else { throw CaverError.IllegalArgumentException("Invalid chainId") }
        
        try appendSignatures(sigList)
        return self
    }
    
    public func sign(_ keyring: AbstractKeyring, _ index: Int) throws -> AbstractTransaction {
        return try sign(keyring, index, TransactionHasher.getHashForSignature)
    }
    
    public func sign(_ keyring: AbstractKeyring, _ index:Int, _ signer: (AbstractTransaction) throws ->String) throws -> AbstractTransaction {
        if type == TransactionType.TxTypeLegacyTransaction.string && keyring.isDecoupled {
            throw CaverError.IllegalArgumentException("A legacy transaction cannot be signed with a decoupled keyring.")
        }
        
        if from == "0x" || from == Utils.DEFAULT_ZERO_ADDRESS {
            from = keyring.address
        }
        
        if from.lowercased() != keyring.address.lowercased() {
            throw CaverError.IllegalArgumentException("The from address of the transaction is different with the address of the keyring to use")
        }
        
        try fillTransaction()
        let role = type == TransactionType.TxTypeAccountUpdate.string ? AccountKeyRoleBased.RoleGroup.ACCOUNT_UPDATE.rawValue : AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue
        
        let hash = try signer(self)
        guard let chainId = Int(hex: chainId),
              let sigList = try keyring.sign(hash, chainId, role, index) else { throw CaverError.IllegalArgumentException("Invalid chainId") }
        
        try appendSignatures(sigList)
        return self
    }
    
    public func fillTransaction() throws {
        if klaytnCall != nil {
            if nonce == "0x" {
                let(_, result) = klaytnCall!.getTransactionCount(from, .Pending)
                print(result?.val.hexa as Any)
                self.nonce = (result?.val.hexa)!
            }
            
            if chainId == "0x" {
                self.chainId = (klaytnCall?.getChainID().1?.val.hexa)!
            }
            
            if gasPrice == "0x" {
                self.gasPrice = (klaytnCall?.getGasPrice().1?.val.hexa)!
            }
        }
        
        if nonce == "0x" || chainId == "0x" || gasPrice == "0x" {
            throw CaverError.RuntimeException("Cannot fill transaction data.(nonce, chainId, gasPrice). `klaytnCall` must be set in Transaction instance to automatically fill the nonce, chainId or gasPrice. Please call the `setKlaytnCall` to set `klaytnCall` in the Transaction instance.")
        }
    }
    
    public func compareTxField(_ txObj: AbstractTransaction, _ checkSig: Bool) -> Bool {
        if type != txObj.type { return false }
        if from.lowercased() != txObj.from.lowercased() { return false }
        if BigInt(hex: nonce) != BigInt(hex: txObj.nonce) { return false }
        if BigInt(hex: gas) != BigInt(hex: txObj.gas) { return false }
        if BigInt(hex: gasPrice) != BigInt(hex: txObj.gasPrice) { return false }
        
        if checkSig {
            let dataList = signatures
            if dataList.count != txObj.signatures.count { return false }
            if zip(dataList, txObj.signatures).first(where: !=) != nil {
                return false
            }
        }
        
        return true
    }
    
    public func appendSignatures(_ signatureData: SignatureData) throws {
        try appendSignatures([signatureData])
    }
    
    public func appendSignatures(_ signatureDataList: [SignatureData]) throws {
        self.signatures.append(contentsOf: signatureDataList);
        self.signatures = try refineSignature(self.signatures);
    }
    
    public func combineSignedRawTransactions(_ rlpEncoded: [String]) throws -> String {
        var fillVariable = false
        
        if Utils.isEmptySig(signatures) {
            fillVariable = true
        }
        
        try rlpEncoded.forEach {
            let txObj = try TransactionDecoder.decode($0)
            
            if fillVariable {
                if nonce == "0x" { try setNonce(txObj.nonce) }
                if gasPrice == "0x" { try setGasPrice(txObj.gasPrice) }
                fillVariable = false
            }
            
            if !compareTxField(txObj, false) {
                throw CaverError.RuntimeException("Transactions containing different information cannot be combined.")
            }
            
            try appendSignatures(txObj.signatures)
        }
        
        return try getRLPEncoding()
    }
    
    public func getRawTransaction() throws -> String {
        return try getRLPEncoding()
    }
    
    public func getTransactionHash() throws -> String {
        return try getRLPEncoding().sha3String
    }
    
    public func getSenderTxHash() throws -> String {
        return try getTransactionHash()
    }
    
    public func getRLPEncodingForSignature() throws -> String {
        guard let txRLP = try getCommonRLPEncodingForSignature().bytesFromHex else { throw CaverError.invalidValue }
        
        let rlpTypeList: [Any] = [
            Data(txRLP),
            chainId,
            0,
            0
        ]
        
        guard let encoded = Rlp.encode(rlpTypeList) else { throw CaverError.invalidValue }
        return encoded.hexString
    }
    
    public func validateOptionalValues(_ checkChainID: Bool) throws {
        if nonce.isEmpty || nonce == "0x" {
            throw CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values.")
        }
        
        if gasPrice.isEmpty || gasPrice == "0x" {
            throw CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values.")
        }
        
        if checkChainID && (chainId.isEmpty || chainId == "0x") {
            throw CaverError.RuntimeException("chainId is undefined. Define chainId in transaction or use 'transaction.fillTransaction' to fill values.")
        }
    }
    
    public func refineSignature(_ signatureDataList: [SignatureData]) throws -> [SignatureData] {
        let isLegacy = type == TransactionType.TxTypeLegacyTransaction.string
        
        var refinedList: [SignatureData] = []
        signatureDataList.forEach {
            if !Utils.isEmptySig($0) && !refinedList.contains($0) {
                refinedList.append($0)
            }
        }
        
        if refinedList.isEmpty {
            refinedList.append(SignatureData.getEmptySignature())
        }
        
        if isLegacy && refinedList.count > 1 {
            throw CaverError.RuntimeException("LegacyTransaction cannot have multiple signature.")
        }
        
        return refinedList
    }
    
    public func setFrom(_ from: String) throws {
        var from = from
        if self is LegacyTransaction {
            if from.isEmpty || from == "0x" || from == Utils.DEFAULT_ZERO_ADDRESS {
                from = Utils.DEFAULT_ZERO_ADDRESS
            }
        } else {
            if from.isEmpty {
                throw CaverError.IllegalArgumentException("from is missing.")
            }
            
            if !Utils.isAddress(from) {
                throw CaverError.IllegalArgumentException("Invalid address. : \(from)")
            }
        }
        self.from = from
    }
    
    public func setNonce(_ nonce: String) throws {
        var nonce = nonce
        if nonce.isEmpty || nonce == "0x" {
            nonce = "0x"
        }
    
        if nonce != "0x" && !Utils.isNumber(nonce) {
            throw CaverError.IllegalArgumentException("Invalid nonce. : \(nonce)")
        }
        self.nonce = nonce
    }
    
    public func setNonce(_ nonce: BigInt) throws {
        try setNonce(nonce.hexa)
    }
    
    public func setGas(_ gas: String) throws {
        if gas.isEmpty || gas == "0x" {
            throw CaverError.IllegalArgumentException("gas is missing.")
        }
    
        if !Utils.isNumber(gas) {
            throw CaverError.IllegalArgumentException("Invalid gas. : \(gas)")
        }
        
        self.gas = gas
    }
    
    public func setGas(_ gas: BigInt) throws {
        try setGas(gas.hexa)
    }
    
    public func setGasPrice(_ gasPrice: String) throws {
        var gasPrice = gasPrice
        if gasPrice.isEmpty || gasPrice == "0x" {
            gasPrice = "0x"
        }
    
        if gasPrice != "0x" && !Utils.isNumber(gasPrice) {
            throw CaverError.IllegalArgumentException("Invalid gasPrice. : \(gasPrice)")
        }
        self.gasPrice = gasPrice
    }
    
    public func setGasPrice(_ gasPrice: BigInt) throws {
        try setGasPrice(gasPrice.hexa)
    }
    
    public func setChainId(_ chainId: String) throws {
        var chainId = chainId
        if chainId.isEmpty || chainId == "0x" {
            chainId = "0x"
        }
    
        if chainId != "0x" && !Utils.isNumber(chainId) {
            throw CaverError.IllegalArgumentException("Invalid chainId. : \(chainId)")
        }
        self.chainId = chainId
    }
    
    public func setChainId(_ chainId: BigInt) throws {
        try setChainId(chainId.hexa)
    }
    
    public func setSignatures(_ signatures: [SignatureData]) throws {
        var signatures = signatures
        if signatures.count == 0 {
            signatures = [SignatureData.getEmptySignature()]
        }
        try appendSignatures(signatures)
    }
    
    public func getKeyType() -> Int {
        guard let type = Int(type),
              let keyType = TransactionType.init(rawValue: type)?.rawValue else {
            return 0
        }
        return keyType
    }
}
