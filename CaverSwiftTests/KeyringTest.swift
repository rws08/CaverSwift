//
//  KeyringTest.swift
//  CaverSwiftTests
//
//  Created by won on 2021/07/06.
//

import XCTest
@testable import CaverSwift

func checkValidateSingleKey(_ actualKeyring: SingleKeyring,_ expectedAddress: String, _ expectedPrivateKey: String) throws {
    XCTAssertTrue(Utils.isAddress(actualKeyring.address))
    XCTAssertEqual(expectedAddress, actualKeyring.address)
    
    let actualPrivateKey = actualKeyring.key
    XCTAssertTrue(Utils.isValidPrivateKey(actualPrivateKey.privateKey))
    XCTAssertEqual(expectedPrivateKey, actualPrivateKey.privateKey)
}

func checkValidateMultipleKey(_ actualKeyring: MultipleKeyring,_ expectedAddress: String, _ expectedPrivateKey: [String]) throws {
    XCTAssertTrue(Utils.isAddress(actualKeyring.address))
    XCTAssertEqual(expectedAddress, actualKeyring.address)
    
    let actualPrivateKeyArr = actualKeyring.keys
    XCTAssertEqual(expectedPrivateKey.count, actualPrivateKeyArr.count)
    zip(expectedPrivateKey, actualPrivateKeyArr).forEach {
        XCTAssertEqual($0, $1.privateKey)
    }
}

func checkValidateRoleBasedKey(_ actualKeyring: RoleBasedKeyring,_ expectedAddress: String, _ expectedPrivateKeyList: [[String]]) throws {
    XCTAssertTrue(Utils.isAddress(actualKeyring.address))
    XCTAssertEqual(expectedAddress, actualKeyring.address)
    
    let actualKeyList = actualKeyring.keys
    zip(expectedPrivateKeyList, actualKeyList).forEach {
        XCTAssertEqual($0.count, $1.count)
        zip($0, $1).forEach {
            XCTAssertEqual($0, $1.privateKey)
        }
    }
}

func checkValidKeyring(_ expect: AbstractKeyring,_ actual: AbstractKeyring) throws {
    XCTAssertEqual(expect.address, actual.address)
    XCTAssertEqual("\(type(of: expect))", "\(type(of: actual))")
    
    if expect is SingleKeyring {
        let ex = expect as! SingleKeyring
        let ac = actual as! SingleKeyring
        XCTAssertEqual(ex.key.privateKey, ac.key.privateKey)
    }
    
    if expect is MultipleKeyring {
        let expectKeyring = expect as! MultipleKeyring
        let actualKeyring = actual as! MultipleKeyring
        XCTAssertEqual(expectKeyring.keys.count, actualKeyring.keys.count)
        zip(expectKeyring.keys, actualKeyring.keys).forEach {
            XCTAssertEqual($0.privateKey, $1.privateKey)
        }
    }
    
    if expect is RoleBasedKeyring {
        let expectKeyring = expect as! RoleBasedKeyring
        let actualKeyring = actual as! RoleBasedKeyring
        zip(expectKeyring.keys, actualKeyring.keys).forEach {
            XCTAssertEqual($0.count, $1.count)
            zip($0, $1).forEach {
                XCTAssertEqual($0.privateKey, $1.privateKey)
            }
        }
    }
}

func generateMultipleKeyring(_ num: Int) throws -> MultipleKeyring {
    var keyArr: [String] = []
    for _ in (0..<num) {
        keyArr.append(PrivateKey.generate("entropy").privateKey)
    }
    
    let address = PrivateKey.generate("entropy").getDerivedAddress()
    return try KeyringFactory.createWithMultipleKey(address, keyArr)
}

func generateRoleBaseKeyring(_ numArr: [Int]) throws -> RoleBasedKeyring {
    var keyArr: [[String]] = []
    for item in numArr {
        var arr: [String] = []
        for _ in (0..<item) {
            arr.append(PrivateKey.generate("entropy").privateKey)
        }
        keyArr.append(arr)
    }
    
    let address = PrivateKey.generate("entropy").getDerivedAddress()
    return try KeyringFactory.createWithRoleBasedKey(address, keyArr)
}

class generateTest: XCTestCase {
    func testGenerate() throws {
        let keyring = KeyringFactory.generate()
        XCTAssertTrue(Utils.isAddress(keyring!.address))
    }
    
    func testGenerateWithEntropy() throws {
        let random = Utils.generateRandomBytes(32)
        let keyring = KeyringFactory.generate(random.hexString)
        XCTAssertTrue(Utils.isAddress(keyring!.address))
    }
}

class createFromPrivateKeyTest: XCTestCase {
    func testCreateFromPrivateKey() throws {
        guard let keyring = KeyringFactory.generate() else { XCTAssert(true); return }
        let expectedAddress = keyring.address
        let expectedPrivateKey = keyring.key.privateKey
        
        let actualKeyring = try KeyringFactory.createFromPrivateKey(expectedPrivateKey)
        try checkValidateSingleKey(actualKeyring, expectedAddress, expectedPrivateKey)
    }
    
    func testCreateFromPrivateKeyWithoutHexPrefix() throws {
        guard let keyring = KeyringFactory.generate() else { XCTAssert(true); return }
        let expectedAddress = keyring.address
        let expectedPrivateKey = keyring.key.privateKey
        
        let actualKeyring = try KeyringFactory.createFromPrivateKey(expectedPrivateKey.cleanHexPrefix)
        try checkValidateSingleKey(actualKeyring, expectedAddress, expectedPrivateKey)
    }
    
    func testCreateFromPrivateFromKlaytnWalletKey() throws {
        let klaytnWalletKey = "0x45a915e4d060149eb4365960e6a7a45f334393093061116b197e3240065ff2d80x000xa94f5374fce5edbc8e2a8697c15331677e6ebf0b"
        let expectedPrivateKey = "0x45a915e4d060149eb4365960e6a7a45f334393093061116b197e3240065ff2d8"
        let expectedAddress = "0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b"
        
        let actualKeyring = try KeyringFactory.createFromPrivateKey(klaytnWalletKey)
        try checkValidateSingleKey(actualKeyring, expectedAddress, expectedPrivateKey)
    }
    
    func testCreateFromPrivate_throwException() throws {
        let random = Utils.generateRandomBytes(31)
        
        XCTAssertThrowsError(try KeyringFactory.createFromPrivateKey(random.hexString)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid private key."))
        }
    }
}

class createFromKlaytnWalletKeyTest: XCTestCase {
    func testCreateFromKlaytnWalletKey() throws {
        let klaytnWalletKey = "0x45a915e4d060149eb4365960e6a7a45f334393093061116b197e3240065ff2d80x000xa94f5374fce5edbc8e2a8697c15331677e6ebf0b"
        let expectedPrivateKey = "0x45a915e4d060149eb4365960e6a7a45f334393093061116b197e3240065ff2d8"
        let expectedAddress = "0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b"
        
        let actualKeyring = try KeyringFactory.createFromKlaytnWalletKey(klaytnWalletKey)
        try checkValidateSingleKey(actualKeyring, expectedAddress, expectedPrivateKey)
    }
    
    func testCreateFromKlaytnWalletKey_throwException() throws {
        let invalidWalletKey = "39d87f15c695ec94d6d7107b48dee85e252f21fedd371e1c6baefbdf0x000x658b7b7a94ac398a8e7275e719a10c"
        
        XCTAssertThrowsError(try KeyringFactory.createFromKlaytnWalletKey(invalidWalletKey)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid Klaytn wallet key."))
        }
    }
}

class createTest: XCTestCase {
    func testCreate_SingleKey() throws {
        let expectedPrivateKey = PrivateKey.generate()
        
        let actualKeyring = try KeyringFactory.create(expectedPrivateKey.getDerivedAddress(), expectedPrivateKey.privateKey)
        try checkValidateSingleKey(actualKeyring, expectedPrivateKey.getDerivedAddress(), expectedPrivateKey.privateKey)
    }
    
    func testCreate_MultiPleKey() throws {
        let expectedAddress = PrivateKey.generate().getDerivedAddress()
        let privateKeyArr = [
            PrivateKey.generate().privateKey,
            PrivateKey.generate().privateKey,
            PrivateKey.generate().privateKey]
        
        let actualKeyring = try KeyringFactory.create(expectedAddress, privateKeyArr)
        try checkValidateMultipleKey(actualKeyring, expectedAddress, privateKeyArr)
    }
    
