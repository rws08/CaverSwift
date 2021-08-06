//
//  UtilsTest.swift
//  CaverSwiftTests
//
//  Created by won on 2021/06/23.
//

import XCTest
@testable import CaverSwift
@testable import ASN1

class UtilsTest_isAddressTest: XCTestCase {
    func testLowerCaseAddressTest() throws {
        let lowercase = ["0xff6916ea19a50878e39c41aaadfeb0cab1b41dad",
                         "0x4834113481fbbac68565987d30f5216bc5719d3b",
                         "ff6916ea19a50878e39c41aaadfeb0cab1b41dad",
                         "4834113481fbbac68565987d30f5216bc5719d3b"]
        for item in lowercase {
            XCTAssertTrue(Utils.isAddress(item), "fail : \(item)")
        }
    }
    
    func testUpperCaseAddressTest() throws {
        let uppercase = ["0xFF6916EA19A50878E39C41AAADFEB0CAB1B41DAD",
                         "0x4834113481FBBAC68565987D30F5216BC5719D3B",
                         "4834113481FBBAC68565987D30F5216BC5719D3B",
                         "FF6916EA19A50878E39C41AAADFEB0CAB1B41DAD"]
        for item in uppercase {
            XCTAssertTrue(Utils.isAddress(item), "fail : \(item)")
        }
    }
    
    func testChecksumAddressTest() throws {
        let checksumAddress = ["0xdbF03B407c01E7cD3CBea99509d93f8DDDC8C6FB",
                               "0xD1220A0cf47c7B9Be7A2E6BA89F429762e7b9aDb",
                               "0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359",
                               "0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed"]
        for item in checksumAddress {
            XCTAssertTrue(Utils.isAddress(item), "fail : \(item)")
        }
    }
    
    func testInvalidAddressTest() throws {
        let checksumAddress = ["0xff6916ea19a50878e39c41cab1b41da",// Length is not 40
                               "0xKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK", // Not Hex String
                               "0x2058a550ea824841e991ef386c3aD63D088303B3"] // Invalid checksum address.
        for item in checksumAddress {
            XCTAssertFalse(Utils.isAddress(item), "fail : \(item)")
        }
    }
}

class UtilsTest_isValidPrivateKeyTest: XCTestCase {
    func testValidPrivateKey() throws {
        let key = PrivateKey.generate().privateKey
        XCTAssertTrue(Utils.isValidPrivateKey(key))
    }
    
    func testInvalidPrivateKey() throws {
        let keys = ["0xff6916ea19a50878e39c41cab1b41d0xff6916ea19a50878e39c41cab1bdd41dK",// Length is not 64
                    "0xff6916ea19a50878e39c41cab1b41d0xff6916ea19a50878e39c41cab1bdd4KK"] // Not Hex String
        for item in keys {
            XCTAssertFalse(Utils.isValidPrivateKey(item), "fail : \(item)")
            XCTAssertFalse(Utils.isAddress(item), "fail : \(item)")
        }
    }
}

class UtilsTest_isKlaytnWalletKeyTest: XCTestCase {
    func testValidWalletKey() throws {
        guard let walletKey = KeyringFactory.generate()?.getKlaytnWalletKey() else { XCTAssert(false)
            return }
        XCTAssertTrue(Utils.isKlaytnWalletKey(walletKey))
    }
    
    func testInValidWalletKey() throws {
        let keys = ["0x63526af77dc34846a0909e5486f972c4a07074f0c94a2b9577675a6433098481" + "0x01" + "0xfc26de905386050894cddbb5a824318b96dde595", // invalid type
                    "0x63526af77dc34846a0909e5486f972c4a07074f0c94a2b9577675a6433098481" + "0xfc26de905386050894cddbb5a824318b96dde595", // no Type
                    "0x63526af77dc34846a0909e5486f972c4a07074f0c94a2b9577675a6433098481" + "0x00" + "0xfc26de905386050894cddbb5a824318b96dde59", // invalid address - invalid length
                    "0x63526af77dc34846a0909e5486f972c4a07074f0c94a2b9577675a6433098481" + "0x00" + "fc26de905386050894cddbb5a824318b96dde595", // invalid address - no prefix
                    "0x63526af77dc34846a0909e5486f972c4a07074f0c94a2b9575a6433098481" + "0x00" + "0xfc26de905386050894cddbb5a824318b96dde595", // invalid privateKey - invalid length
                    "63526af77dc34846a0909e5486f972c4a07074f0c94a2b9577675a6433098481" + "0x00" + "0xfc26de905386050894cddbb5a824318b96dde595"] // invalid type - no prefix
        for item in keys {
            XCTAssertFalse(Utils.isAddress(item), "fail : \(item)")
        }
    }
}

