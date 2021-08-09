//
//  KIP37Test.swift
//  CaverSwiftTests
//
//  Created by won on 2021/07/28.
//

import XCTest
@testable import CaverSwift
@testable import GenericJSON

class KIP37Test: XCTestCase {
    public static var kip37: KIP37?
    public static let tokenURI = "https://kip37.example/{id}.json"
    
    public static func deployContract(_ uri: String) throws {
        let caver = Caver(Caver.DEFAULT_URL)
        _ = try! caver.wallet.add(try! KeyringFactory.createFromPrivateKey("0x2359d1ae7317c01532a58b01452476b796a3ac713336e97d8d3c9651cc0aecc3"))
        _ = try! caver.wallet.add(try! KeyringFactory.createFromPrivateKey("0x734aa75ef35fd4420eea2965900e90040b8b9f9f7484219b1a06d06394330f4e"))
        
        KIP37Test.kip37 = try? KIP37.deploy(caver, uri, TestAccountInfo.LUMAN.address)
        if KIP37Test.kip37 == nil {
            throw CaverError.InstantiationException("kip37 is nil")
        }
    }
    
    public static func createToken(_ kip37: KIP37, _ tokenId: BigUInt, _ initialSupply: BigUInt, _ URI: String, _ sender: String) -> Bool {
        guard let receiptData = try? kip37.create(tokenId, initialSupply, tokenURI, SendOptions(sender)) else {
            return false
        }
        return receiptData.status == "0x1"
    }
}

class KIP37Test_A_ConstructorTest: XCTestCase {
    public var kip37: KIP37?
    
    override func setUpWithError() throws {
        if KIP37Test.kip37 == nil {
            try KIP37Test.deployContract(KIP37Test.tokenURI)
        }
        
        kip37 = KIP37Test.kip37
    }
    
    func test_deploy() throws {
        let caver = Caver(Caver.DEFAULT_URL)
        _ = try! caver.wallet.add(try! KeyringFactory.createFromPrivateKey("0x2359d1ae7317c01532a58b01452476b796a3ac713336e97d8d3c9651cc0aecc3"))
        let contract = try? KIP37.deploy(caver, KIP37Test.tokenURI, TestAccountInfo.LUMAN.address)
        
        XCTAssertNotNil(contract?.contractAddress)
    }
    
    func test_uri() throws {
        let expected = "https://kip37.example/000000000000000000000000000000000000000000000000000000000004cce0.json"
        let tokenUri = try kip37?.uri("0x4cce0")
        XCTAssertEqual(expected, tokenUri)
    }
}

class KIP37Test_B_MintableTest: XCTestCase {
    public var kip37: KIP37?
    
    override func setUpWithError() throws {
        if KIP37Test.kip37 == nil {
            try KIP37Test.deployContract(KIP37Test.tokenURI)
            
            kip37 = KIP37Test.kip37
            
            let initialSupply = BigUInt(1000)
            let tokenURI = "http://mintable.token/"
            if(!KIP37Test.createToken(kip37!, BigUInt(0), initialSupply, tokenURI, TestAccountInfo.LUMAN.address)) {
                XCTAssert(false)
            }
            
            if(!KIP37Test.createToken(kip37!, BigUInt(1), initialSupply, tokenURI, TestAccountInfo.LUMAN.address)) {
                XCTAssert(false)
            }
            
            if(!KIP37Test.createToken(kip37!, BigUInt(2), initialSupply, tokenURI, TestAccountInfo.LUMAN.address)) {
                XCTAssert(false)
            }
        }
        
        kip37 = KIP37Test.kip37
    }
    
    func test_mint() throws {
        let tokenID = BigUInt(1)
        let receiptData = try kip37?.mint(TestAccountInfo.BRANDON.address, tokenID, BigUInt(10), SendOptions(TestAccountInfo.LUMAN.address))
        if(receiptData?.status != "0x1") {
            XCTAssert(false)
        }

        guard let balance = try kip37?.balanceOf(TestAccountInfo.BRANDON.address, BigUInt(1)) else {
            XCTAssert(false)
            return
        }
        
        XCTAssertTrue(balance >= BigUInt(10))
    }
    
    func test_mint_StringID() throws {
        let tokenID = "0x1"
        let receiptData = try kip37?.mint(TestAccountInfo.BRANDON.address, tokenID, BigUInt(10), SendOptions(TestAccountInfo.LUMAN.address))
        if(receiptData?.status != "0x1") {
            XCTAssert(false)
        }

        guard let balance = try kip37?.balanceOf(TestAccountInfo.BRANDON.address, BigUInt(1)) else {
            XCTAssert(false)
            return
        }
        
        XCTAssertTrue(balance >= BigUInt(10))
    }
    
