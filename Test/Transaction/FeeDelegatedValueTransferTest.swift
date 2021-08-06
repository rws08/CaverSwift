//
//  FeeDelegatedValueTransferTest.swift
//  CaverSwiftTests
//
//  Created by won on 2021/07/16.
//

import XCTest
@testable import CaverSwift

class FeeDelegatedValueTransferTest: XCTestCase {
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
        "0x25",
        "0x9f8e49e2ad84b0732984398749956e807e4b526c786af3c5f7416b293e638956",
        "0x6bf88342092f6ff9fabe31739b2ebfa1409707ce54a54693e91a6b9bb77df0e7"
    )
    static let feePayer = "0x5A0043070275d9f6054307Ee7348bD660849D90f"
    static let feePayerSignatureData = SignatureData(
        "0x26",
        "0xf45cf8d7f88c08e6b6ec0b3b562f34ca94283e4689021987abb6b0772ddfd80a",
        "0x298fe2c5aeabb6a518f4cbb5ff39631a5d88be505d3923374f65fdcf63c2955b"
    )

    static let expectedRLPEncoding = "0x09f8d68204d219830f4240947b65b75d204abed71587c9e519a89277766ee1d00a94a94f5374fce5edbc8e2a8697c15331677e6ebf0bf845f84325a09f8e49e2ad84b0732984398749956e807e4b526c786af3c5f7416b293e638956a06bf88342092f6ff9fabe31739b2ebfa1409707ce54a54693e91a6b9bb77df0e7945a0043070275d9f6054307ee7348bd660849d90ff845f84326a0f45cf8d7f88c08e6b6ec0b3b562f34ca94283e4689021987abb6b0772ddfd80aa0298fe2c5aeabb6a518f4cbb5ff39631a5d88be505d3923374f65fdcf63c2955b"
    static let expectedTransactionHash = "0xe1e07f9971153499fc8c7bafcdaf7abc20b37aa4c18fb1e53a9bfcc259e3644c"
    static let expectedSenderTransactionHash = "0x40f8c94e01e07eb5353f6cd4cd3eabd5893215dd53a50ba4b8ff9a447ac51731"
    static let expectedRLPEncodingForFeePayerSigning = "0xf84eb5f4098204d219830f4240947b65b75d204abed71587c9e519a89277766ee1d00a94a94f5374fce5edbc8e2a8697c15331677e6ebf0b945a0043070275d9f6054307ee7348bd660849d90f018080"
        
    public static func generateRoleBaseKeyring(_ numArr: [Int], _ address: String) throws -> AbstractKeyring {
        let keyArr = KeyringFactory.generateRoleBasedKeys(numArr, "entropy")
        return try KeyringFactory.createWithRoleBasedKey(address, keyArr)
    }
}

class FeeDelegatedValueTransferTest_createInstanceBuilder: XCTestCase {
    let from = FeeDelegatedValueTransferTest.from
    let account = FeeDelegatedValueTransferTest.account
    let to = FeeDelegatedValueTransferTest.to
    let gas = FeeDelegatedValueTransferTest.gas
    let nonce = FeeDelegatedValueTransferTest.nonce
    let gasPrice = FeeDelegatedValueTransferTest.gasPrice
    let chainID = FeeDelegatedValueTransferTest.chainID
    let value = FeeDelegatedValueTransferTest.value
    let input = FeeDelegatedValueTransferTest.input
    let humanReadable = FeeDelegatedValueTransferTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferTest.senderSignatureData
    let feePayer = FeeDelegatedValueTransferTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferTest.feePayerSignatureData
        
    public func test_BuilderTest() throws {
        let txObj = try FeeDelegatedValueTransfer.Builder()
                    .setNonce(nonce)
                    .setGas(gas)
                    .setGasPrice(gasPrice)
                    .setTo(to)
                    .setChainId(chainID)
                    .setValue(value)
                    .setFrom(from)
                    .setFeePayer(feePayer)
                    .setSignatures(senderSignatureData)
                    .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertNotNil(txObj)
    }
    
