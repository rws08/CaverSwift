//
//  AccountUpdateTest.swift
//  CaverSwiftTests
//
//  Created by won on 2021/07/13.
//

import XCTest
@testable import CaverSwift

class AccountUpdateTest: XCTestCase {
    public static func generateRoleBaseKeyring(_ numArr: [Int], _ address: String) throws -> AbstractKeyring {
        let keyArr = numArr.map {
            (0..<$0).map { _ in
                PrivateKey.generate("entropy").privateKey
            }
        }
        
        return try KeyringFactory.createWithRoleBasedKey(address, keyArr)
    }
    
    public static func getAccountUpdateList() throws -> [AccountUpdate] {
        let accountUpdateList = [
            try AccountUpdateTest.getLegacyTx(),
            try AccountUpdateTest.getPublicKeyTx(),
            try AccountUpdateTest.getFailTx(),
            try AccountUpdateTest.getMultiSigTx(),
            try AccountUpdateTest.getRoleBasedSigTx()
        ]
        return accountUpdateList
    }
    
    public static func getExpectedDataList() -> [ExpectedData] {
        let expectedDataList = [
            ExpectedData.getExpectedDataLegacy(),
            ExpectedData.getExpectedDataPublic(),
            ExpectedData.getExpectedDataFail(),
            ExpectedData.getExpectedDataMultiSig(),
            ExpectedData.getExpectedDataRoleBased()
        ]
        return expectedDataList
    }
    
    public static func getLegacyTx() throws -> AccountUpdate {
        let address = "0xdca786ce39b074966e8a9eae16eac90783974d80"
        let gas = "0x30d40"
        let nonce = "0x0"
        let gasPrice = "0x5d21dba00"
        let chainID = "0x7e3"
        let signatureData = SignatureData(
                "0x0fea",
                "0x866f7cf552d4062a3c1a6055cabbe358a21ce779cfe2b81cee87b66024b993af",
                "0x2990dc2d9d36cc4de4b9a79c30aeab8d59e2d60631e0d90c8ac3c096b7a38852"
        )

        let account = Account.createWithAccountKeyLegacy(address)

        return try AccountUpdate.Builder()
                .setFrom(address)
                .setGas(gas)
                .setNonce(nonce)
                .setGasPrice(gasPrice)
                .setChainId(chainID)
                .setSignatures(signatureData)
                .setAccount(account)
                .build()
    }

    public static func getPublicKeyTx() throws -> AccountUpdate {
        let address = "0xffb52bc54635f840013e142ebe7c06c9c91c1625"
        let gas = "0x30d40"
        let nonce = "0x0"
        let gasPrice = "0x5d21dba00"
        let chainID = "0x7e3"

        let signatureData = SignatureData(
                "0x0fe9",
                "0x9c2ca281e94567846acbeef724b1a7a5f882d581aff9984755abd92272592b8e",
                "0x344fd23d7774ae9c227809bb579387dfcd69e74ae2fe3a788617f54a4001e5ab"
        )

        let publicKey = "0xc93fcbdb2b9dbef8ee5c4748ffdce11f1f5b06d7ba71cc2b7699e38be7698d1edfa5c0486858a516e8a46c4834ac0ad10ed7dc7ec818a88a9f75fe5fabd20e90"
        let account = Account.createWithAccountKeyPublic(address, publicKey)

        return try AccountUpdate.Builder()
                .setFrom(address)
                .setGas(gas)
                .setNonce(nonce)
                .setGasPrice(gasPrice)
                .setChainId(chainID)
                .setSignatures(signatureData)
                .setAccount(account)
                .build()
    }

    public static func getFailTx() throws -> AccountUpdate {
        let address = "0x26b05cce63f78ddf6a769fb2db39e54b9f2db620"
        let gas = "0x30d40"
        let nonce = "0x0"
        let gasPrice = "0x5d21dba00"
        let chainID = "0x7e3"

        let signatureData = SignatureData(
                "0x0fe9",
                "0x86361c43593859b6989794a6848c5ba1e5d8bd860522347cd167042acd6a7816",
                "0x773f5cc10f734b3b4486b9c5b7e5def156e06d9d9f4a3aaae6662f9a2126094c"
        )

        let account = Account.createWithAccountKeyFail(address)

        return try AccountUpdate.Builder()
                .setFrom(address)
                .setGas(gas)
                .setNonce(nonce)
                .setGasPrice(gasPrice)
                .setChainId(chainID)
                .setSignatures(signatureData)
                .setAccount(account)
                .build()
    }

