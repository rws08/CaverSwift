//
//  AccountTest.swift
//  CaverSwiftTests
//
//  Created by won on 2021/07/02.
//

import XCTest
@testable import CaverSwift
@testable import BigInt

class AccountTest: XCTestCase {
    func checkPublicKey(_ expected: String, _ actual: String) throws {
        var expected = try Utils.compressPublicKey(expected)
        var actual = try Utils.compressPublicKey(actual)

        expected = expected.cleanHexPrefix
        actual = actual.cleanHexPrefix
        
        XCTAssertEqual(expected, actual)
    }
    
    func checkAccountKeyPublic(_ accountKey: IAccountKey, _ expectedPublicKey: String) throws {
        XCTAssertTrue(accountKey is AccountKeyPublic)
        try checkPublicKey(expectedPublicKey, (accountKey as! AccountKeyPublic).publicKey)
    }
    
    func checkAccountKeyWeightedMultiSig(_ accountKey: IAccountKey,_ expectedKeys: [String], _ expectedOption: WeightedMultiSigOptions) throws {
        XCTAssertTrue(accountKey is AccountKeyWeightedMultiSig)
        let actualAccountKey = accountKey as! AccountKeyWeightedMultiSig
        XCTAssertEqual(expectedOption.threshold, actualAccountKey.threshold)
        
        try zip(actualAccountKey.weightedPublicKeys, zip(expectedKeys, expectedOption.weights)).forEach {
            try checkPublicKey($1.0, $0.publicKey)
            XCTAssertEqual($1.1, $0.weight)
        }
    }

    public func testCreateToAccountKeyPublic_uncompressed() throws {
        let address = "0xf43dcbb903a0b4b48a7dfa8a370a63f0a731708d"
        let publicKey = "0x1e3aec6e8bd8247aea112c3d1094566272974e56bb0151c58745847e2998ad0e5e8360b120dceea794c6cb1e4215208a78c82e8df5dcf1ac9aa73f1568ee5f2e"

        let account = Account.create(address, publicKey)
        XCTAssertEqual(address, account.address)
        try checkAccountKeyPublic(account.accountKey, publicKey)
    }
    
    public func testCreateToAccountKeyPublic_compressed() throws {
        let address = "0xf43dcbb903a0b4b48a7dfa8a370a63f0a731708d"
        let publicKey = "0x021e3aec6e8bd8247aea112c3d1094566272974e56bb0151c58745847e2998ad0e"

        let account = Account.create(address, publicKey)
        XCTAssertEqual(address, account.address)
        try checkAccountKeyPublic(account.accountKey, publicKey)
    }
    
    public func testCreateToAccountKeyWeightMultiSig_uncompressed() throws {
        let address = "0xab9825316619a0720ad891135e92adb84fd74fc1"
        let publicKeys = [
            "0x91245244462b3eee6436d3dc0ba3f69ef413fe2296c729733eff891a55f70c02f2b0870653417943e795e7c8694c4f8be8af865b7a0224d1dec0bf8a1bf1b5a6",
            "0x77e05dd93cdd6362f8648447f33d5676cbc5f42f4c4946ae1ad62bd4c0c4f3570b1a104b67d1cd169bbf61dd557f15ab5ee8b661326096954caddadf34ae6ac8",
            "0xd3bb14320d87eed081ae44740b5abbc52bac2c7ccf85b6281a0fc69f3ba4c171cc4bd2ba7f0c969cd72bfa49c854d8ac2cf3d0edea7f0ce0fd31cf080374935d",
            "0xcfa4d1bee51e59e6842b136ff95b9d01385f94bed13c4be8996c6d20cb732c3ee47cd2b6bbb917658c5fd3d02b0ddf1242b1603d1acbde7812a7d9d684ed37a9"]

        let weights = [BigInt(1), BigInt(1), BigInt(2), BigInt(2)]
        let options = try WeightedMultiSigOptions(BigInt(1), weights)
        let account = try Account.create(address, publicKeys, options)
        XCTAssertEqual(address, account.address)
        try checkAccountKeyWeightedMultiSig(account.accountKey, publicKeys, options)
    }
    
    public func testCreateToAccountKeyWeightMultiSig_compressed() throws {
        let address = "0xab9825316619a0720ad891135e92adb84fd74fc1"
        let publicKeys = [
            "0x0291245244462b3eee6436d3dc0ba3f69ef413fe2296c729733eff891a55f70c02",
            "0x0277e05dd93cdd6362f8648447f33d5676cbc5f42f4c4946ae1ad62bd4c0c4f357",
            "0x03d3bb14320d87eed081ae44740b5abbc52bac2c7ccf85b6281a0fc69f3ba4c171",
            "0x03cfa4d1bee51e59e6842b136ff95b9d01385f94bed13c4be8996c6d20cb732c3e"]

        let weights = [BigInt(1), BigInt(1), BigInt(2), BigInt(2)]
        let options = try WeightedMultiSigOptions(BigInt(1), weights)
        let account = try Account.create(address, publicKeys, options)
        XCTAssertEqual(address, account.address)
        try checkAccountKeyWeightedMultiSig(account.accountKey, publicKeys, options)
    }
    
