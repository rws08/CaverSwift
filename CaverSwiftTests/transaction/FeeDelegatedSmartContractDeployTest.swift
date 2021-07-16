//
//  FeeDelegatedSmartContractDeployTest.swift
//  CaverSwiftTests
//
//  Created by won on 2021/07/16.
//

import XCTest
@testable import CaverSwift

class FeeDelegatedSmartContractDeployTest: XCTestCase {
    static let caver = Caver(Caver.DEFAULT_URL)
    
    static let senderPrivateKey = "0x45a915e4d060149eb4365960e6a7a45f334393093061116b197e3240065ff2d8"
    static let feePayerPrivateKey = "0xb9d5558443585bca6f225b935950e3f6e69f9da8a5809a83f51c3365dff53936"
    static let from = "0x8061145252c8f2b4f110aed096435ae6ed7d5a95"
    static let account = Account.createWithAccountKeyLegacy(from)
    static let to = "0x"
    static let gas = "0xdbba0"
    static let gasPrice = "0x5d21dba00"
    static let nonce = "0x0"
    static let chainID = "0x7e3"
    static let value = "0x00"
    static let input = "0x608060405234801561001057600080fd5b506101de806100206000396000f3006080604052600436106100615763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416631a39d8ef81146100805780636353586b146100a757806370a08231146100ca578063fd6b7ef8146100f8575b3360009081526001602052604081208054349081019091558154019055005b34801561008c57600080fd5b5061009561010d565b60408051918252519081900360200190f35b6100c873ffffffffffffffffffffffffffffffffffffffff60043516610113565b005b3480156100d657600080fd5b5061009573ffffffffffffffffffffffffffffffffffffffff60043516610147565b34801561010457600080fd5b506100c8610159565b60005481565b73ffffffffffffffffffffffffffffffffffffffff1660009081526001602052604081208054349081019091558154019055565b60016020526000908152604090205481565b336000908152600160205260408120805490829055908111156101af57604051339082156108fc029083906000818181858888f193505050501561019c576101af565b3360009081526001602052604090208190555b505600a165627a7a72305820627ca46bb09478a015762806cc00c431230501118c7c26c30ac58c4e09e51c4f0029"
    static let humanReadable = false
    static let codeFormat = CodeFormat.EVM.hexa

    static let senderSignatureData = SignatureData(
        "0x0fe9",
        "0x7abfd0f0cfb9a9c38c6e3e1a4eeb15f43aeb4b4f6dee7c3f37c07e417af89d9b",
        "0x3f1e54a512c906d2e57a611b25ce4739d12928e199c3e89792b82f577f0da9ad"
    )
    static let feePayer = "0x2c8eb96e7060ab864d94e91ab16f214dc6647628"
    static let feePayerSignatureData = SignatureData(
        "0x0fe9",
        "0x192e3b6457f13c6ef557bd11074702d5062dd463473c483278c57f651d5b712b",
        "0x3ff8638b7cc7ed86c793cb5ffe0e8a064fc94946c3aab624bb7704c62e81ec2d"
    )

    static let expectedRLPEncoding = "0x29f902cc808505d21dba00830dbba08080948061145252c8f2b4f110aed096435ae6ed7d5a95b901fe608060405234801561001057600080fd5b506101de806100206000396000f3006080604052600436106100615763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416631a39d8ef81146100805780636353586b146100a757806370a08231146100ca578063fd6b7ef8146100f8575b3360009081526001602052604081208054349081019091558154019055005b34801561008c57600080fd5b5061009561010d565b60408051918252519081900360200190f35b6100c873ffffffffffffffffffffffffffffffffffffffff60043516610113565b005b3480156100d657600080fd5b5061009573ffffffffffffffffffffffffffffffffffffffff60043516610147565b34801561010457600080fd5b506100c8610159565b60005481565b73ffffffffffffffffffffffffffffffffffffffff1660009081526001602052604081208054349081019091558154019055565b60016020526000908152604090205481565b336000908152600160205260408120805490829055908111156101af57604051339082156108fc029083906000818181858888f193505050501561019c576101af565b3360009081526001602052604090208190555b505600a165627a7a72305820627ca46bb09478a015762806cc00c431230501118c7c26c30ac58c4e09e51c4f00298080f847f845820fe9a07abfd0f0cfb9a9c38c6e3e1a4eeb15f43aeb4b4f6dee7c3f37c07e417af89d9ba03f1e54a512c906d2e57a611b25ce4739d12928e199c3e89792b82f577f0da9ad942c8eb96e7060ab864d94e91ab16f214dc6647628f847f845820fe9a0192e3b6457f13c6ef557bd11074702d5062dd463473c483278c57f651d5b712ba03ff8638b7cc7ed86c793cb5ffe0e8a064fc94946c3aab624bb7704c62e81ec2d"
    static let expectedTransactionHash = "0x8dc83759a9c9b226493cb9f7b81a33e0b6b4643f2e82a02fbac784fbe53f9cd9"
    static let expectedSenderTransactionHash = "0xe189c8ead022fcddb97a8489bb1ee6362368579c65da7404db6b4e704b037ed7"
    static let expectedRLPEncodingForFeePayerSigning = "0xf90246b90229f9022629808505d21dba00830dbba08080948061145252c8f2b4f110aed096435ae6ed7d5a95b901fe608060405234801561001057600080fd5b506101de806100206000396000f3006080604052600436106100615763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416631a39d8ef81146100805780636353586b146100a757806370a08231146100ca578063fd6b7ef8146100f8575b3360009081526001602052604081208054349081019091558154019055005b34801561008c57600080fd5b5061009561010d565b60408051918252519081900360200190f35b6100c873ffffffffffffffffffffffffffffffffffffffff60043516610113565b005b3480156100d657600080fd5b5061009573ffffffffffffffffffffffffffffffffffffffff60043516610147565b34801561010457600080fd5b506100c8610159565b60005481565b73ffffffffffffffffffffffffffffffffffffffff1660009081526001602052604081208054349081019091558154019055565b60016020526000908152604090205481565b336000908152600160205260408120805490829055908111156101af57604051339082156108fc029083906000818181858888f193505050501561019c576101af565b3360009081526001602052604090208190555b505600a165627a7a72305820627ca46bb09478a015762806cc00c431230501118c7c26c30ac58c4e09e51c4f00298080942c8eb96e7060ab864d94e91ab16f214dc66476288207e38080"
        
    public static func generateRoleBaseKeyring(_ numArr: [Int], _ address: String) throws -> AbstractKeyring {
        let keyArr = KeyringFactory.generateRoleBasedKeys(numArr, "entropy")
        return try KeyringFactory.createWithRoleBasedKey(address, keyArr)
    }
}

