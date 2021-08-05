//
//  FeeDelegatedSmartContractExecutionTest.swift
//  CaverSwiftTests
//
//  Created by won on 2021/07/16.
//

import XCTest
@testable import CaverSwift

class FeeDelegatedSmartContractExecutionTest: XCTestCase {
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

    static let senderSignatureData = SignatureData(
        "0x25",
        "0x253aea7d2c37160da45e84afbb45f6b3341cf1e8fc2df4ecc78f14adb512dc4f",
        "0x22465b74015c2a8f8501186bb5e200e6ce44be52e9374615a7e7e21c41bc27b5"
    )
    static let feePayer = "0x5A0043070275d9f6054307Ee7348bD660849D90f"
    static let feePayerSignatureData = SignatureData(
        "0x26",
        "0xe7c51db7b922c6fa2a941c9687884c593b1b13076bdf0c473538d826bf7b9d1a",
        "0x5b0de2aabb84b66db8bf52d62f3d3b71b592e3748455630f1504c20073624d80"
    )

    static let expectedRLPEncoding = "0x31f8fb8204d219830f4240947b65b75d204abed71587c9e519a89277766ee1d00a94a94f5374fce5edbc8e2a8697c15331677e6ebf0ba46353586b000000000000000000000000bc5951f055a85f41a3b62fd6f68ab7de76d299b2f845f84325a0253aea7d2c37160da45e84afbb45f6b3341cf1e8fc2df4ecc78f14adb512dc4fa022465b74015c2a8f8501186bb5e200e6ce44be52e9374615a7e7e21c41bc27b5945a0043070275d9f6054307ee7348bd660849d90ff845f84326a0e7c51db7b922c6fa2a941c9687884c593b1b13076bdf0c473538d826bf7b9d1aa05b0de2aabb84b66db8bf52d62f3d3b71b592e3748455630f1504c20073624d80"
    static let expectedTransactionHash = "0xef46f28c54b3d90a183e26f406ca1d5cc2b6e9fbb6cfa7c85a10330ffadf54b0"
    static let expectedSenderTransactionHash = "0x3cd3380f4206943422d5d5b218dd66d03d60d19a109f9929ea12b52a230257cb"
    static let expectedRLPEncodingForFeePayerSigning = "0xf875b85bf859318204d219830f4240947b65b75d204abed71587c9e519a89277766ee1d00a94a94f5374fce5edbc8e2a8697c15331677e6ebf0ba46353586b000000000000000000000000bc5951f055a85f41a3b62fd6f68ab7de76d299b2945a0043070275d9f6054307ee7348bd660849d90f018080"
        
    public static func generateRoleBaseKeyring(_ numArr: [Int], _ address: String) throws -> AbstractKeyring {
        let keyArr = KeyringFactory.generateRoleBasedKeys(numArr, "entropy")
        return try KeyringFactory.createWithRoleBasedKey(address, keyArr)
    }
}

class FeeDelegatedSmartContractExecutionTest_createInstanceBuilder: XCTestCase {
    let from = FeeDelegatedSmartContractExecutionTest.from
    let account = FeeDelegatedSmartContractExecutionTest.account
    let to = FeeDelegatedSmartContractExecutionTest.to
    let gas = FeeDelegatedSmartContractExecutionTest.gas
    let nonce = FeeDelegatedSmartContractExecutionTest.nonce
    let gasPrice = FeeDelegatedSmartContractExecutionTest.gasPrice
    let chainID = FeeDelegatedSmartContractExecutionTest.chainID
    let value = FeeDelegatedSmartContractExecutionTest.value
    let input = FeeDelegatedSmartContractExecutionTest.input
    let humanReadable = FeeDelegatedSmartContractExecutionTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractExecutionTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractExecutionTest.senderSignatureData
    let feePayer = FeeDelegatedSmartContractExecutionTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractExecutionTest.feePayerSignatureData
        
    public func test_BuilderTest() throws {
        let txObj = try FeeDelegatedSmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertNotNil(txObj)
    }
    
    public func test_BuilderWithRPCTest() throws {
        let txObj = try FeeDelegatedSmartContractExecution.Builder()
            .setKlaytnCall(FeeDelegatedSmartContractExecutionTest.caver.rpc.klay)
            .setGas(gas)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        try txObj.fillTransaction()
        
        XCTAssertFalse(txObj.nonce.isEmpty)
        XCTAssertFalse(txObj.gasPrice.isEmpty)
        XCTAssertFalse(txObj.chainId.isEmpty)
    }
    
