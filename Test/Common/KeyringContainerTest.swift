//
//  KeyringContainerTest.swift
//  CaverSwiftTests
//
//  Created by won on 2021/07/09.
//

import XCTest
@testable import CaverSwift

class KeyringContainerTest: XCTestCase {
    static func validateSingleKeyring(_ actual: AbstractKeyring,_ expectedAddress: String, _ expectKey: String) throws {
        guard let actual = actual as? SingleKeyring else {
            XCTAssert(false)
            return
        }
        XCTAssertEqual(expectedAddress, actual.address)
        XCTAssertEqual(expectKey, actual.key.privateKey)
    }

    static func validateMultipleKeyring(_ actual: AbstractKeyring,_ expectedAddress: String, _ expectKeyArr: [String]) throws {
        guard let actual = actual as? MultipleKeyring else {
            XCTAssert(false)
            return
        }
        XCTAssertEqual(expectedAddress, actual.address)
        
        zip(expectKeyArr, actual.keys).forEach {
            XCTAssertEqual($0, $1.privateKey)
        }
    }

    static func validateRoleBasedKeyring(_ actual: AbstractKeyring,_ expectedAddress: String, _ expectKeyArr: [[String]]) throws {
        guard let actual = actual as? RoleBasedKeyring else {
            XCTAssert(false)
            return
        }
        XCTAssertEqual(expectedAddress, actual.address)
        
        zip(expectKeyArr, actual.keys).forEach {
            XCTAssertEqual($0.count, $1.count)
            zip($0, $1).forEach {
                XCTAssertEqual($0, $1.privateKey)
            }
        }
    }
    
    static func generateValueTransfer(_ keyring: AbstractKeyring) throws -> ValueTransfer {
        return try ValueTransfer.Builder()
                .setFrom(keyring.address)
                .setTo(keyring.address)
                .setValue("0x1")
                .setChainId("0x7e3")
                .setNonce("0x0")
                .setGas("0x15f90")
                .setGasPrice("0x5d21dba00")
                .build()
    }

    static func generateFeeDelegatedValueTransfer(_ keyring: AbstractKeyring) throws -> FeeDelegatedValueTransfer {
        return try FeeDelegatedValueTransfer.Builder()
                .setFrom(keyring.address)
                .setTo(keyring.address)
                .setValue("0x1")
                .setChainId("0x7e3")
                .setNonce("0x0")
                .setGas("0x15f90")
                .setGasPrice("0x5d21dba00")
                .build()
    }

    static func generateAccountUpdate(_ keyring: RoleBasedKeyring) throws -> AccountUpdate{
        return try AccountUpdate.Builder()
                .setFrom(keyring.address)
                .setAccount(keyring.toAccount())
                .setChainId("0x7E3")
                .setNonce("0x0")
                .setGas("0x15f90")
                .setGasPrice("0x5d21dba00")
                .build()
    }
}

class KeyringContainerTest_generateTest: XCTestCase {
    func checkAddress(_ expectedAddress: [String],_ container: KeyringContainer) throws {
        try expectedAddress.forEach {
            let keyring = try container.getKeyring($0)
            XCTAssertNotNil(keyring)
            XCTAssertEqual($0, keyring?.address)
        }
    }
    
    func test_validKeyringCountNoEntropy() throws {
        let container = KeyringContainer()
        let expectAddressList = try container.generate(10)
        try checkAddress(expectAddressList, container)
    }
    
    func test_validKeyringCountWithEntropy() throws {
        let container = KeyringContainer()
        let expectAddressList = try container.generate(10, "entropy")
        try checkAddress(expectAddressList, container)
    }
}

class KeyringContainerTest_newKeyringTest: XCTestCase {
    func test_newSingleKeyring() throws {
        let container = KeyringContainer()
        let privateKey = PrivateKey.generate()
        let expectAddress = privateKey.getDerivedAddress()
        let expectPrivateKey = privateKey.privateKey
        
        let added = try container.newKeyring(expectAddress, expectPrivateKey)
        try KeyringContainerTest.validateSingleKeyring(added, expectAddress, expectPrivateKey)
        XCTAssertEqual(1, container.count)
    }
    
    func test_newMultipleKeyring() throws {
        let container = KeyringContainer()
        let expectAddress = PrivateKey.generate().getDerivedAddress()
        let expectPrivateKeyArr = [
            PrivateKey.generate().privateKey,
            PrivateKey.generate().privateKey,
            PrivateKey.generate().privateKey
        ]
        
        let added = try container.newKeyring(expectAddress, expectPrivateKeyArr)
        try KeyringContainerTest.validateMultipleKeyring(added, expectAddress, expectPrivateKeyArr)
    }
    
