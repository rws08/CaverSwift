//
//  ContractTest.swift
//  CaverSwiftTests
//
//  Created by won on 2021/07/19.
//

import XCTest
@testable import CaverSwift
@testable import GenericJSON

class ContractTest: XCTestCase {
    static var BINARY = ""
    
    static var jsonObj = ""
    static var contractAddress = ""
    static let ownerPrivateKey = "0x2359d1ae7317c01532a58b01452476b796a3ac713336e97d8d3c9651cc0aecc3"
            
    static let ownerData = TestAccountInfo.LUMAN
    
    static let GAS_LIMIT = BigUInt(9_000_000)
    static let GAS_PRICE = BigUInt(4_100_000_000)
    
    override func setUpWithError() throws {
        if !ContractTest.contractAddress.isEmpty {
            return
        }
        
        do {
            if let file  = Bundle.module.url(forResource: "ContractTestData", withExtension: "json"){
                let data  = try Data(contentsOf: file)
                let json = try JSONDecoder().decode(JSON.self, from:data)
                ContractTest.BINARY = json["BINARY"]?.stringValue ?? ""
                let jsonObj = try JSONEncoder().encode(json["jsonObj"])
                ContractTest.jsonObj = String(data: jsonObj, encoding: .utf8)!
            }else{
                print("no file")
            }
        } catch {
            print(error.localizedDescription)
        }
        
        let caver = Caver(Caver.DEFAULT_URL)
        _ = try! caver.wallet.add(try! KeyringFactory.createFromPrivateKey(ContractTest.ownerData.privateKey))

        let name = "KlayTN"
        let symbol = "KCT"
        let decimals = BigInt(18)
        let initialSupply = BigInt(100_000) * (BigInt(10).power(decimals.int)) // 100000 * 10^18

        let constructorParams: [Any] = [
            name,
            symbol,
            decimals,
            initialSupply
        ]

        let options = SendOptions(ContractTest.ownerData.address, ContractTest.GAS_LIMIT)
        let contractDeployParam = try ContractDeployParams(ContractTest.BINARY, constructorParams)
        let contract = try Contract(caver, ContractTest.jsonObj)
        _ = try contract.deploy(contractDeployParam, options)
        ContractTest.contractAddress = contract.contractAddress!
        
        sleep(1)
    }
    
    func deploy(_ caver: Caver) throws -> Contract {
        let name = "KlayTN"
        let symbol = "KCT"
        let decimals = BigInt(18)
        let initialSupply = BigInt(100_000) * (BigInt(10).power(decimals.int)) // 100000 * 10^18

        let constructorParams: [Any] = [
            name,
            symbol,
            decimals,
            initialSupply
        ]

        let options = SendOptions(ContractTest.ownerData.address, ContractTest.GAS_LIMIT)
        let contractDeployParam = try ContractDeployParams(ContractTest.BINARY, constructorParams)
        let contract = try Contract(caver, ContractTest.jsonObj)
        _ = try contract.deploy(contractDeployParam, options)
        return contract
    }

    func test_deployTest() throws {
        let caver = Caver(Caver.DEFAULT_URL)
        _ = try! caver.wallet.add(try! KeyringFactory.createFromPrivateKey(ContractTest.ownerData.privateKey))
        
        let name = "KlayTN"
        let symbol = "KCT"
        let decimals = BigInt(18)
        let initialSupply = BigInt(100_000) * (BigInt(10).power(decimals.int)) // 100000 * 10^18

        let constructorParams: [Any] = [
            name,
            symbol,
            decimals,
            initialSupply
        ]

        let options = SendOptions(ContractTest.ownerData.address, ContractTest.GAS_LIMIT)
        let contractDeployParam = try ContractDeployParams(ContractTest.BINARY, constructorParams)
        let contract = try Contract(caver, ContractTest.jsonObj)
        _ = try contract.deploy(contractDeployParam, options)
        XCTAssertNotNil(contract.contractAddress)        
        ContractTest.contractAddress = contract.contractAddress!
    }
    
