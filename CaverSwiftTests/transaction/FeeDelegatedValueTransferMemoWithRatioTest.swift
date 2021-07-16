//
//  FeeDelegatedValueTransferMemoWithRatioTest.swift
//  CaverSwiftTests
//
//  Created by won on 2021/07/16.
//

import XCTest
@testable import CaverSwift

class FeeDelegatedValueTransferMemoWithRatioTest: XCTestCase {
    static let caver = Caver(Caver.DEFAULT_URL)
    
    static let privateKey = "0x45a915e4d060149eb4365960e6a7a45f334393093061116b197e3240065ff2d8"
    static let feePayerPrivateKey = "0xb9d5558443585bca6f225b935950e3f6e69f9da8a5809a83f51c3365dff53936"
    static let from = "0xa94f5374Fce5edBC8E2a8697C15331677e6EbF0B"
    static let account = Account.createWithAccountKeyLegacy(from)
    static let to = "0x7b65B75d204aBed71587c9E519a89277766EE1d0"
    static let gas = "0xf4240"
    static let gasPrice = "0x19"
    static let nonce = "0x4d2"
    static let chainID = "0x1"
    static let value = "0xa"
    static let input = "0x68656c6c6f"
    static let humanReadable = false
    static let codeFormat = CodeFormat.EVM.hexa
    static let feeRatio = BigInt(30)

    static let senderSignatureData = SignatureData(
        "0x26",
        "0x769f0afdc310289f9b24decb5bb765c8d7a87a6a4ae28edffb8b7085bbd9bc78",
        "0x6a7b970eea026e60ac29bb52aee10661a4222e6bdcdfb3839a80586e584586b4"
    )
    static let feePayer = "0x5A0043070275d9f6054307Ee7348bD660849D90f"
    static let feePayerSignatureData = SignatureData(
        "0x25",
        "0xc1c54bdc72ce7c08821329bf50542535fac74f4bba5de5b7881118a461d52834",
        "0x3a3a64878d784f9af91c2e3ab9c90f17144c47cfd9951e3588c75063c0649ecd"
    )

    static let expectedRLPEncoding = "0x12f8dd8204d219830f4240947b65b75d204abed71587c9e519a89277766ee1d00a94a94f5374fce5edbc8e2a8697c15331677e6ebf0b8568656c6c6f1ef845f84326a0769f0afdc310289f9b24decb5bb765c8d7a87a6a4ae28edffb8b7085bbd9bc78a06a7b970eea026e60ac29bb52aee10661a4222e6bdcdfb3839a80586e584586b4945a0043070275d9f6054307ee7348bd660849d90ff845f84325a0c1c54bdc72ce7c08821329bf50542535fac74f4bba5de5b7881118a461d52834a03a3a64878d784f9af91c2e3ab9c90f17144c47cfd9951e3588c75063c0649ecd"
    static let expectedTransactionHash = "0xabcb0fd8ebb8f62ac899e5211b9ba47fe948a8efd815229cc4ed9cd781464f15"
    static let expectedRLPSenderTransactionHash = "0x2c4e8cd3c68a4aacae51c695e857cfc1a019037ca71d8cd1e8ca56ec4eaf55b1"
    static let expectedRLPEncodingForFeePayerSigning = "0xf857b83df83b128204d219830f4240947b65b75d204abed71587c9e519a89277766ee1d00a94a94f5374fce5edbc8e2a8697c15331677e6ebf0b8568656c6c6f1e945a0043070275d9f6054307ee7348bd660849d90f018080"
        
    public static func generateRoleBaseKeyring(_ numArr: [Int], _ address: String) throws -> AbstractKeyring {
        let keyArr = KeyringFactory.generateRoleBasedKeys(numArr, "entropy")
        return try KeyringFactory.createWithRoleBasedKey(address, keyArr)
    }
}

class FeeDelegatedValueTransferMemoWithRatioTest_createInstanceBuilder: XCTestCase {
    let from = FeeDelegatedValueTransferMemoWithRatioTest.from
    let account = FeeDelegatedValueTransferMemoWithRatioTest.account
    let to = FeeDelegatedValueTransferMemoWithRatioTest.to
    let gas = FeeDelegatedValueTransferMemoWithRatioTest.gas
    let nonce = FeeDelegatedValueTransferMemoWithRatioTest.nonce
    let gasPrice = FeeDelegatedValueTransferMemoWithRatioTest.gasPrice
    let chainID = FeeDelegatedValueTransferMemoWithRatioTest.chainID
    let value = FeeDelegatedValueTransferMemoWithRatioTest.value
    let input = FeeDelegatedValueTransferMemoWithRatioTest.input
    let humanReadable = FeeDelegatedValueTransferMemoWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferMemoWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferMemoWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedValueTransferMemoWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferMemoWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedValueTransferMemoWithRatioTest.feeRatio
        
    public func test_BuilderTest() throws {
        let txObj = try FeeDelegatedValueTransferMemoWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setInput(input)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertNotNil(txObj)
    }
    
    public func test_BuilderWithRPCTest() throws {
        let txObj = try FeeDelegatedValueTransferMemoWithRatio.Builder()
            .setKlaytnCall(FeeDelegatedValueTransferMemoWithRatioTest.caver.rpc.klay)
            .setGas(gas)
            .setTo(to)
            .setValue(value)
            .setInput(input)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        try txObj.fillTransaction()
        
        XCTAssertFalse(txObj.nonce.isEmpty)
        XCTAssertFalse(txObj.gasPrice.isEmpty)
        XCTAssertFalse(txObj.chainId.isEmpty)
    }
    
    public func test_BuilderTestWithBigInteger() throws {
        let txObj = try FeeDelegatedValueTransferMemoWithRatio.Builder()
            .setNonce(BigInt(hex: nonce)!)
            .setGas(BigInt(hex: gas)!)
            .setGasPrice(BigInt(hex: gasPrice)!)
            .setChainId(BigInt(hex: chainID)!)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertNotNil(txObj)
        
        XCTAssertEqual(gas, txObj.gas)
        XCTAssertEqual(gasPrice, txObj.gasPrice)
        XCTAssertEqual(chainID, txObj.chainId)
    }
    