    public func testCreateToAccountKeyWeightMultiSig_noOption() throws {
        let address = "0xab9825316619a0720ad891135e92adb84fd74fc1"
        let publicKeys = [
            "0x0291245244462b3eee6436d3dc0ba3f69ef413fe2296c729733eff891a55f70c02",
            "0x0277e05dd93cdd6362f8648447f33d5676cbc5f42f4c4946ae1ad62bd4c0c4f357",
            "0x03d3bb14320d87eed081ae44740b5abbc52bac2c7ccf85b6281a0fc69f3ba4c171",
            "0x03cfa4d1bee51e59e6842b136ff95b9d01385f94bed13c4be8996c6d20cb732c3e"]

        let weights = [BigInt(1), BigInt(1), BigInt(1), BigInt(1)]
        let expectedOptions = try WeightedMultiSigOptions(BigInt(1), weights)
        let account = try Account.create(address, publicKeys)
        XCTAssertEqual(address, account.address)
        try checkAccountKeyWeightedMultiSig(account.accountKey, publicKeys, expectedOptions)
    }
    
    public func testCreateToAccountKeyRoleBased_uncompressed() throws {
        let address = "0xab9825316619a0720ad891135e92adb84fd74fc1"
        let publicKeys = [
        ["0xb86b2787e8c7accd7d2d82678c9bef047a0aafd72a6e690817506684e8513c9af36becba90c8de06fd06da16492263267a63720985f94fc5a027d0a26d25e6ae",
         "0xe4d4901155edabc2bd5b356c63e58af20fe0a74e5f210de6396b74094f40215d3bc4d619872b96c091c741a15736a7ef12f530b7593038bbbfbf6c35deee8a34"
        ],
        ["0x1a909c4d7dbb5281b1d1b55e79a1b2568111bd2830246c3173ce824000eb8716afe39b6106fb9db360fb5779e2d346c8328698174831941586b11bdc3e755905",
         "0x1427ac6351bbfc15811e8e5389a674b01d7a2c253e69a6ed30a33583864368f65f63b92fd60be61c5d176ae1771e7738e6a043af814b9af5d81137df29ee95f2",
         "0x90fe4bb78bc981a40874ebcff2f9de4eba1e59ecd7a271a37814413720a3a5ea5fa9bd7d8bc5c66a9a08d77563458b004bbd1d594a3a12ef108cdc7c04c525a6"
        ],
        ["0x91245244462b3eee6436d3dc0ba3f69ef413fe2296c729733eff891a55f70c02f2b0870653417943e795e7c8694c4f8be8af865b7a0224d1dec0bf8a1bf1b5a6",
         "0x77e05dd93cdd6362f8648447f33d5676cbc5f42f4c4946ae1ad62bd4c0c4f3570b1a104b67d1cd169bbf61dd557f15ab5ee8b661326096954caddadf34ae6ac8",
         "0xd3bb14320d87eed081ae44740b5abbc52bac2c7ccf85b6281a0fc69f3ba4c171cc4bd2ba7f0c969cd72bfa49c854d8ac2cf3d0edea7f0ce0fd31cf080374935d",
         "0xcfa4d1bee51e59e6842b136ff95b9d01385f94bed13c4be8996c6d20cb732c3ee47cd2b6bbb917658c5fd3d02b0ddf1242b1603d1acbde7812a7d9d684ed37a9"
        ]]

        let optionWeight = [
            [BigInt(1), BigInt(1)],
            [BigInt(1), BigInt(1), BigInt(2)],
            [BigInt(1), BigInt(1), BigInt(2), BigInt(2)]
        ]
        let options = [try WeightedMultiSigOptions(BigInt(2), optionWeight[0]),
                       try WeightedMultiSigOptions(BigInt(2), optionWeight[1]),
                       try WeightedMultiSigOptions(BigInt(3), optionWeight[2])]
        
        let account = try Account.create(address, publicKeys, options)
        XCTAssertEqual(address, account.address)
        
        XCTAssertTrue(account.accountKey is AccountKeyRoleBased)
        let accountKeyRoleBased = account.accountKey as! AccountKeyRoleBased
        
        let txKey = accountKeyRoleBased.roleTransactionKey
        XCTAssertTrue(txKey is AccountKeyWeightedMultiSig)
        try checkAccountKeyWeightedMultiSig(txKey, publicKeys[0], options[0])
        
        let accountUpdateKey = accountKeyRoleBased.roleAccountUpdateKey
        XCTAssertTrue(accountUpdateKey is AccountKeyWeightedMultiSig)
        try checkAccountKeyWeightedMultiSig(accountUpdateKey, publicKeys[1], options[1])
        
        let feePayerKey = accountKeyRoleBased.roleFeePayerKey
        XCTAssertTrue(feePayerKey is AccountKeyWeightedMultiSig)
        try checkAccountKeyWeightedMultiSig(feePayerKey, publicKeys[2], options[2])
    }
    