    public func test_BuilderWithRPCTest() throws {
        let txObj = try FeeDelegatedValueTransfer.Builder()
            .setKlaytnCall(FeeDelegatedValueTransferTest.caver.rpc.klay)
            .setGas(gas)
            .setTo(to)
            .setValue(value)
            .setFrom(from)
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
        let txObj = try FeeDelegatedValueTransfer.Builder()
            .setNonce(BigInt(hex: nonce)!)
            .setGas(BigInt(hex: gas)!)
            .setGasPrice(BigInt(hex: gasPrice)!)
            .setChainId(BigInt(hex: chainID)!)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
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
        XCTAssertThrowsError(try FeeDelegatedValueTransfer.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setFeePayer(feePayer)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(from)"))
        }
    }
    
    public func test_throwException_missingFrom() throws {
        let from = ""
        XCTAssertThrowsError(try FeeDelegatedValueTransfer.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setFeePayer(feePayer)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("from is missing."))
        }
    }
    
    public func test_throwException_invalidTo() throws {
        let to = "invalid Address"
        XCTAssertThrowsError(try FeeDelegatedValueTransfer.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setFeePayer(feePayer)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(to)"))
        }
    }
    
    public func test_throwException_missingTo() throws {
        let to = ""
        XCTAssertThrowsError(try FeeDelegatedValueTransfer.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setFeePayer(feePayer)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("to is missing."))
        }
    }
    
    public func test_throwException_invalidValue() throws {
        let value = "invalid value"
        XCTAssertThrowsError(try FeeDelegatedValueTransfer.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setFeePayer(feePayer)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid value : \(value)"))
        }
    }
    
    public func test_throwException_missingValue() throws {
        let value = ""
        XCTAssertThrowsError(try FeeDelegatedValueTransfer.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setFeePayer(feePayer)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("value is missing."))
        }
    }
        
    public func test_throwException_invalidGas() throws {
        let gas = "invalid gas"
        XCTAssertThrowsError(try FeeDelegatedValueTransfer.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setFeePayer(feePayer)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid gas. : \(gas)"))
        }
    }
    
    public func test_throwException_missingGas() throws {
        let gas = ""
        XCTAssertThrowsError(try FeeDelegatedValueTransfer.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setFeePayer(feePayer)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("gas is missing."))
        }
    }
    
    public func test_throwException_setFeePayerSignatures_missingFeePayer() throws {
        let feePayer = ""
        XCTAssertThrowsError(try FeeDelegatedValueTransfer.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setFeePayer(feePayer)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("feePayer is missing: feePayer must be defined with feePayerSignatures."))
        }
    }
}

class FeeDelegatedValueTransferTest_createInstance: XCTestCase {
    let from = FeeDelegatedValueTransferTest.from
    let account = FeeDelegatedValueTransferTest.account
    let to = FeeDelegatedValueTransferTest.to
    let gas = FeeDelegatedValueTransferTest.gas
    let nonce = FeeDelegatedValueTransferTest.nonce
    let gasPrice = FeeDelegatedValueTransferTest.gasPrice
    let chainID = FeeDelegatedValueTransferTest.chainID
    let value = FeeDelegatedValueTransferTest.value
    let input = FeeDelegatedValueTransferTest.input
    let humanReadable = FeeDelegatedValueTransferTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferTest.senderSignatureData
    let feePayer = FeeDelegatedValueTransferTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferTest.feePayerSignatureData
    
    public func test_createInstance() throws {
        let txObj = try FeeDelegatedValueTransfer(
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
            value
        )
        
        XCTAssertNotNil(txObj)
    }
    
