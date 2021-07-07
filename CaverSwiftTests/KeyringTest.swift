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
        guard let keyring = KeyringFactory.generate() else { return }
        let expectedAddress = keyring.address
        let expectedPrivateKey = keyring.key.privateKey
        
        let actualKeyring = try KeyringFactory.createFromPrivateKey(expectedPrivateKey)
        try checkValidateSingleKey(actualKeyring, expectedAddress, expectedPrivateKey)
    }
    
    func testCreateFromPrivateKeyWithoutHexPrefix() throws {
        guard let keyring = KeyringFactory.generate() else { return }
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
        guard let keyring = KeyringFactory.generate() else {return}
        let klaytnWalletKey = keyring.getKlaytnWalletKey()
        
        XCTAssertThrowsError(try KeyringFactory.createWithSingleKey(keyring.address, klaytnWalletKey)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid format of parameter. Use 'fromKlaytnWalletKey' to create Keyring from KlaytnWalletKey."))
        }
    }
}

class createWithMultipleKeyTest: XCTestCase {
    func testCreateWithMultipleKey() throws {
        guard let expectedAddress = KeyringFactory.generate()?.address else {return}
        let expectedPrivateKeyArr = [
            PrivateKey.generate().privateKey,
            PrivateKey.generate().privateKey,
            PrivateKey.generate().privateKey]
        
        let actualKeyring = try KeyringFactory.createWithMultipleKey(expectedAddress, expectedPrivateKeyArr)
        try checkValidateMultipleKey(actualKeyring, expectedAddress, expectedPrivateKeyArr)
    }
    
    func testCreateWithMultipleKey_throwException_invalidKey() throws {
        guard let expectedAddress = KeyringFactory.generate()?.address else {return}
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
        guard let expectedAddress = KeyringFactory.generate()?.address else {return}
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
        guard let expectedKeyring = KeyringFactory.generate() else {return}
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
        guard let expectedAddress = KeyringFactory.generate()?.address else {return}
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
              let signatureData = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue, 0) else {return}
        
