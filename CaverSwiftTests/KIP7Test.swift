//
//  KIP7Test.swift
//  CaverSwiftTests
//
//  Created by won on 2021/07/26.
//

import XCTest
@testable import CaverSwift
@testable import GenericJSON

class KIP7Test: XCTestCase {
    public static var kip7contract: KIP7?
    public static let CONTRACT_NAME = "KlayTN"
    public static let CONTRACT_SYMBOL = "KCT"
    public static let CONTRACT_DECIMALS = 18
    public static let CONTRACT_INITIAL_SUPPLY = BigUInt(100_000) * (BigUInt(10).power(CONTRACT_DECIMALS))
    
    public static func deployContract() {
        let caver = Caver(Caver.DEFAULT_URL)
        _ = try! caver.wallet.add(try! KeyringFactory.createFromPrivateKey("0x2359d1ae7317c01532a58b01452476b796a3ac713336e97d8d3c9651cc0aecc3"))
        _ = try! caver.wallet.add(try! KeyringFactory.createFromPrivateKey("0x734aa75ef35fd4420eea2965900e90040b8b9f9f7484219b1a06d06394330f4e"))
        
        let kip7DeployParam = KIP7DeployParams(CONTRACT_NAME, CONTRACT_SYMBOL, CONTRACT_DECIMALS, CONTRACT_INITIAL_SUPPLY)
        KIP7Test.kip7contract = try? KIP7.deploy(caver, kip7DeployParam, TestAccountInfo.LUMAN.address)
    }
}

class KIP7Test_ConstructorTest: XCTestCase {
    public var kip7contract: KIP7?
    
    override func setUpWithError() throws {
        if KIP7Test.kip7contract == nil {
            KIP7Test.deployContract()
        }
        
        kip7contract = KIP7Test.kip7contract
    }
    
    func test_deploy() throws {
        let caver = Caver(Caver.DEFAULT_URL)
        _ = try! caver.wallet.add(try! KeyringFactory.createFromPrivateKey("0x2359d1ae7317c01532a58b01452476b796a3ac713336e97d8d3c9651cc0aecc3"))
        let contract = try? KIP7.deploy(caver, TestAccountInfo.LUMAN.address, KIP7Test.CONTRACT_NAME, KIP7Test.CONTRACT_SYMBOL, KIP7Test.CONTRACT_DECIMALS, KIP7Test.CONTRACT_INITIAL_SUPPLY)
        
        XCTAssertNotNil(contract)
    }
    
    func test_name() throws {
        let name = try kip7contract?.name()
        XCTAssertEqual(KIP7Test.CONTRACT_NAME, name)
    }
    
    func test_symbol() throws {
        let symbol = try kip7contract?.symbol()
        XCTAssertEqual(KIP7Test.CONTRACT_SYMBOL, symbol)
    }
    
    func test_decimals() throws {
        let decimals = try kip7contract?.decimals()
        XCTAssertEqual(KIP7Test.CONTRACT_DECIMALS, decimals)
    }
    
    func test_totalSupply() throws {
        let totalSupply = try kip7contract?.totalSupply()
        XCTAssertEqual(KIP7Test.CONTRACT_INITIAL_SUPPLY, totalSupply)
    }
    
    func test_cloneTestWithSetWallet() throws {
        let caver = Caver(Caver.DEFAULT_URL)
        let kip7 = try KIP7(caver)
        
        let container = KeyringContainer()
        _ = try container.generate(3)
        
        kip7.wallet = container
        let cloned = kip7.clone()
        
        XCTAssertEqual(3, (cloned?.wallet as? KeyringContainer)?.count)
    }
}

class KIP7Test_PausableTest: XCTestCase {
    public var kip7contract: KIP7?
    
    override func setUpWithError() throws {
        if KIP7Test.kip7contract == nil {
            KIP7Test.deployContract()
        }
        
        kip7contract = KIP7Test.kip7contract
        guard let kip7contract = kip7contract else {
            XCTAssert(false)
            return
        }
        kip7contract.setDefaultSendOptions(SendOptions())
        guard let paused = try? kip7contract.paused() else {
            XCTAssert(false)
            return
        }
        if paused {
            let options = SendOptions(TestAccountInfo.LUMAN.address, BigUInt(4000000))
            _ = try kip7contract.unpause(options)
        }
    }
    