    func testCreateFromKlaytnWalletKey_throwException() throws {
        let expectedAddress = PrivateKey.generate().getDerivedAddress()
        let privateKeyArr = [
            PrivateKey.generate().privateKey,
            PrivateKey.generate().privateKey,
            PrivateKey.generate().privateKey,
            PrivateKey.generate().privateKey,
            PrivateKey.generate().privateKey,
            PrivateKey.generate().privateKey,
            PrivateKey.generate().privateKey,
            PrivateKey.generate().privateKey,
            PrivateKey.generate().privateKey,
            PrivateKey.generate().privateKey,
            PrivateKey.generate().privateKey,
            PrivateKey.generate().privateKey]
        
        XCTAssertThrowsError(try KeyringFactory.create(expectedAddress, privateKeyArr)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("MultipleKey has up to 10."))
        }
    }
    
    func testCreate_RoleBasedKey() throws {
        let expectedAddress = PrivateKey.generate().getDerivedAddress()
        let expectedKeyList = [
        [PrivateKey.generate().privateKey,
         PrivateKey.generate().privateKey,
         PrivateKey.generate().privateKey],
        [PrivateKey.generate().privateKey],
        [PrivateKey.generate().privateKey,
         PrivateKey.generate().privateKey]]
        
        let actualKeyring = try KeyringFactory.create(expectedAddress, expectedKeyList)
        try checkValidateRoleBasedKey(actualKeyring, expectedAddress, expectedKeyList)
    }
    
    func testCreateWithRoleBasedKey_EmptyRole() throws {
        let expectedAddress = PrivateKey.generate().getDerivedAddress()
        let expectedKeyList = [
        [],
        [],
        [PrivateKey.generate().privateKey,
         PrivateKey.generate().privateKey]]
        
        let actualKeyring = try KeyringFactory.create(expectedAddress, expectedKeyList)
        try checkValidateRoleBasedKey(actualKeyring, expectedAddress, expectedKeyList)
    }
    
    func testCreate_RoleBasedKey_throwException_exceedComponent() throws {
        let expectedAddress = PrivateKey.generate().getDerivedAddress()
        let expectedKeyList = [
        [],
        [],
        [PrivateKey.generate().privateKey,
         PrivateKey.generate().privateKey],
        []]
        
        XCTAssertThrowsError(try KeyringFactory.create(expectedAddress, expectedKeyList)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("RoleBasedKey component must have 3."))
        }
    }
    
    func testCreate_RoleBasedKey_throwException_exceedKeyCount() throws {
        let expectedAddress = PrivateKey.generate().getDerivedAddress()
        let expectedKeyList = [
        [],
        [],
        [PrivateKey.generate().privateKey,
         PrivateKey.generate().privateKey,
         PrivateKey.generate().privateKey,
         PrivateKey.generate().privateKey,
         PrivateKey.generate().privateKey,
         PrivateKey.generate().privateKey,
         PrivateKey.generate().privateKey,
         PrivateKey.generate().privateKey,
         PrivateKey.generate().privateKey,
         PrivateKey.generate().privateKey,
         PrivateKey.generate().privateKey,
         PrivateKey.generate().privateKey]]
        
        XCTAssertThrowsError(try KeyringFactory.create(expectedAddress, expectedKeyList)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("The keys in RoleBasedKey component has up to 10."))
        }
    }
}

class createWithSingleKeyTest: XCTestCase {
    func testCreateWithSingleKey_coupled() throws {
        let key = PrivateKey.generate()
        let expectedAddress = key.getDerivedAddress()
        let expectedPrivateKey = key.privateKey
        
        let actualKeyring = try KeyringFactory.createWithSingleKey(expectedAddress, expectedPrivateKey)
        try checkValidateSingleKey(actualKeyring, expectedAddress, expectedPrivateKey)
    }
    
    func testCreateWithSingleKey_decoupled() throws {
        let expectedAddress = PrivateKey.generate().getDerivedAddress()
        let expectedPrivateKey = PrivateKey.generate().privateKey
        
        let actualKeyring = try KeyringFactory.createWithSingleKey(expectedAddress, expectedPrivateKey)
        XCTAssertTrue(actualKeyring.isDecoupled)
        try checkValidateSingleKey(actualKeyring, expectedAddress, expectedPrivateKey)
    }
    
    func testCreateWithSingleKey_throwException_KlaytnWalletKeyFormat() throws {
        guard let keyring = KeyringFactory.generate() else { XCTAssert(true); return }
        let klaytnWalletKey = keyring.getKlaytnWalletKey()
        
        XCTAssertThrowsError(try KeyringFactory.createWithSingleKey(keyring.address, klaytnWalletKey)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid format of parameter. Use 'fromKlaytnWalletKey' to create Keyring from KlaytnWalletKey."))
        }
    }
}

class createWithMultipleKeyTest: XCTestCase {
    func testCreateWithMultipleKey() throws {
        guard let expectedAddress = KeyringFactory.generate()?.address else { XCTAssert(true); return }
        let expectedPrivateKeyArr = [
            PrivateKey.generate().privateKey,
            PrivateKey.generate().privateKey,
            PrivateKey.generate().privateKey]
        
        let actualKeyring = try KeyringFactory.createWithMultipleKey(expectedAddress, expectedPrivateKeyArr)
        try checkValidateMultipleKey(actualKeyring, expectedAddress, expectedPrivateKeyArr)
    }
    
    func testCreateWithMultipleKey_throwException_invalidKey() throws {
        guard let expectedAddress = KeyringFactory.generate()?.address else { XCTAssert(true); return }
        let expectedPrivateKeyArr = [
            Utils.generateRandomBytes(31).hexString,
            PrivateKey.generate().privateKey]
        
        XCTAssertThrowsError(try KeyringFactory.createWithMultipleKey(expectedAddress, expectedPrivateKeyArr)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid private key."))
        }
    }
}

class createWithRoleBasedKeyTest: XCTestCase {
    func testCreateWithRoleBasedKey() throws {
        guard let expectedAddress = KeyringFactory.generate()?.address else { XCTAssert(true); return }
        let expectedPrivateKeyArr = [
            [PrivateKey.generate().privateKey,
             PrivateKey.generate().privateKey],
            [PrivateKey.generate().privateKey],
            [PrivateKey.generate().privateKey]]
        
        let actualKeyring = try KeyringFactory.createWithRoleBasedKey(expectedAddress, expectedPrivateKeyArr)
        try checkValidateRoleBasedKey(actualKeyring, expectedAddress, expectedPrivateKeyArr)
    }
    
    func testCreateWithRoleBasedKey_throwException_exceedComponent() throws {
        let expectedAddress = PrivateKey.generate().getDerivedAddress()
        let privateKeyArr = [
            [],
            [],
            [PrivateKey.generate().privateKey,
             PrivateKey.generate().privateKey],
            []]
        
        XCTAssertThrowsError(try KeyringFactory.createWithRoleBasedKey(expectedAddress, privateKeyArr)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("RoleBasedKey component must have 3."))
        }
    }
    
    func testCreateWithRoleBasedKey_throwException_exceedKeyCount() throws {
        let expectedAddress = PrivateKey.generate().getDerivedAddress()
        let expectedKeyList = [
        [],
        [],
        [PrivateKey.generate().privateKey,
         PrivateKey.generate().privateKey,
         PrivateKey.generate().privateKey,
         PrivateKey.generate().privateKey,
         PrivateKey.generate().privateKey,
         PrivateKey.generate().privateKey,
         PrivateKey.generate().privateKey,
         PrivateKey.generate().privateKey,
         PrivateKey.generate().privateKey,
         PrivateKey.generate().privateKey,
         PrivateKey.generate().privateKey,
         PrivateKey.generate().privateKey]]
        
        XCTAssertThrowsError(try KeyringFactory.create(expectedAddress, expectedKeyList)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("The keys in RoleBasedKey component has up to 10."))
        }
    }
}

class copyTest: XCTestCase {
    func testCopy_coupled() throws {
        guard let expectedKeyring = KeyringFactory.generate() else { XCTAssert(true); return }
        let expectedPrivateKey = expectedKeyring.key.privateKey
        let actualKeyring = expectedKeyring.copy()
        
        try checkValidateSingleKey(actualKeyring as! SingleKeyring, expectedKeyring.address, expectedPrivateKey)
    }
    
    func testCopy_decoupled() throws {
        let expectedAddress = PrivateKey.generate().getDerivedAddress()
        let expectedPrivateKey = PrivateKey.generate().privateKey
        let expectedKeyring = try KeyringFactory.create(expectedAddress, expectedPrivateKey)
        let actualKeyring = expectedKeyring.copy()
        
        try checkValidateSingleKey(actualKeyring as! SingleKeyring, expectedKeyring.address, expectedPrivateKey)
    }
    
    func testCopy_multipleKey() throws {
        let expectedAddress = PrivateKey.generate().getDerivedAddress()
        let expectedAddressKeys = [
            PrivateKey.generate().privateKey,
            PrivateKey.generate().privateKey,
            PrivateKey.generate().privateKey,
            PrivateKey.generate().privateKey]
        
        let expectedKeyring = try KeyringFactory.createWithMultipleKey(expectedAddress, expectedAddressKeys)
        let actualKeyring = expectedKeyring.copy()
        
        try checkValidateMultipleKey(actualKeyring as! MultipleKeyring, expectedAddress, expectedAddressKeys)
    }
    
    func testCopy_roleBasedKey() throws {
        guard let expectedAddress = KeyringFactory.generate()?.address else { XCTAssert(true); return }
        let expectedPrivateKeyArr = [
            [PrivateKey.generate().privateKey,
             PrivateKey.generate().privateKey],
            [PrivateKey.generate().privateKey],
            [PrivateKey.generate().privateKey]]
        
        let expectedKeyring = try KeyringFactory.createWithRoleBasedKey(expectedAddress, expectedPrivateKeyArr)
        let actualKeyring = expectedKeyring.copy()
        
        try checkValidateRoleBasedKey(actualKeyring as! RoleBasedKeyring, expectedAddress, expectedPrivateKeyArr)
    }
}

class signWithKeyTest: XCTestCase {
    let HASH = "0xe9a11d9ef95fb437f75d07ce768d43e74f158dd54b106e7d3746ce29d545b550"
    let CHAIN_ID = 1
    
    func testCoupleKey() throws {
        guard let keyring = KeyringFactory.generate(),
              let signatureData = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue, 0) else { XCTAssert(true); return }
        
