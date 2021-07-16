//
//  FeeDelegatedChainDataAnchoringWithRatioTest.swift
//  CaverSwiftTests
//
//  Created by won on 2021/07/16.
//

import XCTest
@testable import CaverSwift

class FeeDelegatedChainDataAnchoringWithRatioTest: XCTestCase {
    static let caver = Caver(Caver.DEFAULT_URL)
    
    static let privateKey = "0x45a915e4d060149eb4365960e6a7a45f334393093061116b197e3240065ff2d8"
    static let feePayerPrivateKey = "0xb9d5558443585bca6f225b935950e3f6e69f9da8a5809a83f51c3365dff53936"
    static let from = "0xa94f5374Fce5edBC8E2a8697C15331677e6EbF0B"
    static let account = Account.createWithAccountKeyLegacy(from)
    static let to = "0x7b65b75d204abed71587c9e519a89277766ee1d0"
    static let gas = "0x174876e800"
    static let gasPrice = "0x5d21dba00"
    static let nonce = "0x12"
    static let chainID = "0x1"
    static let value = "0xa"
    static let input = "0xf8ad80b8aaf8a8a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a00000000000000000000000000000000000000000000000000000000000000004058006"
    static let humanReadable = false
    static let codeFormat = CodeFormat.EVM.hexa
    static let feeRatio = "0x58"

    static let senderSignatureData = SignatureData(
        "0x26",
        "0xc612a243bcb3b98958e9cce1a0bc0e170291b33a7f0dbfae4b36dafb5806797d",
        "0xc734423492ecc21cc53238147c359676fcec43fcc2a0e021d87bb1da49f0abf"
    )
    static let feePayer = "0x33f524631e573329a550296F595c820D6c65213f"
    static let feePayerSignatureData = SignatureData(
        "0x25",
        "0xa3e40598b67e2bcbaa48fdd258b9d1dcfcc9cc134972560ba042430078a769a5",
        "0x6707ea362e588e4e5869cffcd5a058749d823aeff13eb95dc1146faff561df32"
    )

    static let expectedRLPEncoding = "0x4af90177128505d21dba0085174876e80094a94f5374fce5edbc8e2a8697c15331677e6ebf0bb8aff8ad80b8aaf8a8a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a0000000000000000000000000000000000000000000000000000000000000000405800658f845f84326a0c612a243bcb3b98958e9cce1a0bc0e170291b33a7f0dbfae4b36dafb5806797da00c734423492ecc21cc53238147c359676fcec43fcc2a0e021d87bb1da49f0abf9433f524631e573329a550296f595c820d6c65213ff845f84325a0a3e40598b67e2bcbaa48fdd258b9d1dcfcc9cc134972560ba042430078a769a5a06707ea362e588e4e5869cffcd5a058749d823aeff13eb95dc1146faff561df32"
    static let expectedTransactionHash = "0xc01a7c3ece18c115b58d7747669ec7c31ec5ab031a88cb49ad85a31f6dbbf915"
    static let expectedRLPSenderTransactionHash = "0xa0670c01fe39feb2d2442adf7df1957ade3c5abcde778fb5edf99c80c06aa53c"
    static let expectedRLPEncodingForFeePayerSigning = "0xf8f1b8d7f8d54a128505d21dba0085174876e80094a94f5374fce5edbc8e2a8697c15331677e6ebf0bb8aff8ad80b8aaf8a8a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a00000000000000000000000000000000000000000000000000000000000000004058006589433f524631e573329a550296f595c820d6c65213f018080"
        
    public static func generateRoleBaseKeyring(_ numArr: [Int], _ address: String) throws -> AbstractKeyring {
        let keyArr = KeyringFactory.generateRoleBasedKeys(numArr, "entropy")
        return try KeyringFactory.createWithRoleBasedKey(address, keyArr)
    }
}

class FeeDelegatedChainDataAnchoringWithRatioTest_createInstanceBuilder: XCTestCase {
    let from = FeeDelegatedChainDataAnchoringWithRatioTest.from
    let account = FeeDelegatedChainDataAnchoringWithRatioTest.account
    let to = FeeDelegatedChainDataAnchoringWithRatioTest.to
    let gas = FeeDelegatedChainDataAnchoringWithRatioTest.gas
    let nonce = FeeDelegatedChainDataAnchoringWithRatioTest.nonce
    let gasPrice = FeeDelegatedChainDataAnchoringWithRatioTest.gasPrice
    let chainID = FeeDelegatedChainDataAnchoringWithRatioTest.chainID
    let value = FeeDelegatedChainDataAnchoringWithRatioTest.value
    let input = FeeDelegatedChainDataAnchoringWithRatioTest.input
    let humanReadable = FeeDelegatedChainDataAnchoringWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedChainDataAnchoringWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedChainDataAnchoringWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedChainDataAnchoringWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedChainDataAnchoringWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedChainDataAnchoringWithRatioTest.feeRatio
        
    public func test_BuilderTest() throws {
        let txObj = try FeeDelegatedChainDataAnchoringWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
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
        let txObj = try FeeDelegatedChainDataAnchoringWithRatio.Builder()
            .setKlaytnCall(FeeDelegatedChainDataAnchoringWithRatioTest.caver.rpc.klay)
            .setGas(gas)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setInput(input)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        try txObj.fillTransaction()
        
        XCTAssertFalse(txObj.nonce.isEmpty)
        XCTAssertFalse(txObj.gasPrice.isEmpty)
        XCTAssertFalse(txObj.chainId.isEmpty)
    }
    
