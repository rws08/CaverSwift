//
//  KIP17Test.swift
//  CaverSwiftTests
//
//  Created by won on 2021/07/27.
//

import XCTest
@testable import CaverSwift
@testable import GenericJSON

class KIP17Test: XCTestCase {
    public static var kip17Contract: KIP17?
    public static let CONTRACT_NAME = "NFT"
    public static let CONTRACT_SYMBOL = "NFT_KALE"
    public static let sTokenURI = "https://game.example/item-id-8u5h2m.json"
    
    public static func deployContract() {
        let caver = Caver(Caver.DEFAULT_URL)
        _ = try! caver.wallet.add(try! KeyringFactory.createFromPrivateKey("0x2359d1ae7317c01532a58b01452476b796a3ac713336e97d8d3c9651cc0aecc3"))
        _ = try! caver.wallet.add(try! KeyringFactory.createFromPrivateKey("0x734aa75ef35fd4420eea2965900e90040b8b9f9f7484219b1a06d06394330f4e"))
        
        let kip17DeployParam = KIP17DeployParams(CONTRACT_NAME, CONTRACT_SYMBOL)
        KIP17Test.kip17Contract = try? KIP17.deploy(caver, kip17DeployParam, TestAccountInfo.LUMAN.address)
    }
}

class KIP17Test_ConstructorTest: XCTestCase {
    public var kip17Contract: KIP17?
    
    override func setUpWithError() throws {
        if KIP17Test.kip17Contract == nil {
            KIP17Test.deployContract()
        }
        
        kip17Contract = KIP17Test.kip17Contract
    }
    
    func test_deploy() throws {
        let caver = Caver(Caver.DEFAULT_URL)
        _ = try! caver.wallet.add(try! KeyringFactory.createFromPrivateKey("0x2359d1ae7317c01532a58b01452476b796a3ac713336e97d8d3c9651cc0aecc3"))
        let contract = try? KIP17.deploy(caver, TestAccountInfo.LUMAN.address, KIP17Test.CONTRACT_NAME, KIP17Test.CONTRACT_SYMBOL)
        
        XCTAssertNotNil(contract)
    }
    
    func test_name() throws {
        let name = try kip17Contract?.name()
        XCTAssertEqual(KIP17Test.CONTRACT_NAME, name)
    }
    
    func test_symbol() throws {
        let symbol = try kip17Contract?.symbol()
        XCTAssertEqual(KIP17Test.CONTRACT_SYMBOL, symbol)
    }
    
    func test_totalSupply() throws {
        let totalSupply = try kip17Contract?.totalSupply()
        XCTAssertEqual(BigUInt(0), totalSupply)
    }
    
    func test_cloneTestWithSetWallet() throws {
        let caver = Caver(Caver.DEFAULT_URL)
        let kip17 = try KIP17(caver)
        
        let container = KeyringContainer()
        _ = try container.generate(3)
        
        kip17.wallet = container
        let cloned = kip17.clone()
        
        XCTAssertEqual(3, (cloned?.wallet as? KeyringContainer)?.count)
    }
}

class KIP17Test_PausableTest: XCTestCase {
    public var kip17Contract: KIP17?
    
    override func setUpWithError() throws {
        if KIP17Test.kip17Contract == nil {
            KIP17Test.deployContract()
        }
        
        kip17Contract = KIP17Test.kip17Contract
        guard let kip17Contract = kip17Contract else {
            XCTAssert(false)
            return
        }
        kip17Contract.setDefaultSendOptions(SendOptions())
        guard let paused = try? kip17Contract.paused() else {
            XCTAssert(false)
            return
        }
        if paused {
            let options = SendOptions(TestAccountInfo.LUMAN.address, BigUInt(4000000))
            _ = try kip17Contract.unpause(options)
        }
    }
    
    func test_pause() throws {
        let options = SendOptions(TestAccountInfo.LUMAN.address, BigUInt(4000000))
        _ = try kip17Contract?.pause(options)
        XCTAssertTrue(try kip17Contract?.paused() ?? false)
    }
    