        XCTAssertFalse(signatureData.r.isEmpty)
        XCTAssertFalse(signatureData.s.isEmpty)
        XCTAssertFalse(signatureData.v.isEmpty)
    }
    
    func testCoupledKey_with_NotExistedRole() throws {
        guard let keyring = KeyringFactory.generate(),
              let expectedSignatureData = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue, 0),
              let signatureData = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.ACCOUNT_UPDATE.rawValue, 0) else { XCTAssert(true); return }
        
        XCTAssertFalse(signatureData.r.isEmpty)
        XCTAssertFalse(signatureData.s.isEmpty)
        XCTAssertFalse(signatureData.v.isEmpty)
        
        XCTAssertEqual(expectedSignatureData.r, signatureData.r)
        XCTAssertEqual(expectedSignatureData.s, signatureData.s)
        XCTAssertEqual(expectedSignatureData.v, signatureData.v)
    }
    
    func testCoupleKey_throwException_negativeKeyIndex() throws {
        guard let keyring = KeyringFactory.generate() else { XCTAssert(true); return }
        
        XCTAssertThrowsError(try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue, -1)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid index : index cannot be negative"))
        }
    }
    
    func testCoupleKey_throwException_outOfBoundKeyIndex() throws {
        guard let keyring = KeyringFactory.generate() else { XCTAssert(true); return }
        
        XCTAssertThrowsError(try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue, 1)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid index : index must be less than the length of the key."))
        }
    }
    
    func testDeCoupleKey() throws {
        let address = PrivateKey.generate().getDerivedAddress()
        let privateKey = PrivateKey.generate().privateKey
        let keyring = try KeyringFactory.create(address, privateKey)
        guard let signatureData = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue, 0) else { XCTAssert(true); return }
        
        XCTAssertFalse(signatureData.r.isEmpty)
        XCTAssertFalse(signatureData.s.isEmpty)
        XCTAssertFalse(signatureData.v.isEmpty)
    }
    
    func testDeCoupleKey_With_NotExistedRole() throws {
        let address = PrivateKey.generate().getDerivedAddress()
        let privateKey = PrivateKey.generate().privateKey
        let keyring = try KeyringFactory.create(address, privateKey)
        guard let expectedSignatureData = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue, 0),
              let signatureData = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.ACCOUNT_UPDATE.rawValue, 0) else { XCTAssert(true); return }
        
        XCTAssertFalse(signatureData.r.isEmpty)
        XCTAssertFalse(signatureData.s.isEmpty)
        XCTAssertFalse(signatureData.v.isEmpty)
        
        XCTAssertEqual(expectedSignatureData.r, signatureData.r)
        XCTAssertEqual(expectedSignatureData.s, signatureData.s)
        XCTAssertEqual(expectedSignatureData.v, signatureData.v)
    }
    
    func testDeCoupleKey_throwException_negativeKeyIndex() throws {
        let address = PrivateKey.generate().getDerivedAddress()
        let privateKey = PrivateKey.generate().privateKey
        let keyring = try KeyringFactory.create(address, privateKey)
        
        XCTAssertThrowsError(try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue, -1)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid index : index cannot be negative"))
        }
    }
    
    func testDeCoupleKey_throwException_outOfBoundKeyIndex() throws {
        let address = PrivateKey.generate().getDerivedAddress()
        let privateKey = PrivateKey.generate().privateKey
        let keyring = try KeyringFactory.create(address, privateKey)
        
        XCTAssertThrowsError(try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue, 1)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid index : index must be less than the length of the key."))
        }
    }
    
    func testMultipleKey() throws {
        let keyring = try generateMultipleKeyring(3)
        guard let signatureData = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue, 1) else { XCTAssert(true); return }
        
        XCTAssertFalse(signatureData.r.isEmpty)
        XCTAssertFalse(signatureData.s.isEmpty)
        XCTAssertFalse(signatureData.v.isEmpty)
    }
    
    func testMultipleKey_With_NotExistedRole() throws {
        let keyring = try generateMultipleKeyring(3)
        guard let expectedSignatureData = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue, 0),
              let signatureData = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.ACCOUNT_UPDATE.rawValue, 0) else { XCTAssert(true); return }
        
        XCTAssertFalse(signatureData.r.isEmpty)
        XCTAssertFalse(signatureData.s.isEmpty)
        XCTAssertFalse(signatureData.v.isEmpty)
        
        XCTAssertEqual(expectedSignatureData.r, signatureData.r)
        XCTAssertEqual(expectedSignatureData.s, signatureData.s)
        XCTAssertEqual(expectedSignatureData.v, signatureData.v)
    }
    
    func testMultipleKey_throwException_negativeKeyIndex() throws {
        let keyring = try generateMultipleKeyring(3)
        
        XCTAssertThrowsError(try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.ACCOUNT_UPDATE.rawValue, -1)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid index : index cannot be negative"))
        }
    }
    
    func testMultipleKey_throwException_outOfBoundKeyIndex() throws {
        let keyring = try generateMultipleKeyring(3)
        
        XCTAssertThrowsError(try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue, 10)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid index : index must be less than the length of the key."))
        }
    }
    
    func testRoleBasedKey() throws {
        let keyring = try generateRoleBaseKeyring([2, 3, 4])
        guard let signatureData = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue, 1) else { XCTAssert(true); return }
        
        XCTAssertFalse(signatureData.r.isEmpty)
        XCTAssertFalse(signatureData.s.isEmpty)
        XCTAssertFalse(signatureData.v.isEmpty)
    }
    
    func testRoleBasedKey_With_NotExistedRole() throws {
        let keyring = try generateRoleBaseKeyring([2, 0, 4])
        guard let expectedSignatureData = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue, 0),
              let signatureData = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.ACCOUNT_UPDATE.rawValue, 0) else { XCTAssert(true); return }
        
        XCTAssertFalse(signatureData.r.isEmpty)
        XCTAssertFalse(signatureData.s.isEmpty)
        XCTAssertFalse(signatureData.v.isEmpty)
        
        XCTAssertEqual(expectedSignatureData.r, signatureData.r)
        XCTAssertEqual(expectedSignatureData.s, signatureData.s)
        XCTAssertEqual(expectedSignatureData.v, signatureData.v)
    }
    
    func testRoleBasedKey_throwException_negativeKeyIndex() throws {
        let keyring = try generateRoleBaseKeyring([2, 0, 4])
        
        XCTAssertThrowsError(try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue, -1)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid index : index cannot be negative"))
        }
    }
    
    func testRoleBasedKey_throwException_outOfBoundKeyIndex() throws {
        let keyring = try generateRoleBaseKeyring([2, 0, 4])
        
        XCTAssertThrowsError(try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue, 10)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid index : index must be less than the length of the key."))
        }
    }
}

class signWithKeysTest: XCTestCase {
    let HASH = "0xe9a11d9ef95fb437f75d07ce768d43e74f158dd54b106e7d3746ce29d545b550"
    let CHAIN_ID = 1
    
    func checkSignature(_ expected: [SignatureData], _ actual: [SignatureData]) throws {
        XCTAssertEqual(expected.count, actual.count)
        
        zip(expected, actual).forEach {
            XCTAssertEqual($0.r, $1.r)
            XCTAssertEqual($0.s, $1.s)
            XCTAssertEqual($0.v, $1.v)
        }
    }
    
    func testCoupleKey() throws {
        guard let keyring = KeyringFactory.generate(),
              let signatureDataList = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue) else { XCTAssert(true); return }
        
        XCTAssertEqual(1, signatureDataList.count)
        XCTAssertFalse(signatureDataList[0].r.isEmpty)
        XCTAssertFalse(signatureDataList[0].s.isEmpty)
        XCTAssertFalse(signatureDataList[0].v.isEmpty)
    }
    
    func testCoupleKey_with_NotExistedRole() throws {
        guard let keyring = KeyringFactory.generate(),
              let expectedList = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue),
              let actualList = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.ACCOUNT_UPDATE.rawValue) else { XCTAssert(true); return }
        
        XCTAssertEqual(1, actualList.count)
        XCTAssertFalse(actualList[0].r.isEmpty)
        XCTAssertFalse(actualList[0].s.isEmpty)
        XCTAssertFalse(actualList[0].v.isEmpty)
        
        try checkSignature(expectedList, actualList)
    }
        
    func testDeCoupleKey() throws {
        let address = PrivateKey.generate().getDerivedAddress()
        let privateKey = PrivateKey.generate().privateKey
        let keyring = try KeyringFactory.create(address, privateKey)
        guard let actualList = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue) else { XCTAssert(true); return }
        
        XCTAssertEqual(1, actualList.count)
        XCTAssertFalse(actualList[0].r.isEmpty)
        XCTAssertFalse(actualList[0].s.isEmpty)
        XCTAssertFalse(actualList[0].v.isEmpty)
    }
    
    func testDeCoupleKey_With_NotExistedRole() throws {
        let address = PrivateKey.generate().getDerivedAddress()
        let privateKey = PrivateKey.generate().privateKey
        let keyring = try KeyringFactory.create(address, privateKey)
        guard let expectedList = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue),
              let actualList = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.ACCOUNT_UPDATE.rawValue) else { XCTAssert(true); return }
        
        XCTAssertEqual(1, actualList.count)
        try checkSignature(expectedList, actualList)
    }
    
    func testMultipleKey() throws {
        let keyring = try generateMultipleKeyring(3)
        guard let actualList = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue) else { XCTAssert(true); return }
        
        XCTAssertEqual(3, actualList.count)
        actualList.forEach {
            XCTAssertFalse($0.r.isEmpty)
            XCTAssertFalse($0.s.isEmpty)
            XCTAssertFalse($0.v.isEmpty)
        }
    }
    
    func testMultipleKey_With_NotExistedRole() throws {
        let keyring = try generateMultipleKeyring(3)
        guard let expectedList = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue),
              let actualList = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.ACCOUNT_UPDATE.rawValue) else { XCTAssert(true); return }
        
        XCTAssertEqual(3, actualList.count)
        try checkSignature(expectedList, actualList)
    }
    
    func testRoleBasedKey() throws {
        let keyring = try generateRoleBaseKeyring([3, 3, 4])
        guard let actualList = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue) else { XCTAssert(true); return }
        
        XCTAssertEqual(3, actualList.count)
        actualList.forEach {
            XCTAssertFalse($0.r.isEmpty)
            XCTAssertFalse($0.s.isEmpty)
            XCTAssertFalse($0.v.isEmpty)
        }
    }
    
    func testRoleBasedKey_With_NotExistedRole() throws {
        let keyring = try generateRoleBaseKeyring([3, 0, 4])
        guard let expectedList = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue),
              let actualList = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.ACCOUNT_UPDATE.rawValue) else { XCTAssert(true); return }
        
        XCTAssertEqual(3, actualList.count)
        try checkSignature(expectedList, actualList)
    }
}

