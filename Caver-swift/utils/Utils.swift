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
            let item = array.values.first as! ABITuple
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
    
    public static func getStaticStructComponentSize(_ staticStruct: ABITuple) -> Int {
        var count = 0
        staticStruct.encodableValues.forEach {
            switch type(of: $0).rawType {
            case .Tuple(_):
                let item = $0 as! ABITuple
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
    var drop0xPrefix: String { hasPrefix("0x") || hasPrefix("0X") ? String(dropFirst(2)) : self as! String }
    var hexaToDecimal: Int { Int(drop0xPrefix, radix: 16) ?? 0 }
    var decimalToHexa: String { .init(Int(self) ?? 0, radix: 16) }
}

extension BinaryInteger {
    var binary: String { .init(self, radix: 2) }
    var hexa: String { .init(self, radix: 16) }
}

func WARNING(filename: String = #file, line: Int = #line, funcname: String = #function, message:Any...) {
    print("\(filename)[\(funcname)][Line \(line)] \(message)")
}