    func test_getMethodTest() throws {
        let caver = Caver(Caver.DEFAULT_URL)
        let contract = try Contract(caver, ContractTest.jsonObj, ContractTest.contractAddress)
        
        XCTAssertNotNil(try contract.getMethod("symbol"))
    }
    
    func test_getMethodTest_noExisted() throws {
        let caver = Caver(Caver.DEFAULT_URL)
        let contract = try Contract(caver, ContractTest.jsonObj, ContractTest.contractAddress)

        XCTAssertThrowsError(try contract.getMethod("noMethod")) {
            XCTAssertEqual($0 as? CaverError, CaverError.NullPointerException("noMethod method is not exist."))
        }
    }

    func test_getEventTest() throws {
        let caver = Caver(Caver.DEFAULT_URL)
        let contract = try Contract(caver, ContractTest.jsonObj, ContractTest.contractAddress)

        XCTAssertNotNil(try contract.getEvent("Transfer"))
    }

    func test_getEventTest_noExisted() throws {
        let caver = Caver(Caver.DEFAULT_URL)
        let contract = try Contract(caver, ContractTest.jsonObj, ContractTest.contractAddress)

        XCTAssertThrowsError(try contract.getEvent("noEvent")) {
            XCTAssertEqual($0 as? CaverError, CaverError.NullPointerException("noEvent event is not exist."))
        }
    }
    
    func test_call() throws {
        let caver = Caver(Caver.DEFAULT_URL)
        let contract = try Contract(caver, ContractTest.jsonObj, ContractTest.contractAddress)
        let callObject = CallObject.createCallObject(
            ContractTest.ownerData.address,
            ContractTest.contractAddress)
        
        guard let result = try contract.getMethod("symbol").call(nil, callObject)
        else { XCTAssert(false)
            return }
        let symbol = result[0].value as! String
        XCTAssertEqual("KCT", symbol)
    }
    
    func test_callWithNoCallObject() throws {
        let caver = Caver(Caver.DEFAULT_URL)
        let contract = try Contract(caver, ContractTest.jsonObj, ContractTest.contractAddress)
        
        guard let result = try contract.getMethod("symbol").call(nil)
        else { XCTAssert(false)
            return }
        let symbol = result[0].value as! String
        XCTAssertEqual("KCT", symbol)
    }
    
    func test_send() throws {
        let caver = Caver(Caver.DEFAULT_URL)
        _ = try caver.wallet.add(KeyringFactory.createFromPrivateKey(ContractTest.ownerData.privateKey))
        let contract = try Contract(caver, ContractTest.jsonObj, ContractTest.contractAddress)
        let sendOptions = SendOptions(ContractTest.ownerData.address, ContractTest.GAS_LIMIT)
        
        let callParams = [TestAccountInfo.BRANDON.address]
        guard let list = try contract.getMethod("balanceOf").call(callParams, CallObject.createCallObject())
        else { XCTAssert(false)
            return }
        let balance = list[0].value as! BigUInt
        let amount = BigUInt(1) * BigUInt(10).power(17)
        let functionParams: [Any] = [TestAccountInfo.BRANDON.address, amount]
        
        let _ = try contract.getMethod("transfer").send(functionParams, sendOptions)
        guard let result = try contract.getMethod("balanceOf").call(callParams, CallObject.createCallObject())
        else { XCTAssert(false)
            return }
        XCTAssertEqual(balance + amount, result[0].value as! BigUInt)
    }
    
    func test_sendWithInvalidFrom() throws {
        let caver = Caver(Caver.DEFAULT_URL)
        _ = try caver.wallet.add(KeyringFactory.createFromPrivateKey(ContractTest.ownerData.privateKey))
        let contract = try Contract(caver, ContractTest.jsonObj, ContractTest.contractAddress)
        let sendOptions = SendOptions(nil, ContractTest.GAS_LIMIT)
        
        let amount = BigUInt(1) * BigUInt(10).power(17)
        let functionParams: [Any] = [TestAccountInfo.BRANDON.address, amount]

        XCTAssertThrowsError(try contract.getMethod("transfer").send(functionParams, sendOptions)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid 'from' parameter : "))
        }
    }
    
