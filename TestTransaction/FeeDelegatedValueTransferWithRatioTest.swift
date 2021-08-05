//
//  FeeDelegatedValueTransferWithRatioTest.swift
//  CaverSwiftTests
//
//  Created by won on 2021/07/16.
//

import XCTest
@testable import CaverSwift

class FeeDelegatedValueTransferWithRatioTest: XCTestCase {
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
        "0x25",
        "0xdde32b8241f039a82b124fe94d3e556eb08f0d6f26d07dcc0f3fca621f1090ca",
        "0x1c8c336b358ab6d3a2bbf25de2adab4d01b754e2fb3b9b710069177d54c1e956"
    )
    static let feePayer = "0x5A0043070275d9f6054307Ee7348bD660849D90f"
    static let feePayerSignatureData = SignatureData(
        "0x26",
        "0x91ecf53f91bb97bb694f2f2443f3563ac2b646d651497774524394aae396360",
        "0x44228b88f275aa1ec1bab43681d21dc7e3a676786ed1906f6841d0a1a188f88a"
    )

    static let expectedRLPEncoding = "0x0af8d78204d219830f4240947b65b75d204abed71587c9e519a89277766ee1d00a94a94f5374fce5edbc8e2a8697c15331677e6ebf0b1ef845f84325a0dde32b8241f039a82b124fe94d3e556eb08f0d6f26d07dcc0f3fca621f1090caa01c8c336b358ab6d3a2bbf25de2adab4d01b754e2fb3b9b710069177d54c1e956945a0043070275d9f6054307ee7348bd660849d90ff845f84326a0091ecf53f91bb97bb694f2f2443f3563ac2b646d651497774524394aae396360a044228b88f275aa1ec1bab43681d21dc7e3a676786ed1906f6841d0a1a188f88a"
    static let expectedTransactionHash = "0x83a89f4debd8e9d6374b987e25132b3a4030c9cf9ace2fc6e7d1086fcea2ce40"
    static let expectedRLPSenderTransactionHash = "0x4711ed4023e821425968342c1d50063b6bc3176b1792b7075cfeee3656d450f6"
    static let expectedRLPEncodingForFeePayerSigning = "0xf84fb6f50a8204d219830f4240947b65b75d204abed71587c9e519a89277766ee1d00a94a94f5374fce5edbc8e2a8697c15331677e6ebf0b1e945a0043070275d9f6054307ee7348bd660849d90f018080"
        
    public static func generateRoleBaseKeyring(_ numArr: [Int], _ address: String) throws -> AbstractKeyring {
        let keyArr = KeyringFactory.generateRoleBasedKeys(numArr, "entropy")
        return try KeyringFactory.createWithRoleBasedKey(address, keyArr)
    }
}

class FeeDelegatedValueTransferWithRatioTest_createInstanceBuilder: XCTestCase {
    let from = FeeDelegatedValueTransferWithRatioTest.from
    let account = FeeDelegatedValueTransferWithRatioTest.account
    let to = FeeDelegatedValueTransferWithRatioTest.to
    let gas = FeeDelegatedValueTransferWithRatioTest.gas
    let nonce = FeeDelegatedValueTransferWithRatioTest.nonce
    let gasPrice = FeeDelegatedValueTransferWithRatioTest.gasPrice
    let chainID = FeeDelegatedValueTransferWithRatioTest.chainID
    let value = FeeDelegatedValueTransferWithRatioTest.value
    let input = FeeDelegatedValueTransferWithRatioTest.input
    let humanReadable = FeeDelegatedValueTransferWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedValueTransferWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedValueTransferWithRatioTest.feeRatio
        
    public func test_BuilderTest() throws {
        let txObj = try FeeDelegatedValueTransferWithRatio.Builder()
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
            .build()
        
        XCTAssertNotNil(txObj)
    }
    
    public func test_BuilderWithRPCTest() throws {
        let txObj = try FeeDelegatedValueTransferWithRatio.Builder()
            .setKlaytnCall(FeeDelegatedValueTransferWithRatioTest.caver.rpc.klay)
            .setGas(gas)
            .setTo(to)
            .setValue(value)
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
        let txObj = try FeeDelegatedValueTransferWithRatio.Builder()
            .setNonce(BigInt(hex: nonce)!)
            .setGas(BigInt(hex: gas)!)
            .setGasPrice(BigInt(hex: gasPrice)!)
            .setChainId(BigInt(hex: chainID)!)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
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
        XCTAssertThrowsError(try FeeDelegatedValueTransferWithRatio.Builder()
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
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(from)"))
        }
    }
    
