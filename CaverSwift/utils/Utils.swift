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
    public static let LENGTH_KLAYTN_WALLET_KEY_STRING = 110
    static let DOMAIN = Domain.instance(curve: .EC256k1)
        
    private static let baseAddrPattern = "^(0x)?[0-9a-f]{40}$"
    private static let lowerCasePattern = "^(0x|0X)?[0-9a-f]{40}$"
    private static let upperCasePattern = "^(0x|0X)?[0-9A-F]{40}$"

    public static func getAddress(_ publicKey: String) -> String {
        guard let hash = publicKey.hexData?.keccak256 else { return "" }
        let address = hash.subdata(in: 12..<hash.count)
        return address.hexString
    }
    
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
    
    public static func isHexStrict(_ input: String) -> Bool {
        let pattern = try! NSRegularExpression(pattern: "^(-)?0x[0-9A-Fa-f]*$", options: [])
        let range = NSRange(0..<input.utf16.count)
        return !pattern.matches(in: input, options: [], range: range).isEmpty
    }
    
    public static func addHexPrefix(_ input: String) -> String {
        return input.addHexPrefix
    }
    
    public static func stripHexPrefix(_ input: String) -> String {
        return input.cleanHexPrefix
    }
    
    public static func convertToPeb(_ num: String, _ unit: String) -> String {
        return convertToPeb(BigInt(num), KlayUnit.fromString(unit))
    }
    
    public static func convertToPeb(_ num: BigInt, _ unit: String) -> String {
        return convertToPeb(num, KlayUnit.fromString(unit))
    }
    
    public static func convertToPeb(_ num: String, _ unit: KlayUnit) -> String {
        return convertToPeb(BigInt(num), unit)
    }
    
    public static func convertToPeb(_ num: BigInt?, _ unit: KlayUnit) -> String {
        guard let num = num,
              let num = BDouble(num.decimal) else { return "" }
        
        return (num * unit.getPebFactor()).rounded().description
    }
    
    public static func convertFromPeb(_ num: String, _ unit: String) -> String {
        return convertFromPeb(BigInt(num), KlayUnit.fromString(unit))
    }
    
    public static func convertFromPeb(_ num: BigInt, _ unit: String) -> String {
        return convertFromPeb(num, KlayUnit.fromString(unit))
    }
    
    public static func convertFromPeb(_ num: String, _ unit: KlayUnit) -> String {
        return convertFromPeb(BigInt(num), unit)
    }
    
    public static func convertFromPeb(_ num: BigInt?, _ unit: KlayUnit) -> String {
        guard let num = num,
              let num = BDouble(num.decimal) else { return "" }
        
        return (num / unit.getPebFactor()).rounded().description
    }
    
    public static func isEmptySig(_ signatureData: SignatureData) -> Bool {
        return SignatureData.getEmptySignature() == signatureData
    }
    
    public static func isEmptySig(_ signatureDataList: [SignatureData]) -> Bool {
        let emptySig = SignatureData.getEmptySignature()
        return signatureDataList.filter {
            $0 != emptySig
        }.isEmpty
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
    
    public static func isKlaytnWalletKey(_ key: String) -> Bool {
        let cleanPrefixKey = key.cleanHexPrefix
        if cleanPrefixKey.count != LENGTH_KLAYTN_WALLET_KEY_STRING {
            return false
        }
        
        let arr = cleanPrefixKey.components(separatedBy: "0x")
        if arr.count < 3 {
            return false
        }
        if arr[1] != "00" {
            return false
        }
        if !Utils.isAddress(arr[2]) {
            return false
        }
        if !Utils.isValidPrivateKey(arr[0]) {
            return false
        }
        
        return true
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
    
    public static func getECPoint(_ key: String) throws -> Point {
        var key = key
        if try isUncompressedPublicKey(key) {
            key = try compressPublicKey(key)
        }
        guard let bytes = key.bytesFromHex else { throw CaverError.invalidValue }
        return try DOMAIN.decodePoint(bytes)
    }
    
    public static func getECPoint(_ x: String, _ y: String) -> Point {
        return Point(BInt(x, radix: 16) ?? BInt.ZERO, BInt(y, radix: 16) ?? BInt.ZERO)
    }
    
    public static func validateXYPoint(_ compressedPubKey: String) -> Bool {
        guard var point = try? getECPoint(compressedPubKey) else { return false }
        point.isValid = DOMAIN.contains(point)
        return point.isValid
    }
    
    public static func validateXYPoint(_ x: String, _ y: String) -> Bool {
        var point = getECPoint(x, y)
        point.isValid = DOMAIN.contains(point)
        return point.isValid
    }
    
    public static func isValidPublicKey(_ publicKey: String) -> Bool {
        var noPrefixPubKey = publicKey.cleanHexPrefix
        if noPrefixPubKey.count == 130 && noPrefixPubKey.startsWith("04") {
            noPrefixPubKey = String(noPrefixPubKey.dropFirst(2))
        }
        
        if noPrefixPubKey.count != 66 && noPrefixPubKey.count != 128 {
            return false
        }
        
        // Compressed Format
        if noPrefixPubKey.count == 66 {
            if(!noPrefixPubKey.startsWith("02") && !noPrefixPubKey.startsWith("03")) {
                return false
            }
            return validateXYPoint(publicKey)
        } else { // Uncompressed Format
            let x = String(noPrefixPubKey[0..<64])
            let y = String(noPrefixPubKey[64..<noPrefixPubKey.count])

            return validateXYPoint(x, y)
        }
    }
    
    public static func decompressPublicKey(_ publicKey: String) throws -> String {
        if try isUncompressedPublicKey(publicKey) {
            return publicKey
        }
        
        guard let point = try? getECPoint(publicKey),
              let decompressPublicKey = try? DOMAIN.encodePoint(point) else { return "" }
        
        // remove tag(04)
        return String(bytes: Array(decompressPublicKey.dropFirst(1)))
    }
    
    public static func compressPublicKey(_ publicKey: String) throws -> String {
        if try isCompressedPublicKey(publicKey) {
            return publicKey
        }
        
        var noPrefixKey = publicKey.cleanHexPrefix
        if noPrefixKey.count == 130 && noPrefixKey.startsWith("04") {
            noPrefixKey = String(noPrefixKey.dropFirst(2))
        }
        
        guard let publicKeyBN = BInt(noPrefixKey, radix: 16) else { return "" }
        let publicKeyX = String(noPrefixKey[0..<64])
        let pubKeyYPrefix = publicKeyBN.testBit(0) ? "03" : "02"
        
        return pubKeyYPrefix + publicKeyX
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

            if(!validateXYPoint(x, y)) {
                throw CaverError.RuntimeException("Invalid public key.")
            }
            return true;
        }
        return false;
    }
    
    public static func hashMessage(_ message: String) -> String {
        let preamble = "\\x19Klaytn Signed Message:\\n"
        let klaytnMessage = "\(preamble)\(message.count)\(message)"
        return klaytnMessage.sha3String
    }
    
    public static func parseKlaytnWalletKey(_ key: String) throws -> [String] {
        if !isKlaytnWalletKey(key) {
            throw CaverError.IllegalAccessException("Invalid Klaytn wallet key.")
        }
        
        //0x{private key}0x{type}0x{address in hex}
        //[0] = privateKey
        //[1] = type - must be "00"
        //[2] = address
        let cleanPrefixKey = key.cleanHexPrefix
        let arr = cleanPrefixKey.components(separatedBy: "0x").map { $0.addHexPrefix }
        return arr
    }
    
    private static func isVeryfyPublicKey(_ key: String) throws -> Bool {
        guard let bytes = key.bytesFromHex,
              let point = try? DOMAIN.decodePoint(bytes) else { throw CaverError.invalidValue }
        
        return DOMAIN.contains(point)
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
    
    public static func fromString(_ unitName: String) -> KlayUnit {
        switch unitName {
        case KlayUnit.peb.unit: return .peb
        case KlayUnit.kpeb.unit: return .kpeb
        case KlayUnit.Mpeb.unit: return .Mpeb
        case KlayUnit.Gpeb.unit: return .Gpeb
        case KlayUnit.ston.unit: return .ston
        case KlayUnit.uKLAY.unit: return .uKLAY
        case KlayUnit.mKLAY.unit: return .mKLAY
        case KlayUnit.KLAY.unit: return .KLAY
        case KlayUnit.kKLAY.unit: return .kKLAY
        case KlayUnit.MKLAY.unit: return .MKLAY
        case KlayUnit.GKLAY.unit: return .GKLAY
        case KlayUnit.TKLAY.unit: return .TKLAY
        default: return .KLAY
        }
    }
}

func WARNING(filename: String = #file, line: Int = #line, funcname: String = #function, message:Any...) {
    print("\(filename)[\(funcname)][Line \(line)] \(message)")
}