    public func testCreateToAccountKeyRoleBased_compressed() throws {
        let address = "0xab9825316619a0720ad891135e92adb84fd74fc1"
        let publicKeys = [
        ["0x02b86b2787e8c7accd7d2d82678c9bef047a0aafd72a6e690817506684e8513c9a",
         "0x02e4d4901155edabc2bd5b356c63e58af20fe0a74e5f210de6396b74094f40215d"
        ],
        ["0x031a909c4d7dbb5281b1d1b55e79a1b2568111bd2830246c3173ce824000eb8716",
         "0x021427ac6351bbfc15811e8e5389a674b01d7a2c253e69a6ed30a33583864368f6",
         "0x0290fe4bb78bc981a40874ebcff2f9de4eba1e59ecd7a271a37814413720a3a5ea"
        ],
        ["0x0291245244462b3eee6436d3dc0ba3f69ef413fe2296c729733eff891a55f70c02",
         "0x0277e05dd93cdd6362f8648447f33d5676cbc5f42f4c4946ae1ad62bd4c0c4f357",
         "0x03d3bb14320d87eed081ae44740b5abbc52bac2c7ccf85b6281a0fc69f3ba4c171",
         "0x03cfa4d1bee51e59e6842b136ff95b9d01385f94bed13c4be8996c6d20cb732c3e"
        ]]

        let optionWeight = [
            [BigInt(1), BigInt(1)],
            [BigInt(1), BigInt(1), BigInt(2)],
            [BigInt(1), BigInt(1), BigInt(2), BigInt(2)]
        ]
        let options = [try WeightedMultiSigOptions(BigInt(2), optionWeight[0]),
                       try WeightedMultiSigOptions(BigInt(2), optionWeight[1]),
                       try WeightedMultiSigOptions(BigInt(3), optionWeight[2])]
        
        let account = try Account.create(address, publicKeys, options)
        XCTAssertEqual(address, account.address)
        
        XCTAssertTrue(account.accountKey is AccountKeyRoleBased)
        let accountKeyRoleBased = account.accountKey as! AccountKeyRoleBased
        
        let txKey = accountKeyRoleBased.roleTransactionKey
        XCTAssertTrue(txKey is AccountKeyWeightedMultiSig)
        try checkAccountKeyWeightedMultiSig(txKey, publicKeys[0], options[0])
        
        let accountUpdateKey = accountKeyRoleBased.roleAccountUpdateKey
        XCTAssertTrue(accountUpdateKey is AccountKeyWeightedMultiSig)
        try checkAccountKeyWeightedMultiSig(accountUpdateKey, publicKeys[1], options[1])
        
        let feePayerKey = accountKeyRoleBased.roleFeePayerKey
        XCTAssertTrue(feePayerKey is AccountKeyWeightedMultiSig)
        try checkAccountKeyWeightedMultiSig(feePayerKey, publicKeys[2], options[2])
    }
    
    public func testCreateToAccountKeyRoleBased_noOption() throws {
        let address = "0xab9825316619a0720ad891135e92adb84fd74fc1"
        let publicKeys = [
        ["0x02b86b2787e8c7accd7d2d82678c9bef047a0aafd72a6e690817506684e8513c9a",
         "0x02e4d4901155edabc2bd5b356c63e58af20fe0a74e5f210de6396b74094f40215d"
        ],
        ["0x031a909c4d7dbb5281b1d1b55e79a1b2568111bd2830246c3173ce824000eb8716",
         "0x021427ac6351bbfc15811e8e5389a674b01d7a2c253e69a6ed30a33583864368f6",
         "0x0290fe4bb78bc981a40874ebcff2f9de4eba1e59ecd7a271a37814413720a3a5ea"
        ],
        ["0x0291245244462b3eee6436d3dc0ba3f69ef413fe2296c729733eff891a55f70c02",
         "0x0277e05dd93cdd6362f8648447f33d5676cbc5f42f4c4946ae1ad62bd4c0c4f357",
         "0x03d3bb14320d87eed081ae44740b5abbc52bac2c7ccf85b6281a0fc69f3ba4c171",
         "0x03cfa4d1bee51e59e6842b136ff95b9d01385f94bed13c4be8996c6d20cb732c3e"
        ]]

        let optionWeight = [
            [BigInt(1), BigInt(1)],
            [BigInt(1), BigInt(1), BigInt(1)],
            [BigInt(1), BigInt(1), BigInt(1), BigInt(1)]
        ]
        let options = [try WeightedMultiSigOptions(BigInt(1), optionWeight[0]),
                       try WeightedMultiSigOptions(BigInt(1), optionWeight[1]),
                       try WeightedMultiSigOptions(BigInt(1), optionWeight[2])]
        
        let account = try Account.create(address, publicKeys, options)
        XCTAssertEqual(address, account.address)
        
        XCTAssertTrue(account.accountKey is AccountKeyRoleBased)
        let accountKeyRoleBased = account.accountKey as! AccountKeyRoleBased
        
        let txKey = accountKeyRoleBased.roleTransactionKey
        XCTAssertTrue(txKey is AccountKeyWeightedMultiSig)
        try checkAccountKeyWeightedMultiSig(txKey, publicKeys[0], options[0])
        
        let accountUpdateKey = accountKeyRoleBased.roleAccountUpdateKey
        XCTAssertTrue(accountUpdateKey is AccountKeyWeightedMultiSig)
        try checkAccountKeyWeightedMultiSig(accountUpdateKey, publicKeys[1], options[1])
        
        let feePayerKey = accountKeyRoleBased.roleFeePayerKey
        XCTAssertTrue(feePayerKey is AccountKeyWeightedMultiSig)
        try checkAccountKeyWeightedMultiSig(feePayerKey, publicKeys[2], options[2])
    }
    