    func test_pause() throws {
        let options = SendOptions(TestAccountInfo.LUMAN.address, BigUInt(4000000))
        _ = try kip7contract?.pause(options)
        XCTAssertTrue(try kip7contract?.paused() ?? false)
    }
    
    func test_pausedDefaultOptions() throws {
        let options = SendOptions(TestAccountInfo.LUMAN.address, BigUInt(4000000))
        kip7contract?.setDefaultSendOptions(options)
        _ = try kip7contract?.pause()
        XCTAssertTrue(try kip7contract?.paused() ?? false)
    }
    
    func test_pausedNoDefaultGas() throws {
        try kip7contract?.defaultSendOptions?.setFrom(TestAccountInfo.LUMAN.address)
        _ = try kip7contract?.pause()
        XCTAssertTrue(try kip7contract?.paused() ?? false)
    }
    
    func test_pausedNoGas() throws {
        let options = SendOptions(TestAccountInfo.LUMAN.address)
        _ = try kip7contract?.pause(options)
        XCTAssertTrue(try kip7contract?.paused() ?? false)
    }
    
    func test_unPause() throws {
        let options = SendOptions(TestAccountInfo.LUMAN.address, BigUInt(4000000))
        _ = try kip7contract?.pause(options)
        XCTAssertTrue(try kip7contract?.paused() ?? false)
        
        _ = try kip7contract?.unpause(options)
        XCTAssertFalse(try kip7contract?.paused() ?? true)
    }
    
    func test_addPauser() throws {
        let options = SendOptions(TestAccountInfo.LUMAN.address, BigUInt(4000000))
        _ = try kip7contract?.addPauser(TestAccountInfo.BRANDON.address, options)
        XCTAssertTrue(try kip7contract?.isPauser(TestAccountInfo.BRANDON.address) ?? false)
    }
    
    func test_renouncePauser() throws {
        guard let isPauser = try kip7contract?.isPauser(TestAccountInfo.BRANDON.address) else {
            XCTAssert(false)
            return
        }
        if !isPauser {
            let options = SendOptions(TestAccountInfo.LUMAN.address, BigUInt(4000000))
            _ = try kip7contract?.addPauser(TestAccountInfo.BRANDON.address, options)
        }
        
        let options = SendOptions(TestAccountInfo.BRANDON.address, BigUInt(4000000))
        _ = try kip7contract?.renouncePauser(options)
        
        XCTAssertFalse(try kip7contract?.isPauser(TestAccountInfo.BRANDON.address) ?? true)
    }
    
    func test_paused() throws {
        XCTAssertFalse(try kip7contract?.paused() ?? true)
    }
}

class KIP7Test_BurnableTest: XCTestCase {
    public var kip7contract: KIP7?
    
    override func setUpWithError() throws {
        if KIP7Test.kip7contract == nil {
            KIP7Test.deployContract()
        }
        
        kip7contract = KIP7Test.kip7contract
    }
    
    func test_burn() throws {
        let sendOptions = SendOptions(TestAccountInfo.LUMAN.address)
        guard let totalSupply = try kip7contract?.totalSupply(),
              let burnAmount = BigUInt(Utils.convertToPeb("1", "KLAY")) else {
            XCTAssert(false)
            return
        }
        _ = try kip7contract?.burn(burnAmount, sendOptions)

        let afterSupply = try kip7contract?.totalSupply()
        
        XCTAssertEqual(afterSupply, totalSupply - burnAmount)
    }
    
    func test_burnFrom() throws {
        let sendOptions = SendOptions(TestAccountInfo.LUMAN.address)
        guard let beforeBalance = try kip7contract?.balanceOf(TestAccountInfo.LUMAN.address),
              let burnAmount = BigUInt(Utils.convertToPeb("1", "KLAY")) else {
            XCTAssert(false)
            return
        }

        _ = try kip7contract?.approve(TestAccountInfo.BRANDON.address, burnAmount, sendOptions)

        _ = try kip7contract?.burnFrom(TestAccountInfo.LUMAN.address, burnAmount, SendOptions(TestAccountInfo.BRANDON.address))
        let afterBalance = try kip7contract?.balanceOf(TestAccountInfo.LUMAN.address)
        
        XCTAssertEqual(afterBalance, beforeBalance - burnAmount)
    }
}

class KIP7Test_MintableTest: XCTestCase {
    public var kip7contract: KIP7?
    