class UtilsTest_isValidPublicKeyTest: XCTestCase {
    func testUncompressedKey() throws {
        guard let key = try? KeyringFactory.generate()?.getPublicKey() else { XCTAssert(false)
            return }
        XCTAssertTrue(Utils.isValidPublicKey(key))
    }
    
    func testUncompressedKeyWithTag() throws {
        let key = "0x04019b186993b620455077b6bc37bf61666725d8d87ab33eb113ac0414cd48d78ff46e5ea48c6f22e8f19a77e5dbba9d209df60cbcb841b7e3e81fe444ba829831"
        XCTAssertTrue(Utils.isValidPublicKey(key))
    }
    
    func testCompressedKey() throws {
        guard let key = try? KeyringFactory.generate()?.getPublicKey(),
              let key = try? Utils.compressPublicKey(key) else { XCTAssert(false)
            return }
        
        XCTAssertTrue(Utils.isValidPublicKey(key))
    }
    
    func testInvalidLength_UncompressedKey() throws {
        let key = "0a7694872b7f0862d896780c476eefe5dcbcab6145853401f95a610bbbb0f726c1013a286500f3b524834eaeb383d1a882e16f4923cef8a5316c33772b3437"
        XCTAssertFalse(Utils.isValidPublicKey(key))
    }
    
    func testInvalidLength_CompressedKey() throws {
        let key = "0x03434dedfc2eceed1e98fddfde3ebc57512c57f017195988cd5de62b722656b93"
        XCTAssertFalse(Utils.isValidPublicKey(key))
    }
    
    func testInvalidIndicator_CompressedKey() throws {
        let key = "0x05434dedfc2eceed1e98fddfde3ebc57512c57f017195988cd5de62b722656b943"
        XCTAssertFalse(Utils.isValidPublicKey(key))
    }
    
    func testInvalidPoint() throws {
        let key = "0x4be11ff42d8fc1954fb9ed52296db1657564c5e38517764664fb7cf4306a1e163a2686aa755dd0291aa2f291c3560ef4bf4b46c671983ff3e23f11a1b744ff4a"
        XCTAssertFalse(Utils.isValidPublicKey(key))
    }
}

class UtilsTest_decompressPublicKeyTest: XCTestCase {
    func testDecompressPublicKey() throws {
        let compressed = "03434dedfc2eceed1e98fddfde3ebc57512c57f017195988cd5de62b722656b943"
        guard let uncompressed = try? Utils.decompressPublicKey(compressed) else { XCTAssert(false)
            return }
        
        XCTAssertTrue(Utils.isValidPublicKey(uncompressed))
    }
    
    func testAlreadyDecompressedKey() throws {
        guard let expectedUncompressed = try? PrivateKey.generate().getPublicKey(false),
              let actualUncompressed = try? Utils.decompressPublicKey(expectedUncompressed) else { XCTAssert(false)
            return }
        
        XCTAssertTrue(Utils.isValidPublicKey(actualUncompressed))
        XCTAssertEqual(expectedUncompressed, actualUncompressed)
    }
    
    func testAlreadyDecompressedKeyWithTag() throws {
        let expected = "0x04019b186993b620455077b6bc37bf61666725d8d87ab33eb113ac0414cd48d78ff46e5ea48c6f22e8f19a77e5dbba9d209df60cbcb841b7e3e81fe444ba829831"
        guard let uncompressed = try? Utils.decompressPublicKey(expected) else { XCTAssert(false)
            return }
        
        XCTAssertEqual(expected, uncompressed)
    }
}

class UtilsTest_compressPublicKeyTest: XCTestCase {
    func testCompressPublicKey() throws {
        guard let uncompressed = try? PrivateKey.generate().getPublicKey(false),
              let compressed = try? Utils.compressPublicKey(uncompressed) else { XCTAssert(false)
            return }
        
        XCTAssertTrue(Utils.isValidPublicKey(compressed))
    }
    