    func test_sendWithInvalidGas() throws {
        let caver = Caver(Caver.DEFAULT_URL)
        _ = try caver.wallet.add(KeyringFactory.createFromPrivateKey(ContractTest.ownerData.privateKey))
        let contract = try Contract(caver, ContractTest.jsonObj, ContractTest.contractAddress)
        let sendOptions = SendOptions(TestAccountInfo.LUMAN.address, nil)
        
        let amount = BigUInt(1) * BigUInt(10).power(17)
        let functionParams: [Any] = [TestAccountInfo.BRANDON.address, amount]

        XCTAssertThrowsError(try contract.getMethod("transfer").send(functionParams, sendOptions)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid 'gas' parameter : "))
        }
    }
    
    func test_makeSendOptionsOnlyDefaultOption() throws {
        let caver = Caver(Caver.DEFAULT_URL)
        _ = try caver.wallet.add(KeyringFactory.createFromPrivateKey(ContractTest.ownerData.privateKey))
        let contract = try Contract(caver, ContractTest.jsonObj, ContractTest.contractAddress)
        try contract.defaultSendOptions?.setFrom(TestAccountInfo.LUMAN.address)
        try contract.defaultSendOptions?.setGas(ContractTest.GAS_LIMIT)

        let combineOptions = try contract.getMethod("transfer").makeSendOption(nil)
        XCTAssertEqual(TestAccountInfo.LUMAN.address, combineOptions.from)
        XCTAssertEqual(ContractTest.GAS_LIMIT.hexa, combineOptions.gas)
        XCTAssertEqual("0x0", combineOptions.value)
    }
    
    func test_makeSendOptionNoDefaultOption() throws {
        let caver = Caver(Caver.DEFAULT_URL)
        _ = try caver.wallet.add(KeyringFactory.createFromPrivateKey(ContractTest.ownerData.privateKey))
        let contract = try Contract(caver, ContractTest.jsonObj, ContractTest.contractAddress)
        let options = SendOptions(TestAccountInfo.LUMAN.address, ContractTest.GAS_LIMIT)

        let combineOptions = try contract.getMethod("transfer").makeSendOption(options)
        XCTAssertEqual(TestAccountInfo.LUMAN.address, combineOptions.from)
        XCTAssertEqual(ContractTest.GAS_LIMIT.hexa, combineOptions.gas)
        XCTAssertEqual("0x0", combineOptions.value)
    }
    
    func test_makeSendOptionCombineOptions() throws {
        let caver = Caver(Caver.DEFAULT_URL)
        _ = try caver.wallet.add(KeyringFactory.createFromPrivateKey(ContractTest.ownerData.privateKey))
        let contract = try Contract(caver, ContractTest.jsonObj, ContractTest.contractAddress)
        try contract.defaultSendOptions?.setFrom(TestAccountInfo.BRANDON.address)
        
        let options = SendOptions()
        try options.setGas(ContractTest.GAS_LIMIT)

        let combineOptions = try contract.getMethod("transfer").makeSendOption(options)
        XCTAssertEqual(TestAccountInfo.BRANDON.address, combineOptions.from)
        XCTAssertEqual(ContractTest.GAS_LIMIT.hexa, combineOptions.gas)
        XCTAssertEqual("0x0", combineOptions.value)
    }
    
    func test_estimateGas() throws {
        let caver = Caver(Caver.DEFAULT_URL)
        _ = try caver.wallet.add(KeyringFactory.createFromPrivateKey(ContractTest.ownerData.privateKey))
        let contract = try Contract(caver, ContractTest.jsonObj, ContractTest.contractAddress)
                
        let amount = BigUInt(1) * BigUInt(10).power(17)
        let sendParams: [Any] = [TestAccountInfo.BRANDON.address, amount]

        let gas = try contract.getMethod("transfer").estimateGas(sendParams, CallObject.createCallObject(ContractTest.ownerData.address))
        XCTAssertTrue(BigInt(hex: gas)! > BigInt(0))
    }
    