    override func setUpWithError() throws {
        if KIP7Test.kip7contract == nil {
            KIP7Test.deployContract()
        }
        
        kip7contract = KIP7Test.kip7contract
    }
    
    func test_mint() throws {
        let sendOptions = SendOptions(TestAccountInfo.LUMAN.address)
        guard let beforeTotalSupply = try kip7contract?.totalSupply(),
              let mintAmount = BigUInt(Utils.convertToPeb("1", "KLAY")) else {
            XCTAssert(false)
            return
        }
        
        _ = try kip7contract?.mint(TestAccountInfo.LUMAN.address, mintAmount, sendOptions)

        let afterTotalSupply = try kip7contract?.totalSupply()
        
        XCTAssertEqual(afterTotalSupply, beforeTotalSupply + mintAmount)
    }
    
    func test_isMinter() throws {
        XCTAssertTrue(try kip7contract?.isMinter(TestAccountInfo.LUMAN.address) ?? false)
    }
    
    func test_addMinter() throws {
        if try kip7contract?.isMinter(TestAccountInfo.BRANDON.address) ?? false {
            let sendOptions = SendOptions(TestAccountInfo.BRANDON.address)
            _ = try kip7contract?.renounceMinter(sendOptions)
        }
        
        let sendOptions = SendOptions(TestAccountInfo.LUMAN.address)
        _ = try kip7contract?.addMinter(TestAccountInfo.BRANDON.address, sendOptions)
        
        XCTAssertTrue(try kip7contract?.isMinter(TestAccountInfo.BRANDON.address) ?? false)
    }
    
    func test_renounceMinter() throws {
        if !(try kip7contract?.isMinter(TestAccountInfo.BRANDON.address) ?? true) {
            let sendOptions = SendOptions(TestAccountInfo.LUMAN.address)
            _ = try kip7contract?.addMinter(TestAccountInfo.BRANDON.address, sendOptions)
        }
        
        let sendOptions = SendOptions(TestAccountInfo.BRANDON.address)
        _ = try kip7contract?.renounceMinter(sendOptions)
        
        XCTAssertFalse(try kip7contract?.isMinter(TestAccountInfo.BRANDON.address) ?? true)
    }
    
}

class KIP7Test_CommonTest: XCTestCase {
    public var kip7contract: KIP7?
    
    override func setUpWithError() throws {
        if KIP7Test.kip7contract == nil {
            KIP7Test.deployContract()
        }
        
        kip7contract = KIP7Test.kip7contract
    }
    
    func test_balanceOf() throws {
        XCTAssertNotNil(try kip7contract?.balanceOf(TestAccountInfo.LUMAN.address) ?? false)
    }
    
    func test_allowance() throws {
        let allowance = try kip7contract?.allowance(TestAccountInfo.LUMAN.address, TestAccountInfo.WAYNE.address)
        XCTAssertEqual(allowance, BigUInt(0))
    }
    
    func test_approve() throws {
        guard let allowance = try kip7contract?.allowance(TestAccountInfo.LUMAN.address, TestAccountInfo.BRANDON.address) else {
            XCTAssert(false)
            return
        }
        let sendOptions = SendOptions(TestAccountInfo.LUMAN.address)
        let approveAmount = BigUInt(1) * (BigUInt(10).power(KIP7Test.CONTRACT_DECIMALS))

        _ = try kip7contract?.approve(TestAccountInfo.BRANDON.address, approveAmount, sendOptions)

        let afterAllowance = try kip7contract?.allowance(TestAccountInfo.LUMAN.address, TestAccountInfo.BRANDON.address)
        XCTAssertEqual(afterAllowance, allowance + approveAmount)
    }
    
    func test_transfer() throws {
        guard let beforeBalance = try kip7contract?.balanceOf(TestAccountInfo.BRANDON.address) else {
            XCTAssert(false)
            return
        }
        let sendOptions = SendOptions(TestAccountInfo.LUMAN.address)
        let transferAmount = BigUInt(1) * (BigUInt(10).power(KIP7Test.CONTRACT_DECIMALS))

        _ = try kip7contract?.transfer(TestAccountInfo.BRANDON.address, transferAmount, sendOptions)

        let afterBalance = try kip7contract?.balanceOf(TestAccountInfo.BRANDON.address)
        XCTAssertEqual(afterBalance, beforeBalance + transferAmount)
    }
    
