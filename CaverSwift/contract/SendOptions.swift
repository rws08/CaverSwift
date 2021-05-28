//
//  SendOptions.swift
//  CaverSwift
//
//  Created by won on 2021/05/10.
//

import Foundation
import BigInt

class SendOptions {
    var from: String?
    var gas: String?
    var value = "0x0"
    
    init(_ from: String? = nil, _ gas: String? = nil, _ value: String = "0x0") {
        try? setFrom(from)
        try? setGas(gas)
        try? setValue(value)
    }
    
    init(_ from: String? = nil, _ gas: BigInt, _ value: BigInt) {
        try? setFrom(from)
        try? setGas(gas)
        setValue(value)
    }
    
    convenience init(_ from: String? = nil, _ gas: BigInt) {
        self.init(from, gas, BigInt.zero)
    }
    
    public func setFrom(_ from: String? = nil) throws {
        if from != nil {
            guard Utils.isAddress(from!) else {
                throw CaverError.ArgumentException("Invalid address. : " + from!)
            }
        }
        self.from = from
    }
    
    public func setGas(_ gas: String?) throws {
        if gas != nil {
            guard Utils.isNumber(gas!) else {
                throw CaverError.ArgumentException("Invalid gas. : " + gas!)
            }
        }
        self.gas = gas
    }
    
    public func setGas(_ gas: BigInt) throws {
        self.gas = String(bytes: gas.web3.bytes)
    }
    
    public func setValue(_ value: String?) throws {
        if value == nil {
            self.value = "0x0"
        } else {
            guard Utils.isNumber(value!) else {
                throw CaverError.ArgumentException("Invalid value. : " + value!)
            }
            self.value = value!
        }
    }
    
    public func setValue(_ value: BigInt) {
        let gas = String(bytes: value.web3.bytes)
        try? self.setValue(gas)
    }
}