    public static func getMultiSigTx() throws -> AccountUpdate {
        let address = "0x2dcd60f120bd64e35093a2945ce61c0bcb71dc93"
        let gas = "0x30d40"
        let nonce = "0x0"
        let gasPrice = "0x5d21dba00"
        let chainID = "0x7e3"

        let signatureData = SignatureData(
                "0x0fe9",
                "0x02aca4ec6773a26c71340c2500cb45886a61797bcd82790f7f01150ced48b0ac",
                "0x20502f22a1b3c95a5f260a03dc3de0eaa1f4a618b1d2a7d4da643507302e523c"
        )

        let pubKeyArr = [
                "0xe1c4bb4d01245ebdc62a88092f6c79b59d56e319ae694050e7a0c1cff93a0d9240bf159aa0ee59bacb41df2185cf0be1ca316c349d839e4edc04e1af77ec8c4e",
                "0x13853532348457b4fb18526c6447a6cdff38a791dc2e778f19a843fc6b3a3e8d4cb21a4c331ccc967aa9127fb7e49ce52eaf69c967521d4066745371868b297b",
                "0xe0f3c6f28dc933ac3cf7fc3143f0d38bc83aa9541ce7bb67c356cad5c9b020a3a0b24f48b17b1f7880ba027ad39095ae53888d788816658e47a58193c1b81720"
        ]

        let weight = [BigInt(1), BigInt(1), BigInt(1)]
        let weightedMultiSigOptions = try WeightedMultiSigOptions(BigInt(2), weight)
        let account = try Account.createWithAccountKeyWeightedMultiSig(address, pubKeyArr, weightedMultiSigOptions)

        return try AccountUpdate.Builder()
                .setFrom(address)
                .setGas(gas)
                .setNonce(nonce)
                .setGasPrice(gasPrice)
                .setChainId(chainID)
                .setSignatures(signatureData)
                .setAccount(account)
                .build()
    }

    public static func getRoleBasedSigTx() throws -> AccountUpdate {
        let address = "0xfb675bea5c3fa279fd21572161b6b6b2dbd84233"
        let gas = "0x30d40"
        let nonce = "0x0"
        let gasPrice = "0x5d21dba00"
        let chainID = "0x7e3"

        let signatureData = SignatureData(
                "0x0fe9",
                "0x66e28c27f16ba34325770e842874d07473180bcec22e86851a6882acbaeb56c3",
                "0x761e12fe11003aa4cb8fd9b44a41e5edebeb943cc366264b345d0f7e63853724"
        )

        let pubKeyArr = [
                [
                    "0xf7e7e03c328d39cee6201080ac2576919f904f0b8e47fcb7ea8869e7db0baf4470a0b29a1f6dd007e19a53da122d18bf6273cdddb2903ef0ad2b350b207ad67c",
                    "0xedacd9095274f292c702514f6443f58337e7d7c8311694f31c73e86f150ecf45820929c143da861f6009784e36a6ebd99f83b1baf93fd72e820b5df3cd00883b",
                    "0xb74fd682a6a805415e7711890bc91a283c268c78947ebf25a02a2e02625a68aa825b5213f3e9f03c34650da902a2a70915dcc1c7fe86333a7e40e638361335a4"
                ],
                [
                    "0xd0ae803893f344ee664378bbc9ebb35ca2d94f7d7ecea4e3e2f9f33817cdb04bb54cf4211eef21e9627a7d0ca6960e8f1135a35c751f526ce203c6e36b3f2230",
                ],
                [
                    "0x4b4cd35195aa4324184a64821e514a991b513cc354f5fa6d78fb99e23949bc59613d8be87ad3e1418ad11e1d5537233b697bc0c8c5d7335a6decf687cce700ba",
                    "0x3e65f4a76bca1488a1a046d6976778852aa41f07156d2c42e81c3da6621435d2350f8419fe8255dc87158c8ae30378b19b0d3d224eb410ca2de847a41caeb617"
                ]
        ]

        let options = [
            try WeightedMultiSigOptions(BigInt(2), [BigInt(1), BigInt(1), BigInt(1)]),
            WeightedMultiSigOptions(),
            try WeightedMultiSigOptions(BigInt(1), [BigInt(1), BigInt(1)])
        ]

        let account = try Account.createWithAccountKeyRoleBased(address, pubKeyArr, options)

        return try AccountUpdate.Builder()
                .setFrom(address)
                .setGas(gas)
                .setNonce(nonce)
                .setGasPrice(gasPrice)
                .setChainId(chainID)
                .setSignatures(signatureData)
                .setAccount(account)
                .build()
    }
    