    func test_transferFrom() throws {
        let ownerOptions = SendOptions(TestAccountInfo.LUMAN.address)
        let allowanceOptions = SendOptions(TestAccountInfo.BRANDON.address)
        let allowAmount = BigUInt(1) * (BigUInt(10).power(KIP7Test.CONTRACT_DECIMALS))
        
        _ = try kip7contract?.approve(TestAccountInfo.BRANDON.address, BigUInt(0), ownerOptions)
        
        _ = try kip7contract?.approve(TestAccountInfo.BRANDON.address, allowAmount, ownerOptions)
        guard let preBalance = try kip7contract?.balanceOf(TestAccountInfo.WAYNE.address) else {
            XCTAssert(false)
            return
        }
        
        _ = try kip7contract?.transferFrom(TestAccountInfo.LUMAN.address, TestAccountInfo.WAYNE.address, allowAmount, allowanceOptions)
        let afterBalance = try kip7contract?.balanceOf(TestAccountInfo.WAYNE.address)
        
        XCTAssertEqual(afterBalance, preBalance + allowAmount)
    }
    
    func test_safeTransfer() throws {
        guard let beforeBalance = try kip7contract?.balanceOf(TestAccountInfo.BRANDON.address) else {
            XCTAssert(false)
            return
        }
        let sendOptions = SendOptions(TestAccountInfo.LUMAN.address)
        let transferAmount = BigUInt(1) * (BigUInt(10).power(KIP7Test.CONTRACT_DECIMALS))

        _ = try kip7contract?.safeTransfer(TestAccountInfo.BRANDON.address, transferAmount, sendOptions)

        let afterBalance = try kip7contract?.balanceOf(TestAccountInfo.BRANDON.address)
        XCTAssertEqual(afterBalance, beforeBalance + transferAmount)
    }
    
    func test_safeTransferWithData() throws {
        let data = "buffered data"
        guard let beforeBalance = try kip7contract?.balanceOf(TestAccountInfo.BRANDON.address) else {
            XCTAssert(false)
            return
        }
        let sendOptions = SendOptions(TestAccountInfo.LUMAN.address)
        let transferAmount = BigUInt(1) * (BigUInt(10).power(KIP7Test.CONTRACT_DECIMALS))

        _ = try kip7contract?.safeTransfer(TestAccountInfo.BRANDON.address, transferAmount, data, sendOptions)

        let afterBalance = try kip7contract?.balanceOf(TestAccountInfo.BRANDON.address)
        XCTAssertEqual(afterBalance, beforeBalance + transferAmount)
    }
    
    func test_safeTransferFrom() throws {
        let ownerOptions = SendOptions(TestAccountInfo.LUMAN.address)
        let allowanceOptions = SendOptions(TestAccountInfo.BRANDON.address)
        let allowAmount = BigUInt(1) * (BigUInt(10).power(KIP7Test.CONTRACT_DECIMALS))
        
        _ = try kip7contract?.approve(TestAccountInfo.BRANDON.address, BigUInt(0), ownerOptions)
        
        _ = try kip7contract?.approve(TestAccountInfo.BRANDON.address, allowAmount, ownerOptions)
        guard let preBalance = try kip7contract?.balanceOf(TestAccountInfo.WAYNE.address) else {
            XCTAssert(false)
            return
        }
        
        _ = try kip7contract?.safeTransferFrom(TestAccountInfo.LUMAN.address, TestAccountInfo.WAYNE.address, allowAmount, allowanceOptions)
        let afterBalance = try kip7contract?.balanceOf(TestAccountInfo.WAYNE.address)
        
        XCTAssertEqual(afterBalance, preBalance + allowAmount)
    }
    
    func test_safeTransferFromWithData() throws {
        let ownerOptions = SendOptions(TestAccountInfo.LUMAN.address)
        let allowanceOptions = SendOptions(TestAccountInfo.BRANDON.address)
        let allowAmount = BigUInt(1) * (BigUInt(10).power(KIP7Test.CONTRACT_DECIMALS))
        let data = "buffered data"
        
        _ = try kip7contract?.approve(TestAccountInfo.BRANDON.address, BigUInt(0), ownerOptions)
        
        _ = try kip7contract?.approve(TestAccountInfo.BRANDON.address, allowAmount, ownerOptions)
        guard let preBalance = try kip7contract?.balanceOf(TestAccountInfo.WAYNE.address) else {
            XCTAssert(false)
            return
        }
        
        _ = try kip7contract?.safeTransferFrom(TestAccountInfo.LUMAN.address, TestAccountInfo.WAYNE.address, allowAmount, data, allowanceOptions)
        let afterBalance = try kip7contract?.balanceOf(TestAccountInfo.WAYNE.address)
        
        XCTAssertEqual(afterBalance, preBalance + allowAmount)
    }
    