    func test_pausedDefaultOptions() throws {
        let options = SendOptions(TestAccountInfo.LUMAN.address, BigUInt(4000000))
        kip17Contract?.setDefaultSendOptions(options)
        _ = try kip17Contract?.pause()
        XCTAssertTrue(try kip17Contract?.paused() ?? false)
    }
    
    func test_pausedNoDefaultGas() throws {
        try kip17Contract?.defaultSendOptions?.setFrom(TestAccountInfo.LUMAN.address)
        _ = try kip17Contract?.pause()
        XCTAssertTrue(try kip17Contract?.paused() ?? false)
    }
    
    func test_pausedNoGas() throws {
        let options = SendOptions(TestAccountInfo.LUMAN.address)
        _ = try kip17Contract?.pause(options)
        XCTAssertTrue(try kip17Contract?.paused() ?? false)
    }
    
    func test_unPause() throws {
        let options = SendOptions(TestAccountInfo.LUMAN.address, BigUInt(4000000))
        _ = try kip17Contract?.pause(options)
        XCTAssertTrue(try kip17Contract?.paused() ?? false)
        
        _ = try kip17Contract?.unpause(options)
        XCTAssertFalse(try kip17Contract?.paused() ?? true)
    }
    
    func test_addPauser() throws {
        let options = SendOptions(TestAccountInfo.LUMAN.address, BigUInt(4000000))
        _ = try kip17Contract?.addPauser(TestAccountInfo.BRANDON.address, options)
        XCTAssertTrue(try kip17Contract?.isPauser(TestAccountInfo.BRANDON.address) ?? false)
    }
    
    func test_renouncePauser() throws {
        guard let isPauser = try kip17Contract?.isPauser(TestAccountInfo.BRANDON.address) else {
            XCTAssert(false)
            return
        }
        if !isPauser {
            let options = SendOptions(TestAccountInfo.LUMAN.address, BigUInt(4000000))
            _ = try kip17Contract?.addPauser(TestAccountInfo.BRANDON.address, options)
        }
        
        let options = SendOptions(TestAccountInfo.BRANDON.address, BigUInt(4000000))
        _ = try kip17Contract?.renouncePauser(options)
        
        XCTAssertFalse(try kip17Contract?.isPauser(TestAccountInfo.BRANDON.address) ?? true)
    }
    
    func test_paused() throws {
        XCTAssertFalse(try kip17Contract?.paused() ?? true)
    }
}

class KIP17Test_BurnableTest: XCTestCase {
    public var kip17Contract: KIP17?
    
    override func setUpWithError() throws {
        if KIP17Test.kip17Contract == nil {
            KIP17Test.deployContract()
        }
        
        kip17Contract = KIP17Test.kip17Contract
    }
    
    func test_burn() throws {
        let tokenID = BigUInt(0)
        let ownerOptions = SendOptions(TestAccountInfo.LUMAN.address)
        let userOptions = SendOptions(TestAccountInfo.BRANDON.address)
        _ = try kip17Contract?.mint(TestAccountInfo.BRANDON.address, tokenID, ownerOptions)
        
        let address = try kip17Contract?.ownerOf(tokenID)
        XCTAssertEqual(TestAccountInfo.BRANDON.address, address)
        
        _ = try kip17Contract?.burn(tokenID, userOptions)
        let balance = try kip17Contract?.balanceOf(TestAccountInfo.BRANDON.address)
        
        XCTAssertEqual(BigUInt(0), balance)
    }
}

class KIP17Test_MintableTest: XCTestCase {
    public var kip17Contract: KIP17?
    
    override func setUpWithError() throws {
        if KIP17Test.kip17Contract == nil {
            KIP17Test.deployContract()
        }
        
        kip17Contract = KIP17Test.kip17Contract
    }
    
    func test_mint() throws {
        let tokenID = BigUInt(0)
        let sendOptions = SendOptions(TestAccountInfo.LUMAN.address)
        guard let beforeTotalSupply = try kip17Contract?.totalSupply() else {
            XCTAssert(false)
            return
        }
        
        _ = try kip17Contract?.mint(TestAccountInfo.LUMAN.address, tokenID, sendOptions)

        let afterTotalSupply = try kip17Contract?.totalSupply()
        
        XCTAssertEqual(afterTotalSupply, beforeTotalSupply + BigUInt(1))
    }
    