    func test_getPastEvent() throws {
        let caver = Caver(Caver.DEFAULT_URL)
        _ = try caver.wallet.add(KeyringFactory.createFromPrivateKey(ContractTest.ownerData.privateKey))
        let contract = try deploy(caver)
        
        let filter = KlayLogFilter(.Earliest, .Latest, ContractTest.contractAddress, "")
        let logs = try contract.getPastEvent("Transfer", filter)
        
        let logResults = logs.getLogs()
        guard let log = logResults[0] as? KlayLogs.Log,
              let data = log.data,
              let topics = log.topics
        else { XCTAssert(false)
            return }
        
        let eventValues = try ABI.decodeLog(try contract.getEvent("Transfer").inputs, data, topics)
        
        XCTAssertEqual(2, eventValues.indexedValues.count)
        XCTAssertEqual(1, eventValues.nonIndexedValues.count)
        
        let value = BigUInt(100_000) * BigUInt(10).power(18)
        XCTAssertEqual((eventValues.indexedValues[0].value as? Address)?.toValue, "0x0000000000000000000000000000000000000000")
        XCTAssertEqual((eventValues.indexedValues[1].value as? Address)?.toValue, ContractTest.ownerData.address)
        XCTAssertEqual(eventValues.nonIndexedValues[0].value as? BigUInt, value)
    }
    
    @available(iOS 13.0, *)
    func test_onceTest() throws {
        let expectation = XCTestExpectation(description: "timeout")
        
        let webSocketService = WebSocketService(Caver.DEFAULT_URL_SOCKET)
        let caver = Caver(webSocketService)
        webSocketService.connect()
        
        _ = try caver.wallet.add(KeyringFactory.createFromPrivateKey("0x2359d1ae7317c01532a58b01452476b796a3ac713336e97d8d3c9651cc0aecc3"))
        _ = try caver.wallet.add(KeyringFactory.createFromPrivateKey("0x734aa75ef35fd4420eea2965900e90040b8b9f9f7484219b1a06d06394330f4e"))
        
        let contract = try Contract(caver, ContractTest.jsonObj, ContractTest.contractAddress)
                
        let indexedParameter = EventFilterOptions.IndexedParameter("from", [TestAccountInfo.LUMAN.address])
        let eventFilterOptions = EventFilterOptions([indexedParameter], [])
        
        var log: KlayLogs.Log?
        try contract.once("Transfer", eventFilterOptions) {
            guard let logResults = $0?.getLogs()
            else { XCTAssert(false)
                return }
            
            log = logResults[0] as? KlayLogs.Log
            expectation.fulfill()
        }
        
        let amount = BigUInt(1) * BigUInt(10).power(18)
        let sendParams: [Any] = [TestAccountInfo.BRANDON.address, amount]
        let sendOptions = SendOptions(TestAccountInfo.LUMAN.address, ContractTest.GAS_LIMIT)
        _ = try contract.getMethod("transfer").send(sendParams, sendOptions)
        
        let result = XCTWaiter.wait(for: [expectation], timeout: 60.0)
        XCTAssertEqual(result, .completed)
        
        XCTAssertEqual(3, log?.topics?.count)
        XCTAssertEqual("0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef", log?.topics?[0])
        XCTAssertEqual("0x0000000000000000000000002c8ad0ea2e0781db8b8c9242e07de3a5beabb71a", log?.topics?[1])
        XCTAssertEqual("0x000000000000000000000000e97f27e9a5765ce36a7b919b1cb6004c7209217e", log?.topics?[2])
        
        webSocketService.close()
    }
    