class signMessageTest: XCTestCase {
    let data = "some data"
            
    func testCoupledKey_NoIndex() throws {
        guard let keyring = KeyringFactory.generate(),
              let expect = try? keyring.signMessage(data, 0, 0),
              let actual = try? keyring.signMessage(data, 0) else { XCTAssert(true); return }
        
        XCTAssertEqual(expect.message, actual.message)
        XCTAssertEqual(expect.messageHash, actual.messageHash)
        
        XCTAssertEqual(expect.signatures[0].r, actual.signatures[0].r)
        XCTAssertEqual(expect.signatures[0].s, actual.signatures[0].s)
        XCTAssertEqual(expect.signatures[0].v, actual.signatures[0].v)
    }
    
    func testCoupleKey_WithIndex() throws {
        guard let keyring = KeyringFactory.generate(),
              let actual = try? keyring.signMessage(data, 0, 0) else { XCTAssert(true); return }
        
        XCTAssertEqual(Utils.hashMessage(data), actual.messageHash)
        XCTAssertFalse(actual.signatures[0].r.isEmpty)
        XCTAssertFalse(actual.signatures[0].s.isEmpty)
        XCTAssertFalse(actual.signatures[0].v.isEmpty)
    }
    
    func testCoupleKey_NotExistedRoleIndex() throws {
        guard let keyring = KeyringFactory.generate(),
              let expect = try? keyring.signMessage(data, 0, 0),
              let actual = try? keyring.signMessage(data, AccountKeyRoleBased.RoleGroup.FEE_PAYER.rawValue, 0) else { XCTAssert(true); return }
        
        XCTAssertEqual(expect.message, actual.message)
        XCTAssertEqual(expect.messageHash, actual.messageHash)
        
        XCTAssertEqual(expect.signatures[0].r, actual.signatures[0].r)
        XCTAssertEqual(expect.signatures[0].s, actual.signatures[0].s)
        XCTAssertEqual(expect.signatures[0].v, actual.signatures[0].v)
    }
    
    func testRoleBasedKey_throwException_outOfBoundKeyIndex() throws {
        guard let keyring = KeyringFactory.generate() else { XCTAssert(true); return }
        
        XCTAssertThrowsError(try keyring.signMessage(data, 0, 3)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid index : index must be less than the length of the key."))
        }
    }
    
    func testCoupleKey_throwException_WithNegativeKeyIndex() throws {
        guard let keyring = KeyringFactory.generate() else { XCTAssert(true); return }
        
        XCTAssertThrowsError(try keyring.signMessage(data, 0, -1)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid index : index cannot be negative"))
        }
    }
    
    func testDecoupledKey_NoIndex() throws {
        let address = PrivateKey.generate().getDerivedAddress()
        let privateKey = PrivateKey.generate().privateKey
        let decoupled = try KeyringFactory.create(address, privateKey)
        guard let expect = try? decoupled.signMessage(data, 0, 0),
              let actual = try? decoupled.signMessage(data, 0) else { XCTAssert(true); return }
        
        XCTAssertEqual(expect.message, actual.message)
        XCTAssertEqual(expect.messageHash, actual.messageHash)
        
        XCTAssertEqual(expect.signatures[0].r, actual.signatures[0].r)
        XCTAssertEqual(expect.signatures[0].s, actual.signatures[0].s)
        XCTAssertEqual(expect.signatures[0].v, actual.signatures[0].v)
    }
    
    func testDecoupledKey_WithIndex() throws {
        let address = PrivateKey.generate().getDerivedAddress()
        let privateKey = PrivateKey.generate().privateKey
        let decoupled = try KeyringFactory.create(address, privateKey)
        guard let actual = try? decoupled.signMessage(data, 0, 0) else { XCTAssert(true); return }
        
        XCTAssertEqual(Utils.hashMessage(data), actual.messageHash)
        XCTAssertFalse(actual.signatures[0].r.isEmpty)
        XCTAssertFalse(actual.signatures[0].s.isEmpty)
        XCTAssertFalse(actual.signatures[0].v.isEmpty)
    }
    
    func testDecoupleKey_NotExistedRoleIndex() throws {
        let address = PrivateKey.generate().getDerivedAddress()
        let privateKey = PrivateKey.generate().privateKey
        let decoupled = try KeyringFactory.create(address, privateKey)
        guard let expect = try? decoupled.signMessage(data, 0, 0),
              let actual = try? decoupled.signMessage(data, AccountKeyRoleBased.RoleGroup.FEE_PAYER.rawValue, 0) else { XCTAssert(true); return }
        
        XCTAssertEqual(expect.message, actual.message)
        XCTAssertEqual(expect.messageHash, actual.messageHash)
        
        XCTAssertEqual(expect.signatures[0].r, actual.signatures[0].r)
        XCTAssertEqual(expect.signatures[0].s, actual.signatures[0].s)
        XCTAssertEqual(expect.signatures[0].v, actual.signatures[0].v)
    }
    
    func testDecoupleKey_throwException_WithInvalidKeyIndex() throws {
        let address = PrivateKey.generate().getDerivedAddress()
        let privateKey = PrivateKey.generate().privateKey
        let decoupled = try KeyringFactory.create(address, privateKey)
        
        XCTAssertThrowsError(try decoupled.signMessage(data, 0, 3)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid index : index must be less than the length of the key."))
        }
    }
    
    func testDecoupleKey_throwException_WithNegativeKeyIndex() throws {
        let address = PrivateKey.generate().getDerivedAddress()
        let privateKey = PrivateKey.generate().privateKey
        let decoupled = try KeyringFactory.create(address, privateKey)
        
        XCTAssertThrowsError(try decoupled.signMessage(data, 0, -1)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid index : index cannot be negative"))
        }
    }
    
    func testMultipleKey_NoIndex() throws {
        let keyring = try generateMultipleKeyring(3)
        guard let expect = try? keyring.signMessage(data, 0, 0),
              let actual = try? keyring.signMessage(data, 0) else { XCTAssert(true); return }
        
        XCTAssertEqual(expect.message, actual.message)
        XCTAssertEqual(expect.messageHash, actual.messageHash)
        
        XCTAssertEqual(expect.signatures[0].r, actual.signatures[0].r)
        XCTAssertEqual(expect.signatures[0].s, actual.signatures[0].s)
        XCTAssertEqual(expect.signatures[0].v, actual.signatures[0].v)
    }
    
    func testMultipleKey_WithIndex() throws {
        let keyring = try generateMultipleKeyring(3)
        guard let actual = try? keyring.signMessage(data, 0, 0) else { XCTAssert(true); return }
        
        XCTAssertEqual(Utils.hashMessage(data), actual.messageHash)
        XCTAssertFalse(actual.signatures[0].r.isEmpty)
        XCTAssertFalse(actual.signatures[0].s.isEmpty)
        XCTAssertFalse(actual.signatures[0].v.isEmpty)
    }
    
    func testMultipleKey_NotExistedRoleIndex() throws {
        let keyring = try generateMultipleKeyring(3)
        guard let expect = try? keyring.signMessage(data, 0, 2),
              let actual = try? keyring.signMessage(data, AccountKeyRoleBased.RoleGroup.FEE_PAYER.rawValue, 2) else { XCTAssert(true); return }
        
        XCTAssertEqual(expect.message, actual.message)
        XCTAssertEqual(expect.messageHash, actual.messageHash)
        
        XCTAssertEqual(expect.signatures[0].r, actual.signatures[0].r)
        XCTAssertEqual(expect.signatures[0].s, actual.signatures[0].s)
        XCTAssertEqual(expect.signatures[0].v, actual.signatures[0].v)
    }
    
    func testMultipleKey_throwException_WithInvalidKeyIndex() throws {
        let keyring = try generateMultipleKeyring(3)
        
        XCTAssertThrowsError(try keyring.signMessage(data, 0, 6)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid index : index must be less than the length of the key."))
        }
    }
    
    func testMultipleKey_throwException_WithNegativeKeyIndex() throws {
        let keyring = try generateMultipleKeyring(3)
        
        XCTAssertThrowsError(try keyring.signMessage(data, 0, -1)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid index : index cannot be negative"))
        }
    }
    
    func testRoleBasedKey_WithIndex() throws {
        let keyring = try generateRoleBaseKeyring([3, 4, 5])
        guard let actual = try? keyring.signMessage(data, 0, 0) else { XCTAssert(true); return }
        
        XCTAssertEqual(Utils.hashMessage(data), actual.messageHash)
        XCTAssertFalse(actual.signatures[0].r.isEmpty)
        XCTAssertFalse(actual.signatures[0].s.isEmpty)
        XCTAssertFalse(actual.signatures[0].v.isEmpty)
    }
    