class FeeDelegatedSmartContractDeployTest_createInstanceBuilder: XCTestCase {
    let from = FeeDelegatedSmartContractDeployTest.from
    let account = FeeDelegatedSmartContractDeployTest.account
    let to = FeeDelegatedSmartContractDeployTest.to
    let gas = FeeDelegatedSmartContractDeployTest.gas
    let nonce = FeeDelegatedSmartContractDeployTest.nonce
    let gasPrice = FeeDelegatedSmartContractDeployTest.gasPrice
    let chainID = FeeDelegatedSmartContractDeployTest.chainID
    let value = FeeDelegatedSmartContractDeployTest.value
    let input = FeeDelegatedSmartContractDeployTest.input
    let humanReadable = FeeDelegatedSmartContractDeployTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractDeployTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractDeployTest.senderSignatureData
    let feePayer = FeeDelegatedSmartContractDeployTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractDeployTest.feePayerSignatureData
        
    public func test_BuilderTest() throws {
        let txObj = try FeeDelegatedSmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertNotNil(txObj)
    }
    
    public func test_BuilderWithRPCTest() throws {
        let txObj = try FeeDelegatedSmartContractDeploy.Builder()
            .setKlaytnCall(FeeDelegatedSmartContractDeployTest.caver.rpc.klay)
            .setGas(gas)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
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
        let txObj = try FeeDelegatedSmartContractDeploy.Builder()
            .setNonce(BigInt(hex: nonce)!)
            .setGas(BigInt(hex: gas)!)
            .setGasPrice(BigInt(hex: gasPrice)!)
            .setChainId(BigInt(hex: chainID)!)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
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
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeploy.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setValue(value)
                                .setTo(to)
                                .setInput(input)
                                .setHumanReadable(humanReadable)
                                .setCodeFormat(codeFormat)
                                .setFeePayer(feePayer)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(from)"))
        }
    }
    
    public func test_throwException_missingFrom() throws {
        let from = ""
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeploy.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setValue(value)
                                .setTo(to)
                                .setInput(input)
                                .setHumanReadable(humanReadable)
                                .setCodeFormat(codeFormat)
                                .setFeePayer(feePayer)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("from is missing."))
        }
    }
    
    public func test_throwException_invalidTo() throws {
        let to = "invalid input"
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeploy.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setValue(value)
                                .setTo(to)
                                .setInput(input)
                                .setHumanReadable(humanReadable)
                                .setCodeFormat(codeFormat)
                                .setFeePayer(feePayer)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("'to' field must be nil('0x') : \(to)"))
        }
    }
    
    public func test_throwException_invalidValue() throws {
        let value = "invalid value"
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeploy.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setValue(value)
                                .setTo(to)
                                .setInput(input)
                                .setHumanReadable(humanReadable)
                                .setCodeFormat(codeFormat)
                                .setFeePayer(feePayer)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid value : \(value)"))
        }
    }
    
    public func test_throwException_missingValue() throws {
        let value = ""
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeploy.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setValue(value)
                                .setTo(to)
                                .setInput(input)
                                .setHumanReadable(humanReadable)
                                .setCodeFormat(codeFormat)
                                .setFeePayer(feePayer)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("value is missing."))
        }
    }
        
    public func test_throwException_invalidGas() throws {
        let gas = "invalid gas"
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeploy.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setValue(value)
                                .setTo(to)
                                .setInput(input)
                                .setHumanReadable(humanReadable)
                                .setCodeFormat(codeFormat)
                                .setFeePayer(feePayer)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid gas. : \(gas)"))
        }
    }
    
    public func test_throwException_missingGas() throws {
        let gas = ""
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeploy.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setValue(value)
                                .setTo(to)
                                .setInput(input)
                                .setHumanReadable(humanReadable)
                                .setCodeFormat(codeFormat)
                                .setFeePayer(feePayer)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("gas is missing."))
        }
    }
    
    public func test_throwException_setFeePayerSignatures_missingFeePayer() throws {
        let feePayer = ""
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeploy.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setValue(value)
                                .setTo(to)
                                .setInput(input)
                                .setHumanReadable(humanReadable)
                                .setCodeFormat(codeFormat)
                                .setFeePayer(feePayer)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("feePayer is missing: feePayer must be defined with feePayerSignatures."))
        }
    }
}

class FeeDelegatedSmartContractDeployTest_createInstance: XCTestCase {
    let from = FeeDelegatedSmartContractDeployTest.from
    let account = FeeDelegatedSmartContractDeployTest.account
    let to = FeeDelegatedSmartContractDeployTest.to
    let gas = FeeDelegatedSmartContractDeployTest.gas
    let nonce = FeeDelegatedSmartContractDeployTest.nonce
    let gasPrice = FeeDelegatedSmartContractDeployTest.gasPrice
    let chainID = FeeDelegatedSmartContractDeployTest.chainID
    let value = FeeDelegatedSmartContractDeployTest.value
    let input = FeeDelegatedSmartContractDeployTest.input
    let humanReadable = FeeDelegatedSmartContractDeployTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractDeployTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractDeployTest.senderSignatureData
    let feePayer = FeeDelegatedSmartContractDeployTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractDeployTest.feePayerSignatureData
    
    public func test_createInstance() throws {
        let txObj = try FeeDelegatedSmartContractDeploy(
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
            input,
            humanReadable,
            codeFormat
        )
        
        XCTAssertNotNil(txObj)
    }
    
    public func test_throwException_invalidFrom() throws {
        let from = "invalid Address"
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeploy(
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
            input,
            humanReadable,
            codeFormat
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(from)"))
        }
    }
    
    public func test_throwException_missingFrom() throws {
        let from = ""
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeploy(
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
            input,
            humanReadable,
            codeFormat
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("from is missing."))
        }
    }
    
    public func test_throwException_invalidTo() throws {
        let to = "invalid Address"
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeploy(
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
            input,
            humanReadable,
            codeFormat
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("'to' field must be nil('0x') : \(to)"))
        }
    }
    
    public func test_throwException_invalidValue() throws {
        let value = "invalid value"
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeploy(
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
            input,
            humanReadable,
            codeFormat
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid value : \(value)"))
        }
    }
    
    public func test_throwException_missingValue() throws {
        let value = ""
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeploy(
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
            input,
            humanReadable,
            codeFormat
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("value is missing."))
        }
    }
    
    public func test_throwException_invalidGas() throws {
        let gas = "invalid gas"
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeploy(
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
            input,
            humanReadable,
            codeFormat
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid gas. : \(gas)"))
        }
    }
    
    public func test_throwException_missingGas() throws {
        let gas = ""
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeploy(
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
            input,
            humanReadable,
            codeFormat
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("gas is missing."))
        }
    }
    
    public func test_throwException_invalidHumanReadable() throws {
        let humanReadable = true
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeploy(
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
            input,
            humanReadable,
            codeFormat
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("HumanReadable attribute must set false"))
        }
    }
    
    public func test_throwException_invalidCodeFormat() throws {
        let codeFormat = "1"
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeploy(
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
            input,
            humanReadable,
            codeFormat
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("CodeFormat attribute only support EVM(0)"))
        }
    }
    
    public func test_throwException_missingCodeFormat() throws {
        let codeFormat = ""
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeploy(
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
            input,
            humanReadable,
            codeFormat
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("codeFormat is missing"))
        }
    }
    
    public func throwException_setFeePayerSignatures_missingFeePayer() throws {
        let feePayer = ""
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeploy(
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
            input,
            humanReadable,
            codeFormat
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("feePayer is missing: feePayer must be defined with feePayerSignatures."))
        }
    }
}

