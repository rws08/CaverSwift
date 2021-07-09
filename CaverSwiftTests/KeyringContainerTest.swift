//
//  KeyringContainerTest.swift
//  CaverSwiftTests
//
//  Created by won on 2021/07/09.
//

import XCTest
@testable import CaverSwift

class KeyringContainerTest: XCTestCase {
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
}
