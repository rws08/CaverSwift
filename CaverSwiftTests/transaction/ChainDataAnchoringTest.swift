//
//  ChainDataAnchoringTest.swift
//  CaverSwiftTests
//
//  Created by won on 2021/07/14.
//

import XCTest
@testable import CaverSwift

class ChainDataAnchoringTest: XCTestCase {
    static let caver = Caver(Caver.DEFAULT_URL)

    static let privateKey = "0x45a915e4d060149eb4365960e6a7a45f334393093061116b197e3240065ff2d8"
    static let from = "0xa94f5374Fce5edBC8E2a8697C15331677e6EbF0B"
    static let gas = "0xf4240"
    static let gasPrice = "0x19"
    static let nonce = "0x4d2"
    static let chainID = "0x1"
    static let input = "0xf8a6a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a0000000000000000000000000000000000000000000000000000000000000000405"

    static let signatureData = SignatureData(
            "0x25",
            "0xe58b9abf9f33a066b998fccaca711553fb4df425c9234bbb3577f9d9775bb124",
            "0x2c409a6c5d92277c0a812dd0cc553d7fe1d652a807274c3786df3292cd473e09"
    )

    static let expectedRLPEncoding = "0x48f9010e8204d219830f424094a94f5374fce5edbc8e2a8697c15331677e6ebf0bb8a8f8a6a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a0000000000000000000000000000000000000000000000000000000000000000405f845f84325a0e58b9abf9f33a066b998fccaca711553fb4df425c9234bbb3577f9d9775bb124a02c409a6c5d92277c0a812dd0cc553d7fe1d652a807274c3786df3292cd473e09"
    static let expectedTransactionHash = "0x4aad85735e777795d24aa3eab51be959d8ebdf9683083d85b66f70b7170f2ea3"
    static let expectedRLPEncodingForSigning = "0xf8cfb8caf8c8488204d219830f424094a94f5374fce5edbc8e2a8697c15331677e6ebf0bb8a8f8a6a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a0000000000000000000000000000000000000000000000000000000000000000405018080"

    public static func generateRoleBaseKeyring(_ numArr: [Int], _ address: String) throws -> AbstractKeyring {
        let keyArr = numArr.map {
            (0..<$0).map { _ in
                PrivateKey.generate("entropy").privateKey
            }
        }
        
        return try KeyringFactory.createWithRoleBasedKey(address, keyArr)
    }
}

class ChainDataAnchoringTest_createInstanceBuilder: XCTestCase {
    let from = ChainDataAnchoringTest.from
    let gas = ChainDataAnchoringTest.gas
    let nonce = ChainDataAnchoringTest.nonce
    let gasPrice = ChainDataAnchoringTest.gasPrice
    let chainID = ChainDataAnchoringTest.chainID
    let input = ChainDataAnchoringTest.input
    let signatureData = ChainDataAnchoringTest.signatureData
    
    public func test_BuilderTest() throws {
        let txObj = try ChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setInput(input)
            .setSignatures(signatureData)
            .build()
        
        XCTAssertNotNil(txObj)
    }
    
    public func test_BuilderWithRPCTest() throws {
        let txObj = try ChainDataAnchoring.Builder()
            .setKlaytnCall(Caver(Caver.DEFAULT_URL).rpc.klay)
            .setGas(gas)
            .setFrom(from)
            .setInput(input)
            .setSignatures(signatureData)
            .build()
        
        try txObj.fillTransaction()
        
        XCTAssertFalse(txObj.nonce.isEmpty)
        XCTAssertFalse(txObj.gasPrice.isEmpty)
        XCTAssertFalse(txObj.chainId.isEmpty)
    }
    
    public func test_BuilderTestWithBigInteger() throws {
        let txObj = try ChainDataAnchoring.Builder()
            .setNonce(BigInt(hex: nonce)!)
            .setGas(BigInt(hex: gas)!)
            .setGasPrice(BigInt(hex: gasPrice)!)
            .setChainId(BigInt(hex: chainID)!)
            .setFrom(from)
            .setInput(input)
            .setSignatures(signatureData)
            .build()
        
        XCTAssertNotNil(txObj)
        
        XCTAssertEqual(gas, txObj.gas)
        XCTAssertEqual(gasPrice, txObj.gasPrice)
        XCTAssertEqual(chainID, txObj.chainId)
    }
    
