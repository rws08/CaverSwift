//
//  FeeDelegatedCancelWithRatioTest.swift
//  CaverSwiftTests
//
//  Created by won on 2021/07/16.
//

import XCTest
@testable import CaverSwift

class FeeDelegatedCancelWithRatioTest: XCTestCase {
    static let caver = Caver(Caver.DEFAULT_URL)
    
    static let privateKey = "0x45a915e4d060149eb4365960e6a7a45f334393093061116b197e3240065ff2d8"
    static let feePayerPrivateKey = "0xb9d5558443585bca6f225b935950e3f6e69f9da8a5809a83f51c3365dff53936"
    static let from = "0xa94f5374Fce5edBC8E2a8697C15331677e6EbF0B"
    static let account = Account.createWithAccountKeyLegacy(from)
    static let to = "0x7b65b75d204abed71587c9e519a89277766ee1d0"
    static let gas = "0xf4240"
    static let gasPrice = "0x19"
    static let nonce = "0x4d2"
    static let chainID = "0x1"
    static let value = "0xa"
    static let input = "0x68656c6c6f"
    static let humanReadable = false
    static let codeFormat = CodeFormat.EVM.hexa
    static let feeRatio = "0x1e"

    static let senderSignatureData = SignatureData(
        "0x26",
        "0x72efa47960bef40b536c72d7e03ceaf6ca5f6061eb8a3eda3545b1a78fe52ef5",
        "0x62006ddaf874da205f08b3789e2d014ae37794890fc2e575bf75201563a24ba9"
    )
    static let feePayer = "0x5A0043070275d9f6054307Ee7348bD660849D90f"
    static let feePayerSignatureData = SignatureData(
        "0x26",
        "0x6ba5ef20c3049323fc94defe14ca162e28b86aa64f7cf497ac8a5520e9615614",
        "0x4a0a0fc61c10b416759af0ce4ce5c09ca1060141d56d958af77050c9564df6bf"
    )

    static let expectedRLPEncoding = "0x3af8c18204d219830f424094a94f5374fce5edbc8e2a8697c15331677e6ebf0b1ef845f84326a072efa47960bef40b536c72d7e03ceaf6ca5f6061eb8a3eda3545b1a78fe52ef5a062006ddaf874da205f08b3789e2d014ae37794890fc2e575bf75201563a24ba9945a0043070275d9f6054307ee7348bd660849d90ff845f84326a06ba5ef20c3049323fc94defe14ca162e28b86aa64f7cf497ac8a5520e9615614a04a0a0fc61c10b416759af0ce4ce5c09ca1060141d56d958af77050c9564df6bf"
    static let expectedTransactionHash = "0x63604ebf68bfee51b2e3f54ddb2f19f9ea72d32b3fc70877324531ecda25817a"
    static let expectedRLPSenderTransactionHash = "0xc0818be4cffbacfe29be1134e0267e10fd1afb6571f4ccc95dcc67a788bab5e7"
    static let expectedRLPEncodingForFeePayerSigning = "0xf839a0df3a8204d219830f424094a94f5374fce5edbc8e2a8697c15331677e6ebf0b1e945a0043070275d9f6054307ee7348bd660849d90f018080"
        
    public static func generateRoleBaseKeyring(_ numArr: [Int], _ address: String) throws -> AbstractKeyring {
        let keyArr = KeyringFactory.generateRoleBasedKeys(numArr, "entropy")
        return try KeyringFactory.createWithRoleBasedKey(address, keyArr)
    }
}

class FeeDelegatedCancelWithRatioTest_createInstanceBuilder: XCTestCase {
    let from = FeeDelegatedCancelWithRatioTest.from
    let account = FeeDelegatedCancelWithRatioTest.account
    let to = FeeDelegatedCancelWithRatioTest.to
    let gas = FeeDelegatedCancelWithRatioTest.gas
    let nonce = FeeDelegatedCancelWithRatioTest.nonce
    let gasPrice = FeeDelegatedCancelWithRatioTest.gasPrice
    let chainID = FeeDelegatedCancelWithRatioTest.chainID
    let value = FeeDelegatedCancelWithRatioTest.value
    let input = FeeDelegatedCancelWithRatioTest.input
    let humanReadable = FeeDelegatedCancelWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedCancelWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedCancelWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedCancelWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedCancelWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedCancelWithRatioTest.feeRatio
        