    public func testCreateToAccountKeyRoleBased_noOption_AccountKeyPublic() throws {
        let address = "0xab9825316619a0720ad891135e92adb84fd74fc1"
        let publicKeys = [
        ["0x02b86b2787e8c7accd7d2d82678c9bef047a0aafd72a6e690817506684e8513c9a"
        ],
        ["0x031a909c4d7dbb5281b1d1b55e79a1b2568111bd2830246c3173ce824000eb8716",
         "0x021427ac6351bbfc15811e8e5389a674b01d7a2c253e69a6ed30a33583864368f6",
         "0x0290fe4bb78bc981a40874ebcff2f9de4eba1e59ecd7a271a37814413720a3a5ea"
        ],
        ["0x0291245244462b3eee6436d3dc0ba3f69ef413fe2296c729733eff891a55f70c02",
         "0x0277e05dd93cdd6362f8648447f33d5676cbc5f42f4c4946ae1ad62bd4c0c4f357",
         "0x03d3bb14320d87eed081ae44740b5abbc52bac2c7ccf85b6281a0fc69f3ba4c171",
         "0x03cfa4d1bee51e59e6842b136ff95b9d01385f94bed13c4be8996c6d20cb732c3e"
        ]]

        let optionWeight = [
            [BigInt(1), BigInt(1)],
            [BigInt(1), BigInt(1), BigInt(1)],
            [BigInt(1), BigInt(1), BigInt(1), BigInt(1)]
        ]
        let expectedOptions = [WeightedMultiSigOptions(),
                       try WeightedMultiSigOptions(BigInt(1), optionWeight[1]),
                       try WeightedMultiSigOptions(BigInt(1), optionWeight[2])]
        
        let account = try Account.create(address, publicKeys)
        XCTAssertEqual(address, account.address)
        
        XCTAssertTrue(account.accountKey is AccountKeyRoleBased)
        let accountKeyRoleBased = account.accountKey as! AccountKeyRoleBased
        
        let txKey = accountKeyRoleBased.roleTransactionKey
        XCTAssertTrue(txKey is AccountKeyPublic)
        try checkAccountKeyPublic(txKey, publicKeys[0][0])
        
        let accountUpdateKey = accountKeyRoleBased.roleAccountUpdateKey
        XCTAssertTrue(accountUpdateKey is AccountKeyWeightedMultiSig)
        try checkAccountKeyWeightedMultiSig(accountUpdateKey, publicKeys[1], expectedOptions[1])
        
        let feePayerKey = accountKeyRoleBased.roleFeePayerKey
        XCTAssertTrue(feePayerKey is AccountKeyWeightedMultiSig)
        try checkAccountKeyWeightedMultiSig(feePayerKey, publicKeys[2], expectedOptions[2])
    }
    
    public func testCreateFromRLPEncoding_AccountKeyLegacy() throws {
        let address = "0xab9825316619a0720ad891135e92adb84fd74fc1"
        let rlpEncodedAccountKey = "0x01c0"

        let account = try Account.createFromRLPEncoding(address, rlpEncodedAccountKey)
        XCTAssertEqual(address, account.address)
        XCTAssertTrue(account.accountKey is AccountKeyLegacy)
    }
    
    public func testCreateFromRLPEncoding_AccountKeyPublic() throws {
        let address = "0xab9825316619a0720ad891135e92adb84fd74fc1"
        let expectedPubKey = "0xc10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9803a1898f45b2770eda7abce70e8503b5e82b748ec0ce557ac9f4f4796965e4e"
        let rlpEncodedAccountKey = "0x02a102c10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9"

        let account = try Account.createFromRLPEncoding(address, rlpEncodedAccountKey)
        XCTAssertEqual(address, account.address)
        XCTAssertTrue(account.accountKey is AccountKeyPublic)
        try checkAccountKeyPublic(account.accountKey, expectedPubKey)
    }
    
    public func testCreateFromRLPEncoding_AccountKeyFail() throws {
        let address = "0xab9825316619a0720ad891135e92adb84fd74fc1"
        let rlpEncodedAccountKey = "0x03c0"

        let account = try Account.createFromRLPEncoding(address, rlpEncodedAccountKey)
        XCTAssertEqual(address, account.address)
        XCTAssertTrue(account.accountKey is AccountKeyFail)
    }
    
