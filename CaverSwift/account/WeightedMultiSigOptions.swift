//
//  WeightedMultiSigOptions.swift
//  CaverSwift
//
//  Created by won on 2021/06/30.
//

import Foundation

open class WeightedMultiSigOptions {
    public static let MAX_COUNT_WEIGHTED_PUBLIC_KEY = 10
    
    private(set) public var threshold: BigInt?
    private(set) public var weights: [BigInt] = []
    
    init() {
        
    }
    
    init(_ threshold: BigInt?, _ weights: [BigInt]) throws {
        if (!isValidateOptions(threshold, weights)) {
            throw CaverError.IllegalArgumentException("Invalid argument in passing params.")
        }
        
        self.threshold = threshold
        self.weights = weights
    }
    
    public static func getDefaultOptionsForWeightedMultiSig(_ publicKeyArr: [String]) -> WeightedMultiSigOptions {
        let threshold = BigInt(1)
        let weights = publicKeyArr.map { _ in
            BigInt(1)
        }
        
        return try! WeightedMultiSigOptions(threshold, weights)
    }
    
    public static func getDefaultOptionsForRoleBased(_ roleBasedPublicKeys: [[String]]) -> [WeightedMultiSigOptions] {
        return roleBasedPublicKeys.map {
            if $0.count == 1 {
                return WeightedMultiSigOptions()
            } else {
                return getDefaultOptionsForWeightedMultiSig($0)
            }
        }
    }
    
    public func isValidateOptions(_ threshold: BigInt?, _ weights: [BigInt]) -> Bool {
        guard let threshold = threshold else {
            return false
        }
        //threshold value has bigger than zero.
        if threshold <= BigInt.zero {
            return false
        }
        
        //Weighted Public Key has up to 10.
        if weights.count > WeightedMultiSigOptions.MAX_COUNT_WEIGHTED_PUBLIC_KEY {
            return false
        }
        
        let sumOfWeights = weights.reduce(0, +)
        if threshold > sumOfWeights {
            return false
        }
        
        return true
    }
    
    public var isEmpty: Bool {
        return weights.isEmpty && threshold == nil
    }
}
