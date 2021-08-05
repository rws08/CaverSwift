//
//  AccountKeyTest.swift
//  CaverSwiftTests
//
//  Created by won on 2021/06/23.
//

import XCTest
@testable import CaverSwift
@testable import BigInt

class AccountKeyTest_FailTests: XCTestCase {
    func testDecodeWithString() throws {
        let encodedString = "0x03c0"
        let accountKeyFail = try? AccountKeyFail.decode(encodedString)
        XCTAssertTrue(accountKeyFail != nil)
    }
    
    func testDecodeWithByteArray() throws {
        let encodedArr = Data([0x03, 0xc0])
        let accountKeyFail = try? AccountKeyFail.decode(encodedArr)
        XCTAssertTrue(accountKeyFail != nil)
    }
    
    func testDecodeWithString_throwException() throws {
        let encodedString = "0x03"
        let accountKeyFail = try? AccountKeyFail.decode(encodedString)
        XCTAssertFalse(accountKeyFail != nil)
    }
    
    func testDecodeWithByteArray_throwException() throws {
        let encodedArr = Data([0x03])
        let accountKeyFail = try? AccountKeyFail.decode(encodedArr)
        XCTAssertFalse(accountKeyFail != nil)
    }
    
    func testEncodeKey() throws {
        let encodedString = "0x03c0"
        let accountKeyFail = AccountKeyFail()
        XCTAssertEqual(encodedString, accountKeyFail.getRLPEncoding())
    }
}

class AccountKeyTest_LegacyTest: XCTestCase {
    func testDecodeWithString() throws {
        let encodedString = "0x01c0"
        let accountKeyFail = try? AccountKeyLegacy.decode(encodedString)
        XCTAssertTrue(accountKeyFail != nil)
    }
    
    func testDecodeWithByteArray() throws {
        let encodedArr = Data([0x01, 0xc0])
        let accountKeyFail = try? AccountKeyLegacy.decode(encodedArr)
        XCTAssertTrue(accountKeyFail != nil)
    }
    
    func testDecodeWithString_throwException() throws {
        let encodedString = "0x01"
        let accountKeyFail = try? AccountKeyLegacy.decode(encodedString)
        XCTAssertFalse(accountKeyFail != nil)
    }
    
    func testDecodeWithByteArray_throwException() throws {
        let encodedArr = Data([0x01])
        let accountKeyFail = try? AccountKeyLegacy.decode(encodedArr)
        XCTAssertFalse(accountKeyFail != nil)
    }
    
    func testEncodeKey() throws {
        let encodedString = "0x01c0"
        let accountKeyFail = AccountKeyLegacy()
        XCTAssertEqual(encodedString, accountKeyFail.getRLPEncoding())
    }
}

class AccountKeyTest_PublicTest: XCTestCase {
    func testDecodeWithString() throws {
        let expectedAccountKey = "0xc10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9803a1898f45b2770eda7abce70e8503b5e82b748ec0ce557ac9f4f4796965e4e"
        let actualEncodedKey = "0x02a102c10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9"

        guard let accountKeyPublic = try? AccountKeyPublic.decode(actualEncodedKey) else { XCTAssert(false)
            return }
        XCTAssertEqual(expectedAccountKey, accountKeyPublic.publicKey)
    }
    
    func testDecodeWithByteArray() throws {
        let expectedAccountKey = "0xc10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9803a1898f45b2770eda7abce70e8503b5e82b748ec0ce557ac9f4f4796965e4e"
        let actualEncodedKey = "0x02a102c10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9"

        guard let actualEncodedKeyArr = actualEncodedKey.bytesFromHex,
              let accountKeyPublic = try? AccountKeyPublic.decode(actualEncodedKeyArr) else { XCTAssert(false)
            return }
        XCTAssertEqual(expectedAccountKey, accountKeyPublic.publicKey)
    }
    
    func testDecodeWithString_throwException() throws {
        let invalidEncodedValue = "0x03a102c10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9"

        XCTAssertThrowsError(try AccountKeyPublic.decode(invalidEncodedValue)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid RLP-encoded AccountKeyPublic Tag"))
        }
    }
    
    func testDecodeWithByteArray_throwException() throws {
        guard let invalidEncodedValue = "0x03a102c10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9".bytesFromHex else { XCTAssert(false)
            return }

        XCTAssertThrowsError(try AccountKeyPublic.decode(invalidEncodedValue)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid RLP-encoded AccountKeyPublic Tag"))
        }
    }
    
    func testFromXYPoint() throws {
        let publicKey = "0x022dfe0d7c496d954037ab15afd3352008f6c5bfe972850b7b321e96721f4bf11f7e6aa508dd50af53e190dcd4a2559aa1c3ef3f78b97b97e2928ac33e038464"
        let noPrefixPubKey = publicKey.cleanHexPrefix
        
        let x = String(noPrefixPubKey[0..<64])
        let y = String(noPrefixPubKey[64..<noPrefixPubKey.count])

        guard let accountKeyPublic = try? AccountKeyPublic.fromXYPoint(x, y) else { XCTAssert(false)
            return }
        XCTAssertEqual(publicKey, accountKeyPublic.publicKey)
    }
    
    func testFromPublicKey_uncompressedFormat() throws {
        let publicKey = "0x022dfe0d7c496d954037ab15afd3352008f6c5bfe972850b7b321e96721f4bf11f7e6aa508dd50af53e190dcd4a2559aa1c3ef3f78b97b97e2928ac33e038464"

        XCTAssertEqual(publicKey, AccountKeyPublic.fromPublicKey(publicKey).publicKey)
    }
    
    func testFromPublicKey_compressedFormat() throws {
        let publicKey = "0x02022dfe0d7c496d954037ab15afd3352008f6c5bfe972850b7b321e96721f4bf1"

        XCTAssertEqual(publicKey, AccountKeyPublic.fromPublicKey(publicKey).publicKey)
    }
    
    func testGetXYPoint_uncompressedFormat() throws {
        let publicKey = "0x022dfe0d7c496d954037ab15afd3352008f6c5bfe972850b7b321e96721f4bf11f7e6aa508dd50af53e190dcd4a2559aa1c3ef3f78b97b97e2928ac33e038464"
        let noPrefixPubKey = publicKey.cleanHexPrefix
        
        let expectedX = String(noPrefixPubKey[0..<64])
        let expectedY = String(noPrefixPubKey[64..<noPrefixPubKey.count])
        
        let accountKeyPublic = AccountKeyPublic.fromPublicKey(publicKey)
        let arr = accountKeyPublic.getXYPoint()

        XCTAssertEqual(expectedX, arr[0])
        XCTAssertEqual(expectedY, arr[1])
    }
    
