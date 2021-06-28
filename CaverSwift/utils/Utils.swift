//
//  Utils.swift
//  CaverSwift
//
//  Created by won on 2021/05/10.
//

import Foundation
import secp256k1
import SwiftECC
import BigInt

public class Utils {
    public static let LENGTH_PRIVATE_KEY_STRING = 64
    
    private static let baseAddrPattern = "^(0x)?[0-9a-f]{40}$"
    private static let lowerCasePattern = "^(0x|0X)?[0-9a-f]{40}$"
    private static let upperCasePattern = "^(0x|0X)?[0-9A-F]{40}$"

    public static func isAddress(_ address: String) -> Bool {
        let baseAddrCase = try! NSRegularExpression(pattern: Utils.baseAddrPattern, options: [.caseInsensitive])
        let lowerCase = try! NSRegularExpression(pattern: Utils.lowerCasePattern, options: [])
        let upperCase = try! NSRegularExpression(pattern: Utils.upperCasePattern, options: [])
        let range = NSRange(0..<address.utf16.count)

        if baseAddrCase.matches(in: address, options: [], range: range).isEmpty {
            return false
        }
        
        if !lowerCase.matches(in: address, options: [], range: range).isEmpty ||
            !upperCase.matches(in: address, options: [], range: range).isEmpty {
            return true
        }
        
        return checkAddressChecksum(address: address)
    }
    
    public static func isNumber(_ input: String) -> Bool {        
        if BigInt.init(hex: input.lowercased()) == nil {
            return false
        }
        return true
    }
    
    public static func isHex(_ input: String) -> Bool {
        let pattern = try! NSRegularExpression(pattern: "^(-0x|0x)?[0-9A-Fa-f]*$", options: [])
        let range = NSRange(0..<input.utf16.count)
        return !pattern.matches(in: input, options: [], range: range).isEmpty
    }
    
    public static func checkAddressChecksum(address: String) -> Bool {
        let address = address.replacingOccurrences(of: "0X", with: "0x")        
        return KeyUtil.toChecksumAddress(address) == address.addHexPrefix
    }
    
    public static func isValidPrivateKey(_ privateKey: String) -> Bool {
        let noHexPrefixKey = privateKey.cleanHexPrefix
        if noHexPrefixKey.count != LENGTH_PRIVATE_KEY_STRING || !isHex(privateKey) {
            return false
        }
        
        return Sign.isValidPrivateKey(noHexPrefixKey)
    }
    
    public static func generateRandomBytes(_ size: Int) -> Data {
        var data = [UInt8](repeating: 0, count: size)
        let result = SecRandomCopyBytes(kSecRandomDefault,
                               data.count,
                               &data)
        if result == errSecSuccess {
            return Data(data)
        }
        return Data()
    }
    
    public static func getStaticArrayElementSize(_ array: TypeArray) -> Int {
        var count = 0
        switch array.subRawType {
        case .Tuple(_):
            let item = array.values.first as! TypeStruct
            count += array.values.count * getStaticStructComponentSize(item)
            break
        case .FixedArray(_, _):
            let item = array.values.first as! TypeArray
            count += array.values.count * getStaticArrayElementSize(item)
            break
        default:
            count += array.values.count
            break
        }
        return count
    }
    
    public static func getStaticStructComponentSize(_ staticStruct: TypeStruct) -> Int {
        var count = 0
        staticStruct.values.forEach {
            switch type(of: $0).rawType {
            case .Tuple(_):
                let item = $0 as! TypeStruct
                count += getStaticStructComponentSize(item)
                break
            case .FixedArray(_, _):
                let item = $0 as! TypeArray
                count += getStaticArrayElementSize(item)
                break
            default:
                count += 1
                break
            }
        }
        return count
    }
    
    public static func isValidPublicKey(_ publicKey: String) -> Bool {
        
        return true
    }
    
    public static func compressPublicKey(_ publicKey: String) -> String {
//        if  {
//
//        }
        
        return publicKey
    }
    
    public static func isCompressedPublicKey(_ key: String) throws -> Bool {
        let noPrefixKey = key.cleanHexPrefix;

        if(noPrefixKey.count == 66 && (noPrefixKey.startsWith("02") || noPrefixKey.startsWith("03"))) {
            guard let isVeryfy = try? isVeryfyPublicKey(noPrefixKey) else {
                return false
            }
            if(!isVeryfy) {
                throw CaverError.RuntimeException("Invalid public key.")
            }
            return true;
        }
        return false;
    }
    
    public static func isUncompressedPublicKey(_ key: String) throws -> Bool {
        var noPrefixKey = key.cleanHexPrefix;

        if(noPrefixKey.count == 130 && noPrefixKey.startsWith("04")) {
            noPrefixKey = String(noPrefixKey[2..<noPrefixKey.count])
        }

        if(noPrefixKey.count == 128) {
            let x = String(noPrefixKey[0..<64])
            let y = String(noPrefixKey[64..<noPrefixKey.count])

//            if(!validateXYPoint(x, y)) {
//                throw CaverError.RuntimeException("Invalid public key.")
//            }
            return true;
        }
        return false;
    }
    
    private static func isVeryfyPublicKey(_ key: String) throws -> Bool {
        let domain = Domain.instance(curve: .EC256k1)
        let publicKey = try ECPublicKey(der: SwiftECC.Bytes(key.utf8))
        
        let privateKey = try ECPrivateKey(der: SwiftECC.Bytes(key.utf8))
        print(privateKey.description)
//        domain.encodePoint(domain.multiplyG(privateKey.s))
        
        
        guard let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY)) else {
            print("Failed to generate a public key: invalid context.")
            throw KeyUtilError.invalidContext
        }
        
        defer {
            secp256k1_context_destroy(ctx)
        }
        
        let inputKey = NSData(data: key.data(using: .utf8)!).bytes.assumingMemoryBound(to: UInt8.self)
        let publicKeyPtr = UnsafeMutablePointer<secp256k1_pubkey>.allocate(capacity: 1)
        defer {
            inputKey.deallocate()
            publicKeyPtr.deallocate()
        }

        let publicKeyLength = 65
        let result = secp256k1_ec_pubkey_parse(ctx, publicKeyPtr, inputKey, publicKeyLength)
        
        return result == 0 ? false : true
    }
}

public struct KlayUnit {
    public static let peb = KlayUnit("peb", 0)
    public static let kpeb = KlayUnit("kpeb", 3)
    public static let Mpeb = KlayUnit("Mpeb", 6)
    public static let Gpeb = KlayUnit("Gpeb", 9)
    public static let ston = KlayUnit("ston", 9)
    public static let uKLAY = KlayUnit("uKLAY", 12)
    public static let mKLAY = KlayUnit("mKLAY", 15)
    public static let KLAY = KlayUnit("KLAY", 18)
    public static let kKLAY = KlayUnit("kKLAY", 21)
    public static let MKLAY = KlayUnit("MKLAY", 24)
    public static let GKLAY = KlayUnit("GKLAY", 27)
    public static let TKLAY = KlayUnit("TKLAY", 30)
    
    private var unit: String
    private var pebFactor: BDouble
    init(_ unit: String, _ pebFactor: Int) {
        self.unit = unit
        self.pebFactor = pow(BDouble(10), pebFactor)
    }
    
    public func getPebFactor() -> BDouble {
        return pebFactor
    }
    
    public func string() -> String {
        return unit
    }
}

func WARNING(filename: String = #file, line: Int = #line, funcname: String = #function, message:Any...) {
    print("\(filename)[\(funcname)][Line \(line)] \(message)")
}