    public func testCreateFromRLPEncoding_AccountKeyWeightedMultiSig() throws {
        let address = "0xab9825316619a0720ad891135e92adb84fd74fc1"
        let expectPublicKey = [
            "0xc10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9803a1898f45b2770eda7abce70e8503b5e82b748ec0ce557ac9f4f4796965e4e",
            "0x1769a9196f523c419be50c26419ebbec34d3d6aa8b59da834212f13dbec9a9c12a4d0eeb91d7bd5d592653d43dd0593cfe24cb20a5dbef05832932e7c7191bf6"]
        let weights = [BigInt(1), BigInt(1)]
        let expectedOption = try WeightedMultiSigOptions(BigInt(2), weights)
        let rlpEncodedAccountKey = "0x04f84b02f848e301a102c10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9e301a1021769a9196f523c419be50c26419ebbec34d3d6aa8b59da834212f13dbec9a9c1"

        let account = try Account.createFromRLPEncoding(address, rlpEncodedAccountKey)
        XCTAssertEqual(address, account.address)
        try checkAccountKeyWeightedMultiSig(account.accountKey, expectPublicKey, expectedOption)
    }
    
    public func testCreateFromRLPEncoding_AccountKeyRoleBased() throws {
        let address = "0xab9825316619a0720ad891135e92adb84fd74fc1"
        let publicKeys = [
        ["0x6250dad4985bc22c8b9b84d1a05624c4daa0e83c8ae8fb35702d9024a8c14a7117bc107912634970e82bc5450d28d6d1dcfa03f7d759d06b6be5ba96efd9eb95"],
        ["0xc10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9803a1898f45b2770eda7abce70e8503b5e82b748ec0ce557ac9f4f4796965e4e",
         "0x1769a9196f523c419be50c26419ebbec34d3d6aa8b59da834212f13dbec9a9c12a4d0eeb91d7bd5d592653d43dd0593cfe24cb20a5dbef05832932e7c7191bf6"],
        ["0xe7615d056e770b3262e5b39a4823c3124989924ed4dcfab13f10b252701540d4958423c3e2c2a45a9e0e4671b078c8763c3724416f3c6443279ebb9b967ab055",
         "0x6f21d60c16200d99e6777422470b3122b65850d5135a5a4b41344a5607a1446d3a16e2e0f06d767ca158a1daf2463d78012287fd6503d1546229fdb1af532083"]]
        let optionWeight = [[BigInt(1), BigInt(1)],
                       [BigInt(1), BigInt(1)]]
        let expectedOption = [
            WeightedMultiSigOptions(),
            try WeightedMultiSigOptions(BigInt(2), optionWeight[0]),
            try WeightedMultiSigOptions(BigInt(1), optionWeight[1])
        ]
        let rlpEncodedKey = "0x05f8c4a302a1036250dad4985bc22c8b9b84d1a05624c4daa0e83c8ae8fb35702d9024a8c14a71b84e04f84b02f848e301a102c10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9e301a1021769a9196f523c419be50c26419ebbec34d3d6aa8b59da834212f13dbec9a9c1b84e04f84b01f848e301a103e7615d056e770b3262e5b39a4823c3124989924ed4dcfab13f10b252701540d4e301a1036f21d60c16200d99e6777422470b3122b65850d5135a5a4b41344a5607a1446d"

        let account = try Account.createFromRLPEncoding(address, rlpEncodedKey)
        XCTAssertEqual(address, account.address)
        XCTAssertTrue(account.accountKey is AccountKeyRoleBased)
        
        let accountKeyRoleBased = account.accountKey as! AccountKeyRoleBased
        let transaction = accountKeyRoleBased.roleTransactionKey
        XCTAssertTrue(transaction is AccountKeyPublic)
        try checkAccountKeyPublic(transaction, publicKeys[0][0])
        
        let accountUpdate = accountKeyRoleBased.roleAccountUpdateKey
        XCTAssertTrue(accountUpdate is AccountKeyWeightedMultiSig)
        try checkAccountKeyWeightedMultiSig(accountUpdate, publicKeys[1], expectedOption[1])
        
        let feePayerKey = accountKeyRoleBased.roleFeePayerKey
        XCTAssertTrue(feePayerKey is AccountKeyWeightedMultiSig)
        try checkAccountKeyWeightedMultiSig(feePayerKey, publicKeys[2], expectedOption[2])
    }
    