    func test_mintWithToList() throws {
        let tokenID = BigUInt(1)
        let toArr = [TestAccountInfo.WAYNE.address, TestAccountInfo.BRANDON.address]
        let mintAmountArr = [BigUInt(10), BigUInt(10)]
        
        let receiptData = try kip37?.mint(toArr, tokenID, mintAmountArr, SendOptions(TestAccountInfo.LUMAN.address))
        if(receiptData?.status != "0x1") {
            XCTAssert(false)
        }

        guard let balance1 = try kip37?.balanceOf(TestAccountInfo.BRANDON.address, BigUInt(1)),
              let balance2 = try kip37?.balanceOf(TestAccountInfo.WAYNE.address, BigUInt(1))else {
            XCTAssert(false)
            return
        }
        
        XCTAssertTrue(balance1 > BigUInt(0))
        XCTAssertTrue(balance2 > BigUInt(0))
    }
    
    func test_mintWithToList_StringID() throws {
        let tokenID = "0x1"
        let toArr = [TestAccountInfo.WAYNE.address, TestAccountInfo.BRANDON.address]
        let mintAmountArr = [BigUInt(10), BigUInt(10)]
        
        let receiptData = try kip37?.mint(toArr, tokenID, mintAmountArr, SendOptions(TestAccountInfo.LUMAN.address))
        if(receiptData?.status != "0x1") {
            XCTAssert(false)
        }

        guard let balance1 = try kip37?.balanceOf(TestAccountInfo.BRANDON.address, BigUInt(1)),
              let balance2 = try kip37?.balanceOf(TestAccountInfo.WAYNE.address, BigUInt(1))else {
            XCTAssert(false)
            return
        }
        
        XCTAssertTrue(balance1 > BigUInt(0))
        XCTAssertTrue(balance2 > BigUInt(0))
    }
    
    func test_mintBatch() throws {
        let to = TestAccountInfo.BRANDON.address
        let tokenIdArr = [BigUInt(1), BigUInt(2)]
        let valuesArr = [BigUInt(10), BigUInt(10)]
        
        let receiptData = try kip37?.mintBatch(to, tokenIdArr, valuesArr, SendOptions(TestAccountInfo.LUMAN.address))
        if(receiptData?.status != "0x1") {
            XCTAssert(false)
        }

        guard let balance1 = try kip37?.balanceOf(TestAccountInfo.BRANDON.address, BigUInt(1)),
              let balance2 = try kip37?.balanceOf(TestAccountInfo.BRANDON.address, BigUInt(2))else {
            XCTAssert(false)
            return
        }
        
        XCTAssertTrue(balance1 > BigUInt(0))
        XCTAssertTrue(balance2 > BigUInt(0))
    }
    
    func test_mintBatch_StringID() throws {
        let to = TestAccountInfo.BRANDON.address
        let tokenIdArr = ["0x1", "0x2"]
        let valuesArr = [BigUInt(10), BigUInt(10)]
        
        let receiptData = try kip37?.mintBatch(to, tokenIdArr, valuesArr, SendOptions(TestAccountInfo.LUMAN.address))
        if(receiptData?.status != "0x1") {
            XCTAssert(false)
        }

        guard let balance1 = try kip37?.balanceOf(TestAccountInfo.BRANDON.address, BigUInt(1)),
              let balance2 = try kip37?.balanceOf(TestAccountInfo.BRANDON.address, BigUInt(2))else {
            XCTAssert(false)
            return
        }
        
        XCTAssertTrue(balance1 > BigUInt(0))
        XCTAssertTrue(balance2 > BigUInt(0))
    }
    
    func test_isMinter() throws {
        XCTAssertTrue(try kip37?.isMinter(TestAccountInfo.BRANDON.address) ?? false)
    }
    
    func test_addMinter() throws {
        if try kip37?.isMinter(TestAccountInfo.BRANDON.address) ?? false {
            let sendOptions = SendOptions(TestAccountInfo.BRANDON.address)
            _ = try kip37?.renounceMinter(sendOptions)
        }
        
        let sendOptions = SendOptions(TestAccountInfo.LUMAN.address)
        _ = try kip37?.addMinter(TestAccountInfo.BRANDON.address, sendOptions)
        
        XCTAssertTrue(try kip37?.isMinter(TestAccountInfo.BRANDON.address) ?? false)
    }
    
    func test_renounceMinter() throws {
        if !(try kip37?.isMinter(TestAccountInfo.BRANDON.address) ?? true) {
            let sendOptions = SendOptions(TestAccountInfo.LUMAN.address)
            _ = try kip37?.addMinter(TestAccountInfo.BRANDON.address, sendOptions)
        }
        
        let sendOptions = SendOptions(TestAccountInfo.BRANDON.address)
        _ = try kip37?.renounceMinter(sendOptions)
        
        XCTAssertFalse(try kip37?.isMinter(TestAccountInfo.BRANDON.address) ?? true)
    }

}

class KIP37Test_C_PausableTest: XCTestCase {
    public var kip37: KIP37?
    
    override func setUpWithError() throws {
        if KIP37Test.kip37 == nil {
            try KIP37Test.deployContract(KIP37Test.tokenURI)
        }
        
        kip37 = KIP37Test.kip37
        guard let kip37 = kip37 else {
            XCTAssert(false)
            return
        }
        kip37.setDefaultSendOptions(SendOptions(TestAccountInfo.LUMAN.address, BigUInt(4000000)))
        guard let paused = try? kip37.paused() else {
            XCTAssert(false)
            return
        }
        if paused {
            let options = SendOptions(TestAccountInfo.LUMAN.address, BigUInt(4000000))
            let receiptData = try kip37.unpause(options)
            if(receiptData.status != "0x1") {
                XCTAssert(false)
            }
        }
    }
    
