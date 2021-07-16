//
//  SmartContractDeployTest.swift
//  CaverSwiftTests
//
//  Created by won on 2021/07/14.
//

import XCTest
@testable import CaverSwift

class SmartContractDeployTest: XCTestCase {
    static let caver = Caver(Caver.DEFAULT_URL)

    static let privateKey = "0x45a915e4d060149eb4365960e6a7a45f334393093061116b197e3240065ff2d8"
    static let from = "0xd91aec35bea25d379e49cfe2dff5f5775cdac1a3"
    static let gas = "0xdbba0"
    static let gasPrice = "0x5d21dba00"
    static let nonce = "0x1f"
    static let chainID = "0x7e3"
    static let value = "0x0"
    static let input = "0x60806040526000805534801561001457600080fd5b506101ea806100246000396000f30060806040526004361061006d576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff16806306661abd1461007257806342cbb15c1461009d578063767800de146100c8578063b22636271461011f578063d14e62b814610150575b600080fd5b34801561007e57600080fd5b5061008761017d565b6040518082815260200191505060405180910390f35b3480156100a957600080fd5b506100b2610183565b6040518082815260200191505060405180910390f35b3480156100d457600080fd5b506100dd61018b565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b34801561012b57600080fd5b5061014e60048036038101908080356000191690602001909291905050506101b1565b005b34801561015c57600080fd5b5061017b600480360381019080803590602001909291905050506101b4565b005b60005481565b600043905090565b600160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b50565b80600081905550505600a165627a7a7230582053c65686a3571c517e2cf4f741d842e5ee6aa665c96ce70f46f9a594794f11eb0029"
    static let humanReadable = false
    static let codeFormat = CodeFormat.EVM.hexa

    static let signatureData = SignatureData(
            "0x0fe9",
            "0x018a9f680a74e275f1f83a5c2c45e1313c52432df4595e944240b1511a4f4ba7",
            "0x2d762c3417f91b81db4907db832cb28cc64df7dca3ea9be64899ab3f4812f016"
    )

    static let expectedRLPEncoding = "0x28f9027e1f8505d21dba00830dbba0808094d91aec35bea25d379e49cfe2dff5f5775cdac1a3b9020e60806040526000805534801561001457600080fd5b506101ea806100246000396000f30060806040526004361061006d576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff16806306661abd1461007257806342cbb15c1461009d578063767800de146100c8578063b22636271461011f578063d14e62b814610150575b600080fd5b34801561007e57600080fd5b5061008761017d565b6040518082815260200191505060405180910390f35b3480156100a957600080fd5b506100b2610183565b6040518082815260200191505060405180910390f35b3480156100d457600080fd5b506100dd61018b565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b34801561012b57600080fd5b5061014e60048036038101908080356000191690602001909291905050506101b1565b005b34801561015c57600080fd5b5061017b600480360381019080803590602001909291905050506101b4565b005b60005481565b600043905090565b600160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b50565b80600081905550505600a165627a7a7230582053c65686a3571c517e2cf4f741d842e5ee6aa665c96ce70f46f9a594794f11eb00298080f847f845820fe9a0018a9f680a74e275f1f83a5c2c45e1313c52432df4595e944240b1511a4f4ba7a02d762c3417f91b81db4907db832cb28cc64df7dca3ea9be64899ab3f4812f016"
    static let expectedTransactionHash = "0x523417d946221c4d12b58519580edca43662577df7e107f5ff92f115d4b3d210"
    static let expectedRLPEncodingForSigning = "0xf90241b90239f90236281f8505d21dba00830dbba0808094d91aec35bea25d379e49cfe2dff5f5775cdac1a3b9020e60806040526000805534801561001457600080fd5b506101ea806100246000396000f30060806040526004361061006d576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff16806306661abd1461007257806342cbb15c1461009d578063767800de146100c8578063b22636271461011f578063d14e62b814610150575b600080fd5b34801561007e57600080fd5b5061008761017d565b6040518082815260200191505060405180910390f35b3480156100a957600080fd5b506100b2610183565b6040518082815260200191505060405180910390f35b3480156100d457600080fd5b506100dd61018b565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b34801561012b57600080fd5b5061014e60048036038101908080356000191690602001909291905050506101b1565b005b34801561015c57600080fd5b5061017b600480360381019080803590602001909291905050506101b4565b005b60005481565b600043905090565b600160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b50565b80600081905550505600a165627a7a7230582053c65686a3571c517e2cf4f741d842e5ee6aa665c96ce70f46f9a594794f11eb002980808207e38080"

    public static func generateRoleBaseKeyring(_ numArr: [Int], _ address: String) throws -> AbstractKeyring {
        let keyArr = numArr.map {
            (0..<$0).map { _ in
                PrivateKey.generate("entropy").privateKey
            }
        }
        
        return try KeyringFactory.createWithRoleBasedKey(address, keyArr)
    }
}