class FeeDelegatedSmartContractDeployTest_getRLPEncodingTest: XCTestCase {
    let from = FeeDelegatedSmartContractDeployTest.from
    let account = FeeDelegatedSmartContractDeployTest.account
    let to = FeeDelegatedSmartContractDeployTest.to
    let gas = FeeDelegatedSmartContractDeployTest.gas
    let nonce = FeeDelegatedSmartContractDeployTest.nonce
    let gasPrice = FeeDelegatedSmartContractDeployTest.gasPrice
    let chainID = FeeDelegatedSmartContractDeployTest.chainID
    let value = FeeDelegatedSmartContractDeployTest.value
    let input = FeeDelegatedSmartContractDeployTest.input
    let humanReadable = FeeDelegatedSmartContractDeployTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractDeployTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractDeployTest.senderSignatureData
    let feePayer = FeeDelegatedSmartContractDeployTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractDeployTest.feePayerSignatureData
    
    let expectedRLPEncoding = FeeDelegatedSmartContractDeployTest.expectedRLPEncoding
        
    public func test_getRLPEncoding() throws {
        let txObj = try FeeDelegatedSmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertEqual(expectedRLPEncoding, try txObj.getRLPEncoding())
    }
    
    public func test_throwException_NoNonce() throws {
        let txObj = try FeeDelegatedSmartContractDeploy.Builder()
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertThrowsError(try txObj.getRLPEncoding()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NoGasPrice() throws {
        let txObj = try FeeDelegatedSmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertThrowsError(try txObj.getRLPEncoding()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class FeeDelegatedSmartContractDeployTest_signAsFeePayer_OneKeyTest: XCTestCase {
    var mTxObj: FeeDelegatedSmartContractDeploy?
    var klaytnWalletKey: String?
    var keyring: AbstractKeyring?
    var feePayerAddress: String?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedSmartContractDeployTest.feePayerPrivateKey
        
    let from = "0xa94f5374Fce5edBC8E2a8697C15331677e6EbF0B"
    let account = FeeDelegatedSmartContractDeployTest.account
    let to = "0x"
    let gas = "0xf4240"
    let nonce = "0x4d2"
    let gasPrice = "0x19"
    let chainID = "0x1"
    let value = "0x00"
    let input = FeeDelegatedSmartContractDeployTest.input
    let humanReadable = FeeDelegatedSmartContractDeployTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractDeployTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractDeployTest.senderSignatureData
    let feePayer = FeeDelegatedSmartContractDeployTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractDeployTest.feePayerSignatureData
    
    let expectedRLPEncoding = "0x29f902c78204d219830f4240808094a94f5374fce5edbc8e2a8697c15331677e6ebf0bb901fe608060405234801561001057600080fd5b506101de806100206000396000f3006080604052600436106100615763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416631a39d8ef81146100805780636353586b146100a757806370a08231146100ca578063fd6b7ef8146100f8575b3360009081526001602052604081208054349081019091558154019055005b34801561008c57600080fd5b5061009561010d565b60408051918252519081900360200190f35b6100c873ffffffffffffffffffffffffffffffffffffffff60043516610113565b005b3480156100d657600080fd5b5061009573ffffffffffffffffffffffffffffffffffffffff60043516610147565b34801561010457600080fd5b506100c8610159565b60005481565b73ffffffffffffffffffffffffffffffffffffffff1660009081526001602052604081208054349081019091558154019055565b60016020526000908152604090205481565b336000908152600160205260408120805490829055908111156101af57604051339082156108fc029083906000818181858888f193505050501561019c576101af565b3360009081526001602052604090208190555b505600a165627a7a72305820627ca46bb09478a015762806cc00c431230501118c7c26c30ac58c4e09e51c4f00298080f847f845820fe9a07abfd0f0cfb9a9c38c6e3e1a4eeb15f43aeb4b4f6dee7c3f37c07e417af89d9ba03f1e54a512c906d2e57a611b25ce4739d12928e199c3e89792b82f577f0da9ad9433f524631e573329a550296f595c820d6c65213ff845f84326a0e21385082f88713e8548e17a9b30e8627af749e064b0539890f65dbb8c7868caa0375316897322483d2c4946a761a4e8b22007fd2109f82f9d44255e56256905dc"
        
    override func setUpWithError() throws {
        keyring = try KeyringFactory.createFromPrivateKey(feePayerPrivateKey)
        klaytnWalletKey = try keyring?.getKlaytnWalletKey()
        feePayerAddress = keyring?.address
        
        mTxObj = try FeeDelegatedSmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
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

class FeeDelegatedSmartContractDeployTest_signAsFeePayer_AllKeyTest: XCTestCase {
    var mTxObj: FeeDelegatedSmartContractDeploy?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedSmartContractDeployTest.feePayerPrivateKey
        
    let from = FeeDelegatedSmartContractDeployTest.from
    let account = FeeDelegatedSmartContractDeployTest.account
    let to = FeeDelegatedSmartContractDeployTest.to
    let gas = FeeDelegatedSmartContractDeployTest.gas
    let nonce = FeeDelegatedSmartContractDeployTest.nonce
    let gasPrice = FeeDelegatedSmartContractDeployTest.gasPrice
    let chainID = FeeDelegatedSmartContractDeployTest.chainID
    let value = FeeDelegatedSmartContractDeployTest.value
    let input = FeeDelegatedSmartContractDeployTest.input
    let humanReadable = FeeDelegatedSmartContractDeployTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractDeployTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractDeployTest.senderSignatureData
    var feePayer = FeeDelegatedSmartContractDeployTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractDeployTest.feePayerSignatureData
    
    let expectedRLPEncoding = FeeDelegatedSmartContractDeployTest.expectedRLPEncoding
        
    override func setUpWithError() throws {
        feePayer = try KeyringFactory.createFromPrivateKey(feePayerPrivateKey).address
        mTxObj = try FeeDelegatedSmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
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

class FeeDelegatedSmartContractDeployTest_appendFeePayerSignaturesTest: XCTestCase {
    var mTxObj: FeeDelegatedSmartContractDeploy?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = FeeDelegatedSmartContractDeployTest.senderPrivateKey
    let feePayerPrivateKey = FeeDelegatedSmartContractDeployTest.feePayerPrivateKey
        
    let from = FeeDelegatedSmartContractDeployTest.from
    let account = FeeDelegatedSmartContractDeployTest.account
    let to = FeeDelegatedSmartContractDeployTest.to
    let gas = FeeDelegatedSmartContractDeployTest.gas
    let nonce = FeeDelegatedSmartContractDeployTest.nonce
    let gasPrice = FeeDelegatedSmartContractDeployTest.gasPrice
    let chainID = FeeDelegatedSmartContractDeployTest.chainID
    let value = FeeDelegatedSmartContractDeployTest.value
    let input = FeeDelegatedSmartContractDeployTest.input
    let humanReadable = FeeDelegatedSmartContractDeployTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractDeployTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractDeployTest.senderSignatureData
    let feePayer = FeeDelegatedSmartContractDeployTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractDeployTest.feePayerSignatureData
    
    override func setUpWithError() throws {
        mTxObj = try FeeDelegatedSmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
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
        mTxObj = try FeeDelegatedSmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
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
        
        mTxObj = try FeeDelegatedSmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
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
        
        mTxObj = try FeeDelegatedSmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
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

class FeeDelegatedSmartContractDeployTest_combineSignatureTest: XCTestCase {
    var mTxObj: FeeDelegatedSmartContractDeploy?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = FeeDelegatedSmartContractDeployTest.senderPrivateKey
    let from = "0x54dc8905caf698250cebfcbde49f037b52d55f61"
    var account: Account?
    let to = "0x"
    let gas = "0xdbba0"
    let nonce = "0x1"
    let gasPrice = "0x5d21dba00"
    let chainID = "0x7e3"
    let value = "0x0"
    let input = FeeDelegatedSmartContractDeployTest.input
    let humanReadable = FeeDelegatedSmartContractDeployTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractDeployTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractDeployTest.senderSignatureData
    let feePayer = FeeDelegatedSmartContractDeployTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractDeployTest.feePayerSignatureData
    let expectedRLPEncoding = FeeDelegatedSmartContractDeployTest.expectedRLPEncoding
    
    override func setUpWithError() throws {
        mTxObj = try FeeDelegatedSmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
            .build()
    }
    
    public func test_combineSignature() throws {
        let expectedRLPEncoded = "0x29f90288018505d21dba00830dbba080809454dc8905caf698250cebfcbde49f037b52d55f61b901fe608060405234801561001057600080fd5b506101de806100206000396000f3006080604052600436106100615763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416631a39d8ef81146100805780636353586b146100a757806370a08231146100ca578063fd6b7ef8146100f8575b3360009081526001602052604081208054349081019091558154019055005b34801561008c57600080fd5b5061009561010d565b60408051918252519081900360200190f35b6100c873ffffffffffffffffffffffffffffffffffffffff60043516610113565b005b3480156100d657600080fd5b5061009573ffffffffffffffffffffffffffffffffffffffff60043516610147565b34801561010457600080fd5b506100c8610159565b60005481565b73ffffffffffffffffffffffffffffffffffffffff1660009081526001602052604081208054349081019091558154019055565b60016020526000908152604090205481565b336000908152600160205260408120805490829055908111156101af57604051339082156108fc029083906000818181858888f193505050501561019c576101af565b3360009081526001602052604090208190555b505600a165627a7a72305820627ca46bb09478a015762806cc00c431230501118c7c26c30ac58c4e09e51c4f00298080f847f845820fe9a0627b73b8636a2d98f5f51bc30381631055127c3aa13f6f5d470c94ace4d10780a010632196cf8e128de3f99f5e13d41c254dfe3edcc17eea84a49e287cf5b28bda940000000000000000000000000000000000000000c4c3018080"
        
        let expectedSignature = SignatureData(
            "0x0fe9",
            "0x627b73b8636a2d98f5f51bc30381631055127c3aa13f6f5d470c94ace4d10780",
            "0x10632196cf8e128de3f99f5e13d41c254dfe3edcc17eea84a49e287cf5b28bda"
        )
        
        let rlpEncoded = "0x29f90288018505d21dba00830dbba080809454dc8905caf698250cebfcbde49f037b52d55f61b901fe608060405234801561001057600080fd5b506101de806100206000396000f3006080604052600436106100615763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416631a39d8ef81146100805780636353586b146100a757806370a08231146100ca578063fd6b7ef8146100f8575b3360009081526001602052604081208054349081019091558154019055005b34801561008c57600080fd5b5061009561010d565b60408051918252519081900360200190f35b6100c873ffffffffffffffffffffffffffffffffffffffff60043516610113565b005b3480156100d657600080fd5b5061009573ffffffffffffffffffffffffffffffffffffffff60043516610147565b34801561010457600080fd5b506100c8610159565b60005481565b73ffffffffffffffffffffffffffffffffffffffff1660009081526001602052604081208054349081019091558154019055565b60016020526000908152604090205481565b336000908152600160205260408120805490829055908111156101af57604051339082156108fc029083906000818181858888f193505050501561019c576101af565b3360009081526001602052604090208190555b505600a165627a7a72305820627ca46bb09478a015762806cc00c431230501118c7c26c30ac58c4e09e51c4f00298080f847f845820fe9a0627b73b8636a2d98f5f51bc30381631055127c3aa13f6f5d470c94ace4d10780a010632196cf8e128de3f99f5e13d41c254dfe3edcc17eea84a49e287cf5b28bda940000000000000000000000000000000000000000c4c3018080"
        
        let combined = try mTxObj!.combineSignedRawTransactions([rlpEncoded])
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature, mTxObj?.signatures[0])
    }
    
    public func test_combine_multipleSignature() throws {
        let expectedRLPEncoded = "0x29f90316018505d21dba00830dbba080809454dc8905caf698250cebfcbde49f037b52d55f61b901fe608060405234801561001057600080fd5b506101de806100206000396000f3006080604052600436106100615763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416631a39d8ef81146100805780636353586b146100a757806370a08231146100ca578063fd6b7ef8146100f8575b3360009081526001602052604081208054349081019091558154019055005b34801561008c57600080fd5b5061009561010d565b60408051918252519081900360200190f35b6100c873ffffffffffffffffffffffffffffffffffffffff60043516610113565b005b3480156100d657600080fd5b5061009573ffffffffffffffffffffffffffffffffffffffff60043516610147565b34801561010457600080fd5b506100c8610159565b60005481565b73ffffffffffffffffffffffffffffffffffffffff1660009081526001602052604081208054349081019091558154019055565b60016020526000908152604090205481565b336000908152600160205260408120805490829055908111156101af57604051339082156108fc029083906000818181858888f193505050501561019c576101af565b3360009081526001602052604090208190555b505600a165627a7a72305820627ca46bb09478a015762806cc00c431230501118c7c26c30ac58c4e09e51c4f00298080f8d5f845820fe9a0627b73b8636a2d98f5f51bc30381631055127c3aa13f6f5d470c94ace4d10780a010632196cf8e128de3f99f5e13d41c254dfe3edcc17eea84a49e287cf5b28bdaf845820fe9a0c941f8f173e5a5c22216f3f0fdfa4da602356398e24ceee99beb2a2a9c2bfafca00f231de0075bd109708513416a3896fa076130cf6fd891cb1a7abd1835a352bef845820fe9a073bdd7375228ab9598ab5be10a4ffe1c44211de675295cf07bfce726eef2b764a018923a5455d601c52532280259d820ec2ae5cda3ec57095d8df2a872192a5ae9940000000000000000000000000000000000000000c4c3018080"
        
        let expectedSignature = [
            SignatureData(
                    "0x0fe9",
                    "0x627b73b8636a2d98f5f51bc30381631055127c3aa13f6f5d470c94ace4d10780",
                    "0x10632196cf8e128de3f99f5e13d41c254dfe3edcc17eea84a49e287cf5b28bda"
            ),
            SignatureData(
                    "0x0fe9",
                    "0xc941f8f173e5a5c22216f3f0fdfa4da602356398e24ceee99beb2a2a9c2bfafc",
                    "0x0f231de0075bd109708513416a3896fa076130cf6fd891cb1a7abd1835a352be"
            ),
            SignatureData(
                    "0x0fe9",
                    "0x73bdd7375228ab9598ab5be10a4ffe1c44211de675295cf07bfce726eef2b764",
                    "0x18923a5455d601c52532280259d820ec2ae5cda3ec57095d8df2a872192a5ae9"
            )
        ]
        
        let rlpEncodedString = [
            "0x29f90274018505d21dba00830dbba080809454dc8905caf698250cebfcbde49f037b52d55f61b901fe608060405234801561001057600080fd5b506101de806100206000396000f3006080604052600436106100615763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416631a39d8ef81146100805780636353586b146100a757806370a08231146100ca578063fd6b7ef8146100f8575b3360009081526001602052604081208054349081019091558154019055005b34801561008c57600080fd5b5061009561010d565b60408051918252519081900360200190f35b6100c873ffffffffffffffffffffffffffffffffffffffff60043516610113565b005b3480156100d657600080fd5b5061009573ffffffffffffffffffffffffffffffffffffffff60043516610147565b34801561010457600080fd5b506100c8610159565b60005481565b73ffffffffffffffffffffffffffffffffffffffff1660009081526001602052604081208054349081019091558154019055565b60016020526000908152604090205481565b336000908152600160205260408120805490829055908111156101af57604051339082156108fc029083906000818181858888f193505050501561019c576101af565b3360009081526001602052604090208190555b505600a165627a7a72305820627ca46bb09478a015762806cc00c431230501118c7c26c30ac58c4e09e51c4f00298080f847f845820fe9a0c941f8f173e5a5c22216f3f0fdfa4da602356398e24ceee99beb2a2a9c2bfafca00f231de0075bd109708513416a3896fa076130cf6fd891cb1a7abd1835a352be80c4c3018080",
            "0x29f90274018505d21dba00830dbba080809454dc8905caf698250cebfcbde49f037b52d55f61b901fe608060405234801561001057600080fd5b506101de806100206000396000f3006080604052600436106100615763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416631a39d8ef81146100805780636353586b146100a757806370a08231146100ca578063fd6b7ef8146100f8575b3360009081526001602052604081208054349081019091558154019055005b34801561008c57600080fd5b5061009561010d565b60408051918252519081900360200190f35b6100c873ffffffffffffffffffffffffffffffffffffffff60043516610113565b005b3480156100d657600080fd5b5061009573ffffffffffffffffffffffffffffffffffffffff60043516610147565b34801561010457600080fd5b506100c8610159565b60005481565b73ffffffffffffffffffffffffffffffffffffffff1660009081526001602052604081208054349081019091558154019055565b60016020526000908152604090205481565b336000908152600160205260408120805490829055908111156101af57604051339082156108fc029083906000818181858888f193505050501561019c576101af565b3360009081526001602052604090208190555b505600a165627a7a72305820627ca46bb09478a015762806cc00c431230501118c7c26c30ac58c4e09e51c4f00298080f847f845820fe9a073bdd7375228ab9598ab5be10a4ffe1c44211de675295cf07bfce726eef2b764a018923a5455d601c52532280259d820ec2ae5cda3ec57095d8df2a872192a5ae980c4c3018080"
        ]
        
        let senderSignatureData = SignatureData(
            "0x0fe9",
            "0x627b73b8636a2d98f5f51bc30381631055127c3aa13f6f5d470c94ace4d10780",
            "0x10632196cf8e128de3f99f5e13d41c254dfe3edcc17eea84a49e287cf5b28bda"
        )
        
        mTxObj = try FeeDelegatedSmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
            .setSignatures(senderSignatureData)
            .build()
        
        let combined = try mTxObj!.combineSignedRawTransactions(rlpEncodedString)
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature[0], mTxObj?.signatures[0])
        XCTAssertEqual(expectedSignature[1], mTxObj?.signatures[1])
        XCTAssertEqual(expectedSignature[2], mTxObj?.signatures[2])
    }
    
    public func test_combineSignature_feePayerSignature() throws {
        let expectedRLPEncoded = "0x29f90288018505d21dba00830dbba080809454dc8905caf698250cebfcbde49f037b52d55f61b901fe608060405234801561001057600080fd5b506101de806100206000396000f3006080604052600436106100615763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416631a39d8ef81146100805780636353586b146100a757806370a08231146100ca578063fd6b7ef8146100f8575b3360009081526001602052604081208054349081019091558154019055005b34801561008c57600080fd5b5061009561010d565b60408051918252519081900360200190f35b6100c873ffffffffffffffffffffffffffffffffffffffff60043516610113565b005b3480156100d657600080fd5b5061009573ffffffffffffffffffffffffffffffffffffffff60043516610147565b34801561010457600080fd5b506100c8610159565b60005481565b73ffffffffffffffffffffffffffffffffffffffff1660009081526001602052604081208054349081019091558154019055565b60016020526000908152604090205481565b336000908152600160205260408120805490829055908111156101af57604051339082156108fc029083906000818181858888f193505050501561019c576101af565b3360009081526001602052604090208190555b505600a165627a7a72305820627ca46bb09478a015762806cc00c431230501118c7c26c30ac58c4e09e51c4f00298080c4c301808094b1d7bfd3587cd8bfb1cc6ae980fef3735a3601abf847f845820fe9a0142775d7fd0e65c21ddf3a83f32a9b3043638b0fd0f75301b436616b00261121a07efb4167f4cfd4c6497bf812014f80a4e66612f860e1ff5a4f5fdc282b131a72"
        
        let expectedSignature = SignatureData(
            "0x0fe9",
            "0x142775d7fd0e65c21ddf3a83f32a9b3043638b0fd0f75301b436616b00261121",
            "0x7efb4167f4cfd4c6497bf812014f80a4e66612f860e1ff5a4f5fdc282b131a72"
        )
        
        let rlpEncoded = "0x29f90288018505d21dba00830dbba080809454dc8905caf698250cebfcbde49f037b52d55f61b901fe608060405234801561001057600080fd5b506101de806100206000396000f3006080604052600436106100615763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416631a39d8ef81146100805780636353586b146100a757806370a08231146100ca578063fd6b7ef8146100f8575b3360009081526001602052604081208054349081019091558154019055005b34801561008c57600080fd5b5061009561010d565b60408051918252519081900360200190f35b6100c873ffffffffffffffffffffffffffffffffffffffff60043516610113565b005b3480156100d657600080fd5b5061009573ffffffffffffffffffffffffffffffffffffffff60043516610147565b34801561010457600080fd5b506100c8610159565b60005481565b73ffffffffffffffffffffffffffffffffffffffff1660009081526001602052604081208054349081019091558154019055565b60016020526000908152604090205481565b336000908152600160205260408120805490829055908111156101af57604051339082156108fc029083906000818181858888f193505050501561019c576101af565b3360009081526001602052604090208190555b505600a165627a7a72305820627ca46bb09478a015762806cc00c431230501118c7c26c30ac58c4e09e51c4f00298080c4c301808094b1d7bfd3587cd8bfb1cc6ae980fef3735a3601abf847f845820fe9a0142775d7fd0e65c21ddf3a83f32a9b3043638b0fd0f75301b436616b00261121a07efb4167f4cfd4c6497bf812014f80a4e66612f860e1ff5a4f5fdc282b131a72"
        
        let feePayer = "0xb1d7bfd3587cd8bfb1cc6ae980fef3735a3601ab"
        
        mTxObj = try FeeDelegatedSmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
            .setFeePayer(feePayer)
            .build()
        
        let combined = try mTxObj!.combineSignedRawTransactions([rlpEncoded])
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature, mTxObj?.feePayerSignatures[0])
    }
    
    public func test_combineSignature_multipleFeePayerSignature() throws {
        let expectedRLPEncoded = "0x29f90316018505d21dba00830dbba080809454dc8905caf698250cebfcbde49f037b52d55f61b901fe608060405234801561001057600080fd5b506101de806100206000396000f3006080604052600436106100615763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416631a39d8ef81146100805780636353586b146100a757806370a08231146100ca578063fd6b7ef8146100f8575b3360009081526001602052604081208054349081019091558154019055005b34801561008c57600080fd5b5061009561010d565b60408051918252519081900360200190f35b6100c873ffffffffffffffffffffffffffffffffffffffff60043516610113565b005b3480156100d657600080fd5b5061009573ffffffffffffffffffffffffffffffffffffffff60043516610147565b34801561010457600080fd5b506100c8610159565b60005481565b73ffffffffffffffffffffffffffffffffffffffff1660009081526001602052604081208054349081019091558154019055565b60016020526000908152604090205481565b336000908152600160205260408120805490829055908111156101af57604051339082156108fc029083906000818181858888f193505050501561019c576101af565b3360009081526001602052604090208190555b505600a165627a7a72305820627ca46bb09478a015762806cc00c431230501118c7c26c30ac58c4e09e51c4f00298080c4c301808094b1d7bfd3587cd8bfb1cc6ae980fef3735a3601abf8d5f845820fe9a0142775d7fd0e65c21ddf3a83f32a9b3043638b0fd0f75301b436616b00261121a07efb4167f4cfd4c6497bf812014f80a4e66612f860e1ff5a4f5fdc282b131a72f845820feaa06e6acf405e08848854e469e8e38edad783ebf0e24cdefbd5d4a2d8f75c37b662a06f39343ba613683a6b0c85ed2f421acdee010027d5803c0da9658b21602919c6f845820feaa0a85dfa3531c970ad63298dc803176e5c3edb98fdaa406fc32be853bedba01e51a03c6b2458349fc33f5acef72252e62e1c59e38dcb00a1c38426b00c2f0d8051be"
        
        let expectedSignature = [
            SignatureData(
                    "0x0fe9",
                    "0x142775d7fd0e65c21ddf3a83f32a9b3043638b0fd0f75301b436616b00261121",
                    "0x7efb4167f4cfd4c6497bf812014f80a4e66612f860e1ff5a4f5fdc282b131a72"
            ),
            SignatureData(
                    "0x0fea",
                    "0x6e6acf405e08848854e469e8e38edad783ebf0e24cdefbd5d4a2d8f75c37b662",
                    "0x6f39343ba613683a6b0c85ed2f421acdee010027d5803c0da9658b21602919c6"
            ),
            SignatureData(
                    "0x0fea",
                    "0xa85dfa3531c970ad63298dc803176e5c3edb98fdaa406fc32be853bedba01e51",
                    "0x3c6b2458349fc33f5acef72252e62e1c59e38dcb00a1c38426b00c2f0d8051be"
            )
        ]
        
        let rlpEncodedString = [
            "0x29f90288018505d21dba00830dbba080809454dc8905caf698250cebfcbde49f037b52d55f61b901fe608060405234801561001057600080fd5b506101de806100206000396000f3006080604052600436106100615763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416631a39d8ef81146100805780636353586b146100a757806370a08231146100ca578063fd6b7ef8146100f8575b3360009081526001602052604081208054349081019091558154019055005b34801561008c57600080fd5b5061009561010d565b60408051918252519081900360200190f35b6100c873ffffffffffffffffffffffffffffffffffffffff60043516610113565b005b3480156100d657600080fd5b5061009573ffffffffffffffffffffffffffffffffffffffff60043516610147565b34801561010457600080fd5b506100c8610159565b60005481565b73ffffffffffffffffffffffffffffffffffffffff1660009081526001602052604081208054349081019091558154019055565b60016020526000908152604090205481565b336000908152600160205260408120805490829055908111156101af57604051339082156108fc029083906000818181858888f193505050501561019c576101af565b3360009081526001602052604090208190555b505600a165627a7a72305820627ca46bb09478a015762806cc00c431230501118c7c26c30ac58c4e09e51c4f00298080c4c301808094b1d7bfd3587cd8bfb1cc6ae980fef3735a3601abf847f845820feaa06e6acf405e08848854e469e8e38edad783ebf0e24cdefbd5d4a2d8f75c37b662a06f39343ba613683a6b0c85ed2f421acdee010027d5803c0da9658b21602919c6",
            "0x29f90288018505d21dba00830dbba080809454dc8905caf698250cebfcbde49f037b52d55f61b901fe608060405234801561001057600080fd5b506101de806100206000396000f3006080604052600436106100615763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416631a39d8ef81146100805780636353586b146100a757806370a08231146100ca578063fd6b7ef8146100f8575b3360009081526001602052604081208054349081019091558154019055005b34801561008c57600080fd5b5061009561010d565b60408051918252519081900360200190f35b6100c873ffffffffffffffffffffffffffffffffffffffff60043516610113565b005b3480156100d657600080fd5b5061009573ffffffffffffffffffffffffffffffffffffffff60043516610147565b34801561010457600080fd5b506100c8610159565b60005481565b73ffffffffffffffffffffffffffffffffffffffff1660009081526001602052604081208054349081019091558154019055565b60016020526000908152604090205481565b336000908152600160205260408120805490829055908111156101af57604051339082156108fc029083906000818181858888f193505050501561019c576101af565b3360009081526001602052604090208190555b505600a165627a7a72305820627ca46bb09478a015762806cc00c431230501118c7c26c30ac58c4e09e51c4f00298080c4c301808094b1d7bfd3587cd8bfb1cc6ae980fef3735a3601abf847f845820feaa0a85dfa3531c970ad63298dc803176e5c3edb98fdaa406fc32be853bedba01e51a03c6b2458349fc33f5acef72252e62e1c59e38dcb00a1c38426b00c2f0d8051be",
        ]
        
        let feePayer = "0xb1d7bfd3587cd8bfb1cc6ae980fef3735a3601ab"
        let feePayerSignatureData = SignatureData(
            "0x0fe9",
            "0x142775d7fd0e65c21ddf3a83f32a9b3043638b0fd0f75301b436616b00261121",
            "0x7efb4167f4cfd4c6497bf812014f80a4e66612f860e1ff5a4f5fdc282b131a72"
        )
        
        mTxObj = try FeeDelegatedSmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
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
        mTxObj = try FeeDelegatedSmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
            .build()
        
        let rlpEncodedString = "0x29f90302018505d21dba00830dbba080809454dc8905caf698250cebfcbde49f037b52d55f61b901fe608060405234801561001057600080fd5b506101de806100206000396000f3006080604052600436106100615763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416631a39d8ef81146100805780636353586b146100a757806370a08231146100ca578063fd6b7ef8146100f8575b3360009081526001602052604081208054349081019091558154019055005b34801561008c57600080fd5b5061009561010d565b60408051918252519081900360200190f35b6100c873ffffffffffffffffffffffffffffffffffffffff60043516610113565b005b3480156100d657600080fd5b5061009573ffffffffffffffffffffffffffffffffffffffff60043516610147565b34801561010457600080fd5b506100c8610159565b60005481565b73ffffffffffffffffffffffffffffffffffffffff1660009081526001602052604081208054349081019091558154019055565b60016020526000908152604090205481565b336000908152600160205260408120805490829055908111156101af57604051339082156108fc029083906000818181858888f193505050501561019c576101af565b3360009081526001602052604090208190555b505600a165627a7a72305820627ca46bb09478a015762806cc00c431230501118c7c26c30ac58c4e09e51c4f00298080f8d5f845820fe9a0627b73b8636a2d98f5f51bc30381631055127c3aa13f6f5d470c94ace4d10780a010632196cf8e128de3f99f5e13d41c254dfe3edcc17eea84a49e287cf5b28bdaf845820fe9a0c941f8f173e5a5c22216f3f0fdfa4da602356398e24ceee99beb2a2a9c2bfafca00f231de0075bd109708513416a3896fa076130cf6fd891cb1a7abd1835a352bef845820fe9a073bdd7375228ab9598ab5be10a4ffe1c44211de675295cf07bfce726eef2b764a018923a5455d601c52532280259d820ec2ae5cda3ec57095d8df2a872192a5ae980c4c3018080"
        
        let expectedSignature = [
            SignatureData(
                    "0x0fe9",
                    "0x627b73b8636a2d98f5f51bc30381631055127c3aa13f6f5d470c94ace4d10780",
                    "0x10632196cf8e128de3f99f5e13d41c254dfe3edcc17eea84a49e287cf5b28bda"
            ),
            SignatureData(
                    "0x0fe9",
                    "0xc941f8f173e5a5c22216f3f0fdfa4da602356398e24ceee99beb2a2a9c2bfafc",
                    "0x0f231de0075bd109708513416a3896fa076130cf6fd891cb1a7abd1835a352be"
            ),
            SignatureData(
                    "0x0fe9",
                    "0x73bdd7375228ab9598ab5be10a4ffe1c44211de675295cf07bfce726eef2b764",
                    "0x18923a5455d601c52532280259d820ec2ae5cda3ec57095d8df2a872192a5ae9"
            )
        ]
        
        _ = try mTxObj!.combineSignedRawTransactions([rlpEncodedString])
        
        let rlpEncodedStringsWithFeePayerSignatures = "0x29f90316018505d21dba00830dbba080809454dc8905caf698250cebfcbde49f037b52d55f61b901fe608060405234801561001057600080fd5b506101de806100206000396000f3006080604052600436106100615763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416631a39d8ef81146100805780636353586b146100a757806370a08231146100ca578063fd6b7ef8146100f8575b3360009081526001602052604081208054349081019091558154019055005b34801561008c57600080fd5b5061009561010d565b60408051918252519081900360200190f35b6100c873ffffffffffffffffffffffffffffffffffffffff60043516610113565b005b3480156100d657600080fd5b5061009573ffffffffffffffffffffffffffffffffffffffff60043516610147565b34801561010457600080fd5b506100c8610159565b60005481565b73ffffffffffffffffffffffffffffffffffffffff1660009081526001602052604081208054349081019091558154019055565b60016020526000908152604090205481565b336000908152600160205260408120805490829055908111156101af57604051339082156108fc029083906000818181858888f193505050501561019c576101af565b3360009081526001602052604090208190555b505600a165627a7a72305820627ca46bb09478a015762806cc00c431230501118c7c26c30ac58c4e09e51c4f00298080c4c301808094b1d7bfd3587cd8bfb1cc6ae980fef3735a3601abf8d5f845820fe9a0142775d7fd0e65c21ddf3a83f32a9b3043638b0fd0f75301b436616b00261121a07efb4167f4cfd4c6497bf812014f80a4e66612f860e1ff5a4f5fdc282b131a72f845820feaa06e6acf405e08848854e469e8e38edad783ebf0e24cdefbd5d4a2d8f75c37b662a06f39343ba613683a6b0c85ed2f421acdee010027d5803c0da9658b21602919c6f845820feaa0a85dfa3531c970ad63298dc803176e5c3edb98fdaa406fc32be853bedba01e51a03c6b2458349fc33f5acef72252e62e1c59e38dcb00a1c38426b00c2f0d8051be"
        
        let expectedFeePayerSignatures = [
            SignatureData(
                    "0x0fe9",
                    "0x142775d7fd0e65c21ddf3a83f32a9b3043638b0fd0f75301b436616b00261121",
                    "0x7efb4167f4cfd4c6497bf812014f80a4e66612f860e1ff5a4f5fdc282b131a72"
            ),
            SignatureData(
                    "0x0fea",
                    "0x6e6acf405e08848854e469e8e38edad783ebf0e24cdefbd5d4a2d8f75c37b662",
                    "0x6f39343ba613683a6b0c85ed2f421acdee010027d5803c0da9658b21602919c6"
            ),
            SignatureData(
                    "0x0fea",
                    "0xa85dfa3531c970ad63298dc803176e5c3edb98fdaa406fc32be853bedba01e51",
                    "0x3c6b2458349fc33f5acef72252e62e1c59e38dcb00a1c38426b00c2f0d8051be"
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
        mTxObj = try FeeDelegatedSmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
            .build()
        
        let rlpEncoded = "0x09f899018505d21dba00830f4240947b65b75d204abed71587c9e519a89277766ee1d00a9404bb86a1b16113ebe8f57071f839b002cbcbf7d0c4c301808094b85f01a3b0b6aaa2e487c9ed541e27b75b3eba95f847f845820feaa0d432bdce799828530d89d14b4406ccb0446852a51f13e365123eac9375d7e629a04f73deb5343ff7d587a5affb14196a79c522b9a67c7d895762c6758258ac247b"
        
        XCTAssertThrowsError(try mTxObj!.combineSignedRawTransactions([rlpEncoded])) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("Transactions containing different information cannot be combined."))
        }
    }
}

class FeeDelegatedSmartContractDeployTest_getRawTransactionTest: XCTestCase {
    let privateKey = FeeDelegatedSmartContractDeployTest.senderPrivateKey
    let feePayerPrivateKey = FeeDelegatedSmartContractDeployTest.feePayerPrivateKey
        
    let from = FeeDelegatedSmartContractDeployTest.from
    let account = FeeDelegatedSmartContractDeployTest.account
    let to = FeeDelegatedSmartContractDeployTest.to
    let gas = FeeDelegatedSmartContractDeployTest.gas
    let nonce = FeeDelegatedSmartContractDeployTest.nonce
    let gasPrice = FeeDelegatedSmartContractDeployTest.gasPrice
    let chainID = FeeDelegatedSmartContractDeployTest.chainID
    let value = FeeDelegatedSmartContractDeployTest.value
    let input = FeeDelegatedSmartContractDeployTest.input
    let humanReadable = FeeDelegatedSmartContractDeployTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractDeployTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractDeployTest.senderSignatureData
    let feePayer = FeeDelegatedSmartContractDeployTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractDeployTest.feePayerSignatureData
    
    let expectedRLPEncoding = FeeDelegatedSmartContractDeployTest.expectedRLPEncoding
    
    public func test_getRawTransaction() throws {
        let txObj = try FeeDelegatedSmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()

        XCTAssertEqual(expectedRLPEncoding, try txObj.getRawTransaction())
    }
}

class FeeDelegatedSmartContractDeployTest_getTransactionHashTest: XCTestCase {
    var mTxObj: FeeDelegatedSmartContractDeploy?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = FeeDelegatedSmartContractDeployTest.senderPrivateKey
    let feePayerPrivateKey = FeeDelegatedSmartContractDeployTest.feePayerPrivateKey
        
    let from = FeeDelegatedSmartContractDeployTest.from
    let account = FeeDelegatedSmartContractDeployTest.account
    let to = FeeDelegatedSmartContractDeployTest.to
    let gas = FeeDelegatedSmartContractDeployTest.gas
    let nonce = FeeDelegatedSmartContractDeployTest.nonce
    let gasPrice = FeeDelegatedSmartContractDeployTest.gasPrice
    let chainID = FeeDelegatedSmartContractDeployTest.chainID
    let value = FeeDelegatedSmartContractDeployTest.value
    let input = FeeDelegatedSmartContractDeployTest.input
    let humanReadable = FeeDelegatedSmartContractDeployTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractDeployTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractDeployTest.senderSignatureData
    let feePayer = FeeDelegatedSmartContractDeployTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractDeployTest.feePayerSignatureData
    
    let expectedRLPEncoding = FeeDelegatedSmartContractDeployTest.expectedRLPEncoding
    let expectedTransactionHash = FeeDelegatedSmartContractDeployTest.expectedTransactionHash
            
    public func test_getTransactionHash() throws {
        let txObj = try FeeDelegatedSmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()

        XCTAssertEqual(expectedTransactionHash, try txObj.getTransactionHash())
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try FeeDelegatedSmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
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
        
        mTxObj = try FeeDelegatedSmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getTransactionHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class FeeDelegatedSmartContractDeployTest_getSenderTxHashTest: XCTestCase {
    var mTxObj: FeeDelegatedSmartContractDeploy?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = FeeDelegatedSmartContractDeployTest.senderPrivateKey
    let from = FeeDelegatedSmartContractDeployTest.from
    let account = FeeDelegatedSmartContractDeployTest.account
    let to = FeeDelegatedSmartContractDeployTest.to
    let gas = FeeDelegatedSmartContractDeployTest.gas
    let nonce = FeeDelegatedSmartContractDeployTest.nonce
    let gasPrice = FeeDelegatedSmartContractDeployTest.gasPrice
    let chainID = FeeDelegatedSmartContractDeployTest.chainID
    let value = FeeDelegatedSmartContractDeployTest.value
    let input = FeeDelegatedSmartContractDeployTest.input
    let humanReadable = FeeDelegatedSmartContractDeployTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractDeployTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractDeployTest.senderSignatureData
    let feePayer = FeeDelegatedSmartContractDeployTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractDeployTest.feePayerSignatureData
    let expectedRLPEncoding = FeeDelegatedSmartContractDeployTest.expectedRLPEncoding
    let expectedTransactionHash = FeeDelegatedSmartContractDeployTest.expectedTransactionHash
    let expectedSenderTransactionHash = FeeDelegatedSmartContractDeployTest.expectedSenderTransactionHash
            
    public func test_getRLPEncodingForSignature() throws {
        mTxObj = try FeeDelegatedSmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertEqual(expectedSenderTransactionHash, try mTxObj!.getSenderTxHash())
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try FeeDelegatedSmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
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
        
        mTxObj = try FeeDelegatedSmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getSenderTxHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class FeeDelegatedSmartContractDeployTest_getRLPEncodingForFeePayerSignatureTest: XCTestCase {
    var mTxObj: FeeDelegatedSmartContractDeploy?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = FeeDelegatedSmartContractDeployTest.senderPrivateKey
    let from = FeeDelegatedSmartContractDeployTest.from
    let account = FeeDelegatedSmartContractDeployTest.account
    let to = FeeDelegatedSmartContractDeployTest.to
    let gas = FeeDelegatedSmartContractDeployTest.gas
    let nonce = FeeDelegatedSmartContractDeployTest.nonce
    let gasPrice = FeeDelegatedSmartContractDeployTest.gasPrice
    let chainID = FeeDelegatedSmartContractDeployTest.chainID
    let value = FeeDelegatedSmartContractDeployTest.value
    let input = FeeDelegatedSmartContractDeployTest.input
    let humanReadable = FeeDelegatedSmartContractDeployTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractDeployTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractDeployTest.senderSignatureData
    let feePayer = FeeDelegatedSmartContractDeployTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractDeployTest.feePayerSignatureData
    let expectedRLPEncoding = FeeDelegatedSmartContractDeployTest.expectedRLPEncoding
    let expectedTransactionHash = FeeDelegatedSmartContractDeployTest.expectedTransactionHash
    let expectedSenderTransactionHash = FeeDelegatedSmartContractDeployTest.expectedSenderTransactionHash
    let expectedRLPEncodingForFeePayerSigning = FeeDelegatedSmartContractDeployTest.expectedRLPEncodingForFeePayerSigning
            
    public func test_getRLPEncodingForSignature() throws {
        mTxObj = try FeeDelegatedSmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertEqual(expectedRLPEncodingForFeePayerSigning, try mTxObj!.getRLPEncodingForFeePayerSignature())
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try FeeDelegatedSmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
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
        
        mTxObj = try FeeDelegatedSmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
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
        
        mTxObj = try FeeDelegatedSmartContractDeploy.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
            .setFeePayer(feePayer)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("chainId is undefined. Define chainId in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

