//
//  KIP13.swift
//  CaverSwift
//
//  Created by won on 2021/07/27.
//

import Foundation

open class KIP13: Contract {
    public init(_ caver: Caver, _ contractAddress: String? = nil) throws {
        _ = KIP13ConstantData()
        try super.init(caver, KIP13ConstantData.ABI, contractAddress)
    }
    
    public func sendQuery(_ interfaceId: String) -> Bool {
        guard let result = call("supportsInterface", interfaceId),
              let resultVal = result[0].value as? Bool else {
            return false
        }
        return resultVal
    }
    
    public func isImplementedKIP13Interface() -> Bool {
        return sendQuery("0x01ffc9a7") && !sendQuery("0xffffffff")
    }
}
