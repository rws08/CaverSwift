//
//  Quantity.swift
//  Caver-swift
//
//  Created by won on 2021/05/11.
//

import Foundation
import BigInt

class Quantity: ABIResponse {
    required init?(values: [ABIDecoder.DecodedValue]) throws {
        
    }
    
    static var types: [ABIType.Type] = [BigUInt.self, ABIArray<String>.self]
    
    func getValue() {
        
    }
}
