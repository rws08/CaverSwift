//
//  SmartContractExecutionTest.swift
//  CaverSwiftTests
//
//  Created by won on 2021/07/15.
//

import XCTest
@testable import CaverSwift

class SmartContractExecutionTest: XCTestCase {
    static let caver = Caver(Caver.DEFAULT_URL)

    static let privateKey = "0x45a915e4d060149eb4365960e6a7a45f334393093061116b197e3240065ff2d8"
    static let from = "0xa94f5374Fce5edBC8E2a8697C15331677e6EbF0B"
    static let to = "0x7b65B75d204aBed71587c9E519a89277766EE1d0"
    static let gas = "0xf4240"
    static let gasPrice = "0x19"
    static let nonce = "0x4d2"
    static let chainID = "0x1"
    static let value = "0xa"
    static let input = "0x6353586b000000000000000000000000bc5951f055a85f41a3b62fd6f68ab7de76d299b2"
    static let humanReadable = false
    static let codeFormat = CodeFormat.EVM.hexa

    static let signatureData = SignatureData(
            "0x26",
            "0xe4276df1a779274fbb04bc18a0184809eec1ce9770527cebb3d64f926dc1810b",
            "0x4103b828a0671a48d64fe1a3879eae229699f05a684d9c5fd939015dcdd9709b"
    )

    static let expectedRLPEncoding = "0x30f89f8204d219830f4240947b65b75d204abed71587c9e519a89277766ee1d00a94a94f5374fce5edbc8e2a8697c15331677e6ebf0ba46353586b000000000000000000000000bc5951f055a85f41a3b62fd6f68ab7de76d299b2f845f84326a0e4276df1a779274fbb04bc18a0184809eec1ce9770527cebb3d64f926dc1810ba04103b828a0671a48d64fe1a3879eae229699f05a684d9c5fd939015dcdd9709b"
    static let expectedTransactionHash = "0x23bb192bd58d56527843eb63225c5213f3aded95e4c9776f1ff0bdd8ee0b6826"
    static let expectedRLPEncodingForSigning = "0xf860b85bf859308204d219830f4240947b65b75d204abed71587c9e519a89277766ee1d00a94a94f5374fce5edbc8e2a8697c15331677e6ebf0ba46353586b000000000000000000000000bc5951f055a85f41a3b62fd6f68ab7de76d299b2018080"

    public static func generateRoleBaseKeyring(_ numArr: [Int], _ address: String) throws -> AbstractKeyring {
        let keyArr = numArr.map {
            (0..<$0).map { _ in
                PrivateKey.generate("entropy").privateKey
            }
        }
        
        return try KeyringFactory.createWithRoleBasedKey(address, keyArr)
    }
}

class SmartContractExecutionTest_createInstanceBuilder: XCTestCase {
    let from = SmartContractExecutionTest.from
    let to = SmartContractExecutionTest.to
    let gas = SmartContractExecutionTest.gas
    let nonce = SmartContractExecutionTest.nonce
    let gasPrice = SmartContractExecutionTest.gasPrice
    let chainID = SmartContractExecutionTest.chainID
    let value = SmartContractExecutionTest.value
    let input = SmartContractExecutionTest.input
    let humanReadable = SmartContractExecutionTest.humanReadable
    let codeFormat = SmartContractExecutionTest.codeFormat
    let signatureData = SmartContractExecutionTest.signatureData
    
    public func test_BuilderTest() throws {
        let txObj = try SmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setTo(to)
            .setInput(input)
            .setSignatures(signatureData)
            .build()
        
        XCTAssertNotNil(txObj)
    }
    
    public func test_BuilderWithRPCTest() throws {
        let txObj = try SmartContractExecution.Builder()
            .setKlaytnCall(SmartContractExecutionTest.caver.rpc.klay)
            .setGas(gas)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setTo(to)
            .setInput(input)
            .setSignatures(signatureData)
            .build()
        
        try txObj.fillTransaction()
        
        XCTAssertFalse(txObj.nonce.isEmpty)
        XCTAssertFalse(txObj.gasPrice.isEmpty)
        XCTAssertFalse(txObj.chainId.isEmpty)
    }
    