        XCTAssertFalse(signatureData.r.isEmpty)
        XCTAssertFalse(signatureData.s.isEmpty)
        XCTAssertFalse(signatureData.v.isEmpty)
    }
    
    func testCoupledKey_with_NotExistedRole() throws {
        guard let keyring = KeyringFactory.generate(),
              let expectedSignatureData = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue, 0),
              let signatureData = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.ACCOUNT_UPDATE.rawValue, 0) else {return}
        
        XCTAssertFalse(signatureData.r.isEmpty)
        XCTAssertFalse(signatureData.s.isEmpty)
        XCTAssertFalse(signatureData.v.isEmpty)
        
        XCTAssertEqual(expectedSignatureData.r, signatureData.r)
        XCTAssertEqual(expectedSignatureData.s, signatureData.s)
        XCTAssertEqual(expectedSignatureData.v, signatureData.v)
    }
    
    func testCoupleKey_throwException_negativeKeyIndex() throws {
        guard let keyring = KeyringFactory.generate() else {return}
        
        XCTAssertThrowsError(try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue, -1)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid index : index cannot be negative"))
        }
    }
    
    func testCoupleKey_throwException_outOfBoundKeyIndex() throws {
        guard let keyring = KeyringFactory.generate() else {return}
        
        XCTAssertThrowsError(try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue, 1)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid index : index must be less than the length of the key."))
        }
    }
    
    func testDeCoupleKey() throws {
        let address = PrivateKey.generate().getDerivedAddress()
        let privateKey = PrivateKey.generate().privateKey
        let keyring = try KeyringFactory.create(address, privateKey)
        guard let signatureData = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue, 0) else {return}
        
        XCTAssertFalse(signatureData.r.isEmpty)
        XCTAssertFalse(signatureData.s.isEmpty)
        XCTAssertFalse(signatureData.v.isEmpty)
    }
    
    func testDeCoupleKey_With_NotExistedRole() throws {
        let address = PrivateKey.generate().getDerivedAddress()
        let privateKey = PrivateKey.generate().privateKey
        let keyring = try KeyringFactory.create(address, privateKey)
        guard let expectedSignatureData = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue, 0),
              let signatureData = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.ACCOUNT_UPDATE.rawValue, 0) else {return}
        
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
        guard let signatureData = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue, 1) else {return}
        
        XCTAssertFalse(signatureData.r.isEmpty)
        XCTAssertFalse(signatureData.s.isEmpty)
        XCTAssertFalse(signatureData.v.isEmpty)
    }
    
    func testMultipleKey_With_NotExistedRole() throws {
        let keyring = try generateMultipleKeyring(3)
        guard let expectedSignatureData = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue, 0),
              let signatureData = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.ACCOUNT_UPDATE.rawValue, 0) else {return}
        
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
        guard let signatureData = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue, 1) else {return}
        
        XCTAssertFalse(signatureData.r.isEmpty)
        XCTAssertFalse(signatureData.s.isEmpty)
        XCTAssertFalse(signatureData.v.isEmpty)
    }
    
    func testRoleBasedKey_With_NotExistedRole() throws {
        let keyring = try generateRoleBaseKeyring([2, 0, 4])
        guard let expectedSignatureData = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue, 0),
              let signatureData = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.ACCOUNT_UPDATE.rawValue, 0) else {return}
        
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
              let signatureDataList = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue) else {return}
        
        XCTAssertEqual(1, signatureDataList.count)
        XCTAssertFalse(signatureDataList[0].r.isEmpty)
        XCTAssertFalse(signatureDataList[0].s.isEmpty)
        XCTAssertFalse(signatureDataList[0].v.isEmpty)
    }
    
    func testCoupleKey_with_NotExistedRole() throws {
        guard let keyring = KeyringFactory.generate(),
              let expectedList = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue),
              let actualList = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.ACCOUNT_UPDATE.rawValue) else {return}
        
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
        guard let actualList = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue) else {return}
        
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
              let actualList = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.ACCOUNT_UPDATE.rawValue) else {return}
        
        XCTAssertEqual(1, actualList.count)
        try checkSignature(expectedList, actualList)
    }
    
    func testMultipleKey() throws {
        let keyring = try generateMultipleKeyring(3)
        guard let actualList = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue) else {return}
        
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
              let actualList = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.ACCOUNT_UPDATE.rawValue) else {return}
        
        XCTAssertEqual(3, actualList.count)
        try checkSignature(expectedList, actualList)
    }
    
    func testRoleBasedKey() throws {
        let keyring = try generateRoleBaseKeyring([3, 3, 4])
        guard let actualList = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue) else {return}
        
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
              let actualList = try keyring.sign(HASH, CHAIN_ID, AccountKeyRoleBased.RoleGroup.ACCOUNT_UPDATE.rawValue) else {return}
        
        XCTAssertEqual(3, actualList.count)
        try checkSignature(expectedList, actualList)
    }
}

class signMessageTest: XCTestCase {
    let data = "some data"
            
    func testCoupledKey_NoIndex() throws {
        guard let keyring = KeyringFactory.generate(),
              let expect = try? keyring.signMessage(data, 0, 0),
              let actual = try? keyring.signMessage(data, 0) else {return}
        
        XCTAssertEqual(expect.message, actual.message)
        XCTAssertEqual(expect.messageHash, actual.messageHash)
        
        XCTAssertEqual(expect.signatures[0].r, actual.signatures[0].r)
        XCTAssertEqual(expect.signatures[0].s, actual.signatures[0].s)
        XCTAssertEqual(expect.signatures[0].v, actual.signatures[0].v)
    }
    
    func testCoupleKey_WithIndex() throws {
        guard let keyring = KeyringFactory.generate(),
              let actual = try? keyring.signMessage(data, 0, 0) else {return}
        
        XCTAssertEqual(Utils.hashMessage(data), actual.messageHash)
        XCTAssertFalse(actual.signatures[0].r.isEmpty)
        XCTAssertFalse(actual.signatures[0].s.isEmpty)
        XCTAssertFalse(actual.signatures[0].v.isEmpty)
    }
    