    func test_newRoleBasedKeyring() throws {
        let container = KeyringContainer()
        let expectAddress = PrivateKey.generate().getDerivedAddress()
        let expectPrivateKeyArr = [
            [
                PrivateKey.generate().privateKey,
                PrivateKey.generate().privateKey,
                PrivateKey.generate().privateKey
            ],
            [
                PrivateKey.generate().privateKey,
                PrivateKey.generate().privateKey
            ],
            [
                PrivateKey.generate().privateKey,
                PrivateKey.generate().privateKey
            ]
        ]
        
        let added = try container.newKeyring(expectAddress, expectPrivateKeyArr)
        try KeyringContainerTest.validateRoleBasedKeyring(added, expectAddress, expectPrivateKeyArr)
    }
    
    func test_newRoleBasedKeyringWithEmptyRole() throws {
        let container = KeyringContainer()
        let expectAddress = PrivateKey.generate().getDerivedAddress()
        let expectPrivateKeyArr = [
            [
            ],
            [
            ],
            [
                PrivateKey.generate().privateKey,
                PrivateKey.generate().privateKey
            ]
        ]
        
        let added = try container.newKeyring(expectAddress, expectPrivateKeyArr)
        try KeyringContainerTest.validateRoleBasedKeyring(added, expectAddress, expectPrivateKeyArr)
    }
}

class KeyringContainerTest_updateKeyringTest: XCTestCase {
    func test_updateToCoupledKeyring() throws {
        let container = KeyringContainer()
        guard let coupled = KeyringFactory.generate()
        else {
            XCTAssert(false)
            return
        }

        let address = coupled.address
        let privateKey = PrivateKey.generate().privateKey

        let decoupled = try KeyringFactory.createWithSingleKey(coupled.address, privateKey)

        _ = try container.add(decoupled)

        let updated = try container.updateKeyring(coupled)
        let fromContainer = try container.getKeyring(address)!

        try KeyringContainerTest.validateSingleKeyring(updated, address, coupled.key.privateKey)
        try KeyringContainerTest.validateSingleKeyring(fromContainer, coupled.address, coupled.key.privateKey)
    }
    
    func test_updateToDecoupledKeyring() throws {
        let container = KeyringContainer()
        guard let coupled = KeyringFactory.generate()
        else {
            XCTAssert(false)
            return
        }

        let decoupled = try KeyringFactory.createWithSingleKey(coupled.address, PrivateKey.generate().privateKey)

        _ = try container.add(coupled)

        let updated = try container.updateKeyring(decoupled)
        let fromContainer = try container.getKeyring(coupled.address)!

        try KeyringContainerTest.validateSingleKeyring(updated, coupled.address, decoupled.key.privateKey)
        try KeyringContainerTest.validateSingleKeyring(fromContainer, coupled.address, decoupled.key.privateKey)
    }
    
    func test_updateToMultipleKeyring() throws {
        let container = KeyringContainer()
        guard let origin = KeyringFactory.generate()
        else {
            XCTAssert(false)
            return
        }

        let expectPrivateKeyArr = [
            PrivateKey.generate().privateKey,
            PrivateKey.generate().privateKey,
            PrivateKey.generate().privateKey
        ]

        let multipleKeyring = try KeyringFactory.createWithMultipleKey(origin.address, expectPrivateKeyArr)

        _ = try container.add(origin)

        let updated = try container.updateKeyring(multipleKeyring)
        let fromContainer = try container.getKeyring(origin.address)!

        try KeyringContainerTest.validateMultipleKeyring(updated, origin.address, expectPrivateKeyArr)
        try KeyringContainerTest.validateMultipleKeyring(fromContainer, origin.address, expectPrivateKeyArr)
    }
    
    func test_updateToRoleBasedKeyring() throws {
        let container = KeyringContainer()
        guard let origin = KeyringFactory.generate()
        else {
            XCTAssert(false)
            return
        }

        let expectPrivateKeyArr = [
            [
                PrivateKey.generate().privateKey,
                PrivateKey.generate().privateKey,
                PrivateKey.generate().privateKey
            ],
            [
                PrivateKey.generate().privateKey,
                PrivateKey.generate().privateKey
            ],
            [
                PrivateKey.generate().privateKey,
                PrivateKey.generate().privateKey
            ]
        ]

        let multipleKeyring = try KeyringFactory.createWithRoleBasedKey(origin.address, expectPrivateKeyArr)

        _ = try container.add(origin)

        let updated = try container.updateKeyring(multipleKeyring)
        let fromContainer = try container.getKeyring(origin.address)!

        try KeyringContainerTest.validateRoleBasedKeyring(updated, origin.address, expectPrivateKeyArr)
        try KeyringContainerTest.validateRoleBasedKeyring(fromContainer, origin.address, expectPrivateKeyArr)
    }
    