    public func test_throwException_invalidFrom() throws {
        let from = "invalid Address"
        XCTAssertThrowsError(try FeeDelegatedValueTransfer(
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
            value
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(from)"))
        }
    }
    
    public func test_throwException_missingFrom() throws {
        let from = ""
        XCTAssertThrowsError(try FeeDelegatedValueTransfer(
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
            value
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("from is missing."))
        }
    }
    
    public func test_throwException_invalidTo() throws {
        let to = "invalid Address"
        XCTAssertThrowsError(try FeeDelegatedValueTransfer(
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
            value
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(to)"))
        }
    }
    
    public func test_throwException_missingTo() throws {
        let to = ""
        XCTAssertThrowsError(try FeeDelegatedValueTransfer(
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
            value
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("to is missing."))
        }
    }
    
    public func test_throwException_invalidValue() throws {
        let value = "invalid value"
        XCTAssertThrowsError(try FeeDelegatedValueTransfer(
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
            value
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid value : \(value)"))
        }
    }
    
    public func test_throwException_missingValue() throws {
        let value = ""
        XCTAssertThrowsError(try FeeDelegatedValueTransfer(
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
            value
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("value is missing."))
        }
    }
    
    public func test_throwException_invalidGas() throws {
        let gas = "invalid gas"
        XCTAssertThrowsError(try FeeDelegatedValueTransfer(
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
            value
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid gas. : \(gas)"))
        }
    }
    
    public func test_throwException_missingGas() throws {
        let gas = ""
        XCTAssertThrowsError(try FeeDelegatedValueTransfer(
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
            value
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("gas is missing."))
        }
    }
    
    public func test_throwException_setFeePayerSignatures_missingFeePayer() throws {
        let feePayer = ""
        XCTAssertThrowsError(try FeeDelegatedValueTransfer(
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
            value
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("feePayer is missing: feePayer must be defined with feePayerSignatures."))
        }
    }
}

class FeeDelegatedValueTransferTest_getRLPEncodingTest: XCTestCase {
    let from = FeeDelegatedValueTransferTest.from
    let account = FeeDelegatedValueTransferTest.account
    let to = FeeDelegatedValueTransferTest.to
    let gas = FeeDelegatedValueTransferTest.gas
    let nonce = FeeDelegatedValueTransferTest.nonce
    let gasPrice = FeeDelegatedValueTransferTest.gasPrice
    let chainID = FeeDelegatedValueTransferTest.chainID
    let value = FeeDelegatedValueTransferTest.value
    let input = FeeDelegatedValueTransferTest.input
    let humanReadable = FeeDelegatedValueTransferTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferTest.senderSignatureData
    let feePayer = FeeDelegatedValueTransferTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferTest.feePayerSignatureData
    
    let expectedRLPEncoding = FeeDelegatedValueTransferTest.expectedRLPEncoding
        
    public func test_getRLPEncoding() throws {
        let txObj = try FeeDelegatedValueTransfer.Builder()
                    .setNonce(nonce)
                    .setGas(gas)
                    .setGasPrice(gasPrice)
                    .setTo(to)
                    .setChainId(chainID)
                    .setValue(value)
                    .setFrom(from)
                    .setFeePayer(feePayer)
                    .setSignatures(senderSignatureData)
                    .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertEqual(expectedRLPEncoding, try txObj.getRLPEncoding())
    }
    
    public func test_throwException_NoNonce() throws {
        let txObj = try FeeDelegatedValueTransfer.Builder()
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertThrowsError(try txObj.getRLPEncoding()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NoGasPrice() throws {
        let txObj = try FeeDelegatedValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertThrowsError(try txObj.getRLPEncoding()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class FeeDelegatedValueTransferTest_signAsFeePayer_OneKeyTest: XCTestCase {
    var mTxObj: FeeDelegatedValueTransfer?
    var klaytnWalletKey: String?
    var keyring: AbstractKeyring?
    var feePayerAddress: String?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedValueTransferTest.feePayerPrivateKey
        
    let from = FeeDelegatedValueTransferTest.from
    let account = FeeDelegatedValueTransferTest.account
    let to = FeeDelegatedValueTransferTest.to
    let gas = FeeDelegatedValueTransferTest.gas
    let nonce = FeeDelegatedValueTransferTest.nonce
    let gasPrice = FeeDelegatedValueTransferTest.gasPrice
    let chainID = FeeDelegatedValueTransferTest.chainID
    let value = FeeDelegatedValueTransferTest.value
    let input = FeeDelegatedValueTransferTest.input
    let humanReadable = FeeDelegatedValueTransferTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferTest.senderSignatureData
    let feePayer = FeeDelegatedValueTransferTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferTest.feePayerSignatureData
    
    let expectedRLPEncoding = FeeDelegatedValueTransferTest.expectedRLPEncoding
        
    override func setUpWithError() throws {
        keyring = try KeyringFactory.createWithSingleKey(feePayer, feePayerPrivateKey)
        klaytnWalletKey = try keyring?.getKlaytnWalletKey()
        
        mTxObj = try FeeDelegatedValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .build()
    }
    
    public func test_signAsFeePayer_String() throws {
        let expectedRLPEncoding = "0x09f8d68204d219830f4240947b65b75d204abed71587c9e519a89277766ee1d00a94a94f5374fce5edbc8e2a8697c15331677e6ebf0bf845f84325a09f8e49e2ad84b0732984398749956e807e4b526c786af3c5f7416b293e638956a06bf88342092f6ff9fabe31739b2ebfa1409707ce54a54693e91a6b9bb77df0e79433f524631e573329a550296f595c820d6c65213ff845f84325a011f8278d8d465d816acd57c1dd7fe07a070b747cefd65ef8c6607fe35b886de8a074cbb48a5ad3f4d8593de69ee8fd7d67d23636710c16097ca1c9bbb1f6967e72"
        
        let keyring = try KeyringFactory.createFromPrivateKey(feePayerPrivateKey)
        let feePayer = keyring.address
        
        mTxObj = try FeeDelegatedValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
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

class FeeDelegatedValueTransferTest_signAsFeePayer_AllKeyTest: XCTestCase {
    var mTxObj: FeeDelegatedValueTransfer?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedValueTransferTest.feePayerPrivateKey
        
    let from = FeeDelegatedValueTransferTest.from
    let account = FeeDelegatedValueTransferTest.account
    let to = FeeDelegatedValueTransferTest.to
    let gas = FeeDelegatedValueTransferTest.gas
    let nonce = FeeDelegatedValueTransferTest.nonce
    let gasPrice = FeeDelegatedValueTransferTest.gasPrice
    let chainID = FeeDelegatedValueTransferTest.chainID
    let value = FeeDelegatedValueTransferTest.value
    let input = FeeDelegatedValueTransferTest.input
    let humanReadable = FeeDelegatedValueTransferTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferTest.senderSignatureData
    var feePayer = FeeDelegatedValueTransferTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferTest.feePayerSignatureData
    
    let expectedRLPEncoding = FeeDelegatedValueTransferTest.expectedRLPEncoding
        
    override func setUpWithError() throws {
        mTxObj = try FeeDelegatedValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
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

class FeeDelegatedValueTransferTest_appendFeePayerSignaturesTest: XCTestCase {
    var mTxObj: FeeDelegatedValueTransfer?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = FeeDelegatedValueTransferTest.senderPrivateKey
    let feePayerPrivateKey = FeeDelegatedValueTransferTest.feePayerPrivateKey
        
    let from = FeeDelegatedValueTransferTest.from
    let account = FeeDelegatedValueTransferTest.account
    let to = FeeDelegatedValueTransferTest.to
    let gas = FeeDelegatedValueTransferTest.gas
    let nonce = FeeDelegatedValueTransferTest.nonce
    let gasPrice = FeeDelegatedValueTransferTest.gasPrice
    let chainID = FeeDelegatedValueTransferTest.chainID
    let value = FeeDelegatedValueTransferTest.value
    let input = FeeDelegatedValueTransferTest.input
    let humanReadable = FeeDelegatedValueTransferTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferTest.senderSignatureData
    let feePayer = FeeDelegatedValueTransferTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferTest.feePayerSignatureData
    
    override func setUpWithError() throws {
        mTxObj = try FeeDelegatedValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
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
        mTxObj = try FeeDelegatedValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
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
        
        mTxObj = try FeeDelegatedValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
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
        
        mTxObj = try FeeDelegatedValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
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

class FeeDelegatedValueTransferTest_combineSignatureTest: XCTestCase {
    var mTxObj: FeeDelegatedValueTransfer?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = FeeDelegatedValueTransferTest.senderPrivateKey
    let from = "0x04bb86a1b16113ebe8f57071f839b002cbcbf7d0"
    var account: Account?
    let to = "0x7b65b75d204abed71587c9e519a89277766ee1d0"
    let gas = "0xf4240"
    let nonce = "0x1"
    let gasPrice = "0x5d21dba00"
    let chainID = "0x7e3"
    let value = "0xa"
    let input = FeeDelegatedValueTransferTest.input
    let humanReadable = FeeDelegatedValueTransferTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferTest.senderSignatureData
    let feePayer = FeeDelegatedValueTransferTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferTest.feePayerSignatureData
    let expectedRLPEncoding = FeeDelegatedValueTransferTest.expectedRLPEncoding
    
    override func setUpWithError() throws {
        mTxObj = try FeeDelegatedValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .build()
    }
    
    public func test_decode() throws {
        mTxObj = try FeeDelegatedValueTransfer.decode(expectedRLPEncoding)
    }
    
    public func test_combineSignature() throws {
        let expectedRLPEncoded = "0x09f899018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a9404bb86a1b16113ebe8f57071f839b002cbcbf7d0f847f845820feaa068e56f3da7fbe7a86543eb4b244ddbcb13b2d1cb9adb3ee8a4c8b046821bc492a068c29c057055f68a7860b54184bba7967bcf42b6aae12beaf9f30933e6e730c2940000000000000000000000000000000000000000c4c3018080"
        
        let expectedSignature = SignatureData(
            "0x0fea",
            "0x68e56f3da7fbe7a86543eb4b244ddbcb13b2d1cb9adb3ee8a4c8b046821bc492",
            "0x68c29c057055f68a7860b54184bba7967bcf42b6aae12beaf9f30933e6e730c2"
        )
        
        let rlpEncoded = "0x09f899018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a9404bb86a1b16113ebe8f57071f839b002cbcbf7d0f847f845820feaa068e56f3da7fbe7a86543eb4b244ddbcb13b2d1cb9adb3ee8a4c8b046821bc492a068c29c057055f68a7860b54184bba7967bcf42b6aae12beaf9f30933e6e730c2940000000000000000000000000000000000000000c4c3018080"
        
        let combined = try mTxObj!.combineSignedRawTransactions([rlpEncoded])
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature, mTxObj?.signatures[0])
    }
    
    public func test_combine_multipleSignature() throws {
        let expectedRLPEncoded = "0x09f90127018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a9404bb86a1b16113ebe8f57071f839b002cbcbf7d0f8d5f845820feaa068e56f3da7fbe7a86543eb4b244ddbcb13b2d1cb9adb3ee8a4c8b046821bc492a068c29c057055f68a7860b54184bba7967bcf42b6aae12beaf9f30933e6e730c2f845820feaa007337912a1855c1b3ca511eb44099350590e54aa611069058a9b739945ad97eaa037dfa221d29bc6d418ade23456de937993885b77cde5bc265739f278deebbc39f845820fe9a0799f833aa487296b11988650c9a63dc2a850715de4a29c8ab2b7c648718205a6a005a5fbad245cceccb4c08dd4a1cc6e26dc4fda06d0f49b248f83329623e3bee8940000000000000000000000000000000000000000c4c3018080"
        
        let expectedSignature = [
            SignatureData(
                    "0x0fea",
                    "0x68e56f3da7fbe7a86543eb4b244ddbcb13b2d1cb9adb3ee8a4c8b046821bc492",
                    "0x68c29c057055f68a7860b54184bba7967bcf42b6aae12beaf9f30933e6e730c2"
            ),
            SignatureData(
                    "0x0fea",
                    "0x07337912a1855c1b3ca511eb44099350590e54aa611069058a9b739945ad97ea",
                    "0x37dfa221d29bc6d418ade23456de937993885b77cde5bc265739f278deebbc39"
            ),
            SignatureData(
                    "0x0fe9",
                    "0x799f833aa487296b11988650c9a63dc2a850715de4a29c8ab2b7c648718205a6",
                    "0x05a5fbad245cceccb4c08dd4a1cc6e26dc4fda06d0f49b248f83329623e3bee8"
            )
        ]
        
        let rlpEncodedString = [
            "0x09f885018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a9404bb86a1b16113ebe8f57071f839b002cbcbf7d0f847f845820feaa007337912a1855c1b3ca511eb44099350590e54aa611069058a9b739945ad97eaa037dfa221d29bc6d418ade23456de937993885b77cde5bc265739f278deebbc3980c4c3018080",
            "0x09f885018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a9404bb86a1b16113ebe8f57071f839b002cbcbf7d0f847f845820fe9a0799f833aa487296b11988650c9a63dc2a850715de4a29c8ab2b7c648718205a6a005a5fbad245cceccb4c08dd4a1cc6e26dc4fda06d0f49b248f83329623e3bee880c4c3018080"
        ]
        
        let senderSignatureData = SignatureData(
            "0x0fea",
            "0x68e56f3da7fbe7a86543eb4b244ddbcb13b2d1cb9adb3ee8a4c8b046821bc492",
            "0x68c29c057055f68a7860b54184bba7967bcf42b6aae12beaf9f30933e6e730c2"
        )
        
        mTxObj = try FeeDelegatedValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setSignatures(senderSignatureData)
            .build()
        
        let combined = try mTxObj!.combineSignedRawTransactions(rlpEncodedString)
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature[0], mTxObj?.signatures[0])
        XCTAssertEqual(expectedSignature[1], mTxObj?.signatures[1])
        XCTAssertEqual(expectedSignature[2], mTxObj?.signatures[2])
    }
    
    public func test_combineSignature_feePayerSignature() throws {
        let expectedRLPEncoded = "0x09f899018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a9404bb86a1b16113ebe8f57071f839b002cbcbf7d0c4c301808094b85f01a3b0b6aaa2e487c9ed541e27b75b3eba95f847f845820fe9a0388a4beb8a27fe3c3631eb66278f0a756da13562af5fa1c33345eccf742555dda065b829314f8e91f2ee0266d4f4936d3f3bdc7ef1364a931a068742834c2519f2"
        
        let expectedSignature = SignatureData(
            "0x0fe9",
            "0x388a4beb8a27fe3c3631eb66278f0a756da13562af5fa1c33345eccf742555dd",
            "0x65b829314f8e91f2ee0266d4f4936d3f3bdc7ef1364a931a068742834c2519f2"
        )
        
        let rlpEncoded = "0x09f899018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a9404bb86a1b16113ebe8f57071f839b002cbcbf7d0c4c301808094b85f01a3b0b6aaa2e487c9ed541e27b75b3eba95f847f845820fe9a0388a4beb8a27fe3c3631eb66278f0a756da13562af5fa1c33345eccf742555dda065b829314f8e91f2ee0266d4f4936d3f3bdc7ef1364a931a068742834c2519f2"
        
        let feePayer = "0xb85f01a3b0b6aaa2e487c9ed541e27b75b3eba95"
        
        mTxObj = try FeeDelegatedValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setFeePayer(feePayer)
            .build()
        
        let combined = try mTxObj!.combineSignedRawTransactions([rlpEncoded])
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature, mTxObj?.feePayerSignatures[0])
    }
    
    public func test_combineSignature_multipleFeePayerSignature() throws {
        let expectedRLPEncoded = "0x09f90127018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a9404bb86a1b16113ebe8f57071f839b002cbcbf7d0c4c301808094b85f01a3b0b6aaa2e487c9ed541e27b75b3eba95f8d5f845820fe9a0388a4beb8a27fe3c3631eb66278f0a756da13562af5fa1c33345eccf742555dda065b829314f8e91f2ee0266d4f4936d3f3bdc7ef1364a931a068742834c2519f2f845820fe9a00585c73b60072ebb22bcc38b08e318dc88fc074435c3fa5d345219f1962098b7a06adcc5a1bc49d1c465412628bf8782aa8254af7fae8763d834a3f1711b22474af845820feaa0d432bdce799828530d89d14b4406ccb0446852a51f13e365123eac9375d7e629a04f73deb5343ff7d587a5affb14196a79c522b9a67c7d895762c6758258ac247b"
        
        let expectedSignature = [
            SignatureData(
                    "0x0fe9",
                    "0x388a4beb8a27fe3c3631eb66278f0a756da13562af5fa1c33345eccf742555dd",
                    "0x65b829314f8e91f2ee0266d4f4936d3f3bdc7ef1364a931a068742834c2519f2"
            ),
            SignatureData(
                    "0x0fe9",
                    "0x0585c73b60072ebb22bcc38b08e318dc88fc074435c3fa5d345219f1962098b7",
                    "0x6adcc5a1bc49d1c465412628bf8782aa8254af7fae8763d834a3f1711b22474a"
            ),
            SignatureData(
                    "0x0fea",
                    "0xd432bdce799828530d89d14b4406ccb0446852a51f13e365123eac9375d7e629",
                    "0x4f73deb5343ff7d587a5affb14196a79c522b9a67c7d895762c6758258ac247b"
            )
        ]
        
        let rlpEncodedString = [
            "0x09f899018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a9404bb86a1b16113ebe8f57071f839b002cbcbf7d0c4c301808094b85f01a3b0b6aaa2e487c9ed541e27b75b3eba95f847f845820fe9a00585c73b60072ebb22bcc38b08e318dc88fc074435c3fa5d345219f1962098b7a06adcc5a1bc49d1c465412628bf8782aa8254af7fae8763d834a3f1711b22474a",
            "0x09f899018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a9404bb86a1b16113ebe8f57071f839b002cbcbf7d0c4c301808094b85f01a3b0b6aaa2e487c9ed541e27b75b3eba95f847f845820feaa0d432bdce799828530d89d14b4406ccb0446852a51f13e365123eac9375d7e629a04f73deb5343ff7d587a5affb14196a79c522b9a67c7d895762c6758258ac247b",
        ]
        
        let feePayer = "0xb85f01a3b0b6aaa2e487c9ed541e27b75b3eba95"
        let feePayerSignatureData = SignatureData(
            "0x0fe9",
            "0x388a4beb8a27fe3c3631eb66278f0a756da13562af5fa1c33345eccf742555dd",
            "0x65b829314f8e91f2ee0266d4f4936d3f3bdc7ef1364a931a068742834c2519f2"
        )
        
        mTxObj = try FeeDelegatedValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
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
        mTxObj = try FeeDelegatedValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .build()
        
        let rlpEncoded = "0x09f899018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a9404bb86a1b16113ebe8f57071f839b002cbcbf7d0c4c301808094b85f01a3b0b6aaa2e487c9ed541e27b75b3eba95f847f845820feaa0d432bdce799828530d89d14b4406ccb0446852a51f13e365123eac9375d7e629a04f73deb5343ff7d587a5affb14196a79c522b9a67c7d895762c6758258ac247b"
        
        XCTAssertThrowsError(try mTxObj!.combineSignedRawTransactions([rlpEncoded])) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("Transactions containing different information cannot be combined."))
        }
    }
}

class FeeDelegatedValueTransferTest_getRawTransactionTest: XCTestCase {
    let privateKey = FeeDelegatedValueTransferTest.senderPrivateKey
    let feePayerPrivateKey = FeeDelegatedValueTransferTest.feePayerPrivateKey
        
    let from = FeeDelegatedValueTransferTest.from
    let account = FeeDelegatedValueTransferTest.account
    let to = FeeDelegatedValueTransferTest.to
    let gas = FeeDelegatedValueTransferTest.gas
    let nonce = FeeDelegatedValueTransferTest.nonce
    let gasPrice = FeeDelegatedValueTransferTest.gasPrice
    let chainID = FeeDelegatedValueTransferTest.chainID
    let value = FeeDelegatedValueTransferTest.value
    let input = FeeDelegatedValueTransferTest.input
    let humanReadable = FeeDelegatedValueTransferTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferTest.senderSignatureData
    let feePayer = FeeDelegatedValueTransferTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferTest.feePayerSignatureData
    
    let expectedRLPEncoding = FeeDelegatedValueTransferTest.expectedRLPEncoding
    
    public func test_getRawTransaction() throws {
        let txObj = try FeeDelegatedValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()

        XCTAssertEqual(expectedRLPEncoding, try txObj.getRawTransaction())
    }
}

class FeeDelegatedValueTransferTest_getTransactionHashTest: XCTestCase {
    var mTxObj: FeeDelegatedValueTransfer?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = FeeDelegatedValueTransferTest.senderPrivateKey
    let feePayerPrivateKey = FeeDelegatedValueTransferTest.feePayerPrivateKey
        
    let from = FeeDelegatedValueTransferTest.from
    let account = FeeDelegatedValueTransferTest.account
    let to = FeeDelegatedValueTransferTest.to
    let gas = FeeDelegatedValueTransferTest.gas
    let nonce = FeeDelegatedValueTransferTest.nonce
    let gasPrice = FeeDelegatedValueTransferTest.gasPrice
    let chainID = FeeDelegatedValueTransferTest.chainID
    let value = FeeDelegatedValueTransferTest.value
    let input = FeeDelegatedValueTransferTest.input
    let humanReadable = FeeDelegatedValueTransferTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferTest.senderSignatureData
    let feePayer = FeeDelegatedValueTransferTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferTest.feePayerSignatureData
    
    let expectedRLPEncoding = FeeDelegatedValueTransferTest.expectedRLPEncoding
    let expectedTransactionHash = FeeDelegatedValueTransferTest.expectedTransactionHash
            
    public func test_getTransactionHash() throws {
        let txObj = try FeeDelegatedValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()

        XCTAssertEqual(expectedTransactionHash, try txObj.getTransactionHash())
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try FeeDelegatedValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
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
        
        mTxObj = try FeeDelegatedValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
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

class FeeDelegatedValueTransferTest_getSenderTxHashTest: XCTestCase {
    var mTxObj: FeeDelegatedValueTransfer?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = FeeDelegatedValueTransferTest.senderPrivateKey
    let from = FeeDelegatedValueTransferTest.from
    let account = FeeDelegatedValueTransferTest.account
    let to = FeeDelegatedValueTransferTest.to
    let gas = FeeDelegatedValueTransferTest.gas
    let nonce = FeeDelegatedValueTransferTest.nonce
    let gasPrice = FeeDelegatedValueTransferTest.gasPrice
    let chainID = FeeDelegatedValueTransferTest.chainID
    let value = FeeDelegatedValueTransferTest.value
    let input = FeeDelegatedValueTransferTest.input
    let humanReadable = FeeDelegatedValueTransferTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferTest.senderSignatureData
    let feePayer = FeeDelegatedValueTransferTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferTest.feePayerSignatureData
    let expectedRLPEncoding = FeeDelegatedValueTransferTest.expectedRLPEncoding
    let expectedTransactionHash = FeeDelegatedValueTransferTest.expectedTransactionHash
    let expectedSenderTransactionHash = FeeDelegatedValueTransferTest.expectedSenderTransactionHash
            
    public func test_getRLPEncodingForSignature() throws {
        mTxObj = try FeeDelegatedValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertEqual(expectedSenderTransactionHash, try mTxObj!.getSenderTxHash())
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try FeeDelegatedValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
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
        
        mTxObj = try FeeDelegatedValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
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

class FeeDelegatedValueTransferTest_getRLPEncodingForFeePayerSignatureTest: XCTestCase {
    var mTxObj: FeeDelegatedValueTransfer?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = FeeDelegatedValueTransferTest.senderPrivateKey
    let from = FeeDelegatedValueTransferTest.from
    let account = FeeDelegatedValueTransferTest.account
    let to = FeeDelegatedValueTransferTest.to
    let gas = FeeDelegatedValueTransferTest.gas
    let nonce = FeeDelegatedValueTransferTest.nonce
    let gasPrice = FeeDelegatedValueTransferTest.gasPrice
    let chainID = FeeDelegatedValueTransferTest.chainID
    let value = FeeDelegatedValueTransferTest.value
    let input = FeeDelegatedValueTransferTest.input
    let humanReadable = FeeDelegatedValueTransferTest.humanReadable
    let codeFormat = FeeDelegatedValueTransferTest.codeFormat
    let senderSignatureData = FeeDelegatedValueTransferTest.senderSignatureData
    let feePayer = FeeDelegatedValueTransferTest.feePayer
    let feePayerSignatureData = FeeDelegatedValueTransferTest.feePayerSignatureData
    let expectedRLPEncoding = FeeDelegatedValueTransferTest.expectedRLPEncoding
    let expectedTransactionHash = FeeDelegatedValueTransferTest.expectedTransactionHash
    let expectedSenderTransactionHash = FeeDelegatedValueTransferTest.expectedSenderTransactionHash
    let expectedRLPEncodingForFeePayerSigning = FeeDelegatedValueTransferTest.expectedRLPEncodingForFeePayerSigning
            
    public func test_getRLPEncodingForSignature() throws {
        mTxObj = try FeeDelegatedValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertEqual(expectedRLPEncodingForFeePayerSigning, try mTxObj!.getRLPEncodingForFeePayerSignature())
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try FeeDelegatedValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
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
        
        mTxObj = try FeeDelegatedValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
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
        
        mTxObj = try FeeDelegatedValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
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

