//
//  ValueTransferTest.swift
//  CaverSwiftTests
//
//  Created by won on 2021/07/15.
//

import XCTest
@testable import CaverSwift

class ValueTransferTest: XCTestCase {
    static let caver = Caver(Caver.DEFAULT_URL)

    static let privateKey = "0x45a915e4d060149eb4365960e6a7a45f334393093061116b197e3240065ff2d8"
    static let from = "0xa94f5374Fce5edBC8E2a8697C15331677e6EbF0B"
    static let to = "0x7b65b75d204abed71587c9e519a89277766ee1d0"
    static let gas = "0xf4240"
    static let gasPrice = "0x19"
    static let nonce = "0x4D2"
    static let chainID = "0x1"
    static let value = "0xa"
    static let input = "0x68656c6c6f"
    static let humanReadable = false
    static let codeFormat = CodeFormat.EVM.hexa

    static let signatureData = SignatureData(
            "0x25",
            "0xf3d0cd43661cabf53425535817c5058c27781f478cb5459874feaa462ed3a29a",
            "0x6748abe186269ff10b8100a4b7d7fea274b53ea2905acbf498dc8b5ab1bf4fbc"
    )

    static let expectedRLPEncoding = "0x08f87a8204d219830f4240947b65b75d204abed71587c9e519a89277766ee1d00a94a94f5374fce5edbc8e2a8697c15331677e6ebf0bf845f84325a0f3d0cd43661cabf53425535817c5058c27781f478cb5459874feaa462ed3a29aa06748abe186269ff10b8100a4b7d7fea274b53ea2905acbf498dc8b5ab1bf4fbc"
    static let expectedTransactionHash = "0x762f130342569e9669a4d8547f1248bd2554fbbf3062d63a97ce28bfa97aa9d7"
    static let expectedRLPEncodingForSigning = "0xf839b5f4088204d219830f4240947b65b75d204abed71587c9e519a89277766ee1d00a94a94f5374fce5edbc8e2a8697c15331677e6ebf0b018080"

    public static func generateRoleBaseKeyring(_ numArr: [Int], _ address: String) throws -> AbstractKeyring {
        let keyArr = numArr.map {
            (0..<$0).map { _ in
                PrivateKey.generate("entropy").privateKey
            }
        }
        
        return try KeyringFactory.createWithRoleBasedKey(address, keyArr)
    }
}

class ValueTransferTest_createInstanceBuilder: XCTestCase {
    let from = ValueTransferTest.from
    let to = ValueTransferTest.to
    let gas = ValueTransferTest.gas
    let nonce = ValueTransferTest.nonce
    let gasPrice = ValueTransferTest.gasPrice
    let chainID = ValueTransferTest.chainID
    let value = ValueTransferTest.value
    let input = ValueTransferTest.input
    let humanReadable = ValueTransferTest.humanReadable
    let codeFormat = ValueTransferTest.codeFormat
    let signatureData = ValueTransferTest.signatureData
    
    public func test_BuilderTest() throws {
        let txObj = try ValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .build()
        
        XCTAssertNotNil(txObj)
    }
    
    public func test_BuilderWithRPCTest() throws {
        let txObj = try ValueTransfer.Builder()
            .setKlaytnCall(ValueTransferTest.caver.rpc.klay)
            .setGas(gas)
            .setTo(to)
            .setValue(value)
            .setFrom(from)
            .build()
        
        try txObj.fillTransaction()
        
        XCTAssertFalse(txObj.nonce.isEmpty)
        XCTAssertFalse(txObj.gasPrice.isEmpty)
        XCTAssertFalse(txObj.chainId.isEmpty)
    }
    