    func test_throwException_NotExistedKeyring() throws {
        let container = KeyringContainer()
        guard let keyring = KeyringFactory.generate()
        else {
            XCTAssert(false)
            return
        }
        
        XCTAssertThrowsError(try container.updateKeyring(keyring)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Failed to find keyring to update."))
        }
    }
}

class KeyringContainerTest_getKeyringTest: XCTestCase {
    func test_withValidAddress() throws {
        let container = KeyringContainer()
        guard let key = KeyringFactory.generate(),
              let added = try container.add(key) as? SingleKeyring,
              let keyring = try container.getKeyring(added.address)
        else {
            XCTAssert(false)
            return
        }

        try KeyringContainerTest.validateSingleKeyring(keyring, added.address, added.key.privateKey)
    }
    
    func test_notExistsAddress() throws {
        let container = KeyringContainer()
        guard let keyring = KeyringFactory.generate()
        else {
            XCTAssert(false)
            return
        }

        let actual = try container.getKeyring(keyring.address)
        XCTAssertNil(actual)
    }
    
    func test_throwException_InvalidAddress() throws {
        let container = KeyringContainer()
        let invalidAddress = "invalid"
        
        XCTAssertThrowsError(try container.getKeyring(invalidAddress)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. To get keyring from wallet, you need to pass a valid address string as a parameter."))
        }
    }
    
    func test_upperCaseAddress() throws {
        let address = "0x37223E5E41186A782E4A1F709829F521F43B18E5"
        let container = KeyringContainer()
        guard let keyring = try? KeyringFactory.create(address, PrivateKey.generate().privateKey)
        else {
            XCTAssert(false)
            return
        }
        
        _ = try container.add(keyring)
        XCTAssertNotNil(try container.getKeyring(address))
        XCTAssertEqual(address, try container.getKeyring(address)?.address)
    }
}

class KeyringContainerTest_addTest: XCTestCase {
    func test_singleKeyring() throws {
        let container = KeyringContainer()
        guard let keyringToAdd = KeyringFactory.generate(),
              let added = try container.add(keyringToAdd) as? SingleKeyring,
              let fromContainer = try container.getKeyring(added.address)
        else {
            XCTAssert(false)
            return
        }
        
        try KeyringContainerTest.validateSingleKeyring(added, keyringToAdd.address, keyringToAdd.key.privateKey)
        try KeyringContainerTest.validateSingleKeyring(fromContainer, keyringToAdd.address, keyringToAdd.key.privateKey)
    }
    
    func test_deCoupledKeyring() throws {
        let container = KeyringContainer()
        guard let deCoupled = try? KeyringFactory.createWithSingleKey(PrivateKey.generate().getDerivedAddress(), PrivateKey.generate().privateKey),
              let added = try container.add(deCoupled) as? SingleKeyring,
              let fromContainer = try container.getKeyring(deCoupled.address)
        else {
            XCTAssert(false)
            return
        }
        
        try KeyringContainerTest.validateSingleKeyring(added, deCoupled.address, deCoupled.key.privateKey)
        try KeyringContainerTest.validateSingleKeyring(fromContainer, deCoupled.address, deCoupled.key.privateKey)
    }
    
    func test_multipleKeyring() throws {
        let container = KeyringContainer()
        let address = PrivateKey.generate().getDerivedAddress()
        let expectPrivateKeyArr = [
            PrivateKey.generate().privateKey,
            PrivateKey.generate().privateKey,
            PrivateKey.generate().privateKey
        ]
        let multipleKeyring = try KeyringFactory.createWithMultipleKey(address, expectPrivateKeyArr)
        guard let added = try? container.add(multipleKeyring),
              let fromContainer = try container.getKeyring(added.address)
        else {
            XCTAssert(false)
            return
        }
        
        try KeyringContainerTest.validateMultipleKeyring(added, address, expectPrivateKeyArr)
        try KeyringContainerTest.validateMultipleKeyring(fromContainer, address, expectPrivateKeyArr)
    }
    
