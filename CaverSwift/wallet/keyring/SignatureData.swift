//
//  SignatureData.swift
//  CaverSwift
//
//  Created by won on 2021/06/25.
//

import Foundation

open class SignatureData: Equatable {
    var v = ""
    var r = ""
    var s = ""
    
    init(_ v: String, _ r: String, _ s: String) {
        self.v = v
        self.r = r
        self.s = s
    }
    
    init(_ v: [UInt8], _ r: [UInt8], _ s: [UInt8]) {
        self.v = Data(v).hexString
        self.r = Data(r).hexString
        self.s = Data(s).hexString
    }
    
    public static func getEmptySignature() -> SignatureData {
        return SignatureData("0x01", "0x", "0x")
    }
    
    public func makeEIP155Signature(_ chainId: Int) throws {
        if v.isEmpty || v == "0x" {
            throw CaverError.IllegalArgumentException("V value must be set.")
        }
                
        guard var v = BigInt(v, radix: 16) else { return }
        v = (v + BigInt(chainId) * BigInt(2)) + BigInt(8)
        self.v = v.hexa
    }
    
    public var hash: Int {
        var result = v.hash
        result = 31 * result + r.hash
        result = 31 * result + s.hash
        return result
    }
    
    public func toString() -> String {
        return "V : \(v)\nR : \(r)\nS : \(s)"
    }
    
    public static func == (lhs: SignatureData, rhs: SignatureData) -> Bool {
        return lhs.v == rhs.v && lhs.r == rhs.r && lhs.s == rhs.s
    }
}