    public func test_BuilderTestWithBigInteger() throws {
        let txObj = try SmartContractExecution.Builder()
            .setNonce(BigInt(hex: nonce)!)
            .setGas(BigInt(hex: gas)!)
            .setGasPrice(BigInt(hex: gasPrice)!)
            .setChainId(BigInt(hex: chainID)!)
            .setFrom(from)
            .setTo(to)
            .setInput(input)
            .setSignatures(signatureData)
            .build()
        
        XCTAssertNotNil(txObj)
        
        XCTAssertEqual(gas, txObj.gas)
        XCTAssertEqual(gasPrice, txObj.gasPrice)
        XCTAssertEqual(chainID, txObj.chainId)
    }
    
    public func test_throwException_invalidFrom() throws {
        let from = "invalid Address"
        XCTAssertThrowsError(try SmartContractExecution.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setTo(to)
                                .setInput(input)
                                .setSignatures(signatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(from)"))
        }
    }
    
    public func test_throwException_missingFrom() throws {
        let from = ""
        XCTAssertThrowsError(try SmartContractExecution.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setTo(to)
                                .setInput(input)
                                .setSignatures(signatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("from is missing."))
        }
    }
    
    public func test_throwException_invalidTo() throws {
        let to = "invalid Address"
        XCTAssertThrowsError(try SmartContractExecution.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setTo(to)
                                .setInput(input)
                                .setSignatures(signatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(to)"))
        }
    }
    
    public func test_throwException_missingTo() throws {
        let to = ""
        XCTAssertThrowsError(try SmartContractExecution.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setTo(to)
                                .setInput(input)
                                .setSignatures(signatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("to is missing."))
        }
    }
    
    public func test_throwException_invalidValue() throws {
        let value = "invalid value"
        XCTAssertThrowsError(try SmartContractExecution.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setTo(to)
                                .setInput(input)
                                .setSignatures(signatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid value : \(value)"))
        }
    }
    
    public func test_throwException_missingValue() throws {
        let value = ""
        XCTAssertThrowsError(try SmartContractExecution.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setTo(to)
                                .setInput(input)
                                .setSignatures(signatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("value is missing."))
        }
    }
    
    public func test_throwException_invalidGas() throws {
        let gas = "invalid gas"
        XCTAssertThrowsError(try SmartContractExecution.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setTo(to)
                                .setInput(input)
                                .setSignatures(signatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid gas. : \(gas)"))
        }
    }
    
    public func test_throwException_missingGas() throws {
        let gas = ""
        XCTAssertThrowsError(try SmartContractExecution.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setTo(to)
                                .setInput(input)
                                .setSignatures(signatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("gas is missing."))
        }
    }
    
    public func test_throwException_invalidInput() throws {
        let input = "invalid input"
        XCTAssertThrowsError(try SmartContractExecution.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setTo(to)
                                .setInput(input)
                                .setSignatures(signatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid input : \(input)"))
        }
    }
    
    public func test_throwException_missingInput() throws {
        let input = ""
        XCTAssertThrowsError(try SmartContractExecution.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setTo(to)
                                .setInput(input)
                                .setSignatures(signatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("input is missing."))
        }
    }
}

class SmartContractExecutionTest_createInstance: XCTestCase {
    let from = SmartContractExecutionTest.from
    let to = SmartContractExecutionTest.to
    let gas = SmartContractExecutionTest.gas
    let nonce = SmartContractExecutionTest.nonce
    let gasPrice = SmartContractExecutionTest.gasPrice
    let chainID = SmartContractExecutionTest.chainID
    let value = SmartContractExecutionTest.value
    let input = SmartContractExecutionTest.input
    let humanReadable = SmartContractExecutionTest.humanReadable
    let codeFormat = SmartContractExecutionTest.codeFormat
    let signatureData = SmartContractExecutionTest.signatureData
    
    public func test_createInstance() throws {
        let txObj = try SmartContractExecution(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            to,
            value,
            input
        )
        
        XCTAssertNotNil(txObj)
    }
    
    public func test_throwException_invalidFrom() throws {
        let from = "invalid Address"
        XCTAssertThrowsError(try SmartContractExecution(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            to,
            value,
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(from)"))
        }
    }
    
    public func test_throwException_missingFrom() throws {
        let from = ""
        XCTAssertThrowsError(try SmartContractExecution(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            to,
            value,
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("from is missing."))
        }
    }
    
    public func test_throwException_invalidTo() throws {
        let to = "invalid address"
        XCTAssertThrowsError(try SmartContractExecution(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            to,
            value,
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(to)"))
        }
    }
    
    public func test_throwException_missingTo() throws {
        let to = ""
        XCTAssertThrowsError(try SmartContractExecution(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            to,
            value,
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("to is missing."))
        }
    }
    
    public func test_throwException_invalidValue() throws {
        let value = "invalid value"
        XCTAssertThrowsError(try SmartContractExecution(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            to,
            value,
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid value : \(value)"))
        }
    }
    
    public func test_throwException_missingValue() throws {
        let value = ""
        XCTAssertThrowsError(try SmartContractExecution(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            to,
            value,
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("value is missing."))
        }
    }
    
    public func test_throwException_invalidGas() throws {
        let gas = "invalid gas"
        XCTAssertThrowsError(try SmartContractExecution(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            to,
            value,
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid gas. : \(gas)"))
        }
    }
    
    public func test_throwException_missingGas() throws {
        let gas = ""
        XCTAssertThrowsError(try SmartContractExecution(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            to,
            value,
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("gas is missing."))
        }
    }
    
    public func test_throwException_invalidInput() throws {
        let input = "invalid input"
        XCTAssertThrowsError(try SmartContractExecution(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            to,
            value,
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid input : \(input)"))
        }
    }
    
    public func test_throwException_missingInput() throws {
        let input = ""
        XCTAssertThrowsError(try SmartContractExecution(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            to,
            value,
            input
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("input is missing."))
        }
    }
}

class SmartContractExecutionTest_getRLPEncodingTest: XCTestCase {
    let from = SmartContractExecutionTest.from
    let to = SmartContractExecutionTest.to
    let gas = SmartContractExecutionTest.gas
    let nonce = SmartContractExecutionTest.nonce
    let gasPrice = SmartContractExecutionTest.gasPrice
    let chainID = SmartContractExecutionTest.chainID
    let value = SmartContractExecutionTest.value
    let input = SmartContractExecutionTest.input
    let humanReadable = SmartContractExecutionTest.humanReadable
    let codeFormat = SmartContractExecutionTest.codeFormat
    let signatureData = SmartContractExecutionTest.signatureData
    
    let expectedRLPEncoding = SmartContractExecutionTest.expectedRLPEncoding
        
    public func test_getRLPEncoding() throws {
        let txObj = try SmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setTo(to)
            .setInput(input)
            .setSignatures(signatureData)
            .build()
        
        XCTAssertEqual(expectedRLPEncoding, try txObj.getRLPEncoding())
    }
    
    public func test_throwException_NoNonce() throws {
        let txObj = try SmartContractExecution.Builder()
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setTo(to)
            .setInput(input)
            .setSignatures(signatureData)
            .build()
        
        XCTAssertThrowsError(try txObj.getRLPEncoding()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NoGasPrice() throws {
        let txObj = try SmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setTo(to)
            .setInput(input)
            .setSignatures(signatureData)
            .build()
        
        XCTAssertThrowsError(try txObj.getRLPEncoding()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class SmartContractExecutionTest_signWithKeyTest: XCTestCase {
    var mTxObj: SmartContractExecution?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = SmartContractExecutionTest.privateKey
    
    let from = "0xa94f5374Fce5edBC8E2a8697C15331677e6EbF0B"
    let to = SmartContractExecutionTest.to
    let gas = SmartContractExecutionTest.gas
    let nonce = SmartContractExecutionTest.nonce
    let gasPrice = SmartContractExecutionTest.gasPrice
    let chainID = SmartContractExecutionTest.chainID
    let value = SmartContractExecutionTest.value
    let input = SmartContractExecutionTest.input
    let humanReadable = SmartContractExecutionTest.humanReadable
    let codeFormat = SmartContractExecutionTest.codeFormat
    let signatureData = SmartContractExecutionTest.signatureData
    
    let expectedRLPEncoding = SmartContractExecutionTest.expectedRLPEncoding
        
    override func setUpWithError() throws {
        mTxObj = try SmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setTo(to)
            .setInput(input)
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

class SmartContractExecutionTest_signWithKeysTest: XCTestCase {
    var mTxObj: SmartContractExecution?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = SmartContractExecutionTest.privateKey
    
    let from = "0xa94f5374Fce5edBC8E2a8697C15331677e6EbF0B"
    let to = SmartContractExecutionTest.to
    let gas = SmartContractExecutionTest.gas
    let nonce = SmartContractExecutionTest.nonce
    let gasPrice = SmartContractExecutionTest.gasPrice
    let chainID = SmartContractExecutionTest.chainID
    let value = SmartContractExecutionTest.value
    let input = SmartContractExecutionTest.input
    let humanReadable = SmartContractExecutionTest.humanReadable
    let codeFormat = SmartContractExecutionTest.codeFormat
    let signatureData = SmartContractExecutionTest.signatureData
    
    let expectedRLPEncoding = SmartContractExecutionTest.expectedRLPEncoding
        
    override func setUpWithError() throws {
        mTxObj = try SmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setTo(to)
            .setInput(input)
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

class SmartContractExecutionTest_appendSignaturesTest: XCTestCase {
    var mTxObj: SmartContractExecution?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = SmartContractExecutionTest.privateKey
    let from = SmartContractExecutionTest.from
    let to = SmartContractExecutionTest.to
    let gas = SmartContractExecutionTest.gas
    let nonce = SmartContractExecutionTest.nonce
    let gasPrice = SmartContractExecutionTest.gasPrice
    let chainID = SmartContractExecutionTest.chainID
    let value = SmartContractExecutionTest.value
    let input = SmartContractExecutionTest.input
    let humanReadable = SmartContractExecutionTest.humanReadable
    let codeFormat = SmartContractExecutionTest.codeFormat
    let signatureData = SmartContractExecutionTest.signatureData
    let expectedRLPEncoding = SmartContractExecutionTest.expectedRLPEncoding
    
    override func setUpWithError() throws {
        mTxObj = try SmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
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
        mTxObj = try SmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
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
        
        mTxObj = try SmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
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
        
        mTxObj = try SmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
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

class SmartContractExecutionTest_combineSignatureTest: XCTestCase {
    var mTxObj: SmartContractExecution?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = SmartContractExecutionTest.privateKey
    let from = "0x2de587b91c76fb0b92fd607c4fbd5e9a17da799f"
    let to = "0xe3cd4e1cd287235cc0ea48c9fd02978533f5ec2b"
    let gas = "0xdbba0"
    let nonce = "0x1"
    let gasPrice = "0x5d21dba00"
    let chainID = "0x7e3"
    let value = BigInt(0)
    let input = "0xa9059cbb0000000000000000000000008a4c9c443bb0645df646a2d5bb55def0ed1e885a0000000000000000000000000000000000000000000000000000000000003039"
    let humanReadable = SmartContractExecutionTest.humanReadable
    let codeFormat = SmartContractExecutionTest.codeFormat
    let signatureData = SmartContractExecutionTest.signatureData
    let expectedRLPEncoding = SmartContractExecutionTest.expectedRLPEncoding
    
    override func setUpWithError() throws {
        mTxObj = try SmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setSignatures(signatureData)
            .build()
    }
    
    public func test_combineSignature() throws {
        let expectedRLPEncoded = "0x30f90153018505d21dba00830dbba094e3cd4e1cd287235cc0ea48c9fd02978533f5ec2b80942de587b91c76fb0b92fd607c4fbd5e9a17da799fb844a9059cbb0000000000000000000000008a4c9c443bb0645df646a2d5bb55def0ed1e885a0000000000000000000000000000000000000000000000000000000000003039f8d5f845820fe9a04a7d00c2680e5bca49a5880e23c5adb40b069af204a55e888f45746a20978e46a007b57a439201d182f4aec5db28d72192468f58f4fe7a1e717f96dd0d1def2d16f845820fe9a08494bfd86b0480e33700635d37ab0eb0ce3e6d93b5c51e6eda9fadd179569804a047f601d9fcb8682090165d8d048d6a5e3c5a48377ec9b212be6d7ee72b768bfdf845820fe9a0f642b38cf64cf70c89a0ccd74de13266ea98854078119a4619cad3bb2e6d4530a02307abe779333fe9da8eeebf40fbfeff9f1314ae8467a0119541339dfb65f10a"
        
        let expectedSignature = [
            SignatureData(
                "0x0fe9",
                "0x4a7d00c2680e5bca49a5880e23c5adb40b069af204a55e888f45746a20978e46",
                "0x07b57a439201d182f4aec5db28d72192468f58f4fe7a1e717f96dd0d1def2d16"
            ),
            SignatureData(
                "0x0fe9",
                "0x8494bfd86b0480e33700635d37ab0eb0ce3e6d93b5c51e6eda9fadd179569804",
                "0x47f601d9fcb8682090165d8d048d6a5e3c5a48377ec9b212be6d7ee72b768bfd"
            ),
            SignatureData(
                "0x0fe9",
                "0xf642b38cf64cf70c89a0ccd74de13266ea98854078119a4619cad3bb2e6d4530",
                "0x2307abe779333fe9da8eeebf40fbfeff9f1314ae8467a0119541339dfb65f10a"
            )
        ]
        
        let signatureData = SignatureData(
            "0x0fe9",
            "0x4a7d00c2680e5bca49a5880e23c5adb40b069af204a55e888f45746a20978e46",
            "0x07b57a439201d182f4aec5db28d72192468f58f4fe7a1e717f96dd0d1def2d16"
        )
        
        mTxObj = try SmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setSignatures(signatureData)
            .build()
        
        let rlpEncodedString = [
            "0x30f8c5018505d21dba00830dbba094e3cd4e1cd287235cc0ea48c9fd02978533f5ec2b80942de587b91c76fb0b92fd607c4fbd5e9a17da799fb844a9059cbb0000000000000000000000008a4c9c443bb0645df646a2d5bb55def0ed1e885a0000000000000000000000000000000000000000000000000000000000003039f847f845820fe9a08494bfd86b0480e33700635d37ab0eb0ce3e6d93b5c51e6eda9fadd179569804a047f601d9fcb8682090165d8d048d6a5e3c5a48377ec9b212be6d7ee72b768bfd",
            "0x30f8c5018505d21dba00830dbba094e3cd4e1cd287235cc0ea48c9fd02978533f5ec2b80942de587b91c76fb0b92fd607c4fbd5e9a17da799fb844a9059cbb0000000000000000000000008a4c9c443bb0645df646a2d5bb55def0ed1e885a0000000000000000000000000000000000000000000000000000000000003039f847f845820fe9a0f642b38cf64cf70c89a0ccd74de13266ea98854078119a4619cad3bb2e6d4530a02307abe779333fe9da8eeebf40fbfeff9f1314ae8467a0119541339dfb65f10a"
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
        mTxObj = try SmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setSignatures(signatureData)
            .build()
        
        let rlpEncoded = "0x28f9027e018505d21dba00830dbba080809447a4caa81fe2ed8cc834aafe5b1d7ee3ddedecfab9020e60806040526000805534801561001457600080fd5b506101ea806100246000396000f30060806040526004361061006d576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff16806306661abd1461007257806342cbb15c1461009d578063767800de146100c8578063b22636271461011f578063d14e62b814610150575b600080fd5b34801561007e57600080fd5b5061008761017d565b6040518082815260200191505060405180910390f35b3480156100a957600080fd5b506100b2610183565b6040518082815260200191505060405180910390f35b3480156100d457600080fd5b506100dd61018b565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b34801561012b57600080fd5b5061014e60048036038101908080356000191690602001909291905050506101b1565b005b34801561015c57600080fd5b5061017b600480360381019080803590602001909291905050506101b4565b005b60005481565b600043905090565b600160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b50565b80600081905550505600a165627a7a7230582053c65686a3571c517e2cf4f741d842e5ee6aa665c96ce70f46f9a594794f11eb00298080f847f845820fe9a06f59d699a5dd22a653b0ed1e39cbfc52ee468607eec95b195f302680ed7f9815a03b2f3f2a7a9482edfbcc9ee8e003e284b6c4a7ecbc8d361cc486562d4bdda389"
        
        XCTAssertThrowsError(try mTxObj!.combineSignedRawTransactions([rlpEncoded])) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("Transactions containing different information cannot be combined."))
        }
    }
}

class SmartContractExecutionTest_getRawTransactionTest: XCTestCase {
    var mTxObj: SmartContractExecution?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = SmartContractExecutionTest.privateKey
    let from = SmartContractExecutionTest.from
    let to = SmartContractExecutionTest.to
    let gas = SmartContractExecutionTest.gas
    let nonce = SmartContractExecutionTest.nonce
    let gasPrice = SmartContractExecutionTest.gasPrice
    let chainID = SmartContractExecutionTest.chainID
    let value = SmartContractExecutionTest.value
    let input = SmartContractExecutionTest.input
    let humanReadable = SmartContractExecutionTest.humanReadable
    let codeFormat = SmartContractExecutionTest.codeFormat
    let signatureData = SmartContractExecutionTest.signatureData
    let expectedRLPEncoding = SmartContractExecutionTest.expectedRLPEncoding
    
    override func setUpWithError() throws {
        mTxObj = try SmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
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

class SmartContractExecutionTest_getTransactionHashTest: XCTestCase {
    var mTxObj: SmartContractExecution?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = SmartContractExecutionTest.privateKey
    let from = SmartContractExecutionTest.from
    let to = SmartContractExecutionTest.to
    let gas = SmartContractExecutionTest.gas
    let nonce = SmartContractExecutionTest.nonce
    let gasPrice = SmartContractExecutionTest.gasPrice
    let chainID = SmartContractExecutionTest.chainID
    let value = SmartContractExecutionTest.value
    let input = SmartContractExecutionTest.input
    let humanReadable = SmartContractExecutionTest.humanReadable
    let codeFormat = SmartContractExecutionTest.codeFormat
    let signatureData = SmartContractExecutionTest.signatureData
    let expectedRLPEncoding = SmartContractExecutionTest.expectedRLPEncoding
    let expectedTransactionHash = SmartContractExecutionTest.expectedTransactionHash
    
    override func setUpWithError() throws {
        mTxObj = try SmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
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
        
        mTxObj = try SmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setSignatures(signatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getTransactionHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_gasPrice() throws {
        let gasPrice = ""
        
        mTxObj = try SmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setSignatures(signatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getTransactionHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class SmartContractExecutionTest_getSenderTxHashTest: XCTestCase {
    var mTxObj: SmartContractExecution?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = SmartContractExecutionTest.privateKey
    let from = SmartContractExecutionTest.from
    let to = SmartContractExecutionTest.to
    let gas = SmartContractExecutionTest.gas
    let nonce = SmartContractExecutionTest.nonce
    let gasPrice = SmartContractExecutionTest.gasPrice
    let chainID = SmartContractExecutionTest.chainID
    let value = SmartContractExecutionTest.value
    let input = SmartContractExecutionTest.input
    let humanReadable = SmartContractExecutionTest.humanReadable
    let codeFormat = SmartContractExecutionTest.codeFormat
    let signatureData = SmartContractExecutionTest.signatureData
    let expectedRLPEncoding = SmartContractExecutionTest.expectedRLPEncoding
    let expectedTransactionHash = SmartContractExecutionTest.expectedTransactionHash
    
    override func setUpWithError() throws {
        mTxObj = try SmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
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
        
        mTxObj = try SmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setSignatures(signatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getSenderTxHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_gasPrice() throws {
        let gasPrice = ""
        
        mTxObj = try SmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setSignatures(signatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getSenderTxHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class SmartContractExecutionTest_getRLPEncodingForSignatureTest: XCTestCase {
    var mTxObj: SmartContractExecution?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = SmartContractExecutionTest.privateKey
    let from = SmartContractExecutionTest.from
    let to = SmartContractExecutionTest.to
    let gas = SmartContractExecutionTest.gas
    let nonce = SmartContractExecutionTest.nonce
    let gasPrice = SmartContractExecutionTest.gasPrice
    let chainID = SmartContractExecutionTest.chainID
    let value = SmartContractExecutionTest.value
    let input = SmartContractExecutionTest.input
    let humanReadable = SmartContractExecutionTest.humanReadable
    let codeFormat = SmartContractExecutionTest.codeFormat
    let signatureData = SmartContractExecutionTest.signatureData
    let expectedRLPEncoding = SmartContractExecutionTest.expectedRLPEncoding
    let expectedTransactionHash = SmartContractExecutionTest.expectedTransactionHash
    let expectedRLPEncodingForSigning = SmartContractExecutionTest.expectedRLPEncodingForSigning
    
    override func setUpWithError() throws {
        mTxObj = try SmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
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
        
        mTxObj = try SmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setSignatures(signatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_gasPrice() throws {
        let gasPrice = ""
        
        mTxObj = try SmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setSignatures(signatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_chainID() throws {
        let chainID = ""
        
        mTxObj = try SmartContractExecution.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setTo(to)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setSignatures(signatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("chainId is undefined. Define chainId in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}