    func test_mintWithTokenURI() throws {
        let tokenID = BigUInt(1)
        let sendOptions = SendOptions(TestAccountInfo.LUMAN.address)
        
        _ = try kip17Contract?.mintWithTokenURI(TestAccountInfo.LUMAN.address, tokenID, KIP17Test.sTokenURI, sendOptions)
        let uri = try kip17Contract?.tokenURI(tokenID)
        XCTAssertEqual(uri, KIP17Test.sTokenURI)
        
        let tokenOwnerAddr = try kip17Contract?.ownerOf(tokenID)
        XCTAssertEqual(TestAccountInfo.LUMAN.address, tokenOwnerAddr)
    }
    
    func test_isMinter() throws {
        XCTAssertTrue(try kip17Contract?.isMinter(TestAccountInfo.LUMAN.address) ?? false)
    }
    
    func test_addMinter() throws {
        if try kip17Contract?.isMinter(TestAccountInfo.BRANDON.address) ?? false {
            let sendOptions = SendOptions(TestAccountInfo.BRANDON.address)
            _ = try kip17Contract?.renounceMinter(sendOptions)
        }
        
        let sendOptions = SendOptions(TestAccountInfo.LUMAN.address)
        _ = try kip17Contract?.addMinter(TestAccountInfo.BRANDON.address, sendOptions)
        
        XCTAssertTrue(try kip17Contract?.isMinter(TestAccountInfo.BRANDON.address) ?? false)
    }
    
    func test_renounceMinter() throws {
        if !(try kip17Contract?.isMinter(TestAccountInfo.BRANDON.address) ?? true) {
            let sendOptions = SendOptions(TestAccountInfo.LUMAN.address)
            _ = try kip17Contract?.addMinter(TestAccountInfo.BRANDON.address, sendOptions)
        }
        
        let sendOptions = SendOptions(TestAccountInfo.BRANDON.address)
        _ = try kip17Contract?.renounceMinter(sendOptions)
        
        XCTAssertFalse(try kip17Contract?.isMinter(TestAccountInfo.BRANDON.address) ?? true)
    }
    
}

class KIP17Test_EnumerableTest: XCTestCase {
    public var kip17Contract: KIP17?
    
    override func setUpWithError() throws {
        if KIP17Test.kip17Contract == nil {
            KIP17Test.deployContract()
        }
        
        kip17Contract = KIP17Test.kip17Contract
    }
    
    func test_totalSupply() throws {
        let tokenID = BigUInt(0)
        guard let preTotalCount = try kip17Contract?.totalSupply() else {
            XCTAssert(false)
            return
        }
        let sendOptions = SendOptions(TestAccountInfo.LUMAN.address)
        
        _ = try kip17Contract?.mint(TestAccountInfo.LUMAN.address, tokenID, sendOptions)

        let afterTotalSupply = try kip17Contract?.totalSupply()
        XCTAssertEqual(afterTotalSupply, preTotalCount + BigUInt(1))
    }
    
    func test_tokenByIndex() throws {
        let tokenIds = [BigUInt(7000), BigUInt(7001), BigUInt(7002)]
        let sendOptions = SendOptions(TestAccountInfo.LUMAN.address)
        
        try tokenIds.forEach {
            _ = try kip17Contract?.mint(TestAccountInfo.LUMAN.address, $0, sendOptions)
        }
        guard let total = try kip17Contract?.totalSupply() else {
            XCTAssert(false)
            return
        }
        
        var index = total - BigUInt(1)
        var tokenId = try kip17Contract?.tokenByIndex(index)
        XCTAssertEqual(tokenIds[2], tokenId)
        
        index = index - BigUInt(1)
        tokenId = try kip17Contract?.tokenByIndex(index)
        XCTAssertEqual(tokenIds[1], tokenId)
        
        index = index - BigUInt(1)
        tokenId = try kip17Contract?.tokenByIndex(index)
        XCTAssertEqual(tokenIds[0], tokenId)
    }
    
