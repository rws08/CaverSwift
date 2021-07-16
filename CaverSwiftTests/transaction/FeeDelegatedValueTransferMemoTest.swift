//
//  FeeDelegatedValueTransferMemoTest.swift
//  CaverSwiftTests
//
//  Created by won on 2021/07/16.
//

import XCTest
@testable import CaverSwift

class FeeDelegatedValueTransferMemoTest: XCTestCase {
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
    static let input = "0x68656c6c6f"
    static let humanReadable = false
    static let codeFormat = CodeFormat.EVM.hexa

    static let senderSignatureData = SignatureData(
        "0x26",
        "0x64e213aef0167fbd853f8f9989ef5d8b912a77457395ccf13d7f37009edd5c5b",
        "0x5d0c2e55e4d8734fe2516ed56ac628b74c0eb02aa3b6eda51e1e25a1396093e1"
    )
    static let feePayer = "0x5A0043070275d9f6054307Ee7348bD660849D90f"
    static let feePayerSignatureData = SignatureData(
        "0x26",
        "0x87390ac14d3c34440b6ddb7b190d3ebde1a07d9a556e5a82ce7e501f24a060f9",
        "0x37badbcb12cda1ed67b12b1831683a08a3adadee2ea760a07a46bdbb856fea44"
   )

    static let expectedRLPEncoding = "0x11f8dc8204d219830f4240947b65b75d204abed71587c9e519a89277766ee1d00a94a94f5374fce5edbc8e2a8697c15331677e6ebf0b8568656c6c6ff845f84326a064e213aef0167fbd853f8f9989ef5d8b912a77457395ccf13d7f37009edd5c5ba05d0c2e55e4d8734fe2516ed56ac628b74c0eb02aa3b6eda51e1e25a1396093e1945a0043070275d9f6054307ee7348bd660849d90ff845f84326a087390ac14d3c34440b6ddb7b190d3ebde1a07d9a556e5a82ce7e501f24a060f9a037badbcb12cda1ed67b12b1831683a08a3adadee2ea760a07a46bdbb856fea44"
    static let expectedTransactionHash = "0x8f68882f6192a53ba470aeca1e83ed9b9e519906a91256724b284dee778b21c9"
    static let expectedSenderTransactionHash = "0xfffaa2b38d4e684ea70a89c78fc7b2659000d130c76ad721d68175cbfc77c550"
    static let expectedRLPEncodingForFeePayerSigning = "0xf856b83cf83a118204d219830f4240947b65b75d204abed71587c9e519a89277766ee1d00a94a94f5374fce5edbc8e2a8697c15331677e6ebf0b8568656c6c6f945a0043070275d9f6054307ee7348bd660849d90f018080"
        
    public static func generateRoleBaseKeyring(_ numArr: [Int], _ address: String) throws -> AbstractKeyring {
        let keyArr = KeyringFactory.generateRoleBasedKeys(numArr, "entropy")
        return try KeyringFactory.createWithRoleBasedKey(address, keyArr)
    }
}

class FeeDelegatedValueTransferMemoTest_createInstanceBuilder: XCTestCase {
    let from = FeeDelegatedValueTransferMemoTest.from
    let account = FeeDelegatedValueTransferMemoTest.account
    let to = FeeDelegatedValueTransferMemoTest.to
    let gas = FeeDelegatedValueTransferMemoTest.gas
    let nonce = FeeDelegatedValueTransferMemoTest.nonce
    let gasPrice = FeeDelegatedValueTransferMemoTest.gasPrice
    let chainID = FeeDelegatedValueTransferMemoTest.chainID
    let value = FeeDelegatedValueTransferMemoTest.value
    let input = FeeDelegatedValueTransferMemoTest.input
    let humanReadable = FeeDelegatedValueTransferMemoTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferMemoTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferMemoTest.senderSignatureData
    let feePayer = FeeDelegatedValueTransferMemoTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferMemoTest.feePayerSignatureData
        
    public func test_BuilderTest() throws {
        let txObj = try FeeDelegatedValueTransferMemo.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertNotNil(txObj)
    }
    
