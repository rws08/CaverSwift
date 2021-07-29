//
//  Bytes.swift
//  CaverSwift
//
//  Created by won on 2021/05/25.
//

import Foundation

public class Bytes: Type, Decodable {
    public init(_ value: Data) {
        super.init(value, .DynamicBytes)
    }
    
    public var toValue: String {
        get {
            return String(bytes: (value as! Data).bytes)
        }
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let val = (try? container.decode(String.self)) ?? ""        
        super.init(val.hexData!, .DynamicBytes)
    }
}

public class Bytes1: Bytes {
    public override init(_ value: Data) {
        super.init(value)
        self.rawType = .FixedBytes(self.size)
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        self.rawType = .FixedBytes(self.size)
    }
}

public class Bytes2: Bytes {
    public override init(_ value: Data) {
        super.init(value)
        self.rawType = .FixedBytes(self.size)
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        self.rawType = .FixedBytes(self.size)
    }
}

public class Bytes3: Bytes {
    public override init(_ value: Data) {
        super.init(value)
        self.rawType = .FixedBytes(self.size)
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        self.rawType = .FixedBytes(self.size)
    }
}

public class Bytes4: Bytes {
    public override init(_ value: Data) {
        super.init(value)
        self.rawType = .FixedBytes(self.size)
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        self.rawType = .FixedBytes(self.size)
    }
}

public class Bytes5: Bytes {
    public override init(_ value: Data) {
        super.init(value)
        self.rawType = .FixedBytes(self.size)
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        self.rawType = .FixedBytes(self.size)
    }
}

public class Bytes6: Bytes {
    public override init(_ value: Data) {
        super.init(value)
        self.rawType = .FixedBytes(self.size)
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        self.rawType = .FixedBytes(self.size)
    }
}

public class Bytes7: Bytes {
    public override init(_ value: Data) {
        super.init(value)
        self.rawType = .FixedBytes(self.size)
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        self.rawType = .FixedBytes(self.size)
    }
}

public class Bytes8: Bytes {
    public override init(_ value: Data) {
        super.init(value)
        self.rawType = .FixedBytes(self.size)
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        self.rawType = .FixedBytes(self.size)
    }
}

public class Bytes9: Bytes {
    public override init(_ value: Data) {
        super.init(value)
        self.rawType = .FixedBytes(self.size)
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        self.rawType = .FixedBytes(self.size)
    }
}

public class Bytes10: Bytes {
    public override init(_ value: Data) {
        super.init(value)
        self.rawType = .FixedBytes(self.size)
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        self.rawType = .FixedBytes(self.size)
    }
}

public class Bytes11: Bytes {
    public override init(_ value: Data) {
        super.init(value)
        self.rawType = .FixedBytes(self.size)
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        self.rawType = .FixedBytes(self.size)
    }
}

public class Bytes12: Bytes {
    public override init(_ value: Data) {
        super.init(value)
        self.rawType = .FixedBytes(self.size)
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        self.rawType = .FixedBytes(self.size)
    }
}

public class Bytes13: Bytes {
    public override init(_ value: Data) {
        super.init(value)
        self.rawType = .FixedBytes(self.size)
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        self.rawType = .FixedBytes(self.size)
    }
}

public class Bytes14: Bytes {
    public override init(_ value: Data) {
        super.init(value)
        self.rawType = .FixedBytes(self.size)
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        self.rawType = .FixedBytes(self.size)
    }
}

public class Bytes15: Bytes {
    public override init(_ value: Data) {
        super.init(value)
        self.rawType = .FixedBytes(self.size)
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        self.rawType = .FixedBytes(self.size)
    }
}

public class Bytes16: Bytes {
    public override init(_ value: Data) {
        super.init(value)
        self.rawType = .FixedBytes(self.size)
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        self.rawType = .FixedBytes(self.size)
    }
}

public class Bytes17: Bytes {
    public override init(_ value: Data) {
        super.init(value)
        self.rawType = .FixedBytes(self.size)
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        self.rawType = .FixedBytes(self.size)
    }
}

public class Bytes18: Bytes {
    public override init(_ value: Data) {
        super.init(value)
        self.rawType = .FixedBytes(self.size)
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        self.rawType = .FixedBytes(self.size)
    }
}

public class Bytes19: Bytes {
    public override init(_ value: Data) {
        super.init(value)
        self.rawType = .FixedBytes(self.size)
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        self.rawType = .FixedBytes(self.size)
    }
}

public class Bytes20: Bytes {
    public override init(_ value: Data) {
        super.init(value)
        self.rawType = .FixedBytes(self.size)
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        self.rawType = .FixedBytes(self.size)
    }
}

public class Bytes21: Bytes {
    public override init(_ value: Data) {
        super.init(value)
        self.rawType = .FixedBytes(self.size)
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        self.rawType = .FixedBytes(self.size)
    }
}

public class Bytes22: Bytes {
    public override init(_ value: Data) {
        super.init(value)
        self.rawType = .FixedBytes(self.size)
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        self.rawType = .FixedBytes(self.size)
    }
}

public class Bytes23: Bytes {
    public override init(_ value: Data) {
        super.init(value)
        self.rawType = .FixedBytes(self.size)
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        self.rawType = .FixedBytes(self.size)
    }
}

public class Bytes24: Bytes {
    public override init(_ value: Data) {
        super.init(value)
        self.rawType = .FixedBytes(self.size)
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        self.rawType = .FixedBytes(self.size)
    }
}

public class Bytes25: Bytes {
    public override init(_ value: Data) {
        super.init(value)
        self.rawType = .FixedBytes(self.size)
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        self.rawType = .FixedBytes(self.size)
    }
}

public class Bytes26: Bytes {
    public override init(_ value: Data) {
        super.init(value)
        self.rawType = .FixedBytes(self.size)
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        self.rawType = .FixedBytes(self.size)
    }
}

public class Bytes27: Bytes {
    public override init(_ value: Data) {
        super.init(value)
        self.rawType = .FixedBytes(self.size)
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        self.rawType = .FixedBytes(self.size)
    }
}

public class Bytes28: Bytes {
    public override init(_ value: Data) {
        super.init(value)
        self.rawType = .FixedBytes(self.size)
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        self.rawType = .FixedBytes(self.size)
    }
}

public class Bytes29: Bytes {
    public override init(_ value: Data) {
        super.init(value)
        self.rawType = .FixedBytes(self.size)
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        self.rawType = .FixedBytes(self.size)
    }
}

public class Bytes30: Bytes {
    public override init(_ value: Data) {
        super.init(value)
        self.rawType = .FixedBytes(self.size)
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        self.rawType = .FixedBytes(self.size)
    }
}

public class Bytes31: Bytes {
    public override init(_ value: Data) {
        super.init(value)
        self.rawType = .FixedBytes(self.size)
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        self.rawType = .FixedBytes(self.size)
    }
}

public class Bytes32: Bytes {
    public override init(_ value: Data) {
        super.init(value)
        self.rawType = .FixedBytes(self.size)
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        self.rawType = .FixedBytes(self.size)
    }
}