    func test_tokenOfOwnerByIndex() throws {
        let tokenIds = [BigUInt(8000), BigUInt(8001), BigUInt(8002)]
        let sendOptions = SendOptions(TestAccountInfo.LUMAN.address)
        
        try tokenIds.forEach {
            _ = try kip17Contract?.mint(TestAccountInfo.BRANDON.address, $0, sendOptions)
        }
        
        let token1 = try kip17Contract?.tokenOwnerByIndex(TestAccountInfo.BRANDON.address, BigUInt(0))
        XCTAssertEqual(tokenIds[0], token1)
        
        let token2 = try kip17Contract?.tokenOwnerByIndex(TestAccountInfo.BRANDON.address, BigUInt(1))
        XCTAssertEqual(tokenIds[1], token2)
        
        let token3 = try kip17Contract?.tokenOwnerByIndex(TestAccountInfo.BRANDON.address, BigUInt(2))
        XCTAssertEqual(tokenIds[2], token3)
    }
}

class KIP17Test_CommonTest: XCTestCase {
    public var kip17Contract: KIP17?
    
    override func setUpWithError() throws {
        if KIP17Test.kip17Contract == nil {
            KIP17Test.deployContract()
        }
        
        kip17Contract = KIP17Test.kip17Contract
    }
    
    func test_ownerOf() throws {
        let tokenID = BigUInt(0)
        let sendOptions = SendOptions(TestAccountInfo.LUMAN.address)
        _ = try kip17Contract?.mint(TestAccountInfo.LUMAN.address, tokenID, sendOptions)
        
        let address = try kip17Contract?.ownerOf(tokenID)
        XCTAssertEqual(TestAccountInfo.LUMAN.address, address)
    }
    
    func test_balanceOf() throws {
        guard let preBalance = try kip17Contract?.balanceOf(TestAccountInfo.LUMAN.address) else {
            XCTAssert(false)
            return
        }
        
        let tokenID = BigUInt(100000)
        let sendOptions = SendOptions(TestAccountInfo.LUMAN.address)
        _ = try kip17Contract?.mint(TestAccountInfo.LUMAN.address, tokenID, sendOptions)
        
        let currentBalance = try kip17Contract?.balanceOf(TestAccountInfo.LUMAN.address)
        XCTAssertEqual(currentBalance, preBalance + BigUInt(1))
    }
    
    func test_approve() throws {
        let sendOptions = SendOptions(TestAccountInfo.LUMAN.address)
        let tokenID = BigUInt(100)
        _ = try kip17Contract?.mint(TestAccountInfo.LUMAN.address, tokenID, sendOptions)
        
        _ = try kip17Contract?.approve(TestAccountInfo.BRANDON.address, tokenID, sendOptions)
        XCTAssertEqual(TestAccountInfo.BRANDON.address, try kip17Contract?.getApproved(tokenID))
    }
    
    func test_getApproved() throws {
        let sendOptions = SendOptions(TestAccountInfo.LUMAN.address)
        let tokenID = BigUInt(6001)
        _ = try kip17Contract?.mint(TestAccountInfo.LUMAN.address, tokenID, sendOptions)
        
        _ = try kip17Contract?.approve(TestAccountInfo.BRANDON.address, tokenID, sendOptions)
        XCTAssertEqual(TestAccountInfo.BRANDON.address, try kip17Contract?.getApproved(tokenID))
    }
    
    func test_setApprovalForAll() throws {
        let sendOptions = SendOptions(TestAccountInfo.LUMAN.address)
        _ = try kip17Contract?.setApproveForAll(TestAccountInfo.BRANDON.address, true, sendOptions)
        XCTAssertTrue(try kip17Contract?.isApprovedForAll(TestAccountInfo.LUMAN.address, TestAccountInfo.BRANDON.address) ?? false)
        
        _ = try kip17Contract?.setApproveForAll(TestAccountInfo.BRANDON.address, false, sendOptions)
        XCTAssertFalse(try kip17Contract?.isApprovedForAll(TestAccountInfo.LUMAN.address, TestAccountInfo.BRANDON.address) ?? true)
    }
    
