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
}
