//
//  UtilsTest.swift
//  CaverSwiftTests
//
//  Created by won on 2021/06/23.
//

import XCTest
@testable import CaverSwift

class isAddressTest: XCTestCase {
    func testLowerCaseAddressTest() throws {
        let lowercase = ["0xff6916ea19a50878e39c41aaadfeb0cab1b41dad",
                         "0x4834113481fbbac68565987d30f5216bc5719d3b",
                         "ff6916ea19a50878e39c41aaadfeb0cab1b41dad",
                         "4834113481fbbac68565987d30f5216bc5719d3b"]
        for item in lowercase {
            XCTAssertTrue(Utils.isAddress(item), "fail : \(item)")
        }
    }
    
    func testUpperCaseAddressTest() throws {
        let uppercase = ["0xFF6916EA19A50878E39C41AAADFEB0CAB1B41DAD",
                         "0x4834113481FBBAC68565987D30F5216BC5719D3B",
                         "4834113481FBBAC68565987D30F5216BC5719D3B",
                         "FF6916EA19A50878E39C41AAADFEB0CAB1B41DAD"]
        for item in uppercase {
            XCTAssertTrue(Utils.isAddress(item), "fail : \(item)")
        }
    }
    
    func testChecksumAddressTest() throws {
        let checksumAddress = ["0xdbF03B407c01E7cD3CBea99509d93f8DDDC8C6FB",
                               "0xD1220A0cf47c7B9Be7A2E6BA89F429762e7b9aDb",
                               "0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359",
                               "0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed"]
        for item in checksumAddress {
            XCTAssertTrue(Utils.isAddress(item), "fail : \(item)")
        }
    }
    
    func testInvalidAddressTest() throws {
        let checksumAddress = ["0xff6916ea19a50878e39c41cab1b41da",// Length is not 40
                               "0xKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK", // Not Hex String
                               "0x2058a550ea824841e991ef386c3aD63D088303B3"] // Invalid checksum address.
        for item in checksumAddress {
            XCTAssertFalse(Utils.isAddress(item), "fail : \(item)")
        }
    }
}

class isValidPrivateKeyTest: XCTestCase {
    func testValidPrivateKey() throws {
        let lowercase = ["0xff6916ea19a50878e39c41aaadfeb0cab1b41dad",
                         "0x4834113481fbbac68565987d30f5216bc5719d3b",
                         "ff6916ea19a50878e39c41aaadfeb0cab1b41dad",
                         "4834113481fbbac68565987d30f5216bc5719d3b"]
        for item in lowercase {
            XCTAssertTrue(Utils.isAddress(item), "fail : \(item)")
        }
    }
}