    public func test_throwException_missingFrom() throws {
        let from = ""
        XCTAssertThrowsError(try FeeDelegatedValueTransferWithRatio.Builder()
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
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("from is missing."))
        }
    }
    
    public func test_throwException_invalidTo() throws {
        let to = "invalid input"
        XCTAssertThrowsError(try FeeDelegatedValueTransferWithRatio.Builder()
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
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(to)"))
        }
    }
    
    public func test_throwException_missingTo() throws {
        let to = ""
        XCTAssertThrowsError(try FeeDelegatedValueTransferWithRatio.Builder()
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
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("to is missing."))
        }
    }
    
    public func test_throwException_invalidValue() throws {
        let value = "invalid value"
        XCTAssertThrowsError(try FeeDelegatedValueTransferWithRatio.Builder()
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
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid value : \(value)"))
        }
    }
    
    public func test_throwException_missingValue() throws {
        let value = ""
        XCTAssertThrowsError(try FeeDelegatedValueTransferWithRatio.Builder()
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
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("value is missing."))
        }
    }
        
    public func test_throwException_invalidGas() throws {
        let gas = "invalid gas"
        XCTAssertThrowsError(try FeeDelegatedValueTransferWithRatio.Builder()
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
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid gas. : \(gas)"))
        }
    }
    
    public func test_throwException_missingGas() throws {
        let gas = ""
        XCTAssertThrowsError(try FeeDelegatedValueTransferWithRatio.Builder()
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
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("gas is missing."))
        }
    }
    
    public func test_throwException_setFeePayerSignatures_missingFeePayer() throws {
        let feePayer = ""
        XCTAssertThrowsError(try FeeDelegatedValueTransferWithRatio.Builder()
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
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("feePayer is missing: feePayer must be defined with feePayerSignatures."))
        }
    }
    
    public func test_throwException_FeeRatio_invalid() throws {
        let feeRatio = "invalid fee ratio"
        XCTAssertThrowsError(try FeeDelegatedValueTransferWithRatio.Builder()
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
        XCTAssertThrowsError(try FeeDelegatedValueTransferWithRatio.Builder()
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
        XCTAssertThrowsError(try FeeDelegatedValueTransferWithRatio.Builder()
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

class FeeDelegatedValueTransferWithRatioTest_createInstance: XCTestCase {
    let from = FeeDelegatedValueTransferWithRatioTest.from
    let account = FeeDelegatedValueTransferWithRatioTest.account
    let to = FeeDelegatedValueTransferWithRatioTest.to
    let gas = FeeDelegatedValueTransferWithRatioTest.gas
    let nonce = FeeDelegatedValueTransferWithRatioTest.nonce
    let gasPrice = FeeDelegatedValueTransferWithRatioTest.gasPrice
    let chainID = FeeDelegatedValueTransferWithRatioTest.chainID
    let value = FeeDelegatedValueTransferWithRatioTest.value
    let input = FeeDelegatedValueTransferWithRatioTest.input
    let humanReadable = FeeDelegatedValueTransferWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedValueTransferWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedValueTransferWithRatioTest.feeRatio.hexa
    
    public func test_createInstance() throws {
        let txObj = try FeeDelegatedValueTransferWithRatio(
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
            value
        )
        
        XCTAssertNotNil(txObj)
    }
    
    public func test_throwException_invalidFrom() throws {
        let from = "invalid Address"
        XCTAssertThrowsError(try FeeDelegatedValueTransferWithRatio(
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
            value
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(from)"))
        }
    }
    
    public func test_throwException_missingFrom() throws {
        let from = ""
        XCTAssertThrowsError(try FeeDelegatedValueTransferWithRatio(
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
            value
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("from is missing."))
        }
    }
    
    public func test_throwException_invalidTo() throws {
        let to = "invalid Address"
        XCTAssertThrowsError(try FeeDelegatedValueTransferWithRatio(
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
            value
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(to)"))
        }
    }
    
    public func test_throwException_missingTo() throws {
        let to = ""
        XCTAssertThrowsError(try FeeDelegatedValueTransferWithRatio(
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
            value
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("to is missing."))
        }
    }
    
    public func test_throwException_invalidValue() throws {
        let value = "invalid value"
        XCTAssertThrowsError(try FeeDelegatedValueTransferWithRatio(
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
            value
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid value : \(value)"))
        }
    }
    
    public func test_throwException_missingValue() throws {
        let value = ""
        XCTAssertThrowsError(try FeeDelegatedValueTransferWithRatio(
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
            value
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("value is missing."))
        }
    }
    
    public func test_throwException_invalidGas() throws {
        let gas = "invalid gas"
        XCTAssertThrowsError(try FeeDelegatedValueTransferWithRatio(
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
            value
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid gas. : \(gas)"))
        }
    }
    
    public func test_throwException_missingGas() throws {
        let gas = ""
        XCTAssertThrowsError(try FeeDelegatedValueTransferWithRatio(
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
            value
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("gas is missing."))
        }
    }
    
    public func test_throwException_setFeePayerSignatures_missingFeePayer() throws {
        let feePayer = ""
        XCTAssertThrowsError(try FeeDelegatedValueTransferWithRatio(
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
            value
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("feePayer is missing: feePayer must be defined with feePayerSignatures."))
        }
    }
    
    public func test_throwException_FeeRatio_invalid() throws {
        let feeRatio = "invalid fee ratio"
        XCTAssertThrowsError(try FeeDelegatedValueTransferWithRatio(
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
            value
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid type of feeRatio: feeRatio should be number type or hex number string"))
        }
    }
    
    public func test_throwException_FeeRatio_outOfRange() throws {
        let feeRatio = BigInt(101).hexa
        XCTAssertThrowsError(try FeeDelegatedValueTransferWithRatio(
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
            value
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid feeRatio: feeRatio is out of range. [1,99]"))
        }
    }
    
    public func test_throwException_missingFeeRatio() throws {
        let feeRatio = ""
        XCTAssertThrowsError(try FeeDelegatedValueTransferWithRatio(
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
            value
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("feeRatio is missing."))
        }
    }
}

class FeeDelegatedValueTransferWithRatioTest_getRLPEncodingTest: XCTestCase {
    let from = FeeDelegatedValueTransferWithRatioTest.from
    let account = FeeDelegatedValueTransferWithRatioTest.account
    let to = FeeDelegatedValueTransferWithRatioTest.to
    let gas = FeeDelegatedValueTransferWithRatioTest.gas
    let nonce = FeeDelegatedValueTransferWithRatioTest.nonce
    let gasPrice = FeeDelegatedValueTransferWithRatioTest.gasPrice
    let chainID = FeeDelegatedValueTransferWithRatioTest.chainID
    let value = FeeDelegatedValueTransferWithRatioTest.value
    let input = FeeDelegatedValueTransferWithRatioTest.input
    let humanReadable = FeeDelegatedValueTransferWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedValueTransferWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedValueTransferWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedValueTransferWithRatioTest.expectedRLPEncoding
        
    public func test_getRLPEncoding() throws {
        let txObj = try FeeDelegatedValueTransferWithRatio.Builder()
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
            .build()
        
        XCTAssertEqual(expectedRLPEncoding, try txObj.getRLPEncoding())
    }
    
    public func test_throwException_NoNonce() throws {
        let txObj = try FeeDelegatedValueTransferWithRatio.Builder()
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
            .build()
        
        XCTAssertThrowsError(try txObj.getRLPEncoding()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NoGasPrice() throws {
        let txObj = try FeeDelegatedValueTransferWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
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

class FeeDelegatedValueTransferWithRatioTest_signAsFeePayer_OneKeyTest: XCTestCase {
    var mTxObj: FeeDelegatedValueTransferWithRatio?
    var klaytnWalletKey: String?
    var keyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedValueTransferWithRatioTest.feePayerPrivateKey
    
    let from = FeeDelegatedValueTransferWithRatioTest.from
    let account = FeeDelegatedValueTransferWithRatioTest.account
    let to = FeeDelegatedValueTransferWithRatioTest.to
    let gas = FeeDelegatedValueTransferWithRatioTest.gas
    let nonce = FeeDelegatedValueTransferWithRatioTest.nonce
    let gasPrice = FeeDelegatedValueTransferWithRatioTest.gasPrice
    let chainID = FeeDelegatedValueTransferWithRatioTest.chainID
    let value = FeeDelegatedValueTransferWithRatioTest.value
    let input = FeeDelegatedValueTransferWithRatioTest.input
    let humanReadable = FeeDelegatedValueTransferWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferWithRatioTest.senderSignatureData
    var feePayer = FeeDelegatedValueTransferWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedValueTransferWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedValueTransferWithRatioTest.expectedRLPEncoding
        
    override func setUpWithError() throws {
        keyring = try KeyringFactory.createWithSingleKey(feePayer, feePayerPrivateKey)
        
        mTxObj = try FeeDelegatedValueTransferWithRatio.Builder()
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
            .build()
        
        klaytnWalletKey = try keyring?.getKlaytnWalletKey()
    }
    
    public func test_signAsFeePayer_String() throws {
        let privateKey = PrivateKey.generate().privateKey
        let feePayer = try PrivateKey(privateKey).getDerivedAddress()
        
        mTxObj = try FeeDelegatedValueTransferWithRatio.Builder()
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

class FeeDelegatedValueTransferWithRatioTest_signAsFeePayer_AllKeyTest: XCTestCase {
    var mTxObj: FeeDelegatedValueTransferWithRatio?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedValueTransferWithRatioTest.feePayerPrivateKey
    
    let from = FeeDelegatedValueTransferWithRatioTest.from
    let account = FeeDelegatedValueTransferWithRatioTest.account
    let to = FeeDelegatedValueTransferWithRatioTest.to
    let gas = FeeDelegatedValueTransferWithRatioTest.gas
    let nonce = FeeDelegatedValueTransferWithRatioTest.nonce
    let gasPrice = FeeDelegatedValueTransferWithRatioTest.gasPrice
    let chainID = FeeDelegatedValueTransferWithRatioTest.chainID
    let value = FeeDelegatedValueTransferWithRatioTest.value
    let input = FeeDelegatedValueTransferWithRatioTest.input
    let humanReadable = FeeDelegatedValueTransferWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedValueTransferWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedValueTransferWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedValueTransferWithRatioTest.expectedRLPEncoding
        
    override func setUpWithError() throws {
        mTxObj = try FeeDelegatedValueTransferWithRatio.Builder()
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

class FeeDelegatedValueTransferWithRatioTest_appendFeePayerSignaturesTest: XCTestCase {
    var mTxObj: FeeDelegatedValueTransferWithRatio?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedValueTransferWithRatioTest.feePayerPrivateKey
    
    let from = FeeDelegatedValueTransferWithRatioTest.from
    let account = FeeDelegatedValueTransferWithRatioTest.account
    let to = FeeDelegatedValueTransferWithRatioTest.to
    let gas = FeeDelegatedValueTransferWithRatioTest.gas
    let nonce = FeeDelegatedValueTransferWithRatioTest.nonce
    let gasPrice = FeeDelegatedValueTransferWithRatioTest.gasPrice
    let chainID = FeeDelegatedValueTransferWithRatioTest.chainID
    let value = FeeDelegatedValueTransferWithRatioTest.value
    let input = FeeDelegatedValueTransferWithRatioTest.input
    let humanReadable = FeeDelegatedValueTransferWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedValueTransferWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedValueTransferWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedValueTransferWithRatioTest.expectedRLPEncoding
    
    override func setUpWithError() throws {
        mTxObj = try FeeDelegatedValueTransferWithRatio.Builder()
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
        mTxObj = try FeeDelegatedValueTransferWithRatio.Builder()
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
        
        mTxObj = try FeeDelegatedValueTransferWithRatio.Builder()
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
        
        mTxObj = try FeeDelegatedValueTransferWithRatio.Builder()
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

class FeeDelegatedValueTransferWithRatioTest_combineSignatureTest: XCTestCase {
    var mTxObj: FeeDelegatedValueTransferWithRatio?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedValueTransferWithRatioTest.feePayerPrivateKey
    
    let from = "0x31e7c5218f810af8ad1e50bf207de0cfb5bd4526"
    let account = FeeDelegatedValueTransferWithRatioTest.account
    let to = "0x7b65b75d204abed71587c9e519a89277766ee1d0"
    let gas = "0xf4240"
    let nonce = "0x1"
    let gasPrice = "0x5d21dba00"
    let chainID = "0x7e3"
    let value = "0xa"
    let input = FeeDelegatedValueTransferWithRatioTest.input
    let humanReadable = FeeDelegatedValueTransferWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedValueTransferWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedValueTransferWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedValueTransferWithRatioTest.expectedRLPEncoding
    
    override func setUpWithError() throws {
        mTxObj = try FeeDelegatedValueTransferWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setFeeRatio(feeRatio)
            .build()
    }
    
    public func test_combineSignature() throws {
        let expectedRLPEncoded = "0x0af89a018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a9431e7c5218f810af8ad1e50bf207de0cfb5bd45261ef847f845820feaa0a832e241979ee7a3e08b49d7a7e8f8029982ee5502c7f970a8fe2676fe1b1084a044ded5739de93803b37790bb323f5020de50850b7b7cdc9a6a2e23a29a8cc145940000000000000000000000000000000000000000c4c3018080"
        
        let expectedSignature = SignatureData(
            "0x0fea",
            "0xa832e241979ee7a3e08b49d7a7e8f8029982ee5502c7f970a8fe2676fe1b1084",
            "0x44ded5739de93803b37790bb323f5020de50850b7b7cdc9a6a2e23a29a8cc145"
        )
        
        let rlpEncoded = "0x0af89a018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a9431e7c5218f810af8ad1e50bf207de0cfb5bd45261ef847f845820feaa0a832e241979ee7a3e08b49d7a7e8f8029982ee5502c7f970a8fe2676fe1b1084a044ded5739de93803b37790bb323f5020de50850b7b7cdc9a6a2e23a29a8cc145940000000000000000000000000000000000000000c4c3018080"
        
        let combined = try mTxObj!.combineSignedRawTransactions([rlpEncoded])
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature, mTxObj?.signatures[0])
    }
    
    public func test_combine_multipleSignature() throws {
        let expectedRLPEncoded = "0x0af90128018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a9431e7c5218f810af8ad1e50bf207de0cfb5bd45261ef8d5f845820feaa0a832e241979ee7a3e08b49d7a7e8f8029982ee5502c7f970a8fe2676fe1b1084a044ded5739de93803b37790bb323f5020de50850b7b7cdc9a6a2e23a29a8cc145f845820feaa0df06077618ef021174af72c807ac968ab6b8549ca997432df73a1fe3612ed226a052684b175ec8fb45506e6f809ec0c879afa62e5cc1e64bd91e16a58a6aa09667f845820feaa02944c25a5dc2fe12d365743413ee4f4c133c3f0c142629cadff486679408b86ea05d633f11b2dde9cf51bc596565ca18a7f0f92b9d3447ce4f622188563299217e940000000000000000000000000000000000000000c4c3018080"
        
        let expectedSignature = [
            SignatureData(
                    "0x0fea",
                    "0xa832e241979ee7a3e08b49d7a7e8f8029982ee5502c7f970a8fe2676fe1b1084",
                    "0x44ded5739de93803b37790bb323f5020de50850b7b7cdc9a6a2e23a29a8cc145"
            ),
            SignatureData(
                    "0x0fea",
                    "0xdf06077618ef021174af72c807ac968ab6b8549ca997432df73a1fe3612ed226",
                    "0x52684b175ec8fb45506e6f809ec0c879afa62e5cc1e64bd91e16a58a6aa09667"
            ),
            SignatureData(
                    "0x0fea",
                    "0x2944c25a5dc2fe12d365743413ee4f4c133c3f0c142629cadff486679408b86e",
                    "0x5d633f11b2dde9cf51bc596565ca18a7f0f92b9d3447ce4f622188563299217e"
            )
        ]
        
        let rlpEncodedString = [
            "0x0af886018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a9431e7c5218f810af8ad1e50bf207de0cfb5bd45261ef847f845820feaa0df06077618ef021174af72c807ac968ab6b8549ca997432df73a1fe3612ed226a052684b175ec8fb45506e6f809ec0c879afa62e5cc1e64bd91e16a58a6aa0966780c4c3018080",
            "0x0af886018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a9431e7c5218f810af8ad1e50bf207de0cfb5bd45261ef847f845820feaa02944c25a5dc2fe12d365743413ee4f4c133c3f0c142629cadff486679408b86ea05d633f11b2dde9cf51bc596565ca18a7f0f92b9d3447ce4f622188563299217e80c4c3018080"
        ]
        
        let senderSignatureData = SignatureData(
            "0x0fea",
            "0xa832e241979ee7a3e08b49d7a7e8f8029982ee5502c7f970a8fe2676fe1b1084",
            "0x44ded5739de93803b37790bb323f5020de50850b7b7cdc9a6a2e23a29a8cc145"
        )
        
        mTxObj = try FeeDelegatedValueTransferWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
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
        let expectedRLPEncoded = "0x0af89a018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a9431e7c5218f810af8ad1e50bf207de0cfb5bd45261ec4c30180809412dbe69692cb021bc1f161dd5abc0507bd1493cef847f845820fe9a00c438aba938ee678761ccde71696518d40ed0669c420aaedf66952af0f4eafaaa029354a82fe53b4971b745acd837e0182b7df7e03c6e77821e508669b6a0a6390"
        
        let expectedSignature = SignatureData(
            "0x0fe9",
            "0x0c438aba938ee678761ccde71696518d40ed0669c420aaedf66952af0f4eafaa",
            "0x29354a82fe53b4971b745acd837e0182b7df7e03c6e77821e508669b6a0a6390"
        )
        
        let rlpEncoded = "0x0af89a018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a9431e7c5218f810af8ad1e50bf207de0cfb5bd45261ec4c30180809412dbe69692cb021bc1f161dd5abc0507bd1493cef847f845820fe9a00c438aba938ee678761ccde71696518d40ed0669c420aaedf66952af0f4eafaaa029354a82fe53b4971b745acd837e0182b7df7e03c6e77821e508669b6a0a6390"
                
        mTxObj = try FeeDelegatedValueTransferWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setFeeRatio(feeRatio)
            .build()
        
        let combined = try mTxObj!.combineSignedRawTransactions([rlpEncoded])
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature, mTxObj?.feePayerSignatures[0])
    }
    
    public func test_combineSignature_multipleFeePayerSignature() throws {
        let expectedRLPEncoded = "0x0af90128018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a9431e7c5218f810af8ad1e50bf207de0cfb5bd45261ec4c30180809412dbe69692cb021bc1f161dd5abc0507bd1493cef8d5f845820fe9a00c438aba938ee678761ccde71696518d40ed0669c420aaedf66952af0f4eafaaa029354a82fe53b4971b745acd837e0182b7df7e03c6e77821e508669b6a0a6390f845820feaa015a95b922f43aad929329b13a42c3b00760eb0cabebd19cc0c7935db7d46da9ca02e4d9aa62bc12e40405d8209abbd40b65ba90eb6ff63b4e9260180c3a17525e0f845820fe9a0b6a124f371122cb3ac5c98c1d0a94ce41d87387b05fce8cfc244c152ab580ffda0121e3c11516f67cda27ade771a7166b93cdbd2beeba39302bd240ee1d9432060"
        
        let expectedSignature = [
            SignatureData(
                    "0x0fe9",
                    "0x0c438aba938ee678761ccde71696518d40ed0669c420aaedf66952af0f4eafaa",
                    "0x29354a82fe53b4971b745acd837e0182b7df7e03c6e77821e508669b6a0a6390"
            ),
            SignatureData(
                    "0x0fea",
                    "0x15a95b922f43aad929329b13a42c3b00760eb0cabebd19cc0c7935db7d46da9c",
                    "0x2e4d9aa62bc12e40405d8209abbd40b65ba90eb6ff63b4e9260180c3a17525e0"
            ),
            SignatureData(
                    "0x0fe9",
                    "0xb6a124f371122cb3ac5c98c1d0a94ce41d87387b05fce8cfc244c152ab580ffd",
                    "0x121e3c11516f67cda27ade771a7166b93cdbd2beeba39302bd240ee1d9432060"
            )
        ]
        
        let rlpEncodedString = [
            "0x0af89a018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a9431e7c5218f810af8ad1e50bf207de0cfb5bd45261ec4c30180809412dbe69692cb021bc1f161dd5abc0507bd1493cef847f845820feaa015a95b922f43aad929329b13a42c3b00760eb0cabebd19cc0c7935db7d46da9ca02e4d9aa62bc12e40405d8209abbd40b65ba90eb6ff63b4e9260180c3a17525e0",
            "0x0af89a018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a9431e7c5218f810af8ad1e50bf207de0cfb5bd45261ec4c30180809412dbe69692cb021bc1f161dd5abc0507bd1493cef847f845820fe9a0b6a124f371122cb3ac5c98c1d0a94ce41d87387b05fce8cfc244c152ab580ffda0121e3c11516f67cda27ade771a7166b93cdbd2beeba39302bd240ee1d9432060"
        ]
        
        let feePayer = "0x12dbe69692cb021bc1f161dd5abc0507bd1493ce"
        let feePayerSignatureData = SignatureData(
            "0x0fe9",
            "0x0c438aba938ee678761ccde71696518d40ed0669c420aaedf66952af0f4eafaa",
            "0x29354a82fe53b4971b745acd837e0182b7df7e03c6e77821e508669b6a0a6390"
        )
        
        mTxObj = try FeeDelegatedValueTransferWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
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
        mTxObj = try FeeDelegatedValueTransferWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setFeeRatio(feeRatio)
            .build()
        
        let rlpEncodedString = "0x0af90114018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a9431e7c5218f810af8ad1e50bf207de0cfb5bd45261ef8d5f845820feaa0a832e241979ee7a3e08b49d7a7e8f8029982ee5502c7f970a8fe2676fe1b1084a044ded5739de93803b37790bb323f5020de50850b7b7cdc9a6a2e23a29a8cc145f845820feaa0df06077618ef021174af72c807ac968ab6b8549ca997432df73a1fe3612ed226a052684b175ec8fb45506e6f809ec0c879afa62e5cc1e64bd91e16a58a6aa09667f845820feaa02944c25a5dc2fe12d365743413ee4f4c133c3f0c142629cadff486679408b86ea05d633f11b2dde9cf51bc596565ca18a7f0f92b9d3447ce4f622188563299217e80c4c3018080"
        
        let expectedSignature = [
            SignatureData(
                    "0x0fea",
                    "0xa832e241979ee7a3e08b49d7a7e8f8029982ee5502c7f970a8fe2676fe1b1084",
                    "0x44ded5739de93803b37790bb323f5020de50850b7b7cdc9a6a2e23a29a8cc145"
            ),
            SignatureData(
                    "0x0fea",
                    "0xdf06077618ef021174af72c807ac968ab6b8549ca997432df73a1fe3612ed226",
                    "0x52684b175ec8fb45506e6f809ec0c879afa62e5cc1e64bd91e16a58a6aa09667"
            ),
            SignatureData(
                    "0x0fea",
                    "0x2944c25a5dc2fe12d365743413ee4f4c133c3f0c142629cadff486679408b86e",
                    "0x5d633f11b2dde9cf51bc596565ca18a7f0f92b9d3447ce4f622188563299217e"
            )
        ]
        
        _ = try mTxObj!.combineSignedRawTransactions([rlpEncodedString])
        
        let rlpEncodedStringsWithFeePayerSignatures = "0x0af90128018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a9431e7c5218f810af8ad1e50bf207de0cfb5bd45261ec4c30180809412dbe69692cb021bc1f161dd5abc0507bd1493cef8d5f845820fe9a00c438aba938ee678761ccde71696518d40ed0669c420aaedf66952af0f4eafaaa029354a82fe53b4971b745acd837e0182b7df7e03c6e77821e508669b6a0a6390f845820feaa015a95b922f43aad929329b13a42c3b00760eb0cabebd19cc0c7935db7d46da9ca02e4d9aa62bc12e40405d8209abbd40b65ba90eb6ff63b4e9260180c3a17525e0f845820fe9a0b6a124f371122cb3ac5c98c1d0a94ce41d87387b05fce8cfc244c152ab580ffda0121e3c11516f67cda27ade771a7166b93cdbd2beeba39302bd240ee1d9432060"
        
        let expectedFeePayerSignatures = [
            SignatureData(
                    "0x0fe9",
                    "0x0c438aba938ee678761ccde71696518d40ed0669c420aaedf66952af0f4eafaa",
                    "0x29354a82fe53b4971b745acd837e0182b7df7e03c6e77821e508669b6a0a6390"
            ),
            SignatureData(
                    "0x0fea",
                    "0x15a95b922f43aad929329b13a42c3b00760eb0cabebd19cc0c7935db7d46da9c",
                    "0x2e4d9aa62bc12e40405d8209abbd40b65ba90eb6ff63b4e9260180c3a17525e0"
            ),
            SignatureData(
                    "0x0fe9",
                    "0xb6a124f371122cb3ac5c98c1d0a94ce41d87387b05fce8cfc244c152ab580ffd",
                    "0x121e3c11516f67cda27ade771a7166b93cdbd2beeba39302bd240ee1d9432060"
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
        mTxObj = try FeeDelegatedValueTransferWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setFeeRatio(feeRatio)
            .build()
        
        let rlpEncoded = "0x0af886018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a9431e7c5218f810af8ad1e50bf207de0cfb5bd45261ef847f845820feaa0a832e241979ee7a3e08b49d7a7e8f8029982ee5502c7f970a8fe2676fe1b1084a044ded5739de93803b37790bb323f5020de50850b7b7cdc9a6a2e23a29a8cc14580c4c3018080"
        
        XCTAssertThrowsError(try mTxObj!.combineSignedRawTransactions([rlpEncoded])) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("Transactions containing different information cannot be combined."))
        }
    }
}

class FeeDelegatedValueTransferWithRatioTest_getRawTransactionTest: XCTestCase {
    var mTxObj: FeeDelegatedValueTransferWithRatio?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedValueTransferWithRatioTest.feePayerPrivateKey
    
    let from = FeeDelegatedValueTransferWithRatioTest.from
    let account = FeeDelegatedValueTransferWithRatioTest.account
    let to = FeeDelegatedValueTransferWithRatioTest.to
    let gas = FeeDelegatedValueTransferWithRatioTest.gas
    let nonce = FeeDelegatedValueTransferWithRatioTest.nonce
    let gasPrice = FeeDelegatedValueTransferWithRatioTest.gasPrice
    let chainID = FeeDelegatedValueTransferWithRatioTest.chainID
    let value = FeeDelegatedValueTransferWithRatioTest.value
    let input = FeeDelegatedValueTransferWithRatioTest.input
    let humanReadable = FeeDelegatedValueTransferWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedValueTransferWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedValueTransferWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedValueTransferWithRatioTest.expectedRLPEncoding
    
    public func test_getRawTransaction() throws {
        let txObj = try FeeDelegatedValueTransferWithRatio.Builder()
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
            .build()

        XCTAssertEqual(expectedRLPEncoding, try txObj.getRawTransaction())
    }
}

class FeeDelegatedValueTransferWithRatioTest_getTransactionHashTest: XCTestCase {
    var mTxObj: FeeDelegatedValueTransferWithRatio?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedValueTransferWithRatioTest.feePayerPrivateKey
    
    let from = FeeDelegatedValueTransferWithRatioTest.from
    let account = FeeDelegatedValueTransferWithRatioTest.account
    let to = FeeDelegatedValueTransferWithRatioTest.to
    let gas = FeeDelegatedValueTransferWithRatioTest.gas
    let nonce = FeeDelegatedValueTransferWithRatioTest.nonce
    let gasPrice = FeeDelegatedValueTransferWithRatioTest.gasPrice
    let chainID = FeeDelegatedValueTransferWithRatioTest.chainID
    let value = FeeDelegatedValueTransferWithRatioTest.value
    let input = FeeDelegatedValueTransferWithRatioTest.input
    let humanReadable = FeeDelegatedValueTransferWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedValueTransferWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedValueTransferWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedValueTransferWithRatioTest.expectedRLPEncoding
    let expectedTransactionHash = FeeDelegatedValueTransferWithRatioTest.expectedTransactionHash
            
    public func test_getTransactionHash() throws {
        let txObj = try FeeDelegatedValueTransferWithRatio.Builder()
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
            .build()

        XCTAssertEqual(expectedTransactionHash, try txObj.getTransactionHash())
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try FeeDelegatedValueTransferWithRatio.Builder()
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
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getTransactionHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_gasPrice() throws {
        let gasPrice = ""
        
        mTxObj = try FeeDelegatedValueTransferWithRatio.Builder()
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
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getTransactionHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class FeeDelegatedValueTransferWithRatioTest_getSenderTxHashTest: XCTestCase {
    var mTxObj: FeeDelegatedValueTransferWithRatio?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedValueTransferWithRatioTest.feePayerPrivateKey
    
    let from = FeeDelegatedValueTransferWithRatioTest.from
    let account = FeeDelegatedValueTransferWithRatioTest.account
    let to = FeeDelegatedValueTransferWithRatioTest.to
    let gas = FeeDelegatedValueTransferWithRatioTest.gas
    let nonce = FeeDelegatedValueTransferWithRatioTest.nonce
    let gasPrice = FeeDelegatedValueTransferWithRatioTest.gasPrice
    let chainID = FeeDelegatedValueTransferWithRatioTest.chainID
    let value = FeeDelegatedValueTransferWithRatioTest.value
    let input = FeeDelegatedValueTransferWithRatioTest.input
    let humanReadable = FeeDelegatedValueTransferWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedValueTransferWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedValueTransferWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedValueTransferWithRatioTest.expectedRLPEncoding
    let expectedTransactionHash = FeeDelegatedValueTransferWithRatioTest.expectedTransactionHash
    let expectedSenderTransactionHash = FeeDelegatedValueTransferWithRatioTest.expectedRLPSenderTransactionHash
            
    public func test_getRLPEncodingForSignature() throws {
        mTxObj = try FeeDelegatedValueTransferWithRatio.Builder()
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
            .build()
        
        XCTAssertEqual(expectedSenderTransactionHash, try mTxObj!.getSenderTxHash())
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try FeeDelegatedValueTransferWithRatio.Builder()
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
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getSenderTxHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_gasPrice() throws {
        let gasPrice = ""
        
        mTxObj = try FeeDelegatedValueTransferWithRatio.Builder()
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
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getSenderTxHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class FeeDelegatedValueTransferWithRatioTest_getRLPEncodingForFeePayerSignatureTest: XCTestCase {
    var mTxObj: FeeDelegatedValueTransferWithRatio?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedValueTransferWithRatioTest.feePayerPrivateKey
    
    let from = FeeDelegatedValueTransferWithRatioTest.from
    let account = FeeDelegatedValueTransferWithRatioTest.account
    let to = FeeDelegatedValueTransferWithRatioTest.to
    let gas = FeeDelegatedValueTransferWithRatioTest.gas
    let nonce = FeeDelegatedValueTransferWithRatioTest.nonce
    let gasPrice = FeeDelegatedValueTransferWithRatioTest.gasPrice
    let chainID = FeeDelegatedValueTransferWithRatioTest.chainID
    let value = FeeDelegatedValueTransferWithRatioTest.value
    let input = FeeDelegatedValueTransferWithRatioTest.input
    let humanReadable = FeeDelegatedValueTransferWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedValueTransferWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedValueTransferWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedValueTransferWithRatioTest.expectedRLPEncoding
    let expectedTransactionHash = FeeDelegatedValueTransferWithRatioTest.expectedTransactionHash
    let expectedSenderTransactionHash = FeeDelegatedValueTransferWithRatioTest.expectedRLPSenderTransactionHash
    let expectedRLPEncodingForFeePayerSigning = FeeDelegatedValueTransferWithRatioTest.expectedRLPEncodingForFeePayerSigning
            
    public func test_getRLPEncodingForSignature() throws {
        mTxObj = try FeeDelegatedValueTransferWithRatio.Builder()
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
            .build()
        
        XCTAssertEqual(expectedRLPEncodingForFeePayerSigning, try mTxObj!.getRLPEncodingForFeePayerSignature())
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try FeeDelegatedValueTransferWithRatio.Builder()
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
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_gasPrice() throws {
        let gasPrice = ""
        
        mTxObj = try FeeDelegatedValueTransferWithRatio.Builder()
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
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_chainID() throws {
        let chainID = ""
        
        mTxObj = try FeeDelegatedValueTransferWithRatio.Builder()
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
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("chainId is undefined. Define chainId in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}
