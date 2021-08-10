//
//  CancelTest.swift
//  CaverSwiftTests
//
//  Created by won on 2021/07/14.
//

import XCTest
@testable import CaverSwift

class CancelTest: XCTestCase {
    static let caver = Caver(Caver.DEFAULT_URL)

    static let privateKey = "0x45a915e4d060149eb4365960e6a7a45f334393093061116b197e3240065ff2d8"
    static let from = "0xa94f5374Fce5edBC8E2a8697C15331677e6EbF0B"
    static let gas = "0xf4240"
    static let gasPrice = "0x19"
    static let nonce = "0x4d2"
    static let chainID = "0x1"

    static let signatureData = SignatureData(
            "0x25",
            "0xfb2c3d53d2f6b7bb1deb5a09f80366a5a45429cc1e3956687b075a9dcad20434",
            "0x5c6187822ee23b1001e9613d29a5d6002f990498d2902904f7f259ab3358216e"
    )

    static let expectedRLPEncoding = "0x38f8648204d219830f424094a94f5374fce5edbc8e2a8697c15331677e6ebf0bf845f84325a0fb2c3d53d2f6b7bb1deb5a09f80366a5a45429cc1e3956687b075a9dcad20434a05c6187822ee23b1001e9613d29a5d6002f990498d2902904f7f259ab3358216e"
    static let expectedTransactionHash = "0x10d135d590cb587cc45c1f94f4a0e3b8c24d24a6e4243f09ca395fb4e2450413"
    static let expectedRLPEncodingForSigning = "0xe39fde388204d219830f424094a94f5374fce5edbc8e2a8697c15331677e6ebf0b018080"

    public static func generateRoleBaseKeyring(_ numArr: [Int], _ address: String) throws -> AbstractKeyring {
        let keyArr = numArr.map {
            (0..<$0).map { _ in
                PrivateKey.generate("entropy").privateKey
            }
        }
        
        return try KeyringFactory.createWithRoleBasedKey(address, keyArr)
    }
}

class CancelTest_createInstanceBuilder: XCTestCase {
    let from = CancelTest.from
    let gas = CancelTest.gas
    let nonce = CancelTest.nonce
    let gasPrice = CancelTest.gasPrice
    let chainID = CancelTest.chainID
    let signatureData = CancelTest.signatureData
    
    public func test_BuilderTest() throws {
        let txObj = try Cancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setSignatures(signatureData)
            .build()
        
        XCTAssertNotNil(txObj)
    }
    
    public func test_BuilderWithRPCTest() throws {
        let txObj = try Cancel.Builder()
            .setKlaytnCall(Caver(Caver.DEFAULT_URL).rpc.klay)
            .setGas(gas)
            .setFrom(from)
            .setSignatures(signatureData)
            .build()
        
        try txObj.fillTransaction()
        
        XCTAssertFalse(txObj.nonce.isEmpty)
        XCTAssertFalse(txObj.gasPrice.isEmpty)
        XCTAssertFalse(txObj.chainId.isEmpty)
    }
    
    public func test_BuilderTestWithBigInteger() throws {
        let txObj = try Cancel.Builder()
            .setNonce(BigInt(hex: nonce)!)
            .setGas(BigInt(hex: gas)!)
            .setGasPrice(BigInt(hex: gasPrice)!)
            .setChainId(BigInt(hex: chainID)!)
            .setFrom(from)
            .setSignatures(signatureData)
            .build()
        
        XCTAssertNotNil(txObj)
        
        XCTAssertEqual(gas, txObj.gas)
        XCTAssertEqual(gasPrice, txObj.gasPrice)
        XCTAssertEqual(chainID, txObj.chainId)
    }
    