    func test_isApprovedForAll() throws {
        let sendOptions = SendOptions(TestAccountInfo.LUMAN.address)
        _ = try kip17Contract?.setApproveForAll(TestAccountInfo.BRANDON.address, true, sendOptions)
        XCTAssertTrue(try kip17Contract?.isApprovedForAll(TestAccountInfo.LUMAN.address, TestAccountInfo.BRANDON.address) ?? false)
        
        _ = try kip17Contract?.setApproveForAll(TestAccountInfo.BRANDON.address, false, sendOptions)
        XCTAssertFalse(try kip17Contract?.isApprovedForAll(TestAccountInfo.LUMAN.address, TestAccountInfo.BRANDON.address) ?? true)
    }
    
    func test_transferFrom_approve() throws {
        let ownerOptions = SendOptions(TestAccountInfo.LUMAN.address)
        let spenderOption = SendOptions(TestAccountInfo.BRANDON.address)
        let tokenId = BigUInt(7777)
        
        _ = try kip17Contract?.mint(TestAccountInfo.LUMAN.address, tokenId, ownerOptions)
        
        _ = try kip17Contract?.approve(TestAccountInfo.BRANDON.address, tokenId, ownerOptions)
        _ = try kip17Contract?.transferFrom(TestAccountInfo.LUMAN.address, TestAccountInfo.BRANDON.address, tokenId, spenderOption)
        
        XCTAssertEqual(TestAccountInfo.BRANDON.address, try kip17Contract?.ownerOf(tokenId))
    }
    
    func test_safeTransferFrom_approve() throws {
        let ownerOptions = SendOptions(TestAccountInfo.LUMAN.address)
        let spenderOption = SendOptions(TestAccountInfo.BRANDON.address)
        let tokenId = BigUInt(7778)
        
        _ = try kip17Contract?.mint(TestAccountInfo.LUMAN.address, tokenId, ownerOptions)
        
        _ = try kip17Contract?.approve(TestAccountInfo.BRANDON.address, tokenId, ownerOptions)
        _ = try kip17Contract?.safeTransferFrom(TestAccountInfo.LUMAN.address, TestAccountInfo.BRANDON.address, tokenId, spenderOption)
        
        XCTAssertEqual(TestAccountInfo.BRANDON.address, try kip17Contract?.ownerOf(tokenId))
    }
    
    func test_safeTransferFromWithData_approve() throws {
        let ownerOptions = SendOptions(TestAccountInfo.LUMAN.address)
        let spenderOption = SendOptions(TestAccountInfo.BRANDON.address)
        let tokenId = BigUInt(6666)
        
        _ = try kip17Contract?.mint(TestAccountInfo.LUMAN.address, tokenId, ownerOptions)
        
        _ = try kip17Contract?.approve(TestAccountInfo.BRANDON.address, tokenId, ownerOptions)
        _ = try kip17Contract?.safeTransferFrom(TestAccountInfo.LUMAN.address, TestAccountInfo.BRANDON.address, tokenId, "buffer", spenderOption)
        
        XCTAssertEqual(TestAccountInfo.BRANDON.address, try kip17Contract?.ownerOf(tokenId))
    }
    
    func test_transferFrom_setApprovedForAll() throws {
        let ownerOptions = SendOptions(TestAccountInfo.LUMAN.address)
        let spenderOption = SendOptions(TestAccountInfo.BRANDON.address)
        let tokenIdArr = [BigUInt(3001), BigUInt(3002)]
                
        _ = try kip17Contract?.mint(TestAccountInfo.LUMAN.address, tokenIdArr[0], ownerOptions)
        _ = try kip17Contract?.mint(TestAccountInfo.LUMAN.address, tokenIdArr[1], ownerOptions)
        
        _ = try kip17Contract?.setApproveForAll(TestAccountInfo.BRANDON.address, true, ownerOptions)
        _ = try kip17Contract?.transferFrom(TestAccountInfo.LUMAN.address, TestAccountInfo.BRANDON.address, tokenIdArr[0], spenderOption)
        _ = try kip17Contract?.transferFrom(TestAccountInfo.LUMAN.address, TestAccountInfo.BRANDON.address, tokenIdArr[1], spenderOption)
        
        XCTAssertEqual(TestAccountInfo.BRANDON.address, try kip17Contract?.ownerOf(tokenIdArr[0]))
        XCTAssertEqual(TestAccountInfo.BRANDON.address, try kip17Contract?.ownerOf(tokenIdArr[1]))
        
        _ = try kip17Contract?.setApproveForAll(TestAccountInfo.BRANDON.address, false, ownerOptions)
        XCTAssertFalse(try kip17Contract?.isApprovedForAll(TestAccountInfo.LUMAN.address, TestAccountInfo.BRANDON.address) ?? true)
    }
    