    func testRoleBasedKey_NotExistedRoleKey() throws {
        let keyring = try generateRoleBaseKeyring([3, 0, 5])
        guard let expect = try? keyring.signMessage(data, 0, 2),
              let actual = try? keyring.signMessage(data, AccountKeyRoleBased.RoleGroup.ACCOUNT_UPDATE.rawValue, 2) else { XCTAssert(true); return }
        
        XCTAssertEqual(expect.message, actual.message)
        XCTAssertEqual(expect.messageHash, actual.messageHash)
        
        XCTAssertEqual(expect.signatures[0].r, actual.signatures[0].r)
        XCTAssertEqual(expect.signatures[0].s, actual.signatures[0].s)
        XCTAssertEqual(expect.signatures[0].v, actual.signatures[0].v)
    }
    
    func testRoleBasedKey_throwException_WithInvalidKey() throws {
        let keyring = try generateRoleBaseKeyring([3, 4, 5])
        
        XCTAssertThrowsError(try keyring.signMessage(data, 0, 8)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid index : index must be less than the length of the key."))
        }
    }
    
    func testRoleBasedKey_throwException_WithNegativeKeyIndex() throws {
        let keyring = try generateRoleBaseKeyring([3, 4, 5])
        
        XCTAssertThrowsError(try keyring.signMessage(data, 0, -1)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid index : index cannot be negative"))
        }
    }
}

class recoverTest: XCTestCase {
    let data = "some data"
    
    func checkAddress(_ expect: String, _ actual: String) throws {
        let expect = expect.cleanHexPrefix
        let actual = actual.cleanHexPrefix
        XCTAssertEqual(expect, actual)
    }
            
    func testWithMessageAndSignature() throws {
        guard let keyring = KeyringFactory.generate(),
              let signed = try keyring.signMessage(data, 0, 0) else { XCTAssert(true); return }
        
        let actualAddr = try Utils.recover(signed.message, signed.signatures[0])
        
        try checkAddress(keyring.address, actualAddr)
    }
    
    func testAlreadyPrefix() throws {
        guard let keyring = KeyringFactory.generate(),
              let signed = try keyring.signMessage(data, 0, 0) else { XCTAssert(true); return }
        
        let actualAddr = try Utils.recover(signed.messageHash, signed.signatures[0], true)
        
        try checkAddress(keyring.address, actualAddr)
    }
}

class decryptTest: XCTestCase {
    let jsonV3 = "{" +
        "  \"version\":3," +
        "  \"id\":\"7a0a8557-22a5-4c90-b554-d6f3b13783ea\"," +
        "  \"address\":\"0x86bce8c859f5f304aa30adb89f2f7b6ee5a0d6e2\"," +
        "  \"crypto\":{" +
        "    \"ciphertext\":\"696d0e8e8bd21ff1f82f7c87b6964f0f17f8bfbd52141069b59f084555f277b7\"," +
        "    \"cipherparams\":{\"iv\":\"1fd13e0524fa1095c5f80627f1d24cbd\"}," +
        "    \"cipher\":\"aes-128-ctr\"," +
        "    \"kdf\":\"scrypt\"," +
        "    \"kdfparams\":{" +
        "      \"dklen\":32," +
        "      \"salt\":\"7ee980925cef6a60553cda3e91cb8e3c62733f64579f633d0f86ce050c151e26\"," +
        "      \"n\":4096," +
        "      \"r\":8," +
        "      \"p\":1" +
        "    }," +
        "    \"mac\":\"8684d8dc4bf17318cd46c85dbd9a9ec5d9b290e04d78d4f6b5be9c413ff30ea4\"" +
        "  }" +
        "}"
                    
    let jsonV4 = "{" +
        "  \"version\":4," +
        "  \"id\":\"55da3f9c-6444-4fc1-abfa-f2eabfc57501\"," +
        "  \"address\":\"0x86bce8c859f5f304aa30adb89f2f7b6ee5a0d6e2\"," +
        "  \"keyring\":[" +
        "    [" +
        "      {" +
        "        \"ciphertext\":\"93dd2c777abd9b80a0be8e1eb9739cbf27c127621a5d3f81e7779e47d3bb22f6\"," +
        "        \"cipherparams\":{\"iv\":\"84f90907f3f54f53d19cbd6ae1496b86\"}," +
        "        \"cipher\":\"aes-128-ctr\"," +
        "        \"kdf\":\"scrypt\"," +
        "        \"kdfparams\":{" +
        "          \"dklen\":32," +
        "          \"salt\":\"69bf176a136c67a39d131912fb1e0ada4be0ed9f882448e1557b5c4233006e10\"," +
        "          \"n\":4096," +
        "          \"r\":8," +
        "          \"p\":1" +
        "        }," +
        "        \"mac\":\"8f6d1d234f4a87162cf3de0c7fb1d4a8421cd8f5a97b86b1a8e576ffc1eb52d2\"" +
        "      }," +
        "      {" +
        "        \"ciphertext\":\"53d50b4e86b550b26919d9b8cea762cd3c637dfe4f2a0f18995d3401ead839a6\"," +
        "        \"cipherparams\":{\"iv\":\"d7a6f63558996a9f99e7daabd289aa2c\"}," +
        "        \"cipher\":\"aes-128-ctr\"," +
        "        \"kdf\":\"scrypt\"," +
        "        \"kdfparams\":{" +
        "          \"dklen\":32," +
        "          \"salt\":\"966116898d90c3e53ea09e4850a71e16df9533c1f9e1b2e1a9edec781e1ad44f\"," +
        "          \"n\":4096," +
        "          \"r\":8," +
        "          \"p\":1" +
        "        }," +
        "        \"mac\":\"bca7125e17565c672a110ace9a25755847d42b81aa7df4bb8f5ce01ef7213295\"" +
        "      }" +
        "    ]," +
        "    [" +
        "      {" +
        "        \"ciphertext\":\"f16def98a70bb2dae053f791882f3254c66d63416633b8d91c2848893e7876ce\"," +
        "        \"cipherparams\":{\"iv\":\"f5006128a4c53bc02cada64d095c15cf\"}," +
        "        \"cipher\":\"aes-128-ctr\"," +
        "        \"kdf\":\"scrypt\"," +
        "        \"kdfparams\":{" +
        "          \"dklen\":32," +
        "          \"salt\":\"0d8a2f71f79c4880e43ff0795f6841a24cb18838b3ca8ecaeb0cda72da9a72ce\"," +
        "          \"n\":4096," +
        "          \"r\":8," +
        "          \"p\":1" +
        "        }," +
        "        \"mac\":\"38b79276c3805b9d2ff5fbabf1b9d4ead295151b95401c1e54aed782502fc90a\"" +
        "      }" +
        "    ]," +
        "    [" +
        "      {" +
        "        \"ciphertext\":\"544dbcc327942a6a52ad6a7d537e4459506afc700a6da4e8edebd62fb3dd55ee\"," +
        "        \"cipherparams\":{\"iv\":\"05dd5d25ad6426e026818b6fa9b25818\"}," +
        "        \"cipher\":\"aes-128-ctr\"," +
        "        \"kdf\":\"scrypt\"," +
        "        \"kdfparams\":{" +
        "          \"dklen\":32," +
        "          \"salt\":\"3a9003c1527f65c772c54c6056a38b0048c2e2d58dc0e584a1d867f2039a25aa\"," +
        "          \"n\":4096," +
        "          \"r\":8," +
        "          \"p\":1" +
        "        }," +
        "        \"mac\":\"19a698b51409cc9ac22d63d329b1201af3c89a04a1faea3111eec4ca97f2e00f\"" +
        "      }," +
        "      {" +
        "        \"ciphertext\":\"dd6b920f02cbcf5998ed205f8867ddbd9b6b088add8dfe1774a9fda29ff3920b\"," +
        "        \"cipherparams\":{\"iv\":\"ac04c0f4559dad80dc86c975d1ef7067\"}," +
        "        \"cipher\":\"aes-128-ctr\"," +
        "        \"kdf\":\"scrypt\"," +
        "        \"kdfparams\":{" +
        "          \"dklen\":32," +
        "          \"salt\":\"22279c6dbcc706d7daa120022a236cfe149496dca8232b0f8159d1df999569d6\"," +
        "          \"n\":4096," +
        "          \"r\":8," +
        "          \"p\":1" +
        "        }," +
        "        \"mac\":\"1c54f7378fa279a49a2f790a0adb683defad8535a21bdf2f3dadc48a7bddf517\"" +
        "      }" +
        "    ]" +
        "  ]" +
        "}"
    
    let password = "password"
    
    func testCoupleKey() throws {
        let privateKey = PrivateKey.generate().privateKey
        let expect = try KeyringFactory.createFromPrivateKey(privateKey)
        let option = try KeyStoreOption.getDefaultOptionWithKDF(KeyStore.Pbkdf2KdfParams.NAME)
        
        guard let keyStore = try expect.encrypt(password, option) else { XCTAssert(true); return }
        let actual = try KeyringFactory.decrypt(keyStore, password)
        
        try checkValidKeyring(expect, actual)
    }
    
    func testDeCoupleKey() throws {
        let privateKey = PrivateKey.generate().privateKey
        let address = PrivateKey.generate().getDerivedAddress()
        let expect = try KeyringFactory.create(address, privateKey)
        let option = try KeyStoreOption.getDefaultOptionWithKDF(KeyStore.Pbkdf2KdfParams.NAME)
        
        guard let keyStore = try expect.encrypt(password, option) else { XCTAssert(true); return }
        let actual = try KeyringFactory.decrypt(keyStore, password)
        
        try checkValidKeyring(expect, actual)
    }
    