    func testGetXYPoint_compressedFormat() throws {
        let compressedPublicKey = "0x02022dfe0d7c496d954037ab15afd3352008f6c5bfe972850b7b321e96721f4bf1"
        
        let publicKey = "0x022dfe0d7c496d954037ab15afd3352008f6c5bfe972850b7b321e96721f4bf11f7e6aa508dd50af53e190dcd4a2559aa1c3ef3f78b97b97e2928ac33e038464"
        let noPrefixPubKey = publicKey.cleanHexPrefix
        
        let expectedX = String(noPrefixPubKey[0..<64])
        let expectedY = String(noPrefixPubKey[64..<noPrefixPubKey.count])
        
        let accountKeyPublic = AccountKeyPublic.fromPublicKey(compressedPublicKey)
        let arr = accountKeyPublic.getXYPoint()

        XCTAssertEqual(expectedX, arr[0])
        XCTAssertEqual(expectedY, arr[1])
    }
}

class AccountKeyTest_WeightedMultiSigTest: XCTestCase {
    func checkWeightedPublicKey(_ expectedPublicKey: [String], _ expectedOptions: WeightedMultiSigOptions, _ actualAccount: AccountKeyWeightedMultiSig) {
        //check Threshold
        XCTAssertEqual(expectedOptions.threshold, actualAccount.threshold)
        
        //check WeightedPublicKey
        zip(expectedPublicKey, zip(expectedOptions.weights, actualAccount.weightedPublicKeys)).forEach {
            XCTAssertEqual($1.0, $1.1.weight)
            guard let publicKey = try? Utils.decompressPublicKey($1.1.publicKey) else { XCTAssert(false)
            return }
            XCTAssertEqual($0, publicKey)
        }
    }
    
    func testDecodeWithString() throws {
        let expectedAccountKey = [
            "0xc10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9803a1898f45b2770eda7abce70e8503b5e82b748ec0ce557ac9f4f4796965e4e",
            "0x1769a9196f523c419be50c26419ebbec34d3d6aa8b59da834212f13dbec9a9c12a4d0eeb91d7bd5d592653d43dd0593cfe24cb20a5dbef05832932e7c7191bf6"]
        
        guard let expectedOption = try? WeightedMultiSigOptions(BigInt(2), [BigInt(1), BigInt(1)]) else { XCTAssert(false)
            return }
        let encodedKey = "0x04f84b02f848e301a102c10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9e301a1021769a9196f523c419be50c26419ebbec34d3d6aa8b59da834212f13dbec9a9c1"
        
        let multiSig = try AccountKeyWeightedMultiSig.decode(encodedKey)
        
        checkWeightedPublicKey(expectedAccountKey, expectedOption, multiSig)
    }
    
    func testDecodeWithByteArray() throws {
        let expectedAccountKey = [
            "0xc10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9803a1898f45b2770eda7abce70e8503b5e82b748ec0ce557ac9f4f4796965e4e",
            "0x1769a9196f523c419be50c26419ebbec34d3d6aa8b59da834212f13dbec9a9c12a4d0eeb91d7bd5d592653d43dd0593cfe24cb20a5dbef05832932e7c7191bf6"]
        
        guard let expectedOption = try? WeightedMultiSigOptions(BigInt(2), [BigInt(1), BigInt(1)]) else { XCTAssert(false)
            return }
        let encodedKey = "0x04f84b02f848e301a102c10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9e301a1021769a9196f523c419be50c26419ebbec34d3d6aa8b59da834212f13dbec9a9c1".bytesFromHex
        
        let multiSig = try AccountKeyWeightedMultiSig.decode(encodedKey!)
        
        checkWeightedPublicKey(expectedAccountKey, expectedOption, multiSig)
    }
    
    func testDecodeStringWithException() throws {
        let encodedKey = "0x03f84b02f848e301a102c10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9e301a1021769a9196f523c419be50c26419ebbec34d3d6aa8b59da834212f13dbec9a9c1"
                
        XCTAssertThrowsError(try AccountKeyWeightedMultiSig.decode(encodedKey)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid RLP-encoded AccountKeyWeightedMultiSig Tag"))
        }
    }
    
    func testDecodeByteArrayWithException() throws {
        let encodedKey = "0x03f84b02f848e301a102c10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9e301a1021769a9196f523c419be50c26419ebbec34d3d6aa8b59da834212f13dbec9a9c1".bytesFromHex
                
        XCTAssertThrowsError(try AccountKeyWeightedMultiSig.decode(encodedKey!)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid RLP-encoded AccountKeyWeightedMultiSig Tag"))
        }
    }
    
    func testFromPublicKeysAndOptions() throws {
        let expectedAccountKey = [
            "0xc10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9803a1898f45b2770eda7abce70e8503b5e82b748ec0ce557ac9f4f4796965e4e",
            "0x1769a9196f523c419be50c26419ebbec34d3d6aa8b59da834212f13dbec9a9c12a4d0eeb91d7bd5d592653d43dd0593cfe24cb20a5dbef05832932e7c7191bf6"]
        
        guard let expectedOption = try? WeightedMultiSigOptions(BigInt(2), [BigInt(1), BigInt(1)]) else { XCTAssert(false)
            return }
        
        let multiSig = try AccountKeyWeightedMultiSig.fromPublicKeysAndOptions(expectedAccountKey, expectedOption)
        
        checkWeightedPublicKey(expectedAccountKey, expectedOption, multiSig)
    }
    
    func testGetRLPEncoding() throws {
        let expectedEncodedData = "0x04f84b02f848e301a102c10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9e301a1021769a9196f523c419be50c26419ebbec34d3d6aa8b59da834212f13dbec9a9c1"
        let publicKey = [
            "0xc10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9803a1898f45b2770eda7abce70e8503b5e82b748ec0ce557ac9f4f4796965e4e",
            "0x1769a9196f523c419be50c26419ebbec34d3d6aa8b59da834212f13dbec9a9c12a4d0eeb91d7bd5d592653d43dd0593cfe24cb20a5dbef05832932e7c7191bf6"]
        
        guard let expectedOption = try? WeightedMultiSigOptions(BigInt(2), [BigInt(1), BigInt(1)]) else { XCTAssert(false)
            return }
        
        let multiSig = try AccountKeyWeightedMultiSig.fromPublicKeysAndOptions(publicKey, expectedOption)

        XCTAssertEqual(expectedEncodedData, try multiSig.getRLPEncoding())
    }
    