    public class ExpectedData {
        var expectedRLP: String
        var expectedTxHash: String
        var expectedRlpEncodingForSigning: String

        public init(_ expectedRLP: String, _ expectedTxHash: String, _ expectedRlpEncodingForSigning: String) {
            self.expectedRLP = expectedRLP
            self.expectedTxHash = expectedTxHash
            self.expectedRlpEncodingForSigning = expectedRlpEncodingForSigning
        }

        public static func getExpectedDataLegacy() -> ExpectedData {
            return ExpectedData(
                    "0x20f86c808505d21dba0083030d4094dca786ce39b074966e8a9eae16eac90783974d808201c0f847f845820feaa0866f7cf552d4062a3c1a6055cabbe358a21ce779cfe2b81cee87b66024b993afa02990dc2d9d36cc4de4b9a79c30aeab8d59e2d60631e0d90c8ac3c096b7a38852",
                    "0xeea281154fc4000f01b47a5a6f0c2caa1481cbc9ef935cc8c35a5f006f8d97a6",
                    "0xe420808505d21dba0083030d4094dca786ce39b074966e8a9eae16eac90783974d808201c0"
            )
        }

        public static func getExpectedDataPublic() -> ExpectedData {
            return ExpectedData(
                    "0x20f88d808505d21dba0083030d4094ffb52bc54635f840013e142ebe7c06c9c91c1625a302a102c93fcbdb2b9dbef8ee5c4748ffdce11f1f5b06d7ba71cc2b7699e38be7698d1ef847f845820fe9a09c2ca281e94567846acbeef724b1a7a5f882d581aff9984755abd92272592b8ea0344fd23d7774ae9c227809bb579387dfcd69e74ae2fe3a788617f54a4001e5ab",
                    "0x0c52c7e1d67da8221df26fa7ac01f33d87f46dc706844804f378cebe2e66c432",
                    "0xf84520808505d21dba0083030d4094ffb52bc54635f840013e142ebe7c06c9c91c1625a302a102c93fcbdb2b9dbef8ee5c4748ffdce11f1f5b06d7ba71cc2b7699e38be7698d1e"
            )
        }

        public static func getExpectedDataFail() -> ExpectedData {
            return ExpectedData(
                    "0x20f86c808505d21dba0083030d409426b05cce63f78ddf6a769fb2db39e54b9f2db6208203c0f847f845820fe9a086361c43593859b6989794a6848c5ba1e5d8bd860522347cd167042acd6a7816a0773f5cc10f734b3b4486b9c5b7e5def156e06d9d9f4a3aaae6662f9a2126094c",
                    "0xfb6053ce6d0321eebcdbce2c123fd501bc38ab6bcf74a34001663a56d227cd92",
                    "0xe420808505d21dba0083030d409426b05cce63f78ddf6a769fb2db39e54b9f2db6208203c0"
            )
        }

        public static func getExpectedDataMultiSig() -> ExpectedData {
            return ExpectedData(
                    "0x20f8dd808505d21dba0083030d40942dcd60f120bd64e35093a2945ce61c0bcb71dc93b87204f86f02f86ce301a102e1c4bb4d01245ebdc62a88092f6c79b59d56e319ae694050e7a0c1cff93a0d92e301a10313853532348457b4fb18526c6447a6cdff38a791dc2e778f19a843fc6b3a3e8de301a102e0f3c6f28dc933ac3cf7fc3143f0d38bc83aa9541ce7bb67c356cad5c9b020a3f847f845820fe9a002aca4ec6773a26c71340c2500cb45886a61797bcd82790f7f01150ced48b0aca020502f22a1b3c95a5f260a03dc3de0eaa1f4a618b1d2a7d4da643507302e523c",
                    "0x6b67ca5e8f1ef46e009348541d0866dbb2902b75a4dccb3b7286d6987f556b44",
                    "0xf89520808505d21dba0083030d40942dcd60f120bd64e35093a2945ce61c0bcb71dc93b87204f86f02f86ce301a102e1c4bb4d01245ebdc62a88092f6c79b59d56e319ae694050e7a0c1cff93a0d92e301a10313853532348457b4fb18526c6447a6cdff38a791dc2e778f19a843fc6b3a3e8de301a102e0f3c6f28dc933ac3cf7fc3143f0d38bc83aa9541ce7bb67c356cad5c9b020a3"
            )
        }