    func testAlreadyCompressedKey() throws {
        guard let expectedCompressed = try? PrivateKey.generate().getPublicKey(true),
              let actualCompressed = try? Utils.compressPublicKey(expectedCompressed) else { XCTAssert(false)
            return }
        
        XCTAssertTrue(Utils.isValidPublicKey(actualCompressed))
        XCTAssertEqual(expectedCompressed, actualCompressed)
    }
    
    func testAlreadyCompressedKeyWithTag() throws {
        let key = "0x04019b186993b620455077b6bc37bf61666725d8d87ab33eb113ac0414cd48d78ff46e5ea48c6f22e8f19a77e5dbba9d209df60cbcb841b7e3e81fe444ba829831"
        guard let expected = try? Utils.compressPublicKey("019b186993b620455077b6bc37bf61666725d8d87ab33eb113ac0414cd48d78ff46e5ea48c6f22e8f19a77e5dbba9d209df60cbcb841b7e3e81fe444ba829831"),
              let compressed = try? Utils.compressPublicKey(key) else { XCTAssert(false)
            return }
        
        XCTAssertEqual(expected, compressed)
    }
}

class UtilsTest_hashMessageTest: XCTestCase {
    func testHashMessage() throws {
        let data = "0xdeadbeaf"
        XCTAssertEqual(66, Utils.hashMessage(data).count)
    }
}

class UtilsTest_parseKlaytnWalletKeyTest: XCTestCase {
    func testParseKlaytnWalletKey() throws {
        let keyring = KeyringFactory.generate()
        guard let walletKey = keyring?.getKlaytnWalletKey(),
              let parsedData = try? Utils.parseKlaytnWalletKey(walletKey) else { XCTAssert(false)
            return }
        
        XCTAssertEqual(keyring?.key.privateKey, parsedData[0])
        XCTAssertEqual("0x00", parsedData[1])
        XCTAssertEqual(keyring?.address, parsedData[2])
    }
    
    func testInvalidKlaytnWalletKey_invalidType() throws {
        let invalid = "0x63526af77dc34846a0909e5486f972c4a07074f0c94a2b9577675a6433098481"
        XCTAssertThrowsError(try Utils.parseKlaytnWalletKey(invalid)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid Klaytn wallet key."))
        }
    }
    
    func testInvalidKlaytnWalletKey_invalidPrivateKey() throws {
        let invalid = "0x63526af77dc34846a0909e5486f972c4a07074f0c94a2b9577675a64330984"
        XCTAssertThrowsError(try Utils.parseKlaytnWalletKey(invalid)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid Klaytn wallet key."))
        }
    }
    
    func testInvalidKlaytnWalletKey_invalidAddress() throws {
        let invalid = "0x63526af77dc34846a0909e5486f972c4a07074f0c94a2b9577675a6433098481"
        XCTAssertThrowsError(try Utils.parseKlaytnWalletKey(invalid)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid Klaytn wallet key."))
        }
    }
}

class UtilsTest_isHexTest: XCTestCase {
    func testValidHex() throws {
        let hex = ["0x1234",
                   "ffff",
                   "0xaaaa",
                   "34567"]
        for item in hex {
            XCTAssertTrue(Utils.isHex(item), "fail : \(item)")
        }
    }
    
    func testInvalidHex() throws {
        let invalidHex = "0xkkkkk"
        XCTAssertFalse(Utils.isHex(invalidHex))
    }
}

class UtilsTest_isHexStrictTest: XCTestCase {
    func testValidHex() throws {
        let hex = ["0x1234",
                   "0xaaaa",
                   "0xffff"]
        for item in hex {
            XCTAssertTrue(Utils.isHexStrict(item), "fail : \(item)")
        }
    }
    
    func testInvalidHex() throws {
        let hex = ["0xKKKKKKK",
                   "1234"]
        for item in hex {
            XCTAssertFalse(Utils.isHexStrict(item), "fail : \(item)")
        }
    }
}

class UtilsTest_addHexPrefixTest: XCTestCase {
    func testAddHexPrefix() throws {
        let hex = "1234"
        let expected = "0x1234"

        XCTAssertEqual(expected, Utils.addHexPrefix(hex))
    }
    
