//
//  Caver_swiftTests.swift
//  Caver-swiftTests
//
//  Created by won on 2021/04/20.
//

import XCTest
@testable import Caver_swift
@testable import SwiftyJSON
@testable import BigInt

class Caver_swiftTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

//    func testExample() throws {
//        let caver = Caver("https://kaikas.cypress.klaytn.net:8651")
//        do {
//            if let file  = Bundle(for: type(of: self)).url(forResource: "test", withExtension: "json"){
//                let data  = try Data(contentsOf: file)
//                let json = try JSON(data: data)
//
//                let contract = try Contract(caver, json["abi"].rawString()!, "0x3b87b84f3b629ef0afec5ed8e3b6a7df977ba902")
//
//            }else{
//                print("no file")
//            }
//        } catch {
//            print(error.localizedDescription)
//
//        }
//    }
    
    func testBuildFunctionStringTest() throws {
        let caver = Caver("https://kaikas.cypress.klaytn.net:8651")
        if let file  = Bundle(for: type(of: self)).url(forResource: "testFunction", withExtension: "json"){
            let data  = try Data(contentsOf: file)
            let contract = try Contract(caver, String(data: data, encoding: .utf8)!)
     
            XCTAssertEqual("b(string)", try ABI.buildFunctionString(contract.getMethod("b")))
            XCTAssertEqual("g(uint256)", try ABI.buildFunctionString(contract.getMethod("g")))
            XCTAssertEqual("h(bytes32[])", try ABI.buildFunctionString(contract.getMethod("h")))
            
            XCTAssertEqual("staticStruct((uint256,uint256))", try ABI.buildFunctionString(contract.getMethod("staticStruct")))
            XCTAssertEqual("dynamicStruct((uint256,string))", try ABI.buildFunctionString(contract.getMethod("dynamicStruct")))
            XCTAssertEqual("structArray((uint256,uint256[],(uint256,uint256)[])[])", try ABI.buildFunctionString(contract.getMethod("structArray")))
        }else{
            print("no file")
        }
    }
    
    func testTest() {
//        XCTAssertEqual(["string", "tuple(string,string)", "tuple(string,string)"], ABIRawType.splitComponent("tuple(string,tuple(string,string),tuple(string,string))"))
    }
}