    public func test_BuilderTestWithBigInteger() throws {
        let txObj = try ValueTransfer.Builder()
            .setNonce(BigInt(hex: nonce)!)
            .setGas(BigInt(hex: gas)!)
            .setGasPrice(BigInt(hex: gasPrice)!)
            .setChainId(BigInt(hex: chainID)!)
            .setFrom(from)
            .setTo(to)
            .setValue(BigInt(hex: value)!)
            .build()
        
        XCTAssertNotNil(txObj)
        
        XCTAssertEqual(gas, txObj.gas)
        XCTAssertEqual(gasPrice, txObj.gasPrice)
        XCTAssertEqual(chainID, txObj.chainId)
    }
    
    public func test_throwException_invalidFrom() throws {
        let from = "invalid Address"
        XCTAssertThrowsError(try ValueTransfer.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(from)"))
        }
    }
    
    public func test_throwException_missingFrom() throws {
        let from = ""
        XCTAssertThrowsError(try ValueTransfer.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("from is missing."))
        }
    }
    
    public func test_throwException_invalidTo() throws {
        let to = "invalid Address"
        XCTAssertThrowsError(try ValueTransfer.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(to)"))
        }
    }
    
    public func test_throwException_missingTo() throws {
        let to = ""
        XCTAssertThrowsError(try ValueTransfer.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("to is missing."))
        }
    }
    
    public func test_throwException_invalidValue() throws {
        let value = "invalid value"
        XCTAssertThrowsError(try ValueTransfer.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid value : \(value)"))
        }
    }
    
    public func test_throwException_missingValue() throws {
        let value = ""
        XCTAssertThrowsError(try ValueTransfer.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("value is missing."))
        }
    }
    
    public func test_throwException_invalidGas() throws {
        let gas = "invalid gas"
        XCTAssertThrowsError(try ValueTransfer.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid gas. : \(gas)"))
        }
    }
    
    public func test_throwException_missingGas() throws {
        let gas = ""
        XCTAssertThrowsError(try ValueTransfer.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setTo(to)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("gas is missing."))
        }
    }
}

class ValueTransferTest_createInstance: XCTestCase {
    let from = ValueTransferTest.from
    let to = ValueTransferTest.to
    let gas = ValueTransferTest.gas
    let nonce = ValueTransferTest.nonce
    let gasPrice = ValueTransferTest.gasPrice
    let chainID = ValueTransferTest.chainID
    let value = ValueTransferTest.value
    let input = ValueTransferTest.input
    let humanReadable = ValueTransferTest.humanReadable
    let codeFormat = ValueTransferTest.codeFormat
    let signatureData = ValueTransferTest.signatureData
    
    public func test_createInstance() throws {
        let txObj = try ValueTransfer(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            to,
            value
        )
        
        XCTAssertNotNil(txObj)
    }
    