    public func test_throwException_invalidFrom() throws {
        let from = "invalid Address"
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemoWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setFeePayer(feePayer)
                                .setFeeRatio(feeRatio)
                                .setInput(input)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(from)"))
        }
    }
    
    public func test_throwException_missingFrom() throws {
        let from = ""
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemoWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setFeePayer(feePayer)
                                .setFeeRatio(feeRatio)
                                .setInput(input)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("from is missing."))
        }
    }
    
    public func test_throwException_invalidTo() throws {
        let to = "invalid input"
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemoWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setFeePayer(feePayer)
                                .setFeeRatio(feeRatio)
                                .setInput(input)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(to)"))
        }
    }
    
    public func test_throwException_missingTo() throws {
        let to = ""
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemoWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setFeePayer(feePayer)
                                .setFeeRatio(feeRatio)
                                .setInput(input)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("to is missing."))
        }
    }
    
    public func test_throwException_invalidValue() throws {
        let value = "invalid value"
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemoWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setFeePayer(feePayer)
                                .setFeeRatio(feeRatio)
                                .setInput(input)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid value : \(value)"))
        }
    }
    
    public func test_throwException_missingValue() throws {
        let value = ""
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemoWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setFeePayer(feePayer)
                                .setFeeRatio(feeRatio)
                                .setInput(input)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("value is missing."))
        }
    }
        
    public func test_throwException_invalidGas() throws {
        let gas = "invalid gas"
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemoWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setFeePayer(feePayer)
                                .setFeeRatio(feeRatio)
                                .setInput(input)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid gas. : \(gas)"))
        }
    }
    
    public func test_throwException_missingGas() throws {
        let gas = ""
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemoWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setFeePayer(feePayer)
                                .setFeeRatio(feeRatio)
                                .setInput(input)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("gas is missing."))
        }
    }
    
    public func test_throwException_invalidInput() throws {
        let input = "invalid input"
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemoWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setFeePayer(feePayer)
                                .setFeeRatio(feeRatio)
                                .setInput(input)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid input. : \(input)"))
        }
    }
    
    public func test_throwException_missingInput() throws {
        let input = ""
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemoWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setFeePayer(feePayer)
                                .setFeeRatio(feeRatio)
                                .setInput(input)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("input is missing."))
        }
    }
    
    public func test_throwException_setFeePayerSignatures_missingFeePayer() throws {
        let feePayer = ""
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemoWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setFeePayer(feePayer)
                                .setFeeRatio(feeRatio)
                                .setInput(input)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("feePayer is missing: feePayer must be defined with feePayerSignatures."))
        }
    }
    
    public func test_throwException_FeeRatio_invalid() throws {
        let feeRatio = "invalid fee ratio"
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemoWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setFeePayer(feePayer)
                                .setFeeRatio(feeRatio)
                                .setInput(input)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid type of feeRatio: feeRatio should be number type or hex number string"))
        }
    }
    
    public func test_throwException_FeeRatio_outOfRange() throws {
        let feeRatio = BigInt(101)
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemoWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setFeePayer(feePayer)
                                .setFeeRatio(feeRatio)
                                .setInput(input)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid feeRatio: feeRatio is out of range. [1,99]"))
        }
    }
    
    public func test_throwException_missingFeeRatio() throws {
        let feeRatio = ""
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemoWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setFeePayer(feePayer)
                                .setFeeRatio(feeRatio)
                                .setInput(input)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("feeRatio is missing."))
        }
    }
}

class FeeDelegatedValueTransferMemoWithRatioTest_createInstance: XCTestCase {
    let from = FeeDelegatedValueTransferMemoWithRatioTest.from
    let account = FeeDelegatedValueTransferMemoWithRatioTest.account
    let to = FeeDelegatedValueTransferMemoWithRatioTest.to
    let gas = FeeDelegatedValueTransferMemoWithRatioTest.gas
    let nonce = FeeDelegatedValueTransferMemoWithRatioTest.nonce
    let gasPrice = FeeDelegatedValueTransferMemoWithRatioTest.gasPrice
    let chainID = FeeDelegatedValueTransferMemoWithRatioTest.chainID
    let value = FeeDelegatedValueTransferMemoWithRatioTest.value
    let input = FeeDelegatedValueTransferMemoWithRatioTest.input
    let humanReadable = FeeDelegatedValueTransferMemoWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferMemoWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferMemoWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedValueTransferMemoWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferMemoWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedValueTransferMemoWithRatioTest.feeRatio.hexa
    
    public func test_createInstance() throws {
        let txObj = try FeeDelegatedValueTransferMemoWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            feeRatio,
            to,
            value,
            input
        )
        
        XCTAssertNotNil(txObj)
    }
    
    public func test_throwException_invalidFrom() throws {
        let from = "invalid Address"
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemoWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            feeRatio,
            to,
            value,
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(from)"))
        }
    }
    
    public func test_throwException_missingFrom() throws {
        let from = ""
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemoWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            feeRatio,
            to,
            value,
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("from is missing."))
        }
    }
    
    public func test_throwException_invalidTo() throws {
        let to = "invalid Address"
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemoWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            feeRatio,
            to,
            value,
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(to)"))
        }
    }
    
    public func test_throwException_missingTo() throws {
        let to = ""
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemoWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            feeRatio,
            to,
            value,
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("to is missing."))
        }
    }
    
    public func test_throwException_invalidValue() throws {
        let value = "invalid value"
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemoWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            feeRatio,
            to,
            value,
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid value : \(value)"))
        }
    }
    
    public func test_throwException_missingValue() throws {
        let value = ""
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemoWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            feeRatio,
            to,
            value,
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("value is missing."))
        }
    }
    
    public func test_throwException_invalidGas() throws {
        let gas = "invalid gas"
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemoWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            feeRatio,
            to,
            value,
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid gas. : \(gas)"))
        }
    }
    
    public func test_throwException_missingGas() throws {
        let gas = ""
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemoWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            feeRatio,
            to,
            value,
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("gas is missing."))
        }
    }
    
    public func test_throwException_invalidInput() throws {
        let input = "invalid input"
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemoWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            feeRatio,
            to,
            value,
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid input. : \(input)"))
        }
    }
    
    public func test_throwException_missingInput() throws {
        let input = ""
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemoWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            feeRatio,
            to,
            value,
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("input is missing."))
        }
    }
    
    public func test_throwException_setFeePayerSignatures_missingFeePayer() throws {
        let feePayer = ""
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemoWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            feeRatio,
            to,
            value,
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("feePayer is missing: feePayer must be defined with feePayerSignatures."))
        }
    }
    
    public func test_throwException_FeeRatio_invalid() throws {
        let feeRatio = "invalid fee ratio"
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemoWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            feeRatio,
            to,
            value,
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid type of feeRatio: feeRatio should be number type or hex number string"))
        }
    }
    
    public func test_throwException_FeeRatio_outOfRange() throws {
        let feeRatio = BigInt(101).hexa
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemoWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            feeRatio,
            to,
            value,
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid feeRatio: feeRatio is out of range. [1,99]"))
        }
    }
    
    public func test_throwException_missingFeeRatio() throws {
        let feeRatio = ""
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemoWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            feeRatio,
            to,
            value,
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("feeRatio is missing."))
        }
    }
}

class FeeDelegatedValueTransferMemoWithRatioTest_getRLPEncodingTest: XCTestCase {
    let from = FeeDelegatedValueTransferMemoWithRatioTest.from
    let account = FeeDelegatedValueTransferMemoWithRatioTest.account
    let to = FeeDelegatedValueTransferMemoWithRatioTest.to
    let gas = FeeDelegatedValueTransferMemoWithRatioTest.gas
    let nonce = FeeDelegatedValueTransferMemoWithRatioTest.nonce
    let gasPrice = FeeDelegatedValueTransferMemoWithRatioTest.gasPrice
    let chainID = FeeDelegatedValueTransferMemoWithRatioTest.chainID
    let value = FeeDelegatedValueTransferMemoWithRatioTest.value
    let input = FeeDelegatedValueTransferMemoWithRatioTest.input
    let humanReadable = FeeDelegatedValueTransferMemoWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferMemoWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferMemoWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedValueTransferMemoWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferMemoWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedValueTransferMemoWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedValueTransferMemoWithRatioTest.expectedRLPEncoding
        
