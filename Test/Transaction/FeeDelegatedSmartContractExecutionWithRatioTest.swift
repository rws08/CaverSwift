//
//  FeeDelegatedSmartContractExecutionWithRatioTest.swift
//  CaverSwiftTests
//
//  Created by won on 2021/08/05.
//

import XCTest
@testable import CaverSwift

class FeeDelegatedSmartContractExecutionWithRatioTest: XCTestCase {
    static let caver = Caver(Caver.DEFAULT_URL)
    
    static let senderPrivateKey = "0x45a915e4d060149eb4365960e6a7a45f334393093061116b197e3240065ff2d8"
    static let feePayerPrivateKey = "0xb9d5558443585bca6f225b935950e3f6e69f9da8a5809a83f51c3365dff53936"
    static let from = "0xa94f5374Fce5edBC8E2a8697C15331677e6EbF0B"
    static let account = Account.createWithAccountKeyLegacy(from)
    static let to = "0x7b65B75d204aBed71587c9E519a89277766EE1d0"
    static let gas = "0xf4240"
    static let gasPrice = "0x19"
    static let nonce = "0x4d2"
    static let chainID = "0x1"
    static let value = "0xa"
    static let input = "0x6353586b000000000000000000000000bc5951f055a85f41a3b62fd6f68ab7de76d299b2"
    static let humanReadable = false
    static let codeFormat = CodeFormat.EVM.hexa
    static let feeRatio = BigInt(30)
    
    static let senderSignatureData = SignatureData(
        "0x26",
        "0x74ccfee18dc28932396b85617c53784ee366303bce39a2401d8eb602cf73766f",
        "0x4c937a5ab9401d2cacb3f39ba8c29dbcd44588cc5c7d0b6b4113cfa7b7d9427b"
    )
    static let feePayer = "0x5A0043070275d9f6054307Ee7348bD660849D90f"
    static let feePayerSignatureData = SignatureData(
        "0x25",
        "0x4a4997524694d535976d7343c1e3a260f99ba53fcb5477e2b96216ec96ebb565",
        "0xf8cb31a35399d2b0fbbfa39f259c819a15370706c0449952c7cfc682d200d7c"
    )
    
    static let expectedRLPEncoding = "0x32f8fc8204d219830f4240947b65b75d204abed71587c9e519a89277766ee1d00a94a94f5374fce5edbc8e2a8697c15331677e6ebf0ba46353586b000000000000000000000000bc5951f055a85f41a3b62fd6f68ab7de76d299b21ef845f84326a074ccfee18dc28932396b85617c53784ee366303bce39a2401d8eb602cf73766fa04c937a5ab9401d2cacb3f39ba8c29dbcd44588cc5c7d0b6b4113cfa7b7d9427b945a0043070275d9f6054307ee7348bd660849d90ff845f84325a04a4997524694d535976d7343c1e3a260f99ba53fcb5477e2b96216ec96ebb565a00f8cb31a35399d2b0fbbfa39f259c819a15370706c0449952c7cfc682d200d7c"
    static let expectedTransactionHash = "0xb204e530f2a7f010d65b6f0f7639d1e9fc8add73e3a0ff1551b11585c36d3bdb"
    static let expectedSenderTransactionHash = "0xd5e22319cbf020d422d8ba3a07da9d99b9300826637af85b4e061805dcb2c1b0"
    static let expectedRLPEncodingForFeePayerSigning = "0xf876b85cf85a328204d219830f4240947b65b75d204abed71587c9e519a89277766ee1d00a94a94f5374fce5edbc8e2a8697c15331677e6ebf0ba46353586b000000000000000000000000bc5951f055a85f41a3b62fd6f68ab7de76d299b21e945a0043070275d9f6054307ee7348bd660849d90f018080"
    
    public static func generateRoleBaseKeyring(_ numArr: [Int], _ address: String) throws -> AbstractKeyring {
        let keyArr = KeyringFactory.generateRoleBasedKeys(numArr, "entropy")
        return try KeyringFactory.createWithRoleBasedKey(address, keyArr)
    }
}

class FeeDelegatedSmartContractExecutionWithRatioTest_createInstanceBuilder: XCTestCase {
    let from = FeeDelegatedSmartContractExecutionWithRatioTest.from
    let account = FeeDelegatedSmartContractExecutionWithRatioTest.account
    let to = FeeDelegatedSmartContractExecutionWithRatioTest.to
    let gas = FeeDelegatedSmartContractExecutionWithRatioTest.gas
    let nonce = FeeDelegatedSmartContractExecutionWithRatioTest.nonce
    let gasPrice = FeeDelegatedSmartContractExecutionWithRatioTest.gasPrice
    let chainID = FeeDelegatedSmartContractExecutionWithRatioTest.chainID
    let value = FeeDelegatedSmartContractExecutionWithRatioTest.value
    let input = FeeDelegatedSmartContractExecutionWithRatioTest.input
    let humanReadable = FeeDelegatedSmartContractExecutionWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractExecutionWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractExecutionWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedSmartContractExecutionWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractExecutionWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedSmartContractExecutionWithRatioTest.feeRatio
    
    public func test_BuilderTest() throws {
        let txObj = try FeeDelegatedSmartContractExecutionWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
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
    }
    