    func testAlreadyPrefixed() throws {
        let hex = "0x1234"
        
        XCTAssertEqual(hex, Utils.addHexPrefix(hex))
    }
}

class UtilsTest_stripHexPrefixTest: XCTestCase {
    func testStripHexPrefix() throws {
        let hex = "0x1234"
        let expected = "1234"

        XCTAssertEqual(expected, Utils.stripHexPrefix(hex))
    }
    
    func testAlreadyStriped() throws {
        let hex = "1234"
        
        XCTAssertEqual(hex, Utils.stripHexPrefix(hex))
    }
}

class UtilsTest_convertToPebTest: XCTestCase {
    func testFrom_peb() throws {
        let expected = "1"
        var converted = Utils.convertToPeb(BigInt(1), "peb")
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertToPeb("1", "peb")
        XCTAssertEqual(expected, converted)
    }
    
    func testFrom_peb_enum() throws {
        let expected = "1"
        var converted = Utils.convertToPeb(BigInt(1), .peb)
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertToPeb("1", .peb)
        XCTAssertEqual(expected, converted)
    }
    
    func testFrom_kpeb() throws {
        let expected = "1000"
        var converted = Utils.convertToPeb(BigInt(1), "kpeb")
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertToPeb("1", "kpeb")
        XCTAssertEqual(expected, converted)
    }
    
    func testFrom_kpeb_enum() throws {
        let expected = "1000"
        var converted = Utils.convertToPeb(BigInt(1), .kpeb)
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertToPeb("1", .kpeb)
        XCTAssertEqual(expected, converted)
    }
    
    func testFrom_Mpeb() throws {
        let expected = "1000000"
        var converted = Utils.convertToPeb(BigInt(1), "Mpeb")
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertToPeb("1", "Mpeb")
        XCTAssertEqual(expected, converted)
    }
    
    func testFrom_Mpeb_enum() throws {
        let expected = "1000000"
        var converted = Utils.convertToPeb(BigInt(1), .Mpeb)
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertToPeb("1", .Mpeb)
        XCTAssertEqual(expected, converted)
    }
    
    func testFrom_Gpeb() throws {
        let expected = "1000000000"
        var converted = Utils.convertToPeb(BigInt(1), "Gpeb")
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertToPeb("1", "Gpeb")
        XCTAssertEqual(expected, converted)
    }
    
    func testFrom_Gpeb_enum() throws {
        let expected = "1000000000"
        var converted = Utils.convertToPeb(BigInt(1), .Gpeb)
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertToPeb("1", .Gpeb)
        XCTAssertEqual(expected, converted)
    }
    
    func testFrom_ston() throws {
        let expected = "1000000000"
        var converted = Utils.convertToPeb(BigInt(1), "ston")
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertToPeb("1", "ston")
        XCTAssertEqual(expected, converted)
    }
    
    func testFrom_ston_enum() throws {
        let expected = "1000000000"
        var converted = Utils.convertToPeb(BigInt(1), .ston)
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertToPeb("1", .ston)
        XCTAssertEqual(expected, converted)
    }
    
    func testFrom_uKLAY() throws {
        let expected = "1000000000000"
        var converted = Utils.convertToPeb(BigInt(1), "uKLAY")
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertToPeb("1", "uKLAY")
        XCTAssertEqual(expected, converted)
    }
    
    func testFrom_uKLAY_enum() throws {
        let expected = "1000000000000"
        var converted = Utils.convertToPeb(BigInt(1), .uKLAY)
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertToPeb("1", .uKLAY)
        XCTAssertEqual(expected, converted)
    }
    
    func testFrom_mKLAY() throws {
        let expected = "1000000000000000"
        var converted = Utils.convertToPeb(BigInt(1), "mKLAY")
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertToPeb("1", "mKLAY")
        XCTAssertEqual(expected, converted)
    }
    
    func testFrom_mKLAY_enum() throws {
        let expected = "1000000000000000"
        var converted = Utils.convertToPeb(BigInt(1), .mKLAY)
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertToPeb("1", .mKLAY)
        XCTAssertEqual(expected, converted)
    }
    