    public func test_BuilderWithRPCTest() throws {
        let txObj = try FeeDelegatedValueTransferMemo.Builder()
            .setKlaytnCall(FeeDelegatedValueTransferMemoTest.caver.rpc.klay)
            .setGas(gas)
            .setTo(to)
            .setValue(value)
            .setFrom(from)
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
        let txObj = try FeeDelegatedValueTransferMemo.Builder()
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
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemo.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
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
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemo.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
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
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemo.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setInput(input)
                                .setFeePayer(feePayer)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(to)"))
        }
    }
    
    public func test_throwException_missingTo() throws {
        let to = ""
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemo.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setInput(input)
                                .setFeePayer(feePayer)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("to is missing."))
        }
    }
    
    public func test_throwException_invalidValue() throws {
        let value = "invalid value"
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemo.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
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
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemo.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
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
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemo.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
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
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemo.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setInput(input)
                                .setFeePayer(feePayer)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("gas is missing."))
        }
    }
    
    public func test_throwException_setFeePayerSignatures_missingFeePayer() throws {
        let feePayer = ""
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemo.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setInput(input)
                                .setFeePayer(feePayer)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("feePayer is missing: feePayer must be defined with feePayerSignatures."))
        }
    }
}

class FeeDelegatedValueTransferMemoTest_createInstance: XCTestCase {
    let from = FeeDelegatedValueTransferMemoTest.from
    let account = FeeDelegatedValueTransferMemoTest.account
    let to = FeeDelegatedValueTransferMemoTest.to
    let gas = FeeDelegatedValueTransferMemoTest.gas
    let nonce = FeeDelegatedValueTransferMemoTest.nonce
    let gasPrice = FeeDelegatedValueTransferMemoTest.gasPrice
    let chainID = FeeDelegatedValueTransferMemoTest.chainID
    let value = FeeDelegatedValueTransferMemoTest.value
    let input = FeeDelegatedValueTransferMemoTest.input
    let humanReadable = FeeDelegatedValueTransferMemoTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferMemoTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferMemoTest.senderSignatureData
    let feePayer = FeeDelegatedValueTransferMemoTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferMemoTest.feePayerSignatureData
    
