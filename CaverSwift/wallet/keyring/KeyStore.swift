//
//  KeyStore.swift
//  CaverSwift
//
//  Created by won on 2021/07/07.
//

import Foundation
import CommonCrypto
import aes
import libscrypt

open class KeyStore: Decodable, Encodable {
    public static let KEY_STORE_VERSION_V3 = 3
    public static let KEY_STORE_VERSION_V4 = 4
    
    public var address: String?
    public var crypto: Crypto?
    public var keyring: [Any]?
    public var id: String?
    public var version: Int?
    
    init() {
    }
    
    enum CodingKeys: String, CodingKey {
        case address
        case keyring
        case crypto
        case id
        case version
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.address = try values.decode(String.self, forKey: .address)
        self.id = try values.decode(String.self, forKey: .id)
        self.version = try values.decode(Int.self, forKey: .version)
        
        self.crypto = try? values.decode(Crypto.self, forKey: .crypto)
        do {
            self.keyring = try values.decode([[Crypto]].self, forKey: .keyring)
        } catch {
            do {
                self.keyring = try values.decode([Crypto].self, forKey: .keyring)
            } catch {
                if self.crypto == nil {
                    print(error.localizedDescription)
                    throw CaverError.IllegalArgumentException("Invalid key store format: 'crypto' and 'keyring' cannot be defined together.")
                }
            }
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(address, forKey: .address)
        try container.encode(id, forKey: .id)
        try container.encode(version, forKey: .version)
        
        if crypto != nil {
            try container.encode(crypto, forKey: .crypto)
        }
        
        if keyring != nil {
            if keyring is [[Crypto]] {
                try container.encode(keyring as! [[Crypto]], forKey: .keyring)
            } else if keyring is [Crypto]{
                try container.encode(keyring as! [Crypto], forKey: .keyring)
            }
        }
    }
    
    public class Crypto: Codable {
        private static let ENCRYPT_MODE = 1
        private static let DECRYPT_MODE = 2
        
        public var cipher: String?
        public var ciphertext: String?
        public var cipherparams: CipherParams?
        public var kdf: String?
        public var kdfparams: IKdfParams?
        public var mac: String?
        
        init() {            
        }
        
        enum CodingKeys: String, CodingKey {
            case cipher
            case ciphertext
            case cipherparams
            case kdf
            case kdfparams
            case mac
        }
        
        required public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            
            self.cipher = try values.decode(String.self, forKey: .cipher)
            self.ciphertext = try values.decode(String.self, forKey: .ciphertext)
            self.cipherparams = try values.decode(CipherParams.self, forKey: .cipherparams)
            self.kdf = try? values.decode(String.self, forKey: .kdf)
            self.mac = try? values.decode(String.self, forKey: .mac)
            
            do {
                self.kdfparams = try values.decode(ScryptKdfParams.self, forKey: .kdfparams)
            } catch {
                do {
                    self.kdfparams = try values.decode(Pbkdf2KdfParams.self, forKey: .kdfparams)
                } catch {
                    print(error.localizedDescription)
                    throw CaverError.decodeIssue
                }
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(cipher, forKey: .cipher)
            try container.encode(ciphertext, forKey: .ciphertext)
            try container.encode(cipherparams, forKey: .cipherparams)
            try container.encode(kdf, forKey: .kdf)
            try container.encode(mac, forKey: .mac)
            if kdfparams is ScryptKdfParams {
                try container.encode(kdfparams as! ScryptKdfParams, forKey: .kdfparams)
            } else if kdfparams is Pbkdf2KdfParams{
                try container.encode(kdfparams as! Pbkdf2KdfParams, forKey: .kdfparams)
            }
        }
                
