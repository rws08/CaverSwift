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
        
        return String(bytes: Array(publicKey[1..<publicKey.count]))
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
    
    public static func signMessage(_ msg: [UInt8], _ privateKey: String, _ needToHash: Bool) throws -> SignatureData {
        let messageHash = needToHash ? Data(msg).keccak256.bytes : msg
        
        guard let sig = recoverFromSignature(Data(messageHash), privateKey.hexData!) else {
            throw CaverError.RuntimeException("Could not construct a recoverable key. Are your credentials valid?")
        }
        
        return sig
    }
    
    private static func recoverFromSignature(_ message: Data, _ privateKey: Data) -> SignatureData? {
        guard let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY)) else {
            print("Failed to sign message: invalid context.")
            return nil
        }
        
        defer {
            secp256k1_context_destroy(ctx)
        }

        let msg = (message as NSData).bytes.assumingMemoryBound(to: UInt8.self)
        let privateKeyPtr = (privateKey as NSData).bytes.assumingMemoryBound(to: UInt8.self)
        let signaturePtr = UnsafeMutablePointer<secp256k1_ecdsa_recoverable_signature>.allocate(capacity: 1)
        defer {
            signaturePtr.deallocate()
        }
        guard secp256k1.secp256k1_ecdsa_sign_recoverable(ctx, signaturePtr, msg, privateKeyPtr, nil, nil) == 1 else {
            print("Failed to sign message: recoverable ECDSA signature creation failed.")
            return nil
        }
        
        let outputPtr = UnsafeMutablePointer<UInt8>.allocate(capacity: 64)
        defer {
            outputPtr.deallocate()
        }
        var recid: Int32 = 0
        secp256k1_ecdsa_recoverable_signature_serialize_compact(ctx, outputPtr, &recid, signaturePtr)
        
        let data = Data(bytes: outputPtr, count: 64).bytes
        
        return SignatureData([UInt8(recid + 27)], Array(data[0..<32]), Array(data[32..<64]))
    }
    
    public static func recoverFromSignature(_ message: Data, _ sig: Data, _ recId: Int32) -> Data? {
        guard let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY)) else {
            print("Failed to sign message: invalid context.")
            return nil
        }
        
        defer {
            secp256k1_context_destroy(ctx)
        }
        
        let msg = (message as NSData).bytes.assumingMemoryBound(to: UInt8.self)
        let sig = (sig as NSData).bytes.assumingMemoryBound(to: UInt8.self)
        let signaturePtr = UnsafeMutablePointer<secp256k1_ecdsa_recoverable_signature>.allocate(capacity: 1)
        defer {
            signaturePtr.deallocate()
        }
        guard secp256k1.secp256k1_ecdsa_recoverable_signature_parse_compact(ctx, signaturePtr, sig, recId) == 1 else {
            print("Failed to sign message: recoverable ECDSA signature parse failed.")
            return nil
        }
        
        let publicKeyPtr = UnsafeMutablePointer<secp256k1_pubkey>.allocate(capacity: 1)
        defer {
            publicKeyPtr.deallocate()
        }
        guard secp256k1_ecdsa_recover(ctx, publicKeyPtr, signaturePtr, msg) == 1 else {
            print("Failed to sign message: recoverable ECDSA recover failed.")
            return nil
        }
        
        var publicKeyLength = 65
        let outputPtr = UnsafeMutablePointer<UInt8>.allocate(capacity: publicKeyLength)
        defer {
            outputPtr.deallocate()
        }
        secp256k1_ec_pubkey_serialize(ctx, outputPtr, &publicKeyLength, publicKeyPtr, UInt32(SECP256K1_EC_UNCOMPRESSED))
        
        let publicKey = Data(bytes: outputPtr, count: publicKeyLength).subdata(in: 1..<publicKeyLength)
        
        return publicKey
    }
}
