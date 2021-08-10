//
//  RpcTest.swift
//  CaverSwiftTests
//
//  Created by won on 2021/07/29.
//

import XCTest
@testable import CaverSwift
@testable import GenericJSON

class RpcTest: XCTestCase {
    static let LOCAL_CHAIN_ID = 2019
    static let LOCAL_NETWORK_ID = 2018
    
    static let caver = Caver(Caver.DEFAULT_URL)
    static let klay = caver.rpc.klay
    static let rpc = caver.rpc
    static var kip17: KIP17? = nil

    public static func importKey(_ privateKey: String, _ password: String) {
        _ = RPC.Request("personal_importRawKey",
                        [privateKey, password],
                        rpc,
                        Bytes20.self)?
            .send()
    }
    
    public static func unlockAccount(_ address: String, _ password: String) {
        _ = RPC.Request("personal_unlockAccount",
                        [address, password],
                        rpc,
                        Bool.self)?
            .send()
    }

    public static func deployContract() throws {
        let caver = Caver(Caver.DEFAULT_URL)
        _ = try caver.wallet.add(try KeyringFactory.createFromPrivateKey("0x2359d1ae7317c01532a58b01452476b796a3ac713336e97d8d3c9651cc0aecc3"))
        
        let kip7DeployParam = KIP17DeployParams("CONTRACT_NAME", "CONTRACT_SYMBOL")
        kip17 = try KIP17.deploy(caver, kip7DeployParam, TestAccountInfo.LUMAN.address)
    }
}

class RpcTest_encodeAccountKeyTest: XCTestCase {
    func test_withAccountKeyNil() throws {
        let expected = "0x80"
        let (_, result) = RpcTest.klay.encodeAccountKey(AccountKeyNil())
        
        XCTAssertEqual(expected, result?.toValue)
    }
    
    func test_withAccountKeyFail() throws {
        let expected = "0x03c0"
        let (_, result) = RpcTest.klay.encodeAccountKey(AccountKeyFail())
        
        XCTAssertEqual(expected, result?.toValue)
    }
    
    func test_withAccountKeyLegacy() throws {
        let expected = "0x01c0"
        let (_, result) = RpcTest.klay.encodeAccountKey(AccountKeyLegacy())
        
        XCTAssertEqual(expected, result?.toValue)
    }
    
    func test_withAccountKeyPublic() throws {
        let expected = "0x02a102dbac81e8486d68eac4e6ef9db617f7fbd79a04a3b323c982a09cdfc61f0ae0e8"
        
        let x = "0xdbac81e8486d68eac4e6ef9db617f7fbd79a04a3b323c982a09cdfc61f0ae0e8"
        let y = "0x906d7170ba349c86879fb8006134cbf57bda9db9214a90b607b6b4ab57fc026e"
        let (_, result) = RpcTest.klay.encodeAccountKey(try AccountKeyPublic.fromXYPoint(x, y))
        
        XCTAssertEqual(expected, result?.toValue)
    }
    
    func test_withAccountKeyWeightedMultiSig() throws {
        let expected = "0x04f84b02f848e301a102c10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9e301a1021769a9196f523c419be50c26419ebbec34d3d6aa8b59da834212f13dbec9a9c1"
        
        let (_, result) = RpcTest.klay.encodeAccountKey(try AccountKeyWeightedMultiSig.decode(expected))
        
        XCTAssertEqual(expected, result?.toValue)
    }
    
    func test_withAccountKeyRoleBased() throws {
        let expected = "0x05f8c4a302a1036250dad4985bc22c8b9b84d1a05624c4daa0e83c8ae8fb35702d9024a8c14a71b84e04f84b02f848e301a102c10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9e301a1021769a9196f523c419be50c26419ebbec34d3d6aa8b59da834212f13dbec9a9c1b84e04f84b01f848e301a103e7615d056e770b3262e5b39a4823c3124989924ed4dcfab13f10b252701540d4e301a1036f21d60c16200d99e6777422470b3122b65850d5135a5a4b41344a5607a1446d"
        
        let (_, result) = RpcTest.klay.encodeAccountKey(try AccountKeyRoleBased.decode(expected))
        
        XCTAssertEqual(expected, result?.toValue)
    }
}

