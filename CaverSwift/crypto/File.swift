//
//  File.swift
//  CaverSwift
//
//  Created by won on 2021/06/25.
//

import Foundation
import secp256k1

open class Sign {
    public static func isValidPrivateKey(_ privateKey: String) -> Bool {
        guard let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY)) else {
            print("Failed to generate a public key: invalid context.")
            return false
        }
        
        defer {
            secp256k1_context_destroy(ctx)
        }
        
        let privateKeyPtr = NSData(data: privateKey.data(using: .utf8)!).bytes.assumingMemoryBound(to: UInt8.self)
        
        guard secp256k1_ec_seckey_verify(ctx, privateKeyPtr) == 1 else {
            print("Failed to generate a public key: private key is not valid.")
            return false
        }
        return true
    }
    
    public static func publicKeyFromPrivate(_ privateKey: Data) throws -> Data {
        guard let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY)) else {
            print("Failed to generate a public key: invalid context.")
            throw KeyUtilError.invalidContext
        }
        
        defer {
            secp256k1_context_destroy(ctx)
        }
        
        
        let privateKeyPtr = (privateKey as NSData).bytes.assumingMemoryBound(to: UInt8.self)
        guard secp256k1_ec_seckey_verify(ctx, privateKeyPtr) == 1 else {
            print("Failed to generate a public key: private key is not valid.")
            throw KeyUtilError.privateKeyInvalid
        }
        
        let publicKeyPtr = UnsafeMutablePointer<secp256k1_pubkey>.allocate(capacity: 1)
        defer {
            publicKeyPtr.deallocate()
        }
        guard secp256k1_ec_pubkey_create(ctx, publicKeyPtr, privateKeyPtr) == 1 else {
            print("Failed to generate a public key: public key could not be created.")
            throw KeyUtilError.unknownError
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
