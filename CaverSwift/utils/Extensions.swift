//
//  Extensions.swift
//  CaverSwift
//
//  Created by won on 2021/06/28.
//

import Foundation
import secp256k1
import SwiftECC
import BigInt
import keccaktiny

extension StringProtocol {
    public var cleanHexPrefix: String { isHexa ? String(dropFirst(2)) : self as! String }
    public var addHexPrefix: String { isHexa ? self as! String : "0x\(self)"}
    public var hexaToDecimal: Int { Int(cleanHexPrefix, radix: 16) ?? 0 }
    public var decimalToHexa: String { .init(Int(self) ?? 0, radix: 16) }
    public var isHexa: Bool { return hasPrefix("0x") || hasPrefix("0X") }
    public var checkHexaLength: Bool { return self[0] == "-" ? (self.count - 1) % 2 == 0 : self.count % 2 == 0 }
    var matchEven: String {
        if !checkHexaLength {
            if (self[0] == "-") {
                if isHexa { return "0x0" + String(dropFirst(2)) }
                else { return "-0" + self[1..<count]}
            } else {
                if isHexa { return "0x0" + String(dropFirst(2)) }
                else { return "0" + self}
            }
        }
        return self as! String
    }
    
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
    public var hexa: String { .init(self, radix: 16).matchEven }
    public var decimal: String { .init(self, radix: 10) }
    public var double: BDouble { BDouble(self.decimal) ?? BDouble.zero }
}

public extension BigUInt {
    init?(hex: String) {
        self.init(hex.noHexPrefix.lowercased(), radix: 16)
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
        self.init(hex.noHexPrefix.lowercased(), radix: 16)
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
        self.init(hex.noHexPrefix, radix: 16)
    }
    
    var hexString: String {
        return "0x" + String(format: "%x", self)
    }
}

public extension Data {
    init?(hex: String) {
        if let byteArray = try? HexUtil.byteArray(fromHex: hex.noHexPrefix) {
            self.init(bytes: byteArray, count: byteArray.count)
        } else {
            return nil
        }
    }
    
    var hexString: String {
        let bytes = Array<UInt8>(self)
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
    
    var sha3: Data {
        return keccak256
    }
}

public extension String {
    init(bytes: [UInt8]) {
        self.init("0x" + bytes.map { String(format: "%02hhx", $0) }.joined())
    }
    
    var noHexPrefix: String {
        if self.hasPrefix("0x") {
            let index = self.index(self.startIndex, offsetBy: 2)
            if self.count % 2 == 0 {
                return String(self[index...])
            } else {
                return String("0" + self[index...])
            }
        }
        return self
    }
    
    var withHexPrefix: String {
        if !self.hasPrefix("0x") {
            return "0x" + self
        }
        return self
    }
    
    var stringValue: String {
        if let byteArray = try? HexUtil.byteArray(fromHex: self.noHexPrefix), let str = String(bytes: byteArray, encoding: .utf8) {
            return str
        }
        
        return self
    }
    
    var hexData: Data? {
        let noHexPrefix = self.noHexPrefix
        if let bytes = try? HexUtil.byteArray(fromHex: noHexPrefix) {
            return Data( bytes)
        }
        
        return nil
    }
    
    var bytes: [UInt8] {
        return [UInt8](self.utf8)
    }
    
    var bytesFromHex: [UInt8]? {
        let hex = self.noHexPrefix
        do {
            let byteArray = try HexUtil.byteArray(fromHex: hex)
            return byteArray
        } catch {
            return nil
        }
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
        let data = self.data(using: .utf8) ?? Data()
        return data.keccak256
    }
    
    var keccak256fromHex: Data {
        let data = self.hexData!
        return data.keccak256
    }
    
    var sha3String: String {
        return String(bytes: keccak256.bytes).withHexPrefix
    }
}
