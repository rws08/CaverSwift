//
//  ContractImproveFuncTest.swift
//  CaverSwiftTests
//
//  Created by won on 2021/07/23.
//

import XCTest
@testable import CaverSwift
@testable import GenericJSON

class ContractImproveFuncTest: XCTestCase {
    static let FUNC_SET_STRING = "setString"
    static let FUNC_SET_UINT = "setUint"
    static let FUNC_GET_STRING = "getString"
    static let FUNC_GET_UINT = "getUint"
    static let FUNC_GET_SYMBOL = "getSymbol"
    
    static var BINARY = ""
    static var ABI = ""
    
    static let ownerPrivateKey = "0x871ccee7755bb4247e783110cafa6437f9f593a1eaeebe0efcc1b0852282c3e5"
    static var ownerKeyring = try! KeyringFactory.createFromPrivateKey(ownerPrivateKey)
    static var caver = Caver(Caver.DEFAULT_URL)
    static var contract = try! Contract(caver, ABI)
    
    override func setUpWithError() throws {
        if !ContractImproveFuncTest.BINARY.isEmpty {
            return
        }
        
        do {
            if let file  = Bundle(for: type(of: self)).url(forResource: "ContractImproveFuncTestData", withExtension: "json"){
                let data  = try Data(contentsOf: file)
                let json = try JSONDecoder().decode(JSON.self, from:data)
               ContractImproveFuncTest.BINARY = json["BINARY"]?.stringValue ?? ""
                let jsonObj = try JSONEncoder().encode(json["ABI"])
               ContractImproveFuncTest.ABI = String(data: jsonObj, encoding: .utf8)!
            }else{
                print("no file")
            }
        } catch {
            print(error.localizedDescription)
        }
        
        ContractImproveFuncTest.caver = Caver(Caver.DEFAULT_URL)
        ContractImproveFuncTest.ownerKeyring = try! KeyringFactory.createFromPrivateKey(ContractImproveFuncTest.ownerPrivateKey)
        _ = try ContractImproveFuncTest.caver.wallet.add(ContractImproveFuncTest.ownerKeyring)
        ContractImproveFuncTest.contract = try! Contract(ContractImproveFuncTest.caver, ContractImproveFuncTest.ABI)
        ContractImproveFuncTest.contract.setDefaultSendOptions(SendOptions(ContractImproveFuncTest.ownerKeyring.address, BigUInt(8000000)))
        
        let deployParams = try ContractDeployParams(ContractImproveFuncTest.BINARY, ["CONTRACT_TEST"])
        _ = try ContractImproveFuncTest.contract.deploy(deployParams, SendOptions(ContractImproveFuncTest.ownerKeyring.address, BigUInt(6500000)))
        
        _ = storeStringData("Contract", "Call")
        _ = storeUintData("Age", 2)
    }
    
    func storeStringData(_ key: String, _ value: String) -> TransactionReceiptData? {
        let sendOptions = SendOptions(ContractImproveFuncTest.ownerKeyring.address, BigUInt(500000))
        let receiptData = try? ContractImproveFuncTest.contract.send(sendOptions, ContractImproveFuncTest.FUNC_SET_STRING, key, value)
        
        if(receiptData?.status != "0x1") {
            XCTAssert(false)
        }

        return receiptData
    }
    
    func storeUintData(_ key: String, _ value: Int) -> TransactionReceiptData? {
        let sendOptions = SendOptions(ContractImproveFuncTest.ownerKeyring.address, BigUInt(500000))
        let receiptData = try? ContractImproveFuncTest.contract.send(sendOptions, ContractImproveFuncTest.FUNC_SET_UINT, key, value)
        
        if(receiptData?.status != "0x1") {
            XCTAssert(false)
        }

        return receiptData
    }
    
    func test_deployTest() throws {
        let caver = Caver(Caver.DEFAULT_URL);
        _ = try caver.wallet.add(ContractImproveFuncTest.ownerKeyring)

        let contract = try Contract(caver, ContractImproveFuncTest.ABI)
        let sendOptions = SendOptions(ContractImproveFuncTest.ownerKeyring.address, BigUInt(6500000))
        _ = try contract.deploy(sendOptions, ContractImproveFuncTest.BINARY, "TEST")
        XCTAssertNotNil(contract.contractAddress)
    }
    
    func test_send_setString() throws {
        let receiptData = storeStringData("CAVER", "TEST")
        XCTAssertEqual("0x1", receiptData?.status)
    }
    
    func test_send_setUint() throws {
        let receiptData = storeUintData("CAVER", 2020)
        XCTAssertEqual("0x1", receiptData?.status)
    }
    
    func test_sendWithDefaultOption_setString() throws {
        let receiptData = try ContractImproveFuncTest.contract.send(ContractImproveFuncTest.FUNC_SET_STRING, "KLAYTN", "Block chain")
        XCTAssertEqual("0x1", receiptData.status)
    }
    
    func test_sendWithSolidityWrapper_setString() throws {
        let receiptData = try ContractImproveFuncTest.contract.sendWithSolidityType(ContractImproveFuncTest.FUNC_SET_STRING, Utf8String("KLAYTN"), Utf8String("Block chain"))
        XCTAssertEqual("0x1", receiptData.status)
    }
    
