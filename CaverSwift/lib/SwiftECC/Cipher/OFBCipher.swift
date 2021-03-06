//
//  OFBCipher.swift
//  Test
//
//  Created by Leif Ibsen on 03/02/2020.
//

class OFBCipher: Cipher {

    var xor: [UInt8]

    init(_ key: [UInt8], _ iv: [UInt8], _ macKey: [UInt8]) {
        self.xor = iv
        super.init(key, macKey)
    }
    
    override func processBuffer(_ input: inout [UInt8], _ index: inout Int, _ remaining: inout Int) throws {
        self.aes.encrypt(&self.xor)
        let n = min(AES.blockSize, remaining)
        for i in 0 ..< n {
            input[index + i] ^= self.xor[i]
        }
        index += AES.blockSize
        remaining -= AES.blockSize
    }

}
