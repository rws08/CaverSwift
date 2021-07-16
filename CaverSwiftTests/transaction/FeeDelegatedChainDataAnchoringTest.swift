//
//  FeeDelegatedChainDataAnchoringTest.swift
//  CaverSwiftTests
//
//  Created by won on 2021/07/16.
//

import XCTest
@testable import CaverSwift

class FeeDelegatedChainDataAnchoringTest: XCTestCase {
    static let caver = Caver(Caver.DEFAULT_URL)
    
    static let senderPrivateKey = "0x45a915e4d060149eb4365960e6a7a45f334393093061116b197e3240065ff2d8"
    static let feePayerPrivateKey = "0xb9d5558443585bca6f225b935950e3f6e69f9da8a5809a83f51c3365dff53936"
    static let from = "0xa94f5374Fce5edBC8E2a8697C15331677e6EbF0B"
    static let account = Account.createWithAccountKeyLegacy(from)
    static let to = "0x7b65b75d204abed71587c9e519a89277766ee1d0"
    static let gas = "0x174876e800"
    static let gasPrice = "0x5d21dba00"
    static let nonce = "0x11"
    static let chainID = "0x1"
    static let value = "0xa"
    static let input = "f8ad80b8aaf8a8a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a00000000000000000000000000000000000000000000000000000000000000004058006"
    static let humanReadable = false
    static let codeFormat = CodeFormat.EVM.hexa

    static let senderSignatureData = SignatureData(
        "0x26",
        "0xafe41edc9cce1185ab9065ca7dbfb89ab5c7bde3602a659aa258324124644142",
        "0x317848698248ba7cc057b8f0dd19a27b52ef904d29cb72823100f1ed18ba2bb3"
    )
    static let feePayer = "0x33f524631e573329a550296F595c820D6c65213f"
    static let feePayerSignatureData = SignatureData(
        "0x25",
        "0x309e46db21a1bf7bfdae24d9192aca69516d6a341ecce8971fc69cff481cee76",
        "0x4b939bf7384c4f919880307323a5e36d4d6e029bae1887a43332710cdd48f174"
    )

    static let expectedRLPEncoding = "0x49f90176118505d21dba0085174876e80094a94f5374fce5edbc8e2a8697c15331677e6ebf0bb8aff8ad80b8aaf8a8a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a00000000000000000000000000000000000000000000000000000000000000004058006f845f84326a0afe41edc9cce1185ab9065ca7dbfb89ab5c7bde3602a659aa258324124644142a0317848698248ba7cc057b8f0dd19a27b52ef904d29cb72823100f1ed18ba2bb39433f524631e573329a550296f595c820d6c65213ff845f84325a0309e46db21a1bf7bfdae24d9192aca69516d6a341ecce8971fc69cff481cee76a04b939bf7384c4f919880307323a5e36d4d6e029bae1887a43332710cdd48f174"
    static let expectedTransactionHash = "0xecf1ec12937065617f9b3cd07570452bfdb75dc36404c4f37f78995c6dc462af"
    static let expectedSenderTransactionHash = "0x4f5c00ea8f6346baa7d4400dfefd72efa5ec219561ebcebed7be8a2b79d52bcd"
    static let expectedRLPEncodingForFeePayerSigning = "0xf8f0b8d6f8d449118505d21dba0085174876e80094a94f5374fce5edbc8e2a8697c15331677e6ebf0bb8aff8ad80b8aaf8a8a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a000000000000000000000000000000000000000000000000000000000000000040580069433f524631e573329a550296f595c820d6c65213f018080"
        
    public static func generateRoleBaseKeyring(_ numArr: [Int], _ address: String) throws -> AbstractKeyring {
        let keyArr = KeyringFactory.generateRoleBasedKeys(numArr, "entropy")
        return try KeyringFactory.createWithRoleBasedKey(address, keyArr)
    }
}

class FeeDelegatedChainDataAnchoringTest_createInstanceBuilder: XCTestCase {
    let from = FeeDelegatedChainDataAnchoringTest.from
    let account = FeeDelegatedChainDataAnchoringTest.account
    let to = FeeDelegatedChainDataAnchoringTest.to
    let gas = FeeDelegatedChainDataAnchoringTest.gas
    let nonce = FeeDelegatedChainDataAnchoringTest.nonce
    let gasPrice = FeeDelegatedChainDataAnchoringTest.gasPrice
    let chainID = FeeDelegatedChainDataAnchoringTest.chainID
    let value = FeeDelegatedChainDataAnchoringTest.value
    let input = FeeDelegatedChainDataAnchoringTest.input
    let humanReadable = FeeDelegatedChainDataAnchoringTest.humanReadable
    let codeFormat = FeeDelegatedChainDataAnchoringTest.codeFormat
    let senderSignatureData = FeeDelegatedChainDataAnchoringTest.senderSignatureData
    let feePayer = FeeDelegatedChainDataAnchoringTest.feePayer
    let feePayerSignatureData = FeeDelegatedChainDataAnchoringTest.feePayerSignatureData
        
    public func test_BuilderTest() throws {
        let txObj = try FeeDelegatedChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setGas(gas)
            .setFrom(from)
            .setChainId(chainID)
            .setFeePayer(feePayer)
            .setInput(input)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertNotNil(txObj)
    }
    
    public func test_BuilderWithRPCTest() throws {
        let txObj = try FeeDelegatedChainDataAnchoring.Builder()
            .setKlaytnCall(FeeDelegatedChainDataAnchoringTest.caver.rpc.klay)
            .setGas(gas)
            .setFrom(from)
            .setFeePayer(feePayer)
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
        let txObj = try FeeDelegatedChainDataAnchoring.Builder()
            .setNonce(BigInt(hex: nonce)!)
            .setGas(BigInt(hex: gas)!)
            .setGasPrice(BigInt(hex: gasPrice)!)
            .setChainId(BigInt(hex: chainID)!)
            .setFrom(from)
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
        XCTAssertThrowsError(try FeeDelegatedChainDataAnchoring.Builder()
                                .setNonce(nonce)
                                .setGasPrice(gasPrice)
                                .setGas(gas)
                                .setFrom(from)
                                .setChainId(chainID)
                                .setFeePayer(feePayer)
                                .setInput(input)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(from)"))
        }
    }
    