class RpcTest_decodeAccountKeyTest: XCTestCase {
    func test_withAccountKeyNil() throws {
        let encodedStr = "0x80"
        let (_, result) = RpcTest.klay.decodeAccountKey(encodedStr)
        
        XCTAssertTrue(result?.accountKey is AccountKeyNil)
    }
    
    func test_withAccountKeyFail() throws {
        let encodedStr = "0x03c0"
        let (_, result) = RpcTest.klay.decodeAccountKey(encodedStr)
        
        XCTAssertTrue(result?.accountKey is AccountKeyFail)
    }
    
    func test_withAccountKeyLegacy() throws {
        let encodedStr = "0x01c0"
        let (_, result) = RpcTest.klay.decodeAccountKey(encodedStr)
        
        XCTAssertTrue(result?.accountKey is AccountKeyLegacy)
    }
    
    func test_withAccountKeyPublic() throws {
        let encodedStr = "0x02a102dbac81e8486d68eac4e6ef9db617f7fbd79a04a3b323c982a09cdfc61f0ae0e8"
        let (_, result) = RpcTest.klay.decodeAccountKey(encodedStr)
        
        XCTAssertTrue(result?.accountKey is AccountKeyPublic)
        XCTAssertEqual(encodedStr, try result?.accountKey.getRLPEncoding())
    }
    
    func test_withAccountKeyWeightedMultiSig() throws {
        let encodedStr = "0x04f84b02f848e301a102c10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9e301a1021769a9196f523c419be50c26419ebbec34d3d6aa8b59da834212f13dbec9a9c1"
        let (_, result) = RpcTest.klay.decodeAccountKey(encodedStr)
        
        XCTAssertTrue(result?.accountKey is AccountKeyWeightedMultiSig)
        XCTAssertEqual(encodedStr, try result?.accountKey.getRLPEncoding())
    }
    
    func test_withAccountKeyRoleBased() throws {
        let encodedStr = "0x05f8c4a302a1036250dad4985bc22c8b9b84d1a05624c4daa0e83c8ae8fb35702d9024a8c14a71b84e04f84b02f848e301a102c10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9e301a1021769a9196f523c419be50c26419ebbec34d3d6aa8b59da834212f13dbec9a9c1b84e04f84b01f848e301a103e7615d056e770b3262e5b39a4823c3124989924ed4dcfab13f10b252701540d4e301a1036f21d60c16200d99e6777422470b3122b65850d5135a5a4b41344a5607a1446d"
        let (_, result) = RpcTest.klay.decodeAccountKey(encodedStr)
        
        XCTAssertTrue(result?.accountKey is AccountKeyRoleBased)
        XCTAssertEqual(encodedStr, try result?.accountKey.getRLPEncoding())
    }
}

class RpcTest_signTransactionTest: XCTestCase {
    static let klayProvider = "871ccee7755bb4247e783110cafa6437f9f593a1eaeebe0efcc1b0852282c3e5"
    static let klayProviderKeyring = try! KeyringFactory.createFromPrivateKey(klayProvider)
    
    override func setUpWithError() throws {
        RpcTest.importKey(RpcTest_signTransactionTest.klayProvider, "mypassword")
        RpcTest.unlockAccount(RpcTest_signTransactionTest.klayProviderKeyring.address, "mypassword")
    }
    
    func test_valueTransferTest() throws {
        let to = "0x7b65B75d204aBed71587c9E519a89277766EE1d0"
        let gas = "0xf4240"
        let gasPrice = "0x19"
        var nonce = ""
        let value = "0xa"
        
        nonce = (RpcTest.klay.getTransactionCount(RpcTest_signTransactionTest.klayProviderKeyring.address, .Pending).result?.toString)!
        let chainId = (RpcTest.klay.getChainID().result?.toString)!

        let valueTransfer = try ValueTransfer.Builder()
                .setFrom(RpcTest_signTransactionTest.klayProviderKeyring.address)
                .setTo(to)
                .setGas(gas)
                .setGasPrice(gasPrice)
                .setChainId(chainId)
                .setNonce(nonce)
                .setValue(value)
                .build()

        _ = try valueTransfer.sign(RpcTest_signTransactionTest.klayProviderKeyring)

        let signTransaction = RpcTest.klay.signTransaction(valueTransfer).result
        
        XCTAssertEqual(signTransaction?.raw, try valueTransfer.getRLPEncoding())
    }
}