    func testWeightedMultiSigOptionTest_ThresholdCondition1() throws {
        XCTAssertThrowsError(try WeightedMultiSigOptions(BigInt(10), [BigInt(1), BigInt(1)])) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid argument in passing params."))
        }
    }
    
    func testWeightedMultiSigOptionTest_ThresholdCondition2() throws {
        XCTAssertThrowsError(try WeightedMultiSigOptions(BigInt.zero, [BigInt(1), BigInt(1)])) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid argument in passing params."))
        }
    }
    
    func testWeightedMultiSigOptionTest_WeightCount() throws {
        XCTAssertThrowsError(try WeightedMultiSigOptions(BigInt(2), [BigInt(1), BigInt(1), BigInt(1), BigInt(1), BigInt(1), BigInt(1), BigInt(1), BigInt(1), BigInt(1), BigInt(1), BigInt(1)])) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid argument in passing params."))
        }
    }
    
    func testFromPublicKeysAndOptionsWithException() throws {
        let publicKey = [
            "0xc10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9803a1898f45b2770eda7abce70e8503b5e82b748ec0ce557ac9f4f4796965e4e",
            "0x1769a9196f523c419be50c26419ebbec34d3d6aa8b59da834212f13dbec9a9c12a4d0eeb91d7bd5d592653d43dd0593cfe24cb20a5dbef05832932e7c7191bf6",
            "0xd31970913271bb571db505418414ae15e97337b944ef1bef84a0e5d20c2ece7f27a39deb8f449edea7cecf8f3588a51974f31d676a8b200fb61175149fff9b74",
            "0x68ad36b538afe09997af82bb92d056404feb93816b5ec6a5199bc1d6bb15358fa3cfb84ac7cab3275e973be6699cd19c61ba8c470fee97a9998bd0684cf44355"]
        
        guard let expectedOption = try? WeightedMultiSigOptions(BigInt(2), [BigInt(1), BigInt(1), BigInt(1)]) else { XCTAssert(false)
            return }
        
        XCTAssertThrowsError(try AccountKeyWeightedMultiSig.fromPublicKeysAndOptions(publicKey, expectedOption)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("The count of public keys is not equal to the length of weight array."))
        }
    }
    
    func testFromPublicKeysAndOptionsWithException2() throws {
        let publicKey = [
            "0xc10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9803a1898f45b2770eda7abce70e8503b5e82b748ec0ce557ac9f4f4796965e4e",
            "0x1769a9196f523c419be50c26419ebbec34d3d6aa8b59da834212f13dbec9a9c12a4d0eeb91d7bd5d592653d43dd0593cfe24cb20a5dbef05832932e7c7191bf6",
            "0xd31970913271bb571db505418414ae15e97337b944ef1bef84a0e5d20c2ece7f27a39deb8f449edea7cecf8f3588a51974f31d676a8b200fb61175149fff9b74",
            "0x68ad36b538afe09997af82bb92d056404feb93816b5ec6a5199bc1d6bb15358fa3cfb84ac7cab3275e973be6699cd19c61ba8c470fee97a9998bd0684cf44355",
            "0xc10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9803a1898f45b2770eda7abce70e8503b5e82b748ec0ce557ac9f4f4796965e4e",
            "0x1769a9196f523c419be50c26419ebbec34d3d6aa8b59da834212f13dbec9a9c12a4d0eeb91d7bd5d592653d43dd0593cfe24cb20a5dbef05832932e7c7191bf6",
            "0xd31970913271bb571db505418414ae15e97337b944ef1bef84a0e5d20c2ece7f27a39deb8f449edea7cecf8f3588a51974f31d676a8b200fb61175149fff9b74",
            "0x68ad36b538afe09997af82bb92d056404feb93816b5ec6a5199bc1d6bb15358fa3cfb84ac7cab3275e973be6699cd19c61ba8c470fee97a9998bd0684cf44355",
            "0xc10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9803a1898f45b2770eda7abce70e8503b5e82b748ec0ce557ac9f4f4796965e4e",
            "0x1769a9196f523c419be50c26419ebbec34d3d6aa8b59da834212f13dbec9a9c12a4d0eeb91d7bd5d592653d43dd0593cfe24cb20a5dbef05832932e7c7191bf6",
            "0xd31970913271bb571db505418414ae15e97337b944ef1bef84a0e5d20c2ece7f27a39deb8f449edea7cecf8f3588a51974f31d676a8b200fb61175149fff9b74",
            "0x68ad36b538afe09997af82bb92d056404feb93816b5ec6a5199bc1d6bb15358fa3cfb84ac7cab3275e973be6699cd19c61ba8c470fee97a9998bd0684cf44355"]
        
        guard let expectedOption = try? WeightedMultiSigOptions(BigInt(2), [BigInt(1), BigInt(1), BigInt(1)]) else { XCTAssert(false)
            return }
        
        XCTAssertThrowsError(try AccountKeyWeightedMultiSig.fromPublicKeysAndOptions(publicKey, expectedOption)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("It exceeds maximum public key count."))
        }
    }
}

class AccountKeyTest_RoleBasedTest: XCTestCase {
    func checkValid(_ expectedPublicKeyArr: [[String]], _ expectedOptionsList: [WeightedMultiSigOptions], _ actualRoleBasedKey: AccountKeyRoleBased) throws {
        let actualKeys = actualRoleBasedKey.accountKeys
        for i in [0..<AccountKeyRoleBased.ROLE_GROUP_COUNT] {
            guard let i = i.first else { XCTAssert(false)
            return }
            let key = actualKeys[i]
            if key is AccountKeyPublic {
                try checkAccountKeyPublic(expectedPublicKeyArr[i], expectedOptionsList[i], key as! AccountKeyPublic)
            }else if key is AccountKeyWeightedMultiSig {
                try checkAccountKeyWeightedMultiSig(expectedPublicKeyArr[i], expectedOptionsList[i], key as! AccountKeyWeightedMultiSig)
            }
        }
    }
    
    func checkPublicKey(_ expected: String, _ actual: String) throws {
        var expected = try Utils.compressPublicKey(expected)
        var actual = try Utils.compressPublicKey(actual)

        expected = expected.cleanHexPrefix
        actual = actual.cleanHexPrefix
        
        XCTAssertEqual(expected, actual)
    }
    
    func checkAccountKeyPublic(_ expectedKeys: [String], _ expectedOptions: WeightedMultiSigOptions, _ accountKeyPublic: AccountKeyPublic) throws {
        XCTAssertEqual(expectedKeys.count, 1)
        XCTAssertTrue(expectedOptions.isEmpty)
        
        try checkPublicKey(expectedKeys[0], accountKeyPublic.publicKey)
    }
    