        public static func createCrypto(_ privateKeys: [PrivateKey], _ password: String, _ option: KeyStoreOption) throws -> [Crypto] {
            let PRIVATE_KEY_SIZE = 32
            let CIPHER_METHOD = "aes-128-ctr"
            
            var cryptoList: [Crypto] = []
            var kdfName = ""
            
            var salt = option.kdfParams.salt.hexData
            if salt == nil || salt!.isEmpty {
                salt = Utils.generateRandomBytes(32)
            }
            guard let salt = salt else { return cryptoList }
            option.kdfParams.salt = salt.hexString.cleanHexPrefix
            
            var iv: Data
            if option.cipherParams.iv == nil {
                iv = Utils.generateRandomBytes(16)
                option.cipherParams.iv = iv.hexString.cleanHexPrefix
            } else {
                iv = option.cipherParams.iv!.hexData!
            }
            
            try privateKeys.forEach {
                var derivedKey: [UInt8] = []
                switch option.kdfParams {
                case is ScryptKdfParams:
                    kdfName = ScryptKdfParams.NAME
                    let scryptKdfParams = option.kdfParams as! ScryptKdfParams
                    derivedKey = try generateDerivedScryptKey(password.data(using: .utf8)!, salt, scryptKdfParams.n, scryptKdfParams.r, scryptKdfParams.p, scryptKdfParams.dklen)
                    break
                case is Pbkdf2KdfParams:
                    kdfName = Pbkdf2KdfParams.NAME
                    let pbkdf2KdfParams = option.kdfParams as! Pbkdf2KdfParams
                    derivedKey = try generatePbkdf2DerivedKey(password, salt, pbkdf2KdfParams.c, pbkdf2KdfParams.prf)
                    break
                default:
                    throw CaverError.RuntimeException("Unsupported KDF")
                }
                let encryptKey = Data(derivedKey[0..<16])
                let privateKeyBytes = [UInt8](repeating: 0x00, count: PRIVATE_KEY_SIZE - $0.privateKey.bytesFromHex!.count) + $0.privateKey.bytesFromHex!
                let cipherText = try performCipherOperation(ENCRYPT_MODE, encryptKey, iv, Data(privateKeyBytes))
                let mac = generateMac(derivedKey, cipherText)
                
                let crypto = Crypto()
                crypto.cipher = CIPHER_METHOD
                crypto.ciphertext = cipherText.string.cleanHexPrefix
                crypto.cipherparams = option.cipherParams
                crypto.kdf = kdfName
                crypto.kdfparams = option.kdfParams
                crypto.mac = mac.hexString.cleanHexPrefix
                
                cryptoList.append(crypto)
            }
            
            return cryptoList
        }
        
        public static func decryptCrypto(_ crypto: Crypto, _ password: String) throws -> String {
            guard let mac = crypto.mac?.hexData,
                  let iv = crypto.cipherparams?.iv?.hexData,
                  let ciphertext = crypto.ciphertext?.hexData,
                  let salt = crypto.kdfparams?.salt.hexData
            else {return ""}
            
            var derivedKey: [UInt8] = []
            
            switch crypto.kdfparams {
            case is ScryptKdfParams:
                let scryptKdfParams = crypto.kdfparams as! ScryptKdfParams
                derivedKey = try generateDerivedScryptKey(password.data(using: .utf8)!, salt, scryptKdfParams.n, scryptKdfParams.r, scryptKdfParams.p, scryptKdfParams.dklen)
                break
            case is Pbkdf2KdfParams:
                let pbkdf2KdfParams = crypto.kdfparams as! Pbkdf2KdfParams
                derivedKey = try generatePbkdf2DerivedKey(password, salt, pbkdf2KdfParams.c, pbkdf2KdfParams.prf)
                break
            default:
                throw CaverError.RuntimeException("Unable to deserialize params: \(String(describing: crypto.kdf))")
            }
            
            let derivedMac = generateMac(derivedKey, ciphertext.bytes)
            if derivedMac != mac {
                throw CaverError.CipherException("Invalid password provided")
            }
            
            let encryptKey = Data(derivedKey[0..<16])
            let privateKey = try performCipherOperation(DECRYPT_MODE, encryptKey, iv, ciphertext)
            return privateKey.string
        }
        
        private static func performCipherOperation(_ mode: Int, _ encryptKey: Data, _ iv: Data, _ text: Data) throws -> [UInt8] {
            
            let ctx = UnsafeMutablePointer<AES_ctx>.allocate(capacity: 1)
            defer {
                ctx.deallocate()
            }
            
            let keyPtr = (encryptKey as NSData).bytes.assumingMemoryBound(to: UInt8.self)
            let ivPtr = (iv as NSData).bytes.assumingMemoryBound(to: UInt8.self)
            AES_init_ctx_iv(ctx, keyPtr, ivPtr)

            let inputPtr = (text as NSData).bytes.assumingMemoryBound(to: UInt8.self)
            let length = text.count
            let outputPtr = UnsafeMutablePointer<UInt8>.allocate(capacity: length)
            defer {
                outputPtr.deallocate()
            }
            outputPtr.assign(from: inputPtr, count: length)

            AES_CTR_xcrypt_buffer(ctx, outputPtr, UInt32(length))

            return Data(bytes: outputPtr, count: length).bytes
        }
        
        private static func generateMac(_ derivedKey: [UInt8], _ cipherText: [UInt8]) -> Data {
            let result = derivedKey[16..<32] + cipherText
            return Data(result).keccak256
        }
        