    public func test_BuilderTestWithBigInteger() throws {
        let txObj = try FeeDelegatedSmartContractExecution.Builder()
            .setNonce(BigInt(hex: nonce)!)
            .setGas(BigInt(hex: gas)!)
            .setGasPrice(BigInt(hex: gasPrice)!)
            .setChainId(BigInt(hex: chainID)!)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
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
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecution.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setValue(value)
                                .setTo(to)
                                .setInput(input)
                                .setFeePayer(feePayer)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(from)"))
        }
    }
    
    public func test_throwException_missingFrom() throws {
        let from = ""
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecution.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setValue(value)
                                .setTo(to)
                                .setInput(input)
                                .setFeePayer(feePayer)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("from is missing."))
        }
    }
    
    public func test_throwException_invalidTo() throws {
        let to = "invalid Address"
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecution.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setValue(value)
                                .setTo(to)
                                .setInput(input)
                                .setFeePayer(feePayer)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(to)"))
        }
    }
    
    public func test_throwException_invalidValue() throws {
        let value = "invalid value"
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecution.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setValue(value)
                                .setTo(to)
                                .setInput(input)
                                .setFeePayer(feePayer)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid value : \(value)"))
        }
    }
    
    public func test_throwException_missingValue() throws {
        let value = ""
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecution.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setValue(value)
                                .setTo(to)
                                .setInput(input)
                                .setFeePayer(feePayer)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("value is missing."))
        }
    }
        
    public func test_throwException_invalidGas() throws {
        let gas = "invalid gas"
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecution.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setValue(value)
                                .setTo(to)
                                .setInput(input)
                                .setFeePayer(feePayer)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid gas. : \(gas)"))
        }
    }
    
    public func test_throwException_missingGas() throws {
        let gas = ""
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecution.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setValue(value)
                                .setTo(to)
                                .setInput(input)
                                .setFeePayer(feePayer)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("gas is missing."))
        }
    }
    
    public func test_throwException_invalidInput() throws {
        let input = "invalid input"
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecution.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setValue(value)
                                .setTo(to)
                                .setInput(input)
                                .setFeePayer(feePayer)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid input. : \(input)"))
        }
    }
    
    public func test_throwException_missingInput() throws {
        let input = ""
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecution.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setValue(value)
                                .setTo(to)
                                .setInput(input)
                                .setFeePayer(feePayer)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("input is missing."))
        }
    }
    
    public func test_throwException_setFeePayerSignatures_missingFeePayer() throws {
        let feePayer = ""
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecution.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setValue(value)
                                .setTo(to)
                                .setInput(input)
                                .setFeePayer(feePayer)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("feePayer is missing: feePayer must be defined with feePayerSignatures."))
        }
    }
}

class FeeDelegatedSmartContractExecutionTest_createInstance: XCTestCase {
    let from = FeeDelegatedSmartContractExecutionTest.from
    let account = FeeDelegatedSmartContractExecutionTest.account
    let to = FeeDelegatedSmartContractExecutionTest.to
    let gas = FeeDelegatedSmartContractExecutionTest.gas
    let nonce = FeeDelegatedSmartContractExecutionTest.nonce
    let gasPrice = FeeDelegatedSmartContractExecutionTest.gasPrice
    let chainID = FeeDelegatedSmartContractExecutionTest.chainID
    let value = FeeDelegatedSmartContractExecutionTest.value
    let input = FeeDelegatedSmartContractExecutionTest.input
    let humanReadable = FeeDelegatedSmartContractExecutionTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractExecutionTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractExecutionTest.senderSignatureData
    let feePayer = FeeDelegatedSmartContractExecutionTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractExecutionTest.feePayerSignatureData
    
    public func test_createInstance() throws {
        let txObj = try FeeDelegatedSmartContractExecution(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            to,
            value,
            input
        )
        
        XCTAssertNotNil(txObj)
    }
    
    public func test_throwException_invalidFrom() throws {
        let from = "invalid Address"
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecution(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            to,
            value,
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(from)"))
        }
    }
    
    public func test_throwException_missingFrom() throws {
        let from = ""
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecution(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            to,
            value,
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("from is missing."))
        }
    }
    
    public func test_throwException_invalidTo() throws {
        let to = "invalid Address"
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecution(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            to,
            value,
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(to)"))
        }
    }
    
    public func test_throwException_missingTo() throws {
        let to = ""
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecution(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            to,
            value,
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("to is missing."))
        }
    }
    
    public func test_throwException_invalidValue() throws {
        let value = "invalid value"
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecution(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            to,
            value,
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid value : \(value)"))
        }
    }
    
    public func test_throwException_missingValue() throws {
        let value = ""
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecution(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            to,
            value,
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("value is missing."))
        }
    }
    
    public func test_throwException_invalidGas() throws {
        let gas = "invalid gas"
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecution(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            to,
            value,
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid gas. : \(gas)"))
        }
    }
    
    public func test_throwException_missingGas() throws {
        let gas = ""
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecution(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            to,
            value,
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("gas is missing."))
        }
    }
    
    public func test_throwException_invalidInput() throws {
        let input = "invalid input"
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecution(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            to,
            value,
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid input. : \(input)"))
        }
    }
    
    public func test_throwException_missingInput() throws {
        let input = ""
        XCTAssertThrowsError(try FeeDelegatedSmartContractExecution(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            to,
            value,
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("input is missing."))
        }
    }
}

class FeeDelegatedSmartContractExecutionTest_getRLPEncodingTest: XCTestCase {
    let from = FeeDelegatedSmartContractExecutionTest.from
    let account = FeeDelegatedSmartContractExecutionTest.account
    let to = FeeDelegatedSmartContractExecutionTest.to
    let gas = FeeDelegatedSmartContractExecutionTest.gas
    let nonce = FeeDelegatedSmartContractExecutionTest.nonce
    let gasPrice = FeeDelegatedSmartContractExecutionTest.gasPrice
    let chainID = FeeDelegatedSmartContractExecutionTest.chainID
    let value = FeeDelegatedSmartContractExecutionTest.value
    let input = FeeDelegatedSmartContractExecutionTest.input
    let humanReadable = FeeDelegatedSmartContractExecutionTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractExecutionTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractExecutionTest.senderSignatureData
    let feePayer = FeeDelegatedSmartContractExecutionTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractExecutionTest.feePayerSignatureData
    
    let expectedRLPEncoding = FeeDelegatedSmartContractExecutionTest.expectedRLPEncoding
        
    public func test_getRLPEncoding() throws {
        let txObj = try FeeDelegatedSmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertEqual(expectedRLPEncoding, try txObj.getRLPEncoding())
    }
    