    func checkAccountKeyWeightedMultiSig(_ expectedKeys: [String], _ expectedOptions: WeightedMultiSigOptions, _ accountKeyWeightedMultiSig: AccountKeyWeightedMultiSig) throws {
        XCTAssertEqual(expectedKeys.count, accountKeyWeightedMultiSig.weightedPublicKeys.count)
        XCTAssertEqual(expectedOptions.threshold, accountKeyWeightedMultiSig.threshold)
        
        try zip(accountKeyWeightedMultiSig.weightedPublicKeys, zip(expectedKeys, expectedOptions.weights)).forEach {
            try checkPublicKey($1.0, $0.publicKey)
            XCTAssertEqual($1.1, $0.weight)
        }
    }
    
    func testDecodeWithString() throws {
        let encodedData = "0x05f8c4a302a1036250dad4985bc22c8b9b84d1a05624c4daa0e83c8ae8fb35702d9024a8c14a71b84e04f84b02f848e301a102c10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9e301a1021769a9196f523c419be50c26419ebbec34d3d6aa8b59da834212f13dbec9a9c1b84e04f84b01f848e301a103e7615d056e770b3262e5b39a4823c3124989924ed4dcfab13f10b252701540d4e301a1036f21d60c16200d99e6777422470b3122b65850d5135a5a4b41344a5607a1446d"
        let expectedPublicKeyArr = [
                //expectedTransactionKey
                ["0x6250dad4985bc22c8b9b84d1a05624c4daa0e83c8ae8fb35702d9024a8c14a7117bc107912634970e82bc5450d28d6d1dcfa03f7d759d06b6be5ba96efd9eb95"],
                //expectedAccountUpdateKey
                ["0xc10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9803a1898f45b2770eda7abce70e8503b5e82b748ec0ce557ac9f4f4796965e4e",
                 "0x1769a9196f523c419be50c26419ebbec34d3d6aa8b59da834212f13dbec9a9c12a4d0eeb91d7bd5d592653d43dd0593cfe24cb20a5dbef05832932e7c7191bf6",
                ],
                //expectedFeePayedKey
                ["0xe7615d056e770b3262e5b39a4823c3124989924ed4dcfab13f10b252701540d4958423c3e2c2a45a9e0e4671b078c8763c3724416f3c6443279ebb9b967ab055",
                 "0x6f21d60c16200d99e6777422470b3122b65850d5135a5a4b41344a5607a1446d3a16e2e0f06d767ca158a1daf2463d78012287fd6503d1546229fdb1af532083"]
            ]

        let weightArr = [BigInt(1), BigInt(1)]

        let transactionKeyOptions = WeightedMultiSigOptions()
        let accountUpdateKeyOption = try WeightedMultiSigOptions(BigInt(2), weightArr)
        let feePayerKeyOption = try WeightedMultiSigOptions(BigInt(1), weightArr)

        let accountKey = try AccountKeyRoleBased.decode(encodedData)

        let transactionKey = accountKey.roleTransactionKey
        XCTAssertTrue(transactionKey is AccountKeyPublic)
        try checkAccountKeyPublic(expectedPublicKeyArr[0], transactionKeyOptions, transactionKey as! AccountKeyPublic)

        let accountUpdateKey = accountKey.roleAccountUpdateKey
        XCTAssertTrue(accountUpdateKey is AccountKeyWeightedMultiSig)
        try checkAccountKeyWeightedMultiSig(expectedPublicKeyArr[1], accountUpdateKeyOption, accountUpdateKey as! AccountKeyWeightedMultiSig)

        let feePayerKey = accountKey.roleFeePayerKey
        XCTAssertTrue(feePayerKey is AccountKeyWeightedMultiSig)
        try checkAccountKeyWeightedMultiSig(expectedPublicKeyArr[2], feePayerKeyOption, feePayerKey as! AccountKeyWeightedMultiSig)
    }
    
    func testDecodeByteArray() throws {
        let encodedData = "0x05f8c4a302a1036250dad4985bc22c8b9b84d1a05624c4daa0e83c8ae8fb35702d9024a8c14a71b84e04f84b02f848e301a102c10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9e301a1021769a9196f523c419be50c26419ebbec34d3d6aa8b59da834212f13dbec9a9c1b84e04f84b01f848e301a103e7615d056e770b3262e5b39a4823c3124989924ed4dcfab13f10b252701540d4e301a1036f21d60c16200d99e6777422470b3122b65850d5135a5a4b41344a5607a1446d"
        guard let encodedArr = encodedData.bytesFromHex else { XCTAssert(false)
            return }
        let expectedPublicKeyArr = [
                //expectedTransactionKey
                ["0x6250dad4985bc22c8b9b84d1a05624c4daa0e83c8ae8fb35702d9024a8c14a7117bc107912634970e82bc5450d28d6d1dcfa03f7d759d06b6be5ba96efd9eb95"],
                //expectedAccountUpdateKey
                ["0xc10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9803a1898f45b2770eda7abce70e8503b5e82b748ec0ce557ac9f4f4796965e4e",
                 "0x1769a9196f523c419be50c26419ebbec34d3d6aa8b59da834212f13dbec9a9c12a4d0eeb91d7bd5d592653d43dd0593cfe24cb20a5dbef05832932e7c7191bf6",
                ],
                //expectedFeePayedKey
                ["0xe7615d056e770b3262e5b39a4823c3124989924ed4dcfab13f10b252701540d4958423c3e2c2a45a9e0e4671b078c8763c3724416f3c6443279ebb9b967ab055",
                 "0x6f21d60c16200d99e6777422470b3122b65850d5135a5a4b41344a5607a1446d3a16e2e0f06d767ca158a1daf2463d78012287fd6503d1546229fdb1af532083"]
            ]

        let weightArr = [BigInt(1), BigInt(1)]

        let transactionKeyOptions = WeightedMultiSigOptions()
        let accountUpdateKeyOption = try WeightedMultiSigOptions(BigInt(2), weightArr)
        let feePayerKeyOption = try WeightedMultiSigOptions(BigInt(1), weightArr)

        let accountKey = try AccountKeyRoleBased.decode(encodedArr)

        let transactionKey = accountKey.roleTransactionKey
        XCTAssertTrue(transactionKey is AccountKeyPublic)
        try checkAccountKeyPublic(expectedPublicKeyArr[0], transactionKeyOptions, transactionKey as! AccountKeyPublic)

        let accountUpdateKey = accountKey.roleAccountUpdateKey
        XCTAssertTrue(accountUpdateKey is AccountKeyWeightedMultiSig)
        try checkAccountKeyWeightedMultiSig(expectedPublicKeyArr[1], accountUpdateKeyOption, accountUpdateKey as! AccountKeyWeightedMultiSig)

        let feePayerKey = accountKey.roleFeePayerKey
        XCTAssertTrue(feePayerKey is AccountKeyWeightedMultiSig)
        try checkAccountKeyWeightedMultiSig(expectedPublicKeyArr[2], feePayerKeyOption, feePayerKey as! AccountKeyWeightedMultiSig)
    }
    