    public func test_throwException_missingFrom() throws {
        let from = ""
        XCTAssertThrowsError(try FeeDelegatedChainDataAnchoring.Builder()
                                .setNonce(nonce)
                                .setGasPrice(gasPrice)
                                .setGas(gas)
                                .setFrom(from)
                                .setChainId(chainID)
                                .setFeePayer(feePayer)
                                .setInput(input)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("from is missing."))
        }
    }
        
    public func test_throwException_invalidGas() throws {
        let gas = "invalid gas"
        XCTAssertThrowsError(try FeeDelegatedChainDataAnchoring.Builder()
                                .setNonce(nonce)
                                .setGasPrice(gasPrice)
                                .setGas(gas)
                                .setFrom(from)
                                .setChainId(chainID)
                                .setFeePayer(feePayer)
                                .setInput(input)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid gas. : \(gas)"))
        }
    }
    
    public func test_throwException_missingGas() throws {
        let gas = ""
        XCTAssertThrowsError(try FeeDelegatedChainDataAnchoring.Builder()
                                .setNonce(nonce)
                                .setGasPrice(gasPrice)
                                .setGas(gas)
                                .setFrom(from)
                                .setChainId(chainID)
                                .setFeePayer(feePayer)
                                .setInput(input)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("gas is missing."))
        }
    }
    
    public func test_throwException_invalidInput() throws {
        let input = "invalid input"
        XCTAssertThrowsError(try FeeDelegatedChainDataAnchoring.Builder()
                                .setNonce(nonce)
                                .setGasPrice(gasPrice)
                                .setGas(gas)
                                .setFrom(from)
                                .setChainId(chainID)
                                .setFeePayer(feePayer)
                                .setInput(input)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid input. : \(input)"))
        }
    }
    
    public func test_throwException_missingInput() throws {
        let input = ""
        XCTAssertThrowsError(try FeeDelegatedChainDataAnchoring.Builder()
                                .setNonce(nonce)
                                .setGasPrice(gasPrice)
                                .setGas(gas)
                                .setFrom(from)
                                .setChainId(chainID)
                                .setFeePayer(feePayer)
                                .setInput(input)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("input is missing."))
        }
    }
    
    public func test_throwException_setFeePayerSignatures_missingFeePayer() throws {
        let feePayer = ""
        XCTAssertThrowsError(try FeeDelegatedChainDataAnchoring.Builder()
                                .setNonce(nonce)
                                .setGasPrice(gasPrice)
                                .setGas(gas)
                                .setFrom(from)
                                .setChainId(chainID)
                                .setFeePayer(feePayer)
                                .setInput(input)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("feePayer is missing: feePayer must be defined with feePayerSignatures."))
        }
    }
}

class FeeDelegatedChainDataAnchoringTest_createInstance: XCTestCase {
    let from = FeeDelegatedChainDataAnchoringTest.from
    let account = FeeDelegatedChainDataAnchoringTest.account
    let to = FeeDelegatedChainDataAnchoringTest.to
    let gas = FeeDelegatedChainDataAnchoringTest.gas
    let nonce = FeeDelegatedChainDataAnchoringTest.nonce
    let gasPrice = FeeDelegatedChainDataAnchoringTest.gasPrice
    let chainID = FeeDelegatedChainDataAnchoringTest.chainID
    let value = FeeDelegatedChainDataAnchoringTest.value
    let input = FeeDelegatedChainDataAnchoringTest.input
    let humanReadable = FeeDelegatedChainDataAnchoringTest.humanReadable
    let codeFormat = FeeDelegatedChainDataAnchoringTest.codeFormat
    let senderSignatureData = FeeDelegatedChainDataAnchoringTest.senderSignatureData
    let feePayer = FeeDelegatedChainDataAnchoringTest.feePayer
    let feePayerSignatureData = FeeDelegatedChainDataAnchoringTest.feePayerSignatureData
    
    public func test_createInstance() throws {
        let txObj = try FeeDelegatedChainDataAnchoring(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            input
        )
        
        XCTAssertNotNil(txObj)
    }
    