    func test_pause() throws {
        let options = SendOptions(TestAccountInfo.LUMAN.address, BigUInt(4000000))
        _ = try kip37?.pause(options)
        XCTAssertTrue(try kip37?.paused() ?? false)
    }
    
    func test_pausedDefaultOptions() throws {
        _ = try kip37?.pause()
        XCTAssertTrue(try kip37?.paused() ?? false)
    }
    
    func test_pausedNoDefaultGas() throws {
        try kip37?.defaultSendOptions?.setFrom(TestAccountInfo.LUMAN.address)
        _ = try kip37?.pause()
        XCTAssertTrue(try kip37?.paused() ?? false)
    }
    
    func test_pausedNoGas() throws {
        let options = SendOptions(TestAccountInfo.LUMAN.address)
        _ = try kip37?.pause(options)
        XCTAssertTrue(try kip37?.paused() ?? false)
    }
    
    func test_unPause() throws {
        let options = SendOptions(TestAccountInfo.LUMAN.address, BigUInt(4000000))
        _ = try kip37?.pause(options)
        XCTAssertTrue(try kip37?.paused() ?? false)
        
        _ = try kip37?.unpause(options)
        XCTAssertFalse(try kip37?.paused() ?? true)
    }
    
    func test_addPauser() throws {
        let options = SendOptions(TestAccountInfo.LUMAN.address, BigUInt(4000000))
        _ = try kip37?.addPauser(TestAccountInfo.BRANDON.address, options)
        XCTAssertTrue(try kip37?.isPauser(TestAccountInfo.BRANDON.address) ?? false)
    }
    
    func test_renouncePauser() throws {
        guard let isPauser = try kip37?.isPauser(TestAccountInfo.BRANDON.address) else {
            XCTAssert(false)
            return
        }
        if !isPauser {
            let options = SendOptions(TestAccountInfo.LUMAN.address, BigUInt(4000000))
            _ = try kip37?.addPauser(TestAccountInfo.BRANDON.address, options)
        }
        
        let options = SendOptions(TestAccountInfo.BRANDON.address, BigUInt(4000000))
        _ = try kip37?.renouncePauser(options)
        
        XCTAssertFalse(try kip37?.isPauser(TestAccountInfo.BRANDON.address) ?? true)
    }
    
    func test_paused() throws {
        XCTAssertFalse(try kip37?.paused() ?? true)
    }
    
    func test_pauseToken() throws {
        let tokenId = BigUInt(0)
        if(!KIP37Test.createToken(kip37!, tokenId, BigUInt(1000), KIP37Test.tokenURI, TestAccountInfo.LUMAN.address)) {
            XCTAssert(false)
        }
        
        let receiptData = try kip37?.pause(tokenId, SendOptions(TestAccountInfo.LUMAN.address))
        if(receiptData?.status != "0x1") {
            XCTAssert(false)
        }
        
        XCTAssertTrue(try kip37?.paused(tokenId) ?? false)
    }
    
    func test_pauseToken_StringID() throws {
        let tokenId = BigUInt(1)
        if(!KIP37Test.createToken(kip37!, tokenId, BigUInt(1000), KIP37Test.tokenURI, TestAccountInfo.LUMAN.address)) {
            XCTAssert(false)
        }
        
        let receiptData = try kip37?.pause("0x1", SendOptions(TestAccountInfo.LUMAN.address))
        if(receiptData?.status != "0x1") {
            XCTAssert(false)
        }
        
        XCTAssertTrue(try kip37?.paused(tokenId) ?? false)
    }
    
    func test_unpauseToken() throws {
        let tokenId = BigUInt(2)
        if(!KIP37Test.createToken(kip37!, tokenId, BigUInt(1000), KIP37Test.tokenURI, TestAccountInfo.LUMAN.address)) {
            XCTAssert(false)
        }
        
        var receiptData = try kip37?.pause(tokenId, SendOptions(TestAccountInfo.LUMAN.address))
        if(receiptData?.status != "0x1") {
            XCTAssert(false)
        }
        
        receiptData = try kip37?.unpause(tokenId, SendOptions(TestAccountInfo.LUMAN.address))
        if(receiptData?.status != "0x1") {
            XCTAssert(false)
        }
        
        XCTAssertFalse(try kip37?.paused(tokenId) ?? true)
    }
    
    func test_unpauseToken_StringID() throws {
        let tokenId = BigUInt(3)
        if(!KIP37Test.createToken(kip37!, tokenId, BigUInt(1000), KIP37Test.tokenURI, TestAccountInfo.LUMAN.address)) {
            XCTAssert(false)
        }
        
        var receiptData = try kip37?.pause("0x3", SendOptions(TestAccountInfo.LUMAN.address))
        if(receiptData?.status != "0x1") {
            XCTAssert(false)
        }
        
        receiptData = try kip37?.unpause("0x3", SendOptions(TestAccountInfo.LUMAN.address))
        if(receiptData?.status != "0x1") {
            XCTAssert(false)
        }
        
        XCTAssertFalse(try kip37?.paused(tokenId) ?? true)
    }
    