    public func test_throwException_NoNonce() throws {
        let txObj = try FeeDelegatedSmartContractExecution.Builder()
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertThrowsError(try txObj.getRLPEncoding()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NoGasPrice() throws {
        let txObj = try FeeDelegatedSmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertThrowsError(try txObj.getRLPEncoding()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class FeeDelegatedSmartContractExecutionTest_signAsFeePayer_OneKeyTest: XCTestCase {
    var mTxObj: FeeDelegatedSmartContractExecution?
    var klaytnWalletKey: String?
    var keyring: AbstractKeyring?
    var feePayerAddress: String?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedSmartContractExecutionTest.feePayerPrivateKey
        
    let from = FeeDelegatedSmartContractExecutionTest.from
    let account = FeeDelegatedSmartContractExecutionTest.account
    let to = FeeDelegatedSmartContractExecutionTest.to
    let gas = FeeDelegatedSmartContractExecutionTest.gas
    let nonce = FeeDelegatedSmartContractExecutionTest.nonce
    let gasPrice = FeeDelegatedSmartContractExecutionTest.gasPrice
    let chainID = FeeDelegatedSmartContractExecutionTest.chainID
    let value = FeeDelegatedSmartContractExecutionTest.value
    let input = FeeDelegatedSmartContractExecutionTest.input
    let humanReadable = FeeDelegatedSmartContractExecutionTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractExecutionTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractExecutionTest.senderSignatureData
    let feePayer = FeeDelegatedSmartContractExecutionTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractExecutionTest.feePayerSignatureData
    
    let expectedRLPEncoding = "0x31f8fb8204d219830f4240947b65b75d204abed71587c9e519a89277766ee1d00a94a94f5374fce5edbc8e2a8697c15331677e6ebf0ba46353586b000000000000000000000000bc5951f055a85f41a3b62fd6f68ab7de76d299b2f845f84325a0253aea7d2c37160da45e84afbb45f6b3341cf1e8fc2df4ecc78f14adb512dc4fa022465b74015c2a8f8501186bb5e200e6ce44be52e9374615a7e7e21c41bc27b59433f524631e573329a550296f595c820d6c65213ff845f84325a003eb559128cf96555ef9df53a8d93f8d8d3924bb510aa4d546f13d89a6ebcdf0a0743788a7ddc975fce765f837726c601d7f065af70f94af5b671b3f445825ecb5"
        
    override func setUpWithError() throws {
        keyring = try KeyringFactory.createFromPrivateKey(feePayerPrivateKey)
        klaytnWalletKey = try keyring?.getKlaytnWalletKey()
        feePayerAddress = keyring?.address
        
        mTxObj = try FeeDelegatedSmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayerAddress!)
            .setSignatures(senderSignatureData)
            .build()
    }
    
    public func test_signAsFeePayer_String() throws {
        _ = try mTxObj!.signAsFeePayer(feePayerPrivateKey)
        XCTAssertEqual(1, mTxObj?.feePayerSignatures.count)
        XCTAssertEqual(expectedRLPEncoding, try mTxObj?.getRawTransaction())
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
        let keyring = try KeyringFactory.createWithMultipleKey(feePayerAddress!, keyArr)
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
        let roleBasedKeyring = try KeyringFactory.createWithRoleBasedKey(feePayerAddress!, keyArr)
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
        let role = try AccountUpdateTest.generateRoleBaseKeyring([3,3,3], feePayerAddress!)
        
        XCTAssertThrowsError(try mTxObj!.signAsFeePayer(role, 4)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid index : index must be less than the length of the key."))
        }
    }
}

class FeeDelegatedSmartContractExecutionTest_signAsFeePayer_AllKeyTest: XCTestCase {
    var mTxObj: FeeDelegatedSmartContractExecution?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedSmartContractExecutionTest.feePayerPrivateKey
        
    let from = FeeDelegatedSmartContractExecutionTest.from
    let account = FeeDelegatedSmartContractExecutionTest.account
    let to = FeeDelegatedSmartContractExecutionTest.to
    let gas = FeeDelegatedSmartContractExecutionTest.gas
    let nonce = FeeDelegatedSmartContractExecutionTest.nonce
    let gasPrice = FeeDelegatedSmartContractExecutionTest.gasPrice
    let chainID = FeeDelegatedSmartContractExecutionTest.chainID
    let value = FeeDelegatedSmartContractExecutionTest.value
    let input = FeeDelegatedSmartContractExecutionTest.input
    let humanReadable = FeeDelegatedSmartContractExecutionTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractExecutionTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractExecutionTest.senderSignatureData
    var feePayer = FeeDelegatedSmartContractExecutionTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractExecutionTest.feePayerSignatureData
    
    let expectedRLPEncoding = FeeDelegatedSmartContractExecutionTest.expectedRLPEncoding
        
    override func setUpWithError() throws {
        mTxObj = try FeeDelegatedSmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
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

class FeeDelegatedSmartContractExecutionTest_appendFeePayerSignaturesTest: XCTestCase {
    var mTxObj: FeeDelegatedSmartContractExecution?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = FeeDelegatedSmartContractExecutionTest.senderPrivateKey
    let feePayerPrivateKey = FeeDelegatedSmartContractExecutionTest.feePayerPrivateKey
        
    let from = FeeDelegatedSmartContractExecutionTest.from
    let account = FeeDelegatedSmartContractExecutionTest.account
    let to = FeeDelegatedSmartContractExecutionTest.to
    let gas = FeeDelegatedSmartContractExecutionTest.gas
    let nonce = FeeDelegatedSmartContractExecutionTest.nonce
    let gasPrice = FeeDelegatedSmartContractExecutionTest.gasPrice
    let chainID = FeeDelegatedSmartContractExecutionTest.chainID
    let value = FeeDelegatedSmartContractExecutionTest.value
    let input = FeeDelegatedSmartContractExecutionTest.input
    let humanReadable = FeeDelegatedSmartContractExecutionTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractExecutionTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractExecutionTest.senderSignatureData
    let feePayer = FeeDelegatedSmartContractExecutionTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractExecutionTest.feePayerSignatureData
    
    override func setUpWithError() throws {
        mTxObj = try FeeDelegatedSmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
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
        mTxObj = try FeeDelegatedSmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
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
        
        mTxObj = try FeeDelegatedSmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
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
        
        mTxObj = try FeeDelegatedSmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
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

class FeeDelegatedSmartContractExecutionTest_combineSignatureTest: XCTestCase {
    var mTxObj: FeeDelegatedSmartContractExecution?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = FeeDelegatedSmartContractExecutionTest.senderPrivateKey
    let from = "0x553b11f36cd1ebcbf74c920dc51cd8a1648cb98a"
    var account: Account?
    let to = "0xd3e7cbbba40c98e05d972438b11ff9374d71654a"
    let gas = "0xdbba0"
    let nonce = "0x3"
    let gasPrice = "0x5d21dba00"
    let chainID = "0x7e3"
    let value = "0x0"
    let input = "0xa9059cbb000000000000000000000000fc9fb77a8407e4ac10e6d5f96574debc844d0d5b00000000000000000000000000000000000000000000000000000002540be400"
    let humanReadable = FeeDelegatedSmartContractExecutionTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractExecutionTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractExecutionTest.senderSignatureData
    let feePayer = FeeDelegatedSmartContractExecutionTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractExecutionTest.feePayerSignatureData
    let expectedRLPEncoding = FeeDelegatedSmartContractExecutionTest.expectedRLPEncoding
    
    override func setUpWithError() throws {
        mTxObj = try FeeDelegatedSmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setTo(to)
            .setValue(value)
            .setInput(input)
            .setChainId(chainID)
            .build()
    }
    
    public func test_combineSignature() throws {
        let expectedRLPEncoded = "0x31f8df038505d21dba00830dbba094d3e7cbbba40c98e05d972438b11ff9374d71654a8094553b11f36cd1ebcbf74c920dc51cd8a1648cb98ab844a9059cbb000000000000000000000000fc9fb77a8407e4ac10e6d5f96574debc844d0d5b00000000000000000000000000000000000000000000000000000002540be400f847f845820fe9a07531ee2314700f1d4f45983cfd9f865cd7c7d90341c745f7371073f407d48acfa03ea07fc14ccd89da897dbfbe10ad04fe8c74ee3a3f3cadf1c5697a8f669bbd71940000000000000000000000000000000000000000c4c3018080"
        
        let expectedSignature = SignatureData(
            "0x0fe9",
            "0x7531ee2314700f1d4f45983cfd9f865cd7c7d90341c745f7371073f407d48acf",
            "0x3ea07fc14ccd89da897dbfbe10ad04fe8c74ee3a3f3cadf1c5697a8f669bbd71"
        )
        
        let rlpEncoded = "0x31f8df038505d21dba00830dbba094d3e7cbbba40c98e05d972438b11ff9374d71654a8094553b11f36cd1ebcbf74c920dc51cd8a1648cb98ab844a9059cbb000000000000000000000000fc9fb77a8407e4ac10e6d5f96574debc844d0d5b00000000000000000000000000000000000000000000000000000002540be400f847f845820fe9a07531ee2314700f1d4f45983cfd9f865cd7c7d90341c745f7371073f407d48acfa03ea07fc14ccd89da897dbfbe10ad04fe8c74ee3a3f3cadf1c5697a8f669bbd71940000000000000000000000000000000000000000c4c3018080"
        
        let combined = try mTxObj!.combineSignedRawTransactions([rlpEncoded])
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature, mTxObj?.signatures[0])
    }
    
    public func test_combine_multipleSignature() throws {
        let expectedRLPEncoded = "0x31f9016d038505d21dba00830dbba094d3e7cbbba40c98e05d972438b11ff9374d71654a8094553b11f36cd1ebcbf74c920dc51cd8a1648cb98ab844a9059cbb000000000000000000000000fc9fb77a8407e4ac10e6d5f96574debc844d0d5b00000000000000000000000000000000000000000000000000000002540be400f8d5f845820fe9a07531ee2314700f1d4f45983cfd9f865cd7c7d90341c745f7371073f407d48acfa03ea07fc14ccd89da897dbfbe10ad04fe8c74ee3a3f3cadf1c5697a8f669bbd71f845820feaa0390e818cdd138b4c698082c52c330589489af0ba169f5c8685247c53abd08831a0784755dd4bc6c0a4b8e7f32f84c9d22e4b5ed04ddb43e9dfc35ee9083db474a3f845820feaa0a94395fb25f06759e101fb159f7a2989b08c8912564b74d0c64078d964747f18a003c4574aa95af372c69accb57faa8e713ca180d3af85fa690201d33bf2046390940000000000000000000000000000000000000000c4c3018080"
        
        let expectedSignature = [
            SignatureData(
                    "0x0fe9",
                    "0x7531ee2314700f1d4f45983cfd9f865cd7c7d90341c745f7371073f407d48acf",
                    "0x3ea07fc14ccd89da897dbfbe10ad04fe8c74ee3a3f3cadf1c5697a8f669bbd71"
            ),
            SignatureData(
                    "0x0fea",
                    "0x390e818cdd138b4c698082c52c330589489af0ba169f5c8685247c53abd08831",
                    "0x784755dd4bc6c0a4b8e7f32f84c9d22e4b5ed04ddb43e9dfc35ee9083db474a3"
            ),
            SignatureData(
                    "0x0fea",
                    "0xa94395fb25f06759e101fb159f7a2989b08c8912564b74d0c64078d964747f18",
                    "0x03c4574aa95af372c69accb57faa8e713ca180d3af85fa690201d33bf2046390"
            )
        ]
        
        let rlpEncodedString = [
            "0x31f8cb038505d21dba00830dbba094d3e7cbbba40c98e05d972438b11ff9374d71654a8094553b11f36cd1ebcbf74c920dc51cd8a1648cb98ab844a9059cbb000000000000000000000000fc9fb77a8407e4ac10e6d5f96574debc844d0d5b00000000000000000000000000000000000000000000000000000002540be400f847f845820feaa0390e818cdd138b4c698082c52c330589489af0ba169f5c8685247c53abd08831a0784755dd4bc6c0a4b8e7f32f84c9d22e4b5ed04ddb43e9dfc35ee9083db474a380c4c3018080",
            "0x31f8cb038505d21dba00830dbba094d3e7cbbba40c98e05d972438b11ff9374d71654a8094553b11f36cd1ebcbf74c920dc51cd8a1648cb98ab844a9059cbb000000000000000000000000fc9fb77a8407e4ac10e6d5f96574debc844d0d5b00000000000000000000000000000000000000000000000000000002540be400f847f845820feaa0a94395fb25f06759e101fb159f7a2989b08c8912564b74d0c64078d964747f18a003c4574aa95af372c69accb57faa8e713ca180d3af85fa690201d33bf204639080c4c3018080"
        ]
        
        let senderSignatureData = SignatureData(
            "0x0fe9",
            "0x7531ee2314700f1d4f45983cfd9f865cd7c7d90341c745f7371073f407d48acf",
            "0x3ea07fc14ccd89da897dbfbe10ad04fe8c74ee3a3f3cadf1c5697a8f669bbd71"
        )
        
        mTxObj = try FeeDelegatedSmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setTo(to)
            .setValue(value)
            .setInput(input)
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
        let expectedRLPEncoded = "0x31f8df038505d21dba00830dbba094d3e7cbbba40c98e05d972438b11ff9374d71654a8094553b11f36cd1ebcbf74c920dc51cd8a1648cb98ab844a9059cbb000000000000000000000000fc9fb77a8407e4ac10e6d5f96574debc844d0d5b00000000000000000000000000000000000000000000000000000002540be400c4c301808094fc9fb77a8407e4ac10e6d5f96574debc844d0d5bf847f845820feaa08d9d977567a1903deb82d67525beaa23842ebfe8ae7dad04c0d161a9a2451573a07e280f122aaf89e6379e95d1499c2d536d7ac37b77fa8980b5f083d153f2fb5b"
        
        let expectedSignature = SignatureData(
            "0x0fea",
            "0x8d9d977567a1903deb82d67525beaa23842ebfe8ae7dad04c0d161a9a2451573",
            "0x7e280f122aaf89e6379e95d1499c2d536d7ac37b77fa8980b5f083d153f2fb5b"
        )
        
        let rlpEncoded = "0x31f8df038505d21dba00830dbba094d3e7cbbba40c98e05d972438b11ff9374d71654a8094553b11f36cd1ebcbf74c920dc51cd8a1648cb98ab844a9059cbb000000000000000000000000fc9fb77a8407e4ac10e6d5f96574debc844d0d5b00000000000000000000000000000000000000000000000000000002540be400c4c301808094fc9fb77a8407e4ac10e6d5f96574debc844d0d5bf847f845820feaa08d9d977567a1903deb82d67525beaa23842ebfe8ae7dad04c0d161a9a2451573a07e280f122aaf89e6379e95d1499c2d536d7ac37b77fa8980b5f083d153f2fb5b"
        
        mTxObj = try FeeDelegatedSmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setTo(to)
            .setValue(value)
            .setInput(input)
            .setChainId(chainID)
            .build()
        
        let combined = try mTxObj!.combineSignedRawTransactions([rlpEncoded])
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature, mTxObj?.feePayerSignatures[0])
    }
    
    public func test_combineSignature_multipleFeePayerSignature() throws {
        let expectedRLPEncoded = "0x31f9016d038505d21dba00830dbba094d3e7cbbba40c98e05d972438b11ff9374d71654a8094553b11f36cd1ebcbf74c920dc51cd8a1648cb98ab844a9059cbb000000000000000000000000fc9fb77a8407e4ac10e6d5f96574debc844d0d5b00000000000000000000000000000000000000000000000000000002540be400c4c301808094fc9fb77a8407e4ac10e6d5f96574debc844d0d5bf8d5f845820feaa08d9d977567a1903deb82d67525beaa23842ebfe8ae7dad04c0d161a9a2451573a07e280f122aaf89e6379e95d1499c2d536d7ac37b77fa8980b5f083d153f2fb5bf845820fe9a08ffc31dc605d1d93b62e5dc5d72d62efe6994235e370feffc2f4366cf5f68a69a03910e05d112c137482ddb5740062dfcc6ce1556f081f22efb9b5f343adf45638f845820feaa025f9886ca65ae770ac69e155978600c6dfe9f2f3f06c692bbae5175f5eb4d7e1a020d0b91badffe5074dd66bdd558ddd2be0ec629e83e6616cf381bb692d41bbe5"
        
        let expectedSignature = [
            SignatureData(
                    "0x0fea",
                    "0x8d9d977567a1903deb82d67525beaa23842ebfe8ae7dad04c0d161a9a2451573",
                    "0x7e280f122aaf89e6379e95d1499c2d536d7ac37b77fa8980b5f083d153f2fb5b"
            ),
            SignatureData(
                    "0x0fe9",
                    "0x8ffc31dc605d1d93b62e5dc5d72d62efe6994235e370feffc2f4366cf5f68a69",
                    "0x3910e05d112c137482ddb5740062dfcc6ce1556f081f22efb9b5f343adf45638"
            ),
            SignatureData(
                    "0x0fea",
                    "0x25f9886ca65ae770ac69e155978600c6dfe9f2f3f06c692bbae5175f5eb4d7e1",
                    "0x20d0b91badffe5074dd66bdd558ddd2be0ec629e83e6616cf381bb692d41bbe5"
            )
        ]
        
        let rlpEncodedString = [
            "0x31f8df038505d21dba00830dbba094d3e7cbbba40c98e05d972438b11ff9374d71654a8094553b11f36cd1ebcbf74c920dc51cd8a1648cb98ab844a9059cbb000000000000000000000000fc9fb77a8407e4ac10e6d5f96574debc844d0d5b00000000000000000000000000000000000000000000000000000002540be400c4c301808094fc9fb77a8407e4ac10e6d5f96574debc844d0d5bf847f845820fe9a08ffc31dc605d1d93b62e5dc5d72d62efe6994235e370feffc2f4366cf5f68a69a03910e05d112c137482ddb5740062dfcc6ce1556f081f22efb9b5f343adf45638",
            "0x31f8df038505d21dba00830dbba094d3e7cbbba40c98e05d972438b11ff9374d71654a8094553b11f36cd1ebcbf74c920dc51cd8a1648cb98ab844a9059cbb000000000000000000000000fc9fb77a8407e4ac10e6d5f96574debc844d0d5b00000000000000000000000000000000000000000000000000000002540be400c4c301808094fc9fb77a8407e4ac10e6d5f96574debc844d0d5bf847f845820feaa025f9886ca65ae770ac69e155978600c6dfe9f2f3f06c692bbae5175f5eb4d7e1a020d0b91badffe5074dd66bdd558ddd2be0ec629e83e6616cf381bb692d41bbe5",
        ]
        
        let feePayer = "0xfc9fb77a8407e4ac10e6d5f96574debc844d0d5b"
        let feePayerSignatureData = SignatureData(
            "0x0fea",
            "0x8d9d977567a1903deb82d67525beaa23842ebfe8ae7dad04c0d161a9a2451573",
            "0x7e280f122aaf89e6379e95d1499c2d536d7ac37b77fa8980b5f083d153f2fb5b"
        )
        
        mTxObj = try FeeDelegatedSmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setTo(to)
            .setValue(value)
            .setInput(input)
            .setChainId(chainID)
            .setFeePayer(feePayer)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        let combined = try mTxObj!.combineSignedRawTransactions(rlpEncodedString)
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature[0], mTxObj?.feePayerSignatures[0])
        XCTAssertEqual(expectedSignature[1], mTxObj?.feePayerSignatures[1])
        XCTAssertEqual(expectedSignature[2], mTxObj?.feePayerSignatures[2])
    }
    
    public func test_multipleSignature_senderSignatureData_feePayerSignature() throws {
        mTxObj = try FeeDelegatedSmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .build()
        
        let rlpEncodedString = "0x31f90159038505d21dba00830dbba094d3e7cbbba40c98e05d972438b11ff9374d71654a8094553b11f36cd1ebcbf74c920dc51cd8a1648cb98ab844a9059cbb000000000000000000000000fc9fb77a8407e4ac10e6d5f96574debc844d0d5b00000000000000000000000000000000000000000000000000000002540be400f8d5f845820fe9a07531ee2314700f1d4f45983cfd9f865cd7c7d90341c745f7371073f407d48acfa03ea07fc14ccd89da897dbfbe10ad04fe8c74ee3a3f3cadf1c5697a8f669bbd71f845820feaa0390e818cdd138b4c698082c52c330589489af0ba169f5c8685247c53abd08831a0784755dd4bc6c0a4b8e7f32f84c9d22e4b5ed04ddb43e9dfc35ee9083db474a3f845820feaa0a94395fb25f06759e101fb159f7a2989b08c8912564b74d0c64078d964747f18a003c4574aa95af372c69accb57faa8e713ca180d3af85fa690201d33bf204639080c4c3018080"
        
        let expectedSignature = [
            SignatureData(
                    "0x0fe9",
                    "0x7531ee2314700f1d4f45983cfd9f865cd7c7d90341c745f7371073f407d48acf",
                    "0x3ea07fc14ccd89da897dbfbe10ad04fe8c74ee3a3f3cadf1c5697a8f669bbd71"
            ),
            SignatureData(
                    "0x0fea",
                    "0x390e818cdd138b4c698082c52c330589489af0ba169f5c8685247c53abd08831",
                    "0x784755dd4bc6c0a4b8e7f32f84c9d22e4b5ed04ddb43e9dfc35ee9083db474a3"
            ),
            SignatureData(
                    "0x0fea",
                    "0xa94395fb25f06759e101fb159f7a2989b08c8912564b74d0c64078d964747f18",
                    "0x03c4574aa95af372c69accb57faa8e713ca180d3af85fa690201d33bf2046390"
            )
        ]
        
        _ = try mTxObj!.combineSignedRawTransactions([rlpEncodedString])
        
        let rlpEncodedStringsWithFeePayerSignatures = "0x31f9016d038505d21dba00830dbba094d3e7cbbba40c98e05d972438b11ff9374d71654a8094553b11f36cd1ebcbf74c920dc51cd8a1648cb98ab844a9059cbb000000000000000000000000fc9fb77a8407e4ac10e6d5f96574debc844d0d5b00000000000000000000000000000000000000000000000000000002540be400c4c301808094fc9fb77a8407e4ac10e6d5f96574debc844d0d5bf8d5f845820feaa08d9d977567a1903deb82d67525beaa23842ebfe8ae7dad04c0d161a9a2451573a07e280f122aaf89e6379e95d1499c2d536d7ac37b77fa8980b5f083d153f2fb5bf845820fe9a08ffc31dc605d1d93b62e5dc5d72d62efe6994235e370feffc2f4366cf5f68a69a03910e05d112c137482ddb5740062dfcc6ce1556f081f22efb9b5f343adf45638f845820feaa025f9886ca65ae770ac69e155978600c6dfe9f2f3f06c692bbae5175f5eb4d7e1a020d0b91badffe5074dd66bdd558ddd2be0ec629e83e6616cf381bb692d41bbe5"
        
        let expectedFeePayerSignatures = [
            SignatureData(
                    "0x0fea",
                    "0x8d9d977567a1903deb82d67525beaa23842ebfe8ae7dad04c0d161a9a2451573",
                    "0x7e280f122aaf89e6379e95d1499c2d536d7ac37b77fa8980b5f083d153f2fb5b"
            ),
            SignatureData(
                    "0x0fe9",
                    "0x8ffc31dc605d1d93b62e5dc5d72d62efe6994235e370feffc2f4366cf5f68a69",
                    "0x3910e05d112c137482ddb5740062dfcc6ce1556f081f22efb9b5f343adf45638"
            ),
            SignatureData(
                    "0x0fea",
                    "0x25f9886ca65ae770ac69e155978600c6dfe9f2f3f06c692bbae5175f5eb4d7e1",
                    "0x20d0b91badffe5074dd66bdd558ddd2be0ec629e83e6616cf381bb692d41bbe5"
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
        mTxObj = try FeeDelegatedSmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .build()
        
        let rlpEncoded = "0x31f9016d038505d21dba00830dbba094d3e7cbbba40c98e05d972438b11ff9374d71654a8094553b11f36cd1ebcbf74c920dc51cd8a1648cb98ab844a9059cbb000000000000000000000000fc9fb77a8407e4ac10e6d5f96574debc844d0d5b00000000000000000000000000000000000000000000000000000002540be400c4c301808094fc9fb77a8407e4ac10e6d5f96574debc844d0d5bf8d5f845820feaa08d9d977567a1903deb82d67525beaa23842ebfe8ae7dad04c0d161a9a2451573a07e280f122aaf89e6379e95d1499c2d536d7ac37b77fa8980b5f083d153f2fb5bf845820fe9a08ffc31dc605d1d93b62e5dc5d72d62efe6994235e370feffc2f4366cf5f68a69a03910e05d112c137482ddb5740062dfcc6ce1556f081f22efb9b5f343adf45638f845820feaa025f9886ca65ae770ac69e155978600c6dfe9f2f3f06c692bbae5175f5eb4d7e1a020d0b91badffe5074dd66bdd558ddd2be0ec629e83e6616cf381bb692d41bbe5"
        
        XCTAssertThrowsError(try mTxObj!.combineSignedRawTransactions([rlpEncoded])) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("Transactions containing different information cannot be combined."))
        }
    }
}

class FeeDelegatedSmartContractExecutionTest_getRawTransactionTest: XCTestCase {
    let privateKey = FeeDelegatedSmartContractExecutionTest.senderPrivateKey
    let feePayerPrivateKey = FeeDelegatedSmartContractExecutionTest.feePayerPrivateKey
        
    let from = FeeDelegatedSmartContractExecutionTest.from
    let account = FeeDelegatedSmartContractExecutionTest.account
    let to = FeeDelegatedSmartContractExecutionTest.to
    let gas = FeeDelegatedSmartContractExecutionTest.gas
    let nonce = FeeDelegatedSmartContractExecutionTest.nonce
    let gasPrice = FeeDelegatedSmartContractExecutionTest.gasPrice
    let chainID = FeeDelegatedSmartContractExecutionTest.chainID
    let value = FeeDelegatedSmartContractExecutionTest.value
    let input = FeeDelegatedSmartContractExecutionTest.input
    let humanReadable = FeeDelegatedSmartContractExecutionTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractExecutionTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractExecutionTest.senderSignatureData
    let feePayer = FeeDelegatedSmartContractExecutionTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractExecutionTest.feePayerSignatureData
    
    let expectedRLPEncoding = FeeDelegatedSmartContractExecutionTest.expectedRLPEncoding
    
    public func test_getRawTransaction() throws {
        let txObj = try FeeDelegatedSmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()

        XCTAssertEqual(expectedRLPEncoding, try txObj.getRawTransaction())
    }
}

class FeeDelegatedSmartContractExecutionTest_getTransactionHashTest: XCTestCase {
    var mTxObj: FeeDelegatedSmartContractExecution?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = FeeDelegatedSmartContractExecutionTest.senderPrivateKey
    let feePayerPrivateKey = FeeDelegatedSmartContractExecutionTest.feePayerPrivateKey
        
    let from = FeeDelegatedSmartContractExecutionTest.from
    let account = FeeDelegatedSmartContractExecutionTest.account
    let to = FeeDelegatedSmartContractExecutionTest.to
    let gas = FeeDelegatedSmartContractExecutionTest.gas
    let nonce = FeeDelegatedSmartContractExecutionTest.nonce
    let gasPrice = FeeDelegatedSmartContractExecutionTest.gasPrice
    let chainID = FeeDelegatedSmartContractExecutionTest.chainID
    let value = FeeDelegatedSmartContractExecutionTest.value
    let input = FeeDelegatedSmartContractExecutionTest.input
    let humanReadable = FeeDelegatedSmartContractExecutionTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractExecutionTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractExecutionTest.senderSignatureData
    let feePayer = FeeDelegatedSmartContractExecutionTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractExecutionTest.feePayerSignatureData
    
    let expectedRLPEncoding = FeeDelegatedSmartContractExecutionTest.expectedRLPEncoding
    let expectedTransactionHash = FeeDelegatedSmartContractExecutionTest.expectedTransactionHash
            
    public func test_getTransactionHash() throws {
        let txObj = try FeeDelegatedSmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()

        XCTAssertEqual(expectedTransactionHash, try txObj.getTransactionHash())
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try FeeDelegatedSmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getTransactionHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_gasPrice() throws {
        let gasPrice = ""
        
        mTxObj = try FeeDelegatedSmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getTransactionHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class FeeDelegatedSmartContractExecutionTest_getSenderTxHashTest: XCTestCase {
    var mTxObj: FeeDelegatedSmartContractExecution?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = FeeDelegatedSmartContractExecutionTest.senderPrivateKey
    let from = FeeDelegatedSmartContractExecutionTest.from
    let account = FeeDelegatedSmartContractExecutionTest.account
    let to = FeeDelegatedSmartContractExecutionTest.to
    let gas = FeeDelegatedSmartContractExecutionTest.gas
    let nonce = FeeDelegatedSmartContractExecutionTest.nonce
    let gasPrice = FeeDelegatedSmartContractExecutionTest.gasPrice
    let chainID = FeeDelegatedSmartContractExecutionTest.chainID
    let value = FeeDelegatedSmartContractExecutionTest.value
    let input = FeeDelegatedSmartContractExecutionTest.input
    let humanReadable = FeeDelegatedSmartContractExecutionTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractExecutionTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractExecutionTest.senderSignatureData
    let feePayer = FeeDelegatedSmartContractExecutionTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractExecutionTest.feePayerSignatureData
    let expectedRLPEncoding = FeeDelegatedSmartContractExecutionTest.expectedRLPEncoding
    let expectedTransactionHash = FeeDelegatedSmartContractExecutionTest.expectedTransactionHash
    let expectedSenderTransactionHash = FeeDelegatedSmartContractExecutionTest.expectedSenderTransactionHash
            
    public func test_getRLPEncodingForSignature() throws {
        mTxObj = try FeeDelegatedSmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertEqual(expectedSenderTransactionHash, try mTxObj!.getSenderTxHash())
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try FeeDelegatedSmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getSenderTxHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_gasPrice() throws {
        let gasPrice = ""
        
        mTxObj = try FeeDelegatedSmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getSenderTxHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class FeeDelegatedSmartContractExecutionTest_getRLPEncodingForFeePayerSignatureTest: XCTestCase {
    var mTxObj: FeeDelegatedSmartContractExecution?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = FeeDelegatedSmartContractExecutionTest.senderPrivateKey
    let from = FeeDelegatedSmartContractExecutionTest.from
    let account = FeeDelegatedSmartContractExecutionTest.account
    let to = FeeDelegatedSmartContractExecutionTest.to
    let gas = FeeDelegatedSmartContractExecutionTest.gas
    let nonce = FeeDelegatedSmartContractExecutionTest.nonce
    let gasPrice = FeeDelegatedSmartContractExecutionTest.gasPrice
    let chainID = FeeDelegatedSmartContractExecutionTest.chainID
    let value = FeeDelegatedSmartContractExecutionTest.value
    let input = FeeDelegatedSmartContractExecutionTest.input
    let humanReadable = FeeDelegatedSmartContractExecutionTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractExecutionTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractExecutionTest.senderSignatureData
    let feePayer = FeeDelegatedSmartContractExecutionTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractExecutionTest.feePayerSignatureData
    let expectedRLPEncoding = FeeDelegatedSmartContractExecutionTest.expectedRLPEncoding
    let expectedTransactionHash = FeeDelegatedSmartContractExecutionTest.expectedTransactionHash
    let expectedSenderTransactionHash = FeeDelegatedSmartContractExecutionTest.expectedSenderTransactionHash
    let expectedRLPEncodingForFeePayerSigning = FeeDelegatedSmartContractExecutionTest.expectedRLPEncodingForFeePayerSigning
            
    public func test_getRLPEncodingForSignature() throws {
        mTxObj = try FeeDelegatedSmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertEqual(expectedRLPEncodingForFeePayerSigning, try mTxObj!.getRLPEncodingForFeePayerSignature())
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try FeeDelegatedSmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_gasPrice() throws {
        let gasPrice = ""
        
        mTxObj = try FeeDelegatedSmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_chainID() throws {
        let chainID = ""
        
        mTxObj = try FeeDelegatedSmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("chainId is undefined. Define chainId in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