    public func test_BuilderWithRPCTest() throws {
        let txObj = try FeeDelegatedSmartContractExecutionWithRatio.Builder()
            .setKlaytnCall(FeeDelegatedSmartContractExecutionWithRatioTest.caver.rpc.klay)
            .setGas(gas)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
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
        let txObj = try FeeDelegatedSmartContractExecutionWithRatio.Builder()
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
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecutionWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setValue(value)
                                .setTo(to)
                                .setInput(input)
                                .setFeePayer(feePayer)
                                .setFeeRatio(feeRatio)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(from)"))
        }
    }
    
    public func test_throwException_missingFrom() throws {
        let from = ""
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecutionWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setValue(value)
                                .setTo(to)
                                .setInput(input)
                                .setFeePayer(feePayer)
                                .setFeeRatio(feeRatio)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("from is missing."))
        }
    }
    
    public func test_throwException_invalidTo() throws {
        let to = "invalid Address"
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecutionWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setValue(value)
                                .setTo(to)
                                .setInput(input)
                                .setFeePayer(feePayer)
                                .setFeeRatio(feeRatio)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(to)"))
        }
    }
    
    public func test_throwException_invalidValue() throws {
        let value = "invalid value"
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecutionWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setValue(value)
                                .setTo(to)
                                .setInput(input)
                                .setFeePayer(feePayer)
                                .setFeeRatio(feeRatio)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid value : \(value)"))
        }
    }
    
    public func test_throwException_missingValue() throws {
        let value = ""
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecutionWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setValue(value)
                                .setTo(to)
                                .setInput(input)
                                .setFeePayer(feePayer)
                                .setFeeRatio(feeRatio)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("value is missing."))
        }
    }
    
    public func test_throwException_invalidGas() throws {
        let gas = "invalid gas"
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecutionWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setValue(value)
                                .setTo(to)
                                .setInput(input)
                                .setFeePayer(feePayer)
                                .setFeeRatio(feeRatio)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid gas. : \(gas)"))
        }
    }
    
    public func test_throwException_missingGas() throws {
        let gas = ""
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecutionWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setValue(value)
                                .setTo(to)
                                .setInput(input)
                                .setFeePayer(feePayer)
                                .setFeeRatio(feeRatio)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("gas is missing."))
        }
    }
    
    public func test_throwException_invalidInput() throws {
        let input = "invalid input"
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecutionWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setValue(value)
                                .setTo(to)
                                .setInput(input)
                                .setFeePayer(feePayer)
                                .setFeeRatio(feeRatio)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid input. : \(input)"))
        }
    }
    
    public func test_throwException_missingInput() throws {
        let input = ""
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecutionWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setValue(value)
                                .setTo(to)
                                .setInput(input)
                                .setFeePayer(feePayer)
                                .setFeeRatio(feeRatio)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("input is missing."))
        }
    }
    
    public func test_throwException_setFeePayerSignatures_missingFeePayer() throws {
        let feePayer = ""
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecutionWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setValue(value)
                                .setTo(to)
                                .setInput(input)
                                .setFeePayer(feePayer)
                                .setFeeRatio(feeRatio)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("feePayer is missing: feePayer must be defined with feePayerSignatures."))
        }
    }
    
    public func test_throwException_FeeRatio_invalid() throws {
        let feeRatio = "invalid fee ratio"
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecutionWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setFeePayer(feePayer)
                                .setFeeRatio(feeRatio)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid type of feeRatio: feeRatio should be number type or hex number string"))
        }
    }
    
    public func test_throwException_FeeRatio_outOfRange() throws {
        let feeRatio = BigInt(101)
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecutionWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setFeePayer(feePayer)
                                .setFeeRatio(feeRatio)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid feeRatio: feeRatio is out of range. [1,99]"))
        }
    }
    
    public func test_throwException_missingFeeRatio() throws {
        let feeRatio = ""
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecutionWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setFeePayer(feePayer)
                                .setFeeRatio(feeRatio)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("feeRatio is missing."))
        }
    }
}

class FeeDelegatedSmartContractExecutionWithRatioTest_createInstance: XCTestCase {
    let from = FeeDelegatedSmartContractExecutionWithRatioTest.from
    let account = FeeDelegatedSmartContractExecutionWithRatioTest.account
    let to = FeeDelegatedSmartContractExecutionWithRatioTest.to
    let gas = FeeDelegatedSmartContractExecutionWithRatioTest.gas
    let nonce = FeeDelegatedSmartContractExecutionWithRatioTest.nonce
    let gasPrice = FeeDelegatedSmartContractExecutionWithRatioTest.gasPrice
    let chainID = FeeDelegatedSmartContractExecutionWithRatioTest.chainID
    let value = FeeDelegatedSmartContractExecutionWithRatioTest.value
    let input = FeeDelegatedSmartContractExecutionWithRatioTest.input
    let humanReadable = FeeDelegatedSmartContractExecutionWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractExecutionWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractExecutionWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedSmartContractExecutionWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractExecutionWithRatioTest.feePayerSignatureData
    let feeRatio = "0x1E"
    
