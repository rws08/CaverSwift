//
//  Struct.swift
//  CaverSwift
//
//  Created by won on 2021/07/23.
//

import Foundation

public class TypeStruct: Type, ABIType {
    public var values: [ABIType]
    
    public init(_ values: [ABIType], _ subRawType:[ABIRawType] = []) {
        self.values = values        
        super.init(values.isEmpty ? TypeArray([""]) : values.first!)
        
        if subRawType.isEmpty {
            self.subRawType = values.map {
                Type($0).rawType
            }
        } else {
            self.subRawType = subRawType
        }
        self.value = self
        self.rawType = .Tuple(self.subRawType)
    }
    public var subRawType: [ABIRawType] = []
    var subParser: ParserFunction = String.parser
    
    public static var rawType: ABIRawType {
        .Tuple([])
    }
    
    public static var parser: ParserFunction {
        String.parser
    }
    
    public var parser: ParserFunction {
        return self.subParser
    }
}

public class DynamicStruct: TypeStruct { }

public class StaticStruct: TypeStruct { }

