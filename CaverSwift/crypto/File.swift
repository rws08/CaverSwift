//
//  File.swift
//  CaverSwift
//
//  Created by won on 2021/06/25.
//

import Foundation
import secp256k1
import BigInt

open class Sign {
    static let DOMAIN = Domain.instance(curve: .EC256k1)
    
    public static func isValidPrivateKey(_ privateKey: String) -> Bool {
        guard let s = BInt(privateKey.cleanHexPrefix, radix: 16),
              let privKey = try? ECPrivateKey(domain: DOMAIN, s: s) else { return false }
        return publicPointFromPrivate(privKey).isValid
    }
    
    public static func publicKeyFromPrivate(_ privateKey: String) -> String {
        guard let s = BInt(privateKey.cleanHexPrefix, radix: 16),
              let privKey = try? ECPrivateKey(domain: DOMAIN, s: s),
              let publicKey = try? DOMAIN.encodePoint(publicPointFromPrivate(privKey)) else { return "" }
        
        return String(bytes: publicKey)
    }
    
    public static func publicPointFromPrivate(_ privateKey: ECPrivateKey) -> Point {
        var privKey = privateKey.s
        if privateKey.s.bitWidth > DOMAIN.order.bitWidth {
            privKey = privKey.mod(DOMAIN.order)
        }
        
        var point = DOMAIN.multiplyG(privKey)
        point.isValid = DOMAIN.contains(point)
        return point
    }
    
}
