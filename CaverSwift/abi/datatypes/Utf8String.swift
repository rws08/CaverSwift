//
//  Utf8String.swift
//  CaverSwift
//
//  Created by won on 2021/07/23.
//

import Foundation

public class Utf8String: Type {
    init(_ value: String) {
        super.init(value, String.rawType)
    }
    
    public var toValue: String {
        get {
            return value as! String
        }
    }
}