    public func test_throwException_invalidFrom() throws {
        let from = "invalid Address"
        XCTAssertThrowsError(try ChainDataAnchoring.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setInput(input)
                                .setSignatures(signatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(from)"))
        }
    }
    
    public func test_throwException_missingFrom() throws {
        let from = ""
        XCTAssertThrowsError(try ChainDataAnchoring.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setInput(input)
                                .setSignatures(signatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("from is missing."))
        }
    }
    
    public func test_throwException_invalidGas() throws {
        let gas = "invalid gas"
        XCTAssertThrowsError(try ChainDataAnchoring.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setInput(input)
                                .setSignatures(signatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid gas. : \(gas)"))
        }
    }
    
    public func test_throwException_missingGas() throws {
        let gas = ""
        XCTAssertThrowsError(try ChainDataAnchoring.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setInput(input)
                                .setSignatures(signatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("gas is missing."))
        }
    }
    
    public func test_throwException_invalidInput() throws {
        let input = "invalid input"
        XCTAssertThrowsError(try ChainDataAnchoring.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setInput(input)
                                .setSignatures(signatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid input : \(input)"))
        }
    }
    
    public func test_throwException_missingInput() throws {
        let input = ""
        XCTAssertThrowsError(try ChainDataAnchoring.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setInput(input)
                                .setSignatures(signatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("input is missing."))
        }
    }
}

class ChainDataAnchoringTest_createInstance: XCTestCase {
    let from = ChainDataAnchoringTest.from
    let gas = ChainDataAnchoringTest.gas
    let nonce = ChainDataAnchoringTest.nonce
    let gasPrice = ChainDataAnchoringTest.gasPrice
    let chainID = ChainDataAnchoringTest.chainID
    let input = ChainDataAnchoringTest.input
    let signatureData = ChainDataAnchoringTest.signatureData
    
    public func test_createInstance() throws {
        let txObj = try ChainDataAnchoring(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            input
        )
        
        XCTAssertNotNil(txObj)
    }
    
    public func test_throwException_invalidFrom() throws {
        let from = "invalid Address"
        XCTAssertThrowsError(try ChainDataAnchoring(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(from)"))
        }
    }
    
    public func test_throwException_missingFrom() throws {
        let from = ""
        XCTAssertThrowsError(try ChainDataAnchoring(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("from is missing."))
        }
    }
    
    public func test_throwException_invalidGas() throws {
        let gas = "invalid gas"
        XCTAssertThrowsError(try ChainDataAnchoring(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid gas. : \(gas)"))
        }
    }
    
    public func test_throwException_missingGas() throws {
        let gas = ""
        XCTAssertThrowsError(try ChainDataAnchoring(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("gas is missing."))
        }
    }
    
    public func test_throwException_invalidInput() throws {
        let input = "invalid input"
        XCTAssertThrowsError(try ChainDataAnchoring(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid input : \(input)"))
        }
    }
    
    public func test_throwException_missingInput() throws {
        let input = ""
        XCTAssertThrowsError(try ChainDataAnchoring(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("input is missing."))
        }
    }
}

class ChainDataAnchoringTest_getRLPEncodingTest: XCTestCase {
    let from = ChainDataAnchoringTest.from
    let gas = ChainDataAnchoringTest.gas
    let nonce = ChainDataAnchoringTest.nonce
    let gasPrice = ChainDataAnchoringTest.gasPrice
    let chainID = ChainDataAnchoringTest.chainID
    let input = ChainDataAnchoringTest.input
    let signatureData = ChainDataAnchoringTest.signatureData
    let expectedRLPEncoding = ChainDataAnchoringTest.expectedRLPEncoding
        
    public func test_getRLPEncoding() throws {
        let txObj = try ChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setChainId(chainID)
            .setInput(input)
            .setSignatures(signatureData)
            .build()
        
        XCTAssertEqual(expectedRLPEncoding, try txObj.getRLPEncoding())
    }
    
    public func test_throwException_NoNonce() throws {
        let txObj = try ChainDataAnchoring.Builder()
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setChainId(chainID)
            .setInput(input)
            .setSignatures(signatureData)
            .build()
        
        XCTAssertThrowsError(try txObj.getRLPEncoding()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NoGasPrice() throws {
        let txObj = try ChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setFrom(from)
            .setChainId(chainID)
            .setInput(input)
            .setSignatures(signatureData)
            .build()
        
        XCTAssertThrowsError(try txObj.getRLPEncoding()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class ChainDataAnchoringTest_signWithKeyTest: XCTestCase {
    var mTxObj: ChainDataAnchoring?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = ChainDataAnchoringTest.privateKey
    let from = ChainDataAnchoringTest.from
    let gas = ChainDataAnchoringTest.gas
    let nonce = ChainDataAnchoringTest.nonce
    let gasPrice = ChainDataAnchoringTest.gasPrice
    let chainID = ChainDataAnchoringTest.chainID
    let input = ChainDataAnchoringTest.input
    let signatureData = ChainDataAnchoringTest.signatureData
    let expectedRLPEncoding = ChainDataAnchoringTest.expectedRLPEncoding
        
    override func setUpWithError() throws {
        mTxObj = try ChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setChainId(chainID)
            .setInput(input)
            .build()
        
        coupledKeyring = try KeyringFactory.createFromPrivateKey(privateKey)
        deCoupledKeyring = try KeyringFactory.createWithSingleKey(PrivateKey.generate().getDerivedAddress(), privateKey)
        klaytnWalletKey = try coupledKeyring?.getKlaytnWalletKey()
    }
    
    public func test_signWithKey_Keyring() throws {
        _ = try mTxObj!.sign(coupledKeyring!, 0, TransactionHasher.getHashForSignature(_:))
        XCTAssertEqual(expectedRLPEncoding, try mTxObj?.getRawTransaction())
    }
    
    public func test_signWithKey_Keyring_NoIndex() throws {
        _ = try mTxObj!.sign(coupledKeyring!, TransactionHasher.getHashForSignature(_:))
        XCTAssertEqual(expectedRLPEncoding, try mTxObj?.getRawTransaction())
    }
    
    public func test_signWithKey_Keyring_NoSigner() throws {
        _ = try mTxObj!.sign(coupledKeyring!, 0)
        XCTAssertEqual(expectedRLPEncoding, try mTxObj?.getRawTransaction())
    }
    
    public func test_signWithKey_Keyring_Only() throws {
        _ = try mTxObj!.sign(coupledKeyring!)
        XCTAssertEqual(expectedRLPEncoding, try mTxObj?.getRawTransaction())
    }
    
    public func test_signWithKey_KeyString_NoIndex() throws {
        _ = try mTxObj!.sign(privateKey, TransactionHasher.getHashForSignature(_:))
        XCTAssertEqual(expectedRLPEncoding, try mTxObj?.getRawTransaction())
    }
    
    public func test_signWithKey_KeyString_Only() throws {
        _ = try mTxObj!.sign(privateKey)
        XCTAssertEqual(expectedRLPEncoding, try mTxObj?.getRawTransaction())
    }
    
    public func test_signWithKey_KlayWalletKey() throws {
        _ = try mTxObj!.sign(klaytnWalletKey!)
        XCTAssertEqual(expectedRLPEncoding, try mTxObj?.getRawTransaction())
    }
    
    public func test_throwException_NotMatchAddress() throws {
        XCTAssertThrowsError(try mTxObj!.sign(deCoupledKeyring!)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("The from address of the transaction is different with the address of the keyring to use"))
        }
    }
    
    public func test_throwException_InvalidIndex() throws {
        let role = try AccountUpdateTest.generateRoleBaseKeyring([3,3,3], from)
        
        XCTAssertThrowsError(try mTxObj!.sign(role, 4)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid index : index must be less than the length of the key."))
        }
    }
}

class ChainDataAnchoringTest_signWithKeysTest: XCTestCase {
    var mTxObj: ChainDataAnchoring?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = ChainDataAnchoringTest.privateKey
    let from = ChainDataAnchoringTest.from
    let gas = ChainDataAnchoringTest.gas
    let nonce = ChainDataAnchoringTest.nonce
    let gasPrice = ChainDataAnchoringTest.gasPrice
    let chainID = ChainDataAnchoringTest.chainID
    let input = ChainDataAnchoringTest.input
    let signatureData = ChainDataAnchoringTest.signatureData
    let expectedRLPEncoding = ChainDataAnchoringTest.expectedRLPEncoding
        
    override func setUpWithError() throws {
        mTxObj = try ChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setChainId(chainID)
            .setInput(input)
            .build()
        
        coupledKeyring = try KeyringFactory.createFromPrivateKey(privateKey)
        deCoupledKeyring = try KeyringFactory.createWithSingleKey(PrivateKey.generate().getDerivedAddress(), privateKey)
        klaytnWalletKey = try coupledKeyring?.getKlaytnWalletKey()
    }
    
    public func test_signWithKeys_Keyring() throws {
        _ = try mTxObj!.sign(coupledKeyring!, 0, TransactionHasher.getHashForSignature(_:))
        XCTAssertEqual(1, mTxObj?.signatures.count)
        XCTAssertEqual(expectedRLPEncoding, try mTxObj?.getRawTransaction())
    }
    
    public func test_signWithKeys_Keyring_NoSigner() throws {
        _ = try mTxObj!.sign(coupledKeyring!)
        XCTAssertEqual(1, mTxObj?.signatures.count)
        XCTAssertEqual(expectedRLPEncoding, try mTxObj?.getRawTransaction())
    }
    
    public func test_signWithKeys_KeyString() throws {
        _ = try mTxObj!.sign(privateKey, TransactionHasher.getHashForSignature(_:))
        XCTAssertEqual(1, mTxObj?.signatures.count)
        XCTAssertEqual(expectedRLPEncoding, try mTxObj?.getRawTransaction())
    }
    
    public func test_signWithKeys_KeyString_NoSigner() throws {
        _ = try mTxObj!.sign(privateKey)
        XCTAssertEqual(1, mTxObj?.signatures.count)
        XCTAssertEqual(expectedRLPEncoding, try mTxObj?.getRawTransaction())
    }
    
    public func test_throwException_NotMatchAddress() throws {
        XCTAssertThrowsError(try mTxObj!.sign(deCoupledKeyring!)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("The from address of the transaction is different with the address of the keyring to use"))
        }
    }
    
    public func test_signWithKeys_roleBasedKeyring() throws {
        let roleBased = try AccountUpdateTest.generateRoleBaseKeyring([3,3,3], from)
        _ = try mTxObj!.sign(roleBased)
        XCTAssertEqual(3, mTxObj?.signatures.count)
    }
}

class ChainDataAnchoringTest_appendSignaturesTest: XCTestCase {
    var mTxObj: ChainDataAnchoring?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = ChainDataAnchoringTest.privateKey
    let from = ChainDataAnchoringTest.from
    let gas = ChainDataAnchoringTest.gas
    let nonce = ChainDataAnchoringTest.nonce
    let gasPrice = ChainDataAnchoringTest.gasPrice
    let chainID = ChainDataAnchoringTest.chainID
    let input = ChainDataAnchoringTest.input
    let signatureData = ChainDataAnchoringTest.signatureData
    let expectedRLPEncoding = ChainDataAnchoringTest.expectedRLPEncoding
    
    override func setUpWithError() throws {
        mTxObj = try ChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setChainId(chainID)
            .setInput(input)
            .build()
        
        coupledKeyring = try KeyringFactory.createFromPrivateKey(privateKey)
        deCoupledKeyring = try KeyringFactory.createWithSingleKey(PrivateKey.generate().getDerivedAddress(), privateKey)
        klaytnWalletKey = try coupledKeyring?.getKlaytnWalletKey()
    }
    
    public func test_appendSignature() throws {
        let signatureData = SignatureData(
            "0x0fea",
            "0xade9480f584fe481bf070ab758ecc010afa15debc33e1bd75af637d834073a6e",
            "0x38160105d78cef4529d765941ad6637d8dcf6bd99310e165fee1c39fff2aa27e"
        )
        try mTxObj!.appendSignatures(signatureData)
        XCTAssertEqual(signatureData, mTxObj?.signatures[0])
    }
    
    public func test_appendSignatureList() throws {
        let signatureData = SignatureData(
            "0x0fea",
            "0xade9480f584fe481bf070ab758ecc010afa15debc33e1bd75af637d834073a6e",
            "0x38160105d78cef4529d765941ad6637d8dcf6bd99310e165fee1c39fff2aa27e"
        )
        try mTxObj!.appendSignatures([signatureData])
        XCTAssertEqual(signatureData, mTxObj?.signatures[0])
    }
    
    public func test_appendSignatureList_EmptySig() throws {
        let emptySignature = SignatureData.getEmptySignature()
        mTxObj = try ChainDataAnchoring.Builder()
                            .setFrom(from)
                            .setGas(gas)
                            .setNonce(nonce)
                            .setGasPrice(gasPrice)
                            .setChainId(chainID)
                            .setInput(input)
                            .setSignatures(emptySignature)
                            .build()
        
        let signatureData = SignatureData(
            "0x0fea",
            "0xade9480f584fe481bf070ab758ecc010afa15debc33e1bd75af637d834073a6e",
            "0x38160105d78cef4529d765941ad6637d8dcf6bd99310e165fee1c39fff2aa27e"
        )
        try mTxObj!.appendSignatures([signatureData])
        XCTAssertEqual(signatureData, mTxObj?.signatures[0])
    }
    
    public func test_appendSignature_ExistedSignature() throws {
        let signatureData = SignatureData(
            "0x0fea",
            "0xade9480f584fe481bf070ab758ecc010afa15debc33e1bd75af637d834073a6e",
            "0x38160105d78cef4529d765941ad6637d8dcf6bd99310e165fee1c39fff2aa27e"
        )
        
        mTxObj = try ChainDataAnchoring.Builder()
                            .setFrom(from)
                            .setGas(gas)
                            .setNonce(nonce)
                            .setGasPrice(gasPrice)
                            .setChainId(chainID)
                            .setInput(input)
                            .setSignatures(signatureData)
                            .build()
        
        let signatureData1 = SignatureData(
            "0x0fea",
            "0x7a5011b41cfcb6270af1b5f8aeac8aeabb1edb436f028261b5add564de694700",
            "0x23ac51660b8b421bf732ef8148d0d4f19d5e29cb97be6bccb5ae505ebe89eb4a"
        )
        try mTxObj!.appendSignatures([signatureData1])
        XCTAssertEqual(2, mTxObj?.signatures.count)
        XCTAssertEqual(signatureData, mTxObj?.signatures[0])
        XCTAssertEqual(signatureData1, mTxObj?.signatures[1])
    }
    
    public func test_appendSignatureList_ExistedSignature() throws {
        let signatureData = SignatureData(
            "0x0fea",
            "0xade9480f584fe481bf070ab758ecc010afa15debc33e1bd75af637d834073a6e",
            "0x38160105d78cef4529d765941ad6637d8dcf6bd99310e165fee1c39fff2aa27e"
        )
        
        mTxObj = try ChainDataAnchoring.Builder()
                            .setFrom(from)
                            .setGas(gas)
                            .setNonce(nonce)
                            .setGasPrice(gasPrice)
                            .setChainId(chainID)
                            .setInput(input)
                            .setSignatures(signatureData)
                            .build()
        
        let signatureData1 = SignatureData(
            "0x0fea",
            "0x7a5011b41cfcb6270af1b5f8aeac8aeabb1edb436f028261b5add564de694700",
            "0x23ac51660b8b421bf732ef8148d0d4f19d5e29cb97be6bccb5ae505ebe89eb4a"
        )
        let signatureData2 = SignatureData(
            "0x0fea",
            "0x9a5011b41cfcb6270af1b5f8aeac8aeabb1edb436f028261b5add564de694700",
            "0xa3ac51660b8b421bf732ef8148d0d4f19d5e29cb97be6bccb5ae505ebe89eb4a"
        )
        
        try mTxObj!.appendSignatures([signatureData1, signatureData2])
        XCTAssertEqual(3, mTxObj?.signatures.count)
        XCTAssertEqual(signatureData, mTxObj?.signatures[0])
        XCTAssertEqual(signatureData1, mTxObj?.signatures[1])
        XCTAssertEqual(signatureData2, mTxObj?.signatures[2])
    }
}

class ChainDataAnchoringTest_combineSignatureTest: XCTestCase {
    var mTxObj: ChainDataAnchoring?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = ChainDataAnchoringTest.privateKey
    let from = "0xb605c7550ad5fb15ddd9291a2d31a889db808152"
    let gas = "0xf4240"
    let nonce = "0x1"
    let gasPrice = "0x5d21dba00"
    let chainID = "0x7e3"
    let input = ChainDataAnchoringTest.input
    let signatureData = ChainDataAnchoringTest.signatureData
    let expectedRLPEncoding = ChainDataAnchoringTest.expectedRLPEncoding
    
    public func test_combineSignature() throws {
        let expectedRLPEncoded = "0x48f90113018505d21dba00830f424094b605c7550ad5fb15ddd9291a2d31a889db808152b8a8f8a6a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a0000000000000000000000000000000000000000000000000000000000000000405f847f845820feaa091e77e86e76dc7f1edb1ef1c87fd4bcba1fd95cbc659db407e1f358ae0cc00eda008c2fc7ec8ee14e734701435d0ca2e001bc1e0742c0fe0d58bd131a582e4f10c"
        
        let expectedSignature = SignatureData(
            "0x0fea",
            "0x91e77e86e76dc7f1edb1ef1c87fd4bcba1fd95cbc659db407e1f358ae0cc00ed",
            "0x08c2fc7ec8ee14e734701435d0ca2e001bc1e0742c0fe0d58bd131a582e4f10c"
        )
        
        mTxObj = try ChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setChainId(chainID)
            .setInput(input)
            .build()
        
        let rlpEncoded = "0x48f90113018505d21dba00830f424094b605c7550ad5fb15ddd9291a2d31a889db808152b8a8f8a6a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a0000000000000000000000000000000000000000000000000000000000000000405f847f845820feaa091e77e86e76dc7f1edb1ef1c87fd4bcba1fd95cbc659db407e1f358ae0cc00eda008c2fc7ec8ee14e734701435d0ca2e001bc1e0742c0fe0d58bd131a582e4f10c"
        
        let combined = try mTxObj!.combineSignedRawTransactions([rlpEncoded])
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature, mTxObj?.signatures[0])
    }
    
    public func test_combine_multipleSignature() throws {
        let expectedRLPEncoded = "0x48f901a1018505d21dba00830f424094b605c7550ad5fb15ddd9291a2d31a889db808152b8a8f8a6a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a0000000000000000000000000000000000000000000000000000000000000000405f8d5f845820feaa091e77e86e76dc7f1edb1ef1c87fd4bcba1fd95cbc659db407e1f358ae0cc00eda008c2fc7ec8ee14e734701435d0ca2e001bc1e0742c0fe0d58bd131a582e4f10cf845820feaa0c17c5ad8820b984da2bc816f881e1e283a9d7806ed5e3c703f58a7ed1f40edf1a049c4aa23508715aba0891ddad59bab4ff6abde777adffc1f39c79e51a78b786af845820fe9a0d2779b46862d5d10cb31d08ad5907eccf6343148e4264c730e048bb859cf1456a052570001d11eee29ee96c9f530be948a5f270167895705454596f6e61680718c"
        
        let expectedSignature = [
            SignatureData(
                "0x0fea",
                "0x91e77e86e76dc7f1edb1ef1c87fd4bcba1fd95cbc659db407e1f358ae0cc00ed",
                "0x08c2fc7ec8ee14e734701435d0ca2e001bc1e0742c0fe0d58bd131a582e4f10c"
            ),
            SignatureData(
                "0x0fea",
                "0xc17c5ad8820b984da2bc816f881e1e283a9d7806ed5e3c703f58a7ed1f40edf1",
                "0x49c4aa23508715aba0891ddad59bab4ff6abde777adffc1f39c79e51a78b786a"
            ),
            SignatureData(
                "0x0fe9",
                "0xd2779b46862d5d10cb31d08ad5907eccf6343148e4264c730e048bb859cf1456",
                "0x52570001d11eee29ee96c9f530be948a5f270167895705454596f6e61680718c"
            )
        ]
        
        let signatureData = SignatureData(
            "0x0fea",
            "0x91e77e86e76dc7f1edb1ef1c87fd4bcba1fd95cbc659db407e1f358ae0cc00ed",
            "0x08c2fc7ec8ee14e734701435d0ca2e001bc1e0742c0fe0d58bd131a582e4f10c"
        )
        
        mTxObj = try ChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setChainId(chainID)
            .setInput(input)
            .setSignatures(signatureData)
            .build()
        
        let rlpEncodedString = [
            "0x48f90113018505d21dba00830f424094b605c7550ad5fb15ddd9291a2d31a889db808152b8a8f8a6a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a0000000000000000000000000000000000000000000000000000000000000000405f847f845820feaa0c17c5ad8820b984da2bc816f881e1e283a9d7806ed5e3c703f58a7ed1f40edf1a049c4aa23508715aba0891ddad59bab4ff6abde777adffc1f39c79e51a78b786a",
            "0x48f90113018505d21dba00830f424094b605c7550ad5fb15ddd9291a2d31a889db808152b8a8f8a6a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a0000000000000000000000000000000000000000000000000000000000000000405f847f845820fe9a0d2779b46862d5d10cb31d08ad5907eccf6343148e4264c730e048bb859cf1456a052570001d11eee29ee96c9f530be948a5f270167895705454596f6e61680718c"
        ]
        
        let combined = try mTxObj!.combineSignedRawTransactions(rlpEncodedString)
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature[0], mTxObj?.signatures[0])
        XCTAssertEqual(expectedSignature[1], mTxObj?.signatures[1])
        XCTAssertEqual(expectedSignature[2], mTxObj?.signatures[2])
    }
    
    public func test_throwException_differentField() throws {
        let nonce = BigInt(1234)
        mTxObj = try ChainDataAnchoring.Builder()
            .setFrom(from)
            .setGas(gas)
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setInput(input)
            .build()
        
        let rlpEncoded = "0x48f901a1018505d21dba00830f424094b605c7550ad5fb15ddd9291a2d31a889db808152b8a8f8a6a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a0000000000000000000000000000000000000000000000000000000000000000405f8d5f845820feaa091e77e86e76dc7f1edb1ef1c87fd4bcba1fd95cbc659db407e1f358ae0cc00eda008c2fc7ec8ee14e734701435d0ca2e001bc1e0742c0fe0d58bd131a582e4f10cf845820feaa0c17c5ad8820b984da2bc816f881e1e283a9d7806ed5e3c703f58a7ed1f40edf1a049c4aa23508715aba0891ddad59bab4ff6abde777adffc1f39c79e51a78b786af845820fe9a0d2779b46862d5d10cb31d08ad5907eccf6343148e4264c730e048bb859cf1456a052570001d11eee29ee96c9f530be948a5f270167895705454596f6e61680718c"
        
        XCTAssertThrowsError(try mTxObj!.combineSignedRawTransactions([rlpEncoded])) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("Transactions containing different information cannot be combined."))
        }
    }
}

class ChainDataAnchoringTest_getRawTransactionTest: XCTestCase {
    var mTxObj: ChainDataAnchoring?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = ChainDataAnchoringTest.privateKey
    let from = ChainDataAnchoringTest.from
    let gas = ChainDataAnchoringTest.gas
    let nonce = ChainDataAnchoringTest.nonce
    let gasPrice = ChainDataAnchoringTest.gasPrice
    let chainID = ChainDataAnchoringTest.chainID
    let input = ChainDataAnchoringTest.input
    let signatureData = ChainDataAnchoringTest.signatureData
    let expectedRLPEncoding = ChainDataAnchoringTest.expectedRLPEncoding
    
    override func setUpWithError() throws {
        mTxObj = try ChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setChainId(chainID)
            .setInput(input)
            .setSignatures(signatureData)
            .build()
        
        coupledKeyring = try KeyringFactory.createFromPrivateKey(privateKey)
        deCoupledKeyring = try KeyringFactory.createWithSingleKey(PrivateKey.generate().getDerivedAddress(), privateKey)
        klaytnWalletKey = try coupledKeyring?.getKlaytnWalletKey()
    }
    
    public func test_getRawTransaction() throws {
        let rawTx = try mTxObj?.getRawTransaction()
        XCTAssertEqual(expectedRLPEncoding, rawTx)
    }
}

class ChainDataAnchoringTest_getTransactionHashTest: XCTestCase {
    var mTxObj: ChainDataAnchoring?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = ChainDataAnchoringTest.privateKey
    let from = ChainDataAnchoringTest.from
    let gas = ChainDataAnchoringTest.gas
    let nonce = ChainDataAnchoringTest.nonce
    let gasPrice = ChainDataAnchoringTest.gasPrice
    let chainID = ChainDataAnchoringTest.chainID
    let input = ChainDataAnchoringTest.input
    let signatureData = ChainDataAnchoringTest.signatureData
    let expectedRLPEncoding = ChainDataAnchoringTest.expectedRLPEncoding
    let expectedTransactionHash = ChainDataAnchoringTest.expectedTransactionHash
    
    override func setUpWithError() throws {
        mTxObj = try ChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setChainId(chainID)
            .setInput(input)
            .setSignatures(signatureData)
            .build()
        
        coupledKeyring = try KeyringFactory.createFromPrivateKey(privateKey)
        deCoupledKeyring = try KeyringFactory.createWithSingleKey(PrivateKey.generate().getDerivedAddress(), privateKey)
        klaytnWalletKey = try coupledKeyring?.getKlaytnWalletKey()
    }
        
    public func test_getTransactionHash() throws {
        let txHash = try mTxObj?.getTransactionHash()
        XCTAssertEqual(expectedTransactionHash, txHash)
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try ChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setChainId(chainID)
            .setInput(input)
            .setSignatures(signatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getTransactionHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_gasPrice() throws {
        let gasPrice = ""
        
        mTxObj = try ChainDataAnchoring.Builder()
            .setFrom(from)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setNonce(nonce)
            .setChainId(chainID)
            .setInput(input)
            .setSignatures(signatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getTransactionHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class ChainDataAnchoringTest_getSenderTxHashTest: XCTestCase {
    var mTxObj: ChainDataAnchoring?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = ChainDataAnchoringTest.privateKey
    let from = ChainDataAnchoringTest.from
    let gas = ChainDataAnchoringTest.gas
    let nonce = ChainDataAnchoringTest.nonce
    let gasPrice = ChainDataAnchoringTest.gasPrice
    let chainID = ChainDataAnchoringTest.chainID
    let input = ChainDataAnchoringTest.input
    let signatureData = ChainDataAnchoringTest.signatureData
    let expectedRLPEncoding = ChainDataAnchoringTest.expectedRLPEncoding
    let expectedTransactionHash = ChainDataAnchoringTest.expectedTransactionHash
    
    override func setUpWithError() throws {
        mTxObj = try ChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setChainId(chainID)
            .setInput(input)
            .setSignatures(signatureData)
            .build()
        
        coupledKeyring = try KeyringFactory.createFromPrivateKey(privateKey)
        deCoupledKeyring = try KeyringFactory.createWithSingleKey(PrivateKey.generate().getDerivedAddress(), privateKey)
        klaytnWalletKey = try coupledKeyring?.getKlaytnWalletKey()
    }
        
    public func test_getRLPEncodingForSignature() throws {
        let txHash = try mTxObj?.getSenderTxHash()
        XCTAssertEqual(expectedTransactionHash, txHash)
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try ChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setChainId(chainID)
            .setInput(input)
            .setSignatures(signatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getSenderTxHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_gasPrice() throws {
        let gasPrice = ""
        
        mTxObj = try ChainDataAnchoring.Builder()
            .setFrom(from)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setNonce(nonce)
            .setChainId(chainID)
            .setInput(input)
            .setSignatures(signatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getSenderTxHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class ChainDataAnchoringTest_getRLPEncodingForSignatureTest: XCTestCase {
    var mTxObj: ChainDataAnchoring?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = ChainDataAnchoringTest.privateKey
    let from = ChainDataAnchoringTest.from
    let gas = ChainDataAnchoringTest.gas
    let nonce = ChainDataAnchoringTest.nonce
    let gasPrice = ChainDataAnchoringTest.gasPrice
    let chainID = ChainDataAnchoringTest.chainID
    let input = ChainDataAnchoringTest.input
    let signatureData = ChainDataAnchoringTest.signatureData
    let expectedRLPEncoding = ChainDataAnchoringTest.expectedRLPEncoding
    let expectedTransactionHash = ChainDataAnchoringTest.expectedTransactionHash
    let expectedRLPEncodingForSigning = ChainDataAnchoringTest.expectedRLPEncodingForSigning
    
    override func setUpWithError() throws {
        mTxObj = try ChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setChainId(chainID)
            .setInput(input)
            .setSignatures(signatureData)
            .build()
        
        coupledKeyring = try KeyringFactory.createFromPrivateKey(privateKey)
        deCoupledKeyring = try KeyringFactory.createWithSingleKey(PrivateKey.generate().getDerivedAddress(), privateKey)
        klaytnWalletKey = try coupledKeyring?.getKlaytnWalletKey()
    }
        
    public func test_getRLPEncodingForSignature() throws {
        let rlp = try mTxObj?.getRLPEncodingForSignature()
        XCTAssertEqual(expectedRLPEncodingForSigning, rlp)
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try ChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setChainId(chainID)
            .setInput(input)
            .setSignatures(signatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_gasPrice() throws {
        let gasPrice = ""
        
        mTxObj = try ChainDataAnchoring.Builder()
            .setFrom(from)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setNonce(nonce)
            .setChainId(chainID)
            .setInput(input)
            .setSignatures(signatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_chainID() throws {
        let chainID = ""
        
        mTxObj = try ChainDataAnchoring.Builder()
            .setFrom(from)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setNonce(nonce)
            .setChainId(chainID)
            .setInput(input)
            .setSignatures(signatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("chainId is undefined. Define chainId in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}
