//
//  Rlp.swift
//  web3swift
//
//  Created by Julien Niset on 29/06/2017.
//  Copyright © 2017 Argent Labs Limited. All rights reserved.
//

import Foundation
import BigInt

public struct Rlp {
    public static var OFFSET_SHORT_STRING: UInt8 = 0x80
    public static var OFFSET_LONG_STRING: UInt8 = 0xb7
    public static var OFFSET_SHORT_LIST: UInt8 = 0xc0
    public static var OFFSET_LONG_LIST: UInt8 = 0xf7
    
    // MARK: - Encode
    public static func encode(_ item: Any) -> Data? {
        switch item {
        case let int as Int:
            return encodeInt(int)
        case let string as String:
            return encodeString(string)
        case let bint as BigInt:
            return encodeBigInt(bint)
        case let array as [Any]:
            return encodeArray(array)
        case let buint as BigUInt:
            return encodeBigUInt(buint)
        case let data as Data:
            return encodeData(data)
        default:
            return nil
        }
    }
    
    static func encodeString(_ string: String) -> Data? {
        if let hexData = string.hexData {
            return encodeData(hexData)
        }
        
        guard let data = string.data(using: String.Encoding.utf8) else {
            return nil
        }
        return encodeData(data)
    }
    
    static func encodeInt(_ int: Int) -> Data? {
        guard int >= 0 else {
            return nil
        }
        return encodeBigInt(BigInt(int))
    }
    
    static func encodeBigInt(_ bint: BigInt) -> Data? {
        guard bint >= 0 else {
            // TODO implement properly to support negatives if RLP supports.. twos complement reverse?
            return nil
        }
        return encodeBigUInt(BigUInt(bint))
    }
    
    static func encodeBigUInt(_ buint: BigUInt) -> Data? {
        let data = buint.serialize()
        
        let lastIndex = data.count - 1
        let firstIndex = data.firstIndex(where: {$0 != 0x00}) ?? lastIndex
        if lastIndex == -1 {
            return Data( [OFFSET_SHORT_STRING])
        }
        let subdata = data.subdata(in: firstIndex..<lastIndex+1)
        
        if subdata.count == 1 && subdata[0] == 0x00 {
            return Data( [OFFSET_SHORT_STRING])
        }
        
        return encodeData(data.subdata(in: firstIndex..<lastIndex+1))
    }
    
    static func encodeData(_ data: Data) -> Data {
        if data.count == 1 && data[0] <= 0x7f {
            return data // single byte, no header
        }
        
        var encoded = encodeHeader(size: UInt64(data.count), smallTag: OFFSET_SHORT_STRING, largeTag: OFFSET_LONG_STRING)
        encoded.append(data)
        return encoded
    }
    
    static func encodeArray(_ elements: [Any]) -> Data? {
        var encodedData = Data()
        for el in elements {
            guard let encoded = encode(el) else {
                return nil
            }
            encodedData.append(encoded)
            /*if let encoded = encode(el) {
                encodedData.append(encoded)
            } else if let emptyPlaceholder = encodeString("") {
                encodedData.append(emptyPlaceholder)
            }*/
            
        }
        
        var encoded = encodeHeader(size: UInt64(encodedData.count), smallTag: OFFSET_SHORT_LIST, largeTag: OFFSET_LONG_LIST)
        encoded.append(encodedData)
        return encoded
    }
    
    static func encodeHeader(size: UInt64, smallTag: UInt8, largeTag: UInt8) -> Data {
        if size < 56 {
            return Data([smallTag + UInt8(size)])
        }
        
        let sizeData = bigEndianBinary(size)
        var encoded = Data()
        encoded.append(largeTag + UInt8(sizeData.count))
        encoded.append(contentsOf: sizeData)
        return encoded
    }
    
    // in Ethereum integers must be represented in big endian binary form with no leading zeroes
    static func bigEndianBinary(_ i: UInt64) -> Data {
        var value = i
        var bytes = withUnsafeBytes(of: &value) { Array($0) }
        for (index, byte) in bytes.enumerated().reversed() {
            if index != 0 && byte == 0x00 {
                bytes.remove(at: index)
            } else {
                break
            }
        }
        return Data( bytes.reversed())
    }
    
    // MARK: - Decode
    public static func decode(_ encodedInput: Data) -> Any {
        return decode(encodedInput.bytes)
    }
    
    public static func decode(_ hexEncodedInput: [UInt8]) -> Any {
        var rlpList: [Any] = []
        traverse(hexEncodedInput, 0, hexEncodedInput.count, &rlpList)
        if rlpList.count == 1 {
            return rlpList[0]
        }
        return rlpList
    }
    
    public static func traverse(_ data: [UInt8], _ startPos: Int, _ endPos: Int, _ rlpList : inout [Any]) {
        if data.isEmpty {
            return
        }
        var startPos = startPos
        while startPos < endPos {
            let prefix = data[startPos] & 0xff
            
            if prefix < OFFSET_SHORT_STRING {
                rlpList.append(String(prefix).cleanHexPrefix)
                startPos += 1
            } else if prefix < OFFSET_LONG_STRING {
                let strLen = (prefix - OFFSET_SHORT_STRING).int ?? 1
                let start = (startPos + 1)
                rlpList.append(data[start..<(start+strLen)].string)
                startPos += 1 + strLen
            } else if prefix < OFFSET_SHORT_LIST {
                let lenOfStrLen = (prefix - OFFSET_LONG_STRING).int ?? 1
                var start = (startPos + 1)
                let dda = Array(data[start..<(start+lenOfStrLen)])
                let strLen = bigEndian(dda)
                start = (startPos + lenOfStrLen + 1)
                rlpList.append(data[start..<(start+strLen)].string)
                startPos += 1 + strLen + lenOfStrLen
            } else if prefix < OFFSET_LONG_LIST {
                let listLen = (prefix - OFFSET_SHORT_LIST).int ?? 1
                var rlpListSub: [Any] = []
                traverse(data, startPos + 1, startPos + listLen + 1, &rlpListSub)
                rlpList.append(rlpListSub)
                startPos += 1 + listLen
            } else {
                let lenOfListLen = (prefix - OFFSET_LONG_LIST).int ?? 1
                let start = (startPos + 1)
                let dda = Array(data[start..<(start+lenOfListLen)])
                let listLen = bigEndian(dda)
                var rlpListSub: [Any] = []
                traverse(data, startPos + lenOfListLen + 1, startPos + lenOfListLen  + listLen + 1, &rlpListSub)
                rlpList.append(rlpListSub)
                startPos += 1 + listLen + lenOfListLen
            }
        }
    }

    private static func bigEndian(_ data: [UInt8]) -> Int {
        var val = 0
        data.forEach {
            val <<= 8
            val += $0.int ?? 0
        }
        return val
    }
}