    public func testCreateFromRLPEncoding_AccountKeyRoleBasedWithAccountNil() throws {
        let address = "0xab9825316619a0720ad891135e92adb84fd74fc1"
        let publicKeys = [
        ["0x6250dad4985bc22c8b9b84d1a05624c4daa0e83c8ae8fb35702d9024a8c14a7117bc107912634970e82bc5450d28d6d1dcfa03f7d759d06b6be5ba96efd9eb95"],
        [],
        ["0xe7615d056e770b3262e5b39a4823c3124989924ed4dcfab13f10b252701540d4958423c3e2c2a45a9e0e4671b078c8763c3724416f3c6443279ebb9b967ab055",
         "0x6f21d60c16200d99e6777422470b3122b65850d5135a5a4b41344a5607a1446d3a16e2e0f06d767ca158a1daf2463d78012287fd6503d1546229fdb1af532083"]]
        let optionWeight = [
            [BigInt(1), BigInt(1)],
            [BigInt(1), BigInt(1)]]
        let expectedOption = [
            WeightedMultiSigOptions(),
            WeightedMultiSigOptions(),
            try WeightedMultiSigOptions(BigInt(1), optionWeight[1])
        ]
        let rlpEncodedKey = "0x05f876a302a1036250dad4985bc22c8b9b84d1a05624c4daa0e83c8ae8fb35702d9024a8c14a718180b84e04f84b01f848e301a103e7615d056e770b3262e5b39a4823c3124989924ed4dcfab13f10b252701540d4e301a1036f21d60c16200d99e6777422470b3122b65850d5135a5a4b41344a5607a1446d"

        let account = try Account.createFromRLPEncoding(address, rlpEncodedKey)
        XCTAssertEqual(address, account.address)
        XCTAssertTrue(account.accountKey is AccountKeyRoleBased)
        
        let accountKeyRoleBased = account.accountKey as! AccountKeyRoleBased
        let transaction = accountKeyRoleBased.roleTransactionKey
        XCTAssertTrue(transaction is AccountKeyPublic)
        try checkAccountKeyPublic(transaction, publicKeys[0][0])
        
        let accountUpdate = accountKeyRoleBased.roleAccountUpdateKey
        XCTAssertTrue(accountUpdate is AccountKeyNil)
        
        let feePayerKey = accountKeyRoleBased.roleFeePayerKey
        XCTAssertTrue(feePayerKey is AccountKeyWeightedMultiSig)
        try checkAccountKeyWeightedMultiSig(feePayerKey, publicKeys[2], expectedOption[2])
    }
    
    public func testCreateWithAccountKeyLegacy() throws {
        let address = "0xab9825316619a0720ad891135e92adb84fd74fc1"
        
        let account = Account.createWithAccountKeyLegacy(address)
        XCTAssertEqual(address, account.address)
        XCTAssertTrue(account.accountKey is AccountKeyLegacy)
    }
    
    public func testCreateWithAccountKeyPublic_uncompressed() throws {
        let address = "0xab9825316619a0720ad891135e92adb84fd74fc1"
        let publicKey = "0x1e3aec6e8bd8247aea112c3d1094566272974e56bb0151c58745847e2998ad0e5e8360b120dceea794c6cb1e4215208a78c82e8df5dcf1ac9aa73f1568ee5f2e"
        
        let account = Account.createWithAccountKeyPublic(address, publicKey)
        XCTAssertEqual(address, account.address)
        XCTAssertTrue(account.accountKey is AccountKeyPublic)
        try checkAccountKeyPublic(account.accountKey, publicKey)
    }
    
    public func testCreateWithAccountKeyPublic_compressed() throws {
        let address = "0xab9825316619a0720ad891135e92adb84fd74fc1"
        let publicKey = "0x021e3aec6e8bd8247aea112c3d1094566272974e56bb0151c58745847e2998ad0e"
        
        let account = Account.createWithAccountKeyPublic(address, publicKey)
        XCTAssertEqual(address, account.address)
        XCTAssertTrue(account.accountKey is AccountKeyPublic)
        try checkAccountKeyPublic(account.accountKey, publicKey)
    }
    
    public func testCreateWithAccountKeyFail() throws {
        let address = "0xab9825316619a0720ad891135e92adb84fd74fc1"
        
        let account = Account.createWithAccountKeyFail(address)
        XCTAssertEqual(address, account.address)
        XCTAssertTrue(account.accountKey is AccountKeyFail)
    }
    
    public func testCreateWithAccountWeightedMultiSig() throws {
        let address = "0xab9825316619a0720ad891135e92adb84fd74fc1"
        let expectPublicKey = [
            "0xc10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9803a1898f45b2770eda7abce70e8503b5e82b748ec0ce557ac9f4f4796965e4e",
            "0x1769a9196f523c419be50c26419ebbec34d3d6aa8b59da834212f13dbec9a9c12a4d0eeb91d7bd5d592653d43dd0593cfe24cb20a5dbef05832932e7c7191bf6"]
        
        let weights = [BigInt(1), BigInt(1)]
        let expectedOption = try WeightedMultiSigOptions(BigInt(2), weights)
        
        let account = try Account.createWithAccountKeyWeightedMultiSig(address, expectPublicKey, expectedOption)
        XCTAssertEqual(address, account.address)
        try checkAccountKeyWeightedMultiSig(account.accountKey, expectPublicKey, expectedOption)
    }
    
    public func testCreateWithAccountWeightedMultiSig_NoOption() throws {
        let address = "0xab9825316619a0720ad891135e92adb84fd74fc1"
        let expectPublicKey = [
            "0xc10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9803a1898f45b2770eda7abce70e8503b5e82b748ec0ce557ac9f4f4796965e4e",
            "0x1769a9196f523c419be50c26419ebbec34d3d6aa8b59da834212f13dbec9a9c12a4d0eeb91d7bd5d592653d43dd0593cfe24cb20a5dbef05832932e7c7191bf6"]
        
        let weights = [BigInt(1), BigInt(1)]
        let expectedOption = try WeightedMultiSigOptions(BigInt(1), weights)
        
        let account = try Account.createWithAccountKeyWeightedMultiSig(address, expectPublicKey)
        XCTAssertEqual(address, account.address)
        try checkAccountKeyWeightedMultiSig(account.accountKey, expectPublicKey, expectedOption)
    }
    