        private static func generateDerivedScryptKey(_ password: Data, _ salt: Data, _ n: Int, _ r: Int, _ p: Int, _ dkKen: Int) throws -> [UInt8] {
            
            let passwordD = (password as NSData).bytes.assumingMemoryBound(to: UInt8.self)
            let saltD = (salt as NSData).bytes.assumingMemoryBound(to: UInt8.self)
            let bufptr = UnsafeMutablePointer<UInt8>.allocate(capacity: dkKen)
            defer {
                bufptr.deallocate()
            }
            
            libscrypt_scrypt(
                passwordD, password.count,
                saltD, salt.count,
                UInt64(n), UInt32(r), UInt32(p),
                bufptr, dkKen
            )
            
            let key = Data(bytes: bufptr, count: dkKen).bytes
            return key
        }
        
        private static func generatePbkdf2DerivedKey(_ password: String, _ salt: Data, _ c: Int, _ prf: String) throws -> [UInt8] {
            if prf != "hmac-sha256" {
                throw CaverError.CipherException("Unsupported prf: \(prf)")
            }
            
            guard let passwordData = password.data(using: .utf8) else { throw KeystoreUtilError.unknown }
            var derivedKeyData = [UInt8](repeating: 0, count: 32)
            var saltData = salt.bytes
            let derivationStatus = CCKeyDerivationPBKDF(
                CCPBKDFAlgorithm(kCCPBKDF2),
                password,
                passwordData.count,
                &saltData,
                saltData.count,
                CCPBKDFAlgorithm(kCCPRFHmacAlgSHA256),
                UInt32(c),
                &derivedKeyData,
                derivedKeyData.count)

            if derivationStatus != 0 {
                throw CaverError.RuntimeException("Error: \(derivationStatus)")
            }
            
            return derivedKeyData
        }
    }
    
    public struct CipherParams: Codable {
        public var iv: String? {
            willSet(v) {
                do {
                    if v?.hexData?.count != 16 {
                        throw CaverError.IllegalArgumentException("AES-128-CTR must have iv length 16.")
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        init() {
            self.iv = Utils.generateRandomBytes(16).hexString.cleanHexPrefix
        }
        
        init(_ iv: String?) {
            self.iv = iv
        }
    }
    
    open class IKdfParams: Codable {
        public var dklen = 0
        public var salt = ""
    }
    
    public class ScryptKdfParams: IKdfParams {
        public static let NAME = "scrypt"
        
        public var n = 4096
        public var p = 1
        public var r = 8
        
        override init() {
            super.init()
            dklen = 32
            salt = Utils.generateRandomBytes(32).hexString.cleanHexPrefix
        }
        
        init(_ dklen: Int, _ n: Int, _ p: Int, _ r: Int, _ salt: String) {
            super.init()
            self.n = n
            self.p = p
            self.r = r
        }
        
        init(_ salt: String) {
            super.init()
            self.dklen = 32
            self.salt = salt
        }
        
        enum CodingKeys: String, CodingKey {
            case dklen
            case salt
            case n
            case p
            case r
        }
        
        required init(from decoder: Decoder) throws {
            super.init()
            let values = try decoder.container(keyedBy: CodingKeys.self)
            
            self.dklen = try values.decode(Int.self, forKey: .dklen)
            self.salt = try values.decode(String.self, forKey: .salt)
            self.n = try values.decode(Int.self, forKey: .n)
            self.p = try values.decode(Int.self, forKey: .p)
            self.r = try values.decode(Int.self, forKey: .r)
        }
    }
    
    public class Pbkdf2KdfParams: IKdfParams {
        public static let NAME = "pbkdf2"
        
        public var c = 262144
        public var prf = "hmac-sha256"
        
        override init() {
            super.init()
            salt = Utils.generateRandomBytes(32).hexString.cleanHexPrefix
        }
        
        init(_ dklen: Int, _ c: Int, _ prf: String, _ salt: String) {
            super.init()
            self.dklen = dklen
            self.c = c
            self.prf = prf
            self.salt = salt
        }
        
        init(_ salt: String) {
            super.init()
            self.salt = salt
        }
        
        enum CodingKeys: String, CodingKey {
            case dklen
            case salt
            case c
            case prf
        }
        
        required init(from decoder: Decoder) throws {
            super.init()
            let values = try decoder.container(keyedBy: CodingKeys.self)
            
            self.dklen = try values.decode(Int.self, forKey: .dklen)
            self.salt = try values.decode(String.self, forKey: .salt)
            self.c = try values.decode(Int.self, forKey: .c)
            self.prf = try values.decode(String.self, forKey: .prf)
        }
    }
}