        public static func getExpectedDataRoleBased() -> ExpectedData {
            return ExpectedData(
                    "0x20f90156808505d21dba0083030d4094fb675bea5c3fa279fd21572161b6b6b2dbd84233b8eb05f8e8b87204f86f02f86ce301a102f7e7e03c328d39cee6201080ac2576919f904f0b8e47fcb7ea8869e7db0baf44e301a103edacd9095274f292c702514f6443f58337e7d7c8311694f31c73e86f150ecf45e301a102b74fd682a6a805415e7711890bc91a283c268c78947ebf25a02a2e02625a68aaa302a102d0ae803893f344ee664378bbc9ebb35ca2d94f7d7ecea4e3e2f9f33817cdb04bb84e04f84b01f848e301a1024b4cd35195aa4324184a64821e514a991b513cc354f5fa6d78fb99e23949bc59e301a1033e65f4a76bca1488a1a046d6976778852aa41f07156d2c42e81c3da6621435d2f847f845820fe9a066e28c27f16ba34325770e842874d07473180bcec22e86851a6882acbaeb56c3a0761e12fe11003aa4cb8fd9b44a41e5edebeb943cc366264b345d0f7e63853724",
                    "0x57cdfb7b92c16608b467c28e6519f66ef89923046fce37e086baa1f5775ef312",
                    "0xf9010e20808505d21dba0083030d4094fb675bea5c3fa279fd21572161b6b6b2dbd84233b8eb05f8e8b87204f86f02f86ce301a102f7e7e03c328d39cee6201080ac2576919f904f0b8e47fcb7ea8869e7db0baf44e301a103edacd9095274f292c702514f6443f58337e7d7c8311694f31c73e86f150ecf45e301a102b74fd682a6a805415e7711890bc91a283c268c78947ebf25a02a2e02625a68aaa302a102d0ae803893f344ee664378bbc9ebb35ca2d94f7d7ecea4e3e2f9f33817cdb04bb84e04f84b01f848e301a1024b4cd35195aa4324184a64821e514a991b513cc354f5fa6d78fb99e23949bc59e301a1033e65f4a76bca1488a1a046d6976778852aa41f07156d2c42e81c3da6621435d2"
            )
        }

        public func getExpectedRLP() -> String {
            return expectedRLP
        }

        public func getExpectedTxHash() -> String {
            return expectedTxHash
        }

        public func getExpectedRlpEncodingForSigning() -> String {
            return expectedRlpEncodingForSigning
        }
    }
}

class AccountUpdateTest_createInstanceBuilder: XCTestCase {
    let from = "0xfb675bea5c3fa279fd21572161b6b6b2dbd84233"
    let gas = "0x30d40"
    let nonce = "0x0"
    let gasPrice = "0x5d21dba00"
    let chainID = "0x7e3"
    
    let account = Account.createWithAccountKeyLegacy("0xfb675bea5c3fa279fd21572161b6b6b2dbd84233")
    
    public func test_BuilderTest() throws {
        let txObj = try AccountUpdate.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setAccount(account)
            .build()
        
        XCTAssertNotNil(txObj)
    }
    
    public func test_BuilderWithRPCTest() throws {
        let txObj = try AccountUpdate.Builder()
            .setKlaytnCall(Caver(Caver.DEFAULT_URL).rpc.klay)
            .setGas(gas)
            .setFrom(from)
            .setAccount(account)
            .build()
        
        try txObj.fillTransaction()
        
        XCTAssertFalse(txObj.nonce.isEmpty)
        XCTAssertFalse(txObj.gasPrice.isEmpty)
        XCTAssertFalse(txObj.chainId.isEmpty)
    }
    
    public func test_BuilderTestWithBigInteger() throws {
        let txObj = try AccountUpdate.Builder()
            .setNonce(BigInt(hex: nonce)!)
            .setGas(BigInt(hex: gas)!)
            .setGasPrice(BigInt(hex: gasPrice)!)
            .setChainId(BigInt(hex: chainID)!)
            .setFrom(from)
            .setAccount(account)
            .build()
        
        XCTAssertNotNil(txObj)
        
        XCTAssertEqual(gas, txObj.gas)
        XCTAssertEqual(gasPrice, txObj.gasPrice)
        XCTAssertEqual(chainID, txObj.chainId)
    }
    
    public func test_throwException_invalidFrom() throws {
        let from = "invalid Address"
        XCTAssertThrowsError(try AccountUpdate.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setAccount(account)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(from)"))
        }
    }
    
