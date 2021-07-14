//
//  LegacyTransactionTest.swift
//  CaverSwiftTests
//
//  Created by won on 2021/07/12.
//

import XCTest
@testable import CaverSwift

class LegacyTransactionTest: XCTestCase {
    let privateKey = "0x45a915e4d060149eb4365960e6a7a45f334393093061116b197e3240065ff2d8"
    let nonce = "0x4D2"
    let gas = "0xf4240"
    let gasPrice = "0x19"
    let to = "0x7b65b75d204abed71587c9e519a89277766ee1d0"
    let chainID = "0x1"
    let input = "0x31323334"
    let value = "0xa"
    
    public func testCreate() throws {
        let keyring = try KeyringFactory.createFromPrivateKey(privateKey)
        
        let legacyTransaction = try LegacyTransaction(
            nil,
            keyring.address,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            to,
            input,
            value
        )
        
        XCTAssertNotNil(legacyTransaction)
    }
    
    public func testCreateWithRPC() throws {
        let gas = "0x0f4240"
        let to = "7b65b75d204abed71587c9e519a89277766ee1d0"
        let input = "0x31323334"
        let value = "0x0a"

        let caver = Caver(Caver.DEFAULT_URL);
        let keyring = try KeyringFactory.createFromPrivateKey(privateKey)

        let legacyTransaction = try LegacyTransaction(
            caver.rpc.klay,
            keyring.address,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            to,
            input,
            value
        )

        try legacyTransaction.fillTransaction()
        
        XCTAssertNotNil(legacyTransaction.nonce)
        XCTAssertNotNil(legacyTransaction.gasPrice)
        XCTAssertNotNil(legacyTransaction.chainId)
    }
    
    public func test_throwException_missing_value() throws {
        XCTAssertThrowsError(try LegacyTransaction(
            nil,
            "0x",
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            to,
            input,
            ""
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("value is missing."))
        }
    }
    
    public func test_throwException_invalid_value() throws {
        let value = "invalid"
        XCTAssertThrowsError(try LegacyTransaction(
            nil,
            "0x",
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            to,
            input,
            value
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid value : \(value)"))
        }
    }
    
    public func test_throwException_invalid_To() throws {
        let to = "invalid"
        XCTAssertThrowsError(try LegacyTransaction(
            nil,
            "0x",
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            to,
            input,
            "0xa"
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(to)"))
        }
    }
    
    public func test_throwException_missingGas() throws {
        XCTAssertThrowsError(try LegacyTransaction.Builder()
                                .setNonce(nonce)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setInput(input)
                                .setValue(value)
                                .setTo(to)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("gas is missing."))
        }
    }
}

class LegacyTransactionTest_createInstanceBuilder: XCTestCase {
    let privateKey = "0x45a915e4d060149eb4365960e6a7a45f334393093061116b197e3240065ff2d8"
    let nonce = "0x4D2"
    let gas = "0xf4240"
    let gasPrice = "0x19"
    let to = "0x7b65b75d204abed71587c9e519a89277766ee1d0"
    let chainID = "0x1"
    let input = "0x31323334"
    let value = "0xa"
        
    public func testBuilderTest() throws {
        let legacyTransaction = try LegacyTransaction.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setInput(input)
            .setValue(value)
            .setTo(to)
            .build()
        
        XCTAssertNotNil(legacyTransaction)
    }
    
    public func testBuilderTestWithBigInteger() throws {
        let legacyTransaction = try LegacyTransaction.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(BigInt(hex: gasPrice)!)
            .setChainId(BigInt(hex: chainID)!)
            .setInput(input)
            .setValue(BigInt(hex: value)!)
            .setTo(to)
            .build()
        
        XCTAssertEqual(gas, legacyTransaction.gas)
        XCTAssertEqual(gasPrice, legacyTransaction.gasPrice)
        XCTAssertEqual(chainID.addHexPrefix, legacyTransaction.chainId)
        XCTAssertEqual(value, legacyTransaction.value)
    }
    