    func test_supportsInterface() throws {
        let INTERFACE_ID_KIP13 = "0x01ffc9a7"
        let INTERFACE_ID_KIP7_PAUSABLE = "0x4d5507ff"
        let INTERFACE_ID_KIP7_BURNABLE = "0x3b5a0bf8"
        let INTERFACE_ID_KIP7_MINTABLE = "0xeab83e20"
        let INTERFACE_ID_KIP7_METADATA  = "0xa219a025"
        let INTERFACE_ID_KIP7  = "0x65787371"
        let INTERFACE_ID_FALSE = "0xFFFFFFFF"
        
        let isSupported_KIP13 = try kip7contract?.supportInterface(INTERFACE_ID_KIP13)
        XCTAssertTrue(isSupported_KIP13 ?? false)
        
        let isSupported_KIP7_PAUSABLE = try kip7contract?.supportInterface(INTERFACE_ID_KIP7_PAUSABLE)
        XCTAssertTrue(isSupported_KIP7_PAUSABLE ?? false)
        
        let isSupported_KIP7_BURNABLE = try kip7contract?.supportInterface(INTERFACE_ID_KIP7_BURNABLE)
        XCTAssertTrue(isSupported_KIP7_BURNABLE ?? false)
        
        let isSupported_KIP7_MINTABLE = try kip7contract?.supportInterface(INTERFACE_ID_KIP7_MINTABLE)
        XCTAssertTrue(isSupported_KIP7_MINTABLE ?? false)
        
        let isSupported_KIP7_METADATA = try kip7contract?.supportInterface(INTERFACE_ID_KIP7_METADATA)
        XCTAssertTrue(isSupported_KIP7_METADATA ?? false)
        
        let isSupported_KIP7 = try kip7contract?.supportInterface(INTERFACE_ID_KIP7)
        XCTAssertTrue(isSupported_KIP7 ?? false)
        
        let isSupported_FALSE = try kip7contract?.supportInterface(INTERFACE_ID_FALSE)
        XCTAssertFalse(isSupported_FALSE ?? true)
    }
}

class KIP7Test_DetectInterfaceTest: XCTestCase {
    public var kip7contract: KIP7?
    public var caver: Caver?
    
    public var byteCodeWithMintable = ""
    public var byteCodeWithoutBurnablePausable = ""
    public var byteCodeNotSupportedKIP13 = ""
    
    public var abi_mintable = ""
    public var abi_without_pausable_burnable = ""
    public var abi_not_supported_kip13 = ""
    
    override func setUpWithError() throws {
        if !byteCodeWithMintable.isEmpty {
            return
        }
        
        do {
            if let file  = Bundle(for: type(of: self)).url(forResource: "KIP7TestData", withExtension: "json"){
                let data  = try Data(contentsOf: file)
                let json = try JSONDecoder().decode(JSON.self, from:data)
                byteCodeWithMintable = json["byteCodeWithMintable"]?.stringValue ?? ""
                byteCodeWithoutBurnablePausable = json["byteCodeWithoutBurnablePausable"]?.stringValue ?? ""
                byteCodeNotSupportedKIP13 = json["byteCodeNotSupportedKIP13"]?.stringValue ?? ""
                var jsonObj = try JSONEncoder().encode(json["abi_mintable"])
                abi_mintable = String(data: jsonObj, encoding: .utf8)!
                jsonObj = try JSONEncoder().encode(json["abi_without_pausable_burnable"])
                abi_without_pausable_burnable = String(data: jsonObj, encoding: .utf8)!
                jsonObj = try JSONEncoder().encode(json["abi_not_supported_kip13"])
                abi_not_supported_kip13 = String(data: jsonObj, encoding: .utf8)!
            }else{
                print("no file")
            }
        } catch {
            print(error.localizedDescription)
        }
        
        caver = Caver(Caver.DEFAULT_URL)
        _ = try caver?.wallet.add(KeyringFactory.createFromPrivateKey("0x2359d1ae7317c01532a58b01452476b796a3ac713336e97d8d3c9651cc0aecc3"))
        
        if KIP7Test.kip7contract == nil {
            KIP7Test.deployContract()
        }
        
        kip7contract = KIP7Test.kip7contract
    }
    