    func testCoupleKey_NotExistedRoleIndex() throws {
        guard let keyring = KeyringFactory.generate(),
              let expect = try? keyring.signMessage(data, 0, 0),
              let actual = try? keyring.signMessage(data, AccountKeyRoleBased.RoleGroup.FEE_PAYER.rawValue, 0) else {return}
        
        XCTAssertEqual(expect.message, actual.message)
        XCTAssertEqual(expect.messageHash, actual.messageHash)
        
        XCTAssertEqual(expect.signatures[0].r, actual.signatures[0].r)
        XCTAssertEqual(expect.signatures[0].s, actual.signatures[0].s)
        XCTAssertEqual(expect.signatures[0].v, actual.signatures[0].v)
    }
    
    func testRoleBasedKey_throwException_outOfBoundKeyIndex() throws {
        guard let keyring = KeyringFactory.generate() else {return}
        
        XCTAssertThrowsError(try keyring.signMessage(data, 0, 3)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid index : index must be less than the length of the key."))
        }
    }
    
    func testCoupleKey_throwException_WithNegativeKeyIndex() throws {
        guard let keyring = KeyringFactory.generate() else {return}
        
        XCTAssertThrowsError(try keyring.signMessage(data, 0, -1)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid index : index cannot be negative"))
        }
    }
    
    func testDecoupledKey_NoIndex() throws {
        let address = PrivateKey.generate().getDerivedAddress()
        let privateKey = PrivateKey.generate().privateKey
        let decoupled = try KeyringFactory.create(address, privateKey)
        guard let expect = try? decoupled.signMessage(data, 0, 0),
              let actual = try? decoupled.signMessage(data, 0) else {return}
        
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
        guard let actual = try? decoupled.signMessage(data, 0, 0) else {return}
        
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
              let actual = try? decoupled.signMessage(data, AccountKeyRoleBased.RoleGroup.FEE_PAYER.rawValue, 0) else {return}
        
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
              let actual = try? keyring.signMessage(data, 0) else {return}
        
        XCTAssertEqual(expect.message, actual.message)
        XCTAssertEqual(expect.messageHash, actual.messageHash)
        
        XCTAssertEqual(expect.signatures[0].r, actual.signatures[0].r)
        XCTAssertEqual(expect.signatures[0].s, actual.signatures[0].s)
        XCTAssertEqual(expect.signatures[0].v, actual.signatures[0].v)
    }
    
    func testMultipleKey_WithIndex() throws {
        let keyring = try generateMultipleKeyring(3)
        guard let actual = try? keyring.signMessage(data, 0, 0) else {return}
        
        XCTAssertEqual(Utils.hashMessage(data), actual.messageHash)
        XCTAssertFalse(actual.signatures[0].r.isEmpty)
        XCTAssertFalse(actual.signatures[0].s.isEmpty)
        XCTAssertFalse(actual.signatures[0].v.isEmpty)
    }
    
    func testMultipleKey_NotExistedRoleIndex() throws {
        let keyring = try generateMultipleKeyring(3)
        guard let expect = try? keyring.signMessage(data, 0, 2),
              let actual = try? keyring.signMessage(data, AccountKeyRoleBased.RoleGroup.FEE_PAYER.rawValue, 2) else {return}
        
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
        guard let actual = try? keyring.signMessage(data, 0, 0) else {return}
        
        XCTAssertEqual(Utils.hashMessage(data), actual.messageHash)
        XCTAssertFalse(actual.signatures[0].r.isEmpty)
        XCTAssertFalse(actual.signatures[0].s.isEmpty)
        XCTAssertFalse(actual.signatures[0].v.isEmpty)
    }
    