    public func testBuilderTestRPC() throws {
        let gas = "0x0f4240"
        let to = "7b65b75d204abed71587c9e519a89277766ee1d0"
        let input = "0x31323334"
        let value = "0x0a"

        let caver = Caver(Caver.DEFAULT_URL);
        let keyring = try KeyringFactory.createFromPrivateKey(privateKey)

        let legacyTransaction = try LegacyTransaction.Builder()
            .setKlaytnCall(caver.rpc.klay)
            .setGas(gas)
            .setInput(input)
            .setValue(value)
            .setFrom(keyring.address)
            .setTo(to)
            .build()

        try legacyTransaction.fillTransaction()
        
        XCTAssertNotNil(legacyTransaction.nonce)
        XCTAssertNotNil(legacyTransaction.gasPrice)
        XCTAssertNotNil(legacyTransaction.chainId)
    }
    
    public func test_throwException_invalid_value() throws {
        let value = "0x"
        XCTAssertThrowsError(try LegacyTransaction.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setInput(input)
                                .setTo(to)
                                .setValue(value)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid value : \(value)"))
        }
    }
    
    public func test_throwException_invalid_value2() throws {
        let value = "invalid"
        XCTAssertThrowsError(try LegacyTransaction.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setInput(input)
                                .setTo(to)
                                .setValue(value)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid value : \(value)"))
        }
    }
    
    public func test_throwException_invalid_To() throws {
        let to = "invalid"
        XCTAssertThrowsError(try LegacyTransaction.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setInput(input)
                                .setTo(to)
                                .setValue(value)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(to)"))
        }
    }
    
    public func test_throwException_missingGas() throws {
        XCTAssertThrowsError(try LegacyTransaction.Builder()
                                .setNonce(nonce)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setInput(input)
                                .setTo(to)
                                .setValue(value)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("gas is missing."))
        }
    }
}

class LegacyTransactionTest_signWithKeyTest: XCTestCase {
    var caver: Caver?
    
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = "0x45a915e4d060149eb4365960e6a7a45f334393093061116b197e3240065ff2d8"
    let nonce = "0x4D2"
    let gas = "0xf4240"
    let gasPrice = "0x19"
    let to = "0x7b65b75d204abed71587c9e519a89277766ee1d0"
    let chainID = "0x1"
    let input = "0x31323334"
    let value = "0xa"
    
    let expectedRawTransaction = "0xf8668204d219830f4240947b65b75d204abed71587c9e519a89277766ee1d00a843132333425a0b2a5a15550ec298dc7dddde3774429ed75f864c82caeb5ee24399649ad731be9a029da1014d16f2011b3307f7bbe1035b6e699a4204fc416c763def6cefd976567"
    
    public func createLegacyTransaction() throws -> LegacyTransaction{
        return try LegacyTransaction.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setInput(input)
            .setTo(to)
            .setValue(value)
            .build()
    }
    
    override func setUpWithError() throws {
        caver = Caver(Caver.DEFAULT_URL)
        coupledKeyring = try KeyringFactory.createFromPrivateKey(privateKey)
        deCoupledKeyring = try KeyringFactory.createWithSingleKey(PrivateKey.generate().getDerivedAddress(), PrivateKey.generate().privateKey)
    }
    
    public func testSignWithKey_Keyring() throws {
        let legacyTransaction = try createLegacyTransaction()
        let tx = try legacyTransaction.sign(coupledKeyring!, 0, TransactionHasher.getHashForSignature(_:))
        XCTAssertEqual(expectedRawTransaction, try tx.getRawTransaction())
    }
    
    public func testSignWithKey_Keyring_NoIndex() throws {
        let legacyTransaction = try createLegacyTransaction()
        let tx = try legacyTransaction.sign(coupledKeyring!, TransactionHasher.getHashForSignature(_:))
        XCTAssertEqual(expectedRawTransaction, try tx.getRawTransaction())
    }
    
    public func testSignWithKey_Keyring_NoSigner() throws {
        let legacyTransaction = try createLegacyTransaction()
        let tx = try legacyTransaction.sign(coupledKeyring!, 0)
        XCTAssertEqual(expectedRawTransaction, try tx.getRawTransaction())
    }
    
    public func testSignWithKey_Keyring_Only() throws {
        let legacyTransaction = try createLegacyTransaction()
        let tx = try legacyTransaction.sign(coupledKeyring!)
        XCTAssertEqual(expectedRawTransaction, try tx.getRawTransaction())
    }
    