    func test_pausedToken() throws {
        let tokenId = BigUInt(4)
        if(!KIP37Test.createToken(kip37!, tokenId, BigUInt(1000), KIP37Test.tokenURI, TestAccountInfo.LUMAN.address)) {
            XCTAssert(false)
        }
        
        XCTAssertFalse(try kip37?.paused(tokenId) ?? true)
    }
    
    func test_pausedToken_StringID() throws {
        let tokenId = BigUInt(5)
        if(!KIP37Test.createToken(kip37!, tokenId, BigUInt(1000), KIP37Test.tokenURI, TestAccountInfo.LUMAN.address)) {
            XCTAssert(false)
        }
        
        XCTAssertFalse(try kip37?.paused("0x5") ?? true)
    }
}

class KIP37Test_D_BurnableTest: XCTestCase {
    public var kip37: KIP37?
    
    override func setUpWithError() throws {
        if KIP37Test.kip37 == nil {
            try KIP37Test.deployContract(KIP37Test.tokenURI)
            
            kip37 = KIP37Test.kip37
            
            if(!KIP37Test.createToken(kip37!, BigUInt(0), BigUInt(1000), KIP37Test.tokenURI, TestAccountInfo.LUMAN.address)) {
                XCTAssert(false)
            }
            
            if(!KIP37Test.createToken(kip37!, BigUInt(1), BigUInt(1000), KIP37Test.tokenURI, TestAccountInfo.LUMAN.address)) {
                XCTAssert(false)
            }
            
            if(!KIP37Test.createToken(kip37!, BigUInt(2), BigUInt(1000), KIP37Test.tokenURI, TestAccountInfo.LUMAN.address)) {
                XCTAssert(false)
            }
        }
        
        kip37 = KIP37Test.kip37
    }
    
    func test_burn() throws {
        let tokenID = BigUInt(0)
        let receiptData = try kip37?.burn(TestAccountInfo.LUMAN.address, tokenID, BigUInt(10), SendOptions(TestAccountInfo.LUMAN.address))
        if(receiptData?.status != "0x1") {
            XCTAssert(false)
        }

        guard let balance = try kip37?.balanceOf(TestAccountInfo.LUMAN.address, tokenID) else {
            XCTAssert(false)
            return
        }
        
        XCTAssertTrue(balance <= BigUInt(990))
    }
    
    func test_burn_StringID() throws {
        let tokenID = "0x0"
        let receiptData = try kip37?.burn(TestAccountInfo.LUMAN.address, tokenID, BigUInt(10), SendOptions(TestAccountInfo.LUMAN.address))
        if(receiptData?.status != "0x1") {
            XCTAssert(false)
        }

        guard let balance = try kip37?.balanceOf(TestAccountInfo.LUMAN.address, tokenID) else {
            XCTAssert(false)
            return
        }
        
        XCTAssertTrue(balance <= BigUInt(990))
    }
    
    func test_burnBatch() throws {
        let tokenIds = [BigUInt(1), BigUInt(2)]
        let values = [BigUInt(10), BigUInt(10)]
        
        let receiptData = try kip37?.burnBatch(TestAccountInfo.LUMAN.address, tokenIds, values, SendOptions(TestAccountInfo.LUMAN.address))
        if(receiptData?.status != "0x1") {
            XCTAssert(false)
        }

        let accountArr = [TestAccountInfo.LUMAN.address, TestAccountInfo.LUMAN.address]
        guard let balanceList = try kip37?.balanceOfBatch(accountArr, tokenIds) else {
            XCTAssert(false)
            return
        }
        
        XCTAssertTrue(balanceList[0] <= BigUInt(990))
        XCTAssertTrue(balanceList[1] <= BigUInt(990))
    }
    
    func test_burnBatch_StringID() throws {
        let tokenIds = ["0x1", "0x2"]
        let values = [BigUInt(10), BigUInt(10)]
        
        let receiptData = try kip37?.burnBatch(TestAccountInfo.LUMAN.address, tokenIds, values, SendOptions(TestAccountInfo.LUMAN.address))
        if(receiptData?.status != "0x1") {
            XCTAssert(false)
        }

        let accountArr = [TestAccountInfo.LUMAN.address, TestAccountInfo.LUMAN.address]
        guard let balanceList = try kip37?.balanceOfBatch(accountArr, tokenIds) else {
            XCTAssert(false)
            return
        }
        
        XCTAssertTrue(balanceList[0] <= BigUInt(990))
        XCTAssertTrue(balanceList[1] <= BigUInt(990))
    }
}

class KIP37Test_E_IKIP37Test: XCTestCase {
    public var kip37: KIP37?
    
