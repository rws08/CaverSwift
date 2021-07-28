//
//  ContractOverloadFunctionsTest.swift
//  CaverSwiftTests
//
//  Created by won on 2021/07/26.
//

import XCTest
@testable import CaverSwift
@testable import GenericJSON

class ContractOverloadFunctionsTest: XCTestCase {
    static var BYTECODE = ""
    static var ABIJson = ""
    
    static let ownerData = TestAccountInfo.TEST
    static let ownerPrivateKey = ownerData.privateKey
    static var contractAddress = ""
    
    override func setUpWithError() throws {
        if !ContractOverloadFunctionsTest.BYTECODE.isEmpty {
            return
        }
        
        do {
            if let file  = Bundle(for: type(of: self)).url(forResource: "ContractOverloadFunctionsTestData", withExtension: "json"){
                let data  = try Data(contentsOf: file)
                let json = try JSONDecoder().decode(JSON.self, from:data)
               ContractOverloadFunctionsTest.BYTECODE = json["BYTECODE"]?.stringValue ?? ""
                let jsonObj = try JSONEncoder().encode(json["ABIJson"])
               ContractOverloadFunctionsTest.ABIJson = String(data: jsonObj, encoding: .utf8)!
            }else{
                print("no file")
            }
        } catch {
            print(error.localizedDescription)
        }
        
        let caver = Caver(Caver.DEFAULT_URL)
        _ = try caver.wallet.add(KeyringFactory.createFromPrivateKey(ContractOverloadFunctionsTest.ownerPrivateKey))
        
        let options = SendOptions(ContractOverloadFunctionsTest.ownerData.address, ContractTest.GAS_LIMIT)
        let contractDeployParam = try ContractDeployParams(ContractOverloadFunctionsTest.BYTECODE)
        
        let contract = try Contract(caver, ContractOverloadFunctionsTest.ABIJson)
        _ = try contract.deploy(contractDeployParam, options)
        ContractOverloadFunctionsTest.contractAddress = contract.contractAddress!
    }
    
    func test_overloadFunctionTest() throws {
        let methodName = "changeOwner"
        
        let caver = Caver(Caver.DEFAULT_URL)
        _ = try! caver.wallet.add(try! KeyringFactory.createFromPrivateKey(ContractOverloadFunctionsTest.ownerData.privateKey))
        
        let options = SendOptions(ContractOverloadFunctionsTest.ownerData.address, ContractTest.GAS_LIMIT)
        
        let contract = try Contract(caver, ContractOverloadFunctionsTest.ABIJson, ContractOverloadFunctionsTest.contractAddress)
        _ = try contract.getMethod(methodName).sendWithSolidityWrapper(
            [Address(ContractOverloadFunctionsTest.ownerData.address), Utf8String("LUMAN")], options)
        var result = try contract.getMethod("getOwnerName").call(nil, CallObject.createCallObject())
        
        XCTAssertEqual("LUMAN", result?[0].value as? String)
        
        _ = try contract.getMethod(methodName).sendWithSolidityWrapper(
            [Address(ContractOverloadFunctionsTest.ownerData.address), Uint256(1234)], options)
        result = try contract.getMethod("getOwnerName").call(nil, CallObject.createCallObject())
        print(result?[0].value ?? "")
        
        result = try contract.getMethod("getOwnerNumber").call(nil, CallObject.createCallObject())
        XCTAssertEqual(1234, result?[0].value as? BigUInt)
    }
    
    func test_callWithSolidityWrapperTest() throws {
        let methodName = "getOwner"
        
        let caver = Caver(Caver.DEFAULT_URL)
        _ = try! caver.wallet.add(try! KeyringFactory.createFromPrivateKey(ContractOverloadFunctionsTest.ownerData.privateKey))
        
        let contract = try Contract(caver, ContractOverloadFunctionsTest.ABIJson, ContractOverloadFunctionsTest.contractAddress)
        let result = try contract.getMethod(methodName).callWithSolidityWrapper(nil, CallObject.createCallObject())
        
        XCTAssertEqual(ContractOverloadFunctionsTest.ownerData.address.lowercased(), (result?[0].value as? Address)?.toValue)
    }
    
    func test_callWithSolidityWrapperNoCallObjectTest() throws {
        let methodName = "getOwner"
        
        let caver = Caver(Caver.DEFAULT_URL)
        _ = try! caver.wallet.add(try! KeyringFactory.createFromPrivateKey(ContractOverloadFunctionsTest.ownerData.privateKey))
        
        let contract = try Contract(caver, ContractOverloadFunctionsTest.ABIJson, ContractOverloadFunctionsTest.contractAddress)
        let result = try contract.getMethod(methodName).callWithSolidityWrapper(nil)
        
        XCTAssertEqual(ContractOverloadFunctionsTest.ownerData.address.lowercased(), (result?[0].value as? Address)?.toValue)
    }
    
    func test_encodeABIWithSolidityWrapperTest() throws {
        let methodName = "changeOwner"
        
        let caver = Caver(Caver.DEFAULT_URL)
        _ = try! caver.wallet.add(try! KeyringFactory.createFromPrivateKey(ContractOverloadFunctionsTest.ownerData.privateKey))
        
        let contract = try Contract(caver, ContractOverloadFunctionsTest.ABIJson, ContractOverloadFunctionsTest.contractAddress)
        let expected = try contract.getMethod(methodName).encodeABI([ContractOverloadFunctionsTest.ownerData.address])
        let actual = try contract.getMethod(methodName).encodeABIWithSolidityWrapper([Address(ContractOverloadFunctionsTest.ownerData.address)])
        
        XCTAssertEqual(expected, actual)
    }
}