    public func test_createInstance() throws {
        let txObj = try FeeDelegatedSmartContractExecutionWithRatio(
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
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecutionWithRatio(
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
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecutionWithRatio(
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
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecutionWithRatio(
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
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecutionWithRatio(
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
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecutionWithRatio(
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
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecutionWithRatio(
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
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecutionWithRatio(
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
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecutionWithRatio(
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
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecutionWithRatio(
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
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecutionWithRatio(
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
    
    public func test_throwException_FeeRatio_invalid() throws {
        let feeRatio = "invalid fee ratio"
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecutionWithRatio(
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
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecutionWithRatio(
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
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecutionWithRatio(
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

class FeeDelegatedSmartContractExecutionWithRatioTest_getRLPEncodingTest: XCTestCase {
    let from = FeeDelegatedSmartContractExecutionWithRatioTest.from
    let account = FeeDelegatedSmartContractExecutionWithRatioTest.account
    let to = FeeDelegatedSmartContractExecutionWithRatioTest.to
    let gas = FeeDelegatedSmartContractExecutionWithRatioTest.gas
    let nonce = FeeDelegatedSmartContractExecutionWithRatioTest.nonce
    let gasPrice = FeeDelegatedSmartContractExecutionWithRatioTest.gasPrice
    let chainID = FeeDelegatedSmartContractExecutionWithRatioTest.chainID
    let value = FeeDelegatedSmartContractExecutionWithRatioTest.value
    let input = FeeDelegatedSmartContractExecutionWithRatioTest.input
    let humanReadable = FeeDelegatedSmartContractExecutionWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractExecutionWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractExecutionWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedSmartContractExecutionWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractExecutionWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedSmartContractExecutionWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedSmartContractExecutionWithRatioTest.expectedRLPEncoding
    
    public func test_getRLPEncoding() throws {
        let txObj = try FeeDelegatedSmartContractExecutionWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertEqual(expectedRLPEncoding, try txObj.getRLPEncoding())
    }
    
    public func test_throwException_NoNonce() throws {
        let txObj = try FeeDelegatedSmartContractExecutionWithRatio.Builder()
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertThrowsError(try txObj.getRLPEncoding()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NoGasPrice() throws {
        let txObj = try FeeDelegatedSmartContractExecutionWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertThrowsError(try txObj.getRLPEncoding()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class FeeDelegatedSmartContractExecutionWithRatioTest_signAsFeePayer_OneKeyTest: XCTestCase {
    var mTxObj: FeeDelegatedSmartContractExecutionWithRatio?
    var klaytnWalletKey: String?
    var keyring: AbstractKeyring?
    var feePayerAddress: String?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedSmartContractExecutionWithRatioTest.feePayerPrivateKey
    
    let from = FeeDelegatedSmartContractExecutionWithRatioTest.from
    let account = FeeDelegatedSmartContractExecutionWithRatioTest.account
    let to = FeeDelegatedSmartContractExecutionWithRatioTest.to
    let gas = FeeDelegatedSmartContractExecutionWithRatioTest.gas
    let nonce = FeeDelegatedSmartContractExecutionWithRatioTest.nonce
    let gasPrice = FeeDelegatedSmartContractExecutionWithRatioTest.gasPrice
    let chainID = FeeDelegatedSmartContractExecutionWithRatioTest.chainID
    let value = FeeDelegatedSmartContractExecutionWithRatioTest.value
    let input = FeeDelegatedSmartContractExecutionWithRatioTest.input
    let humanReadable = FeeDelegatedSmartContractExecutionWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractExecutionWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractExecutionWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedSmartContractExecutionWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractExecutionWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedSmartContractExecutionWithRatioTest.feeRatio
    
    override func setUpWithError() throws {
        keyring = try KeyringFactory.createWithSingleKey(feePayer, feePayerPrivateKey)
        klaytnWalletKey = try keyring?.getKlaytnWalletKey()
        
        mTxObj = try FeeDelegatedSmartContractExecutionWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .build()
    }
    
    public func test_signAsFeePayer_String() throws {
        let feePayerPrivateKey = PrivateKey.generate().privateKey
        let feePayer = try PrivateKey(feePayerPrivateKey).getDerivedAddress()
        
        mTxObj = try FeeDelegatedSmartContractExecutionWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .build()
        
        _ = try mTxObj!.signAsFeePayer(feePayerPrivateKey)
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

class FeeDelegatedSmartContractExecutionWithRatioTest_signAsFeePayer_AllKeyTest: XCTestCase {
    var mTxObj: FeeDelegatedSmartContractExecutionWithRatio?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedSmartContractExecutionWithRatioTest.feePayerPrivateKey
    
    let from = FeeDelegatedSmartContractExecutionWithRatioTest.from
    let account = FeeDelegatedSmartContractExecutionWithRatioTest.account
    let to = FeeDelegatedSmartContractExecutionWithRatioTest.to
    let gas = FeeDelegatedSmartContractExecutionWithRatioTest.gas
    let nonce = FeeDelegatedSmartContractExecutionWithRatioTest.nonce
    let gasPrice = FeeDelegatedSmartContractExecutionWithRatioTest.gasPrice
    let chainID = FeeDelegatedSmartContractExecutionWithRatioTest.chainID
    let value = FeeDelegatedSmartContractExecutionWithRatioTest.value
    let input = FeeDelegatedSmartContractExecutionWithRatioTest.input
    let humanReadable = FeeDelegatedSmartContractExecutionWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractExecutionWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractExecutionWithRatioTest.senderSignatureData
    var feePayer = FeeDelegatedSmartContractExecutionWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractExecutionWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedSmartContractExecutionWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedSmartContractExecutionWithRatioTest.expectedRLPEncoding
    
    override func setUpWithError() throws {
        mTxObj = try FeeDelegatedSmartContractExecutionWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
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

class FeeDelegatedSmartContractExecutionWithRatioTest_appendFeePayerSignaturesTest: XCTestCase {
    var mTxObj: FeeDelegatedSmartContractExecutionWithRatio?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = FeeDelegatedSmartContractExecutionWithRatioTest.senderPrivateKey
    let feePayerPrivateKey = FeeDelegatedSmartContractExecutionWithRatioTest.feePayerPrivateKey
    
    let from = FeeDelegatedSmartContractExecutionWithRatioTest.from
    let account = FeeDelegatedSmartContractExecutionWithRatioTest.account
    let to = FeeDelegatedSmartContractExecutionWithRatioTest.to
    let gas = FeeDelegatedSmartContractExecutionWithRatioTest.gas
    let nonce = FeeDelegatedSmartContractExecutionWithRatioTest.nonce
    let gasPrice = FeeDelegatedSmartContractExecutionWithRatioTest.gasPrice
    let chainID = FeeDelegatedSmartContractExecutionWithRatioTest.chainID
    let value = FeeDelegatedSmartContractExecutionWithRatioTest.value
    let input = FeeDelegatedSmartContractExecutionWithRatioTest.input
    let humanReadable = FeeDelegatedSmartContractExecutionWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractExecutionWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractExecutionWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedSmartContractExecutionWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractExecutionWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedSmartContractExecutionWithRatioTest.feeRatio
    
    override func setUpWithError() throws {
        mTxObj = try FeeDelegatedSmartContractExecutionWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .build()
        
        coupledKeyring = try KeyringFactory.createFromPrivateKey(privateKey)
        deCoupledKeyring = try KeyringFactory.createWithSingleKey(PrivateKey.generate().getDerivedAddress(), privateKey)
        klaytnWalletKey = try coupledKeyring?.getKlaytnWalletKey()
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
        mTxObj = try FeeDelegatedSmartContractExecutionWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(emptySignature)
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
        
        mTxObj = try FeeDelegatedSmartContractExecutionWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
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
        
        mTxObj = try FeeDelegatedSmartContractExecutionWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
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

class FeeDelegatedSmartContractExecutionWithRatioTest_combineSignatureTest: XCTestCase {
    var mTxObj: FeeDelegatedSmartContractExecutionWithRatio?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = FeeDelegatedSmartContractExecutionWithRatioTest.senderPrivateKey
    let from = "0xe862a5ddac7f82f57eaea34f3f915121a6da1bb2"
    var account: Account?
    let to = "0xf14274fd5f22f436e3a2d3f3b167f9f241c33db5"
    let gas = "0x30d40"
    let nonce = "0x3"
    let gasPrice = "0x5d21dba00"
    let chainID = "0x7e3"
    let value = "0x0"
    let input = "0xa9059cbb000000000000000000000000ad3bd7a7df94367e8b0443dd10e86330750ebf0c00000000000000000000000000000000000000000000000000000002540be400"
    let humanReadable = FeeDelegatedSmartContractExecutionWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractExecutionWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractExecutionWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedSmartContractExecutionWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractExecutionWithRatioTest.feePayerSignatureData
    let feeRatio = BigInt(30)
    let expectedRLPEncoding = FeeDelegatedSmartContractExecutionWithRatioTest.expectedRLPEncoding
    
    override func setUpWithError() throws {
        mTxObj = try FeeDelegatedSmartContractExecutionWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setTo(to)
            .setValue(value)
            .setInput(input)
            .setChainId(chainID)
            .setFeeRatio(feeRatio)
            .build()
    }
    
    public func test_combineSignature() throws {
        let expectedRLPEncoded = "0x32f8e0038505d21dba0083030d4094f14274fd5f22f436e3a2d3f3b167f9f241c33db58094e862a5ddac7f82f57eaea34f3f915121a6da1bb2b844a9059cbb000000000000000000000000ad3bd7a7df94367e8b0443dd10e86330750ebf0c00000000000000000000000000000000000000000000000000000002540be4001ef847f845820fe9a0b95ed5ff6d9cd8d02e3031ea4ddf38d42803817b5ecc086828f497787699bf5ba0105105455d4af28cc943e43e375316b57205e6eb664407b3bc1a7eca9ecd6c8f940000000000000000000000000000000000000000c4c3018080"
        
        let expectedSignature = SignatureData(
            "0x0fe9",
            "0xb95ed5ff6d9cd8d02e3031ea4ddf38d42803817b5ecc086828f497787699bf5b",
            "0x105105455d4af28cc943e43e375316b57205e6eb664407b3bc1a7eca9ecd6c8f"
        )
        
        let rlpEncoded = "0x32f8e0038505d21dba0083030d4094f14274fd5f22f436e3a2d3f3b167f9f241c33db58094e862a5ddac7f82f57eaea34f3f915121a6da1bb2b844a9059cbb000000000000000000000000ad3bd7a7df94367e8b0443dd10e86330750ebf0c00000000000000000000000000000000000000000000000000000002540be4001ef847f845820fe9a0b95ed5ff6d9cd8d02e3031ea4ddf38d42803817b5ecc086828f497787699bf5ba0105105455d4af28cc943e43e375316b57205e6eb664407b3bc1a7eca9ecd6c8f940000000000000000000000000000000000000000c4c3018080"
        
        let combined = try mTxObj!.combineSignedRawTransactions([rlpEncoded])
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature, mTxObj?.signatures[0])
    }
    
    public func test_combine_multipleSignature() throws {
        let expectedRLPEncoded = "0x32f9016e038505d21dba0083030d4094f14274fd5f22f436e3a2d3f3b167f9f241c33db58094e862a5ddac7f82f57eaea34f3f915121a6da1bb2b844a9059cbb000000000000000000000000ad3bd7a7df94367e8b0443dd10e86330750ebf0c00000000000000000000000000000000000000000000000000000002540be4001ef8d5f845820fe9a0b95ed5ff6d9cd8d02e3031ea4ddf38d42803817b5ecc086828f497787699bf5ba0105105455d4af28cc943e43e375316b57205e6eb664407b3bc1a7eca9ecd6c8ff845820fe9a058cf881d440cd88e2a1d0999b4b0eec72b36f7c13a793fcba7d509c544c06505a025bdcc5b6f7619169397508d38da290faa54b01c83c582d1dfa0ba250b7a1871f845820fe9a0fa309605c494a338e4cd92c7bedeafa25387f57e0b5f6e18f9d8da90edea9e44a055d173d614d096f23eb9a01fd894f961d266985df6503d5176d047eb3b3ef5ed940000000000000000000000000000000000000000c4c3018080"
        
        let expectedSignature = [
            SignatureData(
                "0x0fe9",
                "0xb95ed5ff6d9cd8d02e3031ea4ddf38d42803817b5ecc086828f497787699bf5b",
                "0x105105455d4af28cc943e43e375316b57205e6eb664407b3bc1a7eca9ecd6c8f"
            ),
            SignatureData(
                "0x0fe9",
                "0x58cf881d440cd88e2a1d0999b4b0eec72b36f7c13a793fcba7d509c544c06505",
                "0x25bdcc5b6f7619169397508d38da290faa54b01c83c582d1dfa0ba250b7a1871"
            ),
            SignatureData(
                "0x0fe9",
                "0xfa309605c494a338e4cd92c7bedeafa25387f57e0b5f6e18f9d8da90edea9e44",
                "0x55d173d614d096f23eb9a01fd894f961d266985df6503d5176d047eb3b3ef5ed"
            )
        ]
        
        let rlpEncodedString = [
            "0x32f8cc038505d21dba0083030d4094f14274fd5f22f436e3a2d3f3b167f9f241c33db58094e862a5ddac7f82f57eaea34f3f915121a6da1bb2b844a9059cbb000000000000000000000000ad3bd7a7df94367e8b0443dd10e86330750ebf0c00000000000000000000000000000000000000000000000000000002540be4001ef847f845820fe9a058cf881d440cd88e2a1d0999b4b0eec72b36f7c13a793fcba7d509c544c06505a025bdcc5b6f7619169397508d38da290faa54b01c83c582d1dfa0ba250b7a187180c4c3018080",
            "0x32f8cc038505d21dba0083030d4094f14274fd5f22f436e3a2d3f3b167f9f241c33db58094e862a5ddac7f82f57eaea34f3f915121a6da1bb2b844a9059cbb000000000000000000000000ad3bd7a7df94367e8b0443dd10e86330750ebf0c00000000000000000000000000000000000000000000000000000002540be4001ef847f845820fe9a0fa309605c494a338e4cd92c7bedeafa25387f57e0b5f6e18f9d8da90edea9e44a055d173d614d096f23eb9a01fd894f961d266985df6503d5176d047eb3b3ef5ed80c4c3018080"
        ]
        
        let senderSignatureData = SignatureData(
            "0x0fe9",
            "0xb95ed5ff6d9cd8d02e3031ea4ddf38d42803817b5ecc086828f497787699bf5b",
            "0x105105455d4af28cc943e43e375316b57205e6eb664407b3bc1a7eca9ecd6c8f"
        )
        
        mTxObj = try FeeDelegatedSmartContractExecutionWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setTo(to)
            .setValue(value)
            .setInput(input)
            .setChainId(chainID)
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
        let feePayer = "0xad3bd7a7df94367e8b0443dd10e86330750ebf0c"
        let expectedRLPEncoded = "0x32f8e0038505d21dba0083030d4094f14274fd5f22f436e3a2d3f3b167f9f241c33db58094e862a5ddac7f82f57eaea34f3f915121a6da1bb2b844a9059cbb000000000000000000000000ad3bd7a7df94367e8b0443dd10e86330750ebf0c00000000000000000000000000000000000000000000000000000002540be4001ec4c301808094ad3bd7a7df94367e8b0443dd10e86330750ebf0cf847f845820fe9a0c7a060a2e28476e4567bc76964f826153149a07c061e389b51f34f3863f65a31a01bfd20aca5b410ca369113150c16af4d9f9c72907aaaf34896427ef1f1a51ebb"
        
        let expectedSignature = SignatureData(
            "0x0fe9",
            "0xc7a060a2e28476e4567bc76964f826153149a07c061e389b51f34f3863f65a31",
            "0x1bfd20aca5b410ca369113150c16af4d9f9c72907aaaf34896427ef1f1a51ebb"
        )
        
        let rlpEncoded = "0x32f8e0038505d21dba0083030d4094f14274fd5f22f436e3a2d3f3b167f9f241c33db58094e862a5ddac7f82f57eaea34f3f915121a6da1bb2b844a9059cbb000000000000000000000000ad3bd7a7df94367e8b0443dd10e86330750ebf0c00000000000000000000000000000000000000000000000000000002540be4001ec4c301808094ad3bd7a7df94367e8b0443dd10e86330750ebf0cf847f845820fe9a0c7a060a2e28476e4567bc76964f826153149a07c061e389b51f34f3863f65a31a01bfd20aca5b410ca369113150c16af4d9f9c72907aaaf34896427ef1f1a51ebb"
        
        mTxObj = try FeeDelegatedSmartContractExecutionWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setTo(to)
            .setValue(value)
            .setInput(input)
            .setFeePayer(feePayer)
            .setChainId(chainID)
            .setFeeRatio(feeRatio)
            .build()
        
        let combined = try mTxObj!.combineSignedRawTransactions([rlpEncoded])
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature, mTxObj?.feePayerSignatures[0])
    }
    
    public func test_combineSignature_multipleFeePayerSignature() throws {
        let expectedRLPEncoded = "0x32f9016e038505d21dba0083030d4094f14274fd5f22f436e3a2d3f3b167f9f241c33db58094e862a5ddac7f82f57eaea34f3f915121a6da1bb2b844a9059cbb000000000000000000000000ad3bd7a7df94367e8b0443dd10e86330750ebf0c00000000000000000000000000000000000000000000000000000002540be4001ec4c301808094ad3bd7a7df94367e8b0443dd10e86330750ebf0cf8d5f845820fe9a0c7a060a2e28476e4567bc76964f826153149a07c061e389b51f34f3863f65a31a01bfd20aca5b410ca369113150c16af4d9f9c72907aaaf34896427ef1f1a51ebbf845820feaa09d6fb034ed27fa0baf8ba2650b48e087d261ab7716eae4df9299236ddce7dd08a053b1c7ab56349cbb5515e27737846f97862e3f20409b183c3c6b4a918cd20920f845820fe9a019315d03a16242c6d754bd006883376e211b6f8af486d1b41a0705878e3bb100a06d463477534b9c5e82196cb8c8982bc0e3c9120b14c2db3df0f4d1c9dc04c657"
        
        let expectedSignature = [
            SignatureData(
                "0x0fe9",
                "0xc7a060a2e28476e4567bc76964f826153149a07c061e389b51f34f3863f65a31",
                "0x1bfd20aca5b410ca369113150c16af4d9f9c72907aaaf34896427ef1f1a51ebb"
            ),
            SignatureData(
                "0x0fea",
                "0x9d6fb034ed27fa0baf8ba2650b48e087d261ab7716eae4df9299236ddce7dd08",
                "0x53b1c7ab56349cbb5515e27737846f97862e3f20409b183c3c6b4a918cd20920"
            ),
            SignatureData(
                "0x0fe9",
                "0x19315d03a16242c6d754bd006883376e211b6f8af486d1b41a0705878e3bb100",
                "0x6d463477534b9c5e82196cb8c8982bc0e3c9120b14c2db3df0f4d1c9dc04c657"
            )
        ]
        
        let rlpEncodedString = [
            "0x32f8e0038505d21dba0083030d4094f14274fd5f22f436e3a2d3f3b167f9f241c33db58094e862a5ddac7f82f57eaea34f3f915121a6da1bb2b844a9059cbb000000000000000000000000ad3bd7a7df94367e8b0443dd10e86330750ebf0c00000000000000000000000000000000000000000000000000000002540be4001ec4c301808094ad3bd7a7df94367e8b0443dd10e86330750ebf0cf847f845820feaa09d6fb034ed27fa0baf8ba2650b48e087d261ab7716eae4df9299236ddce7dd08a053b1c7ab56349cbb5515e27737846f97862e3f20409b183c3c6b4a918cd20920",
            "0x32f8e0038505d21dba0083030d4094f14274fd5f22f436e3a2d3f3b167f9f241c33db58094e862a5ddac7f82f57eaea34f3f915121a6da1bb2b844a9059cbb000000000000000000000000ad3bd7a7df94367e8b0443dd10e86330750ebf0c00000000000000000000000000000000000000000000000000000002540be4001ec4c301808094ad3bd7a7df94367e8b0443dd10e86330750ebf0cf847f845820fe9a019315d03a16242c6d754bd006883376e211b6f8af486d1b41a0705878e3bb100a06d463477534b9c5e82196cb8c8982bc0e3c9120b14c2db3df0f4d1c9dc04c657",
        ]
        
        let feePayer = "0xad3bd7a7df94367e8b0443dd10e86330750ebf0c"
        let feePayerSignatureData = SignatureData(
            "0x0fe9",
            "0xc7a060a2e28476e4567bc76964f826153149a07c061e389b51f34f3863f65a31",
            "0x1bfd20aca5b410ca369113150c16af4d9f9c72907aaaf34896427ef1f1a51ebb"
        )
        
        mTxObj = try FeeDelegatedSmartContractExecutionWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setTo(to)
            .setValue(value)
            .setInput(input)
            .setChainId(chainID)
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
        mTxObj = try FeeDelegatedSmartContractExecutionWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeeRatio(feeRatio)
            .build()
        
        let rlpEncodedString = "0x32f9015a038505d21dba0083030d4094f14274fd5f22f436e3a2d3f3b167f9f241c33db58094e862a5ddac7f82f57eaea34f3f915121a6da1bb2b844a9059cbb000000000000000000000000ad3bd7a7df94367e8b0443dd10e86330750ebf0c00000000000000000000000000000000000000000000000000000002540be4001ef8d5f845820fe9a0b95ed5ff6d9cd8d02e3031ea4ddf38d42803817b5ecc086828f497787699bf5ba0105105455d4af28cc943e43e375316b57205e6eb664407b3bc1a7eca9ecd6c8ff845820fe9a058cf881d440cd88e2a1d0999b4b0eec72b36f7c13a793fcba7d509c544c06505a025bdcc5b6f7619169397508d38da290faa54b01c83c582d1dfa0ba250b7a1871f845820fe9a0fa309605c494a338e4cd92c7bedeafa25387f57e0b5f6e18f9d8da90edea9e44a055d173d614d096f23eb9a01fd894f961d266985df6503d5176d047eb3b3ef5ed80c4c3018080"
        
        let expectedSignature = [
            SignatureData(
                "0x0fe9",
                "0xb95ed5ff6d9cd8d02e3031ea4ddf38d42803817b5ecc086828f497787699bf5b",
                "0x105105455d4af28cc943e43e375316b57205e6eb664407b3bc1a7eca9ecd6c8f"
            ),
            SignatureData(
                "0x0fe9",
                "0x58cf881d440cd88e2a1d0999b4b0eec72b36f7c13a793fcba7d509c544c06505",
                "0x25bdcc5b6f7619169397508d38da290faa54b01c83c582d1dfa0ba250b7a1871"
            ),
            SignatureData(
                "0x0fe9",
                "0xfa309605c494a338e4cd92c7bedeafa25387f57e0b5f6e18f9d8da90edea9e44",
                "0x55d173d614d096f23eb9a01fd894f961d266985df6503d5176d047eb3b3ef5ed"
            )
        ]
        
        _ = try mTxObj!.combineSignedRawTransactions([rlpEncodedString])
        
        let rlpEncodedStringsWithFeePayerSignatures = "0x32f9016e038505d21dba0083030d4094f14274fd5f22f436e3a2d3f3b167f9f241c33db58094e862a5ddac7f82f57eaea34f3f915121a6da1bb2b844a9059cbb000000000000000000000000ad3bd7a7df94367e8b0443dd10e86330750ebf0c00000000000000000000000000000000000000000000000000000002540be4001ec4c301808094ad3bd7a7df94367e8b0443dd10e86330750ebf0cf8d5f845820fe9a0c7a060a2e28476e4567bc76964f826153149a07c061e389b51f34f3863f65a31a01bfd20aca5b410ca369113150c16af4d9f9c72907aaaf34896427ef1f1a51ebbf845820feaa09d6fb034ed27fa0baf8ba2650b48e087d261ab7716eae4df9299236ddce7dd08a053b1c7ab56349cbb5515e27737846f97862e3f20409b183c3c6b4a918cd20920f845820fe9a019315d03a16242c6d754bd006883376e211b6f8af486d1b41a0705878e3bb100a06d463477534b9c5e82196cb8c8982bc0e3c9120b14c2db3df0f4d1c9dc04c657"
        
        let expectedFeePayerSignatures = [
            SignatureData(
                "0x0fe9",
                "0xc7a060a2e28476e4567bc76964f826153149a07c061e389b51f34f3863f65a31",
                "0x1bfd20aca5b410ca369113150c16af4d9f9c72907aaaf34896427ef1f1a51ebb"
            ),
            SignatureData(
                "0x0fea",
                "0x9d6fb034ed27fa0baf8ba2650b48e087d261ab7716eae4df9299236ddce7dd08",
                "0x53b1c7ab56349cbb5515e27737846f97862e3f20409b183c3c6b4a918cd20920"
            ),
            SignatureData(
                "0x0fe9",
                "0x19315d03a16242c6d754bd006883376e211b6f8af486d1b41a0705878e3bb100",
                "0x6d463477534b9c5e82196cb8c8982bc0e3c9120b14c2db3df0f4d1c9dc04c657"
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
        mTxObj = try FeeDelegatedSmartContractExecutionWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeeRatio(feeRatio)
            .build()
        
        let rlpEncoded = "0x32f8cc038505d21dba0083030d4094f14274fd5f22f436e3a2d3f3b167f9f241c33db58094e862a5ddac7f82f57eaea34f3f915121a6da1bb2b844a9059cbb000000000000000000000000ad3bd7a7df94367e8b0443dd10e86330750ebf0c00000000000000000000000000000000000000000000000000000002540be4001ef847f845820fe9a0b95ed5ff6d9cd8d02e3031ea4ddf38d42803817b5ecc086828f497787699bf5ba0105105455d4af28cc943e43e375316b57205e6eb664407b3bc1a7eca9ecd6c8f80c4c3018080"
        
        XCTAssertThrowsError(try mTxObj!.combineSignedRawTransactions([rlpEncoded])) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("Transactions containing different information cannot be combined."))
        }
    }
}

class FeeDelegatedSmartContractExecutionWithRatioTest_getRawTransactionTest: XCTestCase {
    let privateKey = FeeDelegatedSmartContractExecutionWithRatioTest.senderPrivateKey
    let feePayerPrivateKey = FeeDelegatedSmartContractExecutionWithRatioTest.feePayerPrivateKey
    
    let from = FeeDelegatedSmartContractExecutionWithRatioTest.from
    let account = FeeDelegatedSmartContractExecutionWithRatioTest.account
    let to = FeeDelegatedSmartContractExecutionWithRatioTest.to
    let gas = FeeDelegatedSmartContractExecutionWithRatioTest.gas
    let nonce = FeeDelegatedSmartContractExecutionWithRatioTest.nonce
    let gasPrice = FeeDelegatedSmartContractExecutionWithRatioTest.gasPrice
    let chainID = FeeDelegatedSmartContractExecutionWithRatioTest.chainID
    let value = FeeDelegatedSmartContractExecutionWithRatioTest.value
    let input = FeeDelegatedSmartContractExecutionWithRatioTest.input
    let humanReadable = FeeDelegatedSmartContractExecutionWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractExecutionWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractExecutionWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedSmartContractExecutionWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractExecutionWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedSmartContractExecutionWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedSmartContractExecutionWithRatioTest.expectedRLPEncoding
    
    public func test_getRawTransaction() throws {
        let txObj = try FeeDelegatedSmartContractExecutionWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertEqual(expectedRLPEncoding, try txObj.getRawTransaction())
    }
}

class FeeDelegatedSmartContractExecutionWithRatioTest_getTransactionHashTest: XCTestCase {
    var mTxObj: FeeDelegatedSmartContractExecutionWithRatio?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = FeeDelegatedSmartContractExecutionWithRatioTest.senderPrivateKey
    let feePayerPrivateKey = FeeDelegatedSmartContractExecutionWithRatioTest.feePayerPrivateKey
    
    let from = FeeDelegatedSmartContractExecutionWithRatioTest.from
    let account = FeeDelegatedSmartContractExecutionWithRatioTest.account
    let to = FeeDelegatedSmartContractExecutionWithRatioTest.to
    let gas = FeeDelegatedSmartContractExecutionWithRatioTest.gas
    let nonce = FeeDelegatedSmartContractExecutionWithRatioTest.nonce
    let gasPrice = FeeDelegatedSmartContractExecutionWithRatioTest.gasPrice
    let chainID = FeeDelegatedSmartContractExecutionWithRatioTest.chainID
    let value = FeeDelegatedSmartContractExecutionWithRatioTest.value
    let input = FeeDelegatedSmartContractExecutionWithRatioTest.input
    let humanReadable = FeeDelegatedSmartContractExecutionWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractExecutionWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractExecutionWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedSmartContractExecutionWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractExecutionWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedSmartContractExecutionWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedSmartContractExecutionWithRatioTest.expectedRLPEncoding
    let expectedTransactionHash = FeeDelegatedSmartContractExecutionWithRatioTest.expectedTransactionHash
    
    public func test_getTransactionHash() throws {
        let txObj = try FeeDelegatedSmartContractExecutionWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertEqual(expectedTransactionHash, try txObj.getTransactionHash())
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try FeeDelegatedSmartContractExecutionWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertThrowsError(try mTxObj!.getTransactionHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_gasPrice() throws {
        let gasPrice = ""
        
        mTxObj = try FeeDelegatedSmartContractExecutionWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertThrowsError(try mTxObj!.getTransactionHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class FeeDelegatedSmartContractExecutionWithRatioTest_getSenderTxHashTest: XCTestCase {
    var mTxObj: FeeDelegatedSmartContractExecutionWithRatio?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = FeeDelegatedSmartContractExecutionWithRatioTest.senderPrivateKey
    let from = FeeDelegatedSmartContractExecutionWithRatioTest.from
    let account = FeeDelegatedSmartContractExecutionWithRatioTest.account
    let to = FeeDelegatedSmartContractExecutionWithRatioTest.to
    let gas = FeeDelegatedSmartContractExecutionWithRatioTest.gas
    let nonce = FeeDelegatedSmartContractExecutionWithRatioTest.nonce
    let gasPrice = FeeDelegatedSmartContractExecutionWithRatioTest.gasPrice
    let chainID = FeeDelegatedSmartContractExecutionWithRatioTest.chainID
    let value = FeeDelegatedSmartContractExecutionWithRatioTest.value
    let input = FeeDelegatedSmartContractExecutionWithRatioTest.input
    let humanReadable = FeeDelegatedSmartContractExecutionWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractExecutionWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractExecutionWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedSmartContractExecutionWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractExecutionWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedSmartContractExecutionWithRatioTest.feeRatio
    let expectedRLPEncoding = FeeDelegatedSmartContractExecutionWithRatioTest.expectedRLPEncoding
    let expectedTransactionHash = FeeDelegatedSmartContractExecutionWithRatioTest.expectedTransactionHash
    let expectedSenderTransactionHash = FeeDelegatedSmartContractExecutionWithRatioTest.expectedSenderTransactionHash
    
    public func test_getRLPEncodingForSignature() throws {
        mTxObj = try FeeDelegatedSmartContractExecutionWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertEqual(expectedSenderTransactionHash, try mTxObj!.getSenderTxHash())
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try FeeDelegatedSmartContractExecutionWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertThrowsError(try mTxObj!.getSenderTxHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_gasPrice() throws {
        let gasPrice = ""
        
        mTxObj = try FeeDelegatedSmartContractExecutionWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertThrowsError(try mTxObj!.getSenderTxHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class FeeDelegatedSmartContractExecutionWithRatioTest_getRLPEncodingForFeePayerSignatureTest: XCTestCase {
    var mTxObj: FeeDelegatedSmartContractExecutionWithRatio?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = FeeDelegatedSmartContractExecutionWithRatioTest.senderPrivateKey
    let from = FeeDelegatedSmartContractExecutionWithRatioTest.from
    let account = FeeDelegatedSmartContractExecutionWithRatioTest.account
    let to = FeeDelegatedSmartContractExecutionWithRatioTest.to
    let gas = FeeDelegatedSmartContractExecutionWithRatioTest.gas
    let nonce = FeeDelegatedSmartContractExecutionWithRatioTest.nonce
    let gasPrice = FeeDelegatedSmartContractExecutionWithRatioTest.gasPrice
    let chainID = FeeDelegatedSmartContractExecutionWithRatioTest.chainID
    let value = FeeDelegatedSmartContractExecutionWithRatioTest.value
    let input = FeeDelegatedSmartContractExecutionWithRatioTest.input
    let humanReadable = FeeDelegatedSmartContractExecutionWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractExecutionWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractExecutionWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedSmartContractExecutionWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractExecutionWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedSmartContractExecutionWithRatioTest.feeRatio
    let expectedRLPEncoding = FeeDelegatedSmartContractExecutionWithRatioTest.expectedRLPEncoding
    let expectedTransactionHash = FeeDelegatedSmartContractExecutionWithRatioTest.expectedTransactionHash
    let expectedSenderTransactionHash = FeeDelegatedSmartContractExecutionWithRatioTest.expectedSenderTransactionHash
    let expectedRLPEncodingForFeePayerSigning = FeeDelegatedSmartContractExecutionWithRatioTest.expectedRLPEncodingForFeePayerSigning
    
    public func test_getRLPEncodingForSignature() throws {
        mTxObj = try FeeDelegatedSmartContractExecutionWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertEqual(expectedRLPEncodingForFeePayerSigning, try mTxObj!.getRLPEncodingForFeePayerSignature())
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try FeeDelegatedSmartContractExecutionWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertThrowsError(try mTxObj!.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_gasPrice() throws {
        let gasPrice = ""
        
        mTxObj = try FeeDelegatedSmartContractExecutionWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertThrowsError(try mTxObj!.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_chainID() throws {
        let chainID = ""
        
        mTxObj = try FeeDelegatedSmartContractExecutionWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertThrowsError(try mTxObj!.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("chainId is undefined. Define chainId in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}


