//
//  FeeDelegatedSmartContractDeployWithRatioTest.swift
//  CaverSwiftTests
//
//  Created by won on 2021/07/16.
//

import XCTest
@testable import CaverSwift

class FeeDelegatedSmartContractDeployWithRatioTest: XCTestCase {
    static let caver = Caver(Caver.DEFAULT_URL)
    
    static let privateKey = "0x45a915e4d060149eb4365960e6a7a45f334393093061116b197e3240065ff2d8"
    static let feePayerPrivateKey = "0xb9d5558443585bca6f225b935950e3f6e69f9da8a5809a83f51c3365dff53936"
    static let from = "0x294f5bc8fadbd1079b191d9c47e1f217d6c987b4"
    static let account = Account.createWithAccountKeyLegacy(from)
    static let to = "0x"
    static let gas = "0x493e0"
    static let gasPrice = "0x5d21dba00"
    static let nonce = "0xe"
    static let chainID = "0x7e3"
    static let value = "0x00"
    static let input = "0x608060405234801561001057600080fd5b506101de806100206000396000f3006080604052600436106100615763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416631a39d8ef81146100805780636353586b146100a757806370a08231146100ca578063fd6b7ef8146100f8575b3360009081526001602052604081208054349081019091558154019055005b34801561008c57600080fd5b5061009561010d565b60408051918252519081900360200190f35b6100c873ffffffffffffffffffffffffffffffffffffffff60043516610113565b005b3480156100d657600080fd5b5061009573ffffffffffffffffffffffffffffffffffffffff60043516610147565b34801561010457600080fd5b506100c8610159565b60005481565b73ffffffffffffffffffffffffffffffffffffffff1660009081526001602052604081208054349081019091558154019055565b60016020526000908152604090205481565b336000908152600160205260408120805490829055908111156101af57604051339082156108fc029083906000818181858888f193505050501561019c576101af565b3360009081526001602052604090208190555b505600a165627a7a72305820627ca46bb09478a015762806cc00c431230501118c7c26c30ac58c4e09e51c4f0029"
    static let humanReadable = false
    static let codeFormat = CodeFormat.EVM.hexa
    static let feeRatio = "0x1e"

    static let senderSignatureData = SignatureData(
        "0x0fe9",
        "0x8a20b415ae7cd642f7682e59b63cb81068723a18eb0d8d3ba58fa7545c4fc8a5",
        "0x5ba8a86f4496f124f04293d4b0afec85ab3946b039d1f6a25424217508df5867"
    )
    static let feePayer = "0xc56a1fafa968d64d19b4b81c306ecbab6e489743"
    static let feePayerSignatureData = SignatureData(
        "0x0fe9",
        "0xa525cba1b73cbe33b4df9be7165f8731b848ce3deba607690896eda8791a1a96",
        "0x5ea75b4da1b6744bb98bc2b9748d0eca5c47714ea1c09e26bebc5de386ff9958"
    )

    static let expectedRLPEncoding = "0x2af902cd0e8505d21dba00830493e0808094294f5bc8fadbd1079b191d9c47e1f217d6c987b4b901fe608060405234801561001057600080fd5b506101de806100206000396000f3006080604052600436106100615763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416631a39d8ef81146100805780636353586b146100a757806370a08231146100ca578063fd6b7ef8146100f8575b3360009081526001602052604081208054349081019091558154019055005b34801561008c57600080fd5b5061009561010d565b60408051918252519081900360200190f35b6100c873ffffffffffffffffffffffffffffffffffffffff60043516610113565b005b3480156100d657600080fd5b5061009573ffffffffffffffffffffffffffffffffffffffff60043516610147565b34801561010457600080fd5b506100c8610159565b60005481565b73ffffffffffffffffffffffffffffffffffffffff1660009081526001602052604081208054349081019091558154019055565b60016020526000908152604090205481565b336000908152600160205260408120805490829055908111156101af57604051339082156108fc029083906000818181858888f193505050501561019c576101af565b3360009081526001602052604090208190555b505600a165627a7a72305820627ca46bb09478a015762806cc00c431230501118c7c26c30ac58c4e09e51c4f0029801e80f847f845820fe9a08a20b415ae7cd642f7682e59b63cb81068723a18eb0d8d3ba58fa7545c4fc8a5a05ba8a86f4496f124f04293d4b0afec85ab3946b039d1f6a25424217508df586794c56a1fafa968d64d19b4b81c306ecbab6e489743f847f845820fe9a0a525cba1b73cbe33b4df9be7165f8731b848ce3deba607690896eda8791a1a96a05ea75b4da1b6744bb98bc2b9748d0eca5c47714ea1c09e26bebc5de386ff9958"
    static let expectedTransactionHash = "0x4f87bc437bc048f96f3a005fba82647a468bf1fde914fe60e3772192f929b58a"
    static let expectedRLPSenderTransactionHash = "0xa5fabe514d238298f8ed8ee1431bad33cd5d1349ffcedaf488f28474dfe62be2"
    static let expectedRLPEncodingForFeePayerSigning = "0xf90247b9022af902272a0e8505d21dba00830493e0808094294f5bc8fadbd1079b191d9c47e1f217d6c987b4b901fe608060405234801561001057600080fd5b506101de806100206000396000f3006080604052600436106100615763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416631a39d8ef81146100805780636353586b146100a757806370a08231146100ca578063fd6b7ef8146100f8575b3360009081526001602052604081208054349081019091558154019055005b34801561008c57600080fd5b5061009561010d565b60408051918252519081900360200190f35b6100c873ffffffffffffffffffffffffffffffffffffffff60043516610113565b005b3480156100d657600080fd5b5061009573ffffffffffffffffffffffffffffffffffffffff60043516610147565b34801561010457600080fd5b506100c8610159565b60005481565b73ffffffffffffffffffffffffffffffffffffffff1660009081526001602052604081208054349081019091558154019055565b60016020526000908152604090205481565b336000908152600160205260408120805490829055908111156101af57604051339082156108fc029083906000818181858888f193505050501561019c576101af565b3360009081526001602052604090208190555b505600a165627a7a72305820627ca46bb09478a015762806cc00c431230501118c7c26c30ac58c4e09e51c4f0029801e8094c56a1fafa968d64d19b4b81c306ecbab6e4897438207e38080"
        
    public static func generateRoleBaseKeyring(_ numArr: [Int], _ address: String) throws -> AbstractKeyring {
        let keyArr = KeyringFactory.generateRoleBasedKeys(numArr, "entropy")
        return try KeyringFactory.createWithRoleBasedKey(address, keyArr)
    }
}

class FeeDelegatedSmartContractDeployWithRatioTest_createInstanceBuilder: XCTestCase {
    let from = FeeDelegatedSmartContractDeployWithRatioTest.from
    let account = FeeDelegatedSmartContractDeployWithRatioTest.account
    let to = FeeDelegatedSmartContractDeployWithRatioTest.to
    let gas = FeeDelegatedSmartContractDeployWithRatioTest.gas
    let nonce = FeeDelegatedSmartContractDeployWithRatioTest.nonce
    let gasPrice = FeeDelegatedSmartContractDeployWithRatioTest.gasPrice
    let chainID = FeeDelegatedSmartContractDeployWithRatioTest.chainID
    let value = FeeDelegatedSmartContractDeployWithRatioTest.value
    let input = FeeDelegatedSmartContractDeployWithRatioTest.input
    let humanReadable = FeeDelegatedSmartContractDeployWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractDeployWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractDeployWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedSmartContractDeployWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractDeployWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedSmartContractDeployWithRatioTest.feeRatio
        
