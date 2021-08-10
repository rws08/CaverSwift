//
//  RlpTest.swift
//  CaverSwiftTests
//
//  Created by won on 2021/07/01.
//

import XCTest
@testable import CaverSwift

class RlpTest: XCTestCase {
    func testRlpDecode() {
        var expected: Any = "0127"
        var testVal = Rlp.encode(expected)!.hexString
        var result = Rlp.decode(testVal.bytesFromHex!)
        XCTAssertEqual(expected as! String, result as! String)
        
        expected = "0000000000000000000000000000000000000000000000000000000000000000"
        testVal = Rlp.encode(expected)!.hexString
        result = Rlp.decode(testVal.bytesFromHex!)
        XCTAssertEqual(expected as! String, result as! String)
        
        expected = ["00", "0127"]
        testVal = Rlp.encode(expected)!.hexString
        result = Rlp.decode(testVal.bytesFromHex!)
        XCTAssertEqual(expected as! [String], result as! [String])
        
        expected = ["00", ""]
        testVal = Rlp.encode(expected)!.hexString
        result = Rlp.decode(testVal.bytesFromHex!)
        XCTAssertEqual(expected as! [String], result as! [String])
        
        expected = ["", ""]
        testVal = Rlp.encode(expected)!.hexString
        result = Rlp.decode(testVal.bytesFromHex!)
        XCTAssertEqual(expected as! [String], result as! [String])
        
        expected = "1122334455667788990011223344556677889900112233445566778899001122334455667788990011223344556677889900112233445566"
        testVal = Rlp.encode(expected)!.hexString
        result = Rlp.decode(testVal.bytesFromHex!)
        XCTAssertEqual(expected as! String, result as! String)
        
        expected = ["0000000000000000000000000000000000000000000000000000000000000000", ["6cc5fb56e43b3d023a6f43de915fab26c4c1ec96"], "", "00000000", []]
        testVal = Rlp.encode(expected)!.hexString
        result = Rlp.decode(testVal.bytesFromHex!)
        XCTAssertEqual((expected as! [Any]).description, (result as! [Any]).description)
    }
}
