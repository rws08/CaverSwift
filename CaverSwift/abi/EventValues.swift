//
//  EventValues.swift
//  CaverSwift
//
//  Created by won on 2021/07/21.
//

import Foundation

public class EventValues {
    private(set) public var indexedValues: [Type] = []
    private(set) public var nonIndexedValues: [Type] = []
    
    internal init(_ indexedValues: [Type] = [], _ nonIndexedValues: [Type] = []) {
        self.indexedValues = indexedValues
        self.nonIndexedValues = nonIndexedValues
    }
}
