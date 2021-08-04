//
//  ABIFunction.swift
//  web3swift
//
//  Created by Matt Marshall on 09/04/2018.
//  Copyright © 2018 Argent Labs Limited. All rights reserved.
//

import Foundation
import BigInt

public protocol ABIFunction {
    static var name: String { get }
    var gasPrice: BigUInt? { get }
    var gasLimit: BigUInt? { get }
    var contract: Address { get }
    var from: Address? { get }
    func encode(to encoder: ABIFunctionEncoder) throws
}

public protocol ABIResponse: ABITupleDecodable {}
