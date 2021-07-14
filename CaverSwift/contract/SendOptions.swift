//
//  SendOptions.swift
//  CaverSwift
//
//  Created by won on 2021/05/10.
//

import Foundation
import BigInt

public class SendOptions {
    var from: String?
    var gas: String?
    var value = "0x0"
    
    public init(_ from: String? = nil, _ gas: String? = nil, _ value: String = "0x0") {
        try? setFrom(from)
        try? setGas(gas)
        try? setValue(value)
    }
    
    public init(_ from: String? = nil, _ gas: BigInt, _ value: BigInt) {
        try? setFrom(from)
        try? setGas(gas)
        setValue(value)
    }
    
    public convenience init(_ from: String? = nil, _ gas: BigInt) {
        self.init(from, gas, BigInt.zero)
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
    
    public func setGas(_ gas: BigInt) throws {
        self.gas = String(bytes: gas.bytes)
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
    
    public func setValue(_ value: BigInt) {
        let gas = String(bytes: value.bytes)
        try? self.setValue(gas)
    }
}
