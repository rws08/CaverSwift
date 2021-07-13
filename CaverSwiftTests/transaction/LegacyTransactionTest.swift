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
    
    public func testThrowException_missing_value() throws {
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
    
    public func testThrowException_invalid_value() throws {
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
    
    public func testThrowException_invalid_To() throws {
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
    
    public func testThrowException_missingGas() throws {
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

class createInstanceBuilder: XCTestCase {
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
    
    public func testThrowException_invalid_value() throws {
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
    
    public func testThrowException_invalid_value2() throws {
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
    
    public func testThrowException_invalid_To() throws {
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
    
    public func testThrowException_missingGas() throws {
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

class signWithKeyTest2: XCTestCase {
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
}

class getRLPEncodingTest: XCTestCase {
    public func testGetRLPEncoding() throws {
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
        
        let expected = try LegacyTransaction.decode(expectedRLP)
        XCTAssertTrue(legacyTransaction.compareTxField(expected, true))
    }
}

class getRLPEncodingForSignatureTest: XCTestCase {
    public func testGetRLPEncodingForSignature() throws {
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
}