    @available(iOS 13.0, *)
    func test_onceTest2() throws {
        let expectation = XCTestExpectation(description: "timeout")
        
        let webSocketService = WebSocketService(Caver.DEFAULT_URL_SOCKET)
        let caver = Caver(webSocketService)
        webSocketService.connect()
        
        _ = try caver.wallet.add(KeyringFactory.createFromPrivateKey("0x2359d1ae7317c01532a58b01452476b796a3ac713336e97d8d3c9651cc0aecc3"))
        _ = try caver.wallet.add(KeyringFactory.createFromPrivateKey("0x734aa75ef35fd4420eea2965900e90040b8b9f9f7484219b1a06d06394330f4e"))
        
        let contract = try Contract(caver, ContractTest.jsonObj, ContractTest.contractAddress)
        
        let indexedParameter = EventFilterOptions.IndexedParameter("to", [TestAccountInfo.BRANDON.address])
        let eventFilterOptions = EventFilterOptions([indexedParameter], [])
        
        var log: KlayLogs.Log?
        try contract.once("Transfer", eventFilterOptions) {
            guard let logResults = $0?.getLogs()
            else { XCTAssert(false)
                return }
            
            log = logResults[0] as? KlayLogs.Log
            expectation.fulfill()
        }
        
        let amount = BigUInt(1) * BigUInt(10).power(18)
        let sendParams: [Any] = [TestAccountInfo.BRANDON.address, amount]
        let sendOptions = SendOptions(TestAccountInfo.LUMAN.address, ContractTest.GAS_LIMIT)
        _ = try contract.getMethod("transfer").send(sendParams, sendOptions)
        
        let result = XCTWaiter.wait(for: [expectation], timeout: 60.0)
        XCTAssertEqual(result, .completed)
        
        XCTAssertEqual(3, log?.topics?.count)
        XCTAssertEqual("0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef", log?.topics?[0])
        XCTAssertEqual("0x0000000000000000000000002c8ad0ea2e0781db8b8c9242e07de3a5beabb71a", log?.topics?[1])
        XCTAssertEqual("0x000000000000000000000000e97f27e9a5765ce36a7b919b1cb6004c7209217e", log?.topics?[2])
        
        webSocketService.close()
    }
    
    @available(iOS 13.0, *)
    func test_onceTest_multiOptions() throws {
        let expectation = XCTestExpectation(description: "timeout")
        
        let webSocketService = WebSocketService(Caver.DEFAULT_URL_SOCKET)
        let caver = Caver(webSocketService)
        webSocketService.connect()
        
        _ = try caver.wallet.add(KeyringFactory.createFromPrivateKey("0x2359d1ae7317c01532a58b01452476b796a3ac713336e97d8d3c9651cc0aecc3"))
        _ = try caver.wallet.add(KeyringFactory.createFromPrivateKey("0x734aa75ef35fd4420eea2965900e90040b8b9f9f7484219b1a06d06394330f4e"))
        
        let contract = try Contract(caver, ContractTest.jsonObj, ContractTest.contractAddress)
        
        let indexedParameter = EventFilterOptions.IndexedParameter("from", [TestAccountInfo.LUMAN.address])
        let indexedParameter1 = EventFilterOptions.IndexedParameter("to", [TestAccountInfo.BRANDON.address])
        let eventFilterOptions = EventFilterOptions([indexedParameter, indexedParameter1], [])
        
        var log: KlayLogs.Log?
        try contract.once("Transfer", eventFilterOptions) {
            guard let logResults = $0?.getLogs()
            else { XCTAssert(false)
                return }
            
            log = logResults[0] as? KlayLogs.Log
            expectation.fulfill()
        }
        
        let amount = BigUInt(1) * BigUInt(10).power(18)
        let sendParams: [Any] = [TestAccountInfo.BRANDON.address, amount]
        let sendOptions = SendOptions(TestAccountInfo.LUMAN.address, ContractTest.GAS_LIMIT)
        _ = try contract.getMethod("transfer").send(sendParams, sendOptions)
        
        let result = XCTWaiter.wait(for: [expectation], timeout: 60.0)
        XCTAssertEqual(result, .completed)
        
        XCTAssertEqual(3, log?.topics?.count)
        XCTAssertEqual("0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef", log?.topics?[0])
        XCTAssertEqual("0x0000000000000000000000002c8ad0ea2e0781db8b8c9242e07de3a5beabb71a", log?.topics?[1])
        XCTAssertEqual("0x000000000000000000000000e97f27e9a5765ce36a7b919b1cb6004c7209217e", log?.topics?[2])
        
        webSocketService.close()
    }
    
