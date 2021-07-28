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
    
    public func testttt() throws {
        let tokenID = BigUInt(1)
        let toArr = [TestAccountInfo.WAYNE.address, TestAccountInfo.BRANDON.address]
        let mintAmountArr = [BigUInt(10), BigUInt(10)]
        
        let valueList = mintAmountArr.map { Uint256($0) }
        let addressList = toArr.map { Address($0) }
        
        let tokenIdSol = Uint256(tokenID)
        let toListSol = DynamicArray(addressList)
        let valuesSol = DynamicArray(valueList)
        _ = try ABI.encodeParameters([tokenIdSol, toListSol, valuesSol])
    }
            
    public func temp(_ methodArguments: Any...) -> [Any] {
        print("1", methodArguments)
        return temp2(methodArguments.flatCompactMapForVariadicParameters())
    }
    
    public func temp2(_ methodArguments: Any...) -> [Any] {
        print("2", methodArguments)
        return methodArguments.flatCompactMapForVariadicParameters()
    }

    func testExample() throws {        
        let expectation = XCTestExpectation(description: "Some description")

//        let caver = Caver("https://kaikas.cypress.klaytn.net:8651")
        let caver = Caver("https://api.baobab.klaytn.net:8651")
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

        let(_, result) = caver.rpc.klay.getBalance("0x5330bF6E777aD4DFf04200Db46D9EBF042949ECf")
        print(result?.val.decimal as Any)
        expectation.fulfill()
        
        let waiter = XCTWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(waiter, .completed)
    }
}