    override func setUpWithError() throws {
        if KIP37Test.kip37 == nil {
            try KIP37Test.deployContract(KIP37Test.tokenURI)
            
            kip37 = KIP37Test.kip37
            
            if(!KIP37Test.createToken(kip37!, BigUInt(0), BigUInt(2000), KIP37Test.tokenURI, TestAccountInfo.LUMAN.address)) {
                XCTAssert(false)
            }
            
            if(!KIP37Test.createToken(kip37!, BigUInt(1), BigUInt(2000), KIP37Test.tokenURI, TestAccountInfo.LUMAN.address)) {
                XCTAssert(false)
            }
            
            if(!KIP37Test.createToken(kip37!, BigUInt(2), BigUInt(2000), KIP37Test.tokenURI, TestAccountInfo.LUMAN.address)) {
                XCTAssert(false)
            }
            
            if(!KIP37Test.createToken(kip37!, BigUInt(3), BigUInt(2000), KIP37Test.tokenURI, TestAccountInfo.LUMAN.address)) {
                XCTAssert(false)
            }
        }
        
        kip37 = KIP37Test.kip37
    }
    
    func test_totalSupply() throws {
        let total = try kip37?.totalSupply(BigUInt(0))
        XCTAssertEqual(BigUInt(2000), total)
    }
    
    func test_totalSupplyStringID() throws {
        let total = try kip37?.totalSupply("0x0")
        XCTAssertEqual(BigUInt(2000), total)
    }
    
    func test_balanceOf() throws {
        let balance = try kip37?.balanceOf(TestAccountInfo.LUMAN.address, BigUInt(0))
        XCTAssertEqual(BigUInt(2000), balance)
    }
    
    func test_balanceOfStringID() throws {
        let balance = try kip37?.balanceOf(TestAccountInfo.LUMAN.address, "0x0")
        XCTAssertEqual(BigUInt(2000), balance)
    }
    
    func test_balanceOfBatch() throws {
        let accounts = [TestAccountInfo.LUMAN.address, TestAccountInfo.LUMAN.address]
        let tokenIds = [BigUInt(0), BigUInt(1)]
        
        let balances = try kip37?.balanceOfBatch(accounts, tokenIds)
        XCTAssertEqual(BigUInt(2000), balances?[0])
        XCTAssertEqual(BigUInt(2000), balances?[1])
    }
    
    func test_balanceOfBatchStringID() throws {
        let accounts = [TestAccountInfo.LUMAN.address, TestAccountInfo.LUMAN.address]
        let tokenIds = ["0x0", "0x1"]
        
        let balances = try kip37?.balanceOfBatch(accounts, tokenIds)
        XCTAssertEqual(BigUInt(2000), balances?[0])
        XCTAssertEqual(BigUInt(2000), balances?[1])
    }
    
    func test_isApprovedForAll() throws {
        let owner = TestAccountInfo.LUMAN.address
        let operate = TestAccountInfo.WAYNE.address
        XCTAssertFalse(try kip37?.isApprovedForAll(owner, operate) ?? true)
    }
    
    func test_setApprovedForAll() throws {
        let owner = TestAccountInfo.LUMAN.address
        let operate = TestAccountInfo.BRANDON.address
        
        guard let approved = try? kip37?.isApprovedForAll(owner, operate) else {
            XCTAssert(false)
            return
        }
        
        if approved {
            let receiptData = try kip37?.setApprovalForAll(operate, false, SendOptions(TestAccountInfo.LUMAN.address))
            if(receiptData?.status != "0x1") {
                XCTAssert(false)
            }
        }
        
        let receiptData = try kip37?.setApprovalForAll(operate, true, SendOptions(TestAccountInfo.LUMAN.address, BigUInt(300000)))
        if(receiptData?.status != "0x1") {
            XCTAssert(false)
        }
        
        XCTAssertTrue(try kip37?.isApprovedForAll(owner, operate) ?? false)
    }
    
    func test_safeTransferFrom() throws {
        let from = TestAccountInfo.LUMAN.address
        let to = KeyringFactory.generate()?.address
        let tokenId = BigUInt(2)
        let values = BigUInt(100)
        
        let receiptData = try kip37?.safeTransferFrom(from, to!, tokenId, values, "data", SendOptions(TestAccountInfo.LUMAN.address))
        if(receiptData?.status != "0x1") {
            XCTAssert(false)
        }
        
        XCTAssertEqual(BigUInt(100), try kip37?.balanceOf(to!, tokenId))
    }
    
    func test_safeTransferFromStringID() throws {
        let from = TestAccountInfo.LUMAN.address
        let to = KeyringFactory.generate()?.address
        let tokenId = "0x2"
        let values = BigUInt(100)
        
        let receiptData = try kip37?.safeTransferFrom(from, to!, tokenId, values, "data", SendOptions(TestAccountInfo.LUMAN.address))
        if(receiptData?.status != "0x1") {
            XCTAssert(false)
        }
        
        XCTAssertEqual(BigUInt(100), try kip37?.balanceOf(to!, tokenId))
    }
    
    func test_safeTransferFromWithoutData() throws {
        let from = TestAccountInfo.LUMAN.address
        let to = KeyringFactory.generate()?.address
        let tokenId = BigUInt(2)
        let values = BigUInt(100)
        
        let receiptData = try kip37?.safeTransferFrom(from, to!, tokenId, values, SendOptions(TestAccountInfo.LUMAN.address))
        if(receiptData?.status != "0x1") {
            XCTAssert(false)
        }
        
        XCTAssertEqual(BigUInt(100), try kip37?.balanceOf(to!, tokenId))
    }
    