    public func test_getRLPEncoding() throws {
        let txObj = try FeeDelegatedValueTransferMemoWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setInput(input)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertEqual(expectedRLPEncoding, try txObj.getRLPEncoding())
    }
    
    public func test_throwException_NoNonce() throws {
        let txObj = try FeeDelegatedValueTransferMemoWithRatio.Builder()
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setInput(input)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertThrowsError(try txObj.getRLPEncoding()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NoGasPrice() throws {
        let txObj = try FeeDelegatedValueTransferMemoWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setInput(input)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertThrowsError(try txObj.getRLPEncoding()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class FeeDelegatedValueTransferMemoWithRatioTest_signAsFeePayer_OneKeyTest: XCTestCase {
    var mTxObj: FeeDelegatedValueTransferMemoWithRatio?
    var klaytnWalletKey: String?
    var keyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedValueTransferMemoWithRatioTest.feePayerPrivateKey
    
    let from = FeeDelegatedValueTransferMemoWithRatioTest.from
    let account = FeeDelegatedValueTransferMemoWithRatioTest.account
    let to = FeeDelegatedValueTransferMemoWithRatioTest.to
    let gas = FeeDelegatedValueTransferMemoWithRatioTest.gas
    let nonce = FeeDelegatedValueTransferMemoWithRatioTest.nonce
    let gasPrice = FeeDelegatedValueTransferMemoWithRatioTest.gasPrice
    let chainID = FeeDelegatedValueTransferMemoWithRatioTest.chainID
    let value = FeeDelegatedValueTransferMemoWithRatioTest.value
    let input = FeeDelegatedValueTransferMemoWithRatioTest.input
    let humanReadable = FeeDelegatedValueTransferMemoWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferMemoWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferMemoWithRatioTest.senderSignatureData
    var feePayer = FeeDelegatedValueTransferMemoWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferMemoWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedValueTransferMemoWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedValueTransferMemoWithRatioTest.expectedRLPEncoding
        
    override func setUpWithError() throws {
        keyring = try KeyringFactory.createWithSingleKey(feePayer, feePayerPrivateKey)
        
        mTxObj = try FeeDelegatedValueTransferMemoWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setInput(input)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .build()
        
        klaytnWalletKey = try keyring?.getKlaytnWalletKey()
    }
    
    public func test_signAsFeePayer_String() throws {
        let privateKey = PrivateKey.generate().privateKey
        let feePayer = try PrivateKey(privateKey).getDerivedAddress()
        
        mTxObj = try FeeDelegatedValueTransferMemoWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setInput(input)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .build()
        
        _ = try mTxObj!.signAsFeePayer(privateKey)
        XCTAssertEqual(1, mTxObj?.feePayerSignatures.count)
    }
    
    public func test_signAsFeePayer_KlaytnWalletKey() throws {
        _ = try mTxObj!.signAsFeePayer(klaytnWalletKey!)
        XCTAssertEqual(1, mTxObj?.feePayerSignatures.count)
    }
    
    public func test_signAsFeePayer_Keyring() throws {
        _ = try mTxObj!.signAsFeePayer(keyring!, 0, TransactionHasher.getHashForFeePayerSignature(_:))
        XCTAssertEqual(1, mTxObj?.feePayerSignatures.count)
    }
    
    public func test_signAsFeePayer_Keyring_NoSigner() throws {
        _ = try mTxObj!.signAsFeePayer(keyring!, 0)
        XCTAssertEqual(1, mTxObj?.feePayerSignatures.count)
    }
    
    public func test_signAsFeePayer_multipleKey() throws {
        let keyArr = [
            PrivateKey.generate().privateKey,
            feePayerPrivateKey,
            PrivateKey.generate().privateKey
        ]
        let keyring = try KeyringFactory.createWithMultipleKey(feePayer, keyArr)
        _ = try mTxObj!.signAsFeePayer(keyring, 1)
        XCTAssertEqual(1, mTxObj?.feePayerSignatures.count)
    }
    
    public func test_signAsFeePayer_roleBasedKey() throws {
        let keyArr = [
            [
                PrivateKey.generate().privateKey,
                PrivateKey.generate().privateKey
            ],
            [
                PrivateKey.generate().privateKey
            ],
            [
                PrivateKey.generate().privateKey,
                feePayerPrivateKey
            ]
        ]
        let roleBasedKeyring = try KeyringFactory.createWithRoleBasedKey(feePayer, keyArr)
        _ = try mTxObj!.signAsFeePayer(roleBasedKeyring, 1)
        XCTAssertEqual(1, mTxObj?.feePayerSignatures.count)
    }
    
    public func test_throwException_NotMatchAddress() throws {
        let keyring = try KeyringFactory.createWithSingleKey(feePayerPrivateKey, PrivateKey.generate().privateKey)
        XCTAssertThrowsError(try mTxObj!.signAsFeePayer(keyring, 0)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("The feePayer address of the transaction is different with the address of the keyring to use."))
        }
    }
    
    public func test_throwException_InvalidIndex() throws {
        let role = try AccountUpdateTest.generateRoleBaseKeyring([3,3,3], feePayer)
        
        XCTAssertThrowsError(try mTxObj!.signAsFeePayer(role, 4)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid index : index must be less than the length of the key."))
        }
    }
}

class FeeDelegatedValueTransferMemoWithRatioTest_signAsFeePayer_AllKeyTest: XCTestCase {
    var mTxObj: FeeDelegatedValueTransferMemoWithRatio?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedValueTransferMemoWithRatioTest.feePayerPrivateKey
    
    let from = FeeDelegatedValueTransferMemoWithRatioTest.from
    let account = FeeDelegatedValueTransferMemoWithRatioTest.account
    let to = FeeDelegatedValueTransferMemoWithRatioTest.to
    let gas = FeeDelegatedValueTransferMemoWithRatioTest.gas
    let nonce = FeeDelegatedValueTransferMemoWithRatioTest.nonce
    let gasPrice = FeeDelegatedValueTransferMemoWithRatioTest.gasPrice
    let chainID = FeeDelegatedValueTransferMemoWithRatioTest.chainID
    let value = FeeDelegatedValueTransferMemoWithRatioTest.value
    let input = FeeDelegatedValueTransferMemoWithRatioTest.input
    let humanReadable = FeeDelegatedValueTransferMemoWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferMemoWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferMemoWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedValueTransferMemoWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferMemoWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedValueTransferMemoWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedValueTransferMemoWithRatioTest.expectedRLPEncoding
        
    override func setUpWithError() throws {
        mTxObj = try FeeDelegatedValueTransferMemoWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setInput(input)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .build()
        
        singleKeyring = try KeyringFactory.createWithSingleKey(feePayer, feePayerPrivateKey)
        multipleKeyring = try KeyringFactory.createWithMultipleKey(feePayer, KeyringFactory.generateMultipleKeys(8))
        roleBasedKeyring = try KeyringFactory.createWithRoleBasedKey(feePayer, KeyringFactory.generateRoleBasedKeys([3,4,5]))
    }

    public func test_signWithKeys_singleKeyring() throws {
        _ = try mTxObj!.signAsFeePayer(singleKeyring!, TransactionHasher.getHashForFeePayerSignature(_:))
        XCTAssertEqual(1, mTxObj?.signatures.count)
    }

    public func test_signWithKeys_singleKeyring_NoSigner() throws {
        _ = try mTxObj!.signAsFeePayer(singleKeyring!)
        XCTAssertEqual(1, mTxObj?.feePayerSignatures.count)
    }

    public func test_signWithKeys_multipleKeyring() throws {
        _ = try mTxObj!.signAsFeePayer(multipleKeyring!)
        XCTAssertEqual(8, mTxObj?.feePayerSignatures.count)
    }

    public func test_signWithKeys_roleBasedKeyring() throws {
        _ = try mTxObj!.signAsFeePayer(roleBasedKeyring!)
        XCTAssertEqual(5, mTxObj?.feePayerSignatures.count)
    }

    public func test_throwException_NotMatchAddress() throws {
        let keyring = try KeyringFactory.createFromPrivateKey(PrivateKey.generate().privateKey)
        XCTAssertThrowsError(try mTxObj!.signAsFeePayer(keyring)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("The feePayer address of the transaction is different with the address of the keyring to use."))
        }
    }
}

class FeeDelegatedValueTransferMemoWithRatioTest_appendFeePayerSignaturesTest: XCTestCase {
    var mTxObj: FeeDelegatedValueTransferMemoWithRatio?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedValueTransferMemoWithRatioTest.feePayerPrivateKey
    
    let from = FeeDelegatedValueTransferMemoWithRatioTest.from
    let account = FeeDelegatedValueTransferMemoWithRatioTest.account
    let to = FeeDelegatedValueTransferMemoWithRatioTest.to
    let gas = FeeDelegatedValueTransferMemoWithRatioTest.gas
    let nonce = FeeDelegatedValueTransferMemoWithRatioTest.nonce
    let gasPrice = FeeDelegatedValueTransferMemoWithRatioTest.gasPrice
    let chainID = FeeDelegatedValueTransferMemoWithRatioTest.chainID
    let value = FeeDelegatedValueTransferMemoWithRatioTest.value
    let input = FeeDelegatedValueTransferMemoWithRatioTest.input
    let humanReadable = FeeDelegatedValueTransferMemoWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferMemoWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferMemoWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedValueTransferMemoWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferMemoWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedValueTransferMemoWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedValueTransferMemoWithRatioTest.expectedRLPEncoding
    
    override func setUpWithError() throws {
        mTxObj = try FeeDelegatedValueTransferMemoWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setInput(input)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .build()
    }
    
    public func test_appendFeePayerSignature() throws {
        let signatureData = SignatureData(
            "0x0fea",
            "0xade9480f584fe481bf070ab758ecc010afa15debc33e1bd75af637d834073a6e",
            "0x38160105d78cef4529d765941ad6637d8dcf6bd99310e165fee1c39fff2aa27e"
        )
        try mTxObj!.appendFeePayerSignatures(signatureData)
        XCTAssertEqual(signatureData, mTxObj?.feePayerSignatures[0])
    }
    
    public func test_appendFeePayerSignatureList() throws {
        let signatureData = SignatureData(
            "0x0fea",
            "0xade9480f584fe481bf070ab758ecc010afa15debc33e1bd75af637d834073a6e",
            "0x38160105d78cef4529d765941ad6637d8dcf6bd99310e165fee1c39fff2aa27e"
        )
        try mTxObj!.appendFeePayerSignatures([signatureData])
        XCTAssertEqual(signatureData, mTxObj?.feePayerSignatures[0])
    }
    
    public func test_appendFeePayerSignatureList_EmptySig() throws {
        let emptySignature = SignatureData.getEmptySignature()
        mTxObj = try FeeDelegatedValueTransferMemoWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setInput(input)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(emptySignature)
            .build()
        
        let signatureData = SignatureData(
            "0x0fea",
            "0xade9480f584fe481bf070ab758ecc010afa15debc33e1bd75af637d834073a6e",
            "0x38160105d78cef4529d765941ad6637d8dcf6bd99310e165fee1c39fff2aa27e"
        )
        try mTxObj!.appendFeePayerSignatures([signatureData])
        XCTAssertEqual(signatureData, mTxObj?.feePayerSignatures[0])
    }
    
    public func test_appendFeePayerSignature_ExistedSignature() throws {
        let signatureData = SignatureData(
            "0x0fea",
            "0xade9480f584fe481bf070ab758ecc010afa15debc33e1bd75af637d834073a6e",
            "0x38160105d78cef4529d765941ad6637d8dcf6bd99310e165fee1c39fff2aa27e"
        )
        
        mTxObj = try FeeDelegatedValueTransferMemoWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setInput(input)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(signatureData)
            .build()
        
        let signatureData1 = SignatureData(
            "0x0fea",
            "0x7a5011b41cfcb6270af1b5f8aeac8aeabb1edb436f028261b5add564de694700",
            "0x23ac51660b8b421bf732ef8148d0d4f19d5e29cb97be6bccb5ae505ebe89eb4a"
        )
        try mTxObj!.appendFeePayerSignatures([signatureData1])
        XCTAssertEqual(2, mTxObj?.feePayerSignatures.count)
        XCTAssertEqual(signatureData, mTxObj?.feePayerSignatures[0])
        XCTAssertEqual(signatureData1, mTxObj?.feePayerSignatures[1])
    }
    
    public func test_appendSignatureList_ExistedSignature() throws {
        let signatureData = SignatureData(
            "0x0fea",
            "0xade9480f584fe481bf070ab758ecc010afa15debc33e1bd75af637d834073a6e",
            "0x38160105d78cef4529d765941ad6637d8dcf6bd99310e165fee1c39fff2aa27e"
        )
        
        mTxObj = try FeeDelegatedValueTransferMemoWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setInput(input)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(signatureData)
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
        
        try mTxObj!.appendFeePayerSignatures([signatureData1, signatureData2])
        XCTAssertEqual(3, mTxObj?.feePayerSignatures.count)
        XCTAssertEqual(signatureData, mTxObj?.feePayerSignatures[0])
        XCTAssertEqual(signatureData1, mTxObj?.feePayerSignatures[1])
        XCTAssertEqual(signatureData2, mTxObj?.feePayerSignatures[2])
    }
}

class FeeDelegatedValueTransferMemoWithRatioTest_combineSignatureTest: XCTestCase {
    var mTxObj: FeeDelegatedValueTransferMemoWithRatio?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedValueTransferMemoWithRatioTest.feePayerPrivateKey
    
    let from = "0xceca418cc3ed540c8d16675fe600d703154e379f"
    let account = FeeDelegatedValueTransferMemoWithRatioTest.account
    let to = "0x7b65b75d204abed71587c9e519a89277766ee1d0"
    let gas = "0xf4240"
    let nonce = "0x1"
    let gasPrice = "0x5d21dba00"
    let chainID = "0x7e3"
    let value = "0xa"
    let input = "0x68656c6c6f"
    let humanReadable = FeeDelegatedValueTransferMemoWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferMemoWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferMemoWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedValueTransferMemoWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferMemoWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedValueTransferMemoWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedValueTransferMemoWithRatioTest.expectedRLPEncoding
    
    override func setUpWithError() throws {
        mTxObj = try FeeDelegatedValueTransferMemoWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setInput(input)
            .setFrom(from)
            .setFeeRatio(feeRatio)
            .build()
    }
    
    public func test_combineSignature() throws {
        let expectedRLPEncoded = "0x12f8a0018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a94ceca418cc3ed540c8d16675fe600d703154e379f8568656c6c6f1ef847f845820feaa050edf44854ee83c3ea396614796a19b9ebe4714b6fde40f52ce02b8e7a32be22a01fbbd3dd81af0eadc375e390fd468d9574a76a826cc02abe55f1d1176da4286d940000000000000000000000000000000000000000c4c3018080"
        
        let expectedSignature = SignatureData(
            "0x0fea",
            "0x50edf44854ee83c3ea396614796a19b9ebe4714b6fde40f52ce02b8e7a32be22",
            "0x1fbbd3dd81af0eadc375e390fd468d9574a76a826cc02abe55f1d1176da4286d"
        )
        
        let rlpEncoded = "0x12f8a0018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a94ceca418cc3ed540c8d16675fe600d703154e379f8568656c6c6f1ef847f845820feaa050edf44854ee83c3ea396614796a19b9ebe4714b6fde40f52ce02b8e7a32be22a01fbbd3dd81af0eadc375e390fd468d9574a76a826cc02abe55f1d1176da4286d940000000000000000000000000000000000000000c4c3018080"
        
        let combined = try mTxObj!.combineSignedRawTransactions([rlpEncoded])
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature, mTxObj?.signatures[0])
    }
    
    public func test_combine_multipleSignature() throws {
        let expectedRLPEncoded = "0x12f9012e018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a94ceca418cc3ed540c8d16675fe600d703154e379f8568656c6c6f1ef8d5f845820feaa050edf44854ee83c3ea396614796a19b9ebe4714b6fde40f52ce02b8e7a32be22a01fbbd3dd81af0eadc375e390fd468d9574a76a826cc02abe55f1d1176da4286df845820fe9a03c5bdf4fba47ee89e3072d2c707efb241aef04cb2c7b9771bea2ffd62c2b3807a05d7be6df572fdb60f68a3250da5794a983f609991561d31a9189f0d7212de88cf845820feaa0f1e794e5f0a28afce80bd9a89883ed55f96a8d45b03ae8355524a0000eac8a2ea0202e179034aefcadcc7a25360c3bb88f1a572c5912e5031bac11d466ebb6727e940000000000000000000000000000000000000000c4c3018080"
        
        let expectedSignature = [
            SignatureData(
                    "0x0fea",
                    "0x50edf44854ee83c3ea396614796a19b9ebe4714b6fde40f52ce02b8e7a32be22",
                    "0x1fbbd3dd81af0eadc375e390fd468d9574a76a826cc02abe55f1d1176da4286d"
            ),
            SignatureData(
                    "0x0fe9",
                    "0x3c5bdf4fba47ee89e3072d2c707efb241aef04cb2c7b9771bea2ffd62c2b3807",
                    "0x5d7be6df572fdb60f68a3250da5794a983f609991561d31a9189f0d7212de88c"
            ),
            SignatureData(
                    "0x0fea",
                    "0xf1e794e5f0a28afce80bd9a89883ed55f96a8d45b03ae8355524a0000eac8a2e",
                    "0x202e179034aefcadcc7a25360c3bb88f1a572c5912e5031bac11d466ebb6727e"
            )
        ]
        
        let rlpEncodedString = [
            "0x12f88c018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a94ceca418cc3ed540c8d16675fe600d703154e379f8568656c6c6f1ef847f845820fe9a03c5bdf4fba47ee89e3072d2c707efb241aef04cb2c7b9771bea2ffd62c2b3807a05d7be6df572fdb60f68a3250da5794a983f609991561d31a9189f0d7212de88c80c4c3018080",
            "0x12f88c018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a94ceca418cc3ed540c8d16675fe600d703154e379f8568656c6c6f1ef847f845820feaa0f1e794e5f0a28afce80bd9a89883ed55f96a8d45b03ae8355524a0000eac8a2ea0202e179034aefcadcc7a25360c3bb88f1a572c5912e5031bac11d466ebb6727e80c4c3018080"
        ]
        
        let senderSignatureData = SignatureData(
            "0x0fea",
            "0x50edf44854ee83c3ea396614796a19b9ebe4714b6fde40f52ce02b8e7a32be22",
            "0x1fbbd3dd81af0eadc375e390fd468d9574a76a826cc02abe55f1d1176da4286d"
        )
        
        mTxObj = try FeeDelegatedValueTransferMemoWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setInput(input)
            .setFrom(from)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .build()
        
        let combined = try mTxObj!.combineSignedRawTransactions(rlpEncodedString)
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature[0], mTxObj?.signatures[0])
        XCTAssertEqual(expectedSignature[1], mTxObj?.signatures[1])
        XCTAssertEqual(expectedSignature[2], mTxObj?.signatures[2])
    }
    
    public func test_combineSignature_feePayerSignature() throws {
        let expectedRLPEncoded = "0x12f8a0018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a94ceca418cc3ed540c8d16675fe600d703154e379f8568656c6c6f1ec4c301808094188375ff24b14775e1c13d382c2d1ef3a27ca614f847f845820fe9a05610e0b35da77d24c009fd6040a43ee70248b60b91892611a0cf36ef185399a2a05fc451b5b9e90453e8fcdf797e1a0875746ddfe1fdcc6617a21eb8e35b328f76"
        
        let expectedSignature = SignatureData(
            "0x0fe9",
            "0x5610e0b35da77d24c009fd6040a43ee70248b60b91892611a0cf36ef185399a2",
            "0x5fc451b5b9e90453e8fcdf797e1a0875746ddfe1fdcc6617a21eb8e35b328f76"
        )
        
        let rlpEncoded = "0x12f8a0018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a94ceca418cc3ed540c8d16675fe600d703154e379f8568656c6c6f1ec4c301808094188375ff24b14775e1c13d382c2d1ef3a27ca614f847f845820fe9a05610e0b35da77d24c009fd6040a43ee70248b60b91892611a0cf36ef185399a2a05fc451b5b9e90453e8fcdf797e1a0875746ddfe1fdcc6617a21eb8e35b328f76"
                
        mTxObj = try FeeDelegatedValueTransferMemoWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setInput(input)
            .setFrom(from)
            .setFeeRatio(feeRatio)
            .build()
        
        let combined = try mTxObj!.combineSignedRawTransactions([rlpEncoded])
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature, mTxObj?.feePayerSignatures[0])
    }
    