    func testDecodeWithStringAccountNil() throws {
        let encodedData = "0x05f876a302a1036250dad4985bc22c8b9b84d1a05624c4daa0e83c8ae8fb35702d9024a8c14a718180b84e04f84b01f848e301a103e7615d056e770b3262e5b39a4823c3124989924ed4dcfab13f10b252701540d4e301a1036f21d60c16200d99e6777422470b3122b65850d5135a5a4b41344a5607a1446d"
        let expectedPublicKeyArr = [
                //expectedTransactionKey
                ["0x6250dad4985bc22c8b9b84d1a05624c4daa0e83c8ae8fb35702d9024a8c14a7117bc107912634970e82bc5450d28d6d1dcfa03f7d759d06b6be5ba96efd9eb95"],
                //expectedAccountUpdateKey
                [],
                //expectedFeePayedKey
                ["0xe7615d056e770b3262e5b39a4823c3124989924ed4dcfab13f10b252701540d4958423c3e2c2a45a9e0e4671b078c8763c3724416f3c6443279ebb9b967ab055",
                 "0x6f21d60c16200d99e6777422470b3122b65850d5135a5a4b41344a5607a1446d3a16e2e0f06d767ca158a1daf2463d78012287fd6503d1546229fdb1af532083"]
            ]

        let weightArr = [BigInt(1), BigInt(1)]

        let expectedTransactionRoleOpt = WeightedMultiSigOptions()
        let expectedAccountUpdateRoleOpt = WeightedMultiSigOptions()
        let expectedFeePayerRoleOpt = try WeightedMultiSigOptions(BigInt(1), weightArr)

        let accountKey = try AccountKeyRoleBased.decode(encodedData)

        let transactionKey = accountKey.roleTransactionKey
        XCTAssertTrue(transactionKey is AccountKeyPublic)
        try checkAccountKeyPublic(expectedPublicKeyArr[0], expectedTransactionRoleOpt, transactionKey as! AccountKeyPublic)

        let accountUpdateKey = accountKey.roleAccountUpdateKey
        XCTAssertTrue(accountUpdateKey is AccountKeyNil)
        XCTAssertTrue(expectedAccountUpdateRoleOpt.isEmpty)

        let feePayerKey = accountKey.roleFeePayerKey
        XCTAssertTrue(feePayerKey is AccountKeyWeightedMultiSig)
        try checkAccountKeyWeightedMultiSig(expectedPublicKeyArr[2], expectedFeePayerRoleOpt, feePayerKey as! AccountKeyWeightedMultiSig)
    }
    
    func testDecodeString_throwException() throws {
        let invalidEncodedData = "0x06f8c4a302a1036250dad4985bc22c8b9b84d1a05624c4daa0e83c8ae8fb35702d9024a8c14a71b84e04f84b02f848e301a102c10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9e301a1021769a9196f523c419be50c26419ebbec34d3d6aa8b59da834212f13dbec9a9c1b84e04f84b01f848e301a103e7615d056e770b3262e5b39a4823c3124989924ed4dcfab13f10b252701540d4e301a1036f21d60c16200d99e6777422470b3122b65850d5135a5a4b41344a5607a1446d"
        
        XCTAssertThrowsError(try AccountKeyRoleBased.decode(invalidEncodedData)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid RLP-encoded AccountKeyRoleBased Tag"))
        }
    }
    
    func testDecodeByteArray_throwException() throws {
        let invalidEncodeDataArr = "0x06f8c4a302a1036250dad4985bc22c8b9b84d1a05624c4daa0e83c8ae8fb35702d9024a8c14a71b84e04f84b02f848e301a102c10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9e301a1021769a9196f523c419be50c26419ebbec34d3d6aa8b59da834212f13dbec9a9c1b84e04f84b01f848e301a103e7615d056e770b3262e5b39a4823c3124989924ed4dcfab13f10b252701540d4e301a1036f21d60c16200d99e6777422470b3122b65850d5135a5a4b41344a5607a1446d".bytesFromHex
        
        XCTAssertThrowsError(try AccountKeyRoleBased.decode(invalidEncodeDataArr!)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid RLP-encoded AccountKeyRoleBased Tag"))
        }
    }
    
    func testFromRoleBasedPublicKeysAndOptionsWithUncompressedKey() throws {
        let expectedPublicKey = [
                //expectedTransactionKey
                ["0xb86b2787e8c7accd7d2d82678c9bef047a0aafd72a6e690817506684e8513c9af36becba90c8de06fd06da16492263267a63720985f94fc5a027d0a26d25e6ae",
                 "0xe4d4901155edabc2bd5b356c63e58af20fe0a74e5f210de6396b74094f40215d3bc4d619872b96c091c741a15736a7ef12f530b7593038bbbfbf6c35deee8a34"],
                //expectedAccountUpdateKey
                ["0x1a909c4d7dbb5281b1d1b55e79a1b2568111bd2830246c3173ce824000eb8716afe39b6106fb9db360fb5779e2d346c8328698174831941586b11bdc3e755905",
                 "0x1427ac6351bbfc15811e8e5389a674b01d7a2c253e69a6ed30a33583864368f65f63b92fd60be61c5d176ae1771e7738e6a043af814b9af5d81137df29ee95f2",
                 "0x90fe4bb78bc981a40874ebcff2f9de4eba1e59ecd7a271a37814413720a3a5ea5fa9bd7d8bc5c66a9a08d77563458b004bbd1d594a3a12ef108cdc7c04c525a6"],
                //expectedFeePayedKey
                ["0x91245244462b3eee6436d3dc0ba3f69ef413fe2296c729733eff891a55f70c02f2b0870653417943e795e7c8694c4f8be8af865b7a0224d1dec0bf8a1bf1b5a6",
                 "0x77e05dd93cdd6362f8648447f33d5676cbc5f42f4c4946ae1ad62bd4c0c4f3570b1a104b67d1cd169bbf61dd557f15ab5ee8b661326096954caddadf34ae6ac8",
                 "0xd3bb14320d87eed081ae44740b5abbc52bac2c7ccf85b6281a0fc69f3ba4c171cc4bd2ba7f0c969cd72bfa49c854d8ac2cf3d0edea7f0ce0fd31cf080374935d",
                 "0xcfa4d1bee51e59e6842b136ff95b9d01385f94bed13c4be8996c6d20cb732c3ee47cd2b6bbb917658c5fd3d02b0ddf1242b1603d1acbde7812a7d9d684ed37a9"]
            ]

        let optionWeight = [
            [BigInt(1), BigInt(1)],
            [BigInt(1), BigInt(1), BigInt(2)],
            [BigInt(1), BigInt(1), BigInt(2), BigInt(2)]
        ]

        let transactionKeyOptions = try WeightedMultiSigOptions(BigInt(2), optionWeight[AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue])
        let accountUpdateKeyOption = try WeightedMultiSigOptions(BigInt(2), optionWeight[AccountKeyRoleBased.RoleGroup.ACCOUNT_UPDATE.rawValue])
        let feePayerKeyOption = try WeightedMultiSigOptions(BigInt(1), optionWeight[AccountKeyRoleBased.RoleGroup.FEE_PAYER.rawValue])

        let options = [transactionKeyOptions, accountUpdateKeyOption, feePayerKeyOption]
        let accountKeyRoleBased = try AccountKeyRoleBased.fromRoleBasedPublicKeysAndOptions(expectedPublicKey, options)

        let transactionKey = accountKeyRoleBased.roleTransactionKey
        XCTAssertTrue(transactionKey is AccountKeyWeightedMultiSig)
        try checkAccountKeyWeightedMultiSig(expectedPublicKey[AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue], transactionKeyOptions, transactionKey as! AccountKeyWeightedMultiSig)

        let accountUpdateKey = accountKeyRoleBased.roleAccountUpdateKey
        XCTAssertTrue(accountUpdateKey is AccountKeyWeightedMultiSig)
        try checkAccountKeyWeightedMultiSig(expectedPublicKey[AccountKeyRoleBased.RoleGroup.ACCOUNT_UPDATE.rawValue], accountUpdateKeyOption, accountUpdateKey as! AccountKeyWeightedMultiSig)

        let feePayerKey = accountKeyRoleBased.roleFeePayerKey
        XCTAssertTrue(feePayerKey is AccountKeyWeightedMultiSig)
        try checkAccountKeyWeightedMultiSig(expectedPublicKey[AccountKeyRoleBased.RoleGroup.FEE_PAYER.rawValue], feePayerKeyOption, feePayerKey as! AccountKeyWeightedMultiSig)
    }
    