    func test_detectInterface() throws {
        guard let result = try kip7contract?.detectInterface() else {
            XCTAssert(false)
            return
        }
        XCTAssertTrue(result[KIP7.INTERFACE.IKIP7.getName()] ?? false)
        XCTAssertTrue(result[KIP7.INTERFACE.IKIP7_BURNABLE.getName()] ?? false)
        XCTAssertTrue(result[KIP7.INTERFACE.IKIP7_METADATA.getName()] ?? false)
        XCTAssertTrue(result[KIP7.INTERFACE.IKIP7_MINTABLE.getName()] ?? false)
        XCTAssertTrue(result[KIP7.INTERFACE.IKIP7_PAUSABLE.getName()] ?? false)
    }
    
    func test_detectInterface_staticMethod() throws {
        guard let kip7contract = kip7contract,
              let result = try? KIP7.detectInterface(kip7contract.caver, kip7contract.contractAddress!) else {
            XCTAssert(false)
            return
        }
        XCTAssertTrue(result[KIP7.INTERFACE.IKIP7.getName()] ?? false)
        XCTAssertTrue(result[KIP7.INTERFACE.IKIP7_BURNABLE.getName()] ?? false)
        XCTAssertTrue(result[KIP7.INTERFACE.IKIP7_METADATA.getName()] ?? false)
        XCTAssertTrue(result[KIP7.INTERFACE.IKIP7_MINTABLE.getName()] ?? false)
        XCTAssertTrue(result[KIP7.INTERFACE.IKIP7_PAUSABLE.getName()] ?? false)
    }
    
    func test_only_mintable() throws {
        let contract = try Contract(caver!, abi_mintable)
        _ = try contract.deploy(SendOptions(TestAccountInfo.LUMAN.address, BigUInt(10000000)), byteCodeWithMintable, BigUInt(100000000000))
        guard let result = try? KIP7.detectInterface(caver!, contract.contractAddress!) else {
            XCTAssert(false)
            return
        }
        XCTAssertTrue(result[KIP7.INTERFACE.IKIP7.getName()] ?? false)
        XCTAssertFalse(result[KIP7.INTERFACE.IKIP7_BURNABLE.getName()] ?? true)
        XCTAssertFalse(result[KIP7.INTERFACE.IKIP7_METADATA.getName()] ?? true)
        XCTAssertTrue(result[KIP7.INTERFACE.IKIP7_MINTABLE.getName()] ?? false)
        XCTAssertFalse(result[KIP7.INTERFACE.IKIP7_PAUSABLE.getName()] ?? true)
    }
    
    func test_withoutBurnable_Pausable() throws {
        let contract = try Contract(caver!, abi_without_pausable_burnable)
        _ = try contract.deploy(SendOptions(TestAccountInfo.LUMAN.address, BigUInt(10000000)), byteCodeWithoutBurnablePausable, "Test", "TST", 18, BigUInt(100000000000))
        guard let result = try? KIP7.detectInterface(caver!, contract.contractAddress!) else {
            XCTAssert(false)
            return
        }
        XCTAssertTrue(result[KIP7.INTERFACE.IKIP7.getName()] ?? false)
        XCTAssertFalse(result[KIP7.INTERFACE.IKIP7_BURNABLE.getName()] ?? true)
        XCTAssertTrue(result[KIP7.INTERFACE.IKIP7_METADATA.getName()] ?? false)
        XCTAssertTrue(result[KIP7.INTERFACE.IKIP7_MINTABLE.getName()] ?? false)
        XCTAssertFalse(result[KIP7.INTERFACE.IKIP7_PAUSABLE.getName()] ?? true)
    }
    
    func test_notSupportedKIP13() throws {
        let contract = try Contract(caver!, abi_not_supported_kip13)
        _ = try contract.deploy(SendOptions(TestAccountInfo.LUMAN.address, BigUInt(10000000)), byteCodeNotSupportedKIP13)
                
        XCTAssertThrowsError(try KIP7.detectInterface(caver!, contract.contractAddress!)) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("This contract does not support KIP-13."))
        }
    }
}