    public func test_BuilderTest() throws {
        let txObj = try FeeDelegatedCancelWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertNotNil(txObj)
    }
    
    public func test_BuilderWithRPCTest() throws {
        let txObj = try FeeDelegatedCancelWithRatio.Builder()
            .setKlaytnCall(FeeDelegatedCancelWithRatioTest.caver.rpc.klay)
            .setGas(gas)
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
        let txObj = try FeeDelegatedCancelWithRatio.Builder()
            .setNonce(BigInt(hex: nonce)!)
            .setGas(BigInt(hex: gas)!)
            .setGasPrice(BigInt(hex: gasPrice)!)
            .setChainId(BigInt(hex: chainID)!)
            .setFrom(from)
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
        XCTAssertThrowsError(try FeeDelegatedCancelWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
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
        XCTAssertThrowsError(try FeeDelegatedCancelWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setFeePayer(feePayer)
                                .setFeeRatio(feeRatio)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("from is missing."))
        }
    }
        
    public func test_throwException_invalidGas() throws {
        let gas = "invalid gas"
        XCTAssertThrowsError(try FeeDelegatedCancelWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
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
        XCTAssertThrowsError(try FeeDelegatedCancelWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
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
        XCTAssertThrowsError(try FeeDelegatedCancelWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
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
        XCTAssertThrowsError(try FeeDelegatedCancelWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
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
        XCTAssertThrowsError(try FeeDelegatedCancelWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
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
        XCTAssertThrowsError(try FeeDelegatedCancelWithRatio.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
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

class FeeDelegatedCancelWithRatioTest_createInstance: XCTestCase {
    let from = FeeDelegatedCancelWithRatioTest.from
    let account = FeeDelegatedCancelWithRatioTest.account
    let to = FeeDelegatedCancelWithRatioTest.to
    let gas = FeeDelegatedCancelWithRatioTest.gas
    let nonce = FeeDelegatedCancelWithRatioTest.nonce
    let gasPrice = FeeDelegatedCancelWithRatioTest.gasPrice
    let chainID = FeeDelegatedCancelWithRatioTest.chainID
    let value = FeeDelegatedCancelWithRatioTest.value
    let input = FeeDelegatedCancelWithRatioTest.input
    let humanReadable = FeeDelegatedCancelWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedCancelWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedCancelWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedCancelWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedCancelWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedCancelWithRatioTest.feeRatio
    
    public func test_createInstance() throws {
        let txObj = try FeeDelegatedCancelWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            feeRatio
        )
        
        XCTAssertNotNil(txObj)
    }
    
    public func test_throwException_invalidFrom() throws {
        let from = "invalid Address"
        XCTAssertThrowsError(try FeeDelegatedCancelWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            feeRatio
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(from)"))
        }
    }
    
    public func test_throwException_missingFrom() throws {
        let from = ""
        XCTAssertThrowsError(try FeeDelegatedCancelWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            feeRatio
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("from is missing."))
        }
    }
    
    public func test_throwException_invalidGas() throws {
        let gas = "invalid gas"
        XCTAssertThrowsError(try FeeDelegatedCancelWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            feeRatio
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid gas. : \(gas)"))
        }
    }
    
    public func test_throwException_missingGas() throws {
        let gas = ""
        XCTAssertThrowsError(try FeeDelegatedCancelWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            feeRatio
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("gas is missing."))
        }
    }
    
    public func test_throwException_FeeRatio_invalid() throws {
        let feeRatio = "invalid fee ratio"
        XCTAssertThrowsError(try FeeDelegatedCancelWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            feeRatio
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid type of feeRatio: feeRatio should be number type or hex number string"))
        }
    }
    
    public func test_throwException_FeeRatio_outOfRange() throws {
        let feeRatio = BigInt(101).hexa
        XCTAssertThrowsError(try FeeDelegatedCancelWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            feeRatio
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid feeRatio: feeRatio is out of range. [1,99]"))
        }
    }
    
    public func test_throwException_missingFeeRatio() throws {
        let feeRatio = ""
        XCTAssertThrowsError(try FeeDelegatedCancelWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            feeRatio
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("feeRatio is missing."))
        }
    }
}

class FeeDelegatedCancelWithRatioTest_getRLPEncodingTest: XCTestCase {
    let from = FeeDelegatedCancelWithRatioTest.from
    let account = FeeDelegatedCancelWithRatioTest.account
    let to = FeeDelegatedCancelWithRatioTest.to
    let gas = FeeDelegatedCancelWithRatioTest.gas
    let nonce = FeeDelegatedCancelWithRatioTest.nonce
    let gasPrice = FeeDelegatedCancelWithRatioTest.gasPrice
    let chainID = FeeDelegatedCancelWithRatioTest.chainID
    let value = FeeDelegatedCancelWithRatioTest.value
    let input = FeeDelegatedCancelWithRatioTest.input
    let humanReadable = FeeDelegatedCancelWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedCancelWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedCancelWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedCancelWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedCancelWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedCancelWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedCancelWithRatioTest.expectedRLPEncoding
        
    public func test_getRLPEncoding() throws {
        let txObj = try FeeDelegatedCancelWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertEqual(expectedRLPEncoding, try txObj.getRLPEncoding())
    }
    
    public func test_throwException_NoNonce() throws {
        let txObj = try FeeDelegatedCancelWithRatio.Builder()
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
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
        let txObj = try FeeDelegatedCancelWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setChainId(chainID)
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

class FeeDelegatedCancelWithRatioTest_signAsFeePayer_OneKeyTest: XCTestCase {
    var mTxObj: FeeDelegatedCancelWithRatio?
    var klaytnWalletKey: String?
    var keyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedCancelWithRatioTest.feePayerPrivateKey
    
    let from = FeeDelegatedCancelWithRatioTest.from
    let account = FeeDelegatedCancelWithRatioTest.account
    let to = FeeDelegatedCancelWithRatioTest.to
    let gas = FeeDelegatedCancelWithRatioTest.gas
    let nonce = FeeDelegatedCancelWithRatioTest.nonce
    let gasPrice = FeeDelegatedCancelWithRatioTest.gasPrice
    let chainID = FeeDelegatedCancelWithRatioTest.chainID
    let value = FeeDelegatedCancelWithRatioTest.value
    let input = FeeDelegatedCancelWithRatioTest.input
    let humanReadable = FeeDelegatedCancelWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedCancelWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedCancelWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedCancelWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedCancelWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedCancelWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedCancelWithRatioTest.expectedRLPEncoding
        
    override func setUpWithError() throws {
        mTxObj = try FeeDelegatedCancelWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .build()
        
        keyring = try KeyringFactory.createWithSingleKey(feePayer, feePayerPrivateKey)
        klaytnWalletKey = try keyring?.getKlaytnWalletKey()
    }
    
    public func test_signAsFeePayer_String() throws {
        let feePayer = try PrivateKey(privateKey).getDerivedAddress()
        mTxObj = try FeeDelegatedCancelWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
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
        XCTAssertThrowsError(try mTxObj!.sign(keyring!)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("The from address of the transaction is different with the address of the keyring to use"))
        }
    }
    
    public func test_throwException_InvalidIndex() throws {
        let role = try AccountUpdateTest.generateRoleBaseKeyring([3,3,3], from)
        
        XCTAssertThrowsError(try mTxObj!.sign(role, 4)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid index : index must be less than the length of the key."))
        }
    }
}

class FeeDelegatedCancelWithRatioTest_signAsFeePayer_AllKeyTest: XCTestCase {
    var mTxObj: FeeDelegatedCancelWithRatio?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedCancelWithRatioTest.feePayerPrivateKey
    
    let from = FeeDelegatedCancelWithRatioTest.from
    let account = FeeDelegatedCancelWithRatioTest.account
    let to = FeeDelegatedCancelWithRatioTest.to
    let gas = FeeDelegatedCancelWithRatioTest.gas
    let nonce = FeeDelegatedCancelWithRatioTest.nonce
    let gasPrice = FeeDelegatedCancelWithRatioTest.gasPrice
    let chainID = FeeDelegatedCancelWithRatioTest.chainID
    let value = FeeDelegatedCancelWithRatioTest.value
    let input = FeeDelegatedCancelWithRatioTest.input
    let humanReadable = FeeDelegatedCancelWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedCancelWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedCancelWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedCancelWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedCancelWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedCancelWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedCancelWithRatioTest.expectedRLPEncoding
        
    override func setUpWithError() throws {
        mTxObj = try FeeDelegatedCancelWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
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

class FeeDelegatedCancelWithRatioTest_appendFeePayerSignaturesTest: XCTestCase {
    var mTxObj: FeeDelegatedCancelWithRatio?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedCancelWithRatioTest.feePayerPrivateKey
    
    let from = FeeDelegatedCancelWithRatioTest.from
    let account = FeeDelegatedCancelWithRatioTest.account
    let to = FeeDelegatedCancelWithRatioTest.to
    let gas = FeeDelegatedCancelWithRatioTest.gas
    let nonce = FeeDelegatedCancelWithRatioTest.nonce
    let gasPrice = FeeDelegatedCancelWithRatioTest.gasPrice
    let chainID = FeeDelegatedCancelWithRatioTest.chainID
    let value = FeeDelegatedCancelWithRatioTest.value
    let input = FeeDelegatedCancelWithRatioTest.input
    let humanReadable = FeeDelegatedCancelWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedCancelWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedCancelWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedCancelWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedCancelWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedCancelWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedCancelWithRatioTest.expectedRLPEncoding
    
    override func setUpWithError() throws {
        mTxObj = try FeeDelegatedCancelWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
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
        mTxObj = try FeeDelegatedCancelWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
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
        
        mTxObj = try FeeDelegatedCancelWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
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
        
        mTxObj = try FeeDelegatedCancelWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
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

class FeeDelegatedCancelWithRatioTest_combineSignatureTest: XCTestCase {
    var mTxObj: FeeDelegatedCancelWithRatio?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedCancelWithRatioTest.feePayerPrivateKey
    
    let from = "0x158a98f884e6f5a2731049569cb895cc1c75b47b"
    let account = FeeDelegatedCancelWithRatioTest.account
    let to = FeeDelegatedCancelWithRatioTest.to
    let gas = "0x249f0"
    let nonce = "0x1"
    let gasPrice = "0x5d21dba00"
    let chainID = "0x7e3"
    let value = FeeDelegatedCancelWithRatioTest.value
    let input = FeeDelegatedCancelWithRatioTest.input
    let humanReadable = FeeDelegatedCancelWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedCancelWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedCancelWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedCancelWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedCancelWithRatioTest.feePayerSignatureData
    let feeRatio = BigInt(30)
    
    let expectedRLPEncoding = FeeDelegatedCancelWithRatioTest.expectedRLPEncoding
    
    override func setUpWithError() throws {
        mTxObj = try FeeDelegatedCancelWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setFeeRatio(feeRatio)
            .build()
    }
    
    public func test_combineSignature() throws {
        let expectedRLPEncoded = "0x3af884018505d21dba00830249f094158a98f884e6f5a2731049569cb895cc1c75b47b1ef847f845820fe9a0879126759f424c790069e47d443c44674f4c2154d1e6f4f02134dbc56a6629f1a04b714b50c900b0b099b3e3ba15743654e8c576aa4fe504da38015f4c61757590940000000000000000000000000000000000000000c4c3018080"
        
        let expectedSignature = SignatureData(
            "0x0fe9",
            "0x879126759f424c790069e47d443c44674f4c2154d1e6f4f02134dbc56a6629f1",
            "0x4b714b50c900b0b099b3e3ba15743654e8c576aa4fe504da38015f4c61757590"
        )
        
        let rlpEncoded = "0x3af884018505d21dba00830249f094158a98f884e6f5a2731049569cb895cc1c75b47b1ef847f845820fe9a0879126759f424c790069e47d443c44674f4c2154d1e6f4f02134dbc56a6629f1a04b714b50c900b0b099b3e3ba15743654e8c576aa4fe504da38015f4c61757590940000000000000000000000000000000000000000c4c3018080"
        
        let combined = try mTxObj!.combineSignedRawTransactions([rlpEncoded])
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature, mTxObj?.signatures[0])
    }
    
    public func test_combine_multipleSignature() throws {
        let expectedRLPEncoded = "0x3af90112018505d21dba00830249f094158a98f884e6f5a2731049569cb895cc1c75b47b1ef8d5f845820fe9a0879126759f424c790069e47d443c44674f4c2154d1e6f4f02134dbc56a6629f1a04b714b50c900b0b099b3e3ba15743654e8c576aa4fe504da38015f4c61757590f845820feaa00a5a7ad842672b62c26be2fae2644e9219bdf4baa2f7ea7745c74bab89fa1ff5a054ea57f591aea4d240da909e338b8df7c13a640d731eaaf785ca647c259066c5f845820fe9a0b871f4760b53fcba095b10979ae8b950e2692c1a526cd6f13c91401dde45d228a01aad1aa4f8efdfb9ab22cee80e0071ee3c6f5e8ad9b54ea79287b9f5631f30f1940000000000000000000000000000000000000000c4c3018080"
        
        let expectedSignature = [
            SignatureData(
                    "0x0fe9",
                    "0x879126759f424c790069e47d443c44674f4c2154d1e6f4f02134dbc56a6629f1",
                    "0x4b714b50c900b0b099b3e3ba15743654e8c576aa4fe504da38015f4c61757590"
            ),
            SignatureData(
                    "0x0fea",
                    "0x0a5a7ad842672b62c26be2fae2644e9219bdf4baa2f7ea7745c74bab89fa1ff5",
                    "0x54ea57f591aea4d240da909e338b8df7c13a640d731eaaf785ca647c259066c5"
            ),
            SignatureData(
                    "0x0fe9",
                    "0xb871f4760b53fcba095b10979ae8b950e2692c1a526cd6f13c91401dde45d228",
                    "0x1aad1aa4f8efdfb9ab22cee80e0071ee3c6f5e8ad9b54ea79287b9f5631f30f1"
            )
        ]
        
        let rlpEncodedString = [
            "0x3af870018505d21dba00830249f094158a98f884e6f5a2731049569cb895cc1c75b47b1ef847f845820feaa00a5a7ad842672b62c26be2fae2644e9219bdf4baa2f7ea7745c74bab89fa1ff5a054ea57f591aea4d240da909e338b8df7c13a640d731eaaf785ca647c259066c580c4c3018080",
            "0x3af870018505d21dba00830249f094158a98f884e6f5a2731049569cb895cc1c75b47b1ef847f845820fe9a0b871f4760b53fcba095b10979ae8b950e2692c1a526cd6f13c91401dde45d228a01aad1aa4f8efdfb9ab22cee80e0071ee3c6f5e8ad9b54ea79287b9f5631f30f180c4c3018080"
        ]
        
        let senderSignatureData = SignatureData(
            "0x0fe9",
            "0x879126759f424c790069e47d443c44674f4c2154d1e6f4f02134dbc56a6629f1",
            "0x4b714b50c900b0b099b3e3ba15743654e8c576aa4fe504da38015f4c61757590"
        )
        
        mTxObj = try FeeDelegatedCancelWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
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
        let expectedRLPEncoded = "0x3af884018505d21dba00830249f094158a98f884e6f5a2731049569cb895cc1c75b47b1ec4c301808094c01f48a99539a743256dc02dcfa9d0f5f075a5e4f847f845820feaa061eba44b0175713e33867e2dde40aa8f73c67ecd50cf682dd879653a3e773727a055819bfb65b0a74de90e345fb6a5055872a370bf3cbead2d7bd5e43837bf746d"
        
        let expectedSignature = SignatureData(
            "0x0fea",
            "0x61eba44b0175713e33867e2dde40aa8f73c67ecd50cf682dd879653a3e773727",
            "0x55819bfb65b0a74de90e345fb6a5055872a370bf3cbead2d7bd5e43837bf746d"
        )
        
        let rlpEncoded = "0x3af884018505d21dba00830249f094158a98f884e6f5a2731049569cb895cc1c75b47b1ec4c301808094c01f48a99539a743256dc02dcfa9d0f5f075a5e4f847f845820feaa061eba44b0175713e33867e2dde40aa8f73c67ecd50cf682dd879653a3e773727a055819bfb65b0a74de90e345fb6a5055872a370bf3cbead2d7bd5e43837bf746d"
        
        mTxObj = try FeeDelegatedCancelWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setFeeRatio(feeRatio)
            .build()
        
        let combined = try mTxObj!.combineSignedRawTransactions([rlpEncoded])
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature, mTxObj?.feePayerSignatures[0])
    }
    
    public func test_combineSignature_multipleFeePayerSignature() throws {
        let expectedRLPEncoded = "0x3af90112018505d21dba00830249f094158a98f884e6f5a2731049569cb895cc1c75b47b1ec4c301808094c01f48a99539a743256dc02dcfa9d0f5f075a5e4f8d5f845820feaa061eba44b0175713e33867e2dde40aa8f73c67ecd50cf682dd879653a3e773727a055819bfb65b0a74de90e345fb6a5055872a370bf3cbead2d7bd5e43837bf746df845820fe9a0615be8124c6af821b6aec61b2021ebf7d677a38188c74d6324f21cd8ed3243dea0235142496683c0ff1352fe7f20bc83af7229b30be73ce895f040395ef5dfca66f845820feaa0499e8cb92c800fc1437d64697c8c6c96a8455f30c654656a7ebf1b69f7aa8679a07f56c052fd2a8701705846d7313872afe85195087c06da4e3ed6c546eeb30259"
        
        let expectedSignature = [
            SignatureData(
                "0x0fea",
                "0x61eba44b0175713e33867e2dde40aa8f73c67ecd50cf682dd879653a3e773727",
                "0x55819bfb65b0a74de90e345fb6a5055872a370bf3cbead2d7bd5e43837bf746d"
            ),
            SignatureData(
                "0x0fe9",
                "0x615be8124c6af821b6aec61b2021ebf7d677a38188c74d6324f21cd8ed3243de",
                "0x235142496683c0ff1352fe7f20bc83af7229b30be73ce895f040395ef5dfca66"
            ),
            SignatureData(
                "0x0fea",
                "0x499e8cb92c800fc1437d64697c8c6c96a8455f30c654656a7ebf1b69f7aa8679",
                "0x7f56c052fd2a8701705846d7313872afe85195087c06da4e3ed6c546eeb30259"
            )
        ]
        
        let rlpEncodedString = [
            "0x3af884018505d21dba00830249f094158a98f884e6f5a2731049569cb895cc1c75b47b1ec4c301808094c01f48a99539a743256dc02dcfa9d0f5f075a5e4f847f845820fe9a0615be8124c6af821b6aec61b2021ebf7d677a38188c74d6324f21cd8ed3243dea0235142496683c0ff1352fe7f20bc83af7229b30be73ce895f040395ef5dfca66",
            "0x3af884018505d21dba00830249f094158a98f884e6f5a2731049569cb895cc1c75b47b1ec4c301808094c01f48a99539a743256dc02dcfa9d0f5f075a5e4f847f845820feaa0499e8cb92c800fc1437d64697c8c6c96a8455f30c654656a7ebf1b69f7aa8679a07f56c052fd2a8701705846d7313872afe85195087c06da4e3ed6c546eeb30259"
        ]
        
        let feePayer = "0xc01f48a99539a743256dc02dcfa9d0f5f075a5e4"
        let feePayerSignatureData = SignatureData(
            "0x0fea",
            "0x61eba44b0175713e33867e2dde40aa8f73c67ecd50cf682dd879653a3e773727",
            "0x55819bfb65b0a74de90e345fb6a5055872a370bf3cbead2d7bd5e43837bf746d"
        )
        
        mTxObj = try FeeDelegatedCancelWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
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
        mTxObj = try FeeDelegatedCancelWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setFeeRatio(feeRatio)
            .build()
        
        let rlpEncodedString = "0x3af8fe018505d21dba00830249f094158a98f884e6f5a2731049569cb895cc1c75b47b1ef8d5f845820fe9a0879126759f424c790069e47d443c44674f4c2154d1e6f4f02134dbc56a6629f1a04b714b50c900b0b099b3e3ba15743654e8c576aa4fe504da38015f4c61757590f845820feaa00a5a7ad842672b62c26be2fae2644e9219bdf4baa2f7ea7745c74bab89fa1ff5a054ea57f591aea4d240da909e338b8df7c13a640d731eaaf785ca647c259066c5f845820fe9a0b871f4760b53fcba095b10979ae8b950e2692c1a526cd6f13c91401dde45d228a01aad1aa4f8efdfb9ab22cee80e0071ee3c6f5e8ad9b54ea79287b9f5631f30f180c4c3018080"
        
        let expectedSignature = [
            SignatureData(
                    "0x0fe9",
                    "0x879126759f424c790069e47d443c44674f4c2154d1e6f4f02134dbc56a6629f1",
                    "0x4b714b50c900b0b099b3e3ba15743654e8c576aa4fe504da38015f4c61757590"
            ),
            SignatureData(
                    "0x0fea",
                    "0x0a5a7ad842672b62c26be2fae2644e9219bdf4baa2f7ea7745c74bab89fa1ff5",
                    "0x54ea57f591aea4d240da909e338b8df7c13a640d731eaaf785ca647c259066c5"
            ),
            SignatureData(
                    "0x0fe9",
                    "0xb871f4760b53fcba095b10979ae8b950e2692c1a526cd6f13c91401dde45d228",
                    "0x1aad1aa4f8efdfb9ab22cee80e0071ee3c6f5e8ad9b54ea79287b9f5631f30f1"
            )
        ]
        
        _ = try mTxObj!.combineSignedRawTransactions([rlpEncodedString])
        
        let rlpEncodedStringsWithFeePayerSignatures = "0x3af90112018505d21dba00830249f094158a98f884e6f5a2731049569cb895cc1c75b47b1ec4c301808094c01f48a99539a743256dc02dcfa9d0f5f075a5e4f8d5f845820feaa061eba44b0175713e33867e2dde40aa8f73c67ecd50cf682dd879653a3e773727a055819bfb65b0a74de90e345fb6a5055872a370bf3cbead2d7bd5e43837bf746df845820fe9a0615be8124c6af821b6aec61b2021ebf7d677a38188c74d6324f21cd8ed3243dea0235142496683c0ff1352fe7f20bc83af7229b30be73ce895f040395ef5dfca66f845820feaa0499e8cb92c800fc1437d64697c8c6c96a8455f30c654656a7ebf1b69f7aa8679a07f56c052fd2a8701705846d7313872afe85195087c06da4e3ed6c546eeb30259"
        
        let expectedFeePayerSignatures = [
            SignatureData(
                    "0x0fea",
                    "0x61eba44b0175713e33867e2dde40aa8f73c67ecd50cf682dd879653a3e773727",
                    "0x55819bfb65b0a74de90e345fb6a5055872a370bf3cbead2d7bd5e43837bf746d"
            ),
            SignatureData(
                    "0x0fe9",
                    "0x615be8124c6af821b6aec61b2021ebf7d677a38188c74d6324f21cd8ed3243de",
                    "0x235142496683c0ff1352fe7f20bc83af7229b30be73ce895f040395ef5dfca66"
            ),
            SignatureData(
                    "0x0fea",
                    "0x499e8cb92c800fc1437d64697c8c6c96a8455f30c654656a7ebf1b69f7aa8679",
                    "0x7f56c052fd2a8701705846d7313872afe85195087c06da4e3ed6c546eeb30259"
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
        mTxObj = try FeeDelegatedCancelWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setFeeRatio(feeRatio)
            .build()
        
        let rlpEncoded = "0x3af870018505d21dba00830249f094158a98f884e6f5a2731049569cb895cc1c75b47b1ef847f845820fe9a0879126759f424c790069e47d443c44674f4c2154d1e6f4f02134dbc56a6629f1a04b714b50c900b0b099b3e3ba15743654e8c576aa4fe504da38015f4c6175759080c4c3018080"
        
        XCTAssertThrowsError(try mTxObj!.combineSignedRawTransactions([rlpEncoded])) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("Transactions containing different information cannot be combined."))
        }
    }
}

class FeeDelegatedCancelWithRatioTest_getRawTransactionTest: XCTestCase {
    var mTxObj: FeeDelegatedCancelWithRatio?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedCancelWithRatioTest.feePayerPrivateKey
    
    let from = FeeDelegatedCancelWithRatioTest.from
    let account = FeeDelegatedCancelWithRatioTest.account
    let to = FeeDelegatedCancelWithRatioTest.to
    let gas = FeeDelegatedCancelWithRatioTest.gas
    let nonce = FeeDelegatedCancelWithRatioTest.nonce
    let gasPrice = FeeDelegatedCancelWithRatioTest.gasPrice
    let chainID = FeeDelegatedCancelWithRatioTest.chainID
    let value = FeeDelegatedCancelWithRatioTest.value
    let input = FeeDelegatedCancelWithRatioTest.input
    let humanReadable = FeeDelegatedCancelWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedCancelWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedCancelWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedCancelWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedCancelWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedCancelWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedCancelWithRatioTest.expectedRLPEncoding
    
    public func test_getRawTransaction() throws {
        let txObj = try FeeDelegatedCancelWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()

        XCTAssertEqual(expectedRLPEncoding, try txObj.getRawTransaction())
    }
}

class FeeDelegatedCancelWithRatioTest_getTransactionHashTest: XCTestCase {
    var mTxObj: FeeDelegatedCancelWithRatio?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedCancelWithRatioTest.feePayerPrivateKey
    
    let from = FeeDelegatedCancelWithRatioTest.from
    let account = FeeDelegatedCancelWithRatioTest.account
    let to = FeeDelegatedCancelWithRatioTest.to
    let gas = FeeDelegatedCancelWithRatioTest.gas
    let nonce = FeeDelegatedCancelWithRatioTest.nonce
    let gasPrice = FeeDelegatedCancelWithRatioTest.gasPrice
    let chainID = FeeDelegatedCancelWithRatioTest.chainID
    let value = FeeDelegatedCancelWithRatioTest.value
    let input = FeeDelegatedCancelWithRatioTest.input
    let humanReadable = FeeDelegatedCancelWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedCancelWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedCancelWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedCancelWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedCancelWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedCancelWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedCancelWithRatioTest.expectedRLPEncoding
    let expectedTransactionHash = FeeDelegatedCancelWithRatioTest.expectedTransactionHash
            
    public func test_getTransactionHash() throws {
        let txObj = try FeeDelegatedCancelWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
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
        
        mTxObj = try FeeDelegatedCancelWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
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
        
        mTxObj = try FeeDelegatedCancelWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
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

class FeeDelegatedCancelWithRatioTest_getSenderTxHashTest: XCTestCase {
    var mTxObj: FeeDelegatedCancelWithRatio?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedCancelWithRatioTest.feePayerPrivateKey
    
    let from = FeeDelegatedCancelWithRatioTest.from
    let account = FeeDelegatedCancelWithRatioTest.account
    let to = FeeDelegatedCancelWithRatioTest.to
    let gas = FeeDelegatedCancelWithRatioTest.gas
    let nonce = FeeDelegatedCancelWithRatioTest.nonce
    let gasPrice = FeeDelegatedCancelWithRatioTest.gasPrice
    let chainID = FeeDelegatedCancelWithRatioTest.chainID
    let value = FeeDelegatedCancelWithRatioTest.value
    let input = FeeDelegatedCancelWithRatioTest.input
    let humanReadable = FeeDelegatedCancelWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedCancelWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedCancelWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedCancelWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedCancelWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedCancelWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedCancelWithRatioTest.expectedRLPEncoding
    let expectedTransactionHash = FeeDelegatedCancelWithRatioTest.expectedTransactionHash
    let expectedSenderTransactionHash = FeeDelegatedCancelWithRatioTest.expectedRLPSenderTransactionHash
            
    public func test_getRLPEncodingForSignature() throws {
        mTxObj = try FeeDelegatedCancelWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
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
        
        mTxObj = try FeeDelegatedCancelWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
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
        
        mTxObj = try FeeDelegatedCancelWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
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

class FeeDelegatedCancelWithRatioTest_getRLPEncodingForFeePayerSignatureTest: XCTestCase {
    var mTxObj: FeeDelegatedCancelWithRatio?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedCancelWithRatioTest.feePayerPrivateKey
    
    let from = FeeDelegatedCancelWithRatioTest.from
    let account = FeeDelegatedCancelWithRatioTest.account
    let to = FeeDelegatedCancelWithRatioTest.to
    let gas = FeeDelegatedCancelWithRatioTest.gas
    let nonce = FeeDelegatedCancelWithRatioTest.nonce
    let gasPrice = FeeDelegatedCancelWithRatioTest.gasPrice
    let chainID = FeeDelegatedCancelWithRatioTest.chainID
    let value = FeeDelegatedCancelWithRatioTest.value
    let input = FeeDelegatedCancelWithRatioTest.input
    let humanReadable = FeeDelegatedCancelWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedCancelWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedCancelWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedCancelWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedCancelWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedCancelWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedCancelWithRatioTest.expectedRLPEncoding
    let expectedTransactionHash = FeeDelegatedCancelWithRatioTest.expectedTransactionHash
    let expectedSenderTransactionHash = FeeDelegatedCancelWithRatioTest.expectedRLPSenderTransactionHash
    let expectedRLPEncodingForFeePayerSigning = FeeDelegatedCancelWithRatioTest.expectedRLPEncodingForFeePayerSigning
            
    public func test_getRLPEncodingForSignature() throws {
        mTxObj = try FeeDelegatedCancelWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
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
        
        mTxObj = try FeeDelegatedCancelWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
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
        
        mTxObj = try FeeDelegatedCancelWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
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
        
        mTxObj = try FeeDelegatedCancelWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
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
