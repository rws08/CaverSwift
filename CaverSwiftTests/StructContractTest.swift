//
//  StructContractTest.swift
//  CaverSwiftTests
//
//  Created by won on 2021/07/22.
//

import XCTest
@testable import CaverSwift
@testable import GenericJSON

class StructContractTest: XCTestCase {
    static var BYTECODE = ""
    static var CONTRACT_ABI = ""
    
    static var caver = Caver(Caver.DEFAULT_URL)
    static var testContract = try! Contract(caver, CONTRACT_ABI)
    static var deployerKeyring = try! KeyringFactory.createFromPrivateKey("871ccee7755bb4247e783110cafa6437f9f593a1eaeebe0efcc1b0852282c3e5")
    
    override func setUpWithError() throws {
        if !StructContractTest.BYTECODE.isEmpty {
            return
        }
        
        do {
            if let file  = Bundle(for: type(of: self)).url(forResource: "StructContractTestData", withExtension: "json"){
                let data  = try Data(contentsOf: file)
                let json = try JSONDecoder().decode(JSON.self, from:data)
                StructContractTest.BYTECODE = json["BYTECODE"]?.stringValue ?? ""
                let jsonObj = try JSONEncoder().encode(json["CONTRACT_ABI"])
                StructContractTest.CONTRACT_ABI = String(data: jsonObj, encoding: .utf8)!
            }else{
                print("no file")
            }
        } catch {
            print(error.localizedDescription)
        }
        
        StructContractTest.caver = Caver(Caver.DEFAULT_URL)
        StructContractTest.testContract = try! Contract(StructContractTest.caver, StructContractTest.CONTRACT_ABI)
        StructContractTest.deployerKeyring = try StructContractTest.caver.wallet.add(try! KeyringFactory.createFromPrivateKey("871ccee7755bb4247e783110cafa6437f9f593a1eaeebe0efcc1b0852282c3e5")) as! SingleKeyring
        
        _ = try! StructContractTest.testContract.deploy(SendOptions(StructContractTest.deployerKeyring.address, BigInt(30000000)), StructContractTest.BYTECODE)
        print("\(String(describing: StructContractTest.testContract.contractAddress))")
    }
    
    func testDs() throws {
        guard let result = try StructContractTest.testContract.getMethod("setDs").call([["name", [1, 2, 3]]])
        else { XCTAssert(false)
            return }
        let dynamicStruct = result[0].value as! DynamicStruct
        XCTAssertEqual(dynamicStruct.values[0] as! String, "name")
        XCTAssertEqual(dynamicStruct.values[1] as! TypeArray, TypeArray([BigUInt(1), BigUInt(2), BigUInt(3)], BigUInt.rawType))
    }
    
    func testSs() throws {
        guard let result = try StructContractTest.testContract.getMethod("setSs").call([[1, false]])
        else { XCTAssert(false)
            return }
        let staticStruct = result[0].value as! StaticStruct
        XCTAssertEqual(staticStruct, StaticStruct([BigUInt(1), false]))
    }
    
    func testCs() throws {
        let expected = DynamicStruct([
            DynamicStruct([
                "name",
                StaticArray3([BigUInt(1), BigUInt(2), BigUInt(3)])
            ]),
            StaticStruct([BigUInt(1), false]),
            BigUInt(123)
        ])
        
        guard let result = try StructContractTest.testContract
                .getMethod("setCs")
                .call([[
                    ["name", [1, 2, 3]],
                    [1, false],
                    123
                ]])
        else { XCTAssert(false)
            return }
        let dynamicStruct = result[0].value as! DynamicStruct
        XCTAssertEqual(dynamicStruct, expected)
    }
    
    func testSsArr() throws {
        let expected = DynamicArray([
            StaticStruct([BigUInt(1), false]),
            StaticStruct([BigUInt(2), false]),
            StaticStruct([BigUInt(3), true])
        ])
        
        guard let result = try StructContractTest.testContract
                .getMethod("setSsArr")
                .call([[
                    [1, false],
                    [2, false],
                    [3, true]
                ]])
        else { XCTAssert(false)
            return }
        XCTAssertEqual(result[0].value as? DynamicArray, expected)
    }
}