    public func testSignWithKey_KeyString_NoIndex() throws {
        let legacyTransaction = try createLegacyTransaction()
        let tx = try legacyTransaction.sign(privateKey, TransactionHasher.getHashForSignature(_:))
        XCTAssertEqual(expectedRawTransaction, try tx.getRawTransaction())
    }
    
    public func test_throwException_decoupledKey() throws {
        let legacyTransaction = try createLegacyTransaction()
        XCTAssertThrowsError(try legacyTransaction.sign(deCoupledKeyring!)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("A legacy transaction cannot be signed with a decoupled keyring."))
        }
    }
    
    public func test_throwException_notEqualAddress() throws {
        let legacyTransaction = try LegacyTransaction.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setInput(input)
            .setValue(value)
            .setFrom("0x7b65b75d204abed71587c9e519a89277766aaaa1")
            .setTo(to)
            .build()
        
        XCTAssertThrowsError(try legacyTransaction.sign(coupledKeyring!)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("The from address of the transaction is different with the address of the keyring to use"))
        }
    }
}

class LegacyTransactionTest_signWithKeysTest: XCTestCase {
    var caver: Caver?
    
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = "0x45a915e4d060149eb4365960e6a7a45f334393093061116b197e3240065ff2d8"
    let nonce = "0x4D2"
    let gas = "0xf4240"
    let gasPrice = "0x19"
    let to = "0x7b65b75d204abed71587c9e519a89277766ee1d0"
    let chainID = "0x1"
    let input = "0x31323334"
    let value = "0xa"
    
    let expectedRawTransaction = "0xf8668204d219830f4240947b65b75d204abed71587c9e519a89277766ee1d00a843132333425a0b2a5a15550ec298dc7dddde3774429ed75f864c82caeb5ee24399649ad731be9a029da1014d16f2011b3307f7bbe1035b6e699a4204fc416c763def6cefd976567"
    
    public func createLegacyTransaction() throws -> LegacyTransaction{
        return try LegacyTransaction.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setInput(input)
            .setTo(to)
            .setValue(value)
            .build()
    }
    
    override func setUpWithError() throws {
        caver = Caver(Caver.DEFAULT_URL)
        coupledKeyring = try KeyringFactory.createFromPrivateKey(privateKey)
        deCoupledKeyring = try KeyringFactory.createWithSingleKey(PrivateKey.generate().getDerivedAddress(), PrivateKey.generate().privateKey)
    }
    
    public func testSignWithKeys_Keyring() throws {
        let legacyTransaction = try createLegacyTransaction()
        let tx = try legacyTransaction.sign(coupledKeyring!, TransactionHasher.getHashForSignature(_:))
        XCTAssertEqual(expectedRawTransaction, try tx.getRawTransaction())
    }
    
    public func testSignWithKeys_Keyring_NoSigner() throws {
        let legacyTransaction = try createLegacyTransaction()
        let tx = try legacyTransaction.sign(coupledKeyring!)
        XCTAssertEqual(expectedRawTransaction, try tx.getRawTransaction())
    }
    
    public func testSignWithKeys_KeyString() throws {
        let legacyTransaction = try createLegacyTransaction()
        let tx = try legacyTransaction.sign(privateKey, TransactionHasher.getHashForSignature(_:))
        XCTAssertEqual(expectedRawTransaction, try tx.getRawTransaction())
    }
    
    public func testSignWithKeys_KeyString_KlaytnWalletKeyFormat() throws {
        let legacyTransaction = try createLegacyTransaction()
        let klaytnKey = privateKey + "0x00" + (try KeyringFactory.createFromPrivateKey(privateKey).address)
        let tx = try legacyTransaction.sign(klaytnKey, TransactionHasher.getHashForSignature(_:))
        XCTAssertEqual(expectedRawTransaction, try tx.getRawTransaction())
    }
    
    public func testSignWithKeys_KeyString_NoSigner() throws {
        let legacyTransaction = try createLegacyTransaction()
        let tx = try legacyTransaction.sign(privateKey)
        XCTAssertEqual(expectedRawTransaction, try tx.getRawTransaction())
    }
    
