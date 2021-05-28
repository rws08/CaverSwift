//
//  CaverSwiftTests.swift
//  CaverSwiftTests
//
//  Created by won on 2021/04/20.
//

import XCTest
@testable import CaverSwift
@testable import GenericJSON
@testable import BigInt

class CaverSwiftTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
//        let expectation = XCTestExpectation(description: "Some description")
//
//        let caver = Caver("https://kaikas.cypress.klaytn.net:8651")
//        do {
//            if let file  = Bundle(for: type(of: self)).url(forResource: "DelegationContract", withExtension: "json"){
//                let data  = try Data(contentsOf: file)
//                let json = try JSONDecoder().decode(JSON.self, from:data)
//                let encoded = try JSONEncoder().encode(json["abi"])
//                let contract = try Contract(caver, String(data: encoded, encoding: .utf8)!, "0xe33337cb6fbb68954fe1c3fde2b21f56586632cd")
//                contract.call("getPoolStat", []) {
//                    let sklayBalance = $0?[0].value as? BigUInt ?? BigUInt.zero
//                    let klayBalance = $0?[1].value as? BigUInt ?? BigUInt.zero
//                    let sKlayRatio = klayBalance.double / sklayBalance.double
//                    print(sKlayRatio.decimalExpansion(precisionAfterDecimalPoint: 6, rounded: false))
//                    expectation.fulfill()
//                }
//            }else{
//                print("no file")
//            }
//        } catch {
//            print(error.localizedDescription)
//        }
//
//        let result = XCTWaiter.wait(for: [expectation], timeout: 2.0)
//        XCTAssertEqual(result, .completed)
    }
}