    @available(iOS 13.0, *)
    func test_onceTest4_OR_Options() throws {
        let expectation = XCTestExpectation(description: "timeout")
        
        let webSocketService = WebSocketService(Caver.DEFAULT_URL_SOCKET)
        let caver = Caver(webSocketService)
        webSocketService.connect()
        
        _ = try caver.wallet.add(KeyringFactory.createFromPrivateKey("0x2359d1ae7317c01532a58b01452476b796a3ac713336e97d8d3c9651cc0aecc3"))
        _ = try caver.wallet.add(KeyringFactory.createFromPrivateKey("0x734aa75ef35fd4420eea2965900e90040b8b9f9f7484219b1a06d06394330f4e"))
        
        let contract = try Contract(caver, ContractTest.jsonObj, ContractTest.contractAddress)
        
        let indexedParameter = EventFilterOptions.IndexedParameter("from", [TestAccountInfo.LUMAN.address, TestAccountInfo.BRANDON.address])
        let eventFilterOptions = EventFilterOptions([indexedParameter, indexedParameter], [])
        
        var log: KlayLogs.Log?
        try contract.once("Transfer", eventFilterOptions) {
            guard let logResults = $0?.getLogs()
            else { XCTAssert(false)
                return }
            
            log = logResults[0] as? KlayLogs.Log
            expectation.fulfill()
        }
        
        let amount = BigUInt(1) * BigUInt(10).power(18)
        let sendParams: [Any] = [TestAccountInfo.BRANDON.address, amount]
        let sendOptions = SendOptions(TestAccountInfo.LUMAN.address, ContractTest.GAS_LIMIT)
        _ = try contract.getMethod("transfer").send(sendParams, sendOptions)
        
        let result = XCTWaiter.wait(for: [expectation], timeout: 60.0)
        XCTAssertEqual(result, .completed)
        
        XCTAssertEqual(3, log?.topics?.count)
        XCTAssertEqual("0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef", log?.topics?[0])
        XCTAssertEqual("0x0000000000000000000000002c8ad0ea2e0781db8b8c9242e07de3a5beabb71a", log?.topics?[1])
        XCTAssertEqual("0x000000000000000000000000e97f27e9a5765ce36a7b919b1cb6004c7209217e", log?.topics?[2])
        
        webSocketService.close()
    }
    