    func test_safeTransferFromStringIDWithoutData() throws {
        let from = TestAccountInfo.LUMAN.address
        let to = KeyringFactory.generate()?.address
        let tokenId = "0x2"
        let values = BigUInt(100)
        
        let receiptData = try kip37?.safeTransferFrom(from, to!, tokenId, values, SendOptions(TestAccountInfo.LUMAN.address))
        if(receiptData?.status != "0x1") {
            XCTAssert(false)
        }
        
        XCTAssertEqual(BigUInt(100), try kip37?.balanceOf(to!, tokenId))
    }
    
    func test_safeBatchTransferFrom() throws {
        let from = TestAccountInfo.LUMAN.address
        let to = KeyringFactory.generate()?.address
        let tokenIds = [BigUInt(2), BigUInt(3)]
        let values = [BigUInt(100), BigUInt(100)]
        
        let receiptData = try kip37?.safeBatchTransferFrom(from, to!, tokenIds, values, "data", SendOptions(TestAccountInfo.LUMAN.address))
        if(receiptData?.status != "0x1") {
            XCTAssert(false)
        }
        
        XCTAssertEqual(BigUInt(100), try kip37?.balanceOf(to!, tokenIds[0]))
        XCTAssertEqual(BigUInt(100), try kip37?.balanceOf(to!, tokenIds[1]))
    }
    
    func test_safeBatchTransferFrom_StringID() throws {
        let from = TestAccountInfo.LUMAN.address
        let to = KeyringFactory.generate()?.address
        let tokenIds = ["0x2", "0x3"]
        let values = [BigUInt(100), BigUInt(100)]
        
        let receiptData = try kip37?.safeBatchTransferFrom(from, to!, tokenIds, values, "data", SendOptions(TestAccountInfo.LUMAN.address))
        if(receiptData?.status != "0x1") {
            XCTAssert(false)
        }
        
        XCTAssertEqual(BigUInt(100), try kip37?.balanceOf(to!, tokenIds[0]))
        XCTAssertEqual(BigUInt(100), try kip37?.balanceOf(to!, tokenIds[1]))
    }
    
    func test_safeBatchTransferFromWithoutData() throws {
        let from = TestAccountInfo.LUMAN.address
        let to = KeyringFactory.generate()?.address
        let tokenIds = [BigUInt(2), BigUInt(3)]
        let values = [BigUInt(100), BigUInt(100)]
        
        let receiptData = try kip37?.safeBatchTransferFrom(from, to!, tokenIds, values, SendOptions(TestAccountInfo.LUMAN.address))
        if(receiptData?.status != "0x1") {
            XCTAssert(false)
        }
        
        XCTAssertEqual(BigUInt(100), try kip37?.balanceOf(to!, tokenIds[0]))
        XCTAssertEqual(BigUInt(100), try kip37?.balanceOf(to!, tokenIds[1]))
    }
    
    func test_safeBatchTransferFrom_StringIDWithoutData() throws {
        let from = TestAccountInfo.LUMAN.address
        let to = KeyringFactory.generate()?.address
        let tokenIds = ["0x2", "0x3"]
        let values = [BigUInt(100), BigUInt(100)]
        
        let receiptData = try kip37?.safeBatchTransferFrom(from, to!, tokenIds, values, SendOptions(TestAccountInfo.LUMAN.address))
        if(receiptData?.status != "0x1") {
            XCTAssert(false)
        }
        
        XCTAssertEqual(BigUInt(100), try kip37?.balanceOf(to!, tokenIds[0]))
        XCTAssertEqual(BigUInt(100), try kip37?.balanceOf(to!, tokenIds[1]))
    }
    
    func test_safeTransferFromWithOperator() throws {
        let from = TestAccountInfo.LUMAN.address
        let to = KeyringFactory.generate()?.address
        let tokenId = BigUInt(2)
        let operate = TestAccountInfo.BRANDON.address
        
        guard let approved = try? kip37?.isApprovedForAll(from, operate) else {
            XCTAssert(false)
            return
        }
        
        if !approved {
            let receiptData = try kip37?.setApprovalForAll(operate, true, SendOptions(from))
            if(receiptData?.status != "0x1") {
                XCTAssert(false)
            }
        }
        
        let receiptData = try kip37?.safeTransferFrom(from, to!, tokenId, BigUInt(10), "",  SendOptions(operate))
        if(receiptData?.status != "0x1") {
            XCTAssert(false)
        }
        
        XCTAssertEqual(BigUInt(10), try kip37?.balanceOf(to!, tokenId))
    }
    
    func test_safeTransferFromWithOperator_StringID() throws {
        let from = TestAccountInfo.LUMAN.address
        let to = KeyringFactory.generate()?.address
        let tokenId = "0x2"
        let operate = TestAccountInfo.BRANDON.address
        
        guard let approved = try? kip37?.isApprovedForAll(from, operate) else {
            XCTAssert(false)
            return
        }
        
        if !approved {
            let receiptData = try kip37?.setApprovalForAll(operate, true, SendOptions(from))
            if(receiptData?.status != "0x1") {
                XCTAssert(false)
            }
        }
        
        let receiptData = try kip37?.safeTransferFrom(from, to!, tokenId, BigUInt(10), "",  SendOptions(operate))
        if(receiptData?.status != "0x1") {
            XCTAssert(false)
        }
        
        XCTAssertEqual(BigUInt(10), try kip37?.balanceOf(to!, tokenId))
    }
    
