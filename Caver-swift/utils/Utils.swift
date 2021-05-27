//
//  Utils.swift
//  Caver-swift
//
//  Created by won on 2021/05/10.
//

import Foundation
import BigInt

class Utils {
    private static let baseAddrPattern = "^(0x)?[0-9a-f]{40}$"
    private static let lowerCasePattern = "^(0x|0X)?[0-9a-f]{40}$"
    private static let upperCasePattern = "^(0x|0X)?[0-9A-F]{40}$"

    public static func isAddress(_ address: String) -> Bool {
        let baseAddrCase = try! NSRegularExpression(pattern: Utils.baseAddrPattern, options: [.caseInsensitive])
        let lowerCase = try! NSRegularExpression(pattern: Utils.lowerCasePattern, options: [])
        let upperCase = try! NSRegularExpression(pattern: Utils.upperCasePattern, options: [])
        let range = NSRange(0..<address.utf16.count)

        if baseAddrCase.matches(in: address, options: [], range: range).isEmpty {
            return false
        }
        
        if !lowerCase.matches(in: address, options: [], range: range).isEmpty ||
            !upperCase.matches(in: address, options: [], range: range).isEmpty {
            return true
        }
        
        return checkAddressChecksum(address: address)
    }
    
    public static func isNumber(_ input: String) -> Bool {        
        if BigInt.init(hex: input.lowercased()) == nil {
            return false
        }
        return true
    }
    
    public static func checkAddressChecksum(address: String) -> Bool {
        return address.hexaToDecimal != 0
    }
    
    public static func getStaticArrayElementSize(_ array: TypeArray) -> Int {
        var count = 0
        switch array.subRawType {
        case .Tuple(_):
            let item = array.values.first as! TypeStruct
            count += array.values.count * getStaticStructComponentSize(item)
            break
        case .FixedArray(_, _):
            let item = array.values.first as! TypeArray
            count += array.values.count * getStaticArrayElementSize(item)
            break
        default:
            count += array.values.count
            break
        }
        return count
    }
    
    public static func getStaticStructComponentSize(_ staticStruct: TypeStruct) -> Int {
        var count = 0
        staticStruct.values.forEach {
            switch type(of: $0).rawType {
            case .Tuple(_):
                let item = $0 as! TypeStruct
                count += getStaticStructComponentSize(item)
                break
            case .FixedArray(_, _):
                let item = $0 as! TypeArray
                count += getStaticArrayElementSize(item)
                break
            default:
                count += 1
                break
            }
        }
        return count
    }
}

extension StringProtocol {
    var drop0xPrefix: String { isHexa ? String(dropFirst(2)) : self as! String }
    var hexaToDecimal: Int { Int(drop0xPrefix, radix: 16) ?? 0 }
    var decimalToHexa: String { .init(Int(self) ?? 0, radix: 16) }
    var isHexa: Bool { return hasPrefix("0x") || hasPrefix("0X") }
    var checkHexaLength: Bool { return self[0] == "-" ? (self.count - 1) % 2 == 0 : self.count % 2 == 0 }
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
    var binary: String { .init(self, radix: 2) }
    var hexa: String { .init(self, radix: 16).matchEven }
}

func WARNING(filename: String = #file, line: Int = #line, funcname: String = #function, message:Any...) {
    print("\(filename)[\(funcname)][Line \(line)] \(message)")
}
