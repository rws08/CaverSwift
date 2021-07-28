//
//  Array.swift
//  CaverSwift
//
//  Created by won on 2021/05/25.
//

import Foundation

public class TypeArray: Type, ABIType {
    public var values: [ABIType]
    override var typeName: String { return String(describing: type(of: self)).lowercased() }
    override var size: Int { Int(self.typeName.filter { "0"..."9" ~= $0 }) ?? 0 }
    
    public init(_ values: [ABIType], _ solidityType: String? = nil) {
        self.values = values
        super.init(values.isEmpty ? TypeArray([""]) : values.first!)
        
        if solidityType != nil {
            self.rawType = ABIRawType(rawValue: solidityType!) ?? .DynamicArray(.DynamicString)
            guard let components = solidityType?.components(separatedBy: CharacterSet(charactersIn: "[]")) else { return }
            self.subRawType = ABIRawType(rawValue: String(describing: components[0])) ?? .DynamicString
            if components.count > 3 {
                let sub = solidityType?[solidityType!.startIndex..<solidityType!.lastIndex(of: "[")!]
                self.subRawType = ABIRawType(rawValue: String(describing: String(sub!))) ?? .DynamicString
            }
        } else if let val = values.first {
            self.rawType = .DynamicArray(type(of: val).rawType)
        }
        self.value = self
    }
    
    public init(_ values: [ABIType], _ rawType: ABIRawType) {
        self.values = values
        super.init(values.isEmpty ? TypeArray([""]) : values.first!)
        
        self.rawType = rawType
        self.subRawType = rawType.subType ?? .DynamicString
        
        self.value = self
    }
    
    public var subRawType: ABIRawType = .DynamicString
    var subParser: ParserFunction = String.parser
    
    public static var rawType: ABIRawType {
        .DynamicArray(.DynamicString)
    }
    
    public static var parser: ParserFunction {
        String.parser
    }
    
    public var parser: ParserFunction {
        return self.subParser
    }
}

public class DynamicArray: TypeArray {
    public override init(_ values: [ABIType], _ rawType: ABIRawType) {
        super.init(values, rawType)
    }
    
    public override init(_ values: [ABIType], _ solidityType: String? = nil) {
        if solidityType == nil {
            if let val = (values.first as? Type) {
                super.init(values, ABIRawType.DynamicArray(val.rawType).rawValue)
            } else {
                super.init(values, ABIRawType.DynamicArray(type(of: values.first!).rawType).rawValue)
            }
        } else {
            super.init(values, solidityType)
        }
    }
}

public class StaticArray: TypeArray {
    public override init(_ values: [ABIType], _ rawType: ABIRawType) {
        super.init(values, rawType)
    }
    
    public override init(_ values: [ABIType], _ solidityType: String? = nil) {
        if solidityType == nil {
            super.init(values, ABIRawType.FixedArray(type(of: values.first!).rawType, values.count).rawValue)
        } else {
            super.init(values, solidityType)
        }
    }
}

public class StaticArray1: StaticArray {
    public init(_ values: [ABIType]) {
        super.init(values)
        self.rawType = .FixedArray(type(of: values.first!).rawType, self.size)
    }
}

public class StaticArray2: StaticArray {
    public init(_ values: [ABIType]) {
        super.init(values)
        self.rawType = .FixedArray(type(of: values.first!).rawType, self.size)
    }
}

public class StaticArray3: StaticArray {
    public init(_ values: [ABIType]) {
        super.init(values)
        self.rawType = .FixedArray(type(of: values.first!).rawType, self.size)
    }
}

public class StaticArray4: StaticArray {
    public init(_ values: [ABIType]) {
        super.init(values)
        self.rawType = .FixedArray(type(of: values.first!).rawType, self.size)
    }
}

public class StaticArray5: StaticArray {
    public init(_ values: [ABIType]) {
        super.init(values)
        self.rawType = .FixedArray(type(of: values.first!).rawType, self.size)
    }
}

public class StaticArray6: StaticArray {
    public init(_ values: [ABIType]) {
        super.init(values)
        self.rawType = .FixedArray(type(of: values.first!).rawType, self.size)
    }
}

public class StaticArray7: StaticArray {
    public init(_ values: [ABIType]) {
        super.init(values)
        self.rawType = .FixedArray(type(of: values.first!).rawType, self.size)
    }
}

public class StaticArray8: StaticArray {
    public init(_ values: [ABIType]) {
        super.init(values)
        self.rawType = .FixedArray(type(of: values.first!).rawType, self.size)
    }
}