    func test_safeTransferFrom_setApprovedForAll() throws {
        let ownerOptions = SendOptions(TestAccountInfo.LUMAN.address)
        let spenderOption = SendOptions(TestAccountInfo.BRANDON.address)
        let tokenIdArr = [BigUInt(4001), BigUInt(4002)]
                
        _ = try kip17Contract?.mint(TestAccountInfo.LUMAN.address, tokenIdArr[0], ownerOptions)
        _ = try kip17Contract?.mint(TestAccountInfo.LUMAN.address, tokenIdArr[1], ownerOptions)
        
        _ = try kip17Contract?.setApproveForAll(TestAccountInfo.BRANDON.address, true, ownerOptions)
        _ = try kip17Contract?.safeTransferFrom(TestAccountInfo.LUMAN.address, TestAccountInfo.BRANDON.address, tokenIdArr[0], spenderOption)
        _ = try kip17Contract?.safeTransferFrom(TestAccountInfo.LUMAN.address, TestAccountInfo.BRANDON.address, tokenIdArr[1], spenderOption)
        
        XCTAssertEqual(TestAccountInfo.BRANDON.address, try kip17Contract?.ownerOf(tokenIdArr[0]))
        XCTAssertEqual(TestAccountInfo.BRANDON.address, try kip17Contract?.ownerOf(tokenIdArr[1]))
        
        _ = try kip17Contract?.setApproveForAll(TestAccountInfo.BRANDON.address, false, ownerOptions)
        XCTAssertFalse(try kip17Contract?.isApprovedForAll(TestAccountInfo.LUMAN.address, TestAccountInfo.BRANDON.address) ?? true)
    }
    
    func test_safeTransferFromWithData_setApprovedForAll() throws {
        let ownerOptions = SendOptions(TestAccountInfo.LUMAN.address)
        let spenderOption = SendOptions(TestAccountInfo.BRANDON.address)
        let tokenIdArr = [BigUInt(771), BigUInt(772)]
                
        _ = try kip17Contract?.mint(TestAccountInfo.LUMAN.address, tokenIdArr[0], ownerOptions)
        _ = try kip17Contract?.mint(TestAccountInfo.LUMAN.address, tokenIdArr[1], ownerOptions)
        
        _ = try kip17Contract?.setApproveForAll(TestAccountInfo.BRANDON.address, true, ownerOptions)
        _ = try kip17Contract?.safeTransferFrom(TestAccountInfo.LUMAN.address, TestAccountInfo.BRANDON.address, tokenIdArr[0], "buffered", spenderOption)
        _ = try kip17Contract?.safeTransferFrom(TestAccountInfo.LUMAN.address, TestAccountInfo.BRANDON.address, tokenIdArr[1], "buffered", spenderOption)
        
        XCTAssertEqual(TestAccountInfo.BRANDON.address, try kip17Contract?.ownerOf(tokenIdArr[0]))
        XCTAssertEqual(TestAccountInfo.BRANDON.address, try kip17Contract?.ownerOf(tokenIdArr[1]))
        
        _ = try kip17Contract?.setApproveForAll(TestAccountInfo.BRANDON.address, false, ownerOptions)
        XCTAssertFalse(try kip17Contract?.isApprovedForAll(TestAccountInfo.LUMAN.address, TestAccountInfo.BRANDON.address) ?? true)
    }
    
