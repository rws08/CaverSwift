//
//  TestAccountInfo.swift
//  CaverSwiftTests
//
//  Created by won on 2021/07/22.
//

import Foundation

public class TestAccountInfo {
    static let LUMAN = TestAccount(
        "0x2c8ad0ea2e0781db8b8c9242e07de3a5beabb71a",
        "0x2359d1ae7317c01532a58b01452476b796a3ac713336e97d8d3c9651cc0aecc3"
    )

    static let WAYNE = TestAccount(
        "0x3cd93ba290712e6d28ac98f2b820faf799ae8fdb",
        "0x92c0815f28b20cc22fff5fcf41adc80efe9d7ebe00439628b468f2f88a0aadc4"
    )

    static let BRANDON = TestAccount(
        "0xe97f27e9a5765ce36a7b919b1cb6004c7209217e",
        "0x734aa75ef35fd4420eea2965900e90040b8b9f9f7484219b1a06d06394330f4e"
    )

    static let FEE_PAYER = TestAccount(
        "0x9d0dcbe163be73163348e7f96accb2b9e1e9dcf6",
        "0x1e558ea00698990d875cb69d3c8f9a234fe8eab5c6bd898488d851669289e178"
    )
    
    static let TEST = TestAccount(
        "0x5458d5A35b901fe09270655BEA8ffA67F37010b3",
        "0x0b2791a154bce37238d18f0b8681a513a2cd8a15ce316a1e7843b34e46c43a0a"
    )
    
    struct TestAccount {
        var address = ""
        var privateKey = ""
        init(_ address: String, _ privateKey: String) {
            self.address = address
            self.privateKey = privateKey
        }
    }
}