    func test_safeBatchTransferFromWithOperator() throws {
        let from = TestAccountInfo.LUMAN.address
        let to = KeyringFactory.generate()?.address
        let tokenIds = [BigUInt(2), BigUInt(3)]
        let values = [BigUInt(100), BigUInt(100)]
        let operate = TestAccountInfo.BRANDON.address
        
        guard let approved = try? kip37?.isApprovedForAll(from, operate) else {
            XCTAssert(false)
            return
        }
        
        if !approved {
            let receiptData = try kip37?.setApprovalForAll(operate, true, SendOptions(from))
            if(receiptData?.status != "0x1") {
                XCTAssert(false)
            }
        }
        
        let receiptData = try kip37?.safeBatchTransferFrom(from, to!, tokenIds, values, "data", SendOptions(TestAccountInfo.LUMAN.address))
        if(receiptData?.status != "0x1") {
            XCTAssert(false)
        }
        
        XCTAssertEqual(BigUInt(100), try kip37?.balanceOf(to!, tokenIds[0]))
        XCTAssertEqual(BigUInt(100), try kip37?.balanceOf(to!, tokenIds[1]))
    }
    
    func test_safeBatchTransferFromWithOperator_StringID() throws {
        let from = TestAccountInfo.LUMAN.address
        let to = KeyringFactory.generate()?.address
        let tokenIds = ["0x2", "0x3"]
        let values = [BigUInt(100), BigUInt(100)]
        let operate = TestAccountInfo.BRANDON.address
        
        guard let approved = try? kip37?.isApprovedForAll(from, operate) else {
            XCTAssert(false)
            return
        }
        
        if !approved {
            let receiptData = try kip37?.setApprovalForAll(operate, true, SendOptions(from))
            if(receiptData?.status != "0x1") {
                XCTAssert(false)
            }
        }
        
        let receiptData = try kip37?.safeBatchTransferFrom(from, to!, tokenIds, values, "data", SendOptions(TestAccountInfo.LUMAN.address))
        if(receiptData?.status != "0x1") {
            XCTAssert(false)
        }
        
        XCTAssertEqual(BigUInt(100), try kip37?.balanceOf(to!, tokenIds[0]))
        XCTAssertEqual(BigUInt(100), try kip37?.balanceOf(to!, tokenIds[1]))
    }
    
    func test_supportsInterface() throws {
        let INTERFACE_ID_KIP13 = "0x01ffc9a7"
        let INTERFACE_ID_KIP37  = "0x6433ca1f"
        let INTERFACE_ID_KIP37_PAUSABLE = "0x0e8ffdb7"
        let INTERFACE_ID_KIP37_BURNABLE = "0x9e094e9e"
        let INTERFACE_ID_KIP37_MINTABLE = "0xdfd9d9ec"
        let INTERFACE_ID_FALSE = "0xFFFFFFFF"
        
        let isSupported_KIP13 = try kip37?.supportsInterface(INTERFACE_ID_KIP13)
        XCTAssertTrue(isSupported_KIP13 ?? false)
        
        let isSupported_KIP37_PAUSABLE = try kip37?.supportsInterface(INTERFACE_ID_KIP37_PAUSABLE)
        XCTAssertTrue(isSupported_KIP37_PAUSABLE ?? false)
        
        let isSupported_KIP37_BURNABLE = try kip37?.supportsInterface(INTERFACE_ID_KIP37_BURNABLE)
        XCTAssertTrue(isSupported_KIP37_BURNABLE ?? false)
        
        let isSupported_KIP37_MINTABLE = try kip37?.supportsInterface(INTERFACE_ID_KIP37_MINTABLE)
        XCTAssertTrue(isSupported_KIP37_MINTABLE ?? false)
        
        let isSupported_KIP37 = try kip37?.supportsInterface(INTERFACE_ID_KIP37)
        XCTAssertTrue(isSupported_KIP37 ?? false)
        
        let isSupported_FALSE = try kip37?.supportsInterface(INTERFACE_ID_FALSE)
        XCTAssertFalse(isSupported_FALSE ?? true)
    }
}

class KIP37Test_F_DetectInterfaceTest: XCTestCase {
    public var kip37: KIP37?
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
            if let file  = Bundle.module.url(forResource: "KIP37TestData", withExtension: "json"){
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
        
        if KIP37Test.kip37 == nil {
            try KIP37Test.deployContract(KIP37Test.tokenURI)
        }
        
        kip37 = KIP37Test.kip37
    }
    
