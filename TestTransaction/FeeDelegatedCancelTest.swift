//
//  FeeDelegatedCancelTest.swift
//  CaverSwiftTests
//
//  Created by won on 2021/07/15.
//

import XCTest
@testable import CaverSwift

class FeeDelegatedCancelTest: XCTestCase {
    static let caver = Caver(Caver.DEFAULT_URL)
    
    static let senderPrivateKey = "0x45a915e4d060149eb4365960e6a7a45f334393093061116b197e3240065ff2d8"
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

    static let senderSignatureData = SignatureData(
        "0x26",
        "0x8409f5441d4725f90905ad87f03793857d124de7a43169bc67320cd2f020efa9",
        "0x60af63e87bdc565d7f7de906916b2334336ee7b24d9a71c9521a67df02e7ec92"
    )
    static let feePayer = "0x5A0043070275d9f6054307Ee7348bD660849D90f"
    static let feePayerSignatureData = SignatureData(
        "0x26",
        "0x44d5b25e8c649a1fdaa409dc3817be390ad90a17c25bc17c89b6d5d248495e0",
        "0x73938e690d27b5267c73108352cf12d01de7fd0077b388e94721aa1fa32f85ec"
    )

    static let expectedRLPEncoding = "0x39f8c08204d219830f424094a94f5374fce5edbc8e2a8697c15331677e6ebf0bf845f84326a08409f5441d4725f90905ad87f03793857d124de7a43169bc67320cd2f020efa9a060af63e87bdc565d7f7de906916b2334336ee7b24d9a71c9521a67df02e7ec92945a0043070275d9f6054307ee7348bd660849d90ff845f84326a0044d5b25e8c649a1fdaa409dc3817be390ad90a17c25bc17c89b6d5d248495e0a073938e690d27b5267c73108352cf12d01de7fd0077b388e94721aa1fa32f85ec"
    static let expectedTransactionHash = "0x96b39d3ab849127d31a5f7b5c882ca9ba408cd9d875052640d51a64f8c4acbb2"
    static let expectedSenderTransactionHash = "0xcc6c2673398903b3d906a3023b41636fc08bd1bddd5aa1602116091638f48447"
    static let expectedRLPEncodingForFeePayerSigning = "0xf8389fde398204d219830f424094a94f5374fce5edbc8e2a8697c15331677e6ebf0b945a0043070275d9f6054307ee7348bd660849d90f018080"
        
    public static func generateRoleBaseKeyring(_ numArr: [Int], _ address: String) throws -> AbstractKeyring {
        let keyArr = KeyringFactory.generateRoleBasedKeys(numArr, "entropy")
        return try KeyringFactory.createWithRoleBasedKey(address, keyArr)
    }
}

class FeeDelegatedCancelTest_createInstanceBuilder: XCTestCase {
    let from = FeeDelegatedCancelTest.from
    let account = FeeDelegatedCancelTest.account
    let to = FeeDelegatedCancelTest.to
    let gas = FeeDelegatedCancelTest.gas
    let nonce = FeeDelegatedCancelTest.nonce
    let gasPrice = FeeDelegatedCancelTest.gasPrice
    let chainID = FeeDelegatedCancelTest.chainID
    let value = FeeDelegatedCancelTest.value
    let input = FeeDelegatedCancelTest.input
    let humanReadable = FeeDelegatedCancelTest.humanReadable
    let codeFormat = FeeDelegatedCancelTest.codeFormat
    let senderSignatureData = FeeDelegatedCancelTest.senderSignatureData
    let feePayer = FeeDelegatedCancelTest.feePayer
    let feePayerSignatureData = FeeDelegatedCancelTest.feePayerSignatureData
        
    public func test_BuilderTest() throws {
        let txObj = try FeeDelegatedCancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertNotNil(txObj)
    }
    
    public func test_BuilderWithRPCTest() throws {
        let txObj = try FeeDelegatedCancel.Builder()
            .setKlaytnCall(FeeDelegatedCancelTest.caver.rpc.klay)
            .setGas(gas)
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
        let txObj = try FeeDelegatedCancel.Builder()
            .setNonce(BigInt(hex: nonce)!)
            .setGas(BigInt(hex: gas)!)
            .setGasPrice(BigInt(hex: gasPrice)!)
            .setChainId(BigInt(hex: chainID)!)
            .setFrom(from)
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
        XCTAssertThrowsError(try FeeDelegatedCancel.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
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
        XCTAssertThrowsError(try FeeDelegatedCancel.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setFeePayer(feePayer)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("from is missing."))
        }
    }
        