    public func test_BuilderTest() throws {
        let txObj = try FeeDelegatedSmartContractDeployWithRatio.Builder()
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
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertNotNil(txObj)
    }
    
    public func test_BuilderWithRPCTest() throws {
        let txObj = try FeeDelegatedSmartContractDeployWithRatio.Builder()
            .setKlaytnCall(FeeDelegatedSmartContractDeployWithRatioTest.caver.rpc.klay)
            .setGas(gas)
            .setFrom(from)
            .setValue(value)
            .setTo(to)
            .setInput(input)
            .setHumanReadable(humanReadable)
            .setCodeFormat(codeFormat)
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
        let txObj = try FeeDelegatedSmartContractDeployWithRatio.Builder()
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
            .setFeeRatio(feeRatio)
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
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeployWithRatio.Builder()
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
                                .setFeeRatio(feeRatio)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(from)"))
        }
    }
    
    public func test_throwException_missingFrom() throws {
        let from = ""
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeployWithRatio.Builder()
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
                                .setFeeRatio(feeRatio)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("from is missing."))
        }
    }
    
    public func test_throwException_invalidTo() throws {
        let to = "invalid input"
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeployWithRatio.Builder()
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
                                .setFeeRatio(feeRatio)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("'to' field must be nil('0x') : \(to)"))
        }
    }
    
    public func test_throwException_invalidValue() throws {
        let value = "invalid value"
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeployWithRatio.Builder()
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
                                .setFeeRatio(feeRatio)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid value : \(value)"))
        }
    }
    
    public func test_throwException_missingValue() throws {
        let value = ""
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeployWithRatio.Builder()
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
                                .setFeeRatio(feeRatio)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("value is missing."))
        }
    }
        
    public func test_throwException_invalidGas() throws {
        let gas = "invalid gas"
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeployWithRatio.Builder()
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
                                .setFeeRatio(feeRatio)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid gas. : \(gas)"))
        }
    }
    
    public func test_throwException_missingGas() throws {
        let gas = ""
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeployWithRatio.Builder()
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
                                .setFeeRatio(feeRatio)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("gas is missing."))
        }
    }
    
    public func test_throwException_setFeePayerSignatures_missingFeePayer() throws {
        let feePayer = ""
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeployWithRatio.Builder()
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
                                .setFeeRatio(feeRatio)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("feePayer is missing: feePayer must be defined with feePayerSignatures."))
        }
    }
    
    public func test_throwException_FeeRatio_invalid() throws {
        let feeRatio = "invalid fee ratio"
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeployWithRatio.Builder()
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
                                .setFeeRatio(feeRatio)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid type of feeRatio: feeRatio should be number type or hex number string"))
        }
    }
    
    public func test_throwException_FeeRatio_outOfRange() throws {
        let feeRatio = BigInt(101)
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeployWithRatio.Builder()
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
                                .setFeeRatio(feeRatio)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid feeRatio: feeRatio is out of range. [1,99]"))
        }
    }
    
    public func test_throwException_missingFeeRatio() throws {
        let feeRatio = ""
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeployWithRatio.Builder()
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
                                .setFeeRatio(feeRatio)
                                .setSignatures(senderSignatureData)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("feeRatio is missing."))
        }
    }
}

class FeeDelegatedSmartContractDeployWithRatioTest_createInstance: XCTestCase {
    let from = FeeDelegatedSmartContractDeployWithRatioTest.from
    let account = FeeDelegatedSmartContractDeployWithRatioTest.account
    let to = FeeDelegatedSmartContractDeployWithRatioTest.to
    let gas = FeeDelegatedSmartContractDeployWithRatioTest.gas
    let nonce = FeeDelegatedSmartContractDeployWithRatioTest.nonce
    let gasPrice = FeeDelegatedSmartContractDeployWithRatioTest.gasPrice
    let chainID = FeeDelegatedSmartContractDeployWithRatioTest.chainID
    let value = FeeDelegatedSmartContractDeployWithRatioTest.value
    let input = FeeDelegatedSmartContractDeployWithRatioTest.input
    let humanReadable = FeeDelegatedSmartContractDeployWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractDeployWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractDeployWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedSmartContractDeployWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractDeployWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedSmartContractDeployWithRatioTest.feeRatio
    
    public func test_createInstance() throws {
        let txObj = try FeeDelegatedSmartContractDeployWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            feeRatio,
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
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeployWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            feeRatio,
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
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeployWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            feeRatio,
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
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeployWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            feeRatio,
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
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeployWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            feeRatio,
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
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeployWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            feeRatio,
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
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeployWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            feeRatio,
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
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeployWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            feeRatio,
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
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeployWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            feeRatio,
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
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeployWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            feeRatio,
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
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeployWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            feeRatio,
            to,
            value,
            input,
            humanReadable,
            codeFormat
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("codeFormat is missing"))
        }
    }
    
    public func test_throwException_setFeePayerSignatures_missingFeePayer() throws {
        let feePayer = ""
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeployWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            feeRatio,
            to,
            value,
            input,
            humanReadable,
            codeFormat
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("feePayer is missing: feePayer must be defined with feePayerSignatures."))
        }
    }
    
    public func test_throwException_FeeRatio_invalid() throws {
        let feeRatio = "invalid fee ratio"
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeployWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            feeRatio,
            to,
            value,
            input,
            humanReadable,
            codeFormat
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid type of feeRatio: feeRatio should be number type or hex number string"))
        }
    }
    
    public func test_throwException_FeeRatio_outOfRange() throws {
        let feeRatio = BigInt(101).hexa
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeployWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            feeRatio,
            to,
            value,
            input,
            humanReadable,
            codeFormat
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid feeRatio: feeRatio is out of range. [1,99]"))
        }
    }
    
    public func test_throwException_missingFeeRatio() throws {
        let feeRatio = ""
        XCTAssertThrowsError(try FeeDelegatedSmartContractDeployWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            [senderSignatureData],
            feePayer,
            [feePayerSignatureData],
            feeRatio,
            to,
            value,
            input,
            humanReadable,
            codeFormat
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("feeRatio is missing."))
        }
    }
}

class FeeDelegatedSmartContractDeployWithRatioTest_getRLPEncodingTest: XCTestCase {
    let from = FeeDelegatedSmartContractDeployWithRatioTest.from
    let account = FeeDelegatedSmartContractDeployWithRatioTest.account
    let to = FeeDelegatedSmartContractDeployWithRatioTest.to
    let gas = FeeDelegatedSmartContractDeployWithRatioTest.gas
    let nonce = FeeDelegatedSmartContractDeployWithRatioTest.nonce
    let gasPrice = FeeDelegatedSmartContractDeployWithRatioTest.gasPrice
    let chainID = FeeDelegatedSmartContractDeployWithRatioTest.chainID
    let value = FeeDelegatedSmartContractDeployWithRatioTest.value
    let input = FeeDelegatedSmartContractDeployWithRatioTest.input
    let humanReadable = FeeDelegatedSmartContractDeployWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractDeployWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractDeployWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedSmartContractDeployWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractDeployWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedSmartContractDeployWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedSmartContractDeployWithRatioTest.expectedRLPEncoding
        
