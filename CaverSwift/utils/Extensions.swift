//
//  Extensions.swift
//  CaverSwift
//
//  Created by won on 2021/06/28.
//

import Foundation
import secp256k1
import BigInt
import keccaktiny

extension StringProtocol {
    public var cleanHexPrefix: String {
        if isHexa {
            if isHexaPlus {
                let clean = String(dropFirst(2))
                if clean.count % 2 == 0 { //"0x0100"
                    return clean
                } else { //"0x100"
                    return "0\(clean)"
                }
            } else {
                let clean = String(dropFirst(3))
                if clean.count % 2 == 0 { //"-0x0100"
                    return "-\(clean)"
                } else { //"-0x100"
                    return "-0\(clean)"
                }
            }
        } else {
            if isMinus {
                let clean = String(dropFirst(1))
                if clean.count % 2 == 0 { //"-0100"
                    return "-\(clean)"
                } else { //"-100"
                    return "-0\(clean)"
                }
            } else {
                if self.count % 2 == 0 { //"0100"
                    return "\(self)"
                } else { //"100"
                    return "0\(self)"
                }
            }
        }
    }
    public var addHexPrefix: String {
        if !isHexa {
            if isMinus {
                return "-0x\(self)"
            } else {
                return "0x\(self)"
            }
        }
        return "\(self)"
    }
    public var hexaToDecimal: Int { Int(cleanHexPrefix, radix: 16) ?? 0 }
    public var decimalToHexa: String { .init(Int(self) ?? 0, radix: 16) }
    public var isHexa: Bool { return isHexaPlus || isHexaMinus}
    public var isHexaPlus: Bool { return hasPrefix("0x") || hasPrefix("0X") }
    public var isHexaMinus: Bool { return hasPrefix("-0x") || hasPrefix("-0X") }
    public var isMinus: Bool { return self.count > 0 && self[0] == "-" }

    subscript(offset: Int) -> Character { self[index(startIndex, offsetBy: offset)] }
    subscript(range: Range<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: ClosedRange<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: PartialRangeFrom<Int>) -> SubSequence { self[index(startIndex, offsetBy: range.lowerBound)...] }
    subscript(range: PartialRangeThrough<Int>) -> SubSequence { self[...index(startIndex, offsetBy: range.upperBound)] }
    subscript(range: PartialRangeUpTo<Int>) -> SubSequence { self[..<index(startIndex, offsetBy: range.upperBound)] }
    
    func startsWith(_ prefix: String, _ i: Int = 0) -> Bool {
        if self.count <= i+prefix.count { return false }
        return self[i..<(i+prefix.count)] == prefix
    }
}

extension BinaryInteger {
    public var binary: String { .init(self, radix: 2) }
    public var hexa: String { .init(self, radix: 16).addHexPrefix }
    public var decimal: String { .init(self, radix: 10) }
    public var double: BDouble { BDouble(self.decimal) ?? BDouble.zero }
}

public extension BigUInt {
    init?(hex: String) {
        self.init(hex.cleanHexPrefix.lowercased(), radix: 16)
    }
    
    var bytes: [UInt8] {
        let data = self.magnitude.serialize()
        let bytes = data.bytes
        let lastIndex = bytes.count - 1
        let firstIndex = bytes.firstIndex(where: {$0 != 0x00}) ?? lastIndex
        
        if lastIndex < 0 {
            return Array([0])
        }
        
        return Array(bytes[firstIndex...lastIndex])
    }
    
    var hexString: String {
        return String(bytes: self.bytes)
    }
}

public extension BigInt {
    init?(hex: String) {
        let num = hex.cleanHexPrefix
        if num.count == 0 {
            self.init(0)
        }
        self.init(num.lowercased(), radix: 16)
    }
    
    init(twosComplement data: Data) {
        let unsigned = BigUInt(data)
        self.init(BigInt(unsigned))
        if data[0] == 0xff {
            self.negate()
        }
    }
    
