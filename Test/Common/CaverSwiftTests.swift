//
//  CaverSwiftTests.swift
//  CaverSwiftTests
//
//  Created by won on 2021/04/20.
//

import XCTest
@testable import CaverSwift
@testable import GenericJSON
@testable import BigInt

class CaverSwiftTests: XCTestCase {
    public func VariadicParametersOfAnyType1(_ methodArguments: Any...) -> [Any] {
        print("1", methodArguments)
        return VariadicParametersOfAnyType2(methodArguments.flatCompactMapForVariadicParameters())
    }
    
    public func VariadicParametersOfAnyType2(_ methodArguments: Any...) -> [Any] {
        print("2", methodArguments)
        return methodArguments.flatCompactMapForVariadicParameters()
    }
}