    public func testCreateWithAccountRoleBased() throws {
        let address = "0xab9825316619a0720ad891135e92adb84fd74fc1"
        let publicKeys = [
        ["0x6250dad4985bc22c8b9b84d1a05624c4daa0e83c8ae8fb35702d9024a8c14a7117bc107912634970e82bc5450d28d6d1dcfa03f7d759d06b6be5ba96efd9eb95"],
        ["0xc10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9803a1898f45b2770eda7abce70e8503b5e82b748ec0ce557ac9f4f4796965e4e",
         "0x1769a9196f523c419be50c26419ebbec34d3d6aa8b59da834212f13dbec9a9c12a4d0eeb91d7bd5d592653d43dd0593cfe24cb20a5dbef05832932e7c7191bf6"],
        ["0xe7615d056e770b3262e5b39a4823c3124989924ed4dcfab13f10b252701540d4958423c3e2c2a45a9e0e4671b078c8763c3724416f3c6443279ebb9b967ab055",
         "0x6f21d60c16200d99e6777422470b3122b65850d5135a5a4b41344a5607a1446d3a16e2e0f06d767ca158a1daf2463d78012287fd6503d1546229fdb1af532083"]]
        let optionWeight = [
            [BigInt(1), BigInt(1)],
            [BigInt(1), BigInt(1)]]
        let expectedOption = [
            WeightedMultiSigOptions(),
            try WeightedMultiSigOptions(BigInt(2), optionWeight[0]),
            try WeightedMultiSigOptions(BigInt(1), optionWeight[1])
        ]
        
        
        let account = try Account.createWithAccountKeyRoleBased(address, publicKeys, expectedOption)
        XCTAssertEqual(address, account.address)
        XCTAssertTrue(account.accountKey is AccountKeyRoleBased)
        
        let accountKeyRoleBased = account.accountKey as! AccountKeyRoleBased
        let transaction = accountKeyRoleBased.roleTransactionKey
        XCTAssertTrue(transaction is AccountKeyPublic)
        try checkAccountKeyPublic(transaction, publicKeys[0][0])
        
        let accountUpdate = accountKeyRoleBased.roleAccountUpdateKey
        XCTAssertTrue(accountUpdate is AccountKeyWeightedMultiSig)
        try checkAccountKeyWeightedMultiSig(accountUpdate, publicKeys[1], expectedOption[1])
        
        let feePayerKey = accountKeyRoleBased.roleFeePayerKey
        XCTAssertTrue(feePayerKey is AccountKeyWeightedMultiSig)
        try checkAccountKeyWeightedMultiSig(feePayerKey, publicKeys[2], expectedOption[2])
    }
    
    public func testCreateWithAccountRoleBased_NoOption() throws {
        let address = "0xab9825316619a0720ad891135e92adb84fd74fc1"
        let publicKeys = [
        ["0x6250dad4985bc22c8b9b84d1a05624c4daa0e83c8ae8fb35702d9024a8c14a7117bc107912634970e82bc5450d28d6d1dcfa03f7d759d06b6be5ba96efd9eb95",
         "0x1e3aec6e8bd8247aea112c3d1094566272974e56bb0151c58745847e2998ad0e5e8360b120dceea794c6cb1e4215208a78c82e8df5dcf1ac9aa73f1568ee5f2e"],
        ["0xc10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9803a1898f45b2770eda7abce70e8503b5e82b748ec0ce557ac9f4f4796965e4e",
         "0x1769a9196f523c419be50c26419ebbec34d3d6aa8b59da834212f13dbec9a9c12a4d0eeb91d7bd5d592653d43dd0593cfe24cb20a5dbef05832932e7c7191bf6"],
        ["0xe7615d056e770b3262e5b39a4823c3124989924ed4dcfab13f10b252701540d4958423c3e2c2a45a9e0e4671b078c8763c3724416f3c6443279ebb9b967ab055",
         "0x6f21d60c16200d99e6777422470b3122b65850d5135a5a4b41344a5607a1446d3a16e2e0f06d767ca158a1daf2463d78012287fd6503d1546229fdb1af532083"]]
        let optionWeight = [
            [BigInt(1), BigInt(1)],
            [BigInt(1), BigInt(1)],
            [BigInt(1), BigInt(1)]]
        let expectedOption = [
            try WeightedMultiSigOptions(BigInt(1), optionWeight[0]),
            try WeightedMultiSigOptions(BigInt(1), optionWeight[1]),
            try WeightedMultiSigOptions(BigInt(1), optionWeight[2])
        ]
        
        
        let account = try Account.createWithAccountKeyRoleBased(address, publicKeys)
        XCTAssertEqual(address, account.address)
        XCTAssertTrue(account.accountKey is AccountKeyRoleBased)
        
        let accountKeyRoleBased = account.accountKey as! AccountKeyRoleBased
        let transaction = accountKeyRoleBased.roleTransactionKey
        XCTAssertTrue(transaction is AccountKeyWeightedMultiSig)
        try checkAccountKeyWeightedMultiSig(transaction, publicKeys[0], expectedOption[0])
        
        let accountUpdate = accountKeyRoleBased.roleAccountUpdateKey
        XCTAssertTrue(accountUpdate is AccountKeyWeightedMultiSig)
        try checkAccountKeyWeightedMultiSig(accountUpdate, publicKeys[1], expectedOption[1])
        
        let feePayerKey = accountKeyRoleBased.roleFeePayerKey
        XCTAssertTrue(feePayerKey is AccountKeyWeightedMultiSig)
        try checkAccountKeyWeightedMultiSig(feePayerKey, publicKeys[2], expectedOption[2])
    }
    