    func test_supportsInterface() throws {
        let INTERFACE_ID_KIP13 = "0x01ffc9a7"
        let INTERFACE_ID_KIP17  = "0x80ac58cd"
        let INTERFACE_ID_KIP17_PAUSABLE = "0x4d5507ff"
        let INTERFACE_ID_KIP17_BURNABLE = "0x42966c68"
        let INTERFACE_ID_KIP17_MINTABLE = "0xeab83e20"
        let INTERFACE_ID_KIP17_METADATA  = "0x5b5e139f"
        let INTERFACE_ID_KIP17_METADATA_MINTABLE  = "0xfac27f46"
        let INTERFACE_ID_KIP17_ENUMERABLE  = "0x780e9d63"
        let INTERFACE_ID_FALSE = "0xFFFFFFFF"
        
        let isSupported_KIP13 = try kip17Contract?.supportInterface(INTERFACE_ID_KIP13)
        XCTAssertTrue(isSupported_KIP13 ?? false)
        
        let isSupported_KIP17_PAUSABLE = try kip17Contract?.supportInterface(INTERFACE_ID_KIP17_PAUSABLE)
        XCTAssertTrue(isSupported_KIP17_PAUSABLE ?? false)
        
        let isSupported_KIP17_BURNABLE = try kip17Contract?.supportInterface(INTERFACE_ID_KIP17_BURNABLE)
        XCTAssertTrue(isSupported_KIP17_BURNABLE ?? false)
        
        let isSupported_KIP17_MINTABLE = try kip17Contract?.supportInterface(INTERFACE_ID_KIP17_MINTABLE)
        XCTAssertTrue(isSupported_KIP17_MINTABLE ?? false)
        
        let isSupported_KIP17_METADATA = try kip17Contract?.supportInterface(INTERFACE_ID_KIP17_METADATA)
        XCTAssertTrue(isSupported_KIP17_METADATA ?? false)
        
        let isSupported_KIP17_METADATA_MINTABLE = try kip17Contract?.supportInterface(INTERFACE_ID_KIP17_METADATA_MINTABLE)
        XCTAssertTrue(isSupported_KIP17_METADATA_MINTABLE ?? false)
        
        let isSupported_KIP17_ENUMERABLE = try kip17Contract?.supportInterface(INTERFACE_ID_KIP17_ENUMERABLE)
        XCTAssertTrue(isSupported_KIP17_ENUMERABLE ?? false)
        
        let isSupported_KIP17 = try kip17Contract?.supportInterface(INTERFACE_ID_KIP17)
        XCTAssertTrue(isSupported_KIP17 ?? false)
        
        let isSupported_FALSE = try kip17Contract?.supportInterface(INTERFACE_ID_FALSE)
        XCTAssertFalse(isSupported_FALSE ?? true)
    }
}

class KIP17Test_DetectInterfaceTest: XCTestCase {
    public var kip17Contract: KIP17?
    public var caver: Caver?
    
    public var bytecodeWithFullMetadataMintable = ""
    public var byteCodeWithoutBurnablePausable = ""
    public var byteCodeNotSupportedKIP13 = ""
    
    public var abi_metadata_mintable = ""
    public var abi_without_burnable_pausable = ""
    public var abi_not_supported_kip13 = ""
    