    public func test_throwException_missingFrom() throws {
        let from = ""
        XCTAssertThrowsError(try AccountUpdate.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setAccount(account)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("from is missing."))
        }
    }
    
    public func test_throwException_invalidGas() throws {
        let gas = "invalid gas"
        XCTAssertThrowsError(try AccountUpdate.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setAccount(account)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid gas. : \(gas)"))
        }
    }
    
    public func test_throwException_missingGas() throws {
        let gas = ""
        XCTAssertThrowsError(try AccountUpdate.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setAccount(account)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("gas is missing."))
        }
    }
    
    public func test_throwException_missingAccount() throws {
        let account: Account? = nil
        XCTAssertThrowsError(try AccountUpdate.Builder()
                                .setNonce(nonce)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setChainId(chainID)
                                .setFrom(from)
                                .setAccount(account)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("account is missing."))
        }
    }
}

class AccountUpdateTest_createInstance: XCTestCase {
    let from = "0xfb675bea5c3fa279fd21572161b6b6b2dbd84233"
    let gas = "0x30d40"
    let nonce = "0x0"
    let gasPrice = "0x5d21dba00"
    let chainID = "0x7e3"
    
    let account = Account.createWithAccountKeyLegacy("0xfb675bea5c3fa279fd21572161b6b6b2dbd84233")
    
    public func test_createInstance() throws {
        let txObj = try AccountUpdate(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            account
        )
        
        XCTAssertNotNil(txObj)
    }
    