    public func testGetRLPEncodingAccountKey_AccountKeyLegacy() throws {
        let address = "0xab9825316619a0720ad891135e92adb84fd74fc1"
        let rlpEncodedAccountKey = "0x01c0"
        
        let account = try Account.createFromRLPEncoding(address, rlpEncodedAccountKey)
        XCTAssertEqual(address, account.address)
        XCTAssertTrue(account.accountKey is AccountKeyLegacy)
        XCTAssertEqual(rlpEncodedAccountKey, try account.getRLPEncodingAccountKey())
    }
    
    public func testGetRLPEncodingAccountKey_AccountKeyPublic() throws {
        let address = "0xab9825316619a0720ad891135e92adb84fd74fc1"
        let rlpEncodedAccountKey = "0x02a102c10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9"
        
        let account = try Account.createFromRLPEncoding(address, rlpEncodedAccountKey)
        XCTAssertEqual(address, account.address)
        XCTAssertTrue(account.accountKey is AccountKeyPublic)
        XCTAssertEqual(rlpEncodedAccountKey, try account.getRLPEncodingAccountKey())
    }
    
    public func testGetRLPEncodingAccountKey_AccountKeyFail() throws {
        let address = "0xab9825316619a0720ad891135e92adb84fd74fc1"
        let rlpEncodedAccountKey = "0x03c0"
        
        let account = try Account.createFromRLPEncoding(address, rlpEncodedAccountKey)
        XCTAssertEqual(address, account.address)
        XCTAssertTrue(account.accountKey is AccountKeyFail)
        XCTAssertEqual(rlpEncodedAccountKey, try account.getRLPEncodingAccountKey())
    }
    
    public func testGetRLPEncodingAccountKey_AccountKeyWeightedMultiSig() throws {
        let address = "0xab9825316619a0720ad891135e92adb84fd74fc1"
        let rlpEncodedAccountKey = "0x04f84b02f848e301a102c10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9e301a1021769a9196f523c419be50c26419ebbec34d3d6aa8b59da834212f13dbec9a9c1"
        
        let account = try Account.createFromRLPEncoding(address, rlpEncodedAccountKey)
        XCTAssertEqual(address, account.address)
        XCTAssertTrue(account.accountKey is AccountKeyWeightedMultiSig)
        XCTAssertEqual(rlpEncodedAccountKey, try account.getRLPEncodingAccountKey())
    }
    
    public func testGetRLPEncodingAccountKey_AccountKeyRoleBased() throws {
        let address = "0xab9825316619a0720ad891135e92adb84fd74fc1"
        let rlpEncodedAccountKey = "0x05f8c4a302a1036250dad4985bc22c8b9b84d1a05624c4daa0e83c8ae8fb35702d9024a8c14a71b84e04f84b02f848e301a102c10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9e301a1021769a9196f523c419be50c26419ebbec34d3d6aa8b59da834212f13dbec9a9c1b84e04f84b01f848e301a103e7615d056e770b3262e5b39a4823c3124989924ed4dcfab13f10b252701540d4e301a1036f21d60c16200d99e6777422470b3122b65850d5135a5a4b41344a5607a1446d"
        
        let account = try Account.createFromRLPEncoding(address, rlpEncodedAccountKey)
        XCTAssertEqual(address, account.address)
        XCTAssertTrue(account.accountKey is AccountKeyRoleBased)
        XCTAssertEqual(rlpEncodedAccountKey, try account.getRLPEncodingAccountKey())
    }
    
    public func testGetRLPEncodingAccountKey_AccountKeyRoleBasedWithAccountNil() throws {
        let address = "0xab9825316619a0720ad891135e92adb84fd74fc1"
        let rlpEncodedAccountKey = "0x05f876a302a1036250dad4985bc22c8b9b84d1a05624c4daa0e83c8ae8fb35702d9024a8c14a718180b84e04f84b01f848e301a103e7615d056e770b3262e5b39a4823c3124989924ed4dcfab13f10b252701540d4e301a1036f21d60c16200d99e6777422470b3122b65850d5135a5a4b41344a5607a1446d"
        
        let account = try Account.createFromRLPEncoding(address, rlpEncodedAccountKey)
        XCTAssertEqual(address, account.address)
        XCTAssertTrue(account.accountKey is AccountKeyRoleBased)
        XCTAssertEqual(rlpEncodedAccountKey, try account.getRLPEncodingAccountKey())
    }
}