class SmartContractDeployTest_createInstanceBuilder: XCTestCase {
    let from = SmartContractDeployTest.from
    let gas = SmartContractDeployTest.gas
    let nonce = SmartContractDeployTest.nonce
    let gasPrice = SmartContractDeployTest.gasPrice
    let chainID = SmartContractDeployTest.chainID
    let value = SmartContractDeployTest.value
    let input = SmartContractDeployTest.input
    let humanReadable = SmartContractDeployTest.humanReadable
    let codeFormat = SmartContractDeployTest.codeFormat
    let signatureData = SmartContractDeployTest.signatureData
    
    public func test_BuilderTest() throws {
        let txObj = try SmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
            .setSignatures(signatureData)
            .build()
        
        XCTAssertNotNil(txObj)
    }
    
    public func test_BuilderWithRPCTest() throws {
        let txObj = try SmartContractDeploy.Builder()
            .setKlaytnCall(SmartContractDeployTest.caver.rpc.klay)
            .setGas(gas)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
            .build()
        
        try txObj.fillTransaction()
        
        XCTAssertFalse(txObj.nonce.isEmpty)
        XCTAssertFalse(txObj.gasPrice.isEmpty)
        XCTAssertFalse(txObj.chainId.isEmpty)
    }
    
    public func test_BuilderTestWithBigInteger() throws {
        let txObj = try SmartContractDeploy.Builder()
            .setNonce(BigInt(hex: nonce)!)
            .setGas(BigInt(hex: gas)!)
            .setGasPrice(BigInt(hex: gasPrice)!)
            .setChainId(BigInt(hex: chainID)!)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
            .build()
        
        XCTAssertNotNil(txObj)
        
        XCTAssertEqual(gas, txObj.gas)
        XCTAssertEqual(gasPrice, txObj.gasPrice)
        XCTAssertEqual(chainID, txObj.chainId)
    }
    
    public func test_throwException_invalidFrom() throws {
        let from = "invalid Address"
        XCTAssertThrowsError(try SmartContractDeploy.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setInput(input)
                                .setSignatures(signatureData)
                                .setCodeFormat(codeFormat)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(from)"))
        }
    }
    
    public func test_throwException_missingFrom() throws {
        let from = ""
        XCTAssertThrowsError(try SmartContractDeploy.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setInput(input)
                                .setHumanReadable(humanReadable)
                                .setCodeFormat(codeFormat)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("from is missing."))
        }
    }
    
    public func test_throwException_invalidValue() throws {
        let value = "invalid value"
        XCTAssertThrowsError(try SmartContractDeploy.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setInput(input)
                                .setSignatures(signatureData)
                                .setCodeFormat(codeFormat)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid value : \(value)"))
        }
    }
    
    public func test_throwException_missingValue() throws {
        let value = ""
        XCTAssertThrowsError(try SmartContractDeploy.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setInput(input)
                                .setHumanReadable(humanReadable)
                                .setCodeFormat(codeFormat)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("value is missing."))
        }
    }
    
    public func test_throwException_invalidGas() throws {
        let gas = "invalid gas"
        XCTAssertThrowsError(try SmartContractDeploy.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setInput(input)
                                .setHumanReadable(humanReadable)
                                .setCodeFormat(codeFormat)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid gas. : \(gas)"))
        }
    }
    
    public func test_throwException_missingGas() throws {
        let gas = ""
        XCTAssertThrowsError(try SmartContractDeploy.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setInput(input)
                                .setHumanReadable(humanReadable)
                                .setCodeFormat(codeFormat)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("gas is missing."))
        }
    }
    
    public func test_throwException_invalidInput() throws {
        let input = "invalid input"
        XCTAssertThrowsError(try SmartContractDeploy.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setInput(input)
                                .setHumanReadable(humanReadable)
                                .setCodeFormat(codeFormat)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid input. : \(input)"))
        }
    }
    
    public func test_throwException_missingInput() throws {
        let input = ""
        XCTAssertThrowsError(try SmartContractDeploy.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setInput(input)
                                .setHumanReadable(humanReadable)
                                .setCodeFormat(codeFormat)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("input is missing."))
        }
    }
    
    public func test_throwException_invalidTo() throws {
        let to = "invalid input"
        XCTAssertThrowsError(try SmartContractDeploy.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setValue(value)
                                .setTo(to)
                                .setFrom(from)
                                .setInput(input)
                                .setHumanReadable(humanReadable)
                                .setCodeFormat(codeFormat)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("'to' field must be nil('0x') : \(to)"))
        }
    }
    
    public func test_throwException_invalidHumanReadable() throws {
        let humanReadable = true
        XCTAssertThrowsError(try SmartContractDeploy.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setInput(input)
                                .setHumanReadable(humanReadable)
                                .setCodeFormat(codeFormat)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("HumanReadable attribute must set false"))
        }
    }
    
    public func test_throwException_invalidCodeFormat() throws {
        let codeFormat = "1"
        XCTAssertThrowsError(try SmartContractDeploy.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setInput(input)
                                .setHumanReadable(humanReadable)
                                .setCodeFormat(codeFormat)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("CodeFormat attribute only support EVM(0)"))
        }
    }
    
    public func test_throwException_missingCodeFormat() throws {
        let codeFormat = ""
        XCTAssertThrowsError(try SmartContractDeploy.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setValue(value)
                                .setFrom(from)
                                .setInput(input)
                                .setHumanReadable(humanReadable)
                                .setCodeFormat(codeFormat)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("codeFormat is missing"))
        }
    }
}