    func test_roleBasedKeyring() throws {
        let container = KeyringContainer()
        let address = PrivateKey.generate().getDerivedAddress()
        let expectPrivateKeyArr = [
            [
                PrivateKey.generate().privateKey,
                PrivateKey.generate().privateKey,
                PrivateKey.generate().privateKey
            ],
            [
                PrivateKey.generate().privateKey,
                PrivateKey.generate().privateKey
            ],
            [
                PrivateKey.generate().privateKey,
                PrivateKey.generate().privateKey
            ]
        ]
        let roleBasedKeyring = try KeyringFactory.createWithRoleBasedKey(address, expectPrivateKeyArr)
        guard let added = try? container.add(roleBasedKeyring),
              let fromContainer = try container.getKeyring(added.address)
        else {
            XCTAssert(false)
            return
        }
        
        try KeyringContainerTest.validateRoleBasedKeyring(added, address, expectPrivateKeyArr)
        try KeyringContainerTest.validateRoleBasedKeyring(fromContainer, address, expectPrivateKeyArr)
    }
}

class KeyringContainerTest_removeTest: XCTestCase {
    func test_coupledKey() throws {
        let container = KeyringContainer()
        guard let keyringToAdd = KeyringFactory.generate(),
              let added = try container.add(keyringToAdd) as? SingleKeyring,
              let result = try? container.remove(added.address)
        else {
            XCTAssert(false)
            return
        }
        
        XCTAssertTrue(result)
        XCTAssertEqual(0, container.count)
        XCTAssertNil(try container.getKeyring(keyringToAdd.address))
    }
    
    func test_deCoupledKey() throws {
        let container = KeyringContainer()
        guard let deCoupled = try? KeyringFactory.createWithSingleKey(PrivateKey.generate().getDerivedAddress(), PrivateKey.generate().privateKey),
              let added = try container.add(deCoupled) as? SingleKeyring,
              let result = try? container.remove(added.address)
        else {
            XCTAssert(false)
            return
        }
        
        XCTAssertTrue(result)
        XCTAssertEqual(0, container.count)
        XCTAssertNil(try container.getKeyring(deCoupled.address))
    }
    
    func test_multipleKey() throws {
        let container = KeyringContainer()
        let address = PrivateKey.generate().getDerivedAddress()
        let expectPrivateKeyArr = [
            PrivateKey.generate().privateKey,
            PrivateKey.generate().privateKey,
            PrivateKey.generate().privateKey
        ]
        let multipleKeyring = try KeyringFactory.createWithMultipleKey(address, expectPrivateKeyArr)
        guard let added = try? container.add(multipleKeyring),
              let result = try? container.remove(added.address)
        else {
            XCTAssert(false)
            return
        }
        
        XCTAssertTrue(result)
        XCTAssertEqual(0, container.count)
        XCTAssertNil(try container.getKeyring(multipleKeyring.address))
    }
    
    func test_roleBasedKey() throws {
        let container = KeyringContainer()
        let address = PrivateKey.generate().getDerivedAddress()
        let expectPrivateKeyArr = [
            [
                PrivateKey.generate().privateKey,
                PrivateKey.generate().privateKey,
                PrivateKey.generate().privateKey
            ],
            [
                PrivateKey.generate().privateKey,
                PrivateKey.generate().privateKey
            ],
            [
                PrivateKey.generate().privateKey,
                PrivateKey.generate().privateKey
            ]
        ]
        let roleBasedKeyring = try KeyringFactory.createWithRoleBasedKey(address, expectPrivateKeyArr)
        guard let added = try? container.add(roleBasedKeyring),
              let result = try? container.remove(added.address)
        else {
            XCTAssert(false)
            return
        }
        
        XCTAssertTrue(result)
        XCTAssertEqual(0, container.count)
        XCTAssertNil(try container.getKeyring(roleBasedKeyring.address))
    }
}

class KeyringContainerTest_signMessageTest: XCTestCase {
    func test_signMessage() throws {
        let container = KeyringContainer()
        let message = "message"
        let address = PrivateKey.generate().getDerivedAddress()
        let expectPrivateKeyArr = [
            [
                PrivateKey.generate().privateKey,
                PrivateKey.generate().privateKey,
                PrivateKey.generate().privateKey
            ],
            [
                PrivateKey.generate().privateKey,
                PrivateKey.generate().privateKey
            ],
            [
                PrivateKey.generate().privateKey,
                PrivateKey.generate().privateKey
            ]
        ]
        guard let roleBased = try? container.newKeyring(address, expectPrivateKeyArr),
              let expectedData = try? roleBased.signMessage(message, 0, 0),
              let actualData = try? container.signMessage(address, message)
        else {
            XCTAssert(false)
            return
        }
        
        XCTAssertEqual(message, actualData.message)
        XCTAssertEqual(Utils.hashMessage(message), actualData.messageHash)
        XCTAssertNotNil(actualData.signatures)

        XCTAssertEqual(expectedData.signatures[0].r, actualData.signatures[0].r)
        XCTAssertEqual(expectedData.signatures[0].s, actualData.signatures[0].s)
        XCTAssertEqual(expectedData.signatures[0].v, actualData.signatures[0].v)
    }
    