    public func test_combineSignature_multipleFeePayerSignature() throws {
        let expectedRLPEncoded = "0x12f9012e018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a94ceca418cc3ed540c8d16675fe600d703154e379f8568656c6c6f1ec4c301808094188375ff24b14775e1c13d382c2d1ef3a27ca614f8d5f845820fe9a05610e0b35da77d24c009fd6040a43ee70248b60b91892611a0cf36ef185399a2a05fc451b5b9e90453e8fcdf797e1a0875746ddfe1fdcc6617a21eb8e35b328f76f845820feaa0defc41992109af25e9956cbe7d593cd3f65dd2bf1e8f71d7ac1799451a90c062a03487aacf56a6f5f4719e51778ac5fac00e6994b0327ffa5edf99d879116e6e5af845820fe9a09913be30cc8b8c68fd4745f6b04ede43e272496c9245bc0784339cdff8b3c008a02e3b652fa111946ea868e29714370822220dec6c4bfabfcaf1f023df800217d2"
        
        let expectedSignature = [
            SignatureData(
                    "0x0fe9",
                    "0x5610e0b35da77d24c009fd6040a43ee70248b60b91892611a0cf36ef185399a2",
                    "0x5fc451b5b9e90453e8fcdf797e1a0875746ddfe1fdcc6617a21eb8e35b328f76"
            ),
            SignatureData(
                    "0x0fea",
                    "0xdefc41992109af25e9956cbe7d593cd3f65dd2bf1e8f71d7ac1799451a90c062",
                    "0x3487aacf56a6f5f4719e51778ac5fac00e6994b0327ffa5edf99d879116e6e5a"
            ),
            SignatureData(
                    "0x0fe9",
                    "0x9913be30cc8b8c68fd4745f6b04ede43e272496c9245bc0784339cdff8b3c008",
                    "0x2e3b652fa111946ea868e29714370822220dec6c4bfabfcaf1f023df800217d2"
            )
        ]
        
        let rlpEncodedString = [
            "0x12f8a0018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a94ceca418cc3ed540c8d16675fe600d703154e379f8568656c6c6f1ec4c301808094188375ff24b14775e1c13d382c2d1ef3a27ca614f847f845820feaa0defc41992109af25e9956cbe7d593cd3f65dd2bf1e8f71d7ac1799451a90c062a03487aacf56a6f5f4719e51778ac5fac00e6994b0327ffa5edf99d879116e6e5a",
            "0x12f8a0018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a94ceca418cc3ed540c8d16675fe600d703154e379f8568656c6c6f1ec4c301808094188375ff24b14775e1c13d382c2d1ef3a27ca614f847f845820fe9a09913be30cc8b8c68fd4745f6b04ede43e272496c9245bc0784339cdff8b3c008a02e3b652fa111946ea868e29714370822220dec6c4bfabfcaf1f023df800217d2"
        ]
        
        let feePayer = "0x188375ff24b14775e1c13d382c2d1ef3a27ca614"
        let feePayerSignatureData = SignatureData(
            "0x0fe9",
            "0x5610e0b35da77d24c009fd6040a43ee70248b60b91892611a0cf36ef185399a2",
            "0x5fc451b5b9e90453e8fcdf797e1a0875746ddfe1fdcc6617a21eb8e35b328f76"
        )
        
        mTxObj = try FeeDelegatedValueTransferMemoWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setInput(input)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        let combined = try mTxObj!.combineSignedRawTransactions(rlpEncodedString)
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature[0], mTxObj?.feePayerSignatures[0])
        XCTAssertEqual(expectedSignature[1], mTxObj?.feePayerSignatures[1])
        XCTAssertEqual(expectedSignature[2], mTxObj?.feePayerSignatures[2])
    }
    
    public func test_multipleSignature_senderSignatureData_feePayerSignature() throws {
        mTxObj = try FeeDelegatedValueTransferMemoWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setInput(input)
            .setFrom(from)
            .setFeeRatio(feeRatio)
            .build()
        
        let rlpEncodedString = "0x12f9011a018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a94ceca418cc3ed540c8d16675fe600d703154e379f8568656c6c6f1ef8d5f845820feaa050edf44854ee83c3ea396614796a19b9ebe4714b6fde40f52ce02b8e7a32be22a01fbbd3dd81af0eadc375e390fd468d9574a76a826cc02abe55f1d1176da4286df845820fe9a03c5bdf4fba47ee89e3072d2c707efb241aef04cb2c7b9771bea2ffd62c2b3807a05d7be6df572fdb60f68a3250da5794a983f609991561d31a9189f0d7212de88cf845820feaa0f1e794e5f0a28afce80bd9a89883ed55f96a8d45b03ae8355524a0000eac8a2ea0202e179034aefcadcc7a25360c3bb88f1a572c5912e5031bac11d466ebb6727e80c4c3018080"
        
        let expectedSignature = [
            SignatureData(
                    "0x0fea",
                    "0x50edf44854ee83c3ea396614796a19b9ebe4714b6fde40f52ce02b8e7a32be22",
                    "0x1fbbd3dd81af0eadc375e390fd468d9574a76a826cc02abe55f1d1176da4286d"
            ),
            SignatureData(
                    "0x0fe9",
                    "0x3c5bdf4fba47ee89e3072d2c707efb241aef04cb2c7b9771bea2ffd62c2b3807",
                    "0x5d7be6df572fdb60f68a3250da5794a983f609991561d31a9189f0d7212de88c"
            ),
            SignatureData(
                    "0x0fea",
                    "0xf1e794e5f0a28afce80bd9a89883ed55f96a8d45b03ae8355524a0000eac8a2e",
                    "0x202e179034aefcadcc7a25360c3bb88f1a572c5912e5031bac11d466ebb6727e"
            )
        ]
        
        _ = try mTxObj!.combineSignedRawTransactions([rlpEncodedString])
        
        let rlpEncodedStringsWithFeePayerSignatures = "0x12f9012e018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a94ceca418cc3ed540c8d16675fe600d703154e379f8568656c6c6f1ec4c301808094188375ff24b14775e1c13d382c2d1ef3a27ca614f8d5f845820fe9a05610e0b35da77d24c009fd6040a43ee70248b60b91892611a0cf36ef185399a2a05fc451b5b9e90453e8fcdf797e1a0875746ddfe1fdcc6617a21eb8e35b328f76f845820feaa0defc41992109af25e9956cbe7d593cd3f65dd2bf1e8f71d7ac1799451a90c062a03487aacf56a6f5f4719e51778ac5fac00e6994b0327ffa5edf99d879116e6e5af845820fe9a09913be30cc8b8c68fd4745f6b04ede43e272496c9245bc0784339cdff8b3c008a02e3b652fa111946ea868e29714370822220dec6c4bfabfcaf1f023df800217d2"
        
        let expectedFeePayerSignatures = [
            SignatureData(
                    "0x0fe9",
                    "0x5610e0b35da77d24c009fd6040a43ee70248b60b91892611a0cf36ef185399a2",
                    "0x5fc451b5b9e90453e8fcdf797e1a0875746ddfe1fdcc6617a21eb8e35b328f76"
            ),
            SignatureData(
                    "0x0fea",
                    "0xdefc41992109af25e9956cbe7d593cd3f65dd2bf1e8f71d7ac1799451a90c062",
                    "0x3487aacf56a6f5f4719e51778ac5fac00e6994b0327ffa5edf99d879116e6e5a"
            ),
            SignatureData(
                    "0x0fe9",
                    "0x9913be30cc8b8c68fd4745f6b04ede43e272496c9245bc0784339cdff8b3c008",
                    "0x2e3b652fa111946ea868e29714370822220dec6c4bfabfcaf1f023df800217d2"
            )
        ]
        
        _ = try mTxObj!.combineSignedRawTransactions([rlpEncodedStringsWithFeePayerSignatures])
        
        XCTAssertEqual(expectedSignature[0], mTxObj?.signatures[0])
        XCTAssertEqual(expectedSignature[1], mTxObj?.signatures[1])
        XCTAssertEqual(expectedSignature[2], mTxObj?.signatures[2])
        
        XCTAssertEqual(expectedFeePayerSignatures[0], mTxObj?.feePayerSignatures[0])
        XCTAssertEqual(expectedFeePayerSignatures[1], mTxObj?.feePayerSignatures[1])
        XCTAssertEqual(expectedFeePayerSignatures[2], mTxObj?.feePayerSignatures[2])
    }
    
    public func test_throwException_differentField() throws {
        let gas = "0x1000"
        mTxObj = try FeeDelegatedValueTransferMemoWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setInput(input)
            .setFrom(from)
            .setFeeRatio(feeRatio)
            .build()
        
        let rlpEncoded = "0x12f88c018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a94ceca418cc3ed540c8d16675fe600d703154e379f8568656c6c6f1ef847f845820feaa050edf44854ee83c3ea396614796a19b9ebe4714b6fde40f52ce02b8e7a32be22a01fbbd3dd81af0eadc375e390fd468d9574a76a826cc02abe55f1d1176da4286d80c4c3018080"
        
        XCTAssertThrowsError(try mTxObj!.combineSignedRawTransactions([rlpEncoded])) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("Transactions containing different information cannot be combined."))
        }
    }
}