    func testFromRoleBasedPublicKeysAndOptionsWithCompressedKey() throws {
        let expectedPublicKey = [
                //expectedTransactionKey
                ["0x02b86b2787e8c7accd7d2d82678c9bef047a0aafd72a6e690817506684e8513c9a",
                 "0x02e4d4901155edabc2bd5b356c63e58af20fe0a74e5f210de6396b74094f40215d",
                ],
                //expectedAccountUpdateKey
                ["0x031a909c4d7dbb5281b1d1b55e79a1b2568111bd2830246c3173ce824000eb8716",
                 "0x021427ac6351bbfc15811e8e5389a674b01d7a2c253e69a6ed30a33583864368f6",
                 "0x0290fe4bb78bc981a40874ebcff2f9de4eba1e59ecd7a271a37814413720a3a5ea",
                ],
                //expectedFeePayedKey
                ["0x0291245244462b3eee6436d3dc0ba3f69ef413fe2296c729733eff891a55f70c02",
                 "0x0277e05dd93cdd6362f8648447f33d5676cbc5f42f4c4946ae1ad62bd4c0c4f357",
                 "0x03d3bb14320d87eed081ae44740b5abbc52bac2c7ccf85b6281a0fc69f3ba4c171",
                 "0x03cfa4d1bee51e59e6842b136ff95b9d01385f94bed13c4be8996c6d20cb732c3e",
                ]
            ]

        let optionWeight = [
            [BigInt(1), BigInt(1)],
            [BigInt(1), BigInt(1), BigInt(2)],
            [BigInt(1), BigInt(1), BigInt(2), BigInt(2)]
        ]

        let transactionKeyOptions = try WeightedMultiSigOptions(BigInt(2), optionWeight[AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue])
        let accountUpdateKeyOption = try WeightedMultiSigOptions(BigInt(2), optionWeight[AccountKeyRoleBased.RoleGroup.ACCOUNT_UPDATE.rawValue])
        let feePayerKeyOption = try WeightedMultiSigOptions(BigInt(1), optionWeight[AccountKeyRoleBased.RoleGroup.FEE_PAYER.rawValue])

        let options = [transactionKeyOptions, accountUpdateKeyOption, feePayerKeyOption]
        let accountKeyRoleBased = try AccountKeyRoleBased.fromRoleBasedPublicKeysAndOptions(expectedPublicKey, options)

        let transactionKey = accountKeyRoleBased.roleTransactionKey
        XCTAssertTrue(transactionKey is AccountKeyWeightedMultiSig)
        try checkAccountKeyWeightedMultiSig(expectedPublicKey[AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue], transactionKeyOptions, transactionKey as! AccountKeyWeightedMultiSig)

        let accountUpdateKey = accountKeyRoleBased.roleAccountUpdateKey
        XCTAssertTrue(accountUpdateKey is AccountKeyWeightedMultiSig)
        try checkAccountKeyWeightedMultiSig(expectedPublicKey[AccountKeyRoleBased.RoleGroup.ACCOUNT_UPDATE.rawValue], accountUpdateKeyOption, accountUpdateKey as! AccountKeyWeightedMultiSig)

        let feePayerKey = accountKeyRoleBased.roleFeePayerKey
        XCTAssertTrue(feePayerKey is AccountKeyWeightedMultiSig)
        try checkAccountKeyWeightedMultiSig(expectedPublicKey[AccountKeyRoleBased.RoleGroup.FEE_PAYER.rawValue], feePayerKeyOption, feePayerKey as! AccountKeyWeightedMultiSig)
    }
    