class SmartContractDeployTest_createInstance: XCTestCase {
    let from = SmartContractDeployTest.from
    let gas = SmartContractDeployTest.gas
    let nonce = SmartContractDeployTest.nonce
    let gasPrice = SmartContractDeployTest.gasPrice
    let chainID = SmartContractDeployTest.chainID
    let value = SmartContractDeployTest.value
    let input = SmartContractDeployTest.input
    let humanReadable = SmartContractDeployTest.humanReadable
    let codeFormat = SmartContractDeployTest.codeFormat
    let signatureData = SmartContractDeployTest.signatureData
    
    public func test_createInstance() throws {
        let txObj = try SmartContractDeploy(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            nil,
            value,
            input,
            humanReadable,
            codeFormat
        )
        
        XCTAssertNotNil(txObj)
    }
    
    public func test_throwException_invalidFrom() throws {
        let from = "invalid Address"
        XCTAssertThrowsError(try SmartContractDeploy(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            nil,
            value,
            input,
            humanReadable,
            codeFormat
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(from)"))
        }
    }
    
    public func test_throwException_missingFrom() throws {
        let from = ""
        XCTAssertThrowsError(try SmartContractDeploy(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            nil,
            value,
            input,
            humanReadable,
            codeFormat
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("from is missing."))
        }
    }
    
    public func test_throwException_invalidValue() throws {
        let value = "invalid value"
        XCTAssertThrowsError(try SmartContractDeploy(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            nil,
            value,
            input,
            humanReadable,
            codeFormat
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid value : \(value)"))
        }
    }
    
    public func test_throwException_missingValue() throws {
        let value = ""
        XCTAssertThrowsError(try SmartContractDeploy(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            nil,
            value,
            input,
            humanReadable,
            codeFormat
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("value is missing."))
        }
    }
    
    public func test_throwException_invalidGas() throws {
        let gas = "invalid gas"
        XCTAssertThrowsError(try SmartContractDeploy(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            nil,
            value,
            input,
            humanReadable,
            codeFormat
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid gas. : \(gas)"))
        }
    }
    
    public func test_throwException_missingGas() throws {
        let gas = ""
        XCTAssertThrowsError(try SmartContractDeploy(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            nil,
            value,
            input,
            humanReadable,
            codeFormat
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("gas is missing."))
        }
    }
    
    public func test_throwException_invalidInput() throws {
        let input = "invalid input"
        XCTAssertThrowsError(try SmartContractDeploy(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            nil,
            value,
            input,
            humanReadable,
            codeFormat
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid input. : \(input)"))
        }
    }
    
    public func test_throwException_missingInput() throws {
        let input = ""
        XCTAssertThrowsError(try SmartContractDeploy(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            nil,
            value,
            input,
            humanReadable,
            codeFormat
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("input is missing."))
        }
    }
    
    public func test_throwException_invalidTo() throws {
        let to = "invalid address"
        XCTAssertThrowsError(try SmartContractDeploy(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            to,
            value,
            input,
            humanReadable,
            codeFormat
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("'to' field must be nil('0x') : \(to)"))
        }
    }
    
    public func test_throwException_invalidHumanReadable() throws {
        let humanReadable = true
        XCTAssertThrowsError(try SmartContractDeploy(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            nil,
            value,
            input,
            humanReadable,
            codeFormat
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("HumanReadable attribute must set false"))
        }
    }
    
    public func test_throwException_invalidCodeFormat() throws {
        let codeFormat = "1"
        XCTAssertThrowsError(try SmartContractDeploy(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            nil,
            value,
            input,
            humanReadable,
            codeFormat
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("CodeFormat attribute only support EVM(0)"))
        }
    }
    
    public func test_throwException_missingCodeFormat() throws {
        let codeFormat = ""
        XCTAssertThrowsError(try SmartContractDeploy(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            nil,
            value,
            input,
            humanReadable,
            codeFormat
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("codeFormat is missing"))
        }
    }
}

class SmartContractDeployTest_getRLPEncodingTest: XCTestCase {
    let from = SmartContractDeployTest.from
    let gas = SmartContractDeployTest.gas
    let nonce = SmartContractDeployTest.nonce
    let gasPrice = SmartContractDeployTest.gasPrice
    let chainID = SmartContractDeployTest.chainID
    let value = SmartContractDeployTest.value
    let input = SmartContractDeployTest.input
    let humanReadable = SmartContractDeployTest.humanReadable
    let codeFormat = SmartContractDeployTest.codeFormat
    let signatureData = SmartContractDeployTest.signatureData
    
    let expectedRLPEncoding = SmartContractDeployTest.expectedRLPEncoding
        
    public func test_getRLPEncoding() throws {
        let txObj = try SmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
            .setSignatures(signatureData)
            .build()
        
        XCTAssertEqual(expectedRLPEncoding, try txObj.getRLPEncoding())
    }
    
    public func test_throwException_NoNonce() throws {
        let txObj = try SmartContractDeploy.Builder()
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
            .setSignatures(signatureData)
            .build()
        
        XCTAssertThrowsError(try txObj.getRLPEncoding()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NoGasPrice() throws {
        let txObj = try SmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
            .setSignatures(signatureData)
            .build()
        
        XCTAssertThrowsError(try txObj.getRLPEncoding()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class SmartContractDeployTest_signWithKeyTest: XCTestCase {
    var mTxObj: SmartContractDeploy?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = SmartContractDeployTest.privateKey
    
    let from = "0xa94f5374Fce5edBC8E2a8697C15331677e6EbF0B"
    let gas = SmartContractDeployTest.gas
    let nonce = SmartContractDeployTest.nonce
    let gasPrice = SmartContractDeployTest.gasPrice
    let chainID = SmartContractDeployTest.chainID
    let value = SmartContractDeployTest.value
    let input = SmartContractDeployTest.input
    let humanReadable = SmartContractDeployTest.humanReadable
    let codeFormat = SmartContractDeployTest.codeFormat
    let signatureData = SmartContractDeployTest.signatureData
    
    let expectedRLPEncoding = "0x28f9027e1f8505d21dba00830dbba0808094a94f5374fce5edbc8e2a8697c15331677e6ebf0bb9020e60806040526000805534801561001457600080fd5b506101ea806100246000396000f30060806040526004361061006d576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff16806306661abd1461007257806342cbb15c1461009d578063767800de146100c8578063b22636271461011f578063d14e62b814610150575b600080fd5b34801561007e57600080fd5b5061008761017d565b6040518082815260200191505060405180910390f35b3480156100a957600080fd5b506100b2610183565b6040518082815260200191505060405180910390f35b3480156100d457600080fd5b506100dd61018b565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b34801561012b57600080fd5b5061014e60048036038101908080356000191690602001909291905050506101b1565b005b34801561015c57600080fd5b5061017b600480360381019080803590602001909291905050506101b4565b005b60005481565b600043905090565b600160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b50565b80600081905550505600a165627a7a7230582053c65686a3571c517e2cf4f741d842e5ee6aa665c96ce70f46f9a594794f11eb00298080f847f845820fe9a03a6324d855fa9326e52fc09420eb3194334d81b68e4c94847547e1ee681506f8a04eacfc4c04497cdcd79a28c8165ef824686c399ea6453b7e878d69ab6fcece5b"
        
    override func setUpWithError() throws {
        mTxObj = try SmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setHumanReadable(false)
            .setCodeFormat(codeFormat)
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

class SmartContractDeployTest_signWithKeysTest: XCTestCase {
    var mTxObj: SmartContractDeploy?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = SmartContractDeployTest.privateKey
    
    let from = "0xa94f5374Fce5edBC8E2a8697C15331677e6EbF0B"
    let gas = SmartContractDeployTest.gas
    let nonce = SmartContractDeployTest.nonce
    let gasPrice = SmartContractDeployTest.gasPrice
    let chainID = SmartContractDeployTest.chainID
    let value = SmartContractDeployTest.value
    let input = SmartContractDeployTest.input
    let humanReadable = SmartContractDeployTest.humanReadable
    let codeFormat = SmartContractDeployTest.codeFormat
    let signatureData = SmartContractDeployTest.signatureData
    
    let expectedRLPEncoding = "0x28f9027e1f8505d21dba00830dbba0808094a94f5374fce5edbc8e2a8697c15331677e6ebf0bb9020e60806040526000805534801561001457600080fd5b506101ea806100246000396000f30060806040526004361061006d576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff16806306661abd1461007257806342cbb15c1461009d578063767800de146100c8578063b22636271461011f578063d14e62b814610150575b600080fd5b34801561007e57600080fd5b5061008761017d565b6040518082815260200191505060405180910390f35b3480156100a957600080fd5b506100b2610183565b6040518082815260200191505060405180910390f35b3480156100d457600080fd5b506100dd61018b565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b34801561012b57600080fd5b5061014e60048036038101908080356000191690602001909291905050506101b1565b005b34801561015c57600080fd5b5061017b600480360381019080803590602001909291905050506101b4565b005b60005481565b600043905090565b600160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b50565b80600081905550505600a165627a7a7230582053c65686a3571c517e2cf4f741d842e5ee6aa665c96ce70f46f9a594794f11eb00298080f847f845820fe9a03a6324d855fa9326e52fc09420eb3194334d81b68e4c94847547e1ee681506f8a04eacfc4c04497cdcd79a28c8165ef824686c399ea6453b7e878d69ab6fcece5b"
        
    override func setUpWithError() throws {
        mTxObj = try SmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setHumanReadable(false)
            .setCodeFormat(codeFormat)
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

class SmartContractDeployTest_appendSignaturesTest: XCTestCase {
    var mTxObj: SmartContractDeploy?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = SmartContractDeployTest.privateKey
    let from = SmartContractDeployTest.from
    let gas = SmartContractDeployTest.gas
    let nonce = SmartContractDeployTest.nonce
    let gasPrice = SmartContractDeployTest.gasPrice
    let chainID = SmartContractDeployTest.chainID
    let value = SmartContractDeployTest.value
    let input = SmartContractDeployTest.input
    let humanReadable = SmartContractDeployTest.humanReadable
    let codeFormat = SmartContractDeployTest.codeFormat
    let signatureData = SmartContractDeployTest.signatureData
    let expectedRLPEncoding = SmartContractDeployTest.expectedRLPEncoding
    
    override func setUpWithError() throws {
        mTxObj = try SmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setHumanReadable(false)
            .setCodeFormat(codeFormat)
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
        mTxObj = try SmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setHumanReadable(false)
            .setCodeFormat(codeFormat)
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
        
        mTxObj = try SmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setHumanReadable(false)
            .setCodeFormat(codeFormat)
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
        
        mTxObj = try SmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setHumanReadable(false)
            .setCodeFormat(codeFormat)
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

class SmartContractDeployTest_combineSignatureTest: XCTestCase {
    var mTxObj: SmartContractDeploy?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = SmartContractDeployTest.privateKey
    let from = "0x47a4caa81fe2ed8cc834aafe5b1d7ee3ddedecfa"
    let gas = BigInt(900000)
    let nonce = "0x1"
    let gasPrice = "0x5d21dba00"
    let chainID = SmartContractDeployTest.chainID
    let value = BigInt(0)
    let input = SmartContractDeployTest.input
    let humanReadable = SmartContractDeployTest.humanReadable
    let codeFormat = SmartContractDeployTest.codeFormat
    let signatureData = SmartContractDeployTest.signatureData
    let expectedRLPEncoding = SmartContractDeployTest.expectedRLPEncoding
    
    override func setUpWithError() throws {
        mTxObj = try SmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setHumanReadable(false)
            .setCodeFormat(codeFormat)
            .build()
    }
    
    public func test_combineSignature() throws {
        let expectedRLPEncoded = "0x28f9027e018505d21dba00830dbba080809447a4caa81fe2ed8cc834aafe5b1d7ee3ddedecfab9020e60806040526000805534801561001457600080fd5b506101ea806100246000396000f30060806040526004361061006d576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff16806306661abd1461007257806342cbb15c1461009d578063767800de146100c8578063b22636271461011f578063d14e62b814610150575b600080fd5b34801561007e57600080fd5b5061008761017d565b6040518082815260200191505060405180910390f35b3480156100a957600080fd5b506100b2610183565b6040518082815260200191505060405180910390f35b3480156100d457600080fd5b506100dd61018b565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b34801561012b57600080fd5b5061014e60048036038101908080356000191690602001909291905050506101b1565b005b34801561015c57600080fd5b5061017b600480360381019080803590602001909291905050506101b4565b005b60005481565b600043905090565b600160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b50565b80600081905550505600a165627a7a7230582053c65686a3571c517e2cf4f741d842e5ee6aa665c96ce70f46f9a594794f11eb00298080f847f845820fe9a04fbefaf9da3be278403c0b69861747a4f2f530958c5f3da0b7fed8898aa02a9da010b441518b74b9cb15d86403a4c59a562a4669bc9c878d77276f0205304c3d85"
        
        let expectedSignature = SignatureData(
            "0x0fe9",
            "0x4fbefaf9da3be278403c0b69861747a4f2f530958c5f3da0b7fed8898aa02a9d",
            "0x10b441518b74b9cb15d86403a4c59a562a4669bc9c878d77276f0205304c3d85"
        )
        
        let rlpEncoded = "0x28f9027e018505d21dba00830dbba080809447a4caa81fe2ed8cc834aafe5b1d7ee3ddedecfab9020e60806040526000805534801561001457600080fd5b506101ea806100246000396000f30060806040526004361061006d576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff16806306661abd1461007257806342cbb15c1461009d578063767800de146100c8578063b22636271461011f578063d14e62b814610150575b600080fd5b34801561007e57600080fd5b5061008761017d565b6040518082815260200191505060405180910390f35b3480156100a957600080fd5b506100b2610183565b6040518082815260200191505060405180910390f35b3480156100d457600080fd5b506100dd61018b565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b34801561012b57600080fd5b5061014e60048036038101908080356000191690602001909291905050506101b1565b005b34801561015c57600080fd5b5061017b600480360381019080803590602001909291905050506101b4565b005b60005481565b600043905090565b600160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b50565b80600081905550505600a165627a7a7230582053c65686a3571c517e2cf4f741d842e5ee6aa665c96ce70f46f9a594794f11eb00298080f847f845820fe9a04fbefaf9da3be278403c0b69861747a4f2f530958c5f3da0b7fed8898aa02a9da010b441518b74b9cb15d86403a4c59a562a4669bc9c878d77276f0205304c3d85"
        
        let combined = try mTxObj!.combineSignedRawTransactions([rlpEncoded])
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature, mTxObj?.signatures[0])
    }
    
    public func test_combine_multipleSignature() throws {
        let expectedRLPEncoded = "0x28f9030c018505d21dba00830dbba080809447a4caa81fe2ed8cc834aafe5b1d7ee3ddedecfab9020e60806040526000805534801561001457600080fd5b506101ea806100246000396000f30060806040526004361061006d576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff16806306661abd1461007257806342cbb15c1461009d578063767800de146100c8578063b22636271461011f578063d14e62b814610150575b600080fd5b34801561007e57600080fd5b5061008761017d565b6040518082815260200191505060405180910390f35b3480156100a957600080fd5b506100b2610183565b6040518082815260200191505060405180910390f35b3480156100d457600080fd5b506100dd61018b565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b34801561012b57600080fd5b5061014e60048036038101908080356000191690602001909291905050506101b1565b005b34801561015c57600080fd5b5061017b600480360381019080803590602001909291905050506101b4565b005b60005481565b600043905090565b600160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b50565b80600081905550505600a165627a7a7230582053c65686a3571c517e2cf4f741d842e5ee6aa665c96ce70f46f9a594794f11eb00298080f8d5f845820fe9a04fbefaf9da3be278403c0b69861747a4f2f530958c5f3da0b7fed8898aa02a9da010b441518b74b9cb15d86403a4c59a562a4669bc9c878d77276f0205304c3d85f845820fe9a06f59d699a5dd22a653b0ed1e39cbfc52ee468607eec95b195f302680ed7f9815a03b2f3f2a7a9482edfbcc9ee8e003e284b6c4a7ecbc8d361cc486562d4bdda389f845820feaa04a76af831891d1050d1a0c8e7656b4ab1952ef6a1059bff994edb29a6936a909a06affc6457e9c553c5efb138a7a56dbcbed681a5bae2dceff02848341a61ab9c4"
        
        let expectedSignature = [
            SignatureData(
                "0x0fe9",
                "0x4fbefaf9da3be278403c0b69861747a4f2f530958c5f3da0b7fed8898aa02a9d",
                "0x10b441518b74b9cb15d86403a4c59a562a4669bc9c878d77276f0205304c3d85"
            ),
            SignatureData(
                "0x0fe9",
                "0x6f59d699a5dd22a653b0ed1e39cbfc52ee468607eec95b195f302680ed7f9815",
                "0x3b2f3f2a7a9482edfbcc9ee8e003e284b6c4a7ecbc8d361cc486562d4bdda389"
            ),
            SignatureData(
                "0x0fea",
                "0x4a76af831891d1050d1a0c8e7656b4ab1952ef6a1059bff994edb29a6936a909",
                "0x6affc6457e9c553c5efb138a7a56dbcbed681a5bae2dceff02848341a61ab9c4"
            )
        ]
        
        let signatureData = SignatureData(
            "0x0fe9",
            "0x4fbefaf9da3be278403c0b69861747a4f2f530958c5f3da0b7fed8898aa02a9d",
            "0x10b441518b74b9cb15d86403a4c59a562a4669bc9c878d77276f0205304c3d85"
        )
        
        mTxObj = try SmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setHumanReadable(false)
            .setCodeFormat(codeFormat)
            .setSignatures(signatureData)
            .build()
        
        let rlpEncodedString = [
            "0x28f9027e018505d21dba00830dbba080809447a4caa81fe2ed8cc834aafe5b1d7ee3ddedecfab9020e60806040526000805534801561001457600080fd5b506101ea806100246000396000f30060806040526004361061006d576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff16806306661abd1461007257806342cbb15c1461009d578063767800de146100c8578063b22636271461011f578063d14e62b814610150575b600080fd5b34801561007e57600080fd5b5061008761017d565b6040518082815260200191505060405180910390f35b3480156100a957600080fd5b506100b2610183565b6040518082815260200191505060405180910390f35b3480156100d457600080fd5b506100dd61018b565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b34801561012b57600080fd5b5061014e60048036038101908080356000191690602001909291905050506101b1565b005b34801561015c57600080fd5b5061017b600480360381019080803590602001909291905050506101b4565b005b60005481565b600043905090565b600160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b50565b80600081905550505600a165627a7a7230582053c65686a3571c517e2cf4f741d842e5ee6aa665c96ce70f46f9a594794f11eb00298080f847f845820fe9a06f59d699a5dd22a653b0ed1e39cbfc52ee468607eec95b195f302680ed7f9815a03b2f3f2a7a9482edfbcc9ee8e003e284b6c4a7ecbc8d361cc486562d4bdda389",
            "0x28f9027e018505d21dba00830dbba080809447a4caa81fe2ed8cc834aafe5b1d7ee3ddedecfab9020e60806040526000805534801561001457600080fd5b506101ea806100246000396000f30060806040526004361061006d576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff16806306661abd1461007257806342cbb15c1461009d578063767800de146100c8578063b22636271461011f578063d14e62b814610150575b600080fd5b34801561007e57600080fd5b5061008761017d565b6040518082815260200191505060405180910390f35b3480156100a957600080fd5b506100b2610183565b6040518082815260200191505060405180910390f35b3480156100d457600080fd5b506100dd61018b565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b34801561012b57600080fd5b5061014e60048036038101908080356000191690602001909291905050506101b1565b005b34801561015c57600080fd5b5061017b600480360381019080803590602001909291905050506101b4565b005b60005481565b600043905090565b600160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b50565b80600081905550505600a165627a7a7230582053c65686a3571c517e2cf4f741d842e5ee6aa665c96ce70f46f9a594794f11eb00298080f847f845820feaa04a76af831891d1050d1a0c8e7656b4ab1952ef6a1059bff994edb29a6936a909a06affc6457e9c553c5efb138a7a56dbcbed681a5bae2dceff02848341a61ab9c4"
        ]
        
        let combined = try mTxObj!.combineSignedRawTransactions(rlpEncodedString)
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature[0], mTxObj?.signatures[0])
        XCTAssertEqual(expectedSignature[1], mTxObj?.signatures[1])
        XCTAssertEqual(expectedSignature[2], mTxObj?.signatures[2])
    }
    
    public func test_throwException_differentField() throws {
        let value = BigInt(1000)
        mTxObj = try SmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setHumanReadable(false)
            .setCodeFormat(codeFormat)
            .build()
        
        let rlpEncoded = "0x28f9027e018505d21dba00830dbba080809447a4caa81fe2ed8cc834aafe5b1d7ee3ddedecfab9020e60806040526000805534801561001457600080fd5b506101ea806100246000396000f30060806040526004361061006d576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff16806306661abd1461007257806342cbb15c1461009d578063767800de146100c8578063b22636271461011f578063d14e62b814610150575b600080fd5b34801561007e57600080fd5b5061008761017d565b6040518082815260200191505060405180910390f35b3480156100a957600080fd5b506100b2610183565b6040518082815260200191505060405180910390f35b3480156100d457600080fd5b506100dd61018b565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b34801561012b57600080fd5b5061014e60048036038101908080356000191690602001909291905050506101b1565b005b34801561015c57600080fd5b5061017b600480360381019080803590602001909291905050506101b4565b005b60005481565b600043905090565b600160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b50565b80600081905550505600a165627a7a7230582053c65686a3571c517e2cf4f741d842e5ee6aa665c96ce70f46f9a594794f11eb00298080f847f845820fe9a06f59d699a5dd22a653b0ed1e39cbfc52ee468607eec95b195f302680ed7f9815a03b2f3f2a7a9482edfbcc9ee8e003e284b6c4a7ecbc8d361cc486562d4bdda389"
        
        XCTAssertThrowsError(try mTxObj!.combineSignedRawTransactions([rlpEncoded])) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("Transactions containing different information cannot be combined."))
        }
    }
}

class SmartContractDeployTest_getRawTransactionTest: XCTestCase {
    var mTxObj: SmartContractDeploy?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = SmartContractDeployTest.privateKey
    let from = SmartContractDeployTest.from
    let gas = SmartContractDeployTest.gas
    let nonce = SmartContractDeployTest.nonce
    let gasPrice = SmartContractDeployTest.gasPrice
    let chainID = SmartContractDeployTest.chainID
    let value = SmartContractDeployTest.value
    let input = SmartContractDeployTest.input
    let humanReadable = SmartContractDeployTest.humanReadable
    let codeFormat = SmartContractDeployTest.codeFormat
    let signatureData = SmartContractDeployTest.signatureData
    let expectedRLPEncoding = SmartContractDeployTest.expectedRLPEncoding
    
    override func setUpWithError() throws {
        mTxObj = try SmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
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

class SmartContractDeployTest_getTransactionHashTest: XCTestCase {
    var mTxObj: SmartContractDeploy?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = SmartContractDeployTest.privateKey
    let from = SmartContractDeployTest.from
    let gas = SmartContractDeployTest.gas
    let nonce = SmartContractDeployTest.nonce
    let gasPrice = SmartContractDeployTest.gasPrice
    let chainID = SmartContractDeployTest.chainID
    let value = SmartContractDeployTest.value
    let input = SmartContractDeployTest.input
    let humanReadable = SmartContractDeployTest.humanReadable
    let codeFormat = SmartContractDeployTest.codeFormat
    let signatureData = SmartContractDeployTest.signatureData
    let expectedRLPEncoding = SmartContractDeployTest.expectedRLPEncoding
    let expectedTransactionHash = SmartContractDeployTest.expectedTransactionHash
    
    override func setUpWithError() throws {
        mTxObj = try SmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
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
        
        mTxObj = try SmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
            .setSignatures(signatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getTransactionHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_gasPrice() throws {
        let gasPrice = ""
        
        mTxObj = try SmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
            .setSignatures(signatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getTransactionHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class SmartContractDeployTest_getSenderTxHashTest: XCTestCase {
    var mTxObj: SmartContractDeploy?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = SmartContractDeployTest.privateKey
    let from = SmartContractDeployTest.from
    let gas = SmartContractDeployTest.gas
    let nonce = SmartContractDeployTest.nonce
    let gasPrice = SmartContractDeployTest.gasPrice
    let chainID = SmartContractDeployTest.chainID
    let value = SmartContractDeployTest.value
    let input = SmartContractDeployTest.input
    let humanReadable = SmartContractDeployTest.humanReadable
    let codeFormat = SmartContractDeployTest.codeFormat
    let signatureData = SmartContractDeployTest.signatureData
    let expectedRLPEncoding = SmartContractDeployTest.expectedRLPEncoding
    let expectedTransactionHash = SmartContractDeployTest.expectedTransactionHash
    
    override func setUpWithError() throws {
        mTxObj = try SmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
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
        
        mTxObj = try SmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
            .setSignatures(signatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getSenderTxHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_gasPrice() throws {
        let gasPrice = ""
        
        mTxObj = try SmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
            .setSignatures(signatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getSenderTxHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class SmartContractDeployTest_getRLPEncodingForSignatureTest: XCTestCase {
    var mTxObj: SmartContractDeploy?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = SmartContractDeployTest.privateKey
    let from = SmartContractDeployTest.from
    let gas = SmartContractDeployTest.gas
    let nonce = SmartContractDeployTest.nonce
    let gasPrice = SmartContractDeployTest.gasPrice
    let chainID = SmartContractDeployTest.chainID
    let value = SmartContractDeployTest.value
    let input = SmartContractDeployTest.input
    let humanReadable = SmartContractDeployTest.humanReadable
    let codeFormat = SmartContractDeployTest.codeFormat
    let signatureData = SmartContractDeployTest.signatureData
    let expectedRLPEncoding = SmartContractDeployTest.expectedRLPEncoding
    let expectedTransactionHash = SmartContractDeployTest.expectedTransactionHash
    let expectedRLPEncodingForSigning = SmartContractDeployTest.expectedRLPEncodingForSigning
    
    override func setUpWithError() throws {
        mTxObj = try SmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
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
        
        mTxObj = try SmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
            .setSignatures(signatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_gasPrice() throws {
        let gasPrice = ""
        
        mTxObj = try SmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
            .setSignatures(signatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_chainID() throws {
        let chainID = ""
        
        mTxObj = try SmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setValue(value)
            .setFrom(from)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
            .setSignatures(signatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("chainId is undefined. Define chainId in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}