    public func test_BuilderTestWithBigInteger() throws {
        let txObj = try FeeDelegatedChainDataAnchoringWithRatio.Builder()
            .setNonce(BigInt(hex: nonce)!)
            .setGas(BigInt(hex: gas)!)
            .setGasPrice(BigInt(hex: gasPrice)!)
            .setChainId(BigInt(hex: chainID)!)
            .setFrom(from)
            .setInput(input)
            .setSignatures(senderSignatureData)
            .setFeeRatio(BigInt(hex: feeRatio)!)
            .setFeePayer(feePayer)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertNotNil(txObj)
        
        XCTAssertEqual(gas, txObj.gas)
        XCTAssertEqual(gasPrice, txObj.gasPrice)
        XCTAssertEqual(chainID, txObj.chainId)
    }
    
    public func test_throwException_invalidFrom() throws {
        let from = "invalid Address"
        XCTAssertThrowsError(try FeeDelegatedChainDataAnchoringWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
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
        XCTAssertThrowsError(try FeeDelegatedChainDataAnchoringWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
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
        
    public func test_throwException_invalidGas() throws {
        let gas = "invalid gas"
        XCTAssertThrowsError(try FeeDelegatedChainDataAnchoringWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
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
        XCTAssertThrowsError(try FeeDelegatedChainDataAnchoringWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
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
        XCTAssertThrowsError(try FeeDelegatedChainDataAnchoringWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
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
        XCTAssertThrowsError(try FeeDelegatedChainDataAnchoringWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
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
        XCTAssertThrowsError(try FeeDelegatedChainDataAnchoringWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
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
        XCTAssertThrowsError(try FeeDelegatedChainDataAnchoringWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
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
        XCTAssertThrowsError(try FeeDelegatedChainDataAnchoringWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
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
        XCTAssertThrowsError(try FeeDelegatedChainDataAnchoringWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
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

class FeeDelegatedChainDataAnchoringWithRatioTest_createInstance: XCTestCase {
    let from = FeeDelegatedChainDataAnchoringWithRatioTest.from
    let account = FeeDelegatedChainDataAnchoringWithRatioTest.account
    let to = FeeDelegatedChainDataAnchoringWithRatioTest.to
    let gas = FeeDelegatedChainDataAnchoringWithRatioTest.gas
    let nonce = FeeDelegatedChainDataAnchoringWithRatioTest.nonce
    let gasPrice = FeeDelegatedChainDataAnchoringWithRatioTest.gasPrice
    let chainID = FeeDelegatedChainDataAnchoringWithRatioTest.chainID
    let value = FeeDelegatedChainDataAnchoringWithRatioTest.value
    let input = FeeDelegatedChainDataAnchoringWithRatioTest.input
    let humanReadable = FeeDelegatedChainDataAnchoringWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedChainDataAnchoringWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedChainDataAnchoringWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedChainDataAnchoringWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedChainDataAnchoringWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedChainDataAnchoringWithRatioTest.feeRatio
    
    public func test_createInstance() throws {
        let txObj = try FeeDelegatedChainDataAnchoringWithRatio(
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
            input
        )
        
        XCTAssertNotNil(txObj)
    }
    
    public func test_throwException_invalidFrom() throws {
        let from = "invalid Address"
        XCTAssertThrowsError(try FeeDelegatedChainDataAnchoringWithRatio(
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
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(from)"))
        }
    }
    
    public func test_throwException_missingFrom() throws {
        let from = ""
        XCTAssertThrowsError(try FeeDelegatedChainDataAnchoringWithRatio(
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
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("from is missing."))
        }
    }
    
    public func test_throwException_invalidGas() throws {
        let gas = "invalid gas"
        XCTAssertThrowsError(try FeeDelegatedChainDataAnchoringWithRatio(
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
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid gas. : \(gas)"))
        }
    }
    
    public func test_throwException_missingGas() throws {
        let gas = ""
        XCTAssertThrowsError(try FeeDelegatedChainDataAnchoringWithRatio(
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
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("gas is missing."))
        }
    }
    
    public func test_throwException_invalidInput() throws {
        let input = "invalid input"
        XCTAssertThrowsError(try FeeDelegatedChainDataAnchoringWithRatio(
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
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid input. : \(input)"))
        }
    }
    
    public func test_throwException_missingInput() throws {
        let input = ""
        XCTAssertThrowsError(try FeeDelegatedChainDataAnchoringWithRatio(
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
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("input is missing."))
        }
    }
    
    public func test_throwException_setFeePayerSignatures_missingFeePayer() throws {
        let feePayer = ""
        XCTAssertThrowsError(try FeeDelegatedChainDataAnchoringWithRatio(
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
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("feePayer is missing: feePayer must be defined with feePayerSignatures."))
        }
    }
    
    public func test_throwException_FeeRatio_invalid() throws {
        let feeRatio = "invalid fee ratio"
        XCTAssertThrowsError(try FeeDelegatedChainDataAnchoringWithRatio(
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
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid type of feeRatio: feeRatio should be number type or hex number string"))
        }
    }
    
    public func test_throwException_FeeRatio_outOfRange() throws {
        let feeRatio = BigInt(101).hexa
        XCTAssertThrowsError(try FeeDelegatedChainDataAnchoringWithRatio(
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
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid feeRatio: feeRatio is out of range. [1,99]"))
        }
    }
    
    public func test_throwException_missingFeeRatio() throws {
        let feeRatio = ""
        XCTAssertThrowsError(try FeeDelegatedChainDataAnchoringWithRatio(
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
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("feeRatio is missing."))
        }
    }
}

class FeeDelegatedChainDataAnchoringWithRatioTest_getRLPEncodingTest: XCTestCase {
    let from = FeeDelegatedChainDataAnchoringWithRatioTest.from
    let account = FeeDelegatedChainDataAnchoringWithRatioTest.account
    let to = FeeDelegatedChainDataAnchoringWithRatioTest.to
    let gas = FeeDelegatedChainDataAnchoringWithRatioTest.gas
    let nonce = FeeDelegatedChainDataAnchoringWithRatioTest.nonce
    let gasPrice = FeeDelegatedChainDataAnchoringWithRatioTest.gasPrice
    let chainID = FeeDelegatedChainDataAnchoringWithRatioTest.chainID
    let value = FeeDelegatedChainDataAnchoringWithRatioTest.value
    let input = FeeDelegatedChainDataAnchoringWithRatioTest.input
    let humanReadable = FeeDelegatedChainDataAnchoringWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedChainDataAnchoringWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedChainDataAnchoringWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedChainDataAnchoringWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedChainDataAnchoringWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedChainDataAnchoringWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedChainDataAnchoringWithRatioTest.expectedRLPEncoding
        
    public func test_getRLPEncoding() throws {
        let txObj = try FeeDelegatedChainDataAnchoringWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
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
        let txObj = try FeeDelegatedChainDataAnchoringWithRatio.Builder()
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
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
        let txObj = try FeeDelegatedChainDataAnchoringWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setChainId(chainID)
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

class FeeDelegatedChainDataAnchoringWithRatioTest_signAsFeePayer_OneKeyTest: XCTestCase {
    var mTxObj: FeeDelegatedChainDataAnchoringWithRatio?
    var klaytnWalletKey: String?
    var keyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedChainDataAnchoringWithRatioTest.feePayerPrivateKey
    
    let from = FeeDelegatedChainDataAnchoringWithRatioTest.from
    let account = FeeDelegatedChainDataAnchoringWithRatioTest.account
    let to = FeeDelegatedChainDataAnchoringWithRatioTest.to
    let gas = FeeDelegatedChainDataAnchoringWithRatioTest.gas
    let nonce = FeeDelegatedChainDataAnchoringWithRatioTest.nonce
    let gasPrice = FeeDelegatedChainDataAnchoringWithRatioTest.gasPrice
    let chainID = FeeDelegatedChainDataAnchoringWithRatioTest.chainID
    let value = FeeDelegatedChainDataAnchoringWithRatioTest.value
    let input = FeeDelegatedChainDataAnchoringWithRatioTest.input
    let humanReadable = FeeDelegatedChainDataAnchoringWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedChainDataAnchoringWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedChainDataAnchoringWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedChainDataAnchoringWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedChainDataAnchoringWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedChainDataAnchoringWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedChainDataAnchoringWithRatioTest.expectedRLPEncoding
        
    override func setUpWithError() throws {
        mTxObj = try FeeDelegatedChainDataAnchoringWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setInput(input)
            .setSignatures(senderSignatureData)
            .build()
        
        keyring = try KeyringFactory.createWithSingleKey(feePayer, feePayerPrivateKey)
        klaytnWalletKey = try keyring?.getKlaytnWalletKey()
    }
    
    public func test_signAsFeePayer_String() throws {
        let feePayer = try PrivateKey(privateKey).getDerivedAddress()
        mTxObj = try FeeDelegatedChainDataAnchoringWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setInput(input)
            .setSignatures(senderSignatureData)
            .build()
        
        _ = try mTxObj!.signAsFeePayer(privateKey)
        XCTAssertEqual(1, mTxObj?.feePayerSignatures.count)
    }
    
    public func test_signAsFeePayer_KlaytnWalletKey() throws {
        _ = try mTxObj!.signAsFeePayer(klaytnWalletKey!)
        XCTAssertEqual(1, mTxObj?.feePayerSignatures.count)
        XCTAssertEqual(expectedRLPEncoding, try mTxObj?.getRawTransaction())
    }
    
    public func test_signAsFeePayer_Keyring() throws {
        _ = try mTxObj!.signAsFeePayer(keyring!, 0, TransactionHasher.getHashForFeePayerSignature(_:))
        XCTAssertEqual(1, mTxObj?.feePayerSignatures.count)
        XCTAssertEqual(expectedRLPEncoding, try mTxObj?.getRawTransaction())
    }
    
    public func test_signAsFeePayer_Keyring_NoSigner() throws {
        _ = try mTxObj!.signAsFeePayer(keyring!, 0)
        XCTAssertEqual(1, mTxObj?.feePayerSignatures.count)
        XCTAssertEqual(expectedRLPEncoding, try mTxObj?.getRawTransaction())
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
        XCTAssertEqual(expectedRLPEncoding, try mTxObj?.getRawTransaction())
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
        XCTAssertEqual(expectedRLPEncoding, try mTxObj?.getRawTransaction())
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

class FeeDelegatedChainDataAnchoringWithRatioTest_signAsFeePayer_AllKeyTest: XCTestCase {
    var mTxObj: FeeDelegatedChainDataAnchoringWithRatio?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedChainDataAnchoringWithRatioTest.feePayerPrivateKey
    
    let from = FeeDelegatedChainDataAnchoringWithRatioTest.from
    let account = FeeDelegatedChainDataAnchoringWithRatioTest.account
    let to = FeeDelegatedChainDataAnchoringWithRatioTest.to
    let gas = FeeDelegatedChainDataAnchoringWithRatioTest.gas
    let nonce = FeeDelegatedChainDataAnchoringWithRatioTest.nonce
    let gasPrice = FeeDelegatedChainDataAnchoringWithRatioTest.gasPrice
    let chainID = FeeDelegatedChainDataAnchoringWithRatioTest.chainID
    let value = FeeDelegatedChainDataAnchoringWithRatioTest.value
    let input = FeeDelegatedChainDataAnchoringWithRatioTest.input
    let humanReadable = FeeDelegatedChainDataAnchoringWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedChainDataAnchoringWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedChainDataAnchoringWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedChainDataAnchoringWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedChainDataAnchoringWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedChainDataAnchoringWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedChainDataAnchoringWithRatioTest.expectedRLPEncoding
        
    override func setUpWithError() throws {
        mTxObj = try FeeDelegatedChainDataAnchoringWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setInput(input)
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

class FeeDelegatedChainDataAnchoringWithRatioTest_appendFeePayerSignaturesTest: XCTestCase {
    var mTxObj: FeeDelegatedChainDataAnchoringWithRatio?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedChainDataAnchoringWithRatioTest.feePayerPrivateKey
    
    let from = FeeDelegatedChainDataAnchoringWithRatioTest.from
    let account = FeeDelegatedChainDataAnchoringWithRatioTest.account
    let to = FeeDelegatedChainDataAnchoringWithRatioTest.to
    let gas = FeeDelegatedChainDataAnchoringWithRatioTest.gas
    let nonce = FeeDelegatedChainDataAnchoringWithRatioTest.nonce
    let gasPrice = FeeDelegatedChainDataAnchoringWithRatioTest.gasPrice
    let chainID = FeeDelegatedChainDataAnchoringWithRatioTest.chainID
    let value = FeeDelegatedChainDataAnchoringWithRatioTest.value
    let input = FeeDelegatedChainDataAnchoringWithRatioTest.input
    let humanReadable = FeeDelegatedChainDataAnchoringWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedChainDataAnchoringWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedChainDataAnchoringWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedChainDataAnchoringWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedChainDataAnchoringWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedChainDataAnchoringWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedChainDataAnchoringWithRatioTest.expectedRLPEncoding
    
    override func setUpWithError() throws {
        mTxObj = try FeeDelegatedChainDataAnchoringWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setInput(input)
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
        mTxObj = try FeeDelegatedChainDataAnchoringWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setInput(input)
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
        
        mTxObj = try FeeDelegatedChainDataAnchoringWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setInput(input)
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
        
        mTxObj = try FeeDelegatedChainDataAnchoringWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setInput(input)
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

class FeeDelegatedChainDataAnchoringWithRatioTest_combineSignatureTest: XCTestCase {
    var mTxObj: FeeDelegatedChainDataAnchoringWithRatio?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedChainDataAnchoringWithRatioTest.feePayerPrivateKey
    
    let from = "0xacfda1ac94468f2bda3e30a272215d0a5b5be413"
    let account = FeeDelegatedChainDataAnchoringWithRatioTest.account
    let to = FeeDelegatedChainDataAnchoringWithRatioTest.to
    let gas = "0x249f0"
    let nonce = "0x1"
    let gasPrice = "0x5d21dba00"
    let chainID = "0x7e3"
    let value = FeeDelegatedChainDataAnchoringWithRatioTest.value
    let input = FeeDelegatedChainDataAnchoringWithRatioTest.input
    let humanReadable = FeeDelegatedChainDataAnchoringWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedChainDataAnchoringWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedChainDataAnchoringWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedChainDataAnchoringWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedChainDataAnchoringWithRatioTest.feePayerSignatureData
    let feeRatio = BigInt(30)
    
    let expectedRLPEncoding = FeeDelegatedChainDataAnchoringWithRatioTest.expectedRLPEncoding
    
    override func setUpWithError() throws {
        mTxObj = try FeeDelegatedChainDataAnchoringWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setInput(input)
            .setFeeRatio(feeRatio)
            .setChainId(chainID)
            .build()
    }
    
    public func test_combineSignature() throws {
        let expectedRLPEncoded = "0x4af90135018505d21dba00830249f094acfda1ac94468f2bda3e30a272215d0a5b5be413b8aff8ad80b8aaf8a8a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a000000000000000000000000000000000000000000000000000000000000000040580061ef847f845820feaa01fba7ba78b13f7b85e8f240aea9ea22df8d0eaf68bc33486e815718e5a635413a07e1b339a04862531af1e966f2cddb2fe8dc6f48f508da435300045979d4ef44c940000000000000000000000000000000000000000c4c3018080"
        
        let expectedSignature = SignatureData(
            "0x0fea",
            "0x1fba7ba78b13f7b85e8f240aea9ea22df8d0eaf68bc33486e815718e5a635413",
            "0x7e1b339a04862531af1e966f2cddb2fe8dc6f48f508da435300045979d4ef44c"
        )
        
        let rlpEncoded = "0x4af90135018505d21dba00830249f094acfda1ac94468f2bda3e30a272215d0a5b5be413b8aff8ad80b8aaf8a8a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a000000000000000000000000000000000000000000000000000000000000000040580061ef847f845820feaa01fba7ba78b13f7b85e8f240aea9ea22df8d0eaf68bc33486e815718e5a635413a07e1b339a04862531af1e966f2cddb2fe8dc6f48f508da435300045979d4ef44c940000000000000000000000000000000000000000c4c3018080"
        
        let combined = try mTxObj!.combineSignedRawTransactions([rlpEncoded])
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature, mTxObj?.signatures[0])
    }
    
    public func test_combine_multipleSignature() throws {
        let expectedRLPEncoded = "0x4af901c3018505d21dba00830249f094acfda1ac94468f2bda3e30a272215d0a5b5be413b8aff8ad80b8aaf8a8a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a000000000000000000000000000000000000000000000000000000000000000040580061ef8d5f845820feaa01fba7ba78b13f7b85e8f240aea9ea22df8d0eaf68bc33486e815718e5a635413a07e1b339a04862531af1e966f2cddb2fe8dc6f48f508da435300045979d4ef44cf845820fe9a0d52efcc22cd8bc3ae0dc0fa8b4a0c68ffda9295ed7a9ed612d4af6bcdfc04af5a067749106fce239d6669ae86e9eb389f25e3c506e9934435150774ed2776e974cf845820feaa0ca90225e2de0caa34d9676690224028bd03cd99a76a0fa631466073a3f8f1944a02678afba3c5071e5a7a7084bcec0a12913f779a30303f81d897c862622048ab8940000000000000000000000000000000000000000c4c3018080"
        
        let expectedSignature = [
            SignatureData(
                    "0x0fea",
                    "0x1fba7ba78b13f7b85e8f240aea9ea22df8d0eaf68bc33486e815718e5a635413",
                    "0x7e1b339a04862531af1e966f2cddb2fe8dc6f48f508da435300045979d4ef44c"
            ),
            SignatureData(
                    "0x0fe9",
                    "0xd52efcc22cd8bc3ae0dc0fa8b4a0c68ffda9295ed7a9ed612d4af6bcdfc04af5",
                    "0x67749106fce239d6669ae86e9eb389f25e3c506e9934435150774ed2776e974c"
            ),
            SignatureData(
                    "0x0fea",
                    "0xca90225e2de0caa34d9676690224028bd03cd99a76a0fa631466073a3f8f1944",
                    "0x2678afba3c5071e5a7a7084bcec0a12913f779a30303f81d897c862622048ab8"
            )
        ]
        
        let rlpEncodedString = [
            "0x4af90121018505d21dba00830249f094acfda1ac94468f2bda3e30a272215d0a5b5be413b8aff8ad80b8aaf8a8a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a000000000000000000000000000000000000000000000000000000000000000040580061ef847f845820fe9a0d52efcc22cd8bc3ae0dc0fa8b4a0c68ffda9295ed7a9ed612d4af6bcdfc04af5a067749106fce239d6669ae86e9eb389f25e3c506e9934435150774ed2776e974c80c4c3018080",
            "0x4af90121018505d21dba00830249f094acfda1ac94468f2bda3e30a272215d0a5b5be413b8aff8ad80b8aaf8a8a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a000000000000000000000000000000000000000000000000000000000000000040580061ef847f845820feaa0ca90225e2de0caa34d9676690224028bd03cd99a76a0fa631466073a3f8f1944a02678afba3c5071e5a7a7084bcec0a12913f779a30303f81d897c862622048ab880c4c3018080"
        ]
        
        let senderSignatureData = SignatureData(
            "0x0fea",
            "0x1fba7ba78b13f7b85e8f240aea9ea22df8d0eaf68bc33486e815718e5a635413",
            "0x7e1b339a04862531af1e966f2cddb2fe8dc6f48f508da435300045979d4ef44c"
        )
        
        mTxObj = try FeeDelegatedChainDataAnchoringWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setInput(input)
            .setFeeRatio(feeRatio)
            .setChainId(chainID)
            .setSignatures(senderSignatureData)
            .build()
        
        let combined = try mTxObj!.combineSignedRawTransactions(rlpEncodedString)
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature[0], mTxObj?.signatures[0])
        XCTAssertEqual(expectedSignature[1], mTxObj?.signatures[1])
        XCTAssertEqual(expectedSignature[2], mTxObj?.signatures[2])
    }
    
    public func test_combineSignature_feePayerSignature() throws {
        let expectedRLPEncoded = "0x4af90135018505d21dba00830249f094acfda1ac94468f2bda3e30a272215d0a5b5be413b8aff8ad80b8aaf8a8a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a000000000000000000000000000000000000000000000000000000000000000040580061ec4c30180809475d141c9dbefde51f488c8d79da55f48282a1e52f847f845820feaa0945863c17f8213765cb3196b6988840488e326055d0c654d34c71bd798ae5ec3a0784a6ecf82352503d12bd2c609016b7e7f8af1ed04d0cdceb02cd0f0830d8881"
        
        let expectedSignature = SignatureData(
            "0x0fea",
            "0x945863c17f8213765cb3196b6988840488e326055d0c654d34c71bd798ae5ec3",
            "0x784a6ecf82352503d12bd2c609016b7e7f8af1ed04d0cdceb02cd0f0830d8881"
        )
        
        let rlpEncoded = "0x4af90135018505d21dba00830249f094acfda1ac94468f2bda3e30a272215d0a5b5be413b8aff8ad80b8aaf8a8a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a000000000000000000000000000000000000000000000000000000000000000040580061ec4c30180809475d141c9dbefde51f488c8d79da55f48282a1e52f847f845820feaa0945863c17f8213765cb3196b6988840488e326055d0c654d34c71bd798ae5ec3a0784a6ecf82352503d12bd2c609016b7e7f8af1ed04d0cdceb02cd0f0830d8881"
        
        mTxObj = try FeeDelegatedChainDataAnchoringWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setInput(input)
            .setFeeRatio(feeRatio)
            .setChainId(chainID)
            .build()
        
        let combined = try mTxObj!.combineSignedRawTransactions([rlpEncoded])
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature, mTxObj?.feePayerSignatures[0])
    }
    
    public func test_combineSignature_multipleFeePayerSignature() throws {
        let expectedRLPEncoded = "0x4af901c3018505d21dba00830249f094acfda1ac94468f2bda3e30a272215d0a5b5be413b8aff8ad80b8aaf8a8a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a000000000000000000000000000000000000000000000000000000000000000040580061ec4c30180809475d141c9dbefde51f488c8d79da55f48282a1e52f8d5f845820feaa0945863c17f8213765cb3196b6988840488e326055d0c654d34c71bd798ae5ec3a0784a6ecf82352503d12bd2c609016b7e7f8af1ed04d0cdceb02cd0f0830d8881f845820feaa092b2e701dea51bd0958d40d67b1a794822153a7624f35609d8f6320467067226a0161b871c857cf7ddb259e3dc76b4bad176a52b488bb9cea7198b778f3d0cb770f845820feaa0d67112e14b4fb00d5b0304638d665e0052e57e0d4bfa4fc00040b9e991bbd36da049eb2a9e8d2575e707631d2c3dc708152c5cbf59a52846871adbe7f8ae1add13"
        
        let expectedSignature = [
            SignatureData(
                    "0x0fea",
                    "0x945863c17f8213765cb3196b6988840488e326055d0c654d34c71bd798ae5ec3",
                    "0x784a6ecf82352503d12bd2c609016b7e7f8af1ed04d0cdceb02cd0f0830d8881"
            ),
            SignatureData(
                    "0x0fea",
                    "0x92b2e701dea51bd0958d40d67b1a794822153a7624f35609d8f6320467067226",
                    "0x161b871c857cf7ddb259e3dc76b4bad176a52b488bb9cea7198b778f3d0cb770"
            ),
            SignatureData(
                    "0x0fea",
                    "0xd67112e14b4fb00d5b0304638d665e0052e57e0d4bfa4fc00040b9e991bbd36d",
                    "0x49eb2a9e8d2575e707631d2c3dc708152c5cbf59a52846871adbe7f8ae1add13"
            )
        ]
        
        let rlpEncodedString = [
            "0x4af90135018505d21dba00830249f094acfda1ac94468f2bda3e30a272215d0a5b5be413b8aff8ad80b8aaf8a8a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a000000000000000000000000000000000000000000000000000000000000000040580061ec4c30180809475d141c9dbefde51f488c8d79da55f48282a1e52f847f845820feaa092b2e701dea51bd0958d40d67b1a794822153a7624f35609d8f6320467067226a0161b871c857cf7ddb259e3dc76b4bad176a52b488bb9cea7198b778f3d0cb770",
            "0x4af90135018505d21dba00830249f094acfda1ac94468f2bda3e30a272215d0a5b5be413b8aff8ad80b8aaf8a8a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a000000000000000000000000000000000000000000000000000000000000000040580061ec4c30180809475d141c9dbefde51f488c8d79da55f48282a1e52f847f845820feaa0d67112e14b4fb00d5b0304638d665e0052e57e0d4bfa4fc00040b9e991bbd36da049eb2a9e8d2575e707631d2c3dc708152c5cbf59a52846871adbe7f8ae1add13"
        ]
        
        let feePayer = "0x75d141c9dbefde51f488c8d79da55f48282a1e52"
        let feePayerSignatureData = SignatureData(
            "0x0fea",
            "0x945863c17f8213765cb3196b6988840488e326055d0c654d34c71bd798ae5ec3",
            "0x784a6ecf82352503d12bd2c609016b7e7f8af1ed04d0cdceb02cd0f0830d8881"
        )
        
        mTxObj = try FeeDelegatedChainDataAnchoringWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setInput(input)
            .setFeeRatio(feeRatio)
            .setFeePayer(feePayer)
            .setChainId(chainID)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        let combined = try mTxObj!.combineSignedRawTransactions(rlpEncodedString)
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature[0], mTxObj?.feePayerSignatures[0])
        XCTAssertEqual(expectedSignature[1], mTxObj?.feePayerSignatures[1])
        XCTAssertEqual(expectedSignature[2], mTxObj?.feePayerSignatures[2])
    }
    
    public func test_multipleSignature_senderSignatureData_feePayerSignature() throws {
        mTxObj = try FeeDelegatedChainDataAnchoringWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setInput(input)
            .setFeeRatio(feeRatio)
            .setChainId(chainID)
            .build()
        
        let rlpEncodedString = "0x4af901af018505d21dba00830249f094acfda1ac94468f2bda3e30a272215d0a5b5be413b8aff8ad80b8aaf8a8a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a000000000000000000000000000000000000000000000000000000000000000040580061ef8d5f845820feaa01fba7ba78b13f7b85e8f240aea9ea22df8d0eaf68bc33486e815718e5a635413a07e1b339a04862531af1e966f2cddb2fe8dc6f48f508da435300045979d4ef44cf845820fe9a0d52efcc22cd8bc3ae0dc0fa8b4a0c68ffda9295ed7a9ed612d4af6bcdfc04af5a067749106fce239d6669ae86e9eb389f25e3c506e9934435150774ed2776e974cf845820feaa0ca90225e2de0caa34d9676690224028bd03cd99a76a0fa631466073a3f8f1944a02678afba3c5071e5a7a7084bcec0a12913f779a30303f81d897c862622048ab880c4c3018080"
        
        let expectedSignature = [
            SignatureData(
                    "0x0fea",
                    "0x1fba7ba78b13f7b85e8f240aea9ea22df8d0eaf68bc33486e815718e5a635413",
                    "0x7e1b339a04862531af1e966f2cddb2fe8dc6f48f508da435300045979d4ef44c"
            ),
            SignatureData(
                    "0x0fe9",
                    "0xd52efcc22cd8bc3ae0dc0fa8b4a0c68ffda9295ed7a9ed612d4af6bcdfc04af5",
                    "0x67749106fce239d6669ae86e9eb389f25e3c506e9934435150774ed2776e974c"
            ),
            SignatureData(
                    "0x0fea",
                    "0xca90225e2de0caa34d9676690224028bd03cd99a76a0fa631466073a3f8f1944",
                    "0x2678afba3c5071e5a7a7084bcec0a12913f779a30303f81d897c862622048ab8"
            )
        ]
        
        _ = try mTxObj!.combineSignedRawTransactions([rlpEncodedString])
        
        let rlpEncodedStringsWithFeePayerSignatures = "0x4af901c3018505d21dba00830249f094acfda1ac94468f2bda3e30a272215d0a5b5be413b8aff8ad80b8aaf8a8a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a000000000000000000000000000000000000000000000000000000000000000040580061ec4c30180809475d141c9dbefde51f488c8d79da55f48282a1e52f8d5f845820feaa0945863c17f8213765cb3196b6988840488e326055d0c654d34c71bd798ae5ec3a0784a6ecf82352503d12bd2c609016b7e7f8af1ed04d0cdceb02cd0f0830d8881f845820feaa092b2e701dea51bd0958d40d67b1a794822153a7624f35609d8f6320467067226a0161b871c857cf7ddb259e3dc76b4bad176a52b488bb9cea7198b778f3d0cb770f845820feaa0d67112e14b4fb00d5b0304638d665e0052e57e0d4bfa4fc00040b9e991bbd36da049eb2a9e8d2575e707631d2c3dc708152c5cbf59a52846871adbe7f8ae1add13"
        
        let expectedFeePayerSignatures = [
            SignatureData(
                    "0x0fea",
                    "0x945863c17f8213765cb3196b6988840488e326055d0c654d34c71bd798ae5ec3",
                    "0x784a6ecf82352503d12bd2c609016b7e7f8af1ed04d0cdceb02cd0f0830d8881"
            ),
            SignatureData(
                    "0x0fea",
                    "0x92b2e701dea51bd0958d40d67b1a794822153a7624f35609d8f6320467067226",
                    "0x161b871c857cf7ddb259e3dc76b4bad176a52b488bb9cea7198b778f3d0cb770"
            ),
            SignatureData(
                    "0x0fea",
                    "0xd67112e14b4fb00d5b0304638d665e0052e57e0d4bfa4fc00040b9e991bbd36d",
                    "0x49eb2a9e8d2575e707631d2c3dc708152c5cbf59a52846871adbe7f8ae1add13"
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
        mTxObj = try FeeDelegatedChainDataAnchoringWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setInput(input)
            .setFeeRatio(feeRatio)
            .setChainId(chainID)
            .build()
        
        let rlpEncoded = "0x4af90121018505d21dba00830249f094acfda1ac94468f2bda3e30a272215d0a5b5be413b8aff8ad80b8aaf8a8a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a000000000000000000000000000000000000000000000000000000000000000040580061ef847f845820feaa01fba7ba78b13f7b85e8f240aea9ea22df8d0eaf68bc33486e815718e5a635413a07e1b339a04862531af1e966f2cddb2fe8dc6f48f508da435300045979d4ef44c80c4c3018080"
        
        XCTAssertThrowsError(try mTxObj!.combineSignedRawTransactions([rlpEncoded])) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("Transactions containing different information cannot be combined."))
        }
    }
}

class FeeDelegatedChainDataAnchoringWithRatioTest_getRawTransactionTest: XCTestCase {
    var mTxObj: FeeDelegatedChainDataAnchoringWithRatio?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedChainDataAnchoringWithRatioTest.feePayerPrivateKey
    
    let from = FeeDelegatedChainDataAnchoringWithRatioTest.from
    let account = FeeDelegatedChainDataAnchoringWithRatioTest.account
    let to = FeeDelegatedChainDataAnchoringWithRatioTest.to
    let gas = FeeDelegatedChainDataAnchoringWithRatioTest.gas
    let nonce = FeeDelegatedChainDataAnchoringWithRatioTest.nonce
    let gasPrice = FeeDelegatedChainDataAnchoringWithRatioTest.gasPrice
    let chainID = FeeDelegatedChainDataAnchoringWithRatioTest.chainID
    let value = FeeDelegatedChainDataAnchoringWithRatioTest.value
    let input = FeeDelegatedChainDataAnchoringWithRatioTest.input
    let humanReadable = FeeDelegatedChainDataAnchoringWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedChainDataAnchoringWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedChainDataAnchoringWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedChainDataAnchoringWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedChainDataAnchoringWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedChainDataAnchoringWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedChainDataAnchoringWithRatioTest.expectedRLPEncoding
    
    public func test_getRawTransaction() throws {
        let txObj = try FeeDelegatedChainDataAnchoringWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .setInput(input)
            .build()

        XCTAssertEqual(expectedRLPEncoding, try txObj.getRawTransaction())
    }
}

class FeeDelegatedChainDataAnchoringWithRatioTest_getTransactionHashTest: XCTestCase {
    var mTxObj: FeeDelegatedChainDataAnchoringWithRatio?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedChainDataAnchoringWithRatioTest.feePayerPrivateKey
    
    let from = FeeDelegatedChainDataAnchoringWithRatioTest.from
    let account = FeeDelegatedChainDataAnchoringWithRatioTest.account
    let to = FeeDelegatedChainDataAnchoringWithRatioTest.to
    let gas = FeeDelegatedChainDataAnchoringWithRatioTest.gas
    let nonce = FeeDelegatedChainDataAnchoringWithRatioTest.nonce
    let gasPrice = FeeDelegatedChainDataAnchoringWithRatioTest.gasPrice
    let chainID = FeeDelegatedChainDataAnchoringWithRatioTest.chainID
    let value = FeeDelegatedChainDataAnchoringWithRatioTest.value
    let input = FeeDelegatedChainDataAnchoringWithRatioTest.input
    let humanReadable = FeeDelegatedChainDataAnchoringWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedChainDataAnchoringWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedChainDataAnchoringWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedChainDataAnchoringWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedChainDataAnchoringWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedChainDataAnchoringWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedChainDataAnchoringWithRatioTest.expectedRLPEncoding
    let expectedTransactionHash = FeeDelegatedChainDataAnchoringWithRatioTest.expectedTransactionHash
            
    public func test_getTransactionHash() throws {
        let txObj = try FeeDelegatedChainDataAnchoringWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .setInput(input)
            .build()

        XCTAssertEqual(expectedTransactionHash, try txObj.getTransactionHash())
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try FeeDelegatedChainDataAnchoringWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .setInput(input)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getTransactionHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_gasPrice() throws {
        let gasPrice = ""
        
        mTxObj = try FeeDelegatedChainDataAnchoringWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .setInput(input)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getTransactionHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class FeeDelegatedChainDataAnchoringWithRatioTest_getSenderTxHashTest: XCTestCase {
    var mTxObj: FeeDelegatedChainDataAnchoringWithRatio?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedChainDataAnchoringWithRatioTest.feePayerPrivateKey
    
    let from = FeeDelegatedChainDataAnchoringWithRatioTest.from
    let account = FeeDelegatedChainDataAnchoringWithRatioTest.account
    let to = FeeDelegatedChainDataAnchoringWithRatioTest.to
    let gas = FeeDelegatedChainDataAnchoringWithRatioTest.gas
    let nonce = FeeDelegatedChainDataAnchoringWithRatioTest.nonce
    let gasPrice = FeeDelegatedChainDataAnchoringWithRatioTest.gasPrice
    let chainID = FeeDelegatedChainDataAnchoringWithRatioTest.chainID
    let value = FeeDelegatedChainDataAnchoringWithRatioTest.value
    let input = FeeDelegatedChainDataAnchoringWithRatioTest.input
    let humanReadable = FeeDelegatedChainDataAnchoringWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedChainDataAnchoringWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedChainDataAnchoringWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedChainDataAnchoringWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedChainDataAnchoringWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedChainDataAnchoringWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedChainDataAnchoringWithRatioTest.expectedRLPEncoding
    let expectedTransactionHash = FeeDelegatedChainDataAnchoringWithRatioTest.expectedTransactionHash
    let expectedSenderTransactionHash = FeeDelegatedChainDataAnchoringWithRatioTest.expectedRLPSenderTransactionHash
            
    public func test_getRLPEncodingForSignature() throws {
        mTxObj = try FeeDelegatedChainDataAnchoringWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .setInput(input)
            .build()
        
        XCTAssertEqual(expectedSenderTransactionHash, try mTxObj!.getSenderTxHash())
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try FeeDelegatedChainDataAnchoringWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .setInput(input)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getSenderTxHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_gasPrice() throws {
        let gasPrice = ""
        
        mTxObj = try FeeDelegatedChainDataAnchoringWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .setInput(input)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getSenderTxHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class FeeDelegatedChainDataAnchoringWithRatioTest_getRLPEncodingForFeePayerSignatureTest: XCTestCase {
    var mTxObj: FeeDelegatedChainDataAnchoringWithRatio?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedChainDataAnchoringWithRatioTest.feePayerPrivateKey
    
    let from = FeeDelegatedChainDataAnchoringWithRatioTest.from
    let account = FeeDelegatedChainDataAnchoringWithRatioTest.account
    let to = FeeDelegatedChainDataAnchoringWithRatioTest.to
    let gas = FeeDelegatedChainDataAnchoringWithRatioTest.gas
    let nonce = FeeDelegatedChainDataAnchoringWithRatioTest.nonce
    let gasPrice = FeeDelegatedChainDataAnchoringWithRatioTest.gasPrice
    let chainID = FeeDelegatedChainDataAnchoringWithRatioTest.chainID
    let value = FeeDelegatedChainDataAnchoringWithRatioTest.value
    let input = FeeDelegatedChainDataAnchoringWithRatioTest.input
    let humanReadable = FeeDelegatedChainDataAnchoringWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedChainDataAnchoringWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedChainDataAnchoringWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedChainDataAnchoringWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedChainDataAnchoringWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedChainDataAnchoringWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedChainDataAnchoringWithRatioTest.expectedRLPEncoding
    let expectedTransactionHash = FeeDelegatedChainDataAnchoringWithRatioTest.expectedTransactionHash
    let expectedSenderTransactionHash = FeeDelegatedChainDataAnchoringWithRatioTest.expectedRLPSenderTransactionHash
    let expectedRLPEncodingForFeePayerSigning = FeeDelegatedChainDataAnchoringWithRatioTest.expectedRLPEncodingForFeePayerSigning
            
    public func test_getRLPEncodingForSignature() throws {
        mTxObj = try FeeDelegatedChainDataAnchoringWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .setInput(input)
            .build()
        
        XCTAssertEqual(expectedRLPEncodingForFeePayerSigning, try mTxObj!.getRLPEncodingForFeePayerSignature())
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try FeeDelegatedChainDataAnchoringWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .setInput(input)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_gasPrice() throws {
        let gasPrice = ""
        
        mTxObj = try FeeDelegatedChainDataAnchoringWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .setInput(input)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_chainID() throws {
        let chainID = ""
        
        mTxObj = try FeeDelegatedChainDataAnchoringWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .setInput(input)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("chainId is undefined. Define chainId in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}