    public func test_throwException_invalidGas() throws {
        let gas = "invalid gas"
        XCTAssertThrowsError(try FeeDelegatedCancel.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
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
        XCTAssertThrowsError(try FeeDelegatedCancel.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
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
        XCTAssertThrowsError(try FeeDelegatedCancel.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setFeePayer(feePayer)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("feePayer is missing: feePayer must be defined with feePayerSignatures."))
        }
    }
}

class FeeDelegatedCancelTest_createInstance: XCTestCase {
    let from = FeeDelegatedCancelTest.from
    let account = FeeDelegatedCancelTest.account
    let to = FeeDelegatedCancelTest.to
    let gas = FeeDelegatedCancelTest.gas
    let nonce = FeeDelegatedCancelTest.nonce
    let gasPrice = FeeDelegatedCancelTest.gasPrice
    let chainID = FeeDelegatedCancelTest.chainID
    let value = FeeDelegatedCancelTest.value
    let input = FeeDelegatedCancelTest.input
    let humanReadable = FeeDelegatedCancelTest.humanReadable
    let codeFormat = FeeDelegatedCancelTest.codeFormat
    let senderSignatureData = FeeDelegatedCancelTest.senderSignatureData
    let feePayer = FeeDelegatedCancelTest.feePayer
    let feePayerSignatureData = FeeDelegatedCancelTest.feePayerSignatureData
    
    public func test_createInstance() throws {
        let txObj = try FeeDelegatedCancel(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData]
        )
        
        XCTAssertNotNil(txObj)
    }
    
    public func test_throwException_invalidFrom() throws {
        let from = "invalid Address"
        XCTAssertThrowsError(try FeeDelegatedCancel(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData]
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(from)"))
        }
    }
    
    public func test_throwException_missingFrom() throws {
        let from = ""
        XCTAssertThrowsError(try FeeDelegatedCancel(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData]
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("from is missing."))
        }
    }
    
    public func test_throwException_invalidGas() throws {
        let gas = "invalid gas"
        XCTAssertThrowsError(try FeeDelegatedCancel(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData]
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid gas. : \(gas)"))
        }
    }
    
    public func test_throwException_missingGas() throws {
        let gas = ""
        XCTAssertThrowsError(try FeeDelegatedCancel(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData]
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("gas is missing."))
        }
    }
    
    public func test_throwException_setFeePayerSignatures_missingFeePayer() throws {
        let feePayer = ""
        XCTAssertThrowsError(try FeeDelegatedCancel(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData]
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("feePayer is missing: feePayer must be defined with feePayerSignatures."))
        }
    }
}

class FeeDelegatedCancelTest_getRLPEncodingTest: XCTestCase {
    let from = FeeDelegatedCancelTest.from
    let account = FeeDelegatedCancelTest.account
    let to = FeeDelegatedCancelTest.to
    let gas = FeeDelegatedCancelTest.gas
    let nonce = FeeDelegatedCancelTest.nonce
    let gasPrice = FeeDelegatedCancelTest.gasPrice
    let chainID = FeeDelegatedCancelTest.chainID
    let value = FeeDelegatedCancelTest.value
    let input = FeeDelegatedCancelTest.input
    let humanReadable = FeeDelegatedCancelTest.humanReadable
    let codeFormat = FeeDelegatedCancelTest.codeFormat
    let senderSignatureData = FeeDelegatedCancelTest.senderSignatureData
    let feePayer = FeeDelegatedCancelTest.feePayer
    let feePayerSignatureData = FeeDelegatedCancelTest.feePayerSignatureData
    
    let expectedRLPEncoding = FeeDelegatedCancelTest.expectedRLPEncoding
        
    public func test_getRLPEncoding() throws {
        let txObj = try FeeDelegatedCancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertEqual(expectedRLPEncoding, try txObj.getRLPEncoding())
    }
    