    public func test_throwException_invalidFrom() throws {
        let from = "invalid Address"
        XCTAssertThrowsError(try FeeDelegatedChainDataAnchoring(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(from)"))
        }
    }
    
    public func test_throwException_missingFrom() throws {
        let from = ""
        XCTAssertThrowsError(try FeeDelegatedChainDataAnchoring(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("from is missing."))
        }
    }
    
    public func test_throwException_invalidGas() throws {
        let gas = "invalid gas"
        XCTAssertThrowsError(try FeeDelegatedChainDataAnchoring(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid gas. : \(gas)"))
        }
    }
    
    public func test_throwException_missingGas() throws {
        let gas = ""
        XCTAssertThrowsError(try FeeDelegatedChainDataAnchoring(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("gas is missing."))
        }
    }
    
    public func test_throwException_invalidInput() throws {
        let input = "invalid input"
        XCTAssertThrowsError(try FeeDelegatedChainDataAnchoring(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid input. : \(input)"))
        }
    }
    
    public func test_throwException_missingInput() throws {
        let input = ""
        XCTAssertThrowsError(try FeeDelegatedChainDataAnchoring(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("input is missing."))
        }
    }
    
    public func throwException_setFeePayerSignatures_missingFeePayer() throws {
        let feePayer = ""
        XCTAssertThrowsError(try FeeDelegatedChainDataAnchoring(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("feePayer is missing: feePayer must be defined with feePayerSignatures."))
        }
    }
}

class FeeDelegatedChainDataAnchoringTest_getRLPEncodingTest: XCTestCase {
    let from = FeeDelegatedChainDataAnchoringTest.from
    let account = FeeDelegatedChainDataAnchoringTest.account
    let to = FeeDelegatedChainDataAnchoringTest.to
    let gas = FeeDelegatedChainDataAnchoringTest.gas
    let nonce = FeeDelegatedChainDataAnchoringTest.nonce
    let gasPrice = FeeDelegatedChainDataAnchoringTest.gasPrice
    let chainID = FeeDelegatedChainDataAnchoringTest.chainID
    let value = FeeDelegatedChainDataAnchoringTest.value
    let input = FeeDelegatedChainDataAnchoringTest.input
    let humanReadable = FeeDelegatedChainDataAnchoringTest.humanReadable
    let codeFormat = FeeDelegatedChainDataAnchoringTest.codeFormat
    let senderSignatureData = FeeDelegatedChainDataAnchoringTest.senderSignatureData
    let feePayer = FeeDelegatedChainDataAnchoringTest.feePayer
    let feePayerSignatureData = FeeDelegatedChainDataAnchoringTest.feePayerSignatureData
    
    let expectedRLPEncoding = FeeDelegatedChainDataAnchoringTest.expectedRLPEncoding
        
    public func test_getRLPEncoding() throws {
        let txObj = try FeeDelegatedChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setGas(gas)
            .setFrom(from)
            .setChainId(chainID)
            .setFeePayer(feePayer)
            .setInput(input)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertEqual(expectedRLPEncoding, try txObj.getRLPEncoding())
    }
    
    public func test_throwException_NoNonce() throws {
        let txObj = try FeeDelegatedChainDataAnchoring.Builder()
            .setGasPrice(gasPrice)
            .setGas(gas)
            .setFrom(from)
            .setChainId(chainID)
            .setFeePayer(feePayer)
            .setInput(input)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertThrowsError(try txObj.getRLPEncoding()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NoGasPrice() throws {
        let txObj = try FeeDelegatedChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setFrom(from)
            .setChainId(chainID)
            .setFeePayer(feePayer)
            .setInput(input)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertThrowsError(try txObj.getRLPEncoding()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class FeeDelegatedChainDataAnchoringTest_signAsFeePayer_OneKeyTest: XCTestCase {
    var mTxObj: FeeDelegatedChainDataAnchoring?
    var klaytnWalletKey: String?
    var keyring: AbstractKeyring?
    var feePayerAddress: String?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedChainDataAnchoringTest.feePayerPrivateKey
        
    let from = FeeDelegatedChainDataAnchoringTest.from
    let account = FeeDelegatedChainDataAnchoringTest.account
    let to = FeeDelegatedChainDataAnchoringTest.to
    let gas = FeeDelegatedChainDataAnchoringTest.gas
    let nonce = FeeDelegatedChainDataAnchoringTest.nonce
    let gasPrice = FeeDelegatedChainDataAnchoringTest.gasPrice
    let chainID = FeeDelegatedChainDataAnchoringTest.chainID
    let value = FeeDelegatedChainDataAnchoringTest.value
    let input = FeeDelegatedChainDataAnchoringTest.input
    let humanReadable = FeeDelegatedChainDataAnchoringTest.humanReadable
    let codeFormat = FeeDelegatedChainDataAnchoringTest.codeFormat
    let senderSignatureData = FeeDelegatedChainDataAnchoringTest.senderSignatureData
    let feePayer = FeeDelegatedChainDataAnchoringTest.feePayer
    let feePayerSignatureData = FeeDelegatedChainDataAnchoringTest.feePayerSignatureData
    
    let expectedRLPEncoding = FeeDelegatedChainDataAnchoringTest.expectedRLPEncoding
        
    override func setUpWithError() throws {
        keyring = try KeyringFactory.createWithSingleKey(feePayer, feePayerPrivateKey)
        klaytnWalletKey = try keyring?.getKlaytnWalletKey()
        feePayerAddress = keyring?.address
        
        mTxObj = try FeeDelegatedChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setGas(gas)
            .setFrom(from)
            .setChainId(chainID)
            .setFeePayer(feePayerAddress!)
            .setInput(input)
            .setSignatures(senderSignatureData)
            .build()
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

class FeeDelegatedChainDataAnchoringTest_signAsFeePayer_AllKeyTest: XCTestCase {
    var mTxObj: FeeDelegatedChainDataAnchoring?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedChainDataAnchoringTest.feePayerPrivateKey
        
    let from = FeeDelegatedChainDataAnchoringTest.from
    let account = FeeDelegatedChainDataAnchoringTest.account
    let to = FeeDelegatedChainDataAnchoringTest.to
    let gas = FeeDelegatedChainDataAnchoringTest.gas
    let nonce = FeeDelegatedChainDataAnchoringTest.nonce
    let gasPrice = FeeDelegatedChainDataAnchoringTest.gasPrice
    let chainID = FeeDelegatedChainDataAnchoringTest.chainID
    let value = FeeDelegatedChainDataAnchoringTest.value
    let input = FeeDelegatedChainDataAnchoringTest.input
    let humanReadable = FeeDelegatedChainDataAnchoringTest.humanReadable
    let codeFormat = FeeDelegatedChainDataAnchoringTest.codeFormat
    let senderSignatureData = FeeDelegatedChainDataAnchoringTest.senderSignatureData
    let feePayer = FeeDelegatedChainDataAnchoringTest.feePayer
    let feePayerSignatureData = FeeDelegatedChainDataAnchoringTest.feePayerSignatureData
    
    let expectedRLPEncoding = FeeDelegatedChainDataAnchoringTest.expectedRLPEncoding
        
    override func setUpWithError() throws {
        mTxObj = try FeeDelegatedChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setGas(gas)
            .setFrom(from)
            .setChainId(chainID)
            .setFeePayer(feePayer)
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

class FeeDelegatedChainDataAnchoringTest_appendFeePayerSignaturesTest: XCTestCase {
    var mTxObj: FeeDelegatedChainDataAnchoring?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = FeeDelegatedChainDataAnchoringTest.senderPrivateKey
    let feePayerPrivateKey = FeeDelegatedChainDataAnchoringTest.feePayerPrivateKey
        
    let from = FeeDelegatedChainDataAnchoringTest.from
    let account = FeeDelegatedChainDataAnchoringTest.account
    let to = FeeDelegatedChainDataAnchoringTest.to
    let gas = FeeDelegatedChainDataAnchoringTest.gas
    let nonce = FeeDelegatedChainDataAnchoringTest.nonce
    let gasPrice = FeeDelegatedChainDataAnchoringTest.gasPrice
    let chainID = FeeDelegatedChainDataAnchoringTest.chainID
    let value = FeeDelegatedChainDataAnchoringTest.value
    let input = FeeDelegatedChainDataAnchoringTest.input
    let humanReadable = FeeDelegatedChainDataAnchoringTest.humanReadable
    let codeFormat = FeeDelegatedChainDataAnchoringTest.codeFormat
    let senderSignatureData = FeeDelegatedChainDataAnchoringTest.senderSignatureData
    let feePayer = FeeDelegatedChainDataAnchoringTest.feePayer
    let feePayerSignatureData = FeeDelegatedChainDataAnchoringTest.feePayerSignatureData
    
    override func setUpWithError() throws {
        mTxObj = try FeeDelegatedChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setGas(gas)
            .setFrom(from)
            .setChainId(chainID)
            .setFeePayer(feePayer)
            .setInput(input)
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
        mTxObj = try FeeDelegatedChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setGas(gas)
            .setFrom(from)
            .setChainId(chainID)
            .setFeePayer(feePayer)
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
        
        mTxObj = try FeeDelegatedChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setGas(gas)
            .setFrom(from)
            .setChainId(chainID)
            .setFeePayer(feePayer)
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
        
        mTxObj = try FeeDelegatedChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setGas(gas)
            .setFrom(from)
            .setChainId(chainID)
            .setFeePayer(feePayer)
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

class FeeDelegatedChainDataAnchoringTest_combineSignatureTest: XCTestCase {
    var mTxObj: FeeDelegatedChainDataAnchoring?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = FeeDelegatedChainDataAnchoringTest.senderPrivateKey
    let from = "0xf1f766ded1aae1e06e2ed6c85127dd69891f7b28"
    var account: Account?
    let to = "0x8723590d5D60e35f7cE0Db5C09D3938b26fF80Ae"
    let gas = "0x174876e800"
    let nonce = "0x1"
    let gasPrice = "0x5d21dba00"
    let chainID = "0x7e3"
    let value = BigInt(1)
    let input = FeeDelegatedChainDataAnchoringTest.input
    let humanReadable = FeeDelegatedChainDataAnchoringTest.humanReadable
    let codeFormat = FeeDelegatedChainDataAnchoringTest.codeFormat
    let senderSignatureData = FeeDelegatedChainDataAnchoringTest.senderSignatureData
    let feePayer = FeeDelegatedChainDataAnchoringTest.feePayer
    let feePayerSignatureData = FeeDelegatedChainDataAnchoringTest.feePayerSignatureData
    let expectedRLPEncoding = FeeDelegatedChainDataAnchoringTest.expectedRLPEncoding
    
    override func setUpWithError() throws {
        mTxObj = try FeeDelegatedChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setInput(input)
            .setChainId(chainID)
            .build()
    }
    
    public func test_combineSignature() throws {
        let expectedRLPEncoded = "0x49f90136018505d21dba0085174876e80094f1f766ded1aae1e06e2ed6c85127dd69891f7b28b8aff8ad80b8aaf8a8a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a00000000000000000000000000000000000000000000000000000000000000004058006f847f845820feaa0042800bfb7429b6c054fed37b86c473fdea9d4481d5d5b32cc92f34d744983b9a03ce733dfce2efd9f6ffaf70d50a0a211b94d84a8a18f1196e875053896a974be940000000000000000000000000000000000000000c4c3018080"
        
        let expectedSignature = SignatureData(
            "0x0fea",
            "0x042800bfb7429b6c054fed37b86c473fdea9d4481d5d5b32cc92f34d744983b9",
            "0x3ce733dfce2efd9f6ffaf70d50a0a211b94d84a8a18f1196e875053896a974be"
        )
        
        let rlpEncoded = "0x49f90136018505d21dba0085174876e80094f1f766ded1aae1e06e2ed6c85127dd69891f7b28b8aff8ad80b8aaf8a8a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a00000000000000000000000000000000000000000000000000000000000000004058006f847f845820feaa0042800bfb7429b6c054fed37b86c473fdea9d4481d5d5b32cc92f34d744983b9a03ce733dfce2efd9f6ffaf70d50a0a211b94d84a8a18f1196e875053896a974be940000000000000000000000000000000000000000c4c3018080"
        
        let combined = try mTxObj!.combineSignedRawTransactions([rlpEncoded])
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature, mTxObj?.signatures[0])
    }
    
    public func test_combine_multipleSignature() throws {
        let expectedRLPEncoded = "0x49f901c4018505d21dba0085174876e80094f1f766ded1aae1e06e2ed6c85127dd69891f7b28b8aff8ad80b8aaf8a8a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a00000000000000000000000000000000000000000000000000000000000000004058006f8d5f845820feaa0042800bfb7429b6c054fed37b86c473fdea9d4481d5d5b32cc92f34d744983b9a03ce733dfce2efd9f6ffaf70d50a0a211b94d84a8a18f1196e875053896a974bef845820feaa0a45210f00ff64784e0aac0597b7eb19ea0890144100fd8dc8bb0b2fe003cbe84a07ff706e9a3825be7767f389789927a5633cf4995790a8bfe26d9332300de5db0f845820feaa076a91becce2c632980731d97a319216030de7b1b94b04c8a568236547d42d263a061c3c3456cda8eb7c440c700a168204b054d45d7bf2652c04171a0a1f76eff73940000000000000000000000000000000000000000c4c3018080"
        
        let expectedSignature = [
            SignatureData(
                    "0x0fea",
                    "0x042800bfb7429b6c054fed37b86c473fdea9d4481d5d5b32cc92f34d744983b9",
                    "0x3ce733dfce2efd9f6ffaf70d50a0a211b94d84a8a18f1196e875053896a974be"
            ),
            SignatureData(
                    "0x0fea",
                    "0xa45210f00ff64784e0aac0597b7eb19ea0890144100fd8dc8bb0b2fe003cbe84",
                    "0x7ff706e9a3825be7767f389789927a5633cf4995790a8bfe26d9332300de5db0"
            ),
            SignatureData(
                    "0x0fea",
                    "0x76a91becce2c632980731d97a319216030de7b1b94b04c8a568236547d42d263",
                    "0x61c3c3456cda8eb7c440c700a168204b054d45d7bf2652c04171a0a1f76eff73"
            )
        ]
        
        let rlpEncodedString = [
            "0x49f90122018505d21dba0085174876e80094f1f766ded1aae1e06e2ed6c85127dd69891f7b28b8aff8ad80b8aaf8a8a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a00000000000000000000000000000000000000000000000000000000000000004058006f847f845820feaa0a45210f00ff64784e0aac0597b7eb19ea0890144100fd8dc8bb0b2fe003cbe84a07ff706e9a3825be7767f389789927a5633cf4995790a8bfe26d9332300de5db080c4c3018080",
            "0x49f90122018505d21dba0085174876e80094f1f766ded1aae1e06e2ed6c85127dd69891f7b28b8aff8ad80b8aaf8a8a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a00000000000000000000000000000000000000000000000000000000000000004058006f847f845820feaa076a91becce2c632980731d97a319216030de7b1b94b04c8a568236547d42d263a061c3c3456cda8eb7c440c700a168204b054d45d7bf2652c04171a0a1f76eff7380c4c3018080"
        ]
        
        let senderSignatureData = SignatureData(
            "0x0fea",
            "0x042800bfb7429b6c054fed37b86c473fdea9d4481d5d5b32cc92f34d744983b9",
            "0x3ce733dfce2efd9f6ffaf70d50a0a211b94d84a8a18f1196e875053896a974be"
        )
        
        mTxObj = try FeeDelegatedChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
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
        let expectedRLPEncoded = "0x49f90136018505d21dba0085174876e80094f1f766ded1aae1e06e2ed6c85127dd69891f7b28b8aff8ad80b8aaf8a8a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a00000000000000000000000000000000000000000000000000000000000000004058006c4c301808094ee43ecbed54e4862ed98c11d2e71b8bd04c1667ef847f845820fe9a0f8f21b4d667b139e80818c2b8bfd6117ace4bc11157be3c3ee74c0360565356fa0346828779330f21b7d06be682ec8289f3211c4018a20385cabd0d0ebc2569f16"
        
        let expectedSignature = SignatureData(
            "0x0fe9",
            "0xf8f21b4d667b139e80818c2b8bfd6117ace4bc11157be3c3ee74c0360565356f",
            "0x346828779330f21b7d06be682ec8289f3211c4018a20385cabd0d0ebc2569f16"
        )
        
        let rlpEncoded = "0x49f90136018505d21dba0085174876e80094f1f766ded1aae1e06e2ed6c85127dd69891f7b28b8aff8ad80b8aaf8a8a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a00000000000000000000000000000000000000000000000000000000000000004058006c4c301808094ee43ecbed54e4862ed98c11d2e71b8bd04c1667ef847f845820fe9a0f8f21b4d667b139e80818c2b8bfd6117ace4bc11157be3c3ee74c0360565356fa0346828779330f21b7d06be682ec8289f3211c4018a20385cabd0d0ebc2569f16"
        
        mTxObj = try FeeDelegatedChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setInput(input)
            .setChainId(chainID)
            .build()
        
        let combined = try mTxObj!.combineSignedRawTransactions([rlpEncoded])
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature, mTxObj?.feePayerSignatures[0])
    }
    
    public func test_combineSignature_multipleFeePayerSignature() throws {
        let expectedRLPEncoded = "0x49f901c4018505d21dba0085174876e80094f1f766ded1aae1e06e2ed6c85127dd69891f7b28b8aff8ad80b8aaf8a8a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a00000000000000000000000000000000000000000000000000000000000000004058006c4c301808094ee43ecbed54e4862ed98c11d2e71b8bd04c1667ef8d5f845820fe9a0f8f21b4d667b139e80818c2b8bfd6117ace4bc11157be3c3ee74c0360565356fa0346828779330f21b7d06be682ec8289f3211c4018a20385cabd0d0ebc2569f16f845820feaa0baa6a845e8c68ae8bf9acc7e018bceaab506e0818e0dc8db2afe3490a1927317a046bacf69af211302103f8c3841bc3cc6a79e2298ee4bc5d5e73b25f42ca98156f845820fe9a05df342131bfdae8239829e16a4298d711c238d0d4ab679b864878be729362921a07e3a7f484d6eb139c6b652c96aaa8ac8df43a5dfb3adaff46bc552a2c6965cba"
        
        let expectedSignature = [
            SignatureData(
                    "0x0fe9",
                    "0xf8f21b4d667b139e80818c2b8bfd6117ace4bc11157be3c3ee74c0360565356f",
                    "0x346828779330f21b7d06be682ec8289f3211c4018a20385cabd0d0ebc2569f16"
            ),
            SignatureData(
                    "0x0fea",
                    "0xbaa6a845e8c68ae8bf9acc7e018bceaab506e0818e0dc8db2afe3490a1927317",
                    "0x46bacf69af211302103f8c3841bc3cc6a79e2298ee4bc5d5e73b25f42ca98156"
            ),
            SignatureData(
                    "0x0fe9",
                    "0x5df342131bfdae8239829e16a4298d711c238d0d4ab679b864878be729362921",
                    "0x7e3a7f484d6eb139c6b652c96aaa8ac8df43a5dfb3adaff46bc552a2c6965cba"
            )
        ]
        
        let rlpEncodedString = [
            "0x49f90136018505d21dba0085174876e80094f1f766ded1aae1e06e2ed6c85127dd69891f7b28b8aff8ad80b8aaf8a8a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a00000000000000000000000000000000000000000000000000000000000000004058006c4c301808094ee43ecbed54e4862ed98c11d2e71b8bd04c1667ef847f845820feaa0baa6a845e8c68ae8bf9acc7e018bceaab506e0818e0dc8db2afe3490a1927317a046bacf69af211302103f8c3841bc3cc6a79e2298ee4bc5d5e73b25f42ca98156",
            "0x49f90136018505d21dba0085174876e80094f1f766ded1aae1e06e2ed6c85127dd69891f7b28b8aff8ad80b8aaf8a8a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a00000000000000000000000000000000000000000000000000000000000000004058006c4c301808094ee43ecbed54e4862ed98c11d2e71b8bd04c1667ef847f845820fe9a05df342131bfdae8239829e16a4298d711c238d0d4ab679b864878be729362921a07e3a7f484d6eb139c6b652c96aaa8ac8df43a5dfb3adaff46bc552a2c6965cba",
        ]
        
        let feePayer = "0xee43ecbed54e4862ed98c11d2e71b8bd04c1667e"
        let feePayerSignatureData = SignatureData(
            "0x0fe9",
            "0xf8f21b4d667b139e80818c2b8bfd6117ace4bc11157be3c3ee74c0360565356f",
            "0x346828779330f21b7d06be682ec8289f3211c4018a20385cabd0d0ebc2569f16"
        )
        
        mTxObj = try FeeDelegatedChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setInput(input)
            .setFeePayer(feePayer)
            .setFeePayerSignatures(feePayerSignatureData)
            .setChainId(chainID)
            .build()
        
        let combined = try mTxObj!.combineSignedRawTransactions(rlpEncodedString)
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature[0], mTxObj?.feePayerSignatures[0])
        XCTAssertEqual(expectedSignature[1], mTxObj?.feePayerSignatures[1])
        XCTAssertEqual(expectedSignature[2], mTxObj?.feePayerSignatures[2])
    }
    
    public func test_multipleSignature_senderSignatureData_feePayerSignature() throws {
        mTxObj = try FeeDelegatedChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setInput(input)
            .setChainId(chainID)
            .build()
        
        let rlpEncodedString = "0x49f901b0018505d21dba0085174876e80094f1f766ded1aae1e06e2ed6c85127dd69891f7b28b8aff8ad80b8aaf8a8a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a00000000000000000000000000000000000000000000000000000000000000004058006f8d5f845820feaa0042800bfb7429b6c054fed37b86c473fdea9d4481d5d5b32cc92f34d744983b9a03ce733dfce2efd9f6ffaf70d50a0a211b94d84a8a18f1196e875053896a974bef845820feaa0a45210f00ff64784e0aac0597b7eb19ea0890144100fd8dc8bb0b2fe003cbe84a07ff706e9a3825be7767f389789927a5633cf4995790a8bfe26d9332300de5db0f845820feaa076a91becce2c632980731d97a319216030de7b1b94b04c8a568236547d42d263a061c3c3456cda8eb7c440c700a168204b054d45d7bf2652c04171a0a1f76eff7380c4c3018080"
        
        let expectedSignature = [
            SignatureData(
                    "0x0fea",
                    "0x042800bfb7429b6c054fed37b86c473fdea9d4481d5d5b32cc92f34d744983b9",
                    "0x3ce733dfce2efd9f6ffaf70d50a0a211b94d84a8a18f1196e875053896a974be"
            ),
            SignatureData(
                    "0x0fea",
                    "0xa45210f00ff64784e0aac0597b7eb19ea0890144100fd8dc8bb0b2fe003cbe84",
                    "0x7ff706e9a3825be7767f389789927a5633cf4995790a8bfe26d9332300de5db0"
            ),
            SignatureData(
                    "0x0fea",
                    "0x76a91becce2c632980731d97a319216030de7b1b94b04c8a568236547d42d263",
                    "0x61c3c3456cda8eb7c440c700a168204b054d45d7bf2652c04171a0a1f76eff73"
            )
        ]
        
        _ = try mTxObj!.combineSignedRawTransactions([rlpEncodedString])
        
        let rlpEncodedStringsWithFeePayerSignatures = "0x49f901c4018505d21dba0085174876e80094f1f766ded1aae1e06e2ed6c85127dd69891f7b28b8aff8ad80b8aaf8a8a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a00000000000000000000000000000000000000000000000000000000000000004058006c4c301808094ee43ecbed54e4862ed98c11d2e71b8bd04c1667ef8d5f845820fe9a0f8f21b4d667b139e80818c2b8bfd6117ace4bc11157be3c3ee74c0360565356fa0346828779330f21b7d06be682ec8289f3211c4018a20385cabd0d0ebc2569f16f845820feaa0baa6a845e8c68ae8bf9acc7e018bceaab506e0818e0dc8db2afe3490a1927317a046bacf69af211302103f8c3841bc3cc6a79e2298ee4bc5d5e73b25f42ca98156f845820fe9a05df342131bfdae8239829e16a4298d711c238d0d4ab679b864878be729362921a07e3a7f484d6eb139c6b652c96aaa8ac8df43a5dfb3adaff46bc552a2c6965cba"
        
        let expectedFeePayerSignatures = [
            SignatureData(
                    "0x0fe9",
                    "0xf8f21b4d667b139e80818c2b8bfd6117ace4bc11157be3c3ee74c0360565356f",
                    "0x346828779330f21b7d06be682ec8289f3211c4018a20385cabd0d0ebc2569f16"
            ),
            SignatureData(
                    "0x0fea",
                    "0xbaa6a845e8c68ae8bf9acc7e018bceaab506e0818e0dc8db2afe3490a1927317",
                    "0x46bacf69af211302103f8c3841bc3cc6a79e2298ee4bc5d5e73b25f42ca98156"
            ),
            SignatureData(
                    "0x0fe9",
                    "0x5df342131bfdae8239829e16a4298d711c238d0d4ab679b864878be729362921",
                    "0x7e3a7f484d6eb139c6b652c96aaa8ac8df43a5dfb3adaff46bc552a2c6965cba"
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
        mTxObj = try FeeDelegatedChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setInput(input)
            .setChainId(chainID)
            .build()
        
        let rlpEncoded = "0x49f90122018505d21dba0085174876e80094f1f766ded1aae1e06e2ed6c85127dd69891f7b28b8aff8ad80b8aaf8a8a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000003a00000000000000000000000000000000000000000000000000000000000000004058006f847f845820feaa0042800bfb7429b6c054fed37b86c473fdea9d4481d5d5b32cc92f34d744983b9a03ce733dfce2efd9f6ffaf70d50a0a211b94d84a8a18f1196e875053896a974be80c4c3018080"
        
        XCTAssertThrowsError(try mTxObj!.combineSignedRawTransactions([rlpEncoded])) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("Transactions containing different information cannot be combined."))
        }
    }
}

class FeeDelegatedChainDataAnchoringTest_getRawTransactionTest: XCTestCase {
    let privateKey = FeeDelegatedChainDataAnchoringTest.senderPrivateKey
    let feePayerPrivateKey = FeeDelegatedChainDataAnchoringTest.feePayerPrivateKey
        
    let from = FeeDelegatedChainDataAnchoringTest.from
    let account = FeeDelegatedChainDataAnchoringTest.account
    let to = FeeDelegatedChainDataAnchoringTest.to
    let gas = FeeDelegatedChainDataAnchoringTest.gas
    let nonce = FeeDelegatedChainDataAnchoringTest.nonce
    let gasPrice = FeeDelegatedChainDataAnchoringTest.gasPrice
    let chainID = FeeDelegatedChainDataAnchoringTest.chainID
    let value = FeeDelegatedChainDataAnchoringTest.value
    let input = FeeDelegatedChainDataAnchoringTest.input
    let humanReadable = FeeDelegatedChainDataAnchoringTest.humanReadable
    let codeFormat = FeeDelegatedChainDataAnchoringTest.codeFormat
    let senderSignatureData = FeeDelegatedChainDataAnchoringTest.senderSignatureData
    let feePayer = FeeDelegatedChainDataAnchoringTest.feePayer
    let feePayerSignatureData = FeeDelegatedChainDataAnchoringTest.feePayerSignatureData
    
    let expectedRLPEncoding = FeeDelegatedChainDataAnchoringTest.expectedRLPEncoding
    
    public func test_getRawTransaction() throws {
        let txObj = try FeeDelegatedChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setGas(gas)
            .setFrom(from)
            .setChainId(chainID)
            .setFeePayer(feePayer)
            .setInput(input)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()

        XCTAssertEqual(expectedRLPEncoding, try txObj.getRawTransaction())
    }
}

class FeeDelegatedChainDataAnchoringTest_getTransactionHashTest: XCTestCase {
    var mTxObj: FeeDelegatedChainDataAnchoring?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = FeeDelegatedChainDataAnchoringTest.senderPrivateKey
    let feePayerPrivateKey = FeeDelegatedChainDataAnchoringTest.feePayerPrivateKey
        
    let from = FeeDelegatedChainDataAnchoringTest.from
    let account = FeeDelegatedChainDataAnchoringTest.account
    let to = FeeDelegatedChainDataAnchoringTest.to
    let gas = FeeDelegatedChainDataAnchoringTest.gas
    let nonce = FeeDelegatedChainDataAnchoringTest.nonce
    let gasPrice = FeeDelegatedChainDataAnchoringTest.gasPrice
    let chainID = FeeDelegatedChainDataAnchoringTest.chainID
    let value = FeeDelegatedChainDataAnchoringTest.value
    let input = FeeDelegatedChainDataAnchoringTest.input
    let humanReadable = FeeDelegatedChainDataAnchoringTest.humanReadable
    let codeFormat = FeeDelegatedChainDataAnchoringTest.codeFormat
    let senderSignatureData = FeeDelegatedChainDataAnchoringTest.senderSignatureData
    let feePayer = FeeDelegatedChainDataAnchoringTest.feePayer
    let feePayerSignatureData = FeeDelegatedChainDataAnchoringTest.feePayerSignatureData
    
    let expectedRLPEncoding = FeeDelegatedChainDataAnchoringTest.expectedRLPEncoding
    let expectedTransactionHash = FeeDelegatedChainDataAnchoringTest.expectedTransactionHash
            
    public func test_getTransactionHash() throws {
        let txObj = try FeeDelegatedChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setGas(gas)
            .setFrom(from)
            .setChainId(chainID)
            .setFeePayer(feePayer)
            .setInput(input)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()

        XCTAssertEqual(expectedTransactionHash, try txObj.getTransactionHash())
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try FeeDelegatedChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setGas(gas)
            .setFrom(from)
            .setChainId(chainID)
            .setFeePayer(feePayer)
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
        
        mTxObj = try FeeDelegatedChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setGas(gas)
            .setFrom(from)
            .setChainId(chainID)
            .setFeePayer(feePayer)
            .setInput(input)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getTransactionHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class FeeDelegatedChainDataAnchoringTest_getSenderTxHashTest: XCTestCase {
    var mTxObj: FeeDelegatedChainDataAnchoring?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = FeeDelegatedChainDataAnchoringTest.senderPrivateKey
    let from = FeeDelegatedChainDataAnchoringTest.from
    let account = FeeDelegatedChainDataAnchoringTest.account
    let to = FeeDelegatedChainDataAnchoringTest.to
    let gas = FeeDelegatedChainDataAnchoringTest.gas
    let nonce = FeeDelegatedChainDataAnchoringTest.nonce
    let gasPrice = FeeDelegatedChainDataAnchoringTest.gasPrice
    let chainID = FeeDelegatedChainDataAnchoringTest.chainID
    let value = FeeDelegatedChainDataAnchoringTest.value
    let input = FeeDelegatedChainDataAnchoringTest.input
    let humanReadable = FeeDelegatedChainDataAnchoringTest.humanReadable
    let codeFormat = FeeDelegatedChainDataAnchoringTest.codeFormat
    let senderSignatureData = FeeDelegatedChainDataAnchoringTest.senderSignatureData
    let feePayer = FeeDelegatedChainDataAnchoringTest.feePayer
    let feePayerSignatureData = FeeDelegatedChainDataAnchoringTest.feePayerSignatureData
    let expectedRLPEncoding = FeeDelegatedChainDataAnchoringTest.expectedRLPEncoding
    let expectedTransactionHash = FeeDelegatedChainDataAnchoringTest.expectedTransactionHash
    let expectedSenderTransactionHash = FeeDelegatedChainDataAnchoringTest.expectedSenderTransactionHash
            
    public func test_getRLPEncodingForSignature() throws {
        mTxObj = try FeeDelegatedChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setGas(gas)
            .setFrom(from)
            .setChainId(chainID)
            .setFeePayer(feePayer)
            .setInput(input)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertEqual(expectedSenderTransactionHash, try mTxObj!.getSenderTxHash())
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try FeeDelegatedChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setGas(gas)
            .setFrom(from)
            .setChainId(chainID)
            .setFeePayer(feePayer)
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
        
        mTxObj = try FeeDelegatedChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setGas(gas)
            .setFrom(from)
            .setChainId(chainID)
            .setFeePayer(feePayer)
            .setInput(input)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getSenderTxHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class FeeDelegatedChainDataAnchoringTest_getRLPEncodingForFeePayerSignatureTest: XCTestCase {
    var mTxObj: FeeDelegatedChainDataAnchoring?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = FeeDelegatedChainDataAnchoringTest.senderPrivateKey
    let from = FeeDelegatedChainDataAnchoringTest.from
    let account = FeeDelegatedChainDataAnchoringTest.account
    let to = FeeDelegatedChainDataAnchoringTest.to
    let gas = FeeDelegatedChainDataAnchoringTest.gas
    let nonce = FeeDelegatedChainDataAnchoringTest.nonce
    let gasPrice = FeeDelegatedChainDataAnchoringTest.gasPrice
    let chainID = FeeDelegatedChainDataAnchoringTest.chainID
    let value = FeeDelegatedChainDataAnchoringTest.value
    let input = FeeDelegatedChainDataAnchoringTest.input
    let humanReadable = FeeDelegatedChainDataAnchoringTest.humanReadable
    let codeFormat = FeeDelegatedChainDataAnchoringTest.codeFormat
    let senderSignatureData = FeeDelegatedChainDataAnchoringTest.senderSignatureData
    let feePayer = FeeDelegatedChainDataAnchoringTest.feePayer
    let feePayerSignatureData = FeeDelegatedChainDataAnchoringTest.feePayerSignatureData
    let expectedRLPEncoding = FeeDelegatedChainDataAnchoringTest.expectedRLPEncoding
    let expectedTransactionHash = FeeDelegatedChainDataAnchoringTest.expectedTransactionHash
    let expectedSenderTransactionHash = FeeDelegatedChainDataAnchoringTest.expectedSenderTransactionHash
    let expectedRLPEncodingForFeePayerSigning = FeeDelegatedChainDataAnchoringTest.expectedRLPEncodingForFeePayerSigning
            
    public func test_getRLPEncodingForSignature() throws {
        mTxObj = try FeeDelegatedChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setGas(gas)
            .setFrom(from)
            .setChainId(chainID)
            .setFeePayer(feePayer)
            .setInput(input)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertEqual(expectedRLPEncodingForFeePayerSigning, try mTxObj!.getRLPEncodingForFeePayerSignature())
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try FeeDelegatedChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setGas(gas)
            .setFrom(from)
            .setChainId(chainID)
            .setFeePayer(feePayer)
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
        
        mTxObj = try FeeDelegatedChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setGas(gas)
            .setFrom(from)
            .setChainId(chainID)
            .setFeePayer(feePayer)
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
        
        mTxObj = try FeeDelegatedChainDataAnchoring.Builder()
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setGas(gas)
            .setFrom(from)
            .setChainId(chainID)
            .setFeePayer(feePayer)
            .setInput(input)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("chainId is undefined. Define chainId in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