    public func test_createInstance() throws {
        let txObj = try FeeDelegatedValueTransferMemo(
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
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemo(
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
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemo(
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
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemo(
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
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemo(
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
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemo(
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
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemo(
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
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemo(
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
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemo(
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
    
    public func throwException_setFeePayerSignatures_missingFeePayer() throws {
        let feePayer = ""
        XCTAssertThrowsError(try FeeDelegatedValueTransferMemo(
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
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("feePayer is missing: feePayer must be defined with feePayerSignatures."))
        }
    }
}

class FeeDelegatedValueTransferMemoTest_getRLPEncodingTest: XCTestCase {
    let from = FeeDelegatedValueTransferMemoTest.from
    let account = FeeDelegatedValueTransferMemoTest.account
    let to = FeeDelegatedValueTransferMemoTest.to
    let gas = FeeDelegatedValueTransferMemoTest.gas
    let nonce = FeeDelegatedValueTransferMemoTest.nonce
    let gasPrice = FeeDelegatedValueTransferMemoTest.gasPrice
    let chainID = FeeDelegatedValueTransferMemoTest.chainID
    let value = FeeDelegatedValueTransferMemoTest.value
    let input = FeeDelegatedValueTransferMemoTest.input
    let humanReadable = FeeDelegatedValueTransferMemoTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferMemoTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferMemoTest.senderSignatureData
    let feePayer = FeeDelegatedValueTransferMemoTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferMemoTest.feePayerSignatureData
    
    let expectedRLPEncoding = FeeDelegatedValueTransferMemoTest.expectedRLPEncoding
        
    public func test_getRLPEncoding() throws {
        let txObj = try FeeDelegatedValueTransferMemo.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertEqual(expectedRLPEncoding, try txObj.getRLPEncoding())
    }
    
    public func test_throwException_NoNonce() throws {
        let txObj = try FeeDelegatedValueTransferMemo.Builder()
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
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
        let txObj = try FeeDelegatedValueTransferMemo.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
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

class FeeDelegatedValueTransferMemoTest_signAsFeePayer_OneKeyTest: XCTestCase {
    var mTxObj: FeeDelegatedValueTransferMemo?
    var klaytnWalletKey: String?
    var keyring: AbstractKeyring?
    var feePayerAddress: String?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedValueTransferMemoTest.feePayerPrivateKey
        
    let from = FeeDelegatedValueTransferMemoTest.from
    let account = FeeDelegatedValueTransferMemoTest.account
    let to = FeeDelegatedValueTransferMemoTest.to
    let gas = FeeDelegatedValueTransferMemoTest.gas
    let nonce = FeeDelegatedValueTransferMemoTest.nonce
    let gasPrice = FeeDelegatedValueTransferMemoTest.gasPrice
    let chainID = FeeDelegatedValueTransferMemoTest.chainID
    let value = FeeDelegatedValueTransferMemoTest.value
    let input = FeeDelegatedValueTransferMemoTest.input
    let humanReadable = FeeDelegatedValueTransferMemoTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferMemoTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferMemoTest.senderSignatureData
    let feePayer = FeeDelegatedValueTransferMemoTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferMemoTest.feePayerSignatureData
    
    let expectedRLPEncoding = FeeDelegatedValueTransferMemoTest.expectedRLPEncoding
        
    override func setUpWithError() throws {
        keyring = try KeyringFactory.createWithSingleKey(feePayer, feePayerPrivateKey)
        klaytnWalletKey = try keyring?.getKlaytnWalletKey()
        
        mTxObj = try FeeDelegatedValueTransferMemo.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .build()
    }
    
    public func test_signAsFeePayer_String() throws {
        let expectedRLPEncoding = "0x11f8dc8204d219830f4240947b65b75d204abed71587c9e519a89277766ee1d00a94a94f5374fce5edbc8e2a8697c15331677e6ebf0b8568656c6c6ff845f84326a064e213aef0167fbd853f8f9989ef5d8b912a77457395ccf13d7f37009edd5c5ba05d0c2e55e4d8734fe2516ed56ac628b74c0eb02aa3b6eda51e1e25a1396093e19433f524631e573329a550296f595c820d6c65213ff845f84325a00a59dd9f258c326e1bbaf1ebb0899a269a78afd70976ca73df257acdcb339faba01935d1df1c174c012a723c7a03b33fffd987499755306d2266f00e888f80bd2c"
        
        let keyring = try KeyringFactory.createFromPrivateKey(feePayerPrivateKey)
        let feePayer = keyring.address
        
        mTxObj = try FeeDelegatedValueTransferMemo.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .build()
        
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

class FeeDelegatedValueTransferMemoTest_signAsFeePayer_AllKeyTest: XCTestCase {
    var mTxObj: FeeDelegatedValueTransferMemo?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedValueTransferMemoTest.feePayerPrivateKey
        
    let from = FeeDelegatedValueTransferMemoTest.from
    let account = FeeDelegatedValueTransferMemoTest.account
    let to = FeeDelegatedValueTransferMemoTest.to
    let gas = FeeDelegatedValueTransferMemoTest.gas
    let nonce = FeeDelegatedValueTransferMemoTest.nonce
    let gasPrice = FeeDelegatedValueTransferMemoTest.gasPrice
    let chainID = FeeDelegatedValueTransferMemoTest.chainID
    let value = FeeDelegatedValueTransferMemoTest.value
    let input = FeeDelegatedValueTransferMemoTest.input
    let humanReadable = FeeDelegatedValueTransferMemoTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferMemoTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferMemoTest.senderSignatureData
    var feePayer = FeeDelegatedValueTransferMemoTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferMemoTest.feePayerSignatureData
    
    let expectedRLPEncoding = FeeDelegatedValueTransferMemoTest.expectedRLPEncoding
        
    override func setUpWithError() throws {
        mTxObj = try FeeDelegatedValueTransferMemo.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
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

class FeeDelegatedValueTransferMemoTest_appendFeePayerSignaturesTest: XCTestCase {
    var mTxObj: FeeDelegatedValueTransferMemo?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = FeeDelegatedValueTransferMemoTest.senderPrivateKey
    let feePayerPrivateKey = FeeDelegatedValueTransferMemoTest.feePayerPrivateKey
        
    let from = FeeDelegatedValueTransferMemoTest.from
    let account = FeeDelegatedValueTransferMemoTest.account
    let to = FeeDelegatedValueTransferMemoTest.to
    let gas = FeeDelegatedValueTransferMemoTest.gas
    let nonce = FeeDelegatedValueTransferMemoTest.nonce
    let gasPrice = FeeDelegatedValueTransferMemoTest.gasPrice
    let chainID = FeeDelegatedValueTransferMemoTest.chainID
    let value = FeeDelegatedValueTransferMemoTest.value
    let input = FeeDelegatedValueTransferMemoTest.input
    let humanReadable = FeeDelegatedValueTransferMemoTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferMemoTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferMemoTest.senderSignatureData
    let feePayer = FeeDelegatedValueTransferMemoTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferMemoTest.feePayerSignatureData
    
    override func setUpWithError() throws {
        mTxObj = try FeeDelegatedValueTransferMemo.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
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
        mTxObj = try FeeDelegatedValueTransferMemo.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setSignatures(senderSignatureData)
            .setFeePayer(feePayer)
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
        
        mTxObj = try FeeDelegatedValueTransferMemo.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setSignatures(senderSignatureData)
            .setFeePayer(feePayer)
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
        
        mTxObj = try FeeDelegatedValueTransferMemo.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setSignatures(senderSignatureData)
            .setFeePayer(feePayer)
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

class FeeDelegatedValueTransferMemoTest_combineSignatureTest: XCTestCase {
    var mTxObj: FeeDelegatedValueTransferMemo?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = FeeDelegatedValueTransferMemoTest.senderPrivateKey
    let from = "0x1bc5339c6c55380d0da8aaa28e135164ecb86262"
    var account: Account?
    let to = "0x7b65b75d204abed71587c9e519a89277766ee1d0"
    let gas = "0xf4240"
    let nonce = "0x1"
    let gasPrice = "0x5d21dba00"
    let chainID = "0x7e3"
    let value = "0xa"
    let input = "0x68656c6c6f"
    let humanReadable = FeeDelegatedValueTransferMemoTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferMemoTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferMemoTest.senderSignatureData
    let feePayer = FeeDelegatedValueTransferMemoTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferMemoTest.feePayerSignatureData
    let expectedRLPEncoding = FeeDelegatedValueTransferMemoTest.expectedRLPEncoding
    
    override func setUpWithError() throws {
        mTxObj = try FeeDelegatedValueTransferMemo.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .build()
    }
    
    public func test_combineSignature() throws {
        let expectedRLPEncoded = "0x11f89f018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a941bc5339c6c55380d0da8aaa28e135164ecb862628568656c6c6ff847f845820feaa060a20eed201a2b28bc452b65c699083a6399aaeff2a7572c5c8cf54056254aeaa001586e5321f51ed56da5241d6cc8365bdcade89c4b08d2615bc21231f5e2c26e940000000000000000000000000000000000000000c4c3018080"
        
        let expectedSignature = SignatureData(
            "0x0fea",
            "0x60a20eed201a2b28bc452b65c699083a6399aaeff2a7572c5c8cf54056254aea",
            "0x01586e5321f51ed56da5241d6cc8365bdcade89c4b08d2615bc21231f5e2c26e"
        )
        
        let rlpEncoded = "0x11f89f018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a941bc5339c6c55380d0da8aaa28e135164ecb862628568656c6c6ff847f845820feaa060a20eed201a2b28bc452b65c699083a6399aaeff2a7572c5c8cf54056254aeaa001586e5321f51ed56da5241d6cc8365bdcade89c4b08d2615bc21231f5e2c26e940000000000000000000000000000000000000000c4c3018080"
        
        let combined = try mTxObj!.combineSignedRawTransactions([rlpEncoded])
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature, mTxObj?.signatures[0])
    }
    
    public func test_combine_multipleSignature() throws {
        let expectedRLPEncoded = "0x11f9012d018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a941bc5339c6c55380d0da8aaa28e135164ecb862628568656c6c6ff8d5f845820feaa060a20eed201a2b28bc452b65c699083a6399aaeff2a7572c5c8cf54056254aeaa001586e5321f51ed56da5241d6cc8365bdcade89c4b08d2615bc21231f5e2c26ef845820fe9a0b8f3ba052cd0ef34b683a3e8ad6f68f71a82d9416bf9732def4b66802967a055a07c241fa9b7d32b72fc8310e886c5b70de262457fd07711cbb2e17217d8c39b26f845820feaa06c301c61b6b8746f63baf57c477bd269ecdeb07d6200a719988bfcd0b7767bc1a016da23b63b4e54ffa16ce8668987e48a76b8e64ba7863359462efd1e8d9838a6940000000000000000000000000000000000000000c4c3018080"
        
        let expectedSignature = [
            SignatureData(
                    "0x0fea",
                    "0x60a20eed201a2b28bc452b65c699083a6399aaeff2a7572c5c8cf54056254aea",
                    "0x01586e5321f51ed56da5241d6cc8365bdcade89c4b08d2615bc21231f5e2c26e"
            ),
            SignatureData(
                    "0x0fe9",
                    "0xb8f3ba052cd0ef34b683a3e8ad6f68f71a82d9416bf9732def4b66802967a055",
                    "0x7c241fa9b7d32b72fc8310e886c5b70de262457fd07711cbb2e17217d8c39b26"
            ),
            SignatureData(
                    "0x0fea",
                    "0x6c301c61b6b8746f63baf57c477bd269ecdeb07d6200a719988bfcd0b7767bc1",
                    "0x16da23b63b4e54ffa16ce8668987e48a76b8e64ba7863359462efd1e8d9838a6"
            )
        ]
        
        let rlpEncodedString = [
            "0x11f88b018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a941bc5339c6c55380d0da8aaa28e135164ecb862628568656c6c6ff847f845820fe9a0b8f3ba052cd0ef34b683a3e8ad6f68f71a82d9416bf9732def4b66802967a055a07c241fa9b7d32b72fc8310e886c5b70de262457fd07711cbb2e17217d8c39b2680c4c3018080",
            "0x11f88b018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a941bc5339c6c55380d0da8aaa28e135164ecb862628568656c6c6ff847f845820feaa06c301c61b6b8746f63baf57c477bd269ecdeb07d6200a719988bfcd0b7767bc1a016da23b63b4e54ffa16ce8668987e48a76b8e64ba7863359462efd1e8d9838a680c4c3018080"
        ]
        
        let senderSignatureData = SignatureData(
            "0x0fea",
            "0x60a20eed201a2b28bc452b65c699083a6399aaeff2a7572c5c8cf54056254aea",
            "0x01586e5321f51ed56da5241d6cc8365bdcade89c4b08d2615bc21231f5e2c26e"
        )
        
        mTxObj = try FeeDelegatedValueTransferMemo.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setSignatures(senderSignatureData)
            .build()
        
        let combined = try mTxObj!.combineSignedRawTransactions(rlpEncodedString)
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature[0], mTxObj?.signatures[0])
        XCTAssertEqual(expectedSignature[1], mTxObj?.signatures[1])
        XCTAssertEqual(expectedSignature[2], mTxObj?.signatures[2])
    }
    
    public func test_combineSignature_feePayerSignature() throws {
        let expectedRLPEncoded = "0x11f89f018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a941bc5339c6c55380d0da8aaa28e135164ecb862628568656c6c6fc4c3018080948d2f6e4986bc55e2d50611149e5725999a763d7cf847f845820feaa0779d20a7958d3131e5ef6a423abb2337e8f120bd0798c47227aee51c70d23c06a07d3c36d5a33cb18e8fec7d1e1f2cfd9a0ec932adee9ad9a090fcd28fafd44392"
        
        let expectedSignature = SignatureData(
            "0x0fea",
            "0x779d20a7958d3131e5ef6a423abb2337e8f120bd0798c47227aee51c70d23c06",
            "0x7d3c36d5a33cb18e8fec7d1e1f2cfd9a0ec932adee9ad9a090fcd28fafd44392"
        )
        
        let rlpEncoded = "0x11f89f018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a941bc5339c6c55380d0da8aaa28e135164ecb862628568656c6c6fc4c3018080948d2f6e4986bc55e2d50611149e5725999a763d7cf847f845820feaa0779d20a7958d3131e5ef6a423abb2337e8f120bd0798c47227aee51c70d23c06a07d3c36d5a33cb18e8fec7d1e1f2cfd9a0ec932adee9ad9a090fcd28fafd44392"
        
        let feePayer = "0x8d2f6e4986bc55e2d50611149e5725999a763d7c"
        
        mTxObj = try FeeDelegatedValueTransferMemo.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId("0x1")
            .setValue(value)
            .setInput(input)
            .setFrom(from)
            .setFeePayer(feePayer)
            .build()
        
        let combined = try mTxObj!.combineSignedRawTransactions([rlpEncoded])
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature, mTxObj?.feePayerSignatures[0])
    }
    
    public func test_combineSignature_multipleFeePayerSignature() throws {
        let expectedRLPEncoded = "0x11f9012d018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a941bc5339c6c55380d0da8aaa28e135164ecb862628568656c6c6fc4c3018080948d2f6e4986bc55e2d50611149e5725999a763d7cf8d5f845820feaa0779d20a7958d3131e5ef6a423abb2337e8f120bd0798c47227aee51c70d23c06a07d3c36d5a33cb18e8fec7d1e1f2cfd9a0ec932adee9ad9a090fcd28fafd44392f845820fe9a0de14998f4aba6474b55b84e9a236daf159252b460915cea204a4361cf99c9dc9a0743a40d63646defba13c70581d85000836155dddb30bc8024c62dad76981abecf845820fe9a034fa68120ce57d201f0c859308d32d74835e7969555960c4041a466c9e2f8788a05a996a8c67347f0eba83cd6b38fe030aff2e8356e4b5ec2af85549f040014e3d"
        
        let expectedSignature = [
            SignatureData(
                    "0x0fea",
                    "0x779d20a7958d3131e5ef6a423abb2337e8f120bd0798c47227aee51c70d23c06",
                    "0x7d3c36d5a33cb18e8fec7d1e1f2cfd9a0ec932adee9ad9a090fcd28fafd44392"
            ),
            SignatureData(
                    "0x0fe9",
                    "0xde14998f4aba6474b55b84e9a236daf159252b460915cea204a4361cf99c9dc9",
                    "0x743a40d63646defba13c70581d85000836155dddb30bc8024c62dad76981abec"
            ),
            SignatureData(
                    "0x0fe9",
                    "0x34fa68120ce57d201f0c859308d32d74835e7969555960c4041a466c9e2f8788",
                    "0x5a996a8c67347f0eba83cd6b38fe030aff2e8356e4b5ec2af85549f040014e3d"
            )
        ]
        
        let rlpEncodedString = [
            "0x11f89f018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a941bc5339c6c55380d0da8aaa28e135164ecb862628568656c6c6fc4c3018080948d2f6e4986bc55e2d50611149e5725999a763d7cf847f845820fe9a0de14998f4aba6474b55b84e9a236daf159252b460915cea204a4361cf99c9dc9a0743a40d63646defba13c70581d85000836155dddb30bc8024c62dad76981abec",
            "0x11f89f018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a941bc5339c6c55380d0da8aaa28e135164ecb862628568656c6c6fc4c3018080948d2f6e4986bc55e2d50611149e5725999a763d7cf847f845820fe9a034fa68120ce57d201f0c859308d32d74835e7969555960c4041a466c9e2f8788a05a996a8c67347f0eba83cd6b38fe030aff2e8356e4b5ec2af85549f040014e3d",
        ]
        
        let feePayer = "0x8d2f6e4986bc55e2d50611149e5725999a763d7c"
        let feePayerSignatureData = SignatureData(
            "0x0fea",
            "0x779d20a7958d3131e5ef6a423abb2337e8f120bd0798c47227aee51c70d23c06",
            "0x7d3c36d5a33cb18e8fec7d1e1f2cfd9a0ec932adee9ad9a090fcd28fafd44392"
        )
        
        mTxObj = try FeeDelegatedValueTransferMemo.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId("0x1")
            .setValue(value)
            .setInput(input)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        let combined = try mTxObj!.combineSignedRawTransactions(rlpEncodedString)
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature[0], mTxObj?.feePayerSignatures[0])
        XCTAssertEqual(expectedSignature[1], mTxObj?.feePayerSignatures[1])
        XCTAssertEqual(expectedSignature[2], mTxObj?.feePayerSignatures[2])
    }
    
    public func test_throwException_differentField() throws {
        let gas = "0x1000"
        mTxObj = try FeeDelegatedValueTransferMemo.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId("0x01")
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .build()
        
        let rlpEncoded = "0x09f899018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a9404bb86a1b16113ebe8f57071f839b002cbcbf7d0c4c301808094b85f01a3b0b6aaa2e487c9ed541e27b75b3eba95f847f845820feaa0d432bdce799828530d89d14b4406ccb0446852a51f13e365123eac9375d7e629a04f73deb5343ff7d587a5affb14196a79c522b9a67c7d895762c6758258ac247b"
        
        XCTAssertThrowsError(try mTxObj!.combineSignedRawTransactions([rlpEncoded])) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("Transactions containing different information cannot be combined."))
        }
    }
}

class FeeDelegatedValueTransferMemoTest_getRawTransactionTest: XCTestCase {
    let privateKey = FeeDelegatedValueTransferMemoTest.senderPrivateKey
    let feePayerPrivateKey = FeeDelegatedValueTransferMemoTest.feePayerPrivateKey
        
    let from = FeeDelegatedValueTransferMemoTest.from
    let account = FeeDelegatedValueTransferMemoTest.account
    let to = FeeDelegatedValueTransferMemoTest.to
    let gas = FeeDelegatedValueTransferMemoTest.gas
    let nonce = FeeDelegatedValueTransferMemoTest.nonce
    let gasPrice = FeeDelegatedValueTransferMemoTest.gasPrice
    let chainID = FeeDelegatedValueTransferMemoTest.chainID
    let value = FeeDelegatedValueTransferMemoTest.value
    let input = FeeDelegatedValueTransferMemoTest.input
    let humanReadable = FeeDelegatedValueTransferMemoTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferMemoTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferMemoTest.senderSignatureData
    let feePayer = FeeDelegatedValueTransferMemoTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferMemoTest.feePayerSignatureData
    
    let expectedRLPEncoding = FeeDelegatedValueTransferMemoTest.expectedRLPEncoding
    
    public func test_getRawTransaction() throws {
        let txObj = try FeeDelegatedValueTransferMemo.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setInput(input)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()

        XCTAssertEqual(expectedRLPEncoding, try txObj.getRawTransaction())
    }
}

class FeeDelegatedValueTransferMemoTest_getTransactionHashTest: XCTestCase {
    var mTxObj: FeeDelegatedValueTransferMemo?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = FeeDelegatedValueTransferMemoTest.senderPrivateKey
    let feePayerPrivateKey = FeeDelegatedValueTransferMemoTest.feePayerPrivateKey
        
    let from = FeeDelegatedValueTransferMemoTest.from
    let account = FeeDelegatedValueTransferMemoTest.account
    let to = FeeDelegatedValueTransferMemoTest.to
    let gas = FeeDelegatedValueTransferMemoTest.gas
    let nonce = FeeDelegatedValueTransferMemoTest.nonce
    let gasPrice = FeeDelegatedValueTransferMemoTest.gasPrice
    let chainID = FeeDelegatedValueTransferMemoTest.chainID
    let value = FeeDelegatedValueTransferMemoTest.value
    let input = FeeDelegatedValueTransferMemoTest.input
    let humanReadable = FeeDelegatedValueTransferMemoTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferMemoTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferMemoTest.senderSignatureData
    let feePayer = FeeDelegatedValueTransferMemoTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferMemoTest.feePayerSignatureData
    
    let expectedRLPEncoding = FeeDelegatedValueTransferMemoTest.expectedRLPEncoding
    let expectedTransactionHash = FeeDelegatedValueTransferMemoTest.expectedTransactionHash
            
    public func test_getTransactionHash() throws {
        let txObj = try FeeDelegatedValueTransferMemo.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setInput(input)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()

        XCTAssertEqual(expectedTransactionHash, try txObj.getTransactionHash())
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try FeeDelegatedValueTransferMemo.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setInput(input)
            .setFrom(from)
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
        
        mTxObj = try FeeDelegatedValueTransferMemo.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setInput(input)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getTransactionHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class FeeDelegatedValueTransferMemoTest_getSenderTxHashTest: XCTestCase {
    var mTxObj: FeeDelegatedValueTransferMemo?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = FeeDelegatedValueTransferMemoTest.senderPrivateKey
    let from = FeeDelegatedValueTransferMemoTest.from
    let account = FeeDelegatedValueTransferMemoTest.account
    let to = FeeDelegatedValueTransferMemoTest.to
    let gas = FeeDelegatedValueTransferMemoTest.gas
    let nonce = FeeDelegatedValueTransferMemoTest.nonce
    let gasPrice = FeeDelegatedValueTransferMemoTest.gasPrice
    let chainID = FeeDelegatedValueTransferMemoTest.chainID
    let value = FeeDelegatedValueTransferMemoTest.value
    let input = FeeDelegatedValueTransferMemoTest.input
    let humanReadable = FeeDelegatedValueTransferMemoTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferMemoTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferMemoTest.senderSignatureData
    let feePayer = FeeDelegatedValueTransferMemoTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferMemoTest.feePayerSignatureData
    let expectedRLPEncoding = FeeDelegatedValueTransferMemoTest.expectedRLPEncoding
    let expectedTransactionHash = FeeDelegatedValueTransferMemoTest.expectedTransactionHash
    let expectedSenderTransactionHash = FeeDelegatedValueTransferMemoTest.expectedSenderTransactionHash
            
    public func test_getRLPEncodingForSignature() throws {
        mTxObj = try FeeDelegatedValueTransferMemo.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setInput(input)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertEqual(expectedSenderTransactionHash, try mTxObj!.getSenderTxHash())
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try FeeDelegatedValueTransferMemo.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setInput(input)
            .setFrom(from)
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
        
        mTxObj = try FeeDelegatedValueTransferMemo.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setInput(input)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getSenderTxHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class FeeDelegatedValueTransferMemoTest_getRLPEncodingForFeePayerSignatureTest: XCTestCase {
    var mTxObj: FeeDelegatedValueTransferMemo?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = FeeDelegatedValueTransferMemoTest.senderPrivateKey
    let from = FeeDelegatedValueTransferMemoTest.from
    let account = FeeDelegatedValueTransferMemoTest.account
    let to = FeeDelegatedValueTransferMemoTest.to
    let gas = FeeDelegatedValueTransferMemoTest.gas
    let nonce = FeeDelegatedValueTransferMemoTest.nonce
    let gasPrice = FeeDelegatedValueTransferMemoTest.gasPrice
    let chainID = FeeDelegatedValueTransferMemoTest.chainID
    let value = FeeDelegatedValueTransferMemoTest.value
    let input = FeeDelegatedValueTransferMemoTest.input
    let humanReadable = FeeDelegatedValueTransferMemoTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferMemoTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferMemoTest.senderSignatureData
    let feePayer = FeeDelegatedValueTransferMemoTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferMemoTest.feePayerSignatureData
    let expectedRLPEncoding = FeeDelegatedValueTransferMemoTest.expectedRLPEncoding
    let expectedTransactionHash = FeeDelegatedValueTransferMemoTest.expectedTransactionHash
    let expectedSenderTransactionHash = FeeDelegatedValueTransferMemoTest.expectedSenderTransactionHash
    let expectedRLPEncodingForFeePayerSigning = FeeDelegatedValueTransferMemoTest.expectedRLPEncodingForFeePayerSigning
            
    public func test_getRLPEncodingForSignature() throws {
        mTxObj = try FeeDelegatedValueTransferMemo.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setInput(input)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertEqual(expectedRLPEncodingForFeePayerSigning, try mTxObj!.getRLPEncodingForFeePayerSignature())
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try FeeDelegatedValueTransferMemo.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setInput(input)
            .setFrom(from)
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
        
        mTxObj = try FeeDelegatedValueTransferMemo.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setInput(input)
            .setFrom(from)
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
        
        mTxObj = try FeeDelegatedValueTransferMemo.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setInput(input)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("chainId is undefined. Define chainId in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