    func testFromRoleBasedPublicKeysAndOptionsWithAccountKeyNil() throws {
        let expectedPublicKey = [
                //expectedTransactionKey
                [
                ],
                //expectedAccountUpdateKey
                ["0x031a909c4d7dbb5281b1d1b55e79a1b2568111bd2830246c3173ce824000eb8716",
                 "0x021427ac6351bbfc15811e8e5389a674b01d7a2c253e69a6ed30a33583864368f6",
                 "0x0290fe4bb78bc981a40874ebcff2f9de4eba1e59ecd7a271a37814413720a3a5ea",
                ],
                //expectedFeePayedKey
                ["0x0291245244462b3eee6436d3dc0ba3f69ef413fe2296c729733eff891a55f70c02",
                 "0x0277e05dd93cdd6362f8648447f33d5676cbc5f42f4c4946ae1ad62bd4c0c4f357",
                 "0x03d3bb14320d87eed081ae44740b5abbc52bac2c7ccf85b6281a0fc69f3ba4c171",
                 "0x03cfa4d1bee51e59e6842b136ff95b9d01385f94bed13c4be8996c6d20cb732c3e",
                ]
            ]

        let optionWeight = [
            [BigInt(1), BigInt(1)],
            [BigInt(1), BigInt(1), BigInt(2)],
            [BigInt(1), BigInt(1), BigInt(2), BigInt(2)]
        ]

        let transactionKeyOptions = WeightedMultiSigOptions()
        let accountUpdateKeyOption = try WeightedMultiSigOptions(BigInt(2), optionWeight[AccountKeyRoleBased.RoleGroup.ACCOUNT_UPDATE.rawValue])
        let feePayerKeyOption = try WeightedMultiSigOptions(BigInt(1), optionWeight[AccountKeyRoleBased.RoleGroup.FEE_PAYER.rawValue])

        let options = [transactionKeyOptions, accountUpdateKeyOption, feePayerKeyOption]
        let accountKeyRoleBased = try AccountKeyRoleBased.fromRoleBasedPublicKeysAndOptions(expectedPublicKey, options)

        let transactionKey = accountKeyRoleBased.roleTransactionKey
        XCTAssertTrue(transactionKey is AccountKeyNil)
        XCTAssertTrue(transactionKeyOptions.isEmpty)

        let accountUpdateKey = accountKeyRoleBased.roleAccountUpdateKey
        XCTAssertTrue(accountUpdateKey is AccountKeyWeightedMultiSig)
        try checkAccountKeyWeightedMultiSig(expectedPublicKey[AccountKeyRoleBased.RoleGroup.ACCOUNT_UPDATE.rawValue], accountUpdateKeyOption, accountUpdateKey as! AccountKeyWeightedMultiSig)

        let feePayerKey = accountKeyRoleBased.roleFeePayerKey
        XCTAssertTrue(feePayerKey is AccountKeyWeightedMultiSig)
        try checkAccountKeyWeightedMultiSig(expectedPublicKey[AccountKeyRoleBased.RoleGroup.FEE_PAYER.rawValue], feePayerKeyOption, feePayerKey as! AccountKeyWeightedMultiSig)
    }
    