    func testRoleBasedKey_NotExistedRoleKey() throws {
        let keyring = try generateRoleBaseKeyring([3, 0, 5])
        guard let expect = try? keyring.signMessage(data, 0, 2),
              let actual = try? keyring.signMessage(data, AccountKeyRoleBased.RoleGroup.ACCOUNT_UPDATE.rawValue, 2) else {return}
        
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
              let signed = try keyring.signMessage(data, 0, 0) else {return}
        
        let actualAddr = try Utils.recover(signed.message, signed.signatures[0])
        
        try checkAddress(keyring.address, actualAddr)
    }
    
    func testAlreadyPrefix() throws {
        guard let keyring = KeyringFactory.generate(),
              let signed = try keyring.signMessage(data, 0, 0) else {return}
        
        let actualAddr = try Utils.recover(signed.messageHash, signed.signatures[0], true)
        
        try checkAddress(keyring.address, actualAddr)
    }
}
class decryptTest: XCTestCase {
    let jsonV3 = "{\n" +
        "  \"version\":3,\n" +
        "  \"id\":\"7a0a8557-22a5-4c90-b554-d6f3b13783ea\",\n" +
        "  \"address\":\"0x86bce8c859f5f304aa30adb89f2f7b6ee5a0d6e2\",\n" +
        "  \"crypto\":{\n" +
        "    \"ciphertext\":\"696d0e8e8bd21ff1f82f7c87b6964f0f17f8bfbd52141069b59f084555f277b7\",\n" +
        "    \"cipherparams\":{\"iv\":\"1fd13e0524fa1095c5f80627f1d24cbd\"},\n" +
        "    \"cipher\":\"aes-128-ctr\",\n" +
        "    \"kdf\":\"scrypt\",\n" +
        "    \"kdfparams\":{\n" +
        "      \"dklen\":32,\n" +
        "      \"salt\":\"7ee980925cef6a60553cda3e91cb8e3c62733f64579f633d0f86ce050c151e26\",\n" +
        "      \"n\":4096,\n" +
        "      \"r\":8,\n" +
        "      \"p\":1\n" +
        "    },\n" +
        "    \"mac\":\"8684d8dc4bf17318cd46c85dbd9a9ec5d9b290e04d78d4f6b5be9c413ff30ea4\"\n" +
        "  }\n" +
        "}"
                    