class FeeDelegatedValueTransferMemoWithRatioTest_getRawTransactionTest: XCTestCase {
    var mTxObj: FeeDelegatedValueTransferMemoWithRatio?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedValueTransferMemoWithRatioTest.feePayerPrivateKey
    
    let from = FeeDelegatedValueTransferMemoWithRatioTest.from
    let account = FeeDelegatedValueTransferMemoWithRatioTest.account
    let to = FeeDelegatedValueTransferMemoWithRatioTest.to
    let gas = FeeDelegatedValueTransferMemoWithRatioTest.gas
    let nonce = FeeDelegatedValueTransferMemoWithRatioTest.nonce
    let gasPrice = FeeDelegatedValueTransferMemoWithRatioTest.gasPrice
    let chainID = FeeDelegatedValueTransferMemoWithRatioTest.chainID
    let value = FeeDelegatedValueTransferMemoWithRatioTest.value
    let input = FeeDelegatedValueTransferMemoWithRatioTest.input
    let humanReadable = FeeDelegatedValueTransferMemoWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferMemoWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferMemoWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedValueTransferMemoWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferMemoWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedValueTransferMemoWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedValueTransferMemoWithRatioTest.expectedRLPEncoding
    
    public func test_getRawTransaction() throws {
        let txObj = try FeeDelegatedValueTransferMemoWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setInput(input)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()

        XCTAssertEqual(expectedRLPEncoding, try txObj.getRawTransaction())
    }
}