public class StaticArray9: StaticArray {
    public init(_ values: [ABIType]) {
        super.init(values)
        self.rawType = .FixedArray(type(of: values.first!).rawType, self.size)
    }
}

public class StaticArray10: StaticArray {
    public init(_ values: [ABIType]) {
        super.init(values)
        self.rawType = .FixedArray(type(of: values.first!).rawType, self.size)
    }
}

public class StaticArray11: StaticArray {
    public init(_ values: [ABIType]) {
        super.init(values)
        self.rawType = .FixedArray(type(of: values.first!).rawType, self.size)
    }
}

public class StaticArray12: StaticArray {
    public init(_ values: [ABIType]) {
        super.init(values)
        self.rawType = .FixedArray(type(of: values.first!).rawType, self.size)
    }
}

public class StaticArray13: StaticArray {
    public init(_ values: [ABIType]) {
        super.init(values)
        self.rawType = .FixedArray(type(of: values.first!).rawType, self.size)
    }
}

public class StaticArray14: StaticArray {
    public init(_ values: [ABIType]) {
        super.init(values)
        self.rawType = .FixedArray(type(of: values.first!).rawType, self.size)
    }
}

public class StaticArray15: StaticArray {
    public init(_ values: [ABIType]) {
        super.init(values)
        self.rawType = .FixedArray(type(of: values.first!).rawType, self.size)
    }
}

public class StaticArray16: StaticArray {
    public init(_ values: [ABIType]) {
        super.init(values)
        self.rawType = .FixedArray(type(of: values.first!).rawType, self.size)
    }
}

public class StaticArray17: StaticArray {
    public init(_ values: [ABIType]) {
        super.init(values)
        self.rawType = .FixedArray(type(of: values.first!).rawType, self.size)
    }
}

public class StaticArray18: StaticArray {
    public init(_ values: [ABIType]) {
        super.init(values)
        self.rawType = .FixedArray(type(of: values.first!).rawType, self.size)
    }
}

public class StaticArray19: StaticArray {
    public init(_ values: [ABIType]) {
        super.init(values)
        self.rawType = .FixedArray(type(of: values.first!).rawType, self.size)
    }
}

public class StaticArray20: StaticArray {
    public init(_ values: [ABIType]) {
        super.init(values)
        self.rawType = .FixedArray(type(of: values.first!).rawType, self.size)
    }
}

public class StaticArray21: StaticArray {
    public init(_ values: [ABIType]) {
        super.init(values)
        self.rawType = .FixedArray(type(of: values.first!).rawType, self.size)
    }
}

public class StaticArray22: StaticArray {
    public init(_ values: [ABIType]) {
        super.init(values)
        self.rawType = .FixedArray(type(of: values.first!).rawType, self.size)
    }
}

public class StaticArray23: StaticArray {
    public init(_ values: [ABIType]) {
        super.init(values)
        self.rawType = .FixedArray(type(of: values.first!).rawType, self.size)
    }
}

public class StaticArray24: StaticArray {
    public init(_ values: [ABIType]) {
        super.init(values)
        self.rawType = .FixedArray(type(of: values.first!).rawType, self.size)
    }
}

public class StaticArray25: StaticArray {
    public init(_ values: [ABIType]) {
        super.init(values)
        self.rawType = .FixedArray(type(of: values.first!).rawType, self.size)
    }
}

public class StaticArray26: StaticArray {
    public init(_ values: [ABIType]) {
        super.init(values)
        self.rawType = .FixedArray(type(of: values.first!).rawType, self.size)
    }
}

public class StaticArray27: StaticArray {
    public init(_ values: [ABIType]) {
        super.init(values)
        self.rawType = .FixedArray(type(of: values.first!).rawType, self.size)
    }
}

public class StaticArray28: StaticArray {
    public init(_ values: [ABIType]) {
        super.init(values)
        self.rawType = .FixedArray(type(of: values.first!).rawType, self.size)
    }
}

public class StaticArray29: StaticArray {
    public init(_ values: [ABIType]) {
        super.init(values)
        self.rawType = .FixedArray(type(of: values.first!).rawType, self.size)
    }
}

public class StaticArray30: StaticArray {
    public init(_ values: [ABIType]) {
        super.init(values)
        self.rawType = .FixedArray(type(of: values.first!).rawType, self.size)
    }
}

public class StaticArray31: StaticArray {
    public init(_ values: [ABIType]) {
        super.init(values)
        self.rawType = .FixedArray(type(of: values.first!).rawType, self.size)
    }
}

public class StaticArray32: StaticArray {
    public init(_ values: [ABIType]) {
        super.init(values)
        self.rawType = .FixedArray(type(of: values.first!).rawType, self.size)
    }
}