    public func test_throwException_decoupledKey() throws {
        let legacyTransaction = try createLegacyTransaction()
        XCTAssertThrowsError(try legacyTransaction.sign(deCoupledKeyring!)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("A legacy transaction cannot be signed with a decoupled keyring."))
        }
    }
    
    public func test_throwException_KlaytnWalletKeyFormat_decoupledKey() throws {
        let legacyTransaction = try createLegacyTransaction()
        let klaytnKey = privateKey + "0x00" + KeyringFactory.generate()!.address
        XCTAssertThrowsError(try legacyTransaction.sign(klaytnKey)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("A legacy transaction cannot be signed with a decoupled keyring."))
        }
    }
    
    public func test_throwException_multipleKeyring() throws {
        let legacyTransaction = try createLegacyTransaction()
        let privateKeyArr = [
            PrivateKey.generate().privateKey,
            PrivateKey.generate().privateKey
        ]
        let keyring = try KeyringFactory.createWithMultipleKey(PrivateKey.generate().getDerivedAddress(), privateKeyArr)
        XCTAssertThrowsError(try legacyTransaction.sign(keyring)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("A legacy transaction cannot be signed with a decoupled keyring."))
        }
    }
    
    public func test_throwException_roleBasedKeyring() throws {
        let legacyTransaction = try createLegacyTransaction()
        let privateKeyArr = [
            [
                PrivateKey.generate().privateKey,
                PrivateKey.generate().privateKey
            ],
            [
                PrivateKey.generate().privateKey,
                PrivateKey.generate().privateKey
            ],
            [
                PrivateKey.generate().privateKey,
                PrivateKey.generate().privateKey
            ]
        ]
        let keyring = try KeyringFactory.createWithRoleBasedKey(PrivateKey.generate().getDerivedAddress(), privateKeyArr)
        XCTAssertThrowsError(try legacyTransaction.sign(keyring)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("A legacy transaction cannot be signed with a decoupled keyring."))
        }
    }
    
    public func test_throwException_notEqualAddress() throws {
        let legacyTransaction = try LegacyTransaction.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setInput(input)
            .setValue(value)
            .setFrom("0x7b65b75d204abed71587c9e519a89277766aaaa1")
            .setTo(to)
            .build()
        let keyring = try KeyringFactory.createFromPrivateKey(privateKey)
        XCTAssertThrowsError(try legacyTransaction.sign(keyring)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("The from address of the transaction is different with the address of the keyring to use"))
        }
    }
}

class LegacyTransactionTest_getRLPEncodingTest: XCTestCase {
    let nonce = "0x4D2"
    let gas = "0xf4240"
    let gasPrice = "0x19"
    let to = "0x7b65b75d204abed71587c9e519a89277766ee1d0"
    let chainID = "0x1"
    let input = "0x31323334"
    let value = "0xa"
    
    let signatureData = SignatureData(
        "0x25",
        "0xb2a5a15550ec298dc7dddde3774429ed75f864c82caeb5ee24399649ad731be9",
        "0x29da1014d16f2011b3307f7bbe1035b6e699a4204fc416c763def6cefd976567"
    )
    
    public func testGetRLPEncoding() throws {
        let legacyTransaction = try LegacyTransaction.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setInput(input)
            .setSignatures([signatureData])
            .setTo(to)
            .build()
        
        let expectedRLP = "0xf8668204d219830f4240947b65b75d204abed71587c9e519a89277766ee1d00a843132333425a0b2a5a15550ec298dc7dddde3774429ed75f864c82caeb5ee24399649ad731be9a029da1014d16f2011b3307f7bbe1035b6e699a4204fc416c763def6cefd976567"
        XCTAssertEqual(expectedRLP, try legacyTransaction.getRLPEncoding())
    }
    