    func testFromRoleBasedPublicKeysAndOptionsWithAccountKeyNil_throwException() throws {
        let expectedPublicKey = [
                //expectedTransactionKey
                [],
                //expectedAccountUpdateKey
                ["0x031a909c4d7dbb5281b1d1b55e79a1b2568111bd2830246c3173ce824000eb8716",
                 "0x021427ac6351bbfc15811e8e5389a674b01d7a2c253e69a6ed30a33583864368f6",
                 "0x0290fe4bb78bc981a40874ebcff2f9de4eba1e59ecd7a271a37814413720a3a5ea",
                ],
                //expectedFeePayedKey
                ["0x0291245244462b3eee6436d3dc0ba3f69ef413fe2296c729733eff891a55f70c02",
                 "0x0277e05dd93cdd6362f8648447f33d5676cbc5f42f4c4946ae1ad62bd4c0c4f357",
                 "0x03d3bb14320d87eed081ae44740b5abbc52bac2c7ccf85b6281a0fc69f3ba4c171",
                 "0x03cfa4d1bee51e59e6842b136ff95b9d01385f94bed13c4be8996c6d20cb732c3e",
                ]
            ]

        let optionWeight = [
            [BigInt(1), BigInt(1)],
            [BigInt(1), BigInt(1), BigInt(2)],
            [BigInt(1), BigInt(1), BigInt(2), BigInt(2)]
        ]

        let transactionKeyOptions = try WeightedMultiSigOptions(BigInt(2), optionWeight[AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue])
        let accountUpdateKeyOption = try WeightedMultiSigOptions(BigInt(2), optionWeight[AccountKeyRoleBased.RoleGroup.ACCOUNT_UPDATE.rawValue])
        let feePayerKeyOption = try WeightedMultiSigOptions(BigInt(1), optionWeight[AccountKeyRoleBased.RoleGroup.FEE_PAYER.rawValue])

        let options = [transactionKeyOptions, accountUpdateKeyOption, feePayerKeyOption]
        
        XCTAssertThrowsError(try AccountKeyRoleBased.fromRoleBasedPublicKeysAndOptions(expectedPublicKey, options)) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("Invalid options: AccountKeyNil cannot have options."))
        }
    }
    
    func testFromRoleBasedPublicKeysAndOptionsWithAccountWeightedMultiSig_throwException() throws {
        let expectedPublicKey = [
                //expectedTransactionKey
                ["0x02b86b2787e8c7accd7d2d82678c9bef047a0aafd72a6e690817506684e8513c9a",
                 "0x02e4d4901155edabc2bd5b356c63e58af20fe0a74e5f210de6396b74094f40215d",
                ],
                //expectedAccountUpdateKey
                ["0x031a909c4d7dbb5281b1d1b55e79a1b2568111bd2830246c3173ce824000eb8716",
                 "0x021427ac6351bbfc15811e8e5389a674b01d7a2c253e69a6ed30a33583864368f6",
                 "0x0290fe4bb78bc981a40874ebcff2f9de4eba1e59ecd7a271a37814413720a3a5ea",
                ],
                //expectedFeePayedKey
                ["0x0291245244462b3eee6436d3dc0ba3f69ef413fe2296c729733eff891a55f70c02",
                 "0x0277e05dd93cdd6362f8648447f33d5676cbc5f42f4c4946ae1ad62bd4c0c4f357",
                 "0x03d3bb14320d87eed081ae44740b5abbc52bac2c7ccf85b6281a0fc69f3ba4c171",
                 "0x03cfa4d1bee51e59e6842b136ff95b9d01385f94bed13c4be8996c6d20cb732c3e",
                ]
            ]

        let optionWeight = [
            [],
            [BigInt(1), BigInt(1), BigInt(2)],
            [BigInt(1), BigInt(1), BigInt(2), BigInt(2)]
        ]

        let transactionKeyOptions = WeightedMultiSigOptions()
        let accountUpdateKeyOption = try WeightedMultiSigOptions(BigInt(2), optionWeight[AccountKeyRoleBased.RoleGroup.ACCOUNT_UPDATE.rawValue])
        let feePayerKeyOption = try WeightedMultiSigOptions(BigInt(1), optionWeight[AccountKeyRoleBased.RoleGroup.FEE_PAYER.rawValue])

        let options = [transactionKeyOptions, accountUpdateKeyOption, feePayerKeyOption]
        
        XCTAssertThrowsError(try AccountKeyRoleBased.fromRoleBasedPublicKeysAndOptions(expectedPublicKey, options)) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("Invalid options : AccountKeyWeightedMultiSig must have options"))
        }
    }
    
    func testMakeByConstructor() throws {
        let publicKey = ["0x02b86b2787e8c7accd7d2d82678c9bef047a0aafd72a6e690817506684e8513c9a",
                         "0x02e4d4901155edabc2bd5b356c63e58af20fe0a74e5f210de6396b74094f40215d",
                        ]

        let weights = [BigInt(1), BigInt(1)]
        let option = try WeightedMultiSigOptions(BigInt(1), weights)
        let accountKeyWeightedMultiSig = try AccountKeyWeightedMultiSig.fromPublicKeysAndOptions(publicKey, option)
        
        let accountKeyLegacy = AccountKeyLegacy()
        let accountKeyFail = AccountKeyFail()
        
        let accountKeyRoleBased = try AccountKeyRoleBased([accountKeyLegacy, accountKeyFail, accountKeyWeightedMultiSig])

        let transactionKey = accountKeyRoleBased.roleTransactionKey
        XCTAssertTrue(transactionKey is AccountKeyLegacy)

        let accountUpdateKey = accountKeyRoleBased.roleAccountUpdateKey
        XCTAssertTrue(accountUpdateKey is AccountKeyFail)

        let feePayerKey = accountKeyRoleBased.roleFeePayerKey
        XCTAssertTrue(feePayerKey is AccountKeyWeightedMultiSig)
        try checkAccountKeyWeightedMultiSig(publicKey, option, feePayerKey as! AccountKeyWeightedMultiSig)
    }
    
    func testGetRLPEncoding() throws {
        let expectedEncodedData = "0x05f8c4a302a1036250dad4985bc22c8b9b84d1a05624c4daa0e83c8ae8fb35702d9024a8c14a71b84e04f84b02f848e301a102c10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9e301a1021769a9196f523c419be50c26419ebbec34d3d6aa8b59da834212f13dbec9a9c1b84e04f84b01f848e301a103e7615d056e770b3262e5b39a4823c3124989924ed4dcfab13f10b252701540d4e301a1036f21d60c16200d99e6777422470b3122b65850d5135a5a4b41344a5607a1446d"
        let publicKey = [
            ["0x6250dad4985bc22c8b9b84d1a05624c4daa0e83c8ae8fb35702d9024a8c14a7117bc107912634970e82bc5450d28d6d1dcfa03f7d759d06b6be5ba96efd9eb95"],
            ["0xc10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9803a1898f45b2770eda7abce70e8503b5e82b748ec0ce557ac9f4f4796965e4e",
             "0x1769a9196f523c419be50c26419ebbec34d3d6aa8b59da834212f13dbec9a9c12a4d0eeb91d7bd5d592653d43dd0593cfe24cb20a5dbef05832932e7c7191bf6"],
            ["0xe7615d056e770b3262e5b39a4823c3124989924ed4dcfab13f10b252701540d4958423c3e2c2a45a9e0e4671b078c8763c3724416f3c6443279ebb9b967ab055",
             "0x6f21d60c16200d99e6777422470b3122b65850d5135a5a4b41344a5607a1446d3a16e2e0f06d767ca158a1daf2463d78012287fd6503d1546229fdb1af532083"]
        ]

        let weights = [BigInt(1), BigInt(1)]
        
        let transactionKeyOptions = WeightedMultiSigOptions()
        let accountUpdateKeyOption = try WeightedMultiSigOptions(BigInt(2), weights)
        let feePayerKeyOption = try WeightedMultiSigOptions(BigInt(1), weights)
        
        let accountKeyRoleBased = try AccountKeyRoleBased.fromRoleBasedPublicKeysAndOptions(publicKey, [transactionKeyOptions, accountUpdateKeyOption, feePayerKeyOption])
        
        XCTAssertEqual(expectedEncodedData, try accountKeyRoleBased.getRLPEncoding())
    }
    
    func testFromRoleBasedPublicKeysAndOptionsWithString() throws {
        let expectedPublicKey = [
            ["fail"],
            ["0xc10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9803a1898f45b2770eda7abce70e8503b5e82b748ec0ce557ac9f4f4796965e4e"],
            ["legacy"]
        ]
        
        let transactionKeyOptions = WeightedMultiSigOptions()
        let accountUpdateKeyOption = WeightedMultiSigOptions()
        let feePayerKeyOption = WeightedMultiSigOptions()
        
        let roleBased = try AccountKeyRoleBased.fromRoleBasedPublicKeysAndOptions(expectedPublicKey, [transactionKeyOptions, accountUpdateKeyOption, feePayerKeyOption])
        XCTAssertTrue(roleBased.roleTransactionKey is AccountKeyFail)
        XCTAssertTrue(roleBased.roleAccountUpdateKey is AccountKeyPublic)
        try checkPublicKey(expectedPublicKey[1][0], (roleBased.roleAccountUpdateKey as! AccountKeyPublic).publicKey)
        XCTAssertTrue(roleBased.roleFeePayerKey is AccountKeyLegacy)
    }
    
    func testFromRoleBasedPublicKeysAndOptionsWithStringAndWeightedMultiSig() throws {
        let expectedPublicKey = [
            ["legacy"],
            ["0xc10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9803a1898f45b2770eda7abce70e8503b5e82b748ec0ce557ac9f4f4796965e4e",
             "0x1769a9196f523c419be50c26419ebbec34d3d6aa8b59da834212f13dbec9a9c12a4d0eeb91d7bd5d592653d43dd0593cfe24cb20a5dbef05832932e7c7191bf6"
            ],
            ["fail"]
        ]
        
        let weightArr = [BigInt(1), BigInt(1)]
        let transactionKeyOptions = WeightedMultiSigOptions()
        let accountUpdateKeyOption = try WeightedMultiSigOptions(BigInt(2), weightArr)
        let feePayerKeyOption = WeightedMultiSigOptions()
        
        let roleBased = try AccountKeyRoleBased.fromRoleBasedPublicKeysAndOptions(expectedPublicKey, [transactionKeyOptions, accountUpdateKeyOption, feePayerKeyOption])
        XCTAssertTrue(roleBased.roleTransactionKey is AccountKeyLegacy)
        XCTAssertTrue(roleBased.roleAccountUpdateKey is AccountKeyWeightedMultiSig)
        try checkAccountKeyWeightedMultiSig(expectedPublicKey[1], accountUpdateKeyOption, roleBased.roleAccountUpdateKey as! AccountKeyWeightedMultiSig)
        XCTAssertTrue(roleBased.roleFeePayerKey is AccountKeyFail)
    }
}
