//
//  AccountKeyWeightedMultiSig.swift
//  CaverSwift
//
//  Created by won on 2021/06/30.
//

import Foundation

open class AccountKeyWeightedMultiSig: IAccountKey {
    private static let RLP: UInt8 = 0x04
    static let TYPE = "0x04"
    
    var threshold: BigInt?
    
    var weightedPublicKeys: [WeightedPublicKey] = []
    
    init(_ threshold: BigInt?, _ weightedPublicKeys: [WeightedPublicKey]) {
        self.threshold = threshold
        self.weightedPublicKeys = weightedPublicKeys
    }
    
    public static func decode(_ rlpEncodedKey: String) throws -> AccountKeyWeightedMultiSig {
        guard let hex = rlpEncodedKey.bytesFromHex else {
            throw CaverError.invalidValue
        }
        return try decode(hex)
    }
    
    public static func decode(_ rlpEncodedKey: [UInt8]) throws -> AccountKeyWeightedMultiSig {
        //check tag
        if rlpEncodedKey[0] != RLP {
            throw CaverError.IllegalArgumentException("Invalid RLP-encoded AccountKeyWeightedMultiSig Tag")
        }
        
        //remove Tag
        let rlpList = Rlp.decode(Array(rlpEncodedKey[1..<rlpEncodedKey.count]))
        guard let values = rlpList as? [Any],
              let threshold = values[0] as? String,
              let threshold = BigInt(threshold),
              let rlpWeightedPublicKeys = values[1] as? [[String]] else {
            throw CaverError.RuntimeException("There is an error while decoding process.")
        }
                
        //get WeightedPublicKey
        let weightedPublicKeys: [WeightedPublicKey] = try rlpWeightedPublicKeys.map {
            guard let weight = BigInt($0[0])
            else { throw CaverError.RuntimeException("There is an error while decoding process.") }
            return try WeightedPublicKey($0[1], weight)
        }
        
        return AccountKeyWeightedMultiSig(threshold, weightedPublicKeys)
    }
    
    public static func fromPublicKeysAndOptions(_ publicKeyArr: [String], _ options: WeightedMultiSigOptions) throws -> AccountKeyWeightedMultiSig {
        if publicKeyArr.count > WeightedMultiSigOptions.MAX_COUNT_WEIGHTED_PUBLIC_KEY {
            throw CaverError.IllegalArgumentException("It exceeds maximum public key count.")
        }
        
        if publicKeyArr.count != options.weights.count {
            throw CaverError.IllegalArgumentException("The count of public keys is not equal to the length of weight array.")
        }
        
        let weightedPublicKeyList = try zip(publicKeyArr, options.weights).map {
            try WeightedPublicKey($0, $1)
        }
        
        return AccountKeyWeightedMultiSig(options.threshold, weightedPublicKeyList)
    }
    
    public override func getRLPEncoding() throws -> String {
        guard let threshold = threshold else {
            throw CaverError.NullPointerException("threshold or weightedPublicKeys must be exists for multisig.")
        }
        
        if weightedPublicKeys.count == 0 {
            throw CaverError.RuntimeException("weightedPublicKeys must have items for multisig.")
        }
        
        var rlpTypeList: [Any] = [threshold]
        
        let rlpWeightedPublicKeyList: [Any] = try weightedPublicKeys.map {
            if $0.publicKey.isEmpty {
                throw CaverError.RuntimeException("public key should be specified for a multisig account")
            }
            
            guard let weight = $0.weight else {
                throw CaverError.RuntimeException("weight should be specified for a multisig account")
            }
            
            let compressedKey = try Utils.compressPublicKey($0.publicKey)
            return [weight.description, compressedKey]
        }
        
        rlpTypeList.append(rlpWeightedPublicKeyList)
        
        guard let encodedWeightedKey = Rlp.encode(rlpTypeList) else {
            return ""
        }
        var type = Data([AccountKeyWeightedMultiSig.RLP])
        type.append(encodedWeightedKey)        
        return type.hexString
    }
}