    public func test_throwException_NoNonce() throws {
        let legacyTransaction = try LegacyTransaction.Builder()
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setInput(input)
            .setSignatures([signatureData])
            .setTo(to)
            .build()
        
        XCTAssertThrowsError(try legacyTransaction.getRLPEncoding()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NoGasPrice() throws {
        let legacyTransaction = try LegacyTransaction.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setChainId(chainID)
            .setValue(value)
            .setInput(input)
            .setSignatures([signatureData])
            .setTo(to)
            .build()
        
        XCTAssertThrowsError(try legacyTransaction.getRLPEncoding()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class LegacyTransactionTest_combineSignatureTest: XCTestCase {
    let to = "0x8723590d5D60e35f7cE0Db5C09D3938b26fF80Ae"
    let value = BigInt(1)
    let gas = BigInt(90000)
    let gasPrice = "0x5d21dba00"
    let nonce = "0x3a"
    let chainID = BigInt(2019)
    
    let signatureData = SignatureData(
        "0x25",
        "0xb2a5a15550ec298dc7dddde3774429ed75f864c82caeb5ee24399649ad731be9",
        "0x29da1014d16f2011b3307f7bbe1035b6e699a4204fc416c763def6cefd976567"
    )
    
    let rlpEncoded = "0xf8673a8505d21dba0083015f90948723590d5d60e35f7ce0db5c09d3938b26ff80ae0180820feaa0ade9480f584fe481bf070ab758ecc010afa15debc33e1bd75af637d834073a6ea038160105d78cef4529d765941ad6637d8dcf6bd99310e165fee1c39fff2aa27e"
    
    public func testCombineSignature() throws {        
        let legacyTransaction = try LegacyTransaction.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setTo(to)
            .build()
                
        let combined = try legacyTransaction.combineSignedRawTransactions([rlpEncoded])
        XCTAssertEqual(rlpEncoded, combined)
    }
    
    public func testCombineSignature_EmptySig() throws {
        let emptySig = SignatureData.getEmptySignature()
        
        let legacyTransaction = try LegacyTransaction.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setTo(to)
            .setSignatures(emptySig)
            .build()
        
        let combined = try legacyTransaction.combineSignedRawTransactions([rlpEncoded])
        XCTAssertEqual(rlpEncoded, combined)
    }
    
    public func test_throwException_existSignature() throws {
        let signatureData = SignatureData(
            "0x0fea",
            "0xade9480f584fe481bf070ab758ecc010afa15debc33e1bd75af637d834073a6e",
            "0x38160105d78cef4529d765941ad6637d8dcf6bd99310e165fee1c39fff2aa27e"
        )
        
        let legacyTransaction = try LegacyTransaction.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setTo(to)
            .setSignatures([signatureData])
            .build()
        
        XCTAssertThrowsError(try legacyTransaction.combineSignedRawTransactions([rlpEncoded])) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("Signatures already defined.\(TransactionType.TxTypeLegacyTransaction.string) cannot include more than one signature."))
        }
    }
    
    public func test_throwException_differentField() throws {
        let nonce = "0x3F"
        
        let legacyTransaction = try LegacyTransaction.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setTo(to)
            .setSignatures([signatureData])
            .build()
        
        XCTAssertThrowsError(try legacyTransaction.combineSignedRawTransactions([rlpEncoded])) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("Transactions containing different information cannot be combined."))
        }
    }
}

class LegacyTransactionTest_getRawTransactionTest: XCTestCase {
    let to = "0x8723590d5D60e35f7cE0Db5C09D3938b26fF80Ae"
    let value = BigInt(1)
    let gas = BigInt(90000)
    let gasPrice = "0x5d21dba00"
    let nonce = "0x3a"
    let chainID = BigInt(2019)
    
    let signatureData = SignatureData(
        "0x0fea",
        "0xade9480f584fe481bf070ab758ecc010afa15debc33e1bd75af637d834073a6e",
        "0x38160105d78cef4529d765941ad6637d8dcf6bd99310e165fee1c39fff2aa27e"
    )
    
    let rlpEncoded = "0xf8673a8505d21dba0083015f90948723590d5d60e35f7ce0db5c09d3938b26ff80ae0180820feaa0ade9480f584fe481bf070ab758ecc010afa15debc33e1bd75af637d834073a6ea038160105d78cef4529d765941ad6637d8dcf6bd99310e165fee1c39fff2aa27e"
    
    public func testGetRawTransaction() throws {
        let legacyTransaction = try LegacyTransaction.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setTo(to)
            .setSignatures(signatureData)
            .build()
        
        let raw = try legacyTransaction.getRawTransaction()
        XCTAssertEqual(rlpEncoded, raw)
    }
}

class LegacyTransactionTest_getTransactionHashTest: XCTestCase {
    let nonce = BigInt(1234)
    let gas = "0xf4240"
    let gasPrice = "0x19"
    let to = "0x7b65b75d204abed71587c9e519a89277766ee1d0"
    let chainID = "0x1"
    let input = "0x31323334"
    let value = "0xa"
    