    func testMmultipleKey() throws {
        let expect = try generateMultipleKeyring(3)
        let option = try KeyStoreOption.getDefaultOptionWithKDF(KeyStore.Pbkdf2KdfParams.NAME)
        
        guard let keyStore = try expect.encrypt(password, option) else { XCTAssert(true); return }
        let actual = try KeyringFactory.decrypt(keyStore, password)
        
        try checkValidKeyring(expect, actual)
    }
    
    func testRoleBasedKey() throws {
        let expect = try generateRoleBaseKeyring([3, 4, 5])
        let option = try KeyStoreOption.getDefaultOptionWithKDF(KeyStore.Pbkdf2KdfParams.NAME)
        
        guard let keyStore = try expect.encrypt(password, option) else { XCTAssert(true); return }
        let actual = try KeyringFactory.decrypt(keyStore, password)
        
        try checkValidKeyring(expect, actual)
    }
    
    func testRoleBasedKey_withEmptyRole() throws {
        let expect = try generateRoleBaseKeyring([3, 0, 5])
        let option = try KeyStoreOption.getDefaultOptionWithKDF(KeyStore.Pbkdf2KdfParams.NAME)
        
        guard let keyStore = try expect.encrypt(password, option) else { XCTAssert(true); return }
        let actual = try KeyringFactory.decrypt(keyStore, password)
        
        try checkValidKeyring(expect, actual)
    }
    
    func testJsonStringV4() throws {
        let expectedAddress = "0x86bce8c859f5f304aa30adb89f2f7b6ee5a0d6e2"
        let expectedPrivateKeys = [
            ["0xd1e9f8f00ef9f93365f5eabccccb3f3c5783001b61a40f0f74270e50158c163d",
             "0x4bd8d0b0c1575a7a35915f9af3ef8beb11ad571337ec9b6aca7c88ca7458ef5c"],
            ["0xdc2690ac6017e32ef17ea219c2a2fd14a2bb73e7a0a253dfd69abba3eb8d7d91"],
            ["0xf17bf8b7bee09ffc50a401b7ba8e633b9e55eedcf776782f2a55cf7cc5c40aa8",
             "0x4f8f1e9e1466609b836dba611a0a24628aea8ee11265f757aa346bde3d88d548"]
        ]
        let expect = try KeyringFactory.createWithRoleBasedKey(expectedAddress, expectedPrivateKeys)
        let actual = try KeyringFactory.decrypt(jsonV4, password)
        
        try checkValidKeyring(expect, actual)
    }
    
    func testJsonStringV3() throws {
        let expectedAddress = "0x86bce8c859f5f304aa30adb89f2f7b6ee5a0d6e2"
        let expectedPrivateKeys = "0x36e0a792553f94a7660e5484cfc8367e7d56a383261175b9abced7416a5d87df"
        let expect = try KeyringFactory.createWithSingleKey(expectedAddress, expectedPrivateKeys)
        let actual = try KeyringFactory.decrypt(jsonV3, password)
        
        try checkValidKeyring(expect, actual)
    }
}

class encryptTest: XCTestCase {
    let password = "password"
    
    func checkValidateKeyStore(_ actualData: KeyStore, _ password: String, _ expectedKeyring: AbstractKeyring, _ version: Int) throws {
        XCTAssertEqual(expectedKeyring.address, actualData.address)
        
        if actualData.version == 4 {
            XCTAssertNil(actualData.crypto)
            XCTAssertNotNil(actualData.keyring)
        }
        
        if expectedKeyring is RoleBasedKeyring {
            XCTAssertTrue(actualData.keyring![0] is [Any])
        } else {
            XCTAssertTrue(actualData.keyring![0] is KeyStore.Crypto)
        }
        
        try checkValidKeyring(expectedKeyring, KeyringFactory.decrypt(actualData, password))
    }
    
    func testKeyStoreV4_scrypt() throws {
        guard let keyring = KeyringFactory.generate() else { XCTAssert(true); return }
        let option = try KeyStoreOption.getDefaultOptionWithKDF(KeyStore.ScryptKdfParams.NAME)
        
        guard let keyStore = try keyring.encrypt(password, option) else { XCTAssert(true); return }
                
        try checkValidateKeyStore(keyStore, password, keyring, 4)
    }
    
    func testKeyStoreV4_pbkdf2() throws {
        guard let keyring = KeyringFactory.generate() else { XCTAssert(true); return }
        let option = try KeyStoreOption.getDefaultOptionWithKDF(KeyStore.Pbkdf2KdfParams.NAME)
        
        guard let keyStore = try keyring.encrypt(password, option) else { XCTAssert(true); return }
                
        try checkValidateKeyStore(keyStore, password, keyring, 4)
    }
    
    func testKeyring_single() throws {
        guard let keyring = KeyringFactory.generate() else { XCTAssert(true); return }
        let option = try KeyStoreOption.getDefaultOptionWithKDF(KeyStore.ScryptKdfParams.NAME, keyring.address)
        
        guard let keyStore = try keyring.encrypt(password, option) else { XCTAssert(true); return }              
        try checkValidateKeyStore(keyStore, password, keyring, 4)
    }
    
    func testKeyring_multiple() throws {
        let keyring = try generateMultipleKeyring(3)
        let option = try KeyStoreOption.getDefaultOptionWithKDF(KeyStore.ScryptKdfParams.NAME, keyring.address)
        
        guard let keyStore = try keyring.encrypt(password, option) else { XCTAssert(true); return }
        try checkValidateKeyStore(keyStore, password, keyring, 4)
    }
    
    func testKeyring_roleBased() throws {
        let keyring = try generateRoleBaseKeyring([3, 4, 5])
        let option = try KeyStoreOption.getDefaultOptionWithKDF(KeyStore.ScryptKdfParams.NAME, keyring.address)
        
        guard let keyStore = try keyring.encrypt(password, option) else { XCTAssert(true); return }
        try checkValidateKeyStore(keyStore, password, keyring, 4)
    }
    
    func testAbstractKeyring_singleKey() throws {
        guard let keyring: AbstractKeyring = KeyringFactory.generate() else { XCTAssert(true); return }
        let option = try KeyStoreOption.getDefaultOptionWithKDF(KeyStore.ScryptKdfParams.NAME, keyring.address)
        
        guard let keyStore = try keyring.encrypt(password, option) else { XCTAssert(true); return }
        try checkValidateKeyStore(keyStore, password, keyring, 4)
    }
    
    func testAbstractKeyring_multiple() throws {
        let keyring: AbstractKeyring = try generateMultipleKeyring(3)
        let option = try KeyStoreOption.getDefaultOptionWithKDF(KeyStore.ScryptKdfParams.NAME, keyring.address)
        
        guard let keyStore = try keyring.encrypt(password, option) else { XCTAssert(true); return }
        try checkValidateKeyStore(keyStore, password, keyring, 4)
    }
    
    func testAbstractKeyring_roleBased() throws {
        let keyring: AbstractKeyring = try generateRoleBaseKeyring([3, 4, 5])
        let option = try KeyStoreOption.getDefaultOptionWithKDF(KeyStore.ScryptKdfParams.NAME, keyring.address)
        
        guard let keyStore = try keyring.encrypt(password, option) else { XCTAssert(true); return }
        try checkValidateKeyStore(keyStore, password, keyring, 4)
    }
    
    func testSingleKeyring_noOptions() throws {
        guard let keyring = KeyringFactory.generate() else { XCTAssert(true); return }
        guard let keyStore = try keyring.encrypt(password) else { XCTAssert(true); return }
        try checkValidateKeyStore(keyStore, password, keyring, 4)
    }
    
    func testMultipleKeyring_noOptions() throws {
        let keyring = try generateMultipleKeyring(3)
        guard let keyStore = try keyring.encrypt(password) else { XCTAssert(true); return }
        try checkValidateKeyStore(keyStore, password, keyring, 4)
    }
    
    func testRoleBasedKeyring_noOptions() throws {
        let keyring = try generateRoleBaseKeyring([3, 4, 5])
        guard let keyStore = try keyring.encrypt(password) else { XCTAssert(true); return }
        try checkValidateKeyStore(keyStore, password, keyring, 4)
    }
}

class encryptV3Test: XCTestCase {
    let password = "password"
    
    func checkValidateKeyStore(_ actualData: KeyStore, _ password: String, _ expectedKeyring: AbstractKeyring, _ version: Int) throws {
        XCTAssertEqual(expectedKeyring.address, actualData.address)
        XCTAssertEqual(version, actualData.version)
        XCTAssertNotNil(actualData.crypto)
        XCTAssertNil(actualData.keyring)
        try checkValidKeyring(expectedKeyring, KeyringFactory.decrypt(actualData, password))
    }
    
    func testKeyring_single() throws {
        guard let keyring = KeyringFactory.generate() else { XCTAssert(true); return }
        let option = try KeyStoreOption.getDefaultOptionWithKDF(KeyStore.ScryptKdfParams.NAME, keyring.address)
        
        guard let keyStore = try keyring.encryptV3(password, option) else { XCTAssert(true); return }
        
        try checkValidateKeyStore(keyStore, password, keyring, 3)
    }
    
    func testKeyring_single_noOption() throws {
        guard let keyring = KeyringFactory.generate() else { XCTAssert(true); return }
        guard let keyStore = try keyring.encryptV3(password) else { XCTAssert(true); return }
        
        try checkValidateKeyStore(keyStore, password, keyring, 3)
    }
    