    @available(iOS 13.0, *)
    func test_onceTest5_OR_Options2() throws {
        let expectation = XCTestExpectation(description: "timeout")
        
        let webSocketService = WebSocketService(Caver.DEFAULT_URL_SOCKET)
        let caver = Caver(webSocketService)
        webSocketService.connect()
        
        _ = try caver.wallet.add(KeyringFactory.createFromPrivateKey("0x2359d1ae7317c01532a58b01452476b796a3ac713336e97d8d3c9651cc0aecc3"))
        _ = try caver.wallet.add(KeyringFactory.createFromPrivateKey("0x734aa75ef35fd4420eea2965900e90040b8b9f9f7484219b1a06d06394330f4e"))
        
        let contract = try Contract(caver, ContractTest.jsonObj, ContractTest.contractAddress)
        
        let indexedParameter = EventFilterOptions.IndexedParameter("to", [TestAccountInfo.WAYNE.address, TestAccountInfo.BRANDON.address])
        let eventFilterOptions = EventFilterOptions([indexedParameter, indexedParameter], [])
        
        var log: KlayLogs.Log?
        try contract.once("Transfer", eventFilterOptions) {
            guard let logResults = $0?.getLogs()
            else { XCTAssert(false)
                return }
            
            log = logResults[0] as? KlayLogs.Log
            expectation.fulfill()
        }
        
        let amount = BigUInt(1) * BigUInt(10).power(18)
        let sendParams: [Any] = [TestAccountInfo.WAYNE.address, amount]
        let sendOptions = SendOptions(TestAccountInfo.LUMAN.address, ContractTest.GAS_LIMIT)
        _ = try contract.getMethod("transfer").send(sendParams, sendOptions)
        
        let result = XCTWaiter.wait(for: [expectation], timeout: 60.0)
        XCTAssertEqual(result, .completed)
        
        XCTAssertEqual(3, log?.topics?.count)
        XCTAssertEqual("0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef", log?.topics?[0])
        XCTAssertEqual("0x0000000000000000000000002c8ad0ea2e0781db8b8c9242e07de3a5beabb71a", log?.topics?[1])
        XCTAssertEqual("0x0000000000000000000000003cd93ba290712e6d28ac98f2b820faf799ae8fdb", log?.topics?[2])
        
        webSocketService.close()
    }
    
    @available(iOS 13.0, *)
    func test_onceTest_allEvents() throws {
        let expectation = XCTestExpectation(description: "timeout")
        
        let webSocketService = WebSocketService(Caver.DEFAULT_URL_SOCKET)
        let caver = Caver(webSocketService)
        webSocketService.connect()
        
        _ = try caver.wallet.add(KeyringFactory.createFromPrivateKey("0x2359d1ae7317c01532a58b01452476b796a3ac713336e97d8d3c9651cc0aecc3"))
        _ = try caver.wallet.add(KeyringFactory.createFromPrivateKey("0x734aa75ef35fd4420eea2965900e90040b8b9f9f7484219b1a06d06394330f4e"))
        
        let contract = try Contract(caver, ContractTest.jsonObj, ContractTest.contractAddress)
        
        let indexedParameter = EventFilterOptions.IndexedParameter("to", [TestAccountInfo.WAYNE.address, TestAccountInfo.BRANDON.address])
        let eventFilterOptions = EventFilterOptions([indexedParameter, indexedParameter], [])
        
        var log: KlayLogs.Log?
        try contract.once("allEvents", eventFilterOptions) {
            guard let logResults = $0?.getLogs()
            else { XCTAssert(false)
                return }
            
            log = logResults[0] as? KlayLogs.Log
            expectation.fulfill()
        }
        
        let amount = BigUInt(1) * BigUInt(10).power(18)
        let sendParams: [Any] = [TestAccountInfo.WAYNE.address, amount]
        let sendOptions = SendOptions(TestAccountInfo.LUMAN.address, ContractTest.GAS_LIMIT)
        _ = try contract.getMethod("transfer").send(sendParams, sendOptions)
        
        let result = XCTWaiter.wait(for: [expectation], timeout: 60.0)
        XCTAssertEqual(result, .completed)
        
        XCTAssertEqual(3, log?.topics?.count)
        XCTAssertEqual("0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef", log?.topics?[0])
        XCTAssertEqual("0x0000000000000000000000002c8ad0ea2e0781db8b8c9242e07de3a5beabb71a", log?.topics?[1])
        XCTAssertEqual("0x0000000000000000000000003cd93ba290712e6d28ac98f2b820faf799ae8fdb", log?.topics?[2])
        
        webSocketService.close()
    }
    
    func test_setWallet() throws {
        let caver = Caver(Caver.DEFAULT_URL)
        let contract = try Contract(caver, ContractTest.jsonObj, ContractTest.contractAddress)
        
        XCTAssertEqual(0, (contract.wallet as? KeyringContainer)?.count)
        
        let container = KeyringContainer()
        _ = try container.generate(3)
        
        contract.wallet = container
        XCTAssertEqual(3, (contract.wallet as? KeyringContainer)?.count)
    }
}