    func test_signMessageWithIndex() throws {
        let container = KeyringContainer()
        let message = "message"
        let address = PrivateKey.generate().getDerivedAddress()
        let expectPrivateKeyArr = [
            [
                PrivateKey.generate().privateKey,
                PrivateKey.generate().privateKey,
                PrivateKey.generate().privateKey
            ],
            [
                PrivateKey.generate().privateKey,
                PrivateKey.generate().privateKey
            ],
            [
                PrivateKey.generate().privateKey,
                PrivateKey.generate().privateKey
            ]
        ]
        guard let roleBased = try? container.newKeyring(address, expectPrivateKeyArr),
              let expectedData = try? roleBased.signMessage(message, 1, 0),
              let actualData = try? container.signMessage(address, message, 1, 0)
        else {
            XCTAssert(false)
            return
        }
        
        XCTAssertEqual(message, actualData.message)
        XCTAssertEqual(Utils.hashMessage(message), actualData.messageHash)
        XCTAssertNotNil(actualData.signatures)

        XCTAssertEqual(expectedData.signatures[0].r, actualData.signatures[0].r)
        XCTAssertEqual(expectedData.signatures[0].s, actualData.signatures[0].s)
        XCTAssertEqual(expectedData.signatures[0].v, actualData.signatures[0].v)
    }
}

class KeyringContainerTest_signTest: XCTestCase {
    func test_sign_withIndex_singleKeyring() throws {
        let container = KeyringContainer()
        guard let singleKeyring = KeyringFactory.generate(),
              let _ = try? container.add(singleKeyring),
              let valueTransfer = try? KeyringContainerTest.generateValueTransfer(singleKeyring),
              let _ = try? container.sign(singleKeyring.address, valueTransfer, 0),
              let expectedSig = try singleKeyring.sign(TransactionHasher.getHashForSignature(valueTransfer), valueTransfer.chainId, 0, 0)
        else {
            XCTAssert(false)
            return
        }
        
        XCTAssertEqual(1, valueTransfer.signatures.count)
        XCTAssertEqual(expectedSig, valueTransfer.signatures[0])
    }
    
    func test_sign_withIndex_multipleKeyring() throws {
        let container = KeyringContainer()
        let address = PrivateKey.generate().getDerivedAddress()
        let multipleKey = KeyringFactory.generateMultipleKeys(3)
        let multipleKeyring = try KeyringFactory.createWithMultipleKey(address, multipleKey)
        guard let valueTransfer = try? KeyringContainerTest.generateValueTransfer(multipleKeyring),
              let keyring = try? container.add(multipleKeyring),
              let _ = try? container.sign(keyring.address, valueTransfer, 1),
              let expectedSig = try keyring.sign(TransactionHasher.getHashForSignature(valueTransfer), valueTransfer.chainId, 0, 1)
        else {
            XCTAssert(false)
            return
        }
        
        
        XCTAssertEqual(1, valueTransfer.signatures.count)
        XCTAssertEqual(expectedSig, valueTransfer.signatures[0])
    }
    
    func test_sign_withIndex_roleBasedKeyring() throws {
        let container = KeyringContainer()
        let address = PrivateKey.generate().getDerivedAddress()
        let roleBasedKey = KeyringFactory.generateRoleBasedKeys([4,5,6], "entropy")
        let roleBasedKeyring = try KeyringFactory.createWithRoleBasedKey(address, roleBasedKey)
        guard let valueTransfer = try? KeyringContainerTest.generateValueTransfer(roleBasedKeyring),
              let keyring = try? container.add(roleBasedKeyring),
              let _ = try? container.sign(keyring.address, valueTransfer, 2),
              let expectedSig = try keyring.sign(TransactionHasher.getHashForSignature(valueTransfer), valueTransfer.chainId, 0, 2)
        else {
            XCTAssert(false)
            return
        }
        
        
        XCTAssertEqual(1, valueTransfer.signatures.count)
        XCTAssertEqual(expectedSig, valueTransfer.signatures[0])
    }
    
