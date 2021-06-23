//
//  AccountKeyTest.swift
//  CaverSwiftTests
//
//  Created by won on 2021/06/23.
//

import XCTest
@testable import CaverSwift
@testable import BigInt

class AccountKeyFailTests: XCTestCase {
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

class AccountKeyLegacyTest: XCTestCase {
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

class AccountKeyPublicTest: XCTestCase {
    func testDecodeWithString() throws {
        let expectedAccountKey = "0xc10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9803a1898f45b2770eda7abce70e8503b5e82b748ec0ce557ac9f4f4796965e4e"
        let actualEncodedKey = "0x02a102c10b598a1a3ba252acc21349d61c2fbd9bc8c15c50a5599f420cccc3291f9bf9"

        let accountKeyFail = try? AccountKeyLegacy.decode(actualEncodedKey)
        XCTAssertTrue(accountKeyFail != nil)
    }
}