    func test_sendWithSolidityWrapper_setUint() throws {
        let receiptData = try ContractImproveFuncTest.contract.sendWithSolidityType(ContractImproveFuncTest.FUNC_SET_UINT, Utf8String("DEV"), Uint256(10))
        XCTAssertEqual("0x1", receiptData.status)
    }
    
    func test_call_getSymbol() throws {
        let result = ContractImproveFuncTest.contract.call(ContractImproveFuncTest.FUNC_GET_SYMBOL)
        XCTAssertEqual("CONTRACT_TEST", result?[0].getValue())
    }
    
    func test_callWithSolidityWrapper_getSymbol() throws {
        let result = ContractImproveFuncTest.contract.callWithSolidityType(ContractImproveFuncTest.FUNC_GET_SYMBOL)
        XCTAssertEqual("CONTRACT_TEST", result?[0].getValue())
    }
    
    func test_call_getString() throws {
        let result = ContractImproveFuncTest.contract.call(ContractImproveFuncTest.FUNC_GET_STRING, "Contract")
        XCTAssertEqual("Call", result?[0].getValue())
    }
    
    func test_callWithSolidityWrapper_getString() throws {
        let result = ContractImproveFuncTest.contract.callWithSolidityType(ContractImproveFuncTest.FUNC_GET_STRING, Utf8String("Contract"))
        XCTAssertEqual("Call", result?[0].getValue())
    }
    
    func test_call_getUint() throws {
        let result = ContractImproveFuncTest.contract.call(ContractImproveFuncTest.FUNC_GET_UINT, "Age")
        XCTAssertEqual(BigUInt(2), result?[0].getValue())
    }
    
    func test_callWithSolidityWrapper_getUint() throws {
        let result = ContractImproveFuncTest.contract.callWithSolidityType(ContractImproveFuncTest.FUNC_GET_UINT, Utf8String("Age"))
        XCTAssertEqual(BigUInt(2), result?[0].getValue())
    }
    
    func test_estimateGas() throws {
        let callObject = CallObject.createCallObject(ContractImproveFuncTest.ownerKeyring.address)
        let gas = ContractImproveFuncTest.contract.estimateGas(callObject, ContractImproveFuncTest.FUNC_SET_STRING, "ESTIMATE", "GAS")
        XCTAssertNotNil(gas)
    }
    
    func test_estimateGasWithSolidityType() throws {
        let callObject = CallObject.createCallObject(ContractImproveFuncTest.ownerKeyring.address)
        let gas = ContractImproveFuncTest.contract.estimateGasWithSolidityType(callObject, ContractImproveFuncTest.FUNC_SET_STRING, Utf8String("ESTIMATE"), Utf8String("GAS"))
        XCTAssertNotNil(gas)
    }
    
    func test_encodeABI() throws {
        let expected = try ContractImproveFuncTest.contract.getMethod(ContractImproveFuncTest.FUNC_SET_STRING).encodeABI(["ENCODE", "FUNCTION"])
        let actual = ContractImproveFuncTest.contract.encodeABI(ContractImproveFuncTest.FUNC_SET_STRING, "ENCODE", "FUNCTION")
        
        XCTAssertEqual(expected, actual)
    }
    
    func test_encodeABIWithSolidityType() throws {
        let expected = try ContractImproveFuncTest.contract.getMethod(ContractImproveFuncTest.FUNC_SET_STRING).encodeABIWithSolidityWrapper([Utf8String("ENCODE"), Utf8String("FUNCTION")])
        let actual = ContractImproveFuncTest.contract.encodeABIWithSolidityType(ContractImproveFuncTest.FUNC_SET_STRING, Utf8String("ENCODE"), Utf8String("FUNCTION"))
        
        XCTAssertEqual(expected, actual)
    }
    
    func test_sendRawTx_throwException_send() throws {
        let sendOptions = SendOptions(ContractImproveFuncTest.ownerKeyring.address, BigUInt(500))
        
        XCTAssertThrowsError(try ContractImproveFuncTest.contract.send(sendOptions, ContractImproveFuncTest.FUNC_SET_STRING, "GAS", "ENOUGH")) {
            XCTAssertEqual($0 as? CaverError, CaverError.JSONRPCError("intrinsic gas too low"))
        }
    }
    
    func test_sendRawTx_throwException_deploy() throws {
        let caver = Caver(Caver.DEFAULT_URL);
        _ = try caver.wallet.add(ContractImproveFuncTest.ownerKeyring)

        let contract = try Contract(caver, ContractImproveFuncTest.ABI)
        let sendOptions = SendOptions(ContractImproveFuncTest.ownerKeyring.address, BigUInt(6500))
        
        XCTAssertThrowsError(try contract.deploy(sendOptions, ContractImproveFuncTest.BINARY, "TEST")) {
            XCTAssertEqual($0 as? CaverError, CaverError.JSONRPCError("intrinsic gas too low"))
        }
    }
}
