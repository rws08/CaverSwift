//
//  RpcTest.swift
//  CaverSwiftTests
//
//  Created by won on 2021/07/29.
//

import XCTest
@testable import CaverSwift

class RpcTest: XCTestCase {
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
        
        nonce = (RpcTest.klay.getTransactionCount(RpcTest_signTransactionTest.klayProviderKeyring.address, .Pending).result?.val.hexa)!
        let chainId = (RpcTest.klay.getChainID().result?.val.hexa)!

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