    public func test_throwException_invalidFrom() throws {
        let from = "invalid Address"
        XCTAssertThrowsError(try AccountUpdate(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            account
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(from)"))
        }
    }
    
    public func test_throwException_missingFrom() throws {
        let from = ""
        XCTAssertThrowsError(try AccountUpdate(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            account
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("from is missing."))
        }
    }
    
    public func test_throwException_invalidGas() throws {
        let gas = "invalid gas"
        XCTAssertThrowsError(try AccountUpdate(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            account
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid gas. : \(gas)"))
        }
    }
    
    public func test_throwException_missingGas() throws {
        let gas = ""
        XCTAssertThrowsError(try AccountUpdate(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            account
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("gas is missing."))
        }
    }
}

class AccountUpdateTest_getRLPEncodingTest: XCTestCase {
    let from = "0xfb675bea5c3fa279fd21572161b6b6b2dbd84233"
    let gas = "0x30d40"
    let nonce = "0x0"
    let gasPrice = "0x5d21dba00"
    let chainID = "0x7e3"
    
    let account = Account.createWithAccountKeyLegacy("0xfb675bea5c3fa279fd21572161b6b6b2dbd84233")
        
    public func test_getRLPEncoding() throws {
        let updateList = try AccountUpdateTest.getAccountUpdateList()
        let expectedDataList = AccountUpdateTest.getExpectedDataList()
        
        try zip(expectedDataList, updateList).forEach {
            XCTAssertEqual($0.expectedRLP, try $1.getRLPEncoding())
        }
    }
    
    public func test_throwException_NoNonce() throws {
        let txObj = try AccountUpdate.Builder()
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setAccount(account)
            .build()
        
        XCTAssertThrowsError(try txObj.getRLPEncoding()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NoGasPrice() throws {
        let txObj = try AccountUpdate.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setChainId(chainID)
            .setFrom(from)
            .setAccount(account)
            .build()
        
        XCTAssertThrowsError(try txObj.getRLPEncoding()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class AccountUpdateTest_signWithKeyTest: XCTestCase {
    var mTxObj: AccountUpdate?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = "0x45a915e4d060149eb4365960e6a7a45f334393093061116b197e3240065ff2d8"
    let from = "0xa94f5374Fce5edBC8E2a8697C15331677e6EbF0B"
    let nonce = "0x4d2"
    let gas = "0xf4240"
    let gasPrice = "0x19"
    let to = "0x7b65B75d204aBed71587c9E519a89277766EE1d0"
    let chainID = "0x1"
    let input = "0x31323334"
    let value = "0xa"
    
    let expectedRLPEncoding = "0x20f8888204d219830f424094a94f5374fce5edbc8e2a8697c15331677e6ebf0ba302a1033a514176466fa815ed481ffad09110a2d344f6c9b78c1d14afc351c3a51be33df845f84325a0f7d479628f05f51320f0842193e3f7ae55a5b49d3645bf55c35bee1e8fd2593aa04de8eab5338fdc86e96f8c49ed516550f793fc2c4007614ce3d2a6b33cf9e451"
        
    override func setUpWithError() throws {
        let account = Account.createWithAccountKeyPublic(from, try PrivateKey(privateKey).getPublicKey())
        
        mTxObj = try AccountUpdate.Builder()
            .setFrom(from)
            .setGas(gas)
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setAccount(account)
            .build()
        
        coupledKeyring = try KeyringFactory.createFromPrivateKey(privateKey)
        deCoupledKeyring = try KeyringFactory.createWithSingleKey(PrivateKey.generate().getDerivedAddress(), privateKey)
        klaytnWalletKey = privateKey + "0x00" + coupledKeyring!.address
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

class AccountUpdateTest_signWithKeysTest: XCTestCase {
    var mTxObj: AccountUpdate?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = "0x45a915e4d060149eb4365960e6a7a45f334393093061116b197e3240065ff2d8"
    let from = "0xa94f5374Fce5edBC8E2a8697C15331677e6EbF0B"
    let nonce = "0x4d2"
    let gas = "0xf4240"
    let gasPrice = "0x19"
    let to = "0x7b65B75d204aBed71587c9E519a89277766EE1d0"
    let chainID = "0x1"
    let input = "0x31323334"
    let value = "0xa"
    
    let expectedRLPEncoding = "0x20f8888204d219830f424094a94f5374fce5edbc8e2a8697c15331677e6ebf0ba302a1033a514176466fa815ed481ffad09110a2d344f6c9b78c1d14afc351c3a51be33df845f84325a0f7d479628f05f51320f0842193e3f7ae55a5b49d3645bf55c35bee1e8fd2593aa04de8eab5338fdc86e96f8c49ed516550f793fc2c4007614ce3d2a6b33cf9e451"
        
    override func setUpWithError() throws {
        let account = Account.createWithAccountKeyPublic(from, try PrivateKey(privateKey).getPublicKey())
        
        mTxObj = try AccountUpdate.Builder()
            .setFrom(from)
            .setGas(gas)
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setAccount(account)
            .build()
        
        coupledKeyring = try KeyringFactory.createFromPrivateKey(privateKey)
        deCoupledKeyring = try KeyringFactory.createWithSingleKey(PrivateKey.generate().getDerivedAddress(), privateKey)
        klaytnWalletKey = privateKey + "0x00" + coupledKeyring!.address
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

class AccountUpdateTest_appendSignaturesTest: XCTestCase {
    var mTxObj: AccountUpdate?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = "0x45a915e4d060149eb4365960e6a7a45f334393093061116b197e3240065ff2d8"
    let from = "0xa94f5374Fce5edBC8E2a8697C15331677e6EbF0B"
    let nonce = "0x4d2"
    let gas = "0xf4240"
    let gasPrice = "0x19"
    let to = "0x7b65B75d204aBed71587c9E519a89277766EE1d0"
    let chainID = "0x1"
    let input = "0x31323334"
    let value = "0xa"
    
    var account: Account?
    override func setUpWithError() throws {
        account = Account.createWithAccountKeyPublic(from, try PrivateKey(privateKey).getPublicKey())
        
        mTxObj = try AccountUpdate.Builder()
            .setFrom(from)
            .setGas(gas)
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setAccount(account)
            .build()
        
        coupledKeyring = try KeyringFactory.createFromPrivateKey(privateKey)
        deCoupledKeyring = try KeyringFactory.createWithSingleKey(PrivateKey.generate().getDerivedAddress(), privateKey)
        klaytnWalletKey = privateKey + "0x00" + coupledKeyring!.address
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
        mTxObj = try AccountUpdate.Builder()
                            .setFrom(from)
                            .setGas(gas)
                            .setNonce(nonce)
                            .setGasPrice(gasPrice)
                            .setChainId(chainID)
                            .setAccount(account)
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
        
        mTxObj = try AccountUpdate.Builder()
                            .setFrom(from)
                            .setGas(gas)
                            .setNonce(nonce)
                            .setGasPrice(gasPrice)
                            .setChainId(chainID)
                            .setAccount(account)
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
        
        mTxObj = try AccountUpdate.Builder()
                            .setFrom(from)
                            .setGas(gas)
                            .setNonce(nonce)
                            .setGasPrice(gasPrice)
                            .setChainId(chainID)
                            .setAccount(account)
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

class AccountUpdateTest_combineSignatureTest: XCTestCase {
    var mTxObj: AccountUpdate?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = "0x45a915e4d060149eb4365960e6a7a45f334393093061116b197e3240065ff2d8"
    let from = "0x40efcb7d744fdc881f698a8ec573999fe6383545"
    let nonce = "0x1"
    let gas = "0x15f90"
    let gasPrice = "0x5d21dba00"
    let chainID = "0x7e3"
    
    var account: Account?
    override func setUpWithError() throws {
        account = Account.createWithAccountKeyLegacy(from)
        
        mTxObj = try AccountUpdate.Builder()
            .setFrom(from)
            .setGas(gas)
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setAccount(account)
            .build()
        
        coupledKeyring = try KeyringFactory.createFromPrivateKey(privateKey)
        deCoupledKeyring = try KeyringFactory.createWithSingleKey(PrivateKey.generate().getDerivedAddress(), privateKey)
        klaytnWalletKey = privateKey + "0x00" + coupledKeyring!.address
    }
    
    public func test_combineSignature() throws {
        let expectedSignature = SignatureData(
            "0x0fe9",
            "0xf2a83743da6931ce25a29d04f1c51cec8464f0d9d4dabb5acb059aa3fb8c345a",
            "0x65879e06474669005e02e0b8ca06cba6f8943022305659f8936f1f6109147fdd"
        )
        let rlpEncoded = "0x20f86c018505d21dba0083015f909440efcb7d744fdc881f698a8ec573999fe63835458201c0f847f845820fe9a0f2a83743da6931ce25a29d04f1c51cec8464f0d9d4dabb5acb059aa3fb8c345aa065879e06474669005e02e0b8ca06cba6f8943022305659f8936f1f6109147fdd"
        let combined = try mTxObj!.combineSignedRawTransactions([rlpEncoded])
        XCTAssertEqual(rlpEncoded, combined)
        XCTAssertEqual(expectedSignature, mTxObj?.signatures[0])
    }
    
    public func test_combine_multipleSignature() throws {
        let signatureData = SignatureData(
            "0x0fe9",
            "0xf2a83743da6931ce25a29d04f1c51cec8464f0d9d4dabb5acb059aa3fb8c345a",
            "0x65879e06474669005e02e0b8ca06cba6f8943022305659f8936f1f6109147fdd"
        )
        
        mTxObj = try AccountUpdate.Builder()
            .setFrom(from)
            .setGas(gas)
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setAccount(account)
            .setSignatures(signatureData)
            .build()
        
        let expectedRLPEncoded = "0x20f8fa018505d21dba0083015f909440efcb7d744fdc881f698a8ec573999fe63835458201c0f8d5f845820fe9a0f2a83743da6931ce25a29d04f1c51cec8464f0d9d4dabb5acb059aa3fb8c345aa065879e06474669005e02e0b8ca06cba6f8943022305659f8936f1f6109147fddf845820feaa0638f0d712b4b709cadab174dea6da50e5429ea59d78446e810af954af8d67981a0129ad4eb9222e161e9e52be9c2384e1b1ff7566c640bc5b30c054efd64b081e7f845820fe9a0935584330d98f4a8a1cf83bf81ea7a18e33a962ad17b6a9eb8e04e3f5f95179da026804e07b5c105427497e8336300c1435d30ffa8d379dc27e5c1facd966c58db"
        
        let expectedSignature = [
            SignatureData(
                "0x0fe9",
                "0xf2a83743da6931ce25a29d04f1c51cec8464f0d9d4dabb5acb059aa3fb8c345a",
                "0x65879e06474669005e02e0b8ca06cba6f8943022305659f8936f1f6109147fdd"
            ),
            SignatureData(
                "0x0fea",
                "0x638f0d712b4b709cadab174dea6da50e5429ea59d78446e810af954af8d67981",
                "0x129ad4eb9222e161e9e52be9c2384e1b1ff7566c640bc5b30c054efd64b081e7"
            ),
            SignatureData(
                "0x0fe9",
                "0x935584330d98f4a8a1cf83bf81ea7a18e33a962ad17b6a9eb8e04e3f5f95179d",
                "0x26804e07b5c105427497e8336300c1435d30ffa8d379dc27e5c1facd966c58db"
            )
        ]
        
        let rlpEncodedString = [
            "0x20f86c018505d21dba0083015f909440efcb7d744fdc881f698a8ec573999fe63835458201c0f847f845820feaa0638f0d712b4b709cadab174dea6da50e5429ea59d78446e810af954af8d67981a0129ad4eb9222e161e9e52be9c2384e1b1ff7566c640bc5b30c054efd64b081e7",
            "0x20f86c018505d21dba0083015f909440efcb7d744fdc881f698a8ec573999fe63835458201c0f847f845820fe9a0935584330d98f4a8a1cf83bf81ea7a18e33a962ad17b6a9eb8e04e3f5f95179da026804e07b5c105427497e8336300c1435d30ffa8d379dc27e5c1facd966c58db"
        ]
        
        let combined = try mTxObj!.combineSignedRawTransactions(rlpEncodedString)
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature[0], mTxObj?.signatures[0])
        XCTAssertEqual(expectedSignature[1], mTxObj?.signatures[1])
        XCTAssertEqual(expectedSignature[2], mTxObj?.signatures[2])
    }
    
    public func test_throwException_differentField() throws {
        let nonce = "0x1000"
        mTxObj = try AccountUpdate.Builder()
            .setFrom(from)
            .setGas(gas)
            .setNonce(nonce)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setAccount(account)
            .build()
        
        let rlpEncoded = "0x20f86c018505d21dba0083015f909440efcb7d744fdc881f698a8ec573999fe63835458201c0f847f845820feaa0638f0d712b4b709cadab174dea6da50e5429ea59d78446e810af954af8d67981a0129ad4eb9222e161e9e52be9c2384e1b1ff7566c640bc5b30c054efd64b081e7"
        
        XCTAssertThrowsError(try mTxObj!.combineSignedRawTransactions([rlpEncoded])) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("Transactions containing different information cannot be combined."))
        }
    }
}

class AccountUpdateTest_getRawTransactionTest: XCTestCase {
    public func test_getRLPEncodingForSignature() throws {
        let updateList = try AccountUpdateTest.getAccountUpdateList()
        let expectedDataList = AccountUpdateTest.getExpectedDataList()
        
        try zip(expectedDataList, updateList).forEach {
            XCTAssertEqual($0.expectedRLP, try $1.getRawTransaction())
        }
    }
}

class AccountUpdateTest_getTransactionHashTest: XCTestCase {
    var mTxObj: AccountUpdate?
    
    let from = "0x40efcb7d744fdc881f698a8ec573999fe6383545"
    let gas = "0x15f90"
    let nonce = "0x1"
    let gasPrice = "0x5d21dba00"
    let chainID = "0x7e3"
    
    let account = Account.createWithAccountKeyLegacy("0x40efcb7d744fdc881f698a8ec573999fe6383545")
        
    public func test_getTransactionHash() throws {
        let updateList = try AccountUpdateTest.getAccountUpdateList()
        let expectedDataList = AccountUpdateTest.getExpectedDataList()
        
        try zip(expectedDataList, updateList).forEach {
            XCTAssertEqual($0.expectedTxHash, try $1.getTransactionHash())
        }
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        mTxObj = try AccountUpdate.Builder()
            .setFrom(from)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setAccount(account)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getSenderTxHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_gasPrice() throws {
        mTxObj = try AccountUpdate.Builder()
            .setFrom(from)
            .setGas(gas)
            .setNonce(nonce)
            .setChainId(chainID)
            .setAccount(account)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getSenderTxHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class AccountUpdateTest_getRLPEncodingForSignatureTest: XCTestCase {
    var mTxObj: AccountUpdate?
    
    let from = "0x40efcb7d744fdc881f698a8ec573999fe6383545"
    let gas = "0x15f90"
    let nonce = "0x1"
    let gasPrice = "0x5d21dba00"
    let chainID = "0x7e3"
    
    let account = Account.createWithAccountKeyLegacy("0x40efcb7d744fdc881f698a8ec573999fe6383545")
        
    public func test_getRLPEncodingForSignature() throws {
        let updateList = try AccountUpdateTest.getAccountUpdateList()
        let expectedDataList = AccountUpdateTest.getExpectedDataList()
        
        try zip(expectedDataList, updateList).forEach {
            XCTAssertEqual($0.expectedRlpEncodingForSigning, try $1.getCommonRLPEncodingForSignature())
        }
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        mTxObj = try AccountUpdate.Builder()
            .setFrom(from)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setAccount(account)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_gasPrice() throws {
        mTxObj = try AccountUpdate.Builder()
            .setFrom(from)
            .setGas(gas)
            .setNonce(nonce)
            .setChainId(chainID)
            .setAccount(account)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_chainID() throws {
        mTxObj = try AccountUpdate.Builder()
            .setFrom(from)
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setAccount(account)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("chainId is undefined. Define chainId in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