    override func setUpWithError() throws {
        if !bytecodeWithFullMetadataMintable.isEmpty {
            return
        }
        
        do {
            if let file  = Bundle(for: type(of: self)).url(forResource: "KIP17TestData", withExtension: "json"){
                let data  = try Data(contentsOf: file)
                let json = try JSONDecoder().decode(JSON.self, from:data)
                bytecodeWithFullMetadataMintable = json["bytecodeWithFullMetadataMintable"]?.stringValue ?? ""
                byteCodeWithoutBurnablePausable = json["byteCodeWithoutBurnablePausable"]?.stringValue ?? ""
                byteCodeNotSupportedKIP13 = json["byteCodeNotSupportedKIP13"]?.stringValue ?? ""
                var jsonObj = try JSONEncoder().encode(json["abi_metadata_mintable"])
                abi_metadata_mintable = String(data: jsonObj, encoding: .utf8)!
                jsonObj = try JSONEncoder().encode(json["abi_without_burnable_pausable"])
                abi_without_burnable_pausable = String(data: jsonObj, encoding: .utf8)!
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
        
        if KIP17Test.kip17Contract == nil {
            KIP17Test.deployContract()
        }
        
        kip17Contract = KIP17Test.kip17Contract
    }
    
    func test_detectInterface() throws {
        guard let result = try kip17Contract?.detectInterface() else {
            XCTAssert(false)
            return
        }
        XCTAssertTrue(result[KIP17.INTERFACE.IKIP17.getName()] ?? false)
        XCTAssertTrue(result[KIP17.INTERFACE.IKIP17_METADATA.getName()] ?? false)
        XCTAssertTrue(result[KIP17.INTERFACE.IKIP17_ENUMERABLE.getName()] ?? false)
        XCTAssertTrue(result[KIP17.INTERFACE.IKIP17_MINTABLE.getName()] ?? false)
        XCTAssertTrue(result[KIP17.INTERFACE.IKIP17_METADATA_MINTABLE.getName()] ?? false)
        XCTAssertTrue(result[KIP17.INTERFACE.IKIP17_BURNABLE.getName()] ?? false)
        XCTAssertTrue(result[KIP17.INTERFACE.IKIP17_PAUSABLE.getName()] ?? false)
    }
    
    func test_detectInterface_staticMethod() throws {
        guard let kip17Contract = kip17Contract,
              let result = try? KIP17.detectInterface(kip17Contract.caver, kip17Contract.contractAddress!) else {
            XCTAssert(false)
            return
        }
        XCTAssertTrue(result[KIP17.INTERFACE.IKIP17.getName()] ?? false)
        XCTAssertTrue(result[KIP17.INTERFACE.IKIP17_METADATA.getName()] ?? false)
        XCTAssertTrue(result[KIP17.INTERFACE.IKIP17_ENUMERABLE.getName()] ?? false)
        XCTAssertTrue(result[KIP17.INTERFACE.IKIP17_MINTABLE.getName()] ?? false)
        XCTAssertTrue(result[KIP17.INTERFACE.IKIP17_METADATA_MINTABLE.getName()] ?? false)
        XCTAssertTrue(result[KIP17.INTERFACE.IKIP17_BURNABLE.getName()] ?? false)
        XCTAssertTrue(result[KIP17.INTERFACE.IKIP17_PAUSABLE.getName()] ?? false)
    }
    
    func test_metadata_mintable() throws {
        let contract = try Contract(caver!, abi_metadata_mintable)
        _ = try contract.deploy(SendOptions(TestAccountInfo.LUMAN.address, BigUInt(10000000)), bytecodeWithFullMetadataMintable, "Test", "TST")
        guard let result = try? KIP17.detectInterface(caver!, contract.contractAddress!) else {
            XCTAssert(false)
            return
        }
        XCTAssertTrue(result[KIP17.INTERFACE.IKIP17.getName()] ?? false)
        XCTAssertTrue(result[KIP17.INTERFACE.IKIP17_METADATA.getName()] ?? false)
        XCTAssertTrue(result[KIP17.INTERFACE.IKIP17_ENUMERABLE.getName()] ?? false)
        XCTAssertFalse(result[KIP17.INTERFACE.IKIP17_MINTABLE.getName()] ?? true)
        XCTAssertTrue(result[KIP17.INTERFACE.IKIP17_METADATA_MINTABLE.getName()] ?? false)
        XCTAssertFalse(result[KIP17.INTERFACE.IKIP17_BURNABLE.getName()] ?? true)
        XCTAssertFalse(result[KIP17.INTERFACE.IKIP17_PAUSABLE.getName()] ?? true)
    }
    
    func test_without_burnable_pausable() throws {
        let contract = try Contract(caver!, abi_not_supported_kip13)
        _ = try contract.deploy(SendOptions(TestAccountInfo.LUMAN.address, BigUInt(10000000)), byteCodeNotSupportedKIP13)
        
                
        XCTAssertThrowsError(try KIP17.detectInterface(caver!, contract.contractAddress!)) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("This contract does not support KIP-13."))
        }
    }
}
