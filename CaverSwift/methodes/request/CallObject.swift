//
//  CallObject.swift
//  CaverSwift
//
//  Created by won on 2021/05/10.
//

import Foundation
import BigInt

class CallObject {
    var from: String?
    var to: String?
    var gasLimit: BigInt?
    var gasPrice: BigInt?
    var value: BigInt?
    var data: String?
    
    init(_ from: String? = nil, _ to: String? = nil, _ gasLimit: BigInt? = nil, _ gasPrice: BigInt? = nil, _ value: BigInt? = nil, _ data: String? = nil) {
        self.from = from
        self.to = to
        self.gasLimit = gasLimit
        self.gasPrice = gasPrice
        self.value = value
        self.data = data
    }
    
    public func getGasLimit() -> String? {
        return convert(gasLimit)
    }
    
    public func getGasPrice() -> String? {
        return convert(gasPrice)
    }
    
    public func getValue() -> String? {
        return convert(value)
    }
    
    private func convert(_ value: BigInt?) -> String? {
        guard let value = value else {
            return nil
        }
        
        return RLP.encode(value)?.web3.hexString
    }
}