    var bytes: [UInt8] {
        let data: Data
        if self.sign == .plus {
            data = self.magnitude.serialize()
        } else {
            // Twos Complement
            let len = self.magnitude.serialize().count
            let maximum = BigUInt(1) << (len * 8)
            let twosComplement = maximum - self.magnitude
            data = twosComplement.serialize()
        }
        
        
        let bytes = data.bytes
        let lastIndex = bytes.count - 1
        let firstIndex = bytes.firstIndex(where: {$0 != 0x00}) ?? lastIndex
        
        if lastIndex < 0 {
            return Array([0])
        }
        
        return Array(bytes[firstIndex...lastIndex])
    }
}

public extension Int {
    init?(hex: String) {
        self.init(hex.cleanHexPrefix, radix: 16)
    }
    
    var hexString: String {
        return "0x" + String(format: "%x", self)
    }
}

public extension Data {
    init?(hex: String) {
        if let byteArray = try? HexUtil.byteArray(fromHex: hex.cleanHexPrefix) {
            self.init(bytes: byteArray, count: byteArray.count)
        } else {
            return nil
        }
    }
    
    var hexString: String {
        let bytes = [UInt8](self)
        return "0x" + bytes.map { String(format: "%02hhx", $0) }.joined()
    }
    
    static func ^ (lhs: Data, rhs: Data) -> Data {
        let bytes = zip(lhs.bytes, rhs.bytes).map { lhsByte, rhsByte in
            return lhsByte ^ rhsByte
        }
        
        return Data(bytes)
    }
    
    var bytes: [UInt8] {
        return Array(self)
    }
    
    var strippingZeroesFromBytes: Data {
        var bytes = self.bytes
        while bytes.first == 0 {
            bytes.removeFirst()
        }
        return Data.init(bytes)
    }
    
    var bytes4: Data {
        return self.prefix(4)
    }
    
    static func randomOfLength(_ length: Int) -> Data? {
        var data = [UInt8](repeating: 0, count: length)
        let result = SecRandomCopyBytes(kSecRandomDefault,
                               data.count,
                               &data)
        if result == errSecSuccess {
            return Data(data)
        }
        
        return nil
    }
    
    var keccak256: Data {
        let result = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
        defer {
            result.deallocate()
        }
        let nsData = self as NSData
        let input = nsData.bytes.bindMemory(to: UInt8.self, capacity: self.count)
        keccak_256(result, 32, input, self.count)
        return Data(bytes: result, count: 32)
    }
}

public extension String {
    init(bytes: [UInt8]) {
        self.init("0x" + bytes.map { String(format: "%02hhx", $0) }.joined())
    }
    
    var stringValue: String {
        if let byteArray = try? HexUtil.byteArray(fromHex: self.cleanHexPrefix),
           let str = String(bytes: byteArray, encoding: .utf8) {
            return str
        }
        
        return self
    }
    
    var hexData: Data? {
        let noHexPrefix = self.cleanHexPrefix
        if let bytes = try? HexUtil.byteArray(fromHex: noHexPrefix) {
            return Data(bytes)
        }
        
        return nil
    }
    
    var bytesFromHex: [UInt8]? {
        let noHexPrefix = self.cleanHexPrefix
        if let bytes = try? HexUtil.byteArray(fromHex: noHexPrefix) {
            return bytes
        }
        
        return nil
    }
    
    var isNumeric: Bool {
        guard !self.isEmpty else {
            return false
        }
        
        guard !self.starts(with: "-") else {
            return String(self.dropFirst()).isNumeric
        }
        
        return self.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
    
    var keccak256: Data {
        guard let data = self.hexData else {
            let data = self.data(using: .utf8) ?? Data()
            return data.keccak256
        }
        
        return data.keccak256
    }
    
    var sha3String: String {
        return cleanHexPrefix.keccak256.hexString
    }
}

extension UInt8 {
    var int: Int? {
        return Int(hex: Data([self]).hexString)
    }
}

extension ArraySlice where Element == UInt8 {
    var int: Int? {
        return Int(hex: Data(self).hexString)
    }
    
    var string: String {
        return Data(self).hexString.cleanHexPrefix
    }
}

extension Array where Element == UInt8 {
    var int: Int? {
        return Int(hex: Data(self).hexString)
    }
    
    var string: String {
        return Data(self).hexString.cleanHexPrefix
    }
}