class RpcTest_signTransactionAsFeePayerTest: XCTestCase {
    static let klayProvider = "871ccee7755bb4247e783110cafa6437f9f593a1eaeebe0efcc1b0852282c3e5"
    static let feePayer = "1e558ea00698990d875cb69d3c8f9a234fe8eab5c6bd898488d851669289e178"
    static let klayProviderKeyring = try! KeyringFactory.createFromPrivateKey(klayProvider)
    static let feePayerKeyring = try! KeyringFactory.createFromPrivateKey(feePayer)
    
    override func setUpWithError() throws {
        RpcTest.importKey(RpcTest_signTransactionAsFeePayerTest.klayProvider, "mypassword")
        RpcTest.importKey(RpcTest_signTransactionAsFeePayerTest.feePayer, "mypassword")
        RpcTest.unlockAccount(RpcTest_signTransactionAsFeePayerTest.klayProviderKeyring.address, "mypassword")
        RpcTest.unlockAccount(RpcTest_signTransactionAsFeePayerTest.feePayerKeyring.address, "mypassword")
        
        let caver = Caver(Caver.DEFAULT_URL)
        
        let valueTransfer = try ValueTransfer.Builder()
            .setKlaytnCall(caver.rpc.klay)
            .setFrom(RpcTest_signTransactionAsFeePayerTest.klayProviderKeyring.address)
            .setTo(RpcTest_signTransactionAsFeePayerTest.feePayerKeyring.address)
            .setValue(BigInt(Utils.convertToPeb("100", .KLAY))!)
            .setGas("0xf4240")
            .build()

        _ = try valueTransfer.sign(RpcTest_signTransactionTest.klayProviderKeyring)
        _ = try RpcTest.klay.sendRawTransaction(valueTransfer.getRawTransaction())
    }
    
    func test_feeDelegatedValueTransferTest() throws {
        let to = "0x7b65B75d204aBed71587c9E519a89277766EE1d0"
        let gas = "0xf4240"
        let gasPrice = "0x19"
        var nonce = ""
        let value = "0xa"
        
        nonce = (RpcTest.klay.getTransactionCount(RpcTest_signTransactionAsFeePayerTest.klayProviderKeyring.address, .Pending).result?.toString)!
        let chainId = (RpcTest.klay.getChainID().result?.toString)!

        let valueTransfer = try FeeDelegatedValueTransfer.Builder()
            .setFrom(RpcTest_signTransactionAsFeePayerTest.klayProviderKeyring.address)
            .setTo(to)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setNonce(nonce)
            .setValue(value)
            .setChainId(chainId)
            .setFeePayer(RpcTest_signTransactionAsFeePayerTest.feePayerKeyring.address)
            .build()

        _ = try valueTransfer.signAsFeePayer(RpcTest_signTransactionAsFeePayerTest.feePayerKeyring)

        let signTransaction = RpcTest.klay.signTransactionAsFeePayer(valueTransfer).result
        
        XCTAssertEqual(signTransaction?.raw, try valueTransfer.getRLPEncoding())
    }
    
    func test_feeDelegatedValueTransferFeeRatioTest() throws {
        let to = "0x7b65B75d204aBed71587c9E519a89277766EE1d0"
        let gas = "0xf4240"
        let gasPrice = "0x19"
        var nonce = ""
        let value = "0xa"
        let feeRatio = BigInt(30)
        
        nonce = (RpcTest.klay.getTransactionCount(RpcTest_signTransactionAsFeePayerTest.klayProviderKeyring.address, .Pending).result?.toString)!
        let chainId = (RpcTest.klay.getChainID().result?.toString)!

        let valueTransfer = try FeeDelegatedValueTransferWithRatio.Builder()
            .setFrom(RpcTest_signTransactionAsFeePayerTest.klayProviderKeyring.address)
            .setTo(to)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setNonce(nonce)
            .setValue(value)
            .setChainId(chainId)
            .setFeePayer(RpcTest_signTransactionAsFeePayerTest.feePayerKeyring.address)
            .setFeeRatio(feeRatio)
            .build()

        _ = try valueTransfer.signAsFeePayer(RpcTest_signTransactionAsFeePayerTest.feePayerKeyring)

        let signTransaction = RpcTest.klay.signTransactionAsFeePayer(valueTransfer).result
        
        XCTAssertEqual(signTransaction?.raw, try valueTransfer.getRLPEncoding())
    }
}