    func test_sign_withIndex_accountUpdate() throws {
        let container = KeyringContainer()
        let address = PrivateKey.generate().getDerivedAddress()
        let roleBasedKey = KeyringFactory.generateRoleBasedKeys([4,5,6], "entropy")
        let roleBasedKeyring = try KeyringFactory.createWithRoleBasedKey(address, roleBasedKey)
        guard let accountUpdate = try? KeyringContainerTest.generateAccountUpdate(roleBasedKeyring),
              let keyring = try? container.add(roleBasedKeyring),
              let _ = try? container.sign(keyring.address, accountUpdate, 2),
              let expectedSig = try keyring.sign(TransactionHasher.getHashForSignature(accountUpdate), accountUpdate.chainId, 1, 2)
        else {
            XCTAssert(false)
            return
        }
        
        
        XCTAssertEqual(1, accountUpdate.signatures.count)
        XCTAssertEqual(expectedSig, accountUpdate.signatures[0])
    }
    
    func test_throwException_withIndex_notExistedKeyring() throws {
        let container = KeyringContainer()
        let address = "0x1234567890123456789012345678901234567890"
        guard let valueTransfer = try? KeyringContainerTest.generateValueTransfer(KeyringFactory.generate()!)
        else {
            XCTAssert(false)
            return
        }
        
        XCTAssertThrowsError(try container.sign(address, valueTransfer, 0)) {
            XCTAssertEqual($0 as? CaverError, CaverError.NullPointerException("Failed to find keyring from wallet with address"))
        }
    }
    
    func test_sign_singleKeyring() throws {
        let container = KeyringContainer()
        guard let singleKeyring = KeyringFactory.generate(),
              let _ = try? container.add(singleKeyring),
              let valueTransfer = try? KeyringContainerTest.generateValueTransfer(singleKeyring),
              let _ = try? container.sign(singleKeyring.address, valueTransfer)
        else {
            XCTAssert(false)
            return
        }
        
        XCTAssertEqual(1, valueTransfer.signatures.count)
    }
    
    func test_sign_multipleKeyring() throws {
        let container = KeyringContainer()
        let address = PrivateKey.generate().getDerivedAddress()
        let multipleKey = KeyringFactory.generateMultipleKeys(3)
        let multipleKeyring = try KeyringFactory.createWithMultipleKey(address, multipleKey)
        guard let valueTransfer = try? KeyringContainerTest.generateValueTransfer(multipleKeyring),
              let keyring = try? container.add(multipleKeyring),
              let _ = try? container.sign(keyring.address, valueTransfer)
        else {
            XCTAssert(false)
            return
        }
        
        
        XCTAssertEqual(3, valueTransfer.signatures.count)
    }
    
    func test_sign_roleBasedKeyring() throws {
        let container = KeyringContainer()
        let address = PrivateKey.generate().getDerivedAddress()
        let roleBasedKey = KeyringFactory.generateRoleBasedKeys([4,5,6], "entropy")
        let roleBasedKeyring = try KeyringFactory.createWithRoleBasedKey(address, roleBasedKey)
        guard let valueTransfer = try? KeyringContainerTest.generateValueTransfer(roleBasedKeyring),
              let keyring = try? container.add(roleBasedKeyring),
              let _ = try? container.sign(keyring.address, valueTransfer)
        else {
            XCTAssert(false)
            return
        }
        
        
        XCTAssertEqual(4, valueTransfer.signatures.count)
    }
    
    func test_sign_customHasher() throws {
        let container = KeyringContainer()
        guard let singleKeyring = KeyringFactory.generate(),
              let _ = try? container.add(singleKeyring),
              let valueTransfer = try? KeyringContainerTest.generateValueTransfer(singleKeyring),
              let _ = try? container.sign(singleKeyring.address, valueTransfer, { _ in
            "0xd4aab6590bdb708d1d3eafe95a967dafcd2d7cde197e512f3f0b8158e7b65fd1"
            }),
              let expected = try? singleKeyring.sign("0xd4aab6590bdb708d1d3eafe95a967dafcd2d7cde197e512f3f0b8158e7b65fd1", valueTransfer.chainId, AccountKeyRoleBased.RoleGroup.TRANSACTION.rawValue)
        else {
            XCTAssert(false)
            return
        }
        
        XCTAssertEqual(expected[0], valueTransfer.signatures[0])
    }
    