    func testFrom_KLAY() throws {
        let expected = "1000000000000000000"
        var converted = Utils.convertToPeb(BigInt(1), "KLAY")
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertToPeb("1", "KLAY")
        XCTAssertEqual(expected, converted)
    }
    
    func testFrom_KLAY_enum() throws {
        let expected = "1000000000000000000"
        var converted = Utils.convertToPeb(BigInt(1), .KLAY)
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertToPeb("1", .KLAY)
        XCTAssertEqual(expected, converted)
    }
    
    func testFrom_kKLAY() throws {
        let expected = "1000000000000000000000"
        var converted = Utils.convertToPeb(BigInt(1), "kKLAY")
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertToPeb("1", "kKLAY")
        XCTAssertEqual(expected, converted)
    }
    
    func testFrom_kKLAY_enum() throws {
        let expected = "1000000000000000000000"
        var converted = Utils.convertToPeb(BigInt(1), .kKLAY)
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertToPeb("1", .kKLAY)
        XCTAssertEqual(expected, converted)
    }
    
    func testFrom_MKLAY() throws {
        let expected = "1000000000000000000000000"
        var converted = Utils.convertToPeb(BigInt(1), "MKLAY")
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertToPeb("1", "MKLAY")
        XCTAssertEqual(expected, converted)
    }
    
    func testFrom_MKLAY_enum() throws {
        let expected = "1000000000000000000000000"
        var converted = Utils.convertToPeb(BigInt(1), .MKLAY)
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertToPeb("1", .MKLAY)
        XCTAssertEqual(expected, converted)
    }
    
    func testFrom_GKLAY() throws {
        let expected = "1000000000000000000000000000"
        var converted = Utils.convertToPeb(BigInt(1), "GKLAY")
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertToPeb("1", "GKLAY")
        XCTAssertEqual(expected, converted)
    }
    
    func testFrom_GKLAY_enum() throws {
        let expected = "1000000000000000000000000000"
        var converted = Utils.convertToPeb(BigInt(1), .GKLAY)
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertToPeb("1", .GKLAY)
        XCTAssertEqual(expected, converted)
    }
    
    func testFrom_TKLAY() throws {
        let expected = "1000000000000000000000000000000"
        var converted = Utils.convertToPeb(BigInt(1), "TKLAY")
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertToPeb("1", "TKLAY")
        XCTAssertEqual(expected, converted)
    }
    
    func testFrom_TKLAY_enum() throws {
        let expected = "1000000000000000000000000000000"
        var converted = Utils.convertToPeb(BigInt(1), .TKLAY)
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertToPeb("1", .TKLAY)
        XCTAssertEqual(expected, converted)
    }
}

class UtilsTest_convertFromPebTest: XCTestCase {
    func testTo_peb() throws {
        let amount = "1000000000000000000000000000"
        let expected = amount
        var converted = Utils.convertFromPeb(amount, "peb")
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertFromPeb(BigInt(amount)!, "peb")
        XCTAssertEqual(expected, converted)
    }
    
    func testTo_peb_enum() throws {
        let amount = "1000000000000000000000000000"
        let expected = amount
        var converted = Utils.convertFromPeb(amount, .peb)
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertFromPeb(BigInt(amount)!, .peb)
        XCTAssertEqual(expected, converted)
    }
    
    func testTo_kpeb() throws {
        let amount = "1000000000000000000000000000"
        let expected = "1000000000000000000000000"
        var converted = Utils.convertFromPeb(amount, "kpeb")
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertFromPeb(BigInt(amount)!, "kpeb")
        XCTAssertEqual(expected, converted)
    }
    
    func testTo_kpeb_enum() throws {
        let amount = "1000000000000000000000000000"
        let expected = "1000000000000000000000000"
        var converted = Utils.convertFromPeb(amount, .kpeb)
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertFromPeb(BigInt(amount)!, .kpeb)
        XCTAssertEqual(expected, converted)
    }
    
    func testTo_Mpeb() throws {
        let amount = "1000000000000000000000000000"
        let expected = "1000000000000000000000"
        var converted = Utils.convertFromPeb(amount, "Mpeb")
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertFromPeb(BigInt(amount)!, "Mpeb")
        XCTAssertEqual(expected, converted)
    }
    