class RpcTest_sendTransactionAsFeePayerTest: XCTestCase {
    static let klayProvider = "871ccee7755bb4247e783110cafa6437f9f593a1eaeebe0efcc1b0852282c3e5"
    static let feePayer = "1e558ea00698990d875cb69d3c8f9a234fe8eab5c6bd898488d851669289e178"
    static let klayProviderKeyring = try! KeyringFactory.createFromPrivateKey(klayProvider)
    static let feePayerKeyring = try! KeyringFactory.createFromPrivateKey(feePayer)
    
    override func setUpWithError() throws {
        RpcTest.importKey(RpcTest_signTransactionAsFeePayerTest.klayProvider, "mypassword")
        RpcTest.importKey(RpcTest_signTransactionAsFeePayerTest.feePayer, "mypassword")
        RpcTest.unlockAccount(RpcTest_signTransactionAsFeePayerTest.klayProviderKeyring.address, "mypassword")
        RpcTest.unlockAccount(RpcTest_signTransactionAsFeePayerTest.feePayerKeyring.address, "mypassword")
        
        let caver = Caver(Caver.DEFAULT_URL)
        
        let valueTransfer = try ValueTransfer.Builder()
            .setKlaytnCall(caver.rpc.klay)
            .setFrom(RpcTest_signTransactionAsFeePayerTest.klayProviderKeyring.address)
            .setTo(RpcTest_signTransactionAsFeePayerTest.feePayerKeyring.address)
            .setValue(BigInt(Utils.convertToPeb("100", .KLAY))!)
            .setGas("0xf4240")
            .build()

        _ = try valueTransfer.sign(RpcTest_signTransactionTest.klayProviderKeyring)
        let txHash = try RpcTest.klay.sendRawTransaction(valueTransfer.getRawTransaction()).result!
        for _ in (1..<30) {
            let transactionReceipt = RpcTest.klay.getTransactionReceipt(txHash.toValue).result
            if transactionReceipt == nil {
                sleep(1)
            } else {
                break
            }
        }
    }
    
    func test_feeDelegatedValueTransferTest() throws {
        let to = "0x7b65B75d204aBed71587c9E519a89277766EE1d0"
        let gas = BigUInt(350000).hexa
        var gasPrice = "0x19"
        var nonce = ""
        let value = "0xa"
        
        nonce = (RpcTest.klay.getTransactionCount(RpcTest_signTransactionAsFeePayerTest.klayProviderKeyring.address, .Pending).result?.toString)!
        gasPrice = (RpcTest.klay.getGasPrice().result?.toString)!
        let chainId = (RpcTest.klay.getChainID().result?.toString)!

        let valueTransfer = try FeeDelegatedValueTransfer.Builder()
            .setFrom(RpcTest_signTransactionAsFeePayerTest.klayProviderKeyring.address)
            .setTo(to)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setNonce(nonce)
            .setValue(value)
            .setChainId(chainId)
            .setFeePayer(RpcTest_signTransactionAsFeePayerTest.feePayerKeyring.address)
            .build()

        _ = try valueTransfer.sign(RpcTest_signTransactionAsFeePayerTest.klayProviderKeyring)
        let transactionHash = RpcTest.klay.sendTransactionAsFeePayer(valueTransfer).result

        _ = try valueTransfer.signAsFeePayer(RpcTest_signTransactionAsFeePayerTest.feePayerKeyring)
        
        XCTAssertEqual(transactionHash?.toValue, try valueTransfer.getTransactionHash())
    }
    