    func test_sign_AccountUpdateTx() throws {
        let container = KeyringContainer()
        let address = PrivateKey.generate().getDerivedAddress()
        let roleBasedKey = KeyringFactory.generateRoleBasedKeys([4,5,6], "entropy")
        let roleBasedKeyring = try KeyringFactory.createWithRoleBasedKey(address, roleBasedKey)
        guard let _ = try? container.add(roleBasedKeyring),
              let tx = try? KeyringContainerTest.generateAccountUpdate(roleBasedKeyring),
              let _ = try? container.sign(address, tx)
        else {
            XCTAssert(false)
            return
        }
        
        XCTAssertEqual(5, tx.signatures.count)
    }
    
    func test_throwException_notExistKeyring() throws {
        let container = KeyringContainer()
        let address = "0x1234567890123456789012345678901234567890"
        guard let valueTransfer = try? KeyringContainerTest.generateValueTransfer(KeyringFactory.generate()!)
        else {
            XCTAssert(false)
            return
        }
        
        XCTAssertThrowsError(try container.sign(address, valueTransfer)) {
            XCTAssertEqual($0 as? CaverError, CaverError.NullPointerException("Failed to find keyring from wallet with address"))
        }
    }
}

class KeyringContainerTest_signAsFeePayerTest: XCTestCase {
    func test_signAsFeePayer_withIndex_singleKeyring() throws {
        let container = KeyringContainer()
        guard let singleKeyring = KeyringFactory.generate(),
              let _ = try? container.add(singleKeyring),
              let feeDelegatedValueTransfer = try? KeyringContainerTest.generateFeeDelegatedValueTransfer(singleKeyring),
              let _ = try? container.signAsFeePayer(singleKeyring.address, feeDelegatedValueTransfer, 0),
              let expectedSig = try singleKeyring.sign(TransactionHasher.getHashForFeePayerSignature(feeDelegatedValueTransfer), feeDelegatedValueTransfer.chainId, 2, 0)
        else {
            XCTAssert(false)
            return
        }
        
        XCTAssertEqual(1, feeDelegatedValueTransfer.feePayerSignatures.count)
        XCTAssertEqual(expectedSig, feeDelegatedValueTransfer.feePayerSignatures[0])
    }
    
    func test_signAsFeePayer_withIndex_multipleKeyring() throws {
        let container = KeyringContainer()
        let address = PrivateKey.generate().getDerivedAddress()
        let multipleKey = KeyringFactory.generateMultipleKeys(3)
        let multipleKeyring = try KeyringFactory.createWithMultipleKey(address, multipleKey)
        guard let feeDelegatedValueTransfer = try? KeyringContainerTest.generateFeeDelegatedValueTransfer(multipleKeyring),
              let keyring = try? container.add(multipleKeyring),
              let _ = try? container.signAsFeePayer(keyring.address, feeDelegatedValueTransfer, 1),
              let expectedSig = try keyring.sign(TransactionHasher.getHashForFeePayerSignature(feeDelegatedValueTransfer), feeDelegatedValueTransfer.chainId, 2, 1)
        else {
            XCTAssert(false)
            return
        }
        
        
        XCTAssertEqual(1, feeDelegatedValueTransfer.feePayerSignatures.count)
        XCTAssertEqual(expectedSig, feeDelegatedValueTransfer.feePayerSignatures[0])
    }
    
    func test_signAsFeePayer_withIndex_roleBasedKeyring() throws {
        let container = KeyringContainer()
        let address = PrivateKey.generate().getDerivedAddress()
        let roleBasedKey = KeyringFactory.generateRoleBasedKeys([4,5,6], "entropy")
        let roleBasedKeyring = try KeyringFactory.createWithRoleBasedKey(address, roleBasedKey)
        guard let feeDelegatedValueTransfer = try? KeyringContainerTest.generateFeeDelegatedValueTransfer(roleBasedKeyring),
              let keyring = try? container.add(roleBasedKeyring),
              let _ = try? container.signAsFeePayer(keyring.address, feeDelegatedValueTransfer, 2),
              let expectedSig = try keyring.sign(TransactionHasher.getHashForFeePayerSignature(feeDelegatedValueTransfer), feeDelegatedValueTransfer.chainId, 2, 2)
        else {
            XCTAssert(false)
            return
        }
        
        
        XCTAssertEqual(1, feeDelegatedValueTransfer.feePayerSignatures.count)
        XCTAssertEqual(expectedSig, feeDelegatedValueTransfer.feePayerSignatures[0])
    }
    