    let signatureData = SignatureData(
        "0x25",
        "0xb2a5a15550ec298dc7dddde3774429ed75f864c82caeb5ee24399649ad731be9",
        "0x29da1014d16f2011b3307f7bbe1035b6e699a4204fc416c763def6cefd976567"
    )
    
    public func testGetTransactionHash() throws {
        let legacyTransaction = try LegacyTransaction.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setInput(input)
            .setSignatures([signatureData])
            .setTo(to)
            .build()
        
        let expected = "0xe434257753bf31a130c839fec0bd34fc6ea4aa256b825288ee82db31c2ed7524"
        XCTAssertEqual(expected, try legacyTransaction.getTransactionHash())
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let legacyTransaction = try LegacyTransaction.Builder()
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setInput(input)
            .setSignatures([signatureData])
            .setTo(to)
            .build()
                
        XCTAssertThrowsError(try legacyTransaction.getRawTransaction()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_gasPrice() throws {
        let legacyTransaction = try LegacyTransaction.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setChainId(chainID)
            .setValue(value)
            .setInput(input)
            .setSignatures([signatureData])
            .setTo(to)
            .build()
                
        XCTAssertThrowsError(try legacyTransaction.getRawTransaction()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class LegacyTransactionTest_getSenderTxHashTest: XCTestCase {
    let nonce = BigInt(1234)
    let gas = "0xf4240"
    let gasPrice = "0x19"
    let to = "0x7b65b75d204abed71587c9e519a89277766ee1d0"
    let chainID = "0x1"
    let input = "0x31323334"
    let value = "0xa"
    
    let signatureData = SignatureData(
        "0x25",
        "0xb2a5a15550ec298dc7dddde3774429ed75f864c82caeb5ee24399649ad731be9",
        "0x29da1014d16f2011b3307f7bbe1035b6e699a4204fc416c763def6cefd976567"
    )
    
    public func testGetRLPEncodingForSignature() throws {
        let legacyTransaction = try LegacyTransaction.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setInput(input)
            .setSignatures([signatureData])
            .setTo(to)
            .build()
        
        let expected = "0xe434257753bf31a130c839fec0bd34fc6ea4aa256b825288ee82db31c2ed7524"
        XCTAssertEqual(expected, try legacyTransaction.getSenderTxHash())
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let legacyTransaction = try LegacyTransaction.Builder()
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setInput(input)
            .setSignatures([signatureData])
            .setTo(to)
            .build()
                
        XCTAssertThrowsError(try legacyTransaction.getSenderTxHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_gasPrice() throws {
        let legacyTransaction = try LegacyTransaction.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setChainId(chainID)
            .setValue(value)
            .setInput(input)
            .setSignatures([signatureData])
            .setTo(to)
            .build()
                
        XCTAssertThrowsError(try legacyTransaction.getSenderTxHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class LegacyTransactionTest_getRLPEncodingForSignatureTest: XCTestCase {
    let nonce = BigInt(1234)
    let gas = "0xf4240"
    let gasPrice = "0x19"
    let to = "0x7b65b75d204abed71587c9e519a89277766ee1d0"
    let chainID = "0x1"
    let input = "0x31323334"
    let value = "0xa"
    
    let signatureData = SignatureData(
        "0x25",
        "0xb2a5a15550ec298dc7dddde3774429ed75f864c82caeb5ee24399649ad731be9",
        "0x29da1014d16f2011b3307f7bbe1035b6e699a4204fc416c763def6cefd976567"
    )
    
    public func testGetRLPEncodingForSignature() throws {
        let legacyTransaction = try LegacyTransaction.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setInput(input)
            .setSignatures([signatureData])
            .setTo(to)
            .build()
        
        let expected = "0xe68204d219830f4240947b65b75d204abed71587c9e519a89277766ee1d00a8431323334018080"
        XCTAssertEqual(expected, try legacyTransaction.getRLPEncodingForSignature())
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let legacyTransaction = try LegacyTransaction.Builder()
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setInput(input)
            .setSignatures([signatureData])
            .setTo(to)
            .build()
                
        XCTAssertThrowsError(try legacyTransaction.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_gasPrice() throws {
        let legacyTransaction = try LegacyTransaction.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setChainId(chainID)
            .setValue(value)
            .setInput(input)
            .setSignatures([signatureData])
            .setTo(to)
            .build()
                
        XCTAssertThrowsError(try legacyTransaction.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_gasChainID() throws {
        let legacyTransaction = try LegacyTransaction.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setValue(value)
            .setInput(input)
            .setSignatures([signatureData])
            .setTo(to)
            .build()
                
        XCTAssertThrowsError(try legacyTransaction.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("chainId is undefined. Define chainId in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class LegacyTransactionTest_appendSignaturesTest: XCTestCase {
    let to = "0x8723590d5D60e35f7cE0Db5C09D3938b26fF80Ae"
    let value = BigInt(1)
    let gas = BigInt(90000)
    let gasPrice = "0x5d21dba00"
    let nonce = "0x3a"
    let chainID = BigInt(2019)
    
    let signatureData = SignatureData(
        "0x0fea",
        "0xade9480f584fe481bf070ab758ecc010afa15debc33e1bd75af637d834073a6e",
        "0x38160105d78cef4529d765941ad6637d8dcf6bd99310e165fee1c39fff2aa27e"
    )
    
    let rlpEncoded = "0xf8673a8505d21dba0083015f90948723590d5d60e35f7ce0db5c09d3938b26ff80ae0180820feaa0ade9480f584fe481bf070ab758ecc010afa15debc33e1bd75af637d834073a6ea038160105d78cef4529d765941ad6637d8dcf6bd99310e165fee1c39fff2aa27e"
    
    public func testAppendSignature() throws {
        let legacyTransaction = try LegacyTransaction.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setTo(to)
            .build()
        
        try legacyTransaction.appendSignatures(signatureData)

        XCTAssertEqual(signatureData, legacyTransaction.signatures[0])
    }
    
    public func testAppendSignatureWithEmptySig() throws {
        let legacyTransaction = try LegacyTransaction.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setTo(to)
            .setSignatures(SignatureData.getEmptySignature())
            .build()
        
        try legacyTransaction.appendSignatures(signatureData)

        XCTAssertEqual(signatureData, legacyTransaction.signatures[0])
    }
    
    public func testAppendSignatureList() throws {
        let legacyTransaction = try LegacyTransaction.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setTo(to)
            .build()
        
        try legacyTransaction.appendSignatures([signatureData])

        XCTAssertEqual(signatureData, legacyTransaction.signatures[0])
    }
    
    public func testAppendSignatureList_EmptySig() throws {
        let legacyTransaction = try LegacyTransaction.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setTo(to)
            .setSignatures(SignatureData.getEmptySignature())
            .build()
        
        try legacyTransaction.appendSignatures([signatureData])

        XCTAssertEqual(signatureData, legacyTransaction.signatures[0])
    }
    
    public func test_throwException_appendData_existsSignatureInTransaction() throws {
        let legacyTransaction = try LegacyTransaction.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setSignatures([signatureData])
            .setTo(to)
            .build()
                
        XCTAssertThrowsError(try legacyTransaction.appendSignatures(signatureData)) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("Signatures already defined.\(TransactionType.TxTypeLegacyTransaction.string) cannot include more than one signature."))
        }
    }
    
    public func test_throwException_appendList_existsSignatureInTransaction() throws {
        let legacyTransaction = try LegacyTransaction.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setSignatures([signatureData])
            .setTo(to)
            .build()
                
        XCTAssertThrowsError(try legacyTransaction.appendSignatures([signatureData])) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("Signatures already defined.\(TransactionType.TxTypeLegacyTransaction.string) cannot include more than one signature."))
        }
    }
    
    public func test_throwException_tooLongSignatures() throws {
        let legacyTransaction = try LegacyTransaction.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setTo(to)
            .build()
                
        XCTAssertThrowsError(try legacyTransaction.appendSignatures([signatureData, signatureData])) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("Signatures are too long \(TransactionType.TxTypeLegacyTransaction.string) cannot include more than one signature."))
        }
    }
}