    func testThrowException_keyring_multiple() throws {
        let keyring = try generateMultipleKeyring(3)
        let option = try KeyStoreOption.getDefaultOptionWithKDF(KeyStore.ScryptKdfParams.NAME, keyring.address)
        
        XCTAssertThrowsError(try keyring.encryptV3(password, option)) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("Not supported for this class. Use 'encrypt()' function"))
        }
    }
    
    func testThrowException_keyring_roleBased() throws {
        let keyring = try generateRoleBaseKeyring([3, 4, 5])
        let option = try KeyStoreOption.getDefaultOptionWithKDF(KeyStore.ScryptKdfParams.NAME, keyring.address)
        
        XCTAssertThrowsError(try keyring.encryptV3(password, option)) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("Not supported for this class. Use 'encrypt()' function"))
        }
    }
    
    func testAbstractKeyring_single() throws {
        guard let keyring: AbstractKeyring = KeyringFactory.generate() else { XCTAssert(true); return }
        let option = try KeyStoreOption.getDefaultOptionWithKDF(KeyStore.ScryptKdfParams.NAME, keyring.address)
        
        guard let keyStore = try keyring.encryptV3(password, option) else { XCTAssert(true); return }
        
        try checkValidateKeyStore(keyStore, password, keyring, 3)
    }
    
    func testAbstractKeyring_single_noOption() throws {
        guard let keyring: AbstractKeyring = KeyringFactory.generate() else { XCTAssert(true); return }
        guard let keyStore = try keyring.encryptV3(password) else { XCTAssert(true); return }
        
        try checkValidateKeyStore(keyStore, password, keyring, 3)
    }
    
    func testThrowException_instanceMethod_multipleKey() throws {
        let keyring: AbstractKeyring = try generateMultipleKeyring(3)
        let option = try KeyStoreOption.getDefaultOptionWithKDF(KeyStore.ScryptKdfParams.NAME, keyring.address)
        
        XCTAssertThrowsError(try keyring.encryptV3(password, option)) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("Not supported for this class. Use 'encrypt()' function"))
        }
    }
    
    func testThrowException_instanceMethod_roleBasedKey() throws {
        let keyring: AbstractKeyring = try generateRoleBaseKeyring([3, 4, 5])
        let option = try KeyStoreOption.getDefaultOptionWithKDF(KeyStore.ScryptKdfParams.NAME, keyring.address)
        
        XCTAssertThrowsError(try keyring.encryptV3(password, option)) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("Not supported for this class. Use 'encrypt()' function"))
        }
    }
}

class getKeyByRoleTest: XCTestCase {
    func testGetKeyByRole() throws {
        let roleKeyring = try generateRoleBaseKeyring([2, 3, 4])
        let keys = try roleKeyring.getKeyByRole(AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue)
        
        XCTAssertEqual(2, keys.count)
    }
    
    func testGetKeyByRole_defaultKey() throws {
        let keyring = try generateMultipleKeyring(3)
        let keys = try keyring.getKeyByRole(AccountKeyRoleBased.RoleGroup.FEE_PAYER.rawValue)
        
        XCTAssertEqual(3, keys.count)
    }
    
    func testGetKeyByRole_throwException_defaultKeyEmpty() throws {
        let roleKeyring = try generateRoleBaseKeyring([0, 0, 3])
        
        XCTAssertThrowsError(try roleKeyring.getKeyByRole(AccountKeyRoleBased.RoleGroup.ACCOUNT_UPDATE.rawValue)) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("The Key with specified role group does not exists. The TRANSACTION role group is also empty"))
        }
    }
    
    func testGetKeyByRole_throwException_invalidIndex() throws {
        let roleKeyring = try generateMultipleKeyring(4)
        
        XCTAssertThrowsError(try roleKeyring.getKeyByRole(4)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid role index : \(4)"))
        }
    }
}

class getKlaytnWalletKeyTest: XCTestCase {
    func testGetKlaytnWalletKey_coupled() throws {
        guard let keyring = KeyringFactory.generate() else { XCTAssert(true); return }
        let expectedKeyStr = keyring.key.privateKey + "0x00" + keyring.address
        
        XCTAssertEqual(expectedKeyStr, keyring.getKlaytnWalletKey())
    }
    
    func testGetKlaytnWalletKey_decoupled() throws {
        let address = PrivateKey.generate().getDerivedAddress()
        let privateKey = PrivateKey.generate().privateKey
        let keyring = try KeyringFactory.create(address, privateKey)
        let expectedKeyStr = privateKey + "0x00" + address.addHexPrefix
        
        XCTAssertEqual(expectedKeyStr, keyring.getKlaytnWalletKey())
    }
    
    func testGetKlaytnWallet_throwException_multiKey() throws {
        let roleKeyring = try generateMultipleKeyring(3)
        
        XCTAssertThrowsError(try roleKeyring.getKlaytnWalletKey()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("Not supported for this class."))
        }
    }
    
    func testGetKlaytnWallet_thrownException_roleBased() throws {
        let roleKeyring = try generateRoleBaseKeyring([1, 3, 4])
        
        XCTAssertThrowsError(try roleKeyring.getKlaytnWalletKey()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("Not supported for this class."))
        }
    }
}

class getPublicKeyTest: XCTestCase {
    func testGetPublicKey_single() throws {
        guard let keyring = KeyringFactory.generate() else { XCTAssert(true); return }
        let publicKeys = try keyring.getPublicKey()
        
        XCTAssertEqual(try keyring.key.getPublicKey(false), publicKeys)
    }
    
    func testGetPublicKey_decoupled() throws {
        let address = PrivateKey.generate().getDerivedAddress()
        let privateKey = PrivateKey.generate().privateKey
        let keyring = try KeyringFactory.create(address, privateKey)
        let publicKeys = try keyring.getPublicKey()
        
        XCTAssertEqual(try keyring.key.getPublicKey(false), publicKeys)
    }
    
    func testGetPublicKey_multiple() throws {
        let keyring = try generateMultipleKeyring(2)
        let publicKeys = try keyring.getPublicKey()
        
        XCTAssertEqual(try keyring.keys[0].getPublicKey(false), publicKeys[0])
        XCTAssertEqual(try keyring.keys[1].getPublicKey(false), publicKeys[1])
        
        XCTAssertEqual(2, publicKeys.count)
    }
    
    func testGetPublicKey_roleBased() throws {
        let keyring = try generateRoleBaseKeyring([2, 3, 1])
        let publicKeys = try keyring.getPublicKey()
        
        XCTAssertEqual(try keyring.keys[0][0].getPublicKey(false), publicKeys[0][0])
        XCTAssertEqual(try keyring.keys[0][1].getPublicKey(false), publicKeys[0][1])
        
        XCTAssertEqual(try keyring.keys[1][0].getPublicKey(false), publicKeys[1][0])
        XCTAssertEqual(try keyring.keys[1][1].getPublicKey(false), publicKeys[1][1])
        XCTAssertEqual(try keyring.keys[1][2].getPublicKey(false), publicKeys[1][2])
        
        XCTAssertEqual(try keyring.keys[2][0].getPublicKey(false), publicKeys[2][0])
        
        XCTAssertEqual(2, publicKeys[0].count)
        XCTAssertEqual(3, publicKeys[1].count)
        XCTAssertEqual(1, publicKeys[2].count)
    }
    
    func testGetPublicKey_single_compressed() throws {
        guard let keyring = KeyringFactory.generate() else { XCTAssert(true); return }
        let publicKeys = try keyring.getPublicKey(true)
        
        XCTAssertEqual(try keyring.key.getPublicKey(true), publicKeys)
    }
    
    func testGetPublicKey_decoupled_compressed() throws {
        let address = PrivateKey.generate().getDerivedAddress()
        let privateKey = PrivateKey.generate().privateKey
        let keyring = try KeyringFactory.create(address, privateKey)
        let publicKeys = try keyring.getPublicKey(true)
        
        XCTAssertEqual(try keyring.key.getPublicKey(true), publicKeys)
    }
    
    func testGetPublicKey_multiple_compressed() throws {
        let keyring = try generateMultipleKeyring(2)
        let publicKeys = try keyring.getPublicKey(true)
        
        XCTAssertEqual(try keyring.keys[0].getPublicKey(true), publicKeys[0])
        XCTAssertEqual(try keyring.keys[1].getPublicKey(true), publicKeys[1])
        
        XCTAssertEqual(2, publicKeys.count)
    }
    
    func testGetPublicKey_roleBased_compressed() throws {
        let keyring = try generateRoleBaseKeyring([2, 3, 1])
        let publicKeys = try keyring.getPublicKey(true)
        
        XCTAssertEqual(try keyring.keys[0][0].getPublicKey(true), publicKeys[0][0])
        XCTAssertEqual(try keyring.keys[0][1].getPublicKey(true), publicKeys[0][1])
        
        XCTAssertEqual(try keyring.keys[1][0].getPublicKey(true), publicKeys[1][0])
        XCTAssertEqual(try keyring.keys[1][1].getPublicKey(true), publicKeys[1][1])
        XCTAssertEqual(try keyring.keys[1][2].getPublicKey(true), publicKeys[1][2])
        
        XCTAssertEqual(try keyring.keys[2][0].getPublicKey(true), publicKeys[2][0])
        
        XCTAssertEqual(2, publicKeys[0].count)
        XCTAssertEqual(3, publicKeys[1].count)
        XCTAssertEqual(1, publicKeys[2].count)
    }
}

class isDecoupledTest: XCTestCase {
    func testIsDecoupled_coupled() throws {
        guard let keyring = KeyringFactory.generate() else { XCTAssert(true); return }
                
        XCTAssertFalse(keyring.isDecoupled)
    }
    
    func testIsDecoupled_decoupled() throws {
        let address = PrivateKey.generate().getDerivedAddress()
        let privateKey = PrivateKey.generate().privateKey
        let keyring = try KeyringFactory.create(address, privateKey)
                
        XCTAssertTrue(keyring.isDecoupled)
    }
    