class FeeDelegatedValueTransferMemoWithRatioTest_getTransactionHashTest: XCTestCase {
    var mTxObj: FeeDelegatedValueTransferMemoWithRatio?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedValueTransferMemoWithRatioTest.feePayerPrivateKey
    
    let from = FeeDelegatedValueTransferMemoWithRatioTest.from
    let account = FeeDelegatedValueTransferMemoWithRatioTest.account
    let to = FeeDelegatedValueTransferMemoWithRatioTest.to
    let gas = FeeDelegatedValueTransferMemoWithRatioTest.gas
    let nonce = FeeDelegatedValueTransferMemoWithRatioTest.nonce
    let gasPrice = FeeDelegatedValueTransferMemoWithRatioTest.gasPrice
    let chainID = FeeDelegatedValueTransferMemoWithRatioTest.chainID
    let value = FeeDelegatedValueTransferMemoWithRatioTest.value
    let input = FeeDelegatedValueTransferMemoWithRatioTest.input
    let humanReadable = FeeDelegatedValueTransferMemoWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferMemoWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferMemoWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedValueTransferMemoWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferMemoWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedValueTransferMemoWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedValueTransferMemoWithRatioTest.expectedRLPEncoding
    let expectedTransactionHash = FeeDelegatedValueTransferMemoWithRatioTest.expectedTransactionHash
            