    let jsonV4 = "{\n" +
        "  \"version\":4,\n" +
        "  \"id\":\"55da3f9c-6444-4fc1-abfa-f2eabfc57501\",\n" +
        "  \"address\":\"0x86bce8c859f5f304aa30adb89f2f7b6ee5a0d6e2\",\n" +
        "  \"keyring\":[\n" +
        "    [\n" +
        "      {\n" +
        "        \"ciphertext\":\"93dd2c777abd9b80a0be8e1eb9739cbf27c127621a5d3f81e7779e47d3bb22f6\",\n" +
        "        \"cipherparams\":{\"iv\":\"84f90907f3f54f53d19cbd6ae1496b86\"},\n" +
        "        \"cipher\":\"aes-128-ctr\",\n" +
        "        \"kdf\":\"scrypt\",\n" +
        "        \"kdfparams\":{\n" +
        "          \"dklen\":32,\n" +
        "          \"salt\":\"69bf176a136c67a39d131912fb1e0ada4be0ed9f882448e1557b5c4233006e10\",\n" +
        "          \"n\":4096,\n" +
        "          \"r\":8,\n" +
        "          \"p\":1\n" +
        "        },\n" +
        "        \"mac\":\"8f6d1d234f4a87162cf3de0c7fb1d4a8421cd8f5a97b86b1a8e576ffc1eb52d2\"\n" +
        "      },\n" +
        "      {\n" +
        "        \"ciphertext\":\"53d50b4e86b550b26919d9b8cea762cd3c637dfe4f2a0f18995d3401ead839a6\",\n" +
        "        \"cipherparams\":{\"iv\":\"d7a6f63558996a9f99e7daabd289aa2c\"},\n" +
        "        \"cipher\":\"aes-128-ctr\",\n" +
        "        \"kdf\":\"scrypt\",\n" +
        "        \"kdfparams\":{\n" +
        "          \"dklen\":32,\n" +
        "          \"salt\":\"966116898d90c3e53ea09e4850a71e16df9533c1f9e1b2e1a9edec781e1ad44f\",\n" +
        "          \"n\":4096,\n" +
        "          \"r\":8,\n" +
        "          \"p\":1\n" +
        "        },\n" +
        "        \"mac\":\"bca7125e17565c672a110ace9a25755847d42b81aa7df4bb8f5ce01ef7213295\"\n" +
        "      }\n" +
        "    ],\n" +
        "    [\n" +
        "      {\n" +
        "        \"ciphertext\":\"f16def98a70bb2dae053f791882f3254c66d63416633b8d91c2848893e7876ce\",\n" +
        "        \"cipherparams\":{\"iv\":\"f5006128a4c53bc02cada64d095c15cf\"},\n" +
        "        \"cipher\":\"aes-128-ctr\",\n" +
        "        \"kdf\":\"scrypt\",\n" +
        "        \"kdfparams\":{\n" +
        "          \"dklen\":32,\n" +
        "          \"salt\":\"0d8a2f71f79c4880e43ff0795f6841a24cb18838b3ca8ecaeb0cda72da9a72ce\",\n" +
        "          \"n\":4096,\n" +
        "          \"r\":8,\n" +
        "          \"p\":1\n" +
        "        },\n" +
        "        \"mac\":\"38b79276c3805b9d2ff5fbabf1b9d4ead295151b95401c1e54aed782502fc90a\"\n" +
        "      }\n" +
        "    ],\n" +
        "    [\n" +
        "      {\n" +
        "        \"ciphertext\":\"544dbcc327942a6a52ad6a7d537e4459506afc700a6da4e8edebd62fb3dd55ee\",\n" +
        "        \"cipherparams\":{\"iv\":\"05dd5d25ad6426e026818b6fa9b25818\"},\n" +
        "        \"cipher\":\"aes-128-ctr\",\n" +
        "        \"kdf\":\"scrypt\",\n" +
        "        \"kdfparams\":{\n" +
        "          \"dklen\":32,\n" +
        "          \"salt\":\"3a9003c1527f65c772c54c6056a38b0048c2e2d58dc0e584a1d867f2039a25aa\",\n" +
        "          \"n\":4096,\n" +
        "          \"r\":8,\n" +
        "          \"p\":1\n" +
        "        },\n" +
        "        \"mac\":\"19a698b51409cc9ac22d63d329b1201af3c89a04a1faea3111eec4ca97f2e00f\"\n" +
        "      },\n" +
        "      {\n" +
        "        \"ciphertext\":\"dd6b920f02cbcf5998ed205f8867ddbd9b6b088add8dfe1774a9fda29ff3920b\",\n" +
        "        \"cipherparams\":{\"iv\":\"ac04c0f4559dad80dc86c975d1ef7067\"},\n" +
        "        \"cipher\":\"aes-128-ctr\",\n" +
        "        \"kdf\":\"scrypt\",\n" +
        "        \"kdfparams\":{\n" +
        "          \"dklen\":32,\n" +
        "          \"salt\":\"22279c6dbcc706d7daa120022a236cfe149496dca8232b0f8159d1df999569d6\",\n" +
        "          \"n\":4096,\n" +
        "          \"r\":8,\n" +
        "          \"p\":1\n" +
        "        },\n" +
        "        \"mac\":\"1c54f7378fa279a49a2f790a0adb683defad8535a21bdf2f3dadc48a7bddf517\"\n" +
        "      }\n" +
        "    ]\n" +
        "  ]\n" +
        "}"
    
    let password = "password"
    
    func testWithMessageAndSignature() throws {
        let privateKey = PrivateKey.generate().privateKey
        let expect = try KeyringFactory.createFromPrivateKey(privateKey)
        
        
    }
}