    func test_feeDelegatedValueTransferFeeRatioTest() throws {
        let to = "0x7b65B75d204aBed71587c9E519a89277766EE1d0"
        let gas = BigUInt(550000).hexa
        var gasPrice = "0x19"
        var nonce = ""
        let value = "0xa"
        let feeRatio = BigInt(30)
        
        nonce = (RpcTest.klay.getTransactionCount(RpcTest_signTransactionAsFeePayerTest.klayProviderKeyring.address, .Pending).result?.toString)!
        gasPrice = (RpcTest.klay.getGasPrice().result?.toString)!
        let chainId = (RpcTest.klay.getChainID().result?.toString)!

        let valueTransfer = try FeeDelegatedValueTransferWithRatio.Builder()
            .setFrom(RpcTest_signTransactionAsFeePayerTest.klayProviderKeyring.address)
            .setTo(to)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setNonce(nonce)
            .setValue(value)
            .setChainId(chainId)
            .setFeePayer(RpcTest_signTransactionAsFeePayerTest.feePayerKeyring.address)
            .setFeeRatio(feeRatio)
            .build()

        _ = try valueTransfer.sign(RpcTest_signTransactionAsFeePayerTest.klayProviderKeyring)
        let transactionHash = RpcTest.klay.sendTransactionAsFeePayer(valueTransfer).result

        _ = try valueTransfer.signAsFeePayer(RpcTest_signTransactionAsFeePayerTest.feePayerKeyring)
        
        XCTAssertEqual(transactionHash?.toValue, try valueTransfer.getTransactionHash())
    }
}

class RpcTest_getAccountKeyTest: XCTestCase {
    func test_getAccountKeyResponseTest() throws {
        let testData = "{\"jsonrpc\":\"2.0\",\"id\":8,\"result\":{\"keyType\":2,\"key\":{\"x\":\"0x125b54c0500b2090d9b7504b010d5ee83962f19ca36cf592d5a798d7bc6d94d0\",\"y\":\"0x74dc3e8e8e7def04087010717522f3f1bbebb56c3030fa55853d05c435227cf\"}}}".data(using: .utf8)!
        
        let account = try JSONDecoder().decode(JSONRPCResult<AccountKey>.self, from:testData).result
        XCTAssertEqual("0x125b54c0500b2090d9b7504b010d5ee83962f19ca36cf592d5a798d7bc6d94d0074dc3e8e8e7def04087010717522f3f1bbebb56c3030fa55853d05c435227cf", (account.accountKey as? AccountKeyPublic)?.publicKey)
    }
}

class RpcTest_otherRPCTest: XCTestCase {
    var sampleReceiptData: TransactionReceipt?
    
    static func sendKlay() throws -> TransactionReceipt {
        let caver = Caver(Caver.DEFAULT_URL)
        let keyring = try caver.wallet.add(KeyringFactory.createFromPrivateKey("0x871ccee7755bb4247e783110cafa6437f9f593a1eaeebe0efcc1b0852282c3e5"))
        
        let value = BigInt(Utils.convertToPeb(BigInt(1), .KLAY))!
        
        let valueTransfer = try ValueTransfer.Builder()
            .setKlaytnCall(caver.rpc.klay)
            .setFrom(keyring.address)
            .setTo("0x8084fed6b1847448c24692470fc3b2ed87f9eb47")
            .setValue(value)
            .setGas(BigInt(25000))
            .build()

        _ = try valueTransfer.sign(keyring)
        
        let (error, result) = try RpcTest.klay.sendRawTransaction(valueTransfer.getRawTransaction())
        if let error = error {
            throw error
        }
        let transactionReceiptProcessor = PollingTransactionReceiptProcessor(caver, 1000, 15)
        let transactionReceipt = try transactionReceiptProcessor.waitForTransactionReceipt(result!.toValue)
        return transactionReceipt
    }
    
    override func setUpWithError() throws {
        if RpcTest.kip17 == nil {
            try RpcTest.deployContract()
        }
        
        if sampleReceiptData == nil {
            sampleReceiptData = try RpcTest_otherRPCTest.sendKlay()
        }
    }
    
    func test_IsAccountCreated() throws {
        let response = RpcTest.caver.rpc.klay.accountCreated(
            TestAccountInfo.LUMAN.address,
            .Latest)
        
        XCTAssertTrue(response.result!)
    }
    
    func test_getAccountTest() throws {
        let caver = Caver(Caver.DEFAULT_URL)
        
        let EOA_account = caver.rpc.klay.getAccount(TestAccountInfo.LUMAN.address)
        XCTAssertEqual(IAccountType.AccType.EOA.accType, EOA_account.result?.accType)
        
        let SCA_account = caver.rpc.klay.getAccount((RpcTest.kip17?.contractAddress)!)
        XCTAssertEqual(IAccountType.AccType.SCA.accType, SCA_account.result?.accType)
    }
    