    func test_throwException_withIndex_notExistedKeyring() throws {
        let container = KeyringContainer()
        let address = "0x1234567890123456789012345678901234567890"
        guard let feeDelegatedValueTransfer = try? KeyringContainerTest.generateFeeDelegatedValueTransfer(KeyringFactory.generate()!)
        else {
            XCTAssert(false)
            return
        }
        
        XCTAssertThrowsError(try container.signAsFeePayer(address, feeDelegatedValueTransfer, 0)) {
            XCTAssertEqual($0 as? CaverError, CaverError.NullPointerException("Failed to find keyring from wallet with address"))
        }
    }
    
    func test_signAsFeePayer_singleKeyring() throws {
        let container = KeyringContainer()
        guard let singleKeyring = KeyringFactory.generate(),
              let _ = try? container.add(singleKeyring),
              let feeDelegatedValueTransfer = try? KeyringContainerTest.generateFeeDelegatedValueTransfer(singleKeyring),
              let _ = try? container.signAsFeePayer(singleKeyring.address, feeDelegatedValueTransfer)
        else {
            XCTAssert(false)
            return
        }
        
        XCTAssertEqual(1, feeDelegatedValueTransfer.feePayerSignatures.count)
    }
    
    func test_signAsFeePayer_multipleKeyring() throws {
        let container = KeyringContainer()
        let address = PrivateKey.generate().getDerivedAddress()
        let multipleKey = KeyringFactory.generateMultipleKeys(3)
        let multipleKeyring = try KeyringFactory.createWithMultipleKey(address, multipleKey)
        guard let feeDelegatedValueTransfer = try? KeyringContainerTest.generateFeeDelegatedValueTransfer(multipleKeyring),
              let keyring = try? container.add(multipleKeyring),
              let _ = try? container.signAsFeePayer(keyring.address, feeDelegatedValueTransfer)
        else {
            XCTAssert(false)
            return
        }
        
        
        XCTAssertEqual(3, feeDelegatedValueTransfer.feePayerSignatures.count)
    }
    
    func test_signAsFeePayer_roleBasedKeyring() throws {
        let container = KeyringContainer()
        let address = PrivateKey.generate().getDerivedAddress()
        let roleBasedKey = KeyringFactory.generateRoleBasedKeys([4,5,6], "entropy")
        let roleBasedKeyring = try KeyringFactory.createWithRoleBasedKey(address, roleBasedKey)
        guard let feeDelegatedValueTransfer = try? KeyringContainerTest.generateFeeDelegatedValueTransfer(roleBasedKeyring),
              let keyring = try? container.add(roleBasedKeyring),
              let _ = try? container.signAsFeePayer(keyring.address, feeDelegatedValueTransfer)
        else {
            XCTAssert(false)
            return
        }
        
        
        XCTAssertEqual(6, feeDelegatedValueTransfer.feePayerSignatures.count)
    }
    
    func test_signAsFeePayer_customHasher() throws {
        let container = KeyringContainer()
        guard let singleKeyring = KeyringFactory.generate(),
              let _ = try? container.add(singleKeyring),
              let feeDelegatedValueTransfer = try? KeyringContainerTest.generateFeeDelegatedValueTransfer(singleKeyring),
              let _ = try? container.signAsFeePayer(singleKeyring.address, feeDelegatedValueTransfer, { _ in
                "0xd4aab6590bdb708d1d3eafe95a967dafcd2d7cde197e512f3f0b8158e7b65fd1"
            }),
              let expected = try? singleKeyring.sign("0xd4aab6590bdb708d1d3eafe95a967dafcd2d7cde197e512f3f0b8158e7b65fd1", feeDelegatedValueTransfer.chainId, AccountKeyRoleBased.RoleGroup.FEE_PAYER.rawValue)
        else {
            XCTAssert(false)
            return
        }
        
        XCTAssertEqual(expected[0], feeDelegatedValueTransfer.feePayerSignatures[0])
    }
    
    func test_throwException_notExistKeyring() throws {
        let container = KeyringContainer()
        let address = "0x1234567890123456789012345678901234567890"
        guard let feeDelegatedValueTransfer = try? KeyringContainerTest.generateFeeDelegatedValueTransfer(KeyringFactory.generate()!)
        else {
            XCTAssert(false)
            return
        }
        
        XCTAssertThrowsError(try container.signAsFeePayer(address, feeDelegatedValueTransfer)) {
            XCTAssertEqual($0 as? CaverError, CaverError.NullPointerException("Failed to find keyring from wallet with address"))
        }
    }
}