    public func test_throwException_invalidFrom() throws {
        let from = "invalid Address"
        XCTAssertThrowsError(try ValueTransfer(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            to,
            value
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(from)"))
        }
    }
    
    public func test_throwException_missingFrom() throws {
        let from = ""
        XCTAssertThrowsError(try ValueTransfer(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            to,
            value
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("from is missing."))
        }
    }
    
    public func test_throwException_invalidTo() throws {
        let to = "invalid address"
        XCTAssertThrowsError(try ValueTransfer(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            to,
            value
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(to)"))
        }
    }
    
    public func test_throwException_missingTo() throws {
        let to = ""
        XCTAssertThrowsError(try ValueTransfer(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            to,
            value
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("to is missing."))
        }
    }
    
    public func test_throwException_invalidValue() throws {
        let value = "invalid value"
        XCTAssertThrowsError(try ValueTransfer(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            to,
            value
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid value : \(value)"))
        }
    }
    
    public func test_throwException_missingValue() throws {
        let value = ""
        XCTAssertThrowsError(try ValueTransfer(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            to,
            value
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("value is missing."))
        }
    }
    
    public func test_throwException_invalidGas() throws {
        let gas = "invalid gas"
        XCTAssertThrowsError(try ValueTransfer(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            to,
            value
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid gas. : \(gas)"))
        }
    }
    
    public func test_throwException_missingGas() throws {
        let gas = ""
        XCTAssertThrowsError(try ValueTransfer(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            to,
            value
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("gas is missing."))
        }
    }
}

class ValueTransferTest_getRLPEncodingTest: XCTestCase {
    let from = ValueTransferTest.from
    let to = ValueTransferTest.to
    let gas = ValueTransferTest.gas
    let nonce = ValueTransferTest.nonce
    let gasPrice = ValueTransferTest.gasPrice
    let chainID = ValueTransferTest.chainID
    let value = ValueTransferTest.value
    let input = ValueTransferTest.input
    let humanReadable = ValueTransferTest.humanReadable
    let codeFormat = ValueTransferTest.codeFormat
    let signatureData = ValueTransferTest.signatureData
    
    let expectedRLPEncoding = ValueTransferTest.expectedRLPEncoding
        
    public func test_getRLPEncoding() throws {
        let txObj = try ValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setTo(to)
            .setSignatures(signatureData)
            .build()
        
        XCTAssertEqual(expectedRLPEncoding, try txObj.getRLPEncoding())
    }
    
    public func test_throwException_NoNonce() throws {
        let txObj = try ValueTransfer.Builder()
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setTo(to)
            .setSignatures(signatureData)
            .build()
        
        XCTAssertThrowsError(try txObj.getRLPEncoding()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NoGasPrice() throws {
        let txObj = try ValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setTo(to)
            .setSignatures(signatureData)
            .build()
        
        XCTAssertThrowsError(try txObj.getRLPEncoding()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class ValueTransferTest_signWithKeyTest: XCTestCase {
    var mTxObj: ValueTransfer?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = ValueTransferTest.privateKey
    
    let from = ValueTransferTest.from
    let to = ValueTransferTest.to
    let gas = ValueTransferTest.gas
    let nonce = ValueTransferTest.nonce
    let gasPrice = ValueTransferTest.gasPrice
    let chainID = ValueTransferTest.chainID
    let value = ValueTransferTest.value
    let input = ValueTransferTest.input
    let humanReadable = ValueTransferTest.humanReadable
    let codeFormat = ValueTransferTest.codeFormat
    let signatureData = ValueTransferTest.signatureData
    
    let expectedRLPEncoding = ValueTransferTest.expectedRLPEncoding
        
    override func setUpWithError() throws {
        mTxObj = try ValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setTo(to)
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

class ValueTransferTest_signWithKeysTest: XCTestCase {
    var mTxObj: ValueTransfer?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = ValueTransferTest.privateKey
    
    let from = ValueTransferTest.from
    let to = ValueTransferTest.to
    let gas = ValueTransferTest.gas
    let nonce = ValueTransferTest.nonce
    let gasPrice = ValueTransferTest.gasPrice
    let chainID = ValueTransferTest.chainID
    let value = ValueTransferTest.value
    let input = ValueTransferTest.input
    let humanReadable = ValueTransferTest.humanReadable
    let codeFormat = ValueTransferTest.codeFormat
    let signatureData = ValueTransferTest.signatureData
    
    let expectedRLPEncoding = ValueTransferTest.expectedRLPEncoding
        
    override func setUpWithError() throws {
        mTxObj = try ValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setTo(to)
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

class ValueTransferTest_appendSignaturesTest: XCTestCase {
    var mTxObj: ValueTransfer?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = ValueTransferTest.privateKey
    let from = ValueTransferTest.from
    let to = ValueTransferTest.to
    let gas = ValueTransferTest.gas
    let nonce = ValueTransferTest.nonce
    let gasPrice = ValueTransferTest.gasPrice
    let chainID = ValueTransferTest.chainID
    let value = ValueTransferTest.value
    let input = ValueTransferTest.input
    let humanReadable = ValueTransferTest.humanReadable
    let codeFormat = ValueTransferTest.codeFormat
    let signatureData = ValueTransferTest.signatureData
    let expectedRLPEncoding = ValueTransferTest.expectedRLPEncoding
    
    override func setUpWithError() throws {
        mTxObj = try ValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
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
        mTxObj = try ValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
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
        
        mTxObj = try ValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
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
        
        mTxObj = try ValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
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

class ValueTransferTest_combineSignatureTest: XCTestCase {
    var mTxObj: ValueTransfer?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = ValueTransferTest.privateKey
    let from = "0x7d0104ac150f749d36bb34999bcade9f2c0bd2e6"
    let to = "0x8723590d5D60e35f7cE0Db5C09D3938b26fF80Ae"
    let gas = BigInt(90000)
    let nonce = "0x3a"
    let gasPrice = "0x5d21dba00"
    let chainID = BigInt(2019)
    let value = BigInt(1)
    let input = "0x68656c6c6f"
    let humanReadable = ValueTransferTest.humanReadable
    let codeFormat = ValueTransferTest.codeFormat
    let signatureData = ValueTransferTest.signatureData
    let expectedRLPEncoding = ValueTransferTest.expectedRLPEncoding
    
    override func setUpWithError() throws {
        let signatureData = SignatureData(
                "0x0fea",
                "0x3d820b27d0997baf16f98df01c7b2b2e9734ad05b2228c4d403c2facff8397f3",
                "0x1f4a44eeb8b7f0b0019162d1d6b90c401078e56fcd7495e74f7cfcd37e25f017"
        )
        
        mTxObj = try ValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setSignatures(signatureData)
            .build()
    }
    
    public func test_combineSignature() throws {
        let expectedRLPEncoded = "0x08f87f3a8505d21dba0083015f90948723590d5d60e35f7ce0db5c09d3938b26ff80ae01947d0104ac150f749d36bb34999bcade9f2c0bd2e6f847f845820feaa03d820b27d0997baf16f98df01c7b2b2e9734ad05b2228c4d403c2facff8397f3a01f4a44eeb8b7f0b0019162d1d6b90c401078e56fcd7495e74f7cfcd37e25f017"
        
        let expectedSignature = SignatureData(
            "0x0fea",
            "0x3d820b27d0997baf16f98df01c7b2b2e9734ad05b2228c4d403c2facff8397f3",
            "0x1f4a44eeb8b7f0b0019162d1d6b90c401078e56fcd7495e74f7cfcd37e25f017"
        )
        
        let rlpEncoded = "0x08f87f3a8505d21dba0083015f90948723590d5d60e35f7ce0db5c09d3938b26ff80ae01947d0104ac150f749d36bb34999bcade9f2c0bd2e6f847f845820feaa03d820b27d0997baf16f98df01c7b2b2e9734ad05b2228c4d403c2facff8397f3a01f4a44eeb8b7f0b0019162d1d6b90c401078e56fcd7495e74f7cfcd37e25f017"
        
        let combined = try mTxObj!.combineSignedRawTransactions([rlpEncoded])
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature, mTxObj?.signatures[0])
    }
    
    public func test_combine_multipleSignature() throws {
        let expectedRLPEncoded = "0x08f9010d3a8505d21dba0083015f90948723590d5d60e35f7ce0db5c09d3938b26ff80ae01947d0104ac150f749d36bb34999bcade9f2c0bd2e6f8d5f845820feaa03d820b27d0997baf16f98df01c7b2b2e9734ad05b2228c4d403c2facff8397f3a01f4a44eeb8b7f0b0019162d1d6b90c401078e56fcd7495e74f7cfcd37e25f017f845820feaa0c24227c8128652d4ec039950d9cfa82c3f962c4f4dee61e54236bdf89cbff8e9a04522134ef899ba136a668afd4ae76bd00bb19c0dc5ff66d7492a6a2a506021c2f845820fe9a0c9845154419b26dcb7700b4856c38f6e272004654ac3f38e9663134863600c52a05671961420adee43ee4538cba0200e82ff3c939c81e7d6f977660546b06d6914"
        
        let expectedSignature = [
            SignatureData(
                "0x0fea",
                "0x3d820b27d0997baf16f98df01c7b2b2e9734ad05b2228c4d403c2facff8397f3",
                "0x1f4a44eeb8b7f0b0019162d1d6b90c401078e56fcd7495e74f7cfcd37e25f017"
            ),
            SignatureData(
                "0x0fea",
                "0xc24227c8128652d4ec039950d9cfa82c3f962c4f4dee61e54236bdf89cbff8e9",
                "0x4522134ef899ba136a668afd4ae76bd00bb19c0dc5ff66d7492a6a2a506021c2"
            ),
            SignatureData(
                "0x0fe9",
                "0xc9845154419b26dcb7700b4856c38f6e272004654ac3f38e9663134863600c52",
                "0x5671961420adee43ee4538cba0200e82ff3c939c81e7d6f977660546b06d6914"
            )
        ]
        
        let rlpEncodedString = [
            "0x08f87f3a8505d21dba0083015f90948723590d5d60e35f7ce0db5c09d3938b26ff80ae01947d0104ac150f749d36bb34999bcade9f2c0bd2e6f847f845820feaa0c24227c8128652d4ec039950d9cfa82c3f962c4f4dee61e54236bdf89cbff8e9a04522134ef899ba136a668afd4ae76bd00bb19c0dc5ff66d7492a6a2a506021c2",
            "0x08f87f3a8505d21dba0083015f90948723590d5d60e35f7ce0db5c09d3938b26ff80ae01947d0104ac150f749d36bb34999bcade9f2c0bd2e6f847f845820fe9a0c9845154419b26dcb7700b4856c38f6e272004654ac3f38e9663134863600c52a05671961420adee43ee4538cba0200e82ff3c939c81e7d6f977660546b06d6914"
        ]
        
        let combined = try mTxObj!.combineSignedRawTransactions(rlpEncodedString)
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature[0], mTxObj?.signatures[0])
        XCTAssertEqual(expectedSignature[1], mTxObj?.signatures[1])
        XCTAssertEqual(expectedSignature[2], mTxObj?.signatures[2])
    }
    
    public func test_throwException_differentField() throws {
        let signatureData = SignatureData(
            "0x0fea",
            "0x3d820b27d0997baf16f98df01c7b2b2e9734ad05b2228c4d403c2facff8397f3",
            "0x1f4a44eeb8b7f0b0019162d1d6b90c401078e56fcd7495e74f7cfcd37e25f017"
        )
        let value = "0x1000"
        mTxObj = try ValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setSignatures(signatureData)
            .build()
        
        let rlpEncoded = "0x08f87f3a8505d21dba0083015f90948723590d5d60e35f7ce0db5c09d3938b26ff80ae01947d0104ac150f749d36bb34999bcade9f2c0bd2e6f847f845820feaa0c24227c8128652d4ec039950d9cfa82c3f962c4f4dee61e54236bdf89cbff8e9a04522134ef899ba136a668afd4ae76bd00bb19c0dc5ff66d7492a6a2a506021c2"
        
        XCTAssertThrowsError(try mTxObj!.combineSignedRawTransactions([rlpEncoded])) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("Transactions containing different information cannot be combined."))
        }
    }
}

class ValueTransferTest_getRawTransactionTest: XCTestCase {
    var mTxObj: ValueTransfer?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = ValueTransferTest.privateKey
    let from = ValueTransferTest.from
    let to = ValueTransferTest.to
    let gas = ValueTransferTest.gas
    let nonce = ValueTransferTest.nonce
    let gasPrice = ValueTransferTest.gasPrice
    let chainID = ValueTransferTest.chainID
    let value = ValueTransferTest.value
    let input = ValueTransferTest.input
    let humanReadable = ValueTransferTest.humanReadable
    let codeFormat = ValueTransferTest.codeFormat
    let signatureData = ValueTransferTest.signatureData
    let expectedRLPEncoding = ValueTransferTest.expectedRLPEncoding
    
    override func setUpWithError() throws {
        mTxObj = try ValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
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

class ValueTransferTest_getTransactionHashTest: XCTestCase {
    var mTxObj: ValueTransfer?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = ValueTransferTest.privateKey
    let from = ValueTransferTest.from
    let to = ValueTransferTest.to
    let gas = ValueTransferTest.gas
    let nonce = ValueTransferTest.nonce
    let gasPrice = ValueTransferTest.gasPrice
    let chainID = ValueTransferTest.chainID
    let value = ValueTransferTest.value
    let input = ValueTransferTest.input
    let humanReadable = ValueTransferTest.humanReadable
    let codeFormat = ValueTransferTest.codeFormat
    let signatureData = ValueTransferTest.signatureData
    let expectedRLPEncoding = ValueTransferTest.expectedRLPEncoding
    let expectedTransactionHash = ValueTransferTest.expectedTransactionHash
    
    override func setUpWithError() throws {
        mTxObj = try ValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
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
        
        mTxObj = try ValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setSignatures(signatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getTransactionHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_gasPrice() throws {
        let gasPrice = ""
        
        mTxObj = try ValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setSignatures(signatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getTransactionHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class ValueTransferTest_getSenderTxHashTest: XCTestCase {
    var mTxObj: ValueTransfer?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = ValueTransferTest.privateKey
    let from = ValueTransferTest.from
    let to = ValueTransferTest.to
    let gas = ValueTransferTest.gas
    let nonce = ValueTransferTest.nonce
    let gasPrice = ValueTransferTest.gasPrice
    let chainID = ValueTransferTest.chainID
    let value = ValueTransferTest.value
    let input = ValueTransferTest.input
    let humanReadable = ValueTransferTest.humanReadable
    let codeFormat = ValueTransferTest.codeFormat
    let signatureData = ValueTransferTest.signatureData
    let expectedRLPEncoding = ValueTransferTest.expectedRLPEncoding
    let expectedTransactionHash = ValueTransferTest.expectedTransactionHash
    
    override func setUpWithError() throws {
        mTxObj = try ValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
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
        
        mTxObj = try ValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setSignatures(signatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getSenderTxHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_gasPrice() throws {
        let gasPrice = ""
        
        mTxObj = try ValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setSignatures(signatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getSenderTxHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class ValueTransferTest_getRLPEncodingForSignatureTest: XCTestCase {
    var mTxObj: ValueTransfer?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = ValueTransferTest.privateKey
    let from = ValueTransferTest.from
    let to = ValueTransferTest.to
    let gas = ValueTransferTest.gas
    let nonce = ValueTransferTest.nonce
    let gasPrice = ValueTransferTest.gasPrice
    let chainID = ValueTransferTest.chainID
    let value = ValueTransferTest.value
    let input = ValueTransferTest.input
    let humanReadable = ValueTransferTest.humanReadable
    let codeFormat = ValueTransferTest.codeFormat
    let signatureData = ValueTransferTest.signatureData
    let expectedRLPEncoding = ValueTransferTest.expectedRLPEncoding
    let expectedTransactionHash = ValueTransferTest.expectedTransactionHash
    let expectedRLPEncodingForSigning = ValueTransferTest.expectedRLPEncodingForSigning
    
    override func setUpWithError() throws {
        mTxObj = try ValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setSignatures(signatureData)
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
        
        mTxObj = try ValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setSignatures(signatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_gasPrice() throws {
        let gasPrice = ""
        
        mTxObj = try ValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setSignatures(signatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_chainID() throws {
        let chainID = ""
        
        mTxObj = try ValueTransfer.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setSignatures(signatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("chainId is undefined. Define chainId in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