    func test_getAccountKeyTest() throws {
        let caver = Caver(Caver.DEFAULT_URL)
        let accountKey = caver.rpc.klay.getAccountKey(TestAccountInfo.LUMAN.address).result
        
        XCTAssertNotNil(accountKey)
    }
    
    func test_getBalanceTest() throws {
        let quantity = RpcTest.caver.rpc.klay.getBalance(TestAccountInfo.LUMAN.address).result
        
        XCTAssertNotNil(quantity)
    }
    
    func test_getCodeTest() throws {
        let code = RpcTest.caver.rpc.klay.getCode((RpcTest.kip17?.contractAddress)!).result
        
        XCTAssertNotNil(code)
    }
    
    func test_getTransactionCountTest() throws {
        let response = RpcTest.caver.rpc.klay.getTransactionCount(TestAccountInfo.LUMAN.address, .Latest).result
        
        XCTAssertNotNil(response)
    }
    
    func test_isContractAccountTest() throws {
        let result = RpcTest.caver.rpc.klay.isContractAccount((RpcTest.kip17?.contractAddress)!).result
        
        XCTAssertTrue(result!)
    }
    
    func test_getBlockNumberTest() throws {
        let result = RpcTest.caver.rpc.klay.getBlockNumber().result
        
        XCTAssertNotNil(result)
    }
    
    func test_getBlockByHashTest() throws {
        var response = RpcTest.caver.rpc.klay.getBlockByNumber(.Latest, true).result
        var responseByHash = RpcTest.caver.rpc.klay.getBlockByHash(response!.hash, true).result
        XCTAssertEqual(response?.hash, responseByHash?.hash)
        
        response = RpcTest.caver.rpc.klay.getBlockByNumber(.Latest, false).result
        responseByHash = RpcTest.caver.rpc.klay.getBlockByHash(response!.hash, false).result
        XCTAssertEqual(response?.hash, responseByHash?.hash)
    }
    
    func test_getBlockReceiptsTest() throws {
        let blockReceipts = RpcTest.caver.rpc.klay.getBlockReceipts((sampleReceiptData?.blockHash)!).result
        
        XCTAssertEqual(sampleReceiptData?.blockHash, blockReceipts?[0].blockHash)
    }
    
    func test_getTransactionCountByNumberTest() throws {
        let response = RpcTest.caver.rpc.klay.getBlockByNumber(.Latest, true).result
        let responseByNumber = RpcTest.caver.rpc.klay.getTransactionCountByNumber(DefaultBlockParameterName.Number(Int(hex: response!.number)!)).result
        XCTAssertEqual(response?.transactions.count, responseByNumber?.intValue)
    }
    
    func test_getTransactionCountByHash() throws {
        let response = RpcTest.caver.rpc.klay.getBlockByNumber(.Latest, true).result
        let responseByHash = RpcTest.caver.rpc.klay.getTransactionCountByHash((response?.hash)!).result
        XCTAssertEqual(response?.transactions.count, responseByHash?.intValue)
    }
    
    func test_getBlockWithConsensusInfoByHashTest() throws {
        let response = RpcTest.caver.rpc.klay.getBlockByNumber(.Latest, true).result
        let responseByHash = RpcTest.caver.rpc.klay.getBlockWithConsensusInfoByHash((response?.hash)!).result
        XCTAssertEqual(response?.hash, responseByHash?.hash)
    }
    
    func test_getBlockWithConsensusInfoByNumberTest() throws {
        let response = RpcTest.caver.rpc.klay.getBlockByNumber(.Latest, true).result
        let responseByHash = RpcTest.caver.rpc.klay.getBlockWithConsensusInfoByNumber(DefaultBlockParameterName.Number(Int(hex: response!.number)!)).result
        XCTAssertEqual(response?.number, responseByHash?.number)
    }
    
    func test_getCommitteeTest() throws {
        let result = RpcTest.caver.rpc.klay.getCommittee(.Latest).result
        
        XCTAssertNotNil(result)
    }
    
    func test_getCommitteeSizeTest() throws {
        let result = RpcTest.caver.rpc.klay.getCommitteeSize(.Latest).result
        
        XCTAssertNotNil(result)
    }
    