    public func test_throwException_NoNonce() throws {
        let txObj = try FeeDelegatedCancel.Builder()
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
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
        let txObj = try FeeDelegatedCancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setChainId(chainID)
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

class FeeDelegatedCancelTest_signAsFeePayer_OneKeyTest: XCTestCase {
    var mTxObj: FeeDelegatedCancel?
    var klaytnWalletKey: String?
    var keyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedCancelTest.feePayerPrivateKey
        
    let from = FeeDelegatedCancelTest.from
    let account = FeeDelegatedCancelTest.account
    let to = FeeDelegatedCancelTest.to
    let gas = FeeDelegatedCancelTest.gas
    let nonce = FeeDelegatedCancelTest.nonce
    let gasPrice = FeeDelegatedCancelTest.gasPrice
    let chainID = FeeDelegatedCancelTest.chainID
    let value = FeeDelegatedCancelTest.value
    let input = FeeDelegatedCancelTest.input
    let humanReadable = FeeDelegatedCancelTest.humanReadable
    let codeFormat = FeeDelegatedCancelTest.codeFormat
    let senderSignatureData = FeeDelegatedCancelTest.senderSignatureData
    let feePayer = FeeDelegatedCancelTest.feePayer
    let feePayerSignatureData = FeeDelegatedCancelTest.feePayerSignatureData
    
    let expectedRLPEncoding = FeeDelegatedCancelTest.expectedRLPEncoding
        
    override func setUpWithError() throws {
        mTxObj = try FeeDelegatedCancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .build()
        
        keyring = try KeyringFactory.createWithSingleKey(feePayer, feePayerPrivateKey)
        klaytnWalletKey = try keyring?.getKlaytnWalletKey()
    }
    
    public func test_signAsFeePayer_String() throws {
        let feePayer = try PrivateKey(privateKey).getDerivedAddress()
        
        mTxObj = try FeeDelegatedCancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setFeePayer(feePayer)
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

class FeeDelegatedCancelTest_signAsFeePayer_AllKeyTest: XCTestCase {
    var mTxObj: FeeDelegatedCancel?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedCancelTest.feePayerPrivateKey
        
    let from = FeeDelegatedCancelTest.from
    let account = FeeDelegatedCancelTest.account
    let to = FeeDelegatedCancelTest.to
    let gas = FeeDelegatedCancelTest.gas
    let nonce = FeeDelegatedCancelTest.nonce
    let gasPrice = FeeDelegatedCancelTest.gasPrice
    let chainID = FeeDelegatedCancelTest.chainID
    let value = FeeDelegatedCancelTest.value
    let input = FeeDelegatedCancelTest.input
    let humanReadable = FeeDelegatedCancelTest.humanReadable
    let codeFormat = FeeDelegatedCancelTest.codeFormat
    let senderSignatureData = FeeDelegatedCancelTest.senderSignatureData
    let feePayer = FeeDelegatedCancelTest.feePayer
    let feePayerSignatureData = FeeDelegatedCancelTest.feePayerSignatureData
    
    let expectedRLPEncoding = FeeDelegatedCancelTest.expectedRLPEncoding
        
    override func setUpWithError() throws {
        mTxObj = try FeeDelegatedCancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
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

class FeeDelegatedCancelTest_appendFeePayerSignaturesTest: XCTestCase {
    var mTxObj: FeeDelegatedCancel?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = FeeDelegatedCancelTest.senderPrivateKey
    let feePayerPrivateKey = FeeDelegatedCancelTest.feePayerPrivateKey
        
    let from = FeeDelegatedCancelTest.from
    let account = FeeDelegatedCancelTest.account
    let to = FeeDelegatedCancelTest.to
    let gas = FeeDelegatedCancelTest.gas
    let nonce = FeeDelegatedCancelTest.nonce
    let gasPrice = FeeDelegatedCancelTest.gasPrice
    let chainID = FeeDelegatedCancelTest.chainID
    let value = FeeDelegatedCancelTest.value
    let input = FeeDelegatedCancelTest.input
    let humanReadable = FeeDelegatedCancelTest.humanReadable
    let codeFormat = FeeDelegatedCancelTest.codeFormat
    let senderSignatureData = FeeDelegatedCancelTest.senderSignatureData
    let feePayer = FeeDelegatedCancelTest.feePayer
    let feePayerSignatureData = FeeDelegatedCancelTest.feePayerSignatureData
    
    override func setUpWithError() throws {
        mTxObj = try FeeDelegatedCancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
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
        mTxObj = try FeeDelegatedCancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setFeePayer(feePayer)
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
        
        mTxObj = try FeeDelegatedCancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
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
        
        mTxObj = try FeeDelegatedCancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
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

class FeeDelegatedCancelTest_combineSignatureTest: XCTestCase {
    var mTxObj: FeeDelegatedCancel?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = FeeDelegatedCancelTest.senderPrivateKey
    let from = "0xdcad313f2bf2240dbdb243eaf5eee2f512e0bfd1"
    var account: Account?
    let to = "0x8723590d5D60e35f7cE0Db5C09D3938b26fF80Ae"
    let gas = "0xdbba0"
    let nonce = "0x1"
    let gasPrice = "0x5d21dba00"
    let chainID = "0x7e3"
    let value = BigInt(1)
    let input = "0x68656c6c6f"
    let humanReadable = FeeDelegatedCancelTest.humanReadable
    let codeFormat = FeeDelegatedCancelTest.codeFormat
    let senderSignatureData = FeeDelegatedCancelTest.senderSignatureData
    let feePayer = FeeDelegatedCancelTest.feePayer
    let feePayerSignatureData = FeeDelegatedCancelTest.feePayerSignatureData
    let expectedRLPEncoding = FeeDelegatedCancelTest.expectedRLPEncoding
    
    override func setUpWithError() throws {
        account = Account.createWithAccountKeyLegacy(from)
                
        mTxObj = try FeeDelegatedCancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .build()
    }
    
    public func test_combineSignature() throws {
        let expectedRLPEncoded = "0x39f883018505d21dba00830dbba094dcad313f2bf2240dbdb243eaf5eee2f512e0bfd1f847f845820fe9a04d9bf7a8bd15a41143eeecd3c39691cdc151b50d641534f0c73055849f7abca1a07123185b4cc046eb6a78e1ee370c059dfe437012098ebe18379685acd907606f940000000000000000000000000000000000000000c4c3018080"
        
        let expectedSignature = SignatureData(
            "0x0fe9",
            "0x4d9bf7a8bd15a41143eeecd3c39691cdc151b50d641534f0c73055849f7abca1",
            "0x7123185b4cc046eb6a78e1ee370c059dfe437012098ebe18379685acd907606f"
        )
        
        let rlpEncoded = "0x39f883018505d21dba00830dbba094dcad313f2bf2240dbdb243eaf5eee2f512e0bfd1f847f845820fe9a04d9bf7a8bd15a41143eeecd3c39691cdc151b50d641534f0c73055849f7abca1a07123185b4cc046eb6a78e1ee370c059dfe437012098ebe18379685acd907606f940000000000000000000000000000000000000000c4c3018080"
        
        let combined = try mTxObj!.combineSignedRawTransactions([rlpEncoded])
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature, mTxObj?.signatures[0])
    }
    
    public func test_combine_multipleSignature() throws {
        let expectedRLPEncoded = "0x39f90111018505d21dba00830dbba094dcad313f2bf2240dbdb243eaf5eee2f512e0bfd1f8d5f845820fe9a04d9bf7a8bd15a41143eeecd3c39691cdc151b50d641534f0c73055849f7abca1a07123185b4cc046eb6a78e1ee370c059dfe437012098ebe18379685acd907606ff845820fe9a0205d4f6f758629da5eb25d1d572e82430243e00096ed64097b6d0031847bf792a0280ce8a79438c699fce0417403e8892e46e10da764b16876091ef0965c1ce1dff845820feaa02f3c7b7aebd6c9af7a5b4259f0ea77d96362efbdca397b9f17e3c6924296c53fa00e4197ba6e38cecf99715f523c1805a58559072f944443bad1152dee73bfb167940000000000000000000000000000000000000000c4c3018080"
        
        let expectedSignature = [
            SignatureData(
                "0x0fe9",
                "0x4d9bf7a8bd15a41143eeecd3c39691cdc151b50d641534f0c73055849f7abca1",
                "0x7123185b4cc046eb6a78e1ee370c059dfe437012098ebe18379685acd907606f"
            ),
            SignatureData(
                "0x0fe9",
                "0x205d4f6f758629da5eb25d1d572e82430243e00096ed64097b6d0031847bf792",
                "0x280ce8a79438c699fce0417403e8892e46e10da764b16876091ef0965c1ce1df"
            ),
            SignatureData(
                "0x0fea",
                "0x2f3c7b7aebd6c9af7a5b4259f0ea77d96362efbdca397b9f17e3c6924296c53f",
                "0x0e4197ba6e38cecf99715f523c1805a58559072f944443bad1152dee73bfb167"
            )
        ]
        
        let rlpEncodedString = [
            "0x39f86f018505d21dba00830dbba094dcad313f2bf2240dbdb243eaf5eee2f512e0bfd1f847f845820fe9a0205d4f6f758629da5eb25d1d572e82430243e00096ed64097b6d0031847bf792a0280ce8a79438c699fce0417403e8892e46e10da764b16876091ef0965c1ce1df80c4c3018080",
            "0x39f86f018505d21dba00830dbba094dcad313f2bf2240dbdb243eaf5eee2f512e0bfd1f847f845820feaa02f3c7b7aebd6c9af7a5b4259f0ea77d96362efbdca397b9f17e3c6924296c53fa00e4197ba6e38cecf99715f523c1805a58559072f944443bad1152dee73bfb16780c4c3018080"
        ]
        
        let senderSignatureData = SignatureData(
            "0x0fe9",
            "0x4d9bf7a8bd15a41143eeecd3c39691cdc151b50d641534f0c73055849f7abca1",
            "0x7123185b4cc046eb6a78e1ee370c059dfe437012098ebe18379685acd907606f"
        )
        
        mTxObj = try FeeDelegatedCancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
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
        let expectedRLPEncoded = "0x39f883018505d21dba00830dbba094dcad313f2bf2240dbdb243eaf5eee2f512e0bfd1c4c3018080946f89ec285c52a3e092cdb017e125a9b197e78dc7f847f845820fe9a0a4ca740e08115db092a79ce902bdac45347a3d34a74ea0fcc371ccf01269ca43a029e095bf3f9e0be7e2130fe6985419114958877412b46b5b4243cc39380c5028"
        
        let expectedSignature = SignatureData(
            "0x0fe9",
            "0xa4ca740e08115db092a79ce902bdac45347a3d34a74ea0fcc371ccf01269ca43",
            "0x29e095bf3f9e0be7e2130fe6985419114958877412b46b5b4243cc39380c5028"
        )
        
        let rlpEncoded = "0x39f883018505d21dba00830dbba094dcad313f2bf2240dbdb243eaf5eee2f512e0bfd1c4c3018080946f89ec285c52a3e092cdb017e125a9b197e78dc7f847f845820fe9a0a4ca740e08115db092a79ce902bdac45347a3d34a74ea0fcc371ccf01269ca43a029e095bf3f9e0be7e2130fe6985419114958877412b46b5b4243cc39380c5028"
        
        mTxObj = try FeeDelegatedCancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .build()
        
        let combined = try mTxObj!.combineSignedRawTransactions([rlpEncoded])
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature, mTxObj?.feePayerSignatures[0])
    }
    
    public func test_combineSignature_multipleFeePayerSignature() throws {
        let expectedRLPEncoded = "0x39f90111018505d21dba00830dbba094dcad313f2bf2240dbdb243eaf5eee2f512e0bfd1c4c3018080946f89ec285c52a3e092cdb017e125a9b197e78dc7f8d5f845820fe9a0a4ca740e08115db092a79ce902bdac45347a3d34a74ea0fcc371ccf01269ca43a029e095bf3f9e0be7e2130fe6985419114958877412b46b5b4243cc39380c5028f845820feaa09c86edd1b5d75ac1050a5a7494dece5f186b8e9654f75cf4942f7dca57fc2de0a032f306028776389107c40f1765679b2630f093b1c4f4fda9415f0c909c7addeff845820fe9a0392e7a5d2efbc7da9d114ce79797eebbe2007ece065109f7f93baed1e23bb22ca022e161a9f20c14b5830154e819cdaf59e8d82690b318afb19e2903b52020bb3e"
        
        let expectedSignature = [
            SignatureData(
                "0x0fe9",
                "0xa4ca740e08115db092a79ce902bdac45347a3d34a74ea0fcc371ccf01269ca43",
                "0x29e095bf3f9e0be7e2130fe6985419114958877412b46b5b4243cc39380c5028"
            ),
            SignatureData(
                "0x0fea",
                "0x9c86edd1b5d75ac1050a5a7494dece5f186b8e9654f75cf4942f7dca57fc2de0",
                "0x32f306028776389107c40f1765679b2630f093b1c4f4fda9415f0c909c7addef"
            ),
            SignatureData(
                "0x0fe9",
                "0x392e7a5d2efbc7da9d114ce79797eebbe2007ece065109f7f93baed1e23bb22c",
                "0x22e161a9f20c14b5830154e819cdaf59e8d82690b318afb19e2903b52020bb3e"
            )
        ]
        
        let rlpEncodedString = [
            "0x39f883018505d21dba00830dbba094dcad313f2bf2240dbdb243eaf5eee2f512e0bfd1c4c3018080946f89ec285c52a3e092cdb017e125a9b197e78dc7f847f845820feaa09c86edd1b5d75ac1050a5a7494dece5f186b8e9654f75cf4942f7dca57fc2de0a032f306028776389107c40f1765679b2630f093b1c4f4fda9415f0c909c7addef",
            "0x39f883018505d21dba00830dbba094dcad313f2bf2240dbdb243eaf5eee2f512e0bfd1c4c3018080946f89ec285c52a3e092cdb017e125a9b197e78dc7f847f845820fe9a0392e7a5d2efbc7da9d114ce79797eebbe2007ece065109f7f93baed1e23bb22ca022e161a9f20c14b5830154e819cdaf59e8d82690b318afb19e2903b52020bb3e"
        ]
        
        let feePayer = "0x6f89ec285c52a3e092cdb017e125a9b197e78dc7"
        let feePayerSignatureData = SignatureData(
            "0x0fe9",
            "0xa4ca740e08115db092a79ce902bdac45347a3d34a74ea0fcc371ccf01269ca43",
            "0x29e095bf3f9e0be7e2130fe6985419114958877412b46b5b4243cc39380c5028"
        )
        
        mTxObj = try FeeDelegatedCancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
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
    
    public func test_multipleSignature_senderSignatureData_feePayerSignature() throws {
        mTxObj = try FeeDelegatedCancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .build()
        
        let rlpEncodedString = "0x39f8fd018505d21dba00830dbba094dcad313f2bf2240dbdb243eaf5eee2f512e0bfd1f8d5f845820fe9a04d9bf7a8bd15a41143eeecd3c39691cdc151b50d641534f0c73055849f7abca1a07123185b4cc046eb6a78e1ee370c059dfe437012098ebe18379685acd907606ff845820fe9a0205d4f6f758629da5eb25d1d572e82430243e00096ed64097b6d0031847bf792a0280ce8a79438c699fce0417403e8892e46e10da764b16876091ef0965c1ce1dff845820feaa02f3c7b7aebd6c9af7a5b4259f0ea77d96362efbdca397b9f17e3c6924296c53fa00e4197ba6e38cecf99715f523c1805a58559072f944443bad1152dee73bfb16780c4c3018080"
        
        let expectedSignature = [
            SignatureData(
                "0x0fe9",
                "0x4d9bf7a8bd15a41143eeecd3c39691cdc151b50d641534f0c73055849f7abca1",
                "0x7123185b4cc046eb6a78e1ee370c059dfe437012098ebe18379685acd907606f"
            ),
            SignatureData(
                "0x0fe9",
                "0x205d4f6f758629da5eb25d1d572e82430243e00096ed64097b6d0031847bf792",
                "0x280ce8a79438c699fce0417403e8892e46e10da764b16876091ef0965c1ce1df"
            ),
            SignatureData(
                "0x0fea",
                "0x2f3c7b7aebd6c9af7a5b4259f0ea77d96362efbdca397b9f17e3c6924296c53f",
                "0x0e4197ba6e38cecf99715f523c1805a58559072f944443bad1152dee73bfb167"
            )
        ]
        
        _ = try mTxObj!.combineSignedRawTransactions([rlpEncodedString])
        
        let rlpEncodedStringsWithFeePayerSignatures = "0x39f90111018505d21dba00830dbba094dcad313f2bf2240dbdb243eaf5eee2f512e0bfd1c4c3018080946f89ec285c52a3e092cdb017e125a9b197e78dc7f8d5f845820fe9a0a4ca740e08115db092a79ce902bdac45347a3d34a74ea0fcc371ccf01269ca43a029e095bf3f9e0be7e2130fe6985419114958877412b46b5b4243cc39380c5028f845820feaa09c86edd1b5d75ac1050a5a7494dece5f186b8e9654f75cf4942f7dca57fc2de0a032f306028776389107c40f1765679b2630f093b1c4f4fda9415f0c909c7addeff845820fe9a0392e7a5d2efbc7da9d114ce79797eebbe2007ece065109f7f93baed1e23bb22ca022e161a9f20c14b5830154e819cdaf59e8d82690b318afb19e2903b52020bb3e"
        
        let expectedFeePayerSignatures = [
            SignatureData(
                "0x0fe9",
                "0xa4ca740e08115db092a79ce902bdac45347a3d34a74ea0fcc371ccf01269ca43",
                "0x29e095bf3f9e0be7e2130fe6985419114958877412b46b5b4243cc39380c5028"
            ),
            SignatureData(
                "0x0fea",
                "0x9c86edd1b5d75ac1050a5a7494dece5f186b8e9654f75cf4942f7dca57fc2de0",
                "0x32f306028776389107c40f1765679b2630f093b1c4f4fda9415f0c909c7addef"
            ),
            SignatureData(
                "0x0fe9",
                "0x392e7a5d2efbc7da9d114ce79797eebbe2007ece065109f7f93baed1e23bb22c",
                "0x22e161a9f20c14b5830154e819cdaf59e8d82690b318afb19e2903b52020bb3e"
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
        mTxObj = try FeeDelegatedCancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setFeePayer(feePayer)
            .build()
        
        let rlpEncoded = "0x39f86f018505d21dba00830dbba094dcad313f2bf2240dbdb243eaf5eee2f512e0bfd1f847f845820fe9a04d9bf7a8bd15a41143eeecd3c39691cdc151b50d641534f0c73055849f7abca1a07123185b4cc046eb6a78e1ee370c059dfe437012098ebe18379685acd907606f80c4c3018080"
        
        XCTAssertThrowsError(try mTxObj!.combineSignedRawTransactions([rlpEncoded])) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("Transactions containing different information cannot be combined."))
        }
    }
}

class FeeDelegatedCancelTest_getRawTransactionTest: XCTestCase {
    let privateKey = FeeDelegatedCancelTest.senderPrivateKey
    let feePayerPrivateKey = FeeDelegatedCancelTest.feePayerPrivateKey
        
    let from = FeeDelegatedCancelTest.from
    let account = FeeDelegatedCancelTest.account
    let to = FeeDelegatedCancelTest.to
    let gas = FeeDelegatedCancelTest.gas
    let nonce = FeeDelegatedCancelTest.nonce
    let gasPrice = FeeDelegatedCancelTest.gasPrice
    let chainID = FeeDelegatedCancelTest.chainID
    let value = FeeDelegatedCancelTest.value
    let input = FeeDelegatedCancelTest.input
    let humanReadable = FeeDelegatedCancelTest.humanReadable
    let codeFormat = FeeDelegatedCancelTest.codeFormat
    let senderSignatureData = FeeDelegatedCancelTest.senderSignatureData
    let feePayer = FeeDelegatedCancelTest.feePayer
    let feePayerSignatureData = FeeDelegatedCancelTest.feePayerSignatureData
    
    let expectedRLPEncoding = FeeDelegatedCancelTest.expectedRLPEncoding
    
    public func test_getRawTransaction() throws {
        let txObj = try FeeDelegatedCancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()

        XCTAssertEqual(expectedRLPEncoding, try txObj.getRawTransaction())
    }
}

class FeeDelegatedCancelTest_getTransactionHashTest: XCTestCase {
    var mTxObj: FeeDelegatedCancel?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = FeeDelegatedCancelTest.senderPrivateKey
    let feePayerPrivateKey = FeeDelegatedCancelTest.feePayerPrivateKey
        
    let from = FeeDelegatedCancelTest.from
    let account = FeeDelegatedCancelTest.account
    let to = FeeDelegatedCancelTest.to
    let gas = FeeDelegatedCancelTest.gas
    let nonce = FeeDelegatedCancelTest.nonce
    let gasPrice = FeeDelegatedCancelTest.gasPrice
    let chainID = FeeDelegatedCancelTest.chainID
    let value = FeeDelegatedCancelTest.value
    let input = FeeDelegatedCancelTest.input
    let humanReadable = FeeDelegatedCancelTest.humanReadable
    let codeFormat = FeeDelegatedCancelTest.codeFormat
    let senderSignatureData = FeeDelegatedCancelTest.senderSignatureData
    let feePayer = FeeDelegatedCancelTest.feePayer
    let feePayerSignatureData = FeeDelegatedCancelTest.feePayerSignatureData
    
    let expectedRLPEncoding = FeeDelegatedCancelTest.expectedRLPEncoding
    let expectedTransactionHash = FeeDelegatedCancelTest.expectedTransactionHash
            
    public func test_getTransactionHash() throws {
        let txObj = try FeeDelegatedCancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()

        XCTAssertEqual(expectedTransactionHash, try txObj.getTransactionHash())
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try FeeDelegatedCancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
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
        
        mTxObj = try FeeDelegatedCancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
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

class FeeDelegatedCancelTest_getSenderTxHashTest: XCTestCase {
    var mTxObj: FeeDelegatedCancel?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = FeeDelegatedCancelTest.senderPrivateKey
    let from = FeeDelegatedCancelTest.from
    let account = FeeDelegatedCancelTest.account
    let to = FeeDelegatedCancelTest.to
    let gas = FeeDelegatedCancelTest.gas
    let nonce = FeeDelegatedCancelTest.nonce
    let gasPrice = FeeDelegatedCancelTest.gasPrice
    let chainID = FeeDelegatedCancelTest.chainID
    let value = FeeDelegatedCancelTest.value
    let input = FeeDelegatedCancelTest.input
    let humanReadable = FeeDelegatedCancelTest.humanReadable
    let codeFormat = FeeDelegatedCancelTest.codeFormat
    let senderSignatureData = FeeDelegatedCancelTest.senderSignatureData
    let feePayer = FeeDelegatedCancelTest.feePayer
    let feePayerSignatureData = FeeDelegatedCancelTest.feePayerSignatureData
    let expectedRLPEncoding = FeeDelegatedCancelTest.expectedRLPEncoding
    let expectedTransactionHash = FeeDelegatedCancelTest.expectedTransactionHash
    let expectedSenderTransactionHash = FeeDelegatedCancelTest.expectedSenderTransactionHash
            
    public func test_getRLPEncodingForSignature() throws {
        mTxObj = try FeeDelegatedCancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertEqual(expectedSenderTransactionHash, try mTxObj!.getSenderTxHash())
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try FeeDelegatedCancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
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
        
        mTxObj = try FeeDelegatedCancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
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

class FeeDelegatedCancelTest_getRLPEncodingForFeePayerSignatureTest: XCTestCase {
    var mTxObj: FeeDelegatedCancel?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = FeeDelegatedCancelTest.senderPrivateKey
    let from = FeeDelegatedCancelTest.from
    let account = FeeDelegatedCancelTest.account
    let to = FeeDelegatedCancelTest.to
    let gas = FeeDelegatedCancelTest.gas
    let nonce = FeeDelegatedCancelTest.nonce
    let gasPrice = FeeDelegatedCancelTest.gasPrice
    let chainID = FeeDelegatedCancelTest.chainID
    let value = FeeDelegatedCancelTest.value
    let input = FeeDelegatedCancelTest.input
    let humanReadable = FeeDelegatedCancelTest.humanReadable
    let codeFormat = FeeDelegatedCancelTest.codeFormat
    let senderSignatureData = FeeDelegatedCancelTest.senderSignatureData
    let feePayer = FeeDelegatedCancelTest.feePayer
    let feePayerSignatureData = FeeDelegatedCancelTest.feePayerSignatureData
    let expectedRLPEncoding = FeeDelegatedCancelTest.expectedRLPEncoding
    let expectedTransactionHash = FeeDelegatedCancelTest.expectedTransactionHash
    let expectedSenderTransactionHash = FeeDelegatedCancelTest.expectedSenderTransactionHash
    let expectedRLPEncodingForFeePayerSigning = FeeDelegatedCancelTest.expectedRLPEncodingForFeePayerSigning
            
    public func test_getRLPEncodingForSignature() throws {
        mTxObj = try FeeDelegatedCancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertEqual(expectedRLPEncodingForFeePayerSigning, try mTxObj!.getRLPEncodingForFeePayerSignature())
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try FeeDelegatedCancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
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
        
        mTxObj = try FeeDelegatedCancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
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
        
        mTxObj = try FeeDelegatedCancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
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
