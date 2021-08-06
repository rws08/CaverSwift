//
//  AccountKeyPublic.swift
//  CaverSwift
//
//  Created by won on 2021/06/23.
//

import Foundation

open class AccountKeyPublic: IAccountKey {
    private static let RLP: UInt8 = 0x02
    static let TYPE = "0x02"
    
    private(set) public var publicKey = ""
    
    public static let OFFSET_X_POINT = 0
    public static let OFFSET_Y_POINT = 1
    
    init(_ publicKey: String) {
        super.init()
        try? self.setPublicKey(publicKey)
    }
    
    public func setPublicKey(_ publicKey: String) throws {
        if !AccountKeyPublicUtils.isValidPublicKey(publicKey) {
            throw CaverError.RuntimeException("Invalid Public Key format")
        }
        self.publicKey = publicKey
    }
    
    public override func getRLPEncoding() throws -> String {
        let compressedKey = try AccountKeyPublicUtils.compressPublicKey(publicKey)
        guard let encodedPubKey = Rlp.encode(compressedKey) else { return "" }        
        var type = Data([AccountKeyPublic.RLP])
        type.append(encodedPubKey)
        return type.hexString
    }
    
    public func getXYPoint() -> [String] {
        var key = publicKey
        do {
            if try AccountKeyPublicUtils.isCompressedPublicKey(publicKey) {
                key = try AccountKeyPublicUtils.decompressPublicKey(publicKey)
            }
            
            let noPrefixKeyStr = key.cleanHexPrefix
            return [String(noPrefixKeyStr[0..<64]), String(noPrefixKeyStr[64..<noPrefixKeyStr.count])]
        } catch {
            print(error.localizedDescription)
        }
        
        return []
    }
    
    public static func fromXYPoint(_ x: String, _ y: String) throws -> AccountKeyPublic {
        guard let xPoint = x.hexData?.hexString,
              let yPoint = y.hexData?.hexString
        else { throw CaverError.invalidValue }
        
        return AccountKeyPublic(xPoint + yPoint.cleanHexPrefix)
    }
    
    public static func fromPublicKey(_ publicKey: String) -> AccountKeyPublic {
        return AccountKeyPublic(publicKey)
    }
    
    public static func decode(_ rlpEncodedKey: String) throws -> AccountKeyPublic {
        guard let bytes = rlpEncodedKey.bytesFromHex else {
            throw CaverError.invalidValue
        }
        
        return try decode(bytes)
    }
    
    public static func decode(_ rlpEncodedKey: [UInt8]) throws -> AccountKeyPublic {
        if rlpEncodedKey[0] != RLP {
            throw CaverError.IllegalArgumentException("Invalid RLP-encoded AccountKeyPublic Tag")
        }
        
        //remove Tag
        let encodedPublicKey = rlpEncodedKey[1..<rlpEncodedKey.count]
        guard let compressedPubKey = Rlp.decode(Array(encodedPublicKey)) as? String,
              let publicKey = try? AccountKeyPublicUtils.decompressPublicKey(compressedPubKey)
        else { throw CaverError.RuntimeException("There is an error while decoding process.")}
        
        
        return AccountKeyPublic(publicKey)
    }
    
    enum CodingKeys: String, CodingKey {
        case keyType
        case key
        case x
        case y
    }
    
    public override func encode(to encoder: Encoder) throws {
        let xy = getXYPoint()
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Int(hex: AccountKeyPublic.TYPE), forKey: .keyType)
        
        var sub = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .key)
        try sub.encode(xy[AccountKeyPublic.OFFSET_X_POINT].addHexPrefix, forKey: .x)
        try sub.encode(xy[AccountKeyPublic.OFFSET_Y_POINT].addHexPrefix, forKey: .y)
    }
    
    public required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let keyType = (try? container.decode(UInt8.self, forKey: .keyType)) ?? 0
        let type = Data([keyType]).hexString
        if type != AccountKeyPublic.TYPE {
            throw CaverError.decodeIssue
        }
        let sub = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .key)
        let x = (try? sub.decode(String.self, forKey: .x)) ?? ""
        let y = (try? sub.decode(String.self, forKey: .y)) ?? ""
        
        self.publicKey = x.hexData!.hexString + y.hexData!.hexString.cleanHexPrefix
    }
}
