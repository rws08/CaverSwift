//
//  Struct.swift
//  CaverSwift
//
//  Created by won on 2021/07/23.
//

import Foundation

public class TypeStruct: Equatable, ABIType {
    public static func == (lhs: TypeStruct, rhs: TypeStruct) -> Bool {
        return lhs.values.elementsEqual(rhs.values) { lhsItem, rhsItem in
            Type(lhsItem) == Type(rhsItem)
        }
    }
    
    public var values: [ABIType]
    
    public init(_ values: [ABIType], _ subRawType:[ABIRawType] = []) {
        self.values = values
        if subRawType.isEmpty {
            self.subRawType = values.map {
                Type($0).rawType
            }
        } else {
            self.subRawType = subRawType
        }
    }
    public var subRawType: [ABIRawType] = []
    var subParser: ParserFunction = String.parser
    
    public static var rawType: ABIRawType {
        .Tuple([])
    }
    
    public static var parser: ParserFunction {
        String.parser
    }
    
    public var value: ABIType { self }
    public var rawType: ABIRawType { .Tuple(self.subRawType) }
    public var parser: ParserFunction {
        return self.subParser
    }
}

public class DynamicStruct: TypeStruct { }

public class StaticStruct: TypeStruct { }