    func testTo_Mpeb_enum() throws {
        let amount = "1000000000000000000000000000"
        let expected = "1000000000000000000000"
        var converted = Utils.convertFromPeb(amount, .Mpeb)
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertFromPeb(BigInt(amount)!, .Mpeb)
        XCTAssertEqual(expected, converted)
    }
    
    func testTo_Gpeb() throws {
        let amount = "1000000000000000000000000000"
        let expected = "1000000000000000000"
        var converted = Utils.convertFromPeb(amount, "Gpeb")
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertFromPeb(BigInt(amount)!, "Gpeb")
        XCTAssertEqual(expected, converted)
    }
    
    func testTo_Gpeb_enum() throws {
        let amount = "1000000000000000000000000000"
        let expected = "1000000000000000000"
        var converted = Utils.convertFromPeb(amount, .Gpeb)
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertFromPeb(BigInt(amount)!, .Gpeb)
        XCTAssertEqual(expected, converted)
    }
    
    func testTo_ston() throws {
        let amount = "1000000000000000000000000000"
        let expected = "1000000000000000000"
        var converted = Utils.convertFromPeb(amount, "ston")
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertFromPeb(BigInt(amount)!, "ston")
        XCTAssertEqual(expected, converted)
    }
    
    func testTo_ston_enum() throws {
        let amount = "1000000000000000000000000000"
        let expected = "1000000000000000000"
        var converted = Utils.convertFromPeb(amount, .ston)
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertFromPeb(BigInt(amount)!, .ston)
        XCTAssertEqual(expected, converted)
    }
    
    func testTo_uKLAY() throws {
        let amount = "1000000000000000000000000000"
        let expected = "1000000000000000"
        var converted = Utils.convertFromPeb(amount, "uKLAY")
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertFromPeb(BigInt(amount)!, "uKLAY")
        XCTAssertEqual(expected, converted)
    }
    
    func testTo_uKLAY_enum() throws {
        let amount = "1000000000000000000000000000"
        let expected = "1000000000000000"
        var converted = Utils.convertFromPeb(amount, .uKLAY)
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertFromPeb(BigInt(amount)!, .uKLAY)
        XCTAssertEqual(expected, converted)
    }
    
    func testTo_mKLAY() throws {
        let amount = "1000000000000000000000000000"
        let expected = "1000000000000"
        var converted = Utils.convertFromPeb(amount, "mKLAY")
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertFromPeb(BigInt(amount)!, "mKLAY")
        XCTAssertEqual(expected, converted)
    }
    
    func testTo_mKLAY_enum() throws {
        let amount = "1000000000000000000000000000"
        let expected = "1000000000000"
        var converted = Utils.convertFromPeb(amount, .mKLAY)
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertFromPeb(BigInt(amount)!, .mKLAY)
        XCTAssertEqual(expected, converted)
    }
    
    func testTo_KLAY() throws {
        let amount = "1000000000000000000000000000"
        let expected = "1000000000"
        var converted = Utils.convertFromPeb(amount, "KLAY")
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertFromPeb(BigInt(amount)!, "KLAY")
        XCTAssertEqual(expected, converted)
    }
    
    func testTo_KLAY_enum() throws {
        let amount = "1000000000000000000000000000"
        let expected = "1000000000"
        var converted = Utils.convertFromPeb(amount, .KLAY)
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertFromPeb(BigInt(amount)!, .KLAY)
        XCTAssertEqual(expected, converted)
    }
    
    func testTo_kKLAY() throws {
        let amount = "1000000000000000000000000000"
        let expected = "1000000"
        var converted = Utils.convertFromPeb(amount, "kKLAY")
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertFromPeb(BigInt(amount)!, "kKLAY")
        XCTAssertEqual(expected, converted)
    }
    
    func testTo_kKLAY_enum() throws {
        let amount = "1000000000000000000000000000"
        let expected = "1000000"
        var converted = Utils.convertFromPeb(amount, .kKLAY)
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertFromPeb(BigInt(amount)!, .kKLAY)
        XCTAssertEqual(expected, converted)
    }
    
