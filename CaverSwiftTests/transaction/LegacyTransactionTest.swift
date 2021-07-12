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