    func test_getCouncilTest() throws {
        let result = RpcTest.caver.rpc.klay.getCouncil(.Latest).result
        
        XCTAssertNotNil(result)
    }
    
    func test_getCouncilSizeTest() throws {
        let result = RpcTest.caver.rpc.klay.getCouncilSize(.Latest).result
        
        XCTAssertNotNil(result)
    }
    
    func test_getStorageAtTest() throws {
        let result = RpcTest.caver.rpc.klay.getStorageAt(TestAccountInfo.LUMAN.address,
                                                         DefaultBlockParameterName.Number(0),
                                                         .Latest).result
        
        XCTAssertNotNil(result)
    }
    
    func test_isSyncingTest() throws {
        let result = RpcTest.caver.rpc.klay.isSyncing().result
        
        XCTAssertNotNil(result)
    }
    
    func test_estimateGasTest() throws {
        let encoded = try RpcTest.kip17?.getMethod("setApprovalForAll").encodeABI([TestAccountInfo.BRANDON.address , true])
        
        let callObject = CallObject.createCallObject(
            TestAccountInfo.LUMAN.address,
            RpcTest.kip17?.contractAddress,
            BigInt(hex: "100000"),
            BigInt(hex: "5d21dba00"),
            BigInt(hex: "0"),
            encoded
        )
        
        let result = RpcTest.caver.rpc.klay.estimateGas(callObject).result
        
        XCTAssertEqual("0xb2d9", result?.toString)
    }
    
    func test_estimateComputationCostTest() throws {
        let encoded = try RpcTest.kip17?.getMethod("setApprovalForAll").encodeABI([TestAccountInfo.BRANDON.address , true])
        
        let callObject = CallObject.createCallObject(
            TestAccountInfo.LUMAN.address,
            RpcTest.kip17?.contractAddress,
            BigInt(hex: "100000"),
            BigInt(hex: "5d21dba00"),
            BigInt(hex: "0"),
            encoded
        )
        
        let result = RpcTest.caver.rpc.klay.estimateComputationCost(callObject, .Latest).result
        
        XCTAssertEqual("0xe036", result?.toString)
    }
    
    func test_getTransactionByBlockHashAndIndexTest() throws {
        let receiptData = try RpcTest_otherRPCTest.sendKlay()
        
        let result = RpcTest.caver.rpc.klay.getTransactionByBlockHashAndIndex(receiptData.blockHash!, 0).result
        
        XCTAssertEqual(receiptData.blockHash, result?.blockHash)
    }
    
    func test_getTransactionByBlockNumberAndIndexTest() throws {
        let response = RpcTest.caver.rpc.klay.getBlockByHash((sampleReceiptData?.blockHash)!).result
                
        let result = RpcTest.caver.rpc.klay.getTransactionByBlockNumberAndIndex(
            DefaultBlockParameterName.Number(Int(hex: response!.number)!),
            DefaultBlockParameterName.Number(0)).result
        
        XCTAssertEqual(response?.hash, result?.blockHash)
    }
    
    func test_getTransactionByHashTest() throws {
        let response = RpcTest.caver.rpc.klay.getTransactionByHash((sampleReceiptData?.transactionHash)!).result
        XCTAssertEqual(sampleReceiptData?.transactionHash, response?.hash)
    }
    
    func test_getTransactionBySenderTxHashTest() throws {
        let response = RpcTest.caver.rpc.klay.getTransactionBySenderTxHash((sampleReceiptData?.transactionHash)!).result
        XCTAssertEqual(sampleReceiptData?.transactionHash, response?.hash)
    }
    
    func test_getTransactionReceiptTest() throws {
        let response = RpcTest.caver.rpc.klay.getTransactionReceipt((sampleReceiptData?.transactionHash)!).result
        XCTAssertEqual(sampleReceiptData?.transactionHash, response?.transactionHash)
    }
    
    func test_getTransactionReceiptBySenderTxHashTest() throws {
        let response = RpcTest.caver.rpc.klay.getTransactionReceiptBySenderTxHash((sampleReceiptData?.transactionHash)!).result
        XCTAssertEqual(sampleReceiptData?.transactionHash, response?.transactionHash)
    }
    
    func test_getChainIdTest() throws {
        let response = RpcTest.caver.rpc.klay.getChainID().result
        XCTAssertEqual(BigInt(RpcTest.LOCAL_CHAIN_ID), response?.val)
    }
    