    func testTo_MKLAY() throws {
        let amount = "1000000000000000000000000000"
        let expected = "1000"
        var converted = Utils.convertFromPeb(amount, "MKLAY")
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertFromPeb(BigInt(amount)!, "MKLAY")
        XCTAssertEqual(expected, converted)
    }
    
    func testTo_MKLAY_enum() throws {
        let amount = "1000000000000000000000000000"
        let expected = "1000"
        var converted = Utils.convertFromPeb(amount, .MKLAY)
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertFromPeb(BigInt(amount)!, .MKLAY)
        XCTAssertEqual(expected, converted)
    }
    
    func testTo_GKLAY() throws {
        let amount = "1000000000000000000000000000"
        let expected = "1"
        var converted = Utils.convertFromPeb(amount, "GKLAY")
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertFromPeb(BigInt(amount)!, "GKLAY")
        XCTAssertEqual(expected, converted)
    }
    
    func testTo_GKLAY_enum() throws {
        let amount = "1000000000000000000000000000"
        let expected = "1"
        var converted = Utils.convertFromPeb(amount, .GKLAY)
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertFromPeb(BigInt(amount)!, .GKLAY)
        XCTAssertEqual(expected, converted)
    }
    
    func testTo_TKLAY() throws {
        let amount = "1000000000000000000000000000000"
        let expected = "1"
        var converted = Utils.convertFromPeb(amount, "TKLAY")
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertFromPeb(BigInt(amount)!, "TKLAY")
        XCTAssertEqual(expected, converted)
    }
    
    func testTo_TKLAY_enum() throws {
        let amount = "1000000000000000000000000000000"
        let expected = "1"
        var converted = Utils.convertFromPeb(amount, .TKLAY)
        XCTAssertEqual(expected, converted)
        
        converted = Utils.convertFromPeb(BigInt(amount)!, .TKLAY)
        XCTAssertEqual(expected, converted)
    }
}

class UtilsTest_isNumberTest: XCTestCase {
    func testValidHexNumber() throws {
        let valid = ["0x1234",
                     "1234",
                     "aaaaaaa",
                     "0xaaaaaa"]
        for item in valid {
            XCTAssertTrue(Utils.isNumber(item), "fail : \(item)")
        }
    }
    
    func testInvalidHexNumber() throws {
        let invalid = ["kkkkkkkkkk",
                       "0x1234k"]
        for item in invalid {
            XCTAssertFalse(Utils.isNumber(item), "fail : \(item)")
        }
    }
}

class UtilsTest_isEmptySigTest: XCTestCase {
    func testValidEmptySig() throws {
        let emptySig = SignatureData("0x01", "0x", "0x")
        XCTAssertTrue(Utils.isEmptySig(emptySig))
    }
    
    func testValidEmptySigList() throws {
        let emptySigArr = [SignatureData("0x01", "0x", "0x"),
                           SignatureData("0x01", "0x", "0x")]
        XCTAssertTrue(Utils.isEmptySig(emptySigArr))
    }
    
    func testNotEmptySigData() throws {
        let signatureData = SignatureData("0x25",
                                        "0xb2a5a15550ec298dc7dddde3774429ed75f864c82caeb5ee24399649ad731be9",
                                        "0x29da1014d16f2011b3307f7bbe1035b6e699a4204fc416c763def6cefd976567")
        XCTAssertFalse(Utils.isEmptySig(signatureData))
    }
    
    func testNotEmptySigDataList() throws {
        let signatureDataArr = [SignatureData("0x25",
                                         "0xb2a5a15550ec298dc7dddde3774429ed75f864c82caeb5ee24399649ad731be9",
                                         "0x29da1014d16f2011b3307f7bbe1035b6e699a4204fc416c763def6cefd976567"),
                           SignatureData("0x25",
                                         "0xb2a5a15550ec298dc7dddde3774429ed75f864c82caeb5ee24399649ad731be9",
                                         "0x29da1014d16f2011b3307f7bbe1035b6e699a4204fc416c763def6cefd976567")]
        XCTAssertFalse(Utils.isEmptySig(signatureDataArr))
    }
}

class UtilsTest_generateRandomBytesTest: XCTestCase {
    func testGenerateRandomBytes() throws {
        let arr = Utils.generateRandomBytes(32)
        
        XCTAssertEqual(32, arr.count)
    }
}