    func test_detectInterface() throws {
        guard let result = try kip37?.detectInterface() else {
            XCTAssert(false)
            return
        }
        XCTAssertTrue(result[KIP37.INTERFACE.IKIP37.getName()] ?? false)
        XCTAssertTrue(result[KIP37.INTERFACE.IKIP37_METADATA.getName()] ?? false)
        XCTAssertTrue(result[KIP37.INTERFACE.IKIP37_MINTABLE.getName()] ?? false)
        XCTAssertTrue(result[KIP37.INTERFACE.IKIP37_BURNABLE.getName()] ?? false)
        XCTAssertTrue(result[KIP37.INTERFACE.IKIP37_PAUSABLE.getName()] ?? false)
    }
    
    func test_detectInterface_staticMethod() throws {
        guard let kip37 = kip37,
              let result = try? KIP37.detectInterface(kip37.caver, kip37.contractAddress!) else {
            XCTAssert(false)
            return
        }
        XCTAssertTrue(result[KIP37.INTERFACE.IKIP37.getName()] ?? false)
        XCTAssertTrue(result[KIP37.INTERFACE.IKIP37_METADATA.getName()] ?? false)
        XCTAssertTrue(result[KIP37.INTERFACE.IKIP37_MINTABLE.getName()] ?? false)
        XCTAssertTrue(result[KIP37.INTERFACE.IKIP37_BURNABLE.getName()] ?? false)
        XCTAssertTrue(result[KIP37.INTERFACE.IKIP37_PAUSABLE.getName()] ?? false)
    }
    
    func test_only_mintable() throws {
        let contract = try Contract(caver!, abi_mintable)
        _ = try contract.deploy(SendOptions(TestAccountInfo.LUMAN.address, BigUInt(10000000)), byteCodeWithMintable, "uri")
        guard let result = try? KIP37.detectInterface(caver!, contract.contractAddress!) else {
            XCTAssert(false)
            return
        }
        XCTAssertTrue(result[KIP37.INTERFACE.IKIP37.getName()] ?? false)
        XCTAssertFalse(result[KIP37.INTERFACE.IKIP37_BURNABLE.getName()] ?? true)
        XCTAssertTrue(result[KIP37.INTERFACE.IKIP37_METADATA.getName()] ?? false)
        XCTAssertFalse(result[KIP37.INTERFACE.IKIP37_MINTABLE.getName()] ?? true)
        XCTAssertFalse(result[KIP37.INTERFACE.IKIP37_PAUSABLE.getName()] ?? true)
    }
    
    func test_withoutBurnable_Pausable() throws {
        let contract = try Contract(caver!, abi_without_pausable_burnable)
        _ = try contract.deploy(SendOptions(TestAccountInfo.LUMAN.address, BigUInt(10000000)), byteCodeWithoutBurnablePausable, "uri")
        guard let result = try? KIP37.detectInterface(caver!, contract.contractAddress!) else {
            XCTAssert(false)
            return
        }
        XCTAssertTrue(result[KIP37.INTERFACE.IKIP37.getName()] ?? false)
        XCTAssertFalse(result[KIP37.INTERFACE.IKIP37_BURNABLE.getName()] ?? true)
        XCTAssertTrue(result[KIP37.INTERFACE.IKIP37_METADATA.getName()] ?? false)
        XCTAssertTrue(result[KIP37.INTERFACE.IKIP37_MINTABLE.getName()] ?? false)
        XCTAssertFalse(result[KIP37.INTERFACE.IKIP37_PAUSABLE.getName()] ?? true)
    }
    
    func test_without_burnable_pausable() throws {
        let contract = try Contract(caver!, abi_not_supported_kip13)
        _ = try contract.deploy(SendOptions(TestAccountInfo.LUMAN.address, BigUInt(10000000)), byteCodeNotSupportedKIP13)
        
                
        XCTAssertThrowsError(try KIP37.detectInterface(caver!, contract.contractAddress!)) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("This contract does not support KIP-13."))
        }
    }
}

class KIP37Test_G_UriTest: XCTestCase {
    public var caver: Caver?
    
    override func setUpWithError() throws {
        if caver != nil {
            return
        }
        
        caver = Caver(Caver.DEFAULT_URL)
        _ = try caver?.wallet.add(KeyringFactory.createFromPrivateKey("0x2359d1ae7317c01532a58b01452476b796a3ac713336e97d8d3c9651cc0aecc3"))
    }
    
    func test_uriWithID() throws {
        let expected = "https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json"

        let tokenURI = "https://token-cdn-domain/{id}.json"
        let kip37 = try KIP37.deploy(caver!, tokenURI, TestAccountInfo.LUMAN.address)

        let uriFromStr = try kip37.uri("0x4cce0")
        XCTAssertEqual(expected, uriFromStr)
        
        let uriFromInt = try kip37.uri(BigUInt(314592))
        XCTAssertEqual(expected, uriFromInt)
    }
    
    func test_uriWithoutID() throws {
        let tokenURI = "https://token-cdn-domain/example.json"
        let kip37 = try KIP37.deploy(caver!, tokenURI, TestAccountInfo.LUMAN.address)

        let uriFromStr = try kip37.uri("0x4cce0")
        XCTAssertEqual(tokenURI, uriFromStr)
        
        let uriFromInt = try kip37.uri(BigUInt(314592))
        XCTAssertEqual(tokenURI, uriFromInt)
    }
}
