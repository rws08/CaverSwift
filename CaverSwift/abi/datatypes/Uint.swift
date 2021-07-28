//
//  Uint.swift
//  CaverSwift
//
//  Created by won on 2021/07/23.
//

import Foundation

public class Uint: Type, ABIType {
    public init(_ value: Int) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
    
    public init(_ value: BigUInt) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
    
    public static var rawType: ABIRawType { .FixedUInt(256) }
    public static var parser: ParserFunction {
        return { data in
            let first = data.first ?? ""
            return try ABIDecoder.decode(first, to: Uint.self)
        }
    }
    
    public var toValue: String {
        get {
            if value is Int {
                return String(value as! Int)
            } else if value is BigUInt {
                return String(value as! BigUInt)
            }
            
            return ""
        }
    }
}

public class Uint8: Uint {
    public override init(_ value: Int) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
    
    public override init(_ value: BigUInt) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
}

public class Uint16: Uint {
    public override init(_ value: Int) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
    
    public override init(_ value: BigUInt) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
}

public class Uint24: Uint {
    public override init(_ value: Int) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
    
    public override init(_ value: BigUInt) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
}

public class Uint32: Uint {
    public override init(_ value: Int) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
    
    public override init(_ value: BigUInt) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
}

public class Uint40: Uint {
    public override init(_ value: Int) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
    
    public override init(_ value: BigUInt) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
}

public class Uint48: Uint {
    public override init(_ value: Int) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
    
    public override init(_ value: BigUInt) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
}

public class Uint56: Uint {
    public override init(_ value: Int) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
    
    public override init(_ value: BigUInt) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
}

public class Uint64: Uint {
    public override init(_ value: Int) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
    
    public override init(_ value: BigUInt) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
}

public class Uint72: Uint {
    public override init(_ value: Int) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
    
    public override init(_ value: BigUInt) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
}

public class Uint80: Uint {
    public override init(_ value: Int) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
    
    public override init(_ value: BigUInt) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
}

public class Uint88: Uint {
    public override init(_ value: Int) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
    
    public override init(_ value: BigUInt) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
}

public class Uint96: Uint {
    public override init(_ value: Int) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
    
    public override init(_ value: BigUInt) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
}

public class Uint104: Uint {
    public override init(_ value: Int) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
    
    public override init(_ value: BigUInt) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
}

public class Uint112: Uint {
    public override init(_ value: Int) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
    
    public override init(_ value: BigUInt) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
}

public class Uint120: Uint {
    public override init(_ value: Int) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
    
    public override init(_ value: BigUInt) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
}

public class Uint128: Uint {
    public override init(_ value: Int) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
    
    public override init(_ value: BigUInt) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
}

public class Uint136: Uint {
    public override init(_ value: Int) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
    
    public override init(_ value: BigUInt) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
}

public class Uint144: Uint {
    public override init(_ value: Int) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
    
    public override init(_ value: BigUInt) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
}

public class Uint152: Uint {
    public override init(_ value: Int) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
    
    public override init(_ value: BigUInt) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
}

public class Uint160: Uint {
    public override init(_ value: Int) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
    
    public override init(_ value: BigUInt) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
}

public class Uint168: Uint {
    public override init(_ value: Int) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
    
    public override init(_ value: BigUInt) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
}

public class Uint176: Uint {
    public override init(_ value: Int) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
    
    public override init(_ value: BigUInt) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
}

public class Uint184: Uint {
    public override init(_ value: Int) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
    
    public override init(_ value: BigUInt) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
}

public class Uint192: Uint {
    public override init(_ value: Int) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
    
    public override init(_ value: BigUInt) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
}

public class Uint200: Uint {
    public override init(_ value: Int) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
    
    public override init(_ value: BigUInt) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
}

public class Uint208: Uint {
    public override init(_ value: Int) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
    
    public override init(_ value: BigUInt) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
}

public class Uint216: Uint {
    public override init(_ value: Int) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
    
    public override init(_ value: BigUInt) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
}

public class Uint224: Uint {
    public override init(_ value: Int) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
    
    public override init(_ value: BigUInt) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
}

public class Uint232: Uint {
    public override init(_ value: Int) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
    
    public override init(_ value: BigUInt) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
}

public class Uint240: Uint {
    public override init(_ value: Int) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
    
    public override init(_ value: BigUInt) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
}

public class Uint248: Uint {
    public override init(_ value: Int) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
    
    public override init(_ value: BigUInt) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
}

public class Uint256: Uint {
    public override init(_ value: Int) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
    
    public override init(_ value: BigUInt) {
        super.init(value)
        self.rawType = .FixedUInt(self.size)
    }
}
