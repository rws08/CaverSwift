//
//  SendOptions.swift
//  CaverSwift
//
//  Created by won on 2021/05/10.
//

import Foundation
import BigInt

open class SendOptions {
    private(set) var from: String?
    private(set) var gas: String?
    private(set) var value = "0x0"
    
    public init(_ from: String? = nil, _ gas: String? = nil, _ value: String = "0x0") {
        try? setFrom(from)
        try? setGas(gas)
        try? setValue(value)
    }
    
    public init(_ from: String? = nil, _ gas: BigUInt, _ value: BigUInt) {
        try? setFrom(from)
        try? setGas(gas)
        setValue(value)
    }
    
    public convenience init(_ from: String? = nil, _ gas: BigUInt) {
        self.init(from, gas, BigUInt.zero)
    }
    
    public func setFrom(_ from: String? = nil) throws {
        if from != nil {
            guard Utils.isAddress(from!) else {
                throw CaverError.ArgumentException("Invalid address. : \(from!)")
            }
        }
        self.from = from
    }
    
    public func setGas(_ gas: String?) throws {
        if gas != nil {
            guard Utils.isNumber(gas!) else {
                throw CaverError.ArgumentException("Invalid gas. : \(gas!)")
            }
        }
        self.gas = gas
    }
    
    public func setGas(_ gas: BigUInt) throws {
        self.gas = gas.hexa
    }
    
    public func setValue(_ value: String?) throws {
        if value == nil {
            self.value = "0x0"
        } else {
            guard Utils.isNumber(value!) else {
                throw CaverError.ArgumentException("Invalid value. : \(value!)")
            }
            self.value = value!
        }
    }
    
    public func setValue(_ value: BigUInt) {
        let gas = value.hexa
        try? self.setValue(gas)
    }
}