    func test_getClientVersionTest() throws {
        let response = RpcTest.caver.rpc.klay.getClientVersion().result
        XCTAssertNotNil(response)
    }
    
    func test_getGasPriceTest() throws {
        let response = RpcTest.caver.rpc.klay.getGasPrice().result
        XCTAssertEqual(BigInt(hex: "5d21dba00"), response?.val)
    }
    
    func test_getGasPriceAtTest() throws {
        let response = RpcTest.caver.rpc.klay.getGasPriceAt().result
        XCTAssertEqual(BigInt(hex: "5d21dba00"), response?.val)
    }
    
    func test_isParallelDbWriteTest() throws {
        let response = RpcTest.caver.rpc.klay.isParallelDBWrite().result
        XCTAssertTrue(response ?? false)
    }
    
    func test_isSenderTxHashIndexingEnabledTest() throws {
        let response = RpcTest.caver.rpc.klay.isSenderTxHashIndexingEnabled().result
        XCTAssertFalse(response ?? true)
    }
    
    func test_getProtocolVersionTest() throws {
        let response = RpcTest.caver.rpc.klay.getProtocolVersion().result
        XCTAssertEqual("0x40", response?.toValue)
    }
    
    func Ignore_getRewardbaseTest() throws {
        let (error, _) = RpcTest.caver.rpc.klay.getRewardbase()
        XCTAssertEqual("rewardbase must be explicitly specified", error.debugDescription)
    }
    
    func Ignore_getFilterChangesTest() throws {
        _ = RpcTest.caver.rpc.klay.getFilterChanges("d5b93cf592b2050aee314767a02976c5")
    }
    
    func Ignore_getFilterLogsTest() throws {
        _ = RpcTest.caver.rpc.klay.getFilterLogs("d5b93cf592b2050aee314767a02976c5")
    }
    
    func Ignore_getLogsTest() throws {
        let filter = KlayLogFilter(
            .Earliest,
            .Latest,
            TestAccountInfo.LUMAN.address,
            "0xe2649fe9fbaa75601408fc54200e3f9b2128e8fec7cea96c9a65b9caf905c9e3")
        _ = RpcTest.caver.rpc.klay.getLogs(filter)
    }
    
    func test_newBlockFilterTest() throws {
        let response = RpcTest.caver.rpc.klay.newBlockFilter().result
        XCTAssertNotNil(response)
    }
    
    func test_newFilterTest() throws {
        let filter = KlayFilter(
            .Earliest,
            .Latest,
            TestAccountInfo.LUMAN.address)
        _ = filter.addSingleTopic("0xd596fdad182d29130ce218f4c1590c4b5ede105bee36690727baa6592bd2bfc8")
        let response = RpcTest.caver.rpc.klay.newFilter(filter)
        XCTAssertNotNil(response)
    }
    
    func test_newPendingTransactionFilterTest() throws {
        let response = RpcTest.caver.rpc.klay.newPendingTransactionFilter().result
        XCTAssertNotNil(response)
    }
    
    func Ignore_uninstallFilterTest() throws {
        _ = RpcTest.caver.rpc.klay.uninstallFilter("0x0").result
    }
    
    func test_getSha3Test() throws {
        let response = RpcTest.caver.rpc.klay.sha3("0x123f").result
        XCTAssertEqual("0x7fab6b214381d6479bf140c3c8967efb9babe535025500d5b1dc2d549984b90b", response?.toValue)
    }
    
    func test_getIdTest() throws {
        let response = RpcTest.caver.rpc.net.getNetworkID().result
        XCTAssertEqual(String(RpcTest.LOCAL_NETWORK_ID), response?.toValue)
    }
    
    func test_isListeningTest() throws {
        let response = RpcTest.caver.rpc.net.isListening().result
        XCTAssertTrue(response ?? false)
    }
    
    func test_getPeerCountTest() throws {
        let response = RpcTest.caver.rpc.net.getPeerCount().result
        XCTAssertTrue(response?.intValue ?? -1 >= 0)
    }
    
    func test_getPeerCountByTypeTest() throws {
        let response = RpcTest.caver.rpc.net.getPeerCountByType().result
        XCTAssertTrue(response?.total.int ?? -1 >= 0)
    }
}