    public func test_getRLPEncoding() throws {
        let txObj = try FeeDelegatedSmartContractDeployWithRatio.Builder()
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
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertEqual(expectedRLPEncoding, try txObj.getRLPEncoding())
    }
    
    public func test_throwException_NoNonce() throws {
        let txObj = try FeeDelegatedSmartContractDeployWithRatio.Builder()
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
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertThrowsError(try txObj.getRLPEncoding()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NoGasPrice() throws {
        let txObj = try FeeDelegatedSmartContractDeployWithRatio.Builder()
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
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertThrowsError(try txObj.getRLPEncoding()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class FeeDelegatedSmartContractDeployWithRatioTest_signAsFeePayer_OneKeyTest: XCTestCase {
    var mTxObj: FeeDelegatedSmartContractDeployWithRatio?
    var klaytnWalletKey: String?
    var keyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedSmartContractDeployWithRatioTest.feePayerPrivateKey
    
    let from = FeeDelegatedSmartContractDeployWithRatioTest.from
    let account = FeeDelegatedSmartContractDeployWithRatioTest.account
    let to = FeeDelegatedSmartContractDeployWithRatioTest.to
    let gas = FeeDelegatedSmartContractDeployWithRatioTest.gas
    let nonce = FeeDelegatedSmartContractDeployWithRatioTest.nonce
    let gasPrice = FeeDelegatedSmartContractDeployWithRatioTest.gasPrice
    let chainID = FeeDelegatedSmartContractDeployWithRatioTest.chainID
    let value = FeeDelegatedSmartContractDeployWithRatioTest.value
    let input = FeeDelegatedSmartContractDeployWithRatioTest.input
    let humanReadable = FeeDelegatedSmartContractDeployWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractDeployWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractDeployWithRatioTest.senderSignatureData
    var feePayer = FeeDelegatedSmartContractDeployWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractDeployWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedSmartContractDeployWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedSmartContractDeployWithRatioTest.expectedRLPEncoding
        
    override func setUpWithError() throws {
        keyring = try KeyringFactory.createFromPrivateKey(feePayerPrivateKey)
        feePayer = keyring!.address
        
        mTxObj = try FeeDelegatedSmartContractDeployWithRatio.Builder()
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
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .build()
        
        klaytnWalletKey = try keyring?.getKlaytnWalletKey()
    }
    
    public func test_signAsFeePayer_String() throws {
        _ = try mTxObj!.signAsFeePayer(feePayerPrivateKey)
        XCTAssertEqual(1, mTxObj?.feePayerSignatures.count)
    }
    
    public func test_signAsFeePayer_KlaytnWalletKey() throws {
        _ = try mTxObj!.signAsFeePayer(klaytnWalletKey!)
        XCTAssertEqual(1, mTxObj?.feePayerSignatures.count)
    }
    
    public func test_signAsFeePayer_Keyring() throws {
        _ = try mTxObj!.signAsFeePayer(keyring!, 0, TransactionHasher.getHashForFeePayerSignature(_:))
        XCTAssertEqual(1, mTxObj?.feePayerSignatures.count)
    }
    
    public func test_signAsFeePayer_Keyring_NoSigner() throws {
        _ = try mTxObj!.signAsFeePayer(keyring!, 0)
        XCTAssertEqual(1, mTxObj?.feePayerSignatures.count)
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
        let roleBasedKeyring = try KeyringFactory.createWithRoleBasedKey(keyring!.address, keyArr)
        _ = try mTxObj!.signAsFeePayer(roleBasedKeyring, 1)
        XCTAssertEqual(1, mTxObj?.feePayerSignatures.count)
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

class FeeDelegatedSmartContractDeployWithRatioTest_signAsFeePayer_AllKeyTest: XCTestCase {
    var mTxObj: FeeDelegatedSmartContractDeployWithRatio?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedSmartContractDeployWithRatioTest.feePayerPrivateKey
    
    let from = FeeDelegatedSmartContractDeployWithRatioTest.from
    let account = FeeDelegatedSmartContractDeployWithRatioTest.account
    let to = FeeDelegatedSmartContractDeployWithRatioTest.to
    let gas = FeeDelegatedSmartContractDeployWithRatioTest.gas
    let nonce = FeeDelegatedSmartContractDeployWithRatioTest.nonce
    let gasPrice = FeeDelegatedSmartContractDeployWithRatioTest.gasPrice
    let chainID = FeeDelegatedSmartContractDeployWithRatioTest.chainID
    let value = FeeDelegatedSmartContractDeployWithRatioTest.value
    let input = FeeDelegatedSmartContractDeployWithRatioTest.input
    let humanReadable = FeeDelegatedSmartContractDeployWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractDeployWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractDeployWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedSmartContractDeployWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractDeployWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedSmartContractDeployWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedSmartContractDeployWithRatioTest.expectedRLPEncoding
        
    override func setUpWithError() throws {
        let feePayer = try KeyringFactory.createFromPrivateKey(feePayerPrivateKey).address
        
        mTxObj = try FeeDelegatedSmartContractDeployWithRatio.Builder()
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

class FeeDelegatedSmartContractDeployWithRatioTest_appendFeePayerSignaturesTest: XCTestCase {
    var mTxObj: FeeDelegatedSmartContractDeployWithRatio?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedSmartContractDeployWithRatioTest.feePayerPrivateKey
    
    let from = FeeDelegatedSmartContractDeployWithRatioTest.from
    let account = FeeDelegatedSmartContractDeployWithRatioTest.account
    let to = FeeDelegatedSmartContractDeployWithRatioTest.to
    let gas = FeeDelegatedSmartContractDeployWithRatioTest.gas
    let nonce = FeeDelegatedSmartContractDeployWithRatioTest.nonce
    let gasPrice = FeeDelegatedSmartContractDeployWithRatioTest.gasPrice
    let chainID = FeeDelegatedSmartContractDeployWithRatioTest.chainID
    let value = FeeDelegatedSmartContractDeployWithRatioTest.value
    let input = FeeDelegatedSmartContractDeployWithRatioTest.input
    let humanReadable = FeeDelegatedSmartContractDeployWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractDeployWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractDeployWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedSmartContractDeployWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractDeployWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedSmartContractDeployWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedSmartContractDeployWithRatioTest.expectedRLPEncoding
    
    override func setUpWithError() throws {
        mTxObj = try FeeDelegatedSmartContractDeployWithRatio.Builder()
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
        mTxObj = try FeeDelegatedSmartContractDeployWithRatio.Builder()
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
        
        mTxObj = try FeeDelegatedSmartContractDeployWithRatio.Builder()
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
        
        mTxObj = try FeeDelegatedSmartContractDeployWithRatio.Builder()
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

class FeeDelegatedSmartContractDeployWithRatioTest_combineSignatureTest: XCTestCase {
    var mTxObj: FeeDelegatedSmartContractDeployWithRatio?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedSmartContractDeployWithRatioTest.feePayerPrivateKey
    
    let from = "0x2b2043ef30fd370997404397156ccc8d4fe6c04a"
    let account = FeeDelegatedSmartContractDeployWithRatioTest.account
    let to = FeeDelegatedSmartContractDeployWithRatioTest.to
    let gas = "0x493e0"
    let nonce = "0x1"
    let gasPrice = "0x5d21dba00"
    let chainID = "0x7e3"
    let value = "0x0"
    let input = FeeDelegatedSmartContractDeployWithRatioTest.input
    let humanReadable = FeeDelegatedSmartContractDeployWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractDeployWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractDeployWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedSmartContractDeployWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractDeployWithRatioTest.feePayerSignatureData
    let feeRatio = "0x1E"
    
    let expectedRLPEncoding = FeeDelegatedSmartContractDeployWithRatioTest.expectedRLPEncoding
    
    override func setUpWithError() throws {
        mTxObj = try FeeDelegatedSmartContractDeployWithRatio.Builder()
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
            .setFeeRatio(feeRatio)
            .build()
    }
    
    public func test_combineSignature() throws {
        let expectedRLPEncoded = "0x2af90289018505d21dba00830493e08080942b2043ef30fd370997404397156ccc8d4fe6c04ab901fe608060405234801561001057600080fd5b506101de806100206000396000f3006080604052600436106100615763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416631a39d8ef81146100805780636353586b146100a757806370a08231146100ca578063fd6b7ef8146100f8575b3360009081526001602052604081208054349081019091558154019055005b34801561008c57600080fd5b5061009561010d565b60408051918252519081900360200190f35b6100c873ffffffffffffffffffffffffffffffffffffffff60043516610113565b005b3480156100d657600080fd5b5061009573ffffffffffffffffffffffffffffffffffffffff60043516610147565b34801561010457600080fd5b506100c8610159565b60005481565b73ffffffffffffffffffffffffffffffffffffffff1660009081526001602052604081208054349081019091558154019055565b60016020526000908152604090205481565b336000908152600160205260408120805490829055908111156101af57604051339082156108fc029083906000818181858888f193505050501561019c576101af565b3360009081526001602052604090208190555b505600a165627a7a72305820627ca46bb09478a015762806cc00c431230501118c7c26c30ac58c4e09e51c4f0029801e80f847f845820fe9a0f7c0b0d305325ae87e8d63aaa771312764931c7cf27bcd516218de5d48f63fc9a045226063f9a529afeefc10e2f0e5f5c1c551d8fb9ebb0e6cb88d6c62262e0cd2940000000000000000000000000000000000000000c4c3018080"
        
        let expectedSignature = SignatureData(
            "0x0fe9",
            "0xf7c0b0d305325ae87e8d63aaa771312764931c7cf27bcd516218de5d48f63fc9",
            "0x45226063f9a529afeefc10e2f0e5f5c1c551d8fb9ebb0e6cb88d6c62262e0cd2"
        )
        
        let rlpEncoded = "0x2af90289018505d21dba00830493e08080942b2043ef30fd370997404397156ccc8d4fe6c04ab901fe608060405234801561001057600080fd5b506101de806100206000396000f3006080604052600436106100615763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416631a39d8ef81146100805780636353586b146100a757806370a08231146100ca578063fd6b7ef8146100f8575b3360009081526001602052604081208054349081019091558154019055005b34801561008c57600080fd5b5061009561010d565b60408051918252519081900360200190f35b6100c873ffffffffffffffffffffffffffffffffffffffff60043516610113565b005b3480156100d657600080fd5b5061009573ffffffffffffffffffffffffffffffffffffffff60043516610147565b34801561010457600080fd5b506100c8610159565b60005481565b73ffffffffffffffffffffffffffffffffffffffff1660009081526001602052604081208054349081019091558154019055565b60016020526000908152604090205481565b336000908152600160205260408120805490829055908111156101af57604051339082156108fc029083906000818181858888f193505050501561019c576101af565b3360009081526001602052604090208190555b505600a165627a7a72305820627ca46bb09478a015762806cc00c431230501118c7c26c30ac58c4e09e51c4f0029801e80f847f845820fe9a0f7c0b0d305325ae87e8d63aaa771312764931c7cf27bcd516218de5d48f63fc9a045226063f9a529afeefc10e2f0e5f5c1c551d8fb9ebb0e6cb88d6c62262e0cd2940000000000000000000000000000000000000000c4c3018080"
        
        let combined = try mTxObj!.combineSignedRawTransactions([rlpEncoded])
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature, mTxObj?.signatures[0])
    }
    
    public func test_combine_multipleSignature() throws {
        let expectedRLPEncoded = "0x2af90317018505d21dba00830493e08080942b2043ef30fd370997404397156ccc8d4fe6c04ab901fe608060405234801561001057600080fd5b506101de806100206000396000f3006080604052600436106100615763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416631a39d8ef81146100805780636353586b146100a757806370a08231146100ca578063fd6b7ef8146100f8575b3360009081526001602052604081208054349081019091558154019055005b34801561008c57600080fd5b5061009561010d565b60408051918252519081900360200190f35b6100c873ffffffffffffffffffffffffffffffffffffffff60043516610113565b005b3480156100d657600080fd5b5061009573ffffffffffffffffffffffffffffffffffffffff60043516610147565b34801561010457600080fd5b506100c8610159565b60005481565b73ffffffffffffffffffffffffffffffffffffffff1660009081526001602052604081208054349081019091558154019055565b60016020526000908152604090205481565b336000908152600160205260408120805490829055908111156101af57604051339082156108fc029083906000818181858888f193505050501561019c576101af565b3360009081526001602052604090208190555b505600a165627a7a72305820627ca46bb09478a015762806cc00c431230501118c7c26c30ac58c4e09e51c4f0029801e80f8d5f845820fe9a0f7c0b0d305325ae87e8d63aaa771312764931c7cf27bcd516218de5d48f63fc9a045226063f9a529afeefc10e2f0e5f5c1c551d8fb9ebb0e6cb88d6c62262e0cd2f845820feaa04015d11ffebcc72ab8bb8b6a337e4121316d1f24cc421c958fcb5c49328603a4a00bb02ad934a105c0d9436f9a0d88b721f489d7e2b13cb7d5af4269bb3202b114f845820feaa06645f3dad39b1b9fbb533828cdc7100c67fccc8fec08d7867fe9667a65538cbba07ddbfc223f4377a78f0ee3d18263e31080faad8305132dcc5c17f1f093c9e9a2940000000000000000000000000000000000000000c4c3018080"
        
        let expectedSignature = [
            SignatureData(
                    "0x0fe9",
                    "0xf7c0b0d305325ae87e8d63aaa771312764931c7cf27bcd516218de5d48f63fc9",
                    "0x45226063f9a529afeefc10e2f0e5f5c1c551d8fb9ebb0e6cb88d6c62262e0cd2"
            ),
            SignatureData(
                    "0x0fea",
                    "0x4015d11ffebcc72ab8bb8b6a337e4121316d1f24cc421c958fcb5c49328603a4",
                    "0x0bb02ad934a105c0d9436f9a0d88b721f489d7e2b13cb7d5af4269bb3202b114"
            ),
            SignatureData(
                    "0x0fea",
                    "0x6645f3dad39b1b9fbb533828cdc7100c67fccc8fec08d7867fe9667a65538cbb",
                    "0x7ddbfc223f4377a78f0ee3d18263e31080faad8305132dcc5c17f1f093c9e9a2"
            )
        ]
        
        let rlpEncodedString = [
            "0x2af90275018505d21dba00830493e08080942b2043ef30fd370997404397156ccc8d4fe6c04ab901fe608060405234801561001057600080fd5b506101de806100206000396000f3006080604052600436106100615763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416631a39d8ef81146100805780636353586b146100a757806370a08231146100ca578063fd6b7ef8146100f8575b3360009081526001602052604081208054349081019091558154019055005b34801561008c57600080fd5b5061009561010d565b60408051918252519081900360200190f35b6100c873ffffffffffffffffffffffffffffffffffffffff60043516610113565b005b3480156100d657600080fd5b5061009573ffffffffffffffffffffffffffffffffffffffff60043516610147565b34801561010457600080fd5b506100c8610159565b60005481565b73ffffffffffffffffffffffffffffffffffffffff1660009081526001602052604081208054349081019091558154019055565b60016020526000908152604090205481565b336000908152600160205260408120805490829055908111156101af57604051339082156108fc029083906000818181858888f193505050501561019c576101af565b3360009081526001602052604090208190555b505600a165627a7a72305820627ca46bb09478a015762806cc00c431230501118c7c26c30ac58c4e09e51c4f0029801e80f847f845820feaa04015d11ffebcc72ab8bb8b6a337e4121316d1f24cc421c958fcb5c49328603a4a00bb02ad934a105c0d9436f9a0d88b721f489d7e2b13cb7d5af4269bb3202b11480c4c3018080",
            "0x2af90275018505d21dba00830493e08080942b2043ef30fd370997404397156ccc8d4fe6c04ab901fe608060405234801561001057600080fd5b506101de806100206000396000f3006080604052600436106100615763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416631a39d8ef81146100805780636353586b146100a757806370a08231146100ca578063fd6b7ef8146100f8575b3360009081526001602052604081208054349081019091558154019055005b34801561008c57600080fd5b5061009561010d565b60408051918252519081900360200190f35b6100c873ffffffffffffffffffffffffffffffffffffffff60043516610113565b005b3480156100d657600080fd5b5061009573ffffffffffffffffffffffffffffffffffffffff60043516610147565b34801561010457600080fd5b506100c8610159565b60005481565b73ffffffffffffffffffffffffffffffffffffffff1660009081526001602052604081208054349081019091558154019055565b60016020526000908152604090205481565b336000908152600160205260408120805490829055908111156101af57604051339082156108fc029083906000818181858888f193505050501561019c576101af565b3360009081526001602052604090208190555b505600a165627a7a72305820627ca46bb09478a015762806cc00c431230501118c7c26c30ac58c4e09e51c4f0029801e80f847f845820feaa06645f3dad39b1b9fbb533828cdc7100c67fccc8fec08d7867fe9667a65538cbba07ddbfc223f4377a78f0ee3d18263e31080faad8305132dcc5c17f1f093c9e9a280c4c3018080"
        ]
        
        let senderSignatureData = SignatureData(
            "0x0fe9",
            "0xf7c0b0d305325ae87e8d63aaa771312764931c7cf27bcd516218de5d48f63fc9",
            "0x45226063f9a529afeefc10e2f0e5f5c1c551d8fb9ebb0e6cb88d6c62262e0cd2"
        )
        
        mTxObj = try FeeDelegatedSmartContractDeployWithRatio.Builder()
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
        let expectedRLPEncoded = "0x2af90289018505d21dba00830493e08080942b2043ef30fd370997404397156ccc8d4fe6c04ab901fe608060405234801561001057600080fd5b506101de806100206000396000f3006080604052600436106100615763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416631a39d8ef81146100805780636353586b146100a757806370a08231146100ca578063fd6b7ef8146100f8575b3360009081526001602052604081208054349081019091558154019055005b34801561008c57600080fd5b5061009561010d565b60408051918252519081900360200190f35b6100c873ffffffffffffffffffffffffffffffffffffffff60043516610113565b005b3480156100d657600080fd5b5061009573ffffffffffffffffffffffffffffffffffffffff60043516610147565b34801561010457600080fd5b506100c8610159565b60005481565b73ffffffffffffffffffffffffffffffffffffffff1660009081526001602052604081208054349081019091558154019055565b60016020526000908152604090205481565b336000908152600160205260408120805490829055908111156101af57604051339082156108fc029083906000818181858888f193505050501561019c576101af565b3360009081526001602052604090208190555b505600a165627a7a72305820627ca46bb09478a015762806cc00c431230501118c7c26c30ac58c4e09e51c4f0029801e80c4c3018080941df7e797610fabf3b0aefb32b3df4f7cfff52b40f847f845820fe9a0c2d6fe5745e3a3a805dee9d6969efc60c58e8bba9368eed456ddad0347fa2597a01da449694111b286f9006fd9994fbb0ad3ce7298b33ff6e579748e653818e669"
        
        let expectedSignature = SignatureData(
            "0x0fe9",
            "0xc2d6fe5745e3a3a805dee9d6969efc60c58e8bba9368eed456ddad0347fa2597",
            "0x1da449694111b286f9006fd9994fbb0ad3ce7298b33ff6e579748e653818e669"
        )
        
        let rlpEncoded = "0x2af90289018505d21dba00830493e08080942b2043ef30fd370997404397156ccc8d4fe6c04ab901fe608060405234801561001057600080fd5b506101de806100206000396000f3006080604052600436106100615763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416631a39d8ef81146100805780636353586b146100a757806370a08231146100ca578063fd6b7ef8146100f8575b3360009081526001602052604081208054349081019091558154019055005b34801561008c57600080fd5b5061009561010d565b60408051918252519081900360200190f35b6100c873ffffffffffffffffffffffffffffffffffffffff60043516610113565b005b3480156100d657600080fd5b5061009573ffffffffffffffffffffffffffffffffffffffff60043516610147565b34801561010457600080fd5b506100c8610159565b60005481565b73ffffffffffffffffffffffffffffffffffffffff1660009081526001602052604081208054349081019091558154019055565b60016020526000908152604090205481565b336000908152600160205260408120805490829055908111156101af57604051339082156108fc029083906000818181858888f193505050501561019c576101af565b3360009081526001602052604090208190555b505600a165627a7a72305820627ca46bb09478a015762806cc00c431230501118c7c26c30ac58c4e09e51c4f0029801e80c4c3018080941df7e797610fabf3b0aefb32b3df4f7cfff52b40f847f845820fe9a0c2d6fe5745e3a3a805dee9d6969efc60c58e8bba9368eed456ddad0347fa2597a01da449694111b286f9006fd9994fbb0ad3ce7298b33ff6e579748e653818e669"
        
        let feePayer = "0x1df7e797610fabf3b0aefb32b3df4f7cfff52b40"
        
        mTxObj = try FeeDelegatedSmartContractDeployWithRatio.Builder()
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
            .setFeeRatio(feeRatio)
            .build()
        
        let combined = try mTxObj!.combineSignedRawTransactions([rlpEncoded])
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature, mTxObj?.feePayerSignatures[0])
    }
    
    public func test_combineSignature_multipleFeePayerSignature() throws {
        let expectedRLPEncoded = "0x2af90317018505d21dba00830493e08080942b2043ef30fd370997404397156ccc8d4fe6c04ab901fe608060405234801561001057600080fd5b506101de806100206000396000f3006080604052600436106100615763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416631a39d8ef81146100805780636353586b146100a757806370a08231146100ca578063fd6b7ef8146100f8575b3360009081526001602052604081208054349081019091558154019055005b34801561008c57600080fd5b5061009561010d565b60408051918252519081900360200190f35b6100c873ffffffffffffffffffffffffffffffffffffffff60043516610113565b005b3480156100d657600080fd5b5061009573ffffffffffffffffffffffffffffffffffffffff60043516610147565b34801561010457600080fd5b506100c8610159565b60005481565b73ffffffffffffffffffffffffffffffffffffffff1660009081526001602052604081208054349081019091558154019055565b60016020526000908152604090205481565b336000908152600160205260408120805490829055908111156101af57604051339082156108fc029083906000818181858888f193505050501561019c576101af565b3360009081526001602052604090208190555b505600a165627a7a72305820627ca46bb09478a015762806cc00c431230501118c7c26c30ac58c4e09e51c4f0029801e80c4c3018080941df7e797610fabf3b0aefb32b3df4f7cfff52b40f8d5f845820fe9a0c2d6fe5745e3a3a805dee9d6969efc60c58e8bba9368eed456ddad0347fa2597a01da449694111b286f9006fd9994fbb0ad3ce7298b33ff6e579748e653818e669f845820feaa01a875f02c07dfd8f1729b23183b17ec1072dc5b1f132bd4497e1a5834e1abf6fa0453b67bd7cce843aec8bcc64df6d9eed52f0efcaeab45366c11bcdd555768ccbf845820fe9a01ebfb413857294515eaf49db2ee050fbdda8a92fd413fb90671bd4b2f6a29f63a04a18a7423ea5210bda2753c57dbc8487909f126a01fd7577d5d48288c797bac7"
        
        let expectedSignature = [
            SignatureData(
                    "0x0fe9",
                    "0xc2d6fe5745e3a3a805dee9d6969efc60c58e8bba9368eed456ddad0347fa2597",
                    "0x1da449694111b286f9006fd9994fbb0ad3ce7298b33ff6e579748e653818e669"
            ),
            SignatureData(
                    "0x0fea",
                    "0x1a875f02c07dfd8f1729b23183b17ec1072dc5b1f132bd4497e1a5834e1abf6f",
                    "0x453b67bd7cce843aec8bcc64df6d9eed52f0efcaeab45366c11bcdd555768ccb"
            ),
            SignatureData(
                    "0x0fe9",
                    "0x1ebfb413857294515eaf49db2ee050fbdda8a92fd413fb90671bd4b2f6a29f63",
                    "0x4a18a7423ea5210bda2753c57dbc8487909f126a01fd7577d5d48288c797bac7"
            )
        ]
        
        let rlpEncodedString = [
            "0x2af90289018505d21dba00830493e08080942b2043ef30fd370997404397156ccc8d4fe6c04ab901fe608060405234801561001057600080fd5b506101de806100206000396000f3006080604052600436106100615763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416631a39d8ef81146100805780636353586b146100a757806370a08231146100ca578063fd6b7ef8146100f8575b3360009081526001602052604081208054349081019091558154019055005b34801561008c57600080fd5b5061009561010d565b60408051918252519081900360200190f35b6100c873ffffffffffffffffffffffffffffffffffffffff60043516610113565b005b3480156100d657600080fd5b5061009573ffffffffffffffffffffffffffffffffffffffff60043516610147565b34801561010457600080fd5b506100c8610159565b60005481565b73ffffffffffffffffffffffffffffffffffffffff1660009081526001602052604081208054349081019091558154019055565b60016020526000908152604090205481565b336000908152600160205260408120805490829055908111156101af57604051339082156108fc029083906000818181858888f193505050501561019c576101af565b3360009081526001602052604090208190555b505600a165627a7a72305820627ca46bb09478a015762806cc00c431230501118c7c26c30ac58c4e09e51c4f0029801e80c4c3018080941df7e797610fabf3b0aefb32b3df4f7cfff52b40f847f845820feaa01a875f02c07dfd8f1729b23183b17ec1072dc5b1f132bd4497e1a5834e1abf6fa0453b67bd7cce843aec8bcc64df6d9eed52f0efcaeab45366c11bcdd555768ccb",
            "0x2af90289018505d21dba00830493e08080942b2043ef30fd370997404397156ccc8d4fe6c04ab901fe608060405234801561001057600080fd5b506101de806100206000396000f3006080604052600436106100615763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416631a39d8ef81146100805780636353586b146100a757806370a08231146100ca578063fd6b7ef8146100f8575b3360009081526001602052604081208054349081019091558154019055005b34801561008c57600080fd5b5061009561010d565b60408051918252519081900360200190f35b6100c873ffffffffffffffffffffffffffffffffffffffff60043516610113565b005b3480156100d657600080fd5b5061009573ffffffffffffffffffffffffffffffffffffffff60043516610147565b34801561010457600080fd5b506100c8610159565b60005481565b73ffffffffffffffffffffffffffffffffffffffff1660009081526001602052604081208054349081019091558154019055565b60016020526000908152604090205481565b336000908152600160205260408120805490829055908111156101af57604051339082156108fc029083906000818181858888f193505050501561019c576101af565b3360009081526001602052604090208190555b505600a165627a7a72305820627ca46bb09478a015762806cc00c431230501118c7c26c30ac58c4e09e51c4f0029801e80c4c3018080941df7e797610fabf3b0aefb32b3df4f7cfff52b40f847f845820fe9a01ebfb413857294515eaf49db2ee050fbdda8a92fd413fb90671bd4b2f6a29f63a04a18a7423ea5210bda2753c57dbc8487909f126a01fd7577d5d48288c797bac7"
        ]
        
        let feePayer = "0x1df7e797610fabf3b0aefb32b3df4f7cfff52b40"
        let feePayerSignatureData = SignatureData(
            "0x0fe9",
            "0xc2d6fe5745e3a3a805dee9d6969efc60c58e8bba9368eed456ddad0347fa2597",
            "0x1da449694111b286f9006fd9994fbb0ad3ce7298b33ff6e579748e653818e669"
        )
        
        mTxObj = try FeeDelegatedSmartContractDeployWithRatio.Builder()
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
            .setFeeRatio(feeRatio)
            .build()
        
        let combined = try mTxObj!.combineSignedRawTransactions(rlpEncodedString)
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature[0], mTxObj?.feePayerSignatures[0])
        XCTAssertEqual(expectedSignature[1], mTxObj?.feePayerSignatures[1])
        XCTAssertEqual(expectedSignature[2], mTxObj?.feePayerSignatures[2])
    }
    
    public func test_multipleSignature_senderSignatureData_feePayerSignature() throws {
        mTxObj = try FeeDelegatedSmartContractDeployWithRatio.Builder()
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
            .setFeeRatio(feeRatio)
            .build()
        
        let rlpEncodedString = "0x2af90303018505d21dba00830493e08080942b2043ef30fd370997404397156ccc8d4fe6c04ab901fe608060405234801561001057600080fd5b506101de806100206000396000f3006080604052600436106100615763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416631a39d8ef81146100805780636353586b146100a757806370a08231146100ca578063fd6b7ef8146100f8575b3360009081526001602052604081208054349081019091558154019055005b34801561008c57600080fd5b5061009561010d565b60408051918252519081900360200190f35b6100c873ffffffffffffffffffffffffffffffffffffffff60043516610113565b005b3480156100d657600080fd5b5061009573ffffffffffffffffffffffffffffffffffffffff60043516610147565b34801561010457600080fd5b506100c8610159565b60005481565b73ffffffffffffffffffffffffffffffffffffffff1660009081526001602052604081208054349081019091558154019055565b60016020526000908152604090205481565b336000908152600160205260408120805490829055908111156101af57604051339082156108fc029083906000818181858888f193505050501561019c576101af565b3360009081526001602052604090208190555b505600a165627a7a72305820627ca46bb09478a015762806cc00c431230501118c7c26c30ac58c4e09e51c4f0029801e80f8d5f845820fe9a0f7c0b0d305325ae87e8d63aaa771312764931c7cf27bcd516218de5d48f63fc9a045226063f9a529afeefc10e2f0e5f5c1c551d8fb9ebb0e6cb88d6c62262e0cd2f845820feaa04015d11ffebcc72ab8bb8b6a337e4121316d1f24cc421c958fcb5c49328603a4a00bb02ad934a105c0d9436f9a0d88b721f489d7e2b13cb7d5af4269bb3202b114f845820feaa06645f3dad39b1b9fbb533828cdc7100c67fccc8fec08d7867fe9667a65538cbba07ddbfc223f4377a78f0ee3d18263e31080faad8305132dcc5c17f1f093c9e9a280c4c3018080"
        
        let expectedSignature = [
            SignatureData(
                    "0x0fe9",
                    "0xf7c0b0d305325ae87e8d63aaa771312764931c7cf27bcd516218de5d48f63fc9",
                    "0x45226063f9a529afeefc10e2f0e5f5c1c551d8fb9ebb0e6cb88d6c62262e0cd2"
            ),
            SignatureData(
                    "0x0fea",
                    "0x4015d11ffebcc72ab8bb8b6a337e4121316d1f24cc421c958fcb5c49328603a4",
                    "0x0bb02ad934a105c0d9436f9a0d88b721f489d7e2b13cb7d5af4269bb3202b114"
            ),
            SignatureData(
                    "0x0fea",
                    "0x6645f3dad39b1b9fbb533828cdc7100c67fccc8fec08d7867fe9667a65538cbb",
                    "0x7ddbfc223f4377a78f0ee3d18263e31080faad8305132dcc5c17f1f093c9e9a2"
            )
        ]
        
        _ = try mTxObj!.combineSignedRawTransactions([rlpEncodedString])
        
        let rlpEncodedStringsWithFeePayerSignatures = "0x2af90317018505d21dba00830493e08080942b2043ef30fd370997404397156ccc8d4fe6c04ab901fe608060405234801561001057600080fd5b506101de806100206000396000f3006080604052600436106100615763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416631a39d8ef81146100805780636353586b146100a757806370a08231146100ca578063fd6b7ef8146100f8575b3360009081526001602052604081208054349081019091558154019055005b34801561008c57600080fd5b5061009561010d565b60408051918252519081900360200190f35b6100c873ffffffffffffffffffffffffffffffffffffffff60043516610113565b005b3480156100d657600080fd5b5061009573ffffffffffffffffffffffffffffffffffffffff60043516610147565b34801561010457600080fd5b506100c8610159565b60005481565b73ffffffffffffffffffffffffffffffffffffffff1660009081526001602052604081208054349081019091558154019055565b60016020526000908152604090205481565b336000908152600160205260408120805490829055908111156101af57604051339082156108fc029083906000818181858888f193505050501561019c576101af565b3360009081526001602052604090208190555b505600a165627a7a72305820627ca46bb09478a015762806cc00c431230501118c7c26c30ac58c4e09e51c4f0029801e80c4c3018080941df7e797610fabf3b0aefb32b3df4f7cfff52b40f8d5f845820fe9a0c2d6fe5745e3a3a805dee9d6969efc60c58e8bba9368eed456ddad0347fa2597a01da449694111b286f9006fd9994fbb0ad3ce7298b33ff6e579748e653818e669f845820feaa01a875f02c07dfd8f1729b23183b17ec1072dc5b1f132bd4497e1a5834e1abf6fa0453b67bd7cce843aec8bcc64df6d9eed52f0efcaeab45366c11bcdd555768ccbf845820fe9a01ebfb413857294515eaf49db2ee050fbdda8a92fd413fb90671bd4b2f6a29f63a04a18a7423ea5210bda2753c57dbc8487909f126a01fd7577d5d48288c797bac7"
        
        let expectedFeePayerSignatures = [
            SignatureData(
                    "0x0fe9",
                    "0xc2d6fe5745e3a3a805dee9d6969efc60c58e8bba9368eed456ddad0347fa2597",
                    "0x1da449694111b286f9006fd9994fbb0ad3ce7298b33ff6e579748e653818e669"
            ),
            SignatureData(
                    "0x0fea",
                    "0x1a875f02c07dfd8f1729b23183b17ec1072dc5b1f132bd4497e1a5834e1abf6f",
                    "0x453b67bd7cce843aec8bcc64df6d9eed52f0efcaeab45366c11bcdd555768ccb"
            ),
            SignatureData(
                    "0x0fe9",
                    "0x1ebfb413857294515eaf49db2ee050fbdda8a92fd413fb90671bd4b2f6a29f63",
                    "0x4a18a7423ea5210bda2753c57dbc8487909f126a01fd7577d5d48288c797bac7"
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
        mTxObj = try FeeDelegatedSmartContractDeployWithRatio.Builder()
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
            .setFeeRatio(feeRatio)
            .build()
        
        let rlpEncoded = "0x2af90275018505d21dba00830493e08080942b2043ef30fd370997404397156ccc8d4fe6c04ab901fe608060405234801561001057600080fd5b506101de806100206000396000f3006080604052600436106100615763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416631a39d8ef81146100805780636353586b146100a757806370a08231146100ca578063fd6b7ef8146100f8575b3360009081526001602052604081208054349081019091558154019055005b34801561008c57600080fd5b5061009561010d565b60408051918252519081900360200190f35b6100c873ffffffffffffffffffffffffffffffffffffffff60043516610113565b005b3480156100d657600080fd5b5061009573ffffffffffffffffffffffffffffffffffffffff60043516610147565b34801561010457600080fd5b506100c8610159565b60005481565b73ffffffffffffffffffffffffffffffffffffffff1660009081526001602052604081208054349081019091558154019055565b60016020526000908152604090205481565b336000908152600160205260408120805490829055908111156101af57604051339082156108fc029083906000818181858888f193505050501561019c576101af565b3360009081526001602052604090208190555b505600a165627a7a72305820627ca46bb09478a015762806cc00c431230501118c7c26c30ac58c4e09e51c4f0029801e80f847f845820fe9a0f7c0b0d305325ae87e8d63aaa771312764931c7cf27bcd516218de5d48f63fc9a045226063f9a529afeefc10e2f0e5f5c1c551d8fb9ebb0e6cb88d6c62262e0cd280c4c3018080"
        
        XCTAssertThrowsError(try mTxObj!.combineSignedRawTransactions([rlpEncoded])) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("Transactions containing different information cannot be combined."))
        }
    }
}

class FeeDelegatedSmartContractDeployWithRatioTest_getRawTransactionTest: XCTestCase {
    var mTxObj: FeeDelegatedSmartContractDeployWithRatio?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedSmartContractDeployWithRatioTest.feePayerPrivateKey
    
    let from = FeeDelegatedSmartContractDeployWithRatioTest.from
    let account = FeeDelegatedSmartContractDeployWithRatioTest.account
    let to = FeeDelegatedSmartContractDeployWithRatioTest.to
    let gas = FeeDelegatedSmartContractDeployWithRatioTest.gas
    let nonce = FeeDelegatedSmartContractDeployWithRatioTest.nonce
    let gasPrice = FeeDelegatedSmartContractDeployWithRatioTest.gasPrice
    let chainID = FeeDelegatedSmartContractDeployWithRatioTest.chainID
    let value = FeeDelegatedSmartContractDeployWithRatioTest.value
    let input = FeeDelegatedSmartContractDeployWithRatioTest.input
    let humanReadable = FeeDelegatedSmartContractDeployWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractDeployWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractDeployWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedSmartContractDeployWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractDeployWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedSmartContractDeployWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedSmartContractDeployWithRatioTest.expectedRLPEncoding
    
    public func test_getRawTransaction() throws {
        let txObj = try FeeDelegatedSmartContractDeployWithRatio.Builder()
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
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()

        XCTAssertEqual(expectedRLPEncoding, try txObj.getRawTransaction())
    }
}

class FeeDelegatedSmartContractDeployWithRatioTest_getTransactionHashTest: XCTestCase {
    var mTxObj: FeeDelegatedSmartContractDeployWithRatio?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedSmartContractDeployWithRatioTest.feePayerPrivateKey
    
    let from = FeeDelegatedSmartContractDeployWithRatioTest.from
    let account = FeeDelegatedSmartContractDeployWithRatioTest.account
    let to = FeeDelegatedSmartContractDeployWithRatioTest.to
    let gas = FeeDelegatedSmartContractDeployWithRatioTest.gas
    let nonce = FeeDelegatedSmartContractDeployWithRatioTest.nonce
    let gasPrice = FeeDelegatedSmartContractDeployWithRatioTest.gasPrice
    let chainID = FeeDelegatedSmartContractDeployWithRatioTest.chainID
    let value = FeeDelegatedSmartContractDeployWithRatioTest.value
    let input = FeeDelegatedSmartContractDeployWithRatioTest.input
    let humanReadable = FeeDelegatedSmartContractDeployWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractDeployWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractDeployWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedSmartContractDeployWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractDeployWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedSmartContractDeployWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedSmartContractDeployWithRatioTest.expectedRLPEncoding
    let expectedTransactionHash = FeeDelegatedSmartContractDeployWithRatioTest.expectedTransactionHash
            
    public func test_getTransactionHash() throws {
        let txObj = try FeeDelegatedSmartContractDeployWithRatio.Builder()
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
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()

        XCTAssertEqual(expectedTransactionHash, try txObj.getTransactionHash())
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try FeeDelegatedSmartContractDeployWithRatio.Builder()
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
        
        mTxObj = try FeeDelegatedSmartContractDeployWithRatio.Builder()
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
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getTransactionHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class FeeDelegatedSmartContractDeployWithRatioTest_getSenderTxHashTest: XCTestCase {
    var mTxObj: FeeDelegatedSmartContractDeployWithRatio?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedSmartContractDeployWithRatioTest.feePayerPrivateKey
    
    let from = FeeDelegatedSmartContractDeployWithRatioTest.from
    let account = FeeDelegatedSmartContractDeployWithRatioTest.account
    let to = FeeDelegatedSmartContractDeployWithRatioTest.to
    let gas = FeeDelegatedSmartContractDeployWithRatioTest.gas
    let nonce = FeeDelegatedSmartContractDeployWithRatioTest.nonce
    let gasPrice = FeeDelegatedSmartContractDeployWithRatioTest.gasPrice
    let chainID = FeeDelegatedSmartContractDeployWithRatioTest.chainID
    let value = FeeDelegatedSmartContractDeployWithRatioTest.value
    let input = FeeDelegatedSmartContractDeployWithRatioTest.input
    let humanReadable = FeeDelegatedSmartContractDeployWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractDeployWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractDeployWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedSmartContractDeployWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractDeployWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedSmartContractDeployWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedSmartContractDeployWithRatioTest.expectedRLPEncoding
    let expectedTransactionHash = FeeDelegatedSmartContractDeployWithRatioTest.expectedTransactionHash
    let expectedSenderTransactionHash = FeeDelegatedSmartContractDeployWithRatioTest.expectedRLPSenderTransactionHash
            
    public func test_getRLPEncodingForSignature() throws {
        mTxObj = try FeeDelegatedSmartContractDeployWithRatio.Builder()
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
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertEqual(expectedSenderTransactionHash, try mTxObj!.getSenderTxHash())
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try FeeDelegatedSmartContractDeployWithRatio.Builder()
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
        
        mTxObj = try FeeDelegatedSmartContractDeployWithRatio.Builder()
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
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getSenderTxHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class FeeDelegatedSmartContractDeployWithRatioTest_getRLPEncodingForFeePayerSignatureTest: XCTestCase {
    var mTxObj: FeeDelegatedSmartContractDeployWithRatio?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
    
    let privateKey = PrivateKey.generate().privateKey
    let feePayerPrivateKey = FeeDelegatedSmartContractDeployWithRatioTest.feePayerPrivateKey
    
    let from = FeeDelegatedSmartContractDeployWithRatioTest.from
    let account = FeeDelegatedSmartContractDeployWithRatioTest.account
    let to = FeeDelegatedSmartContractDeployWithRatioTest.to
    let gas = FeeDelegatedSmartContractDeployWithRatioTest.gas
    let nonce = FeeDelegatedSmartContractDeployWithRatioTest.nonce
    let gasPrice = FeeDelegatedSmartContractDeployWithRatioTest.gasPrice
    let chainID = FeeDelegatedSmartContractDeployWithRatioTest.chainID
    let value = FeeDelegatedSmartContractDeployWithRatioTest.value
    let input = FeeDelegatedSmartContractDeployWithRatioTest.input
    let humanReadable = FeeDelegatedSmartContractDeployWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedSmartContractDeployWithRatioTest.codeFormat
    let senderSignatureData = FeeDelegatedSmartContractDeployWithRatioTest.senderSignatureData
    let feePayer = FeeDelegatedSmartContractDeployWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedSmartContractDeployWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedSmartContractDeployWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedSmartContractDeployWithRatioTest.expectedRLPEncoding
    let expectedTransactionHash = FeeDelegatedSmartContractDeployWithRatioTest.expectedTransactionHash
    let expectedSenderTransactionHash = FeeDelegatedSmartContractDeployWithRatioTest.expectedRLPSenderTransactionHash
    let expectedRLPEncodingForFeePayerSigning = FeeDelegatedSmartContractDeployWithRatioTest.expectedRLPEncodingForFeePayerSigning
            
    public func test_getRLPEncodingForSignature() throws {
        mTxObj = try FeeDelegatedSmartContractDeployWithRatio.Builder()
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
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertEqual(expectedRLPEncodingForFeePayerSigning, try mTxObj!.getRLPEncodingForFeePayerSignature())
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try FeeDelegatedSmartContractDeployWithRatio.Builder()
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
        
        mTxObj = try FeeDelegatedSmartContractDeployWithRatio.Builder()
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
        
        mTxObj = try FeeDelegatedSmartContractDeployWithRatio.Builder()
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
            .setFeeRatio(feeRatio)
            .setSignatures(senderSignatureData)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("chainId is undefined. Define chainId in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}