    public func test_throwException_invalidFrom() throws {
        let from = "invalid Address"
        XCTAssertThrowsError(try Cancel.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setSignatures(signatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(from)"))
        }
    }
    
    public func test_throwException_missingFrom() throws {
        let from = ""
        XCTAssertThrowsError(try Cancel.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setSignatures(signatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("from is missing."))
        }
    }
    
    public func test_throwException_invalidGas() throws {
        let gas = "invalid gas"
        XCTAssertThrowsError(try Cancel.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setSignatures(signatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid gas. : \(gas)"))
        }
    }
    
    public func test_throwException_missingGas() throws {
        let gas = ""
        XCTAssertThrowsError(try Cancel.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setSignatures(signatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("gas is missing."))
        }
    }
}

class CancelTest_createInstance: XCTestCase {
    let from = CancelTest.from
    let gas = CancelTest.gas
    let nonce = CancelTest.nonce
    let gasPrice = CancelTest.gasPrice
    let chainID = CancelTest.chainID
    let signatureData = CancelTest.signatureData
    
    public func test_createInstance() throws {
        let txObj = try Cancel(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil
        )
        
        XCTAssertNotNil(txObj)
    }
    
    public func test_throwException_invalidFrom() throws {
        let from = "invalid Address"
        XCTAssertThrowsError(try Cancel(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(from)"))
        }
    }
    
    public func test_throwException_missingFrom() throws {
        let from = ""
        XCTAssertThrowsError(try Cancel(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("from is missing."))
        }
    }
    
    public func test_throwException_invalidGas() throws {
        let gas = "invalid gas"
        XCTAssertThrowsError(try Cancel(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid gas. : \(gas)"))
        }
    }
    
    public func test_throwException_missingGas() throws {
        let gas = ""
        XCTAssertThrowsError(try Cancel(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("gas is missing."))
        }
    }
}

class CancelTest_getRLPEncodingTest: XCTestCase {
    let from = CancelTest.from
    let gas = CancelTest.gas
    let nonce = CancelTest.nonce
    let gasPrice = CancelTest.gasPrice
    let chainID = CancelTest.chainID
    let signatureData = CancelTest.signatureData
    let expectedRLPEncoding = CancelTest.expectedRLPEncoding
        
    public func test_getRLPEncoding() throws {
        let txObj = try Cancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setChainId(chainID)
            .setSignatures(signatureData)
            .build()
        
        XCTAssertEqual(expectedRLPEncoding, try txObj.getRLPEncoding())
    }
    
    public func test_throwException_NoNonce() throws {
        let txObj = try Cancel.Builder()
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setChainId(chainID)
            .setSignatures(signatureData)
            .build()
        
        XCTAssertThrowsError(try txObj.getRLPEncoding()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NoGasPrice() throws {
        let txObj = try Cancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setChainId(chainID)
            .setFrom(from)
            .build()
        
        XCTAssertThrowsError(try txObj.getRLPEncoding()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class CancelTest_signWithKeyTest: XCTestCase {
    var mTxObj: Cancel?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = CancelTest.privateKey
    let from = CancelTest.from
    let gas = CancelTest.gas
    let nonce = CancelTest.nonce
    let gasPrice = CancelTest.gasPrice
    let chainID = CancelTest.chainID
    let signatureData = CancelTest.signatureData
    let expectedRLPEncoding = CancelTest.expectedRLPEncoding
        
    override func setUpWithError() throws {
        mTxObj = try Cancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setChainId(chainID)
            .build()
        
        coupledKeyring = try KeyringFactory.createFromPrivateKey(privateKey)
        deCoupledKeyring = try KeyringFactory.createWithSingleKey(PrivateKey.generate().getDerivedAddress(), privateKey)
        klaytnWalletKey = try coupledKeyring?.getKlaytnWalletKey()
    }
    
    public func test_signWithKey_Keyring() throws {
        _ = try mTxObj!.sign(coupledKeyring!, 0, TransactionHasher.getHashForSignature(_:))
        XCTAssertEqual(expectedRLPEncoding, try mTxObj?.getRawTransaction())
    }
    
    public func test_signWithKey_Keyring_NoIndex() throws {
        _ = try mTxObj!.sign(coupledKeyring!, TransactionHasher.getHashForSignature(_:))
        XCTAssertEqual(expectedRLPEncoding, try mTxObj?.getRawTransaction())
    }
    
    public func test_signWithKey_Keyring_NoSigner() throws {
        _ = try mTxObj!.sign(coupledKeyring!, 0)
        XCTAssertEqual(expectedRLPEncoding, try mTxObj?.getRawTransaction())
    }
    
    public func test_signWithKey_Keyring_Only() throws {
        _ = try mTxObj!.sign(coupledKeyring!)
        XCTAssertEqual(expectedRLPEncoding, try mTxObj?.getRawTransaction())
    }
    
    public func test_signWithKey_KeyString_NoIndex() throws {
        _ = try mTxObj!.sign(privateKey, TransactionHasher.getHashForSignature(_:))
        XCTAssertEqual(expectedRLPEncoding, try mTxObj?.getRawTransaction())
    }
    
    public func test_signWithKey_KeyString_Only() throws {
        _ = try mTxObj!.sign(privateKey)
        XCTAssertEqual(expectedRLPEncoding, try mTxObj?.getRawTransaction())
    }
    
    public func test_signWithKey_KlayWalletKey() throws {
        _ = try mTxObj!.sign(klaytnWalletKey!)
        XCTAssertEqual(expectedRLPEncoding, try mTxObj?.getRawTransaction())
    }
    
    public func test_throwException_NotMatchAddress() throws {
        XCTAssertThrowsError(try mTxObj!.sign(deCoupledKeyring!)) {
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

class CancelTest_signWithKeysTest: XCTestCase {
    var mTxObj: Cancel?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = CancelTest.privateKey
    let from = CancelTest.from
    let gas = CancelTest.gas
    let nonce = CancelTest.nonce
    let gasPrice = CancelTest.gasPrice
    let chainID = CancelTest.chainID
    let signatureData = CancelTest.signatureData
    let expectedRLPEncoding = CancelTest.expectedRLPEncoding
        
    override func setUpWithError() throws {
        mTxObj = try Cancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setChainId(chainID)
            .build()
        
        coupledKeyring = try KeyringFactory.createFromPrivateKey(privateKey)
        deCoupledKeyring = try KeyringFactory.createWithSingleKey(PrivateKey.generate().getDerivedAddress(), privateKey)
        klaytnWalletKey = try coupledKeyring?.getKlaytnWalletKey()
    }
    
    public func test_signWithKeys_Keyring() throws {
        _ = try mTxObj!.sign(coupledKeyring!, 0, TransactionHasher.getHashForSignature(_:))
        XCTAssertEqual(1, mTxObj?.signatures.count)
        XCTAssertEqual(expectedRLPEncoding, try mTxObj?.getRawTransaction())
    }
    
    public func test_signWithKeys_Keyring_NoSigner() throws {
        _ = try mTxObj!.sign(coupledKeyring!)
        XCTAssertEqual(1, mTxObj?.signatures.count)
        XCTAssertEqual(expectedRLPEncoding, try mTxObj?.getRawTransaction())
    }
    
    public func test_signWithKeys_KeyString() throws {
        _ = try mTxObj!.sign(privateKey, TransactionHasher.getHashForSignature(_:))
        XCTAssertEqual(1, mTxObj?.signatures.count)
        XCTAssertEqual(expectedRLPEncoding, try mTxObj?.getRawTransaction())
    }
    
    public func test_signWithKeys_KeyString_NoSigner() throws {
        _ = try mTxObj!.sign(privateKey)
        XCTAssertEqual(1, mTxObj?.signatures.count)
        XCTAssertEqual(expectedRLPEncoding, try mTxObj?.getRawTransaction())
    }
    
    public func test_throwException_NotMatchAddress() throws {
        XCTAssertThrowsError(try mTxObj!.sign(deCoupledKeyring!)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("The from address of the transaction is different with the address of the keyring to use"))
        }
    }
    
    public func test_signWithKeys_roleBasedKeyring() throws {
        let roleBased = try AccountUpdateTest.generateRoleBaseKeyring([3,3,3], from)
        _ = try mTxObj!.sign(roleBased)
        XCTAssertEqual(3, mTxObj?.signatures.count)
    }
}

class CancelTest_appendSignaturesTest: XCTestCase {
    var mTxObj: Cancel?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = CancelTest.privateKey
    let from = CancelTest.from
    let gas = CancelTest.gas
    let nonce = CancelTest.nonce
    let gasPrice = CancelTest.gasPrice
    let chainID = CancelTest.chainID
    let signatureData = CancelTest.signatureData
    let expectedRLPEncoding = CancelTest.expectedRLPEncoding
    
    override func setUpWithError() throws {
        mTxObj = try Cancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setChainId(chainID)
            .build()
        
        coupledKeyring = try KeyringFactory.createFromPrivateKey(privateKey)
        deCoupledKeyring = try KeyringFactory.createWithSingleKey(PrivateKey.generate().getDerivedAddress(), privateKey)
        klaytnWalletKey = try coupledKeyring?.getKlaytnWalletKey()
    }
    
    public func test_appendSignature() throws {
        let signatureData = SignatureData(
            "0x0fea",
            "0xade9480f584fe481bf070ab758ecc010afa15debc33e1bd75af637d834073a6e",
            "0x38160105d78cef4529d765941ad6637d8dcf6bd99310e165fee1c39fff2aa27e"
        )
        try mTxObj!.appendSignatures(signatureData)
        XCTAssertEqual(signatureData, mTxObj?.signatures[0])
    }
    
    public func test_appendSignatureList() throws {
        let signatureData = SignatureData(
            "0x0fea",
            "0xade9480f584fe481bf070ab758ecc010afa15debc33e1bd75af637d834073a6e",
            "0x38160105d78cef4529d765941ad6637d8dcf6bd99310e165fee1c39fff2aa27e"
        )
        try mTxObj!.appendSignatures([signatureData])
        XCTAssertEqual(signatureData, mTxObj?.signatures[0])
    }
    
    public func test_appendSignatureList_EmptySig() throws {
        let emptySignature = SignatureData.getEmptySignature()
        mTxObj = try Cancel.Builder()
                            .setFrom(from)
                            .setGas(gas)
                            .setNonce(nonce)
                            .setGasPrice(gasPrice)
                            .setChainId(chainID)
                            .setSignatures(emptySignature)
                            .build()
        
        let signatureData = SignatureData(
            "0x0fea",
            "0xade9480f584fe481bf070ab758ecc010afa15debc33e1bd75af637d834073a6e",
            "0x38160105d78cef4529d765941ad6637d8dcf6bd99310e165fee1c39fff2aa27e"
        )
        try mTxObj!.appendSignatures([signatureData])
        XCTAssertEqual(signatureData, mTxObj?.signatures[0])
    }
    
    public func test_appendSignature_ExistedSignature() throws {
        let signatureData = SignatureData(
            "0x0fea",
            "0xade9480f584fe481bf070ab758ecc010afa15debc33e1bd75af637d834073a6e",
            "0x38160105d78cef4529d765941ad6637d8dcf6bd99310e165fee1c39fff2aa27e"
        )
        
        mTxObj = try Cancel.Builder()
                            .setFrom(from)
                            .setGas(gas)
                            .setNonce(nonce)
                            .setGasPrice(gasPrice)
                            .setChainId(chainID)
                            .setSignatures(signatureData)
                            .build()
        
        let signatureData1 = SignatureData(
            "0x0fea",
            "0x7a5011b41cfcb6270af1b5f8aeac8aeabb1edb436f028261b5add564de694700",
            "0x23ac51660b8b421bf732ef8148d0d4f19d5e29cb97be6bccb5ae505ebe89eb4a"
        )
        try mTxObj!.appendSignatures([signatureData1])
        XCTAssertEqual(2, mTxObj?.signatures.count)
        XCTAssertEqual(signatureData, mTxObj?.signatures[0])
        XCTAssertEqual(signatureData1, mTxObj?.signatures[1])
    }
    
    public func test_appendSignatureList_ExistedSignature() throws {
        let signatureData = SignatureData(
            "0x0fea",
            "0xade9480f584fe481bf070ab758ecc010afa15debc33e1bd75af637d834073a6e",
            "0x38160105d78cef4529d765941ad6637d8dcf6bd99310e165fee1c39fff2aa27e"
        )
        
        mTxObj = try Cancel.Builder()
                            .setFrom(from)
                            .setGas(gas)
                            .setNonce(nonce)
                            .setGasPrice(gasPrice)
                            .setChainId(chainID)
                            .setSignatures(signatureData)
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
        
        try mTxObj!.appendSignatures([signatureData1, signatureData2])
        XCTAssertEqual(3, mTxObj?.signatures.count)
        XCTAssertEqual(signatureData, mTxObj?.signatures[0])
        XCTAssertEqual(signatureData1, mTxObj?.signatures[1])
        XCTAssertEqual(signatureData2, mTxObj?.signatures[2])
    }
}

class CancelTest_combineSignatureTest: XCTestCase {
    var mTxObj: Cancel?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = CancelTest.privateKey
    let from = "0x504a835246e030d70ded9027f9f5a0aefcd45143"
    let gas = "0xdbba0"
    let nonce = "0x1"
    let gasPrice = "0x5d21dba00"
    let chainID = "0x7e3"
    let signatureData = CancelTest.signatureData
    let expectedRLPEncoding = CancelTest.expectedRLPEncoding
    
    public func test_combineSignature() throws {
        let expectedRLPEncoded = "0x38f869018505d21dba00830dbba094504a835246e030d70ded9027f9f5a0aefcd45143f847f845820feaa00382dcd275a9657d8fc3c4dc1509ad975f083184e3d34779dc6bef10e0e973c8a059d5deb0f4c06a35a8024506159864ffc46dd08d91d5ac16fa69e92fb2d6b9ae"
        
        let expectedSignature = SignatureData(
            "0x0fea",
            "0x0382dcd275a9657d8fc3c4dc1509ad975f083184e3d34779dc6bef10e0e973c8",
            "0x59d5deb0f4c06a35a8024506159864ffc46dd08d91d5ac16fa69e92fb2d6b9ae"
        )
        
        mTxObj = try Cancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setChainId(chainID)
            .build()
        
        let rlpEncoded = "0x38f869018505d21dba00830dbba094504a835246e030d70ded9027f9f5a0aefcd45143f847f845820feaa00382dcd275a9657d8fc3c4dc1509ad975f083184e3d34779dc6bef10e0e973c8a059d5deb0f4c06a35a8024506159864ffc46dd08d91d5ac16fa69e92fb2d6b9ae"
        
        let combined = try mTxObj!.combineSignedRawTransactions([rlpEncoded])
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature, mTxObj?.signatures[0])
    }
    
    public func test_combine_multipleSignature() throws {
        let expectedRLPEncoded = "0x38f8f7018505d21dba00830dbba094504a835246e030d70ded9027f9f5a0aefcd45143f8d5f845820feaa00382dcd275a9657d8fc3c4dc1509ad975f083184e3d34779dc6bef10e0e973c8a059d5deb0f4c06a35a8024506159864ffc46dd08d91d5ac16fa69e92fb2d6b9aef845820feaa05a3a7910ce495e316da1394f197cdadd95dbb6954d803052b9f62ce993c0ec3ca00934f8dda9666d759e511a5658de1db36faefb35e76a5e237d87ba8c3b9bb700f845820feaa0dccd060bd76582d221f6fe7e02e70877a25b65d80fed13b69b5c79d7c4520912a07572c5c68daf7094a17105eb6e5fed1b102bfe4ca737d62b51f921f7663fb2bd"
        
        let expectedSignature = [
            SignatureData(
                "0x0fea",
                "0x0382dcd275a9657d8fc3c4dc1509ad975f083184e3d34779dc6bef10e0e973c8",
                "0x59d5deb0f4c06a35a8024506159864ffc46dd08d91d5ac16fa69e92fb2d6b9ae"
            ),
            SignatureData(
                "0x0fea",
                "0x5a3a7910ce495e316da1394f197cdadd95dbb6954d803052b9f62ce993c0ec3c",
                "0x0934f8dda9666d759e511a5658de1db36faefb35e76a5e237d87ba8c3b9bb700"
            ),
            SignatureData(
                "0x0fea",
                "0xdccd060bd76582d221f6fe7e02e70877a25b65d80fed13b69b5c79d7c4520912",
                "0x7572c5c68daf7094a17105eb6e5fed1b102bfe4ca737d62b51f921f7663fb2bd"
            )
        ]
        
        let signatureData = SignatureData(
            "0x0fea",
            "0x0382dcd275a9657d8fc3c4dc1509ad975f083184e3d34779dc6bef10e0e973c8",
            "0x59d5deb0f4c06a35a8024506159864ffc46dd08d91d5ac16fa69e92fb2d6b9ae"
        )
        
        mTxObj = try Cancel.Builder()
            .setFrom(from)
            .setGas(gas)
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setSignatures(signatureData)
            .build()
        
        let rlpEncodedString = [
            "0x38f869018505d21dba00830dbba094504a835246e030d70ded9027f9f5a0aefcd45143f847f845820feaa05a3a7910ce495e316da1394f197cdadd95dbb6954d803052b9f62ce993c0ec3ca00934f8dda9666d759e511a5658de1db36faefb35e76a5e237d87ba8c3b9bb700",
            "0x38f869018505d21dba00830dbba094504a835246e030d70ded9027f9f5a0aefcd45143f847f845820feaa0dccd060bd76582d221f6fe7e02e70877a25b65d80fed13b69b5c79d7c4520912a07572c5c68daf7094a17105eb6e5fed1b102bfe4ca737d62b51f921f7663fb2bd"
        ]
        
        let combined = try mTxObj!.combineSignedRawTransactions(rlpEncodedString)
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature[0], mTxObj?.signatures[0])
        XCTAssertEqual(expectedSignature[1], mTxObj?.signatures[1])
        XCTAssertEqual(expectedSignature[2], mTxObj?.signatures[2])
    }
    
    public func test_throwException_differentField() throws {
        let nonce = BigInt(1234)
        mTxObj = try Cancel.Builder()
            .setFrom(from)
            .setGas(gas)
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .build()
        
        let rlpEncoded = "0x38f869018505d21dba00830dbba094504a835246e030d70ded9027f9f5a0aefcd45143f847f845820feaa05a3a7910ce495e316da1394f197cdadd95dbb6954d803052b9f62ce993c0ec3ca00934f8dda9666d759e511a5658de1db36faefb35e76a5e237d87ba8c3b9bb700"
        
        XCTAssertThrowsError(try mTxObj!.combineSignedRawTransactions([rlpEncoded])) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("Transactions containing different information cannot be combined."))
        }
    }
}

class CancelTest_getRawTransactionTest: XCTestCase {
    var mTxObj: Cancel?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = CancelTest.privateKey
    let from = CancelTest.from
    let gas = CancelTest.gas
    let nonce = CancelTest.nonce
    let gasPrice = CancelTest.gasPrice
    let chainID = CancelTest.chainID
    let signatureData = CancelTest.signatureData
    let expectedRLPEncoding = CancelTest.expectedRLPEncoding
    
    override func setUpWithError() throws {
        mTxObj = try Cancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setChainId(chainID)
            .setSignatures(signatureData)
            .build()
        
        coupledKeyring = try KeyringFactory.createFromPrivateKey(privateKey)
        deCoupledKeyring = try KeyringFactory.createWithSingleKey(PrivateKey.generate().getDerivedAddress(), privateKey)
        klaytnWalletKey = try coupledKeyring?.getKlaytnWalletKey()
    }
    
    public func test_getRawTransaction() throws {
        let rawTx = try mTxObj?.getRawTransaction()
        XCTAssertEqual(expectedRLPEncoding, rawTx)
    }
}

class CancelTest_getTransactionHashTest: XCTestCase {
    var mTxObj: Cancel?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = CancelTest.privateKey
    let from = CancelTest.from
    let gas = CancelTest.gas
    let nonce = CancelTest.nonce
    let gasPrice = CancelTest.gasPrice
    let chainID = CancelTest.chainID
    let signatureData = CancelTest.signatureData
    let expectedRLPEncoding = CancelTest.expectedRLPEncoding
    let expectedTransactionHash = CancelTest.expectedTransactionHash
    
    override func setUpWithError() throws {
        mTxObj = try Cancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setChainId(chainID)
            .setSignatures(signatureData)
            .build()
        
        coupledKeyring = try KeyringFactory.createFromPrivateKey(privateKey)
        deCoupledKeyring = try KeyringFactory.createWithSingleKey(PrivateKey.generate().getDerivedAddress(), privateKey)
        klaytnWalletKey = try coupledKeyring?.getKlaytnWalletKey()
    }
        
    public func test_getTransactionHash() throws {
        let txHash = try mTxObj?.getTransactionHash()
        XCTAssertEqual(expectedTransactionHash, txHash)
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try Cancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setChainId(chainID)
            .setSignatures(signatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getTransactionHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_gasPrice() throws {
        let gasPrice = ""
        
        mTxObj = try Cancel.Builder()
            .setFrom(from)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setNonce(nonce)
            .setChainId(chainID)
            .setSignatures(signatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getTransactionHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class CancelTest_getSenderTxHashTest: XCTestCase {
    var mTxObj: Cancel?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = CancelTest.privateKey
    let from = CancelTest.from
    let gas = CancelTest.gas
    let nonce = CancelTest.nonce
    let gasPrice = CancelTest.gasPrice
    let chainID = CancelTest.chainID
    let signatureData = CancelTest.signatureData
    let expectedRLPEncoding = CancelTest.expectedRLPEncoding
    let expectedTransactionHash = CancelTest.expectedTransactionHash
    
    override func setUpWithError() throws {
        mTxObj = try Cancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setChainId(chainID)
            .setSignatures(signatureData)
            .build()
        
        coupledKeyring = try KeyringFactory.createFromPrivateKey(privateKey)
        deCoupledKeyring = try KeyringFactory.createWithSingleKey(PrivateKey.generate().getDerivedAddress(), privateKey)
        klaytnWalletKey = try coupledKeyring?.getKlaytnWalletKey()
    }
        
    public func test_getRLPEncodingForSignature() throws {
        let txHash = try mTxObj?.getSenderTxHash()
        XCTAssertEqual(expectedTransactionHash, txHash)
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try Cancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setChainId(chainID)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getSenderTxHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_gasPrice() throws {
        let gasPrice = ""
        
        mTxObj = try Cancel.Builder()
            .setFrom(from)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setNonce(nonce)
            .setChainId(chainID)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getSenderTxHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class CancelTest_getRLPEncodingForSignatureTest: XCTestCase {
    var mTxObj: Cancel?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = CancelTest.privateKey
    let from = CancelTest.from
    let gas = CancelTest.gas
    let nonce = CancelTest.nonce
    let gasPrice = CancelTest.gasPrice
    let chainID = CancelTest.chainID
    let signatureData = CancelTest.signatureData
    let expectedRLPEncoding = CancelTest.expectedRLPEncoding
    let expectedTransactionHash = CancelTest.expectedTransactionHash
    let expectedRLPEncodingForSigning = CancelTest.expectedRLPEncodingForSigning
    
    override func setUpWithError() throws {
        mTxObj = try Cancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setChainId(chainID)
            .build()
        
        coupledKeyring = try KeyringFactory.createFromPrivateKey(privateKey)
        deCoupledKeyring = try KeyringFactory.createWithSingleKey(PrivateKey.generate().getDerivedAddress(), privateKey)
        klaytnWalletKey = try coupledKeyring?.getKlaytnWalletKey()
    }
        
    public func test_getRLPEncodingForSignature() throws {
        let rlp = try mTxObj?.getRLPEncodingForSignature()
        XCTAssertEqual(expectedRLPEncodingForSigning, rlp)
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try Cancel.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFrom(from)
            .setChainId(chainID)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_gasPrice() throws {
        let gasPrice = ""
        
        mTxObj = try Cancel.Builder()
            .setFrom(from)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setNonce(nonce)
            .setChainId(chainID)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_chainID() throws {
        let chainID = ""
        
        mTxObj = try Cancel.Builder()
            .setFrom(from)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setNonce(nonce)
            .setChainId(chainID)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("chainId is undefined. Define chainId in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}