    func testIsDecoupled_multiKey() throws {
        let keyring = try generateMultipleKeyring(3)
        XCTAssertTrue(keyring.isDecoupled)
    }
    
    func testIsDecoupled_roleBased() throws {
        let keyring = try generateRoleBaseKeyring([2, 3, 1])
        XCTAssertTrue(keyring.isDecoupled)
    }
}

class toAccountTest: XCTestCase {
    func checkAccountKeyPublic(_ keyring: SingleKeyring, _ account: Account) throws {
        let expectedPublicKey = try keyring.getKeyByRole(AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue).getPublicKey()
        guard let accountKey = account.accountKey as? AccountKeyPublic else {
            XCTAssertThrowsError(true)
            return
        }
        XCTAssertEqual(keyring.address.addHexPrefix, account.address.addHexPrefix)
        XCTAssertEqual(expectedPublicKey, accountKey.publicKey)
    }
    
    func checkAccountKeyWeightedMultiSig(_ keyring: MultipleKeyring, _ account: Account, _ options: WeightedMultiSigOptions) throws {
        let expectedPublicKeys = try keyring.getPublicKey()
        guard let accountKey = account.accountKey as? AccountKeyWeightedMultiSig else {
            XCTAssertThrowsError(true)
            return
        }
        let actualKeys = accountKey.weightedPublicKeys
        
        XCTAssertEqual(keyring.address.addHexPrefix, account.address.addHexPrefix)
        XCTAssertEqual(options.threshold, accountKey.threshold)
        try checkPublicKey(expectedPublicKeys, actualKeys, options)
    }
    
    func checkPublicKey(_ expectedPublicKey: [String], _ actualKey: [WeightedPublicKey], _ options: WeightedMultiSigOptions) throws {
        zip(zip(expectedPublicKey, actualKey), options.weights).forEach {
            XCTAssertEqual($0.0, $0.1.publicKey)
            XCTAssertEqual($1, $0.1.weight)
        }
    }
    
    func testSingleKeyTest() throws {
        guard let keyring = KeyringFactory.generate() else { XCTAssert(true); return }
        let account = try keyring.toAccount()
        
        try checkAccountKeyPublic(keyring, account)
    }
    
    func testToAccount_withMultipleType() throws {
        let expectedKeyring = try generateMultipleKeyring(3)
        let optionWeight = [
            BigInt(1), BigInt(1), BigInt(1)
        ]
        let expectedOptions = try WeightedMultiSigOptions(BigInt(1), optionWeight)
        let account = try expectedKeyring.toAccount()
        
        try checkAccountKeyWeightedMultiSig(expectedKeyring, account, expectedOptions)
    }
    
    func testToAccount_withRoleBasedType() throws {
        let expectedKeyring = try generateRoleBaseKeyring([2, 1, 4])
        let optionWeight = [
            [BigInt(1), BigInt(1)],
            [],
            [BigInt(1), BigInt(1), BigInt(1), BigInt(1)]
        ]
        let expectedOption = [
            try WeightedMultiSigOptions(BigInt(1), optionWeight[0]),
            WeightedMultiSigOptions(),
            try WeightedMultiSigOptions(BigInt(1), optionWeight[2])
        ]
        let expectedPublicKeys = try expectedKeyring.getPublicKey()
        let account = try expectedKeyring.toAccount()
        
        guard let key = account.accountKey as? AccountKeyRoleBased,
              let txRoleKey = key.roleTransactionKey as? AccountKeyWeightedMultiSig,
              let accountRoleKey = key.roleAccountUpdateKey as? AccountKeyPublic,
              let feePayerKey = key.roleFeePayerKey as? AccountKeyWeightedMultiSig else {
            XCTAssertThrowsError(true)
            return
        }
        
        try checkPublicKey(expectedPublicKeys[0], txRoleKey.weightedPublicKeys, expectedOption[0])
        XCTAssertEqual(expectedPublicKeys[1][0], accountRoleKey.publicKey)
        try checkPublicKey(expectedPublicKeys[2], feePayerKey.weightedPublicKeys, expectedOption[2])
    }
    
    func testMultipleKeyTest() throws {
        let expectedKeyring = try generateMultipleKeyring(3)
        let optionWeight = [
            BigInt(1), BigInt(1), BigInt(2)
        ]
        let expectedOptions = try WeightedMultiSigOptions(BigInt(1), optionWeight)
        let account = try expectedKeyring.toAccount(expectedOptions)
        
        try checkAccountKeyWeightedMultiSig(expectedKeyring, account, expectedOptions)
    }
    
    func testMultipleKeyTest_throwException_noKey() throws {
        let expectedKeyring = try generateMultipleKeyring(0)
        let optionWeight = [
            BigInt(1), BigInt(1), BigInt(2)
        ]
        let expectedOptions = try WeightedMultiSigOptions(BigInt(1), optionWeight)
        
        XCTAssertThrowsError(try expectedKeyring.toAccount(expectedOptions)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("The count of public keys is not equal to the length of weight array."))
        }
    }
    
    func testMultipleKeyTest_throwException_weightedOptionCount() throws {
        let expectedKeyring = try generateMultipleKeyring(2)
        let optionWeight = [
            BigInt(1), BigInt(1), BigInt(2)
        ]
        let expectedOptions = try WeightedMultiSigOptions(BigInt(1), optionWeight)
        
        XCTAssertThrowsError(try expectedKeyring.toAccount(expectedOptions)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("The count of public keys is not equal to the length of weight array."))
        }
    }
    
    func testRoleBasedKeyTest_SingleKey() throws {
        let expectedKeyring = try generateRoleBaseKeyring([1, 1, 1])
        
        let expectedOption = [
            WeightedMultiSigOptions(),
            WeightedMultiSigOptions(),
            WeightedMultiSigOptions()
        ]
        let expectedPublicKeys = try expectedKeyring.getPublicKey()
        let account = try expectedKeyring.toAccount(expectedOption)
        
        guard let key = account.accountKey as? AccountKeyRoleBased,
              let txRoleKey = key.roleTransactionKey as? AccountKeyPublic,
              let accountRoleKey = key.roleAccountUpdateKey as? AccountKeyPublic,
              let feePayerKey = key.roleFeePayerKey as? AccountKeyPublic else {
            XCTAssertThrowsError(true)
            return
        }
        
        XCTAssertEqual(expectedPublicKeys[0][0], txRoleKey.publicKey)
        XCTAssertEqual(expectedPublicKeys[1][0], accountRoleKey.publicKey)
        XCTAssertEqual(expectedPublicKeys[2][0], feePayerKey.publicKey)
    }
    
    func testRoleBaseKeyTest_multipleKey() throws {
        let expectedKeyring = try generateRoleBaseKeyring([2, 3, 4])
        let optionWeight = [
            [BigInt(1), BigInt(1)],
            [BigInt(1), BigInt(1), BigInt(2)],
            [BigInt(1), BigInt(1), BigInt(2), BigInt(2)]
        ]
        let expectedOption = [
            try WeightedMultiSigOptions(BigInt(2), optionWeight[0]),
            try WeightedMultiSigOptions(BigInt(2), optionWeight[1]),
            try WeightedMultiSigOptions(BigInt(3), optionWeight[2])
        ]
        let expectedPublicKeys = try expectedKeyring.getPublicKey()
        let account = try expectedKeyring.toAccount(expectedOption)
        
        guard let key = account.accountKey as? AccountKeyRoleBased,
              let txRoleKey = key.roleTransactionKey as? AccountKeyWeightedMultiSig,
              let accountRoleKey = key.roleAccountUpdateKey as? AccountKeyWeightedMultiSig,
              let feePayerKey = key.roleFeePayerKey as? AccountKeyWeightedMultiSig else {
            XCTAssertThrowsError(true)
            return
        }
        
        try checkPublicKey(expectedPublicKeys[0], txRoleKey.weightedPublicKeys, expectedOption[0])
        try checkPublicKey(expectedPublicKeys[1], accountRoleKey.weightedPublicKeys, expectedOption[1])
        try checkPublicKey(expectedPublicKeys[2], feePayerKey.weightedPublicKeys, expectedOption[2])
    }
    
    func testRoleBasedKeyTest_combined() throws {
        let address = PrivateKey.generate().getDerivedAddress()
        let expectedPrivateKeyArr = [
            [PrivateKey.generate().privateKey,
             PrivateKey.generate().privateKey],
            [],
            [PrivateKey.generate().privateKey]
        ]
        
        let optionWeight = [
            [BigInt(1), BigInt(1)],
            [BigInt(1), BigInt(1), BigInt(2)],
            [BigInt(1), BigInt(1), BigInt(2), BigInt(2)]
        ]
        let expectedOption = [
            try WeightedMultiSigOptions(BigInt(2), optionWeight[0]),
            WeightedMultiSigOptions(),
            WeightedMultiSigOptions()
        ]
        let expectedKeyring = try KeyringFactory.createWithRoleBasedKey(address, expectedPrivateKeyArr)
        let expectedPublicKeys = try expectedKeyring.getPublicKey()
        let account = try expectedKeyring.toAccount(expectedOption)
        
        guard let key = account.accountKey as? AccountKeyRoleBased,
              let txRoleKey = key.roleTransactionKey as? AccountKeyWeightedMultiSig,
              let _ = key.roleAccountUpdateKey as? AccountKeyNil,
              let feePayerKey = key.roleFeePayerKey as? AccountKeyPublic else {
            XCTAssertThrowsError(true)
            return
        }
        
        try checkPublicKey(expectedPublicKeys[0], txRoleKey.weightedPublicKeys, expectedOption[0])
        XCTAssertEqual(expectedPublicKeys[2][0], feePayerKey.publicKey)
    }
}