    public func test_getTransactionHash() throws {
        let txObj = try FeeDelegatedValueTransferMemoWithRatio.Builder()
                    .setNonce(nonce)
                    .setGas(gas)
                    .setGasPrice(gasPrice)
                    .setTo(to)
                    .setChainId(chainID)
                    .setValue(value)
                    .setFrom(from)
                    .setFeePayer(feePayer)
                    .setFeeRatio(feeRatio)
                    .setInput(input)
                    .setSignatures(senderSignatureData)
                    .setFeePayerSignatures(feePayerSignatureData)
            .build()

        XCTAssertEqual(expectedTransactionHash, try txObj.getTransactionHash())
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try FeeDelegatedValueTransferMemoWithRatio.Builder()
                    .setNonce(nonce)
                    .setGas(gas)
                    .setGasPrice(gasPrice)
                    .setTo(to)
                    .setChainId(chainID)
                    .setValue(value)
                    .setFrom(from)
                    .setFeePayer(feePayer)
                    .setFeeRatio(feeRatio)
                    .setInput(input)
                    .setSignatures(senderSignatureData)
                    .setFeePayerSignatures(feePayerSignatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getTransactionHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_gasPrice() throws {
        let gasPrice = ""
        
        mTxObj = try FeeDelegatedValueTransferMemoWithRatio.Builder()
                    .setNonce(nonce)
                    .setGas(gas)
                    .setGasPrice(gasPrice)
                    .setTo(to)
                    .setChainId(chainID)
                    .setValue(value)
                    .setFrom(from)
                    .setFeePayer(feePayer)
                    .setFeeRatio(feeRatio)
                    .setInput(input)
                    .setSignatures(senderSignatureData)
                    .setFeePayerSignatures(feePayerSignatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getTransactionHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class FeeDelegatedValueTransferMemoWithRatioTest_getSenderTxHashTest: XCTestCase {
    var mTxObj: FeeDelegatedValueTransferMemoWithRatio?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedValueTransferMemoWithRatioTest.feePayerPrivateKey
    
    let from = FeeDelegatedValueTransferMemoWithRatioTest.from
    let account = FeeDelegatedValueTransferMemoWithRatioTest.account
    let to = FeeDelegatedValueTransferMemoWithRatioTest.to
    let gas = FeeDelegatedValueTransferMemoWithRatioTest.gas
    let nonce = FeeDelegatedValueTransferMemoWithRatioTest.nonce
    let gasPrice = FeeDelegatedValueTransferMemoWithRatioTest.gasPrice
    let chainID = FeeDelegatedValueTransferMemoWithRatioTest.chainID
    let value = FeeDelegatedValueTransferMemoWithRatioTest.value
    let input = FeeDelegatedValueTransferMemoWithRatioTest.input
    let humanReadable = FeeDelegatedValueTransferMemoWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferMemoWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferMemoWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedValueTransferMemoWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferMemoWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedValueTransferMemoWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedValueTransferMemoWithRatioTest.expectedRLPEncoding
    let expectedTransactionHash = FeeDelegatedValueTransferMemoWithRatioTest.expectedTransactionHash
    let expectedSenderTransactionHash = FeeDelegatedValueTransferMemoWithRatioTest.expectedRLPSenderTransactionHash
            
    public func test_getRLPEncodingForSignature() throws {
        mTxObj = try FeeDelegatedValueTransferMemoWithRatio.Builder()
                    .setNonce(nonce)
                    .setGas(gas)
                    .setGasPrice(gasPrice)
                    .setTo(to)
                    .setChainId(chainID)
                    .setValue(value)
                    .setFrom(from)
                    .setFeePayer(feePayer)
                    .setFeeRatio(feeRatio)
                    .setInput(input)
                    .setSignatures(senderSignatureData)
                    .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertEqual(expectedSenderTransactionHash, try mTxObj!.getSenderTxHash())
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try FeeDelegatedValueTransferMemoWithRatio.Builder()
                    .setNonce(nonce)
                    .setGas(gas)
                    .setGasPrice(gasPrice)
                    .setTo(to)
                    .setChainId(chainID)
                    .setValue(value)
                    .setFrom(from)
                    .setFeePayer(feePayer)
                    .setFeeRatio(feeRatio)
                    .setInput(input)
                    .setSignatures(senderSignatureData)
                    .setFeePayerSignatures(feePayerSignatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getSenderTxHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_gasPrice() throws {
        let gasPrice = ""
        
        mTxObj = try FeeDelegatedValueTransferMemoWithRatio.Builder()
                    .setNonce(nonce)
                    .setGas(gas)
                    .setGasPrice(gasPrice)
                    .setTo(to)
                    .setChainId(chainID)
                    .setValue(value)
                    .setFrom(from)
                    .setFeePayer(feePayer)
                    .setFeeRatio(feeRatio)
                    .setInput(input)
                    .setSignatures(senderSignatureData)
                    .setFeePayerSignatures(feePayerSignatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getSenderTxHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class FeeDelegatedValueTransferMemoWithRatioTest_getRLPEncodingForFeePayerSignatureTest: XCTestCase {
    var mTxObj: FeeDelegatedValueTransferMemoWithRatio?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedValueTransferMemoWithRatioTest.feePayerPrivateKey
    
    let from = FeeDelegatedValueTransferMemoWithRatioTest.from
    let account = FeeDelegatedValueTransferMemoWithRatioTest.account
    let to = FeeDelegatedValueTransferMemoWithRatioTest.to
    let gas = FeeDelegatedValueTransferMemoWithRatioTest.gas
    let nonce = FeeDelegatedValueTransferMemoWithRatioTest.nonce
    let gasPrice = FeeDelegatedValueTransferMemoWithRatioTest.gasPrice
    let chainID = FeeDelegatedValueTransferMemoWithRatioTest.chainID
    let value = FeeDelegatedValueTransferMemoWithRatioTest.value
    let input = FeeDelegatedValueTransferMemoWithRatioTest.input
    let humanReadable = FeeDelegatedValueTransferMemoWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferMemoWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferMemoWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedValueTransferMemoWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferMemoWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedValueTransferMemoWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedValueTransferMemoWithRatioTest.expectedRLPEncoding
    let expectedTransactionHash = FeeDelegatedValueTransferMemoWithRatioTest.expectedTransactionHash
    let expectedSenderTransactionHash = FeeDelegatedValueTransferMemoWithRatioTest.expectedRLPSenderTransactionHash
    let expectedRLPEncodingForFeePayerSigning = FeeDelegatedValueTransferMemoWithRatioTest.expectedRLPEncodingForFeePayerSigning
            
    public func test_getRLPEncodingForSignature() throws {
        mTxObj = try FeeDelegatedValueTransferMemoWithRatio.Builder()
                    .setNonce(nonce)
                    .setGas(gas)
                    .setGasPrice(gasPrice)
                    .setTo(to)
                    .setChainId(chainID)
                    .setValue(value)
                    .setFrom(from)
                    .setFeePayer(feePayer)
                    .setFeeRatio(feeRatio)
                    .setInput(input)
                    .setSignatures(senderSignatureData)
                    .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertEqual(expectedRLPEncodingForFeePayerSigning, try mTxObj!.getRLPEncodingForFeePayerSignature())
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try FeeDelegatedValueTransferMemoWithRatio.Builder()
                    .setNonce(nonce)
                    .setGas(gas)
                    .setGasPrice(gasPrice)
                    .setTo(to)
                    .setChainId(chainID)
                    .setValue(value)
                    .setFrom(from)
                    .setFeePayer(feePayer)
                    .setFeeRatio(feeRatio)
                    .setInput(input)
                    .setSignatures(senderSignatureData)
                    .setFeePayerSignatures(feePayerSignatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_gasPrice() throws {
        let gasPrice = ""
        
        mTxObj = try FeeDelegatedValueTransferMemoWithRatio.Builder()
                    .setNonce(nonce)
                    .setGas(gas)
                    .setGasPrice(gasPrice)
                    .setTo(to)
                    .setChainId(chainID)
                    .setValue(value)
                    .setFrom(from)
                    .setFeePayer(feePayer)
                    .setFeeRatio(feeRatio)
                    .setInput(input)
                    .setSignatures(senderSignatureData)
                    .setFeePayerSignatures(feePayerSignatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_chainID() throws {
        let chainID = ""
        
        mTxObj = try FeeDelegatedValueTransferMemoWithRatio.Builder()
                    .setNonce(nonce)
                    .setGas(gas)
                    .setGasPrice(gasPrice)
                    .setTo(to)
                    .setChainId(chainID)
                    .setValue(value)
                    .setFrom(from)
                    .setFeePayer(feePayer)
                    .setFeeRatio(feeRatio)
                    .setInput(input)
                    .setSignatures(senderSignatureData)
                    .setFeePayerSignatures(feePayerSignatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("chainId is undefined. Define chainId in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}
