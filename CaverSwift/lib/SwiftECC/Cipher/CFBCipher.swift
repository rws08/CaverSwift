//
//  CFBCipher.swift
//  Test
//
//  Created by Leif Ibsen on 03/02/2020.
//

class CFBCipher: Cipher {

    var xor: [UInt8]

    init(_ key: [UInt8], _ iv: [UInt8], _ macKey: [UInt8]) {
        self.xor = iv
        super.init(key, macKey)
    }
    
    override func processBuffer(_ input: inout [UInt8], _ index: inout Int, _ remaining: inout Int) throws {
        self.aes.encrypt(&self.xor)
        let n = min(AES.blockSize, remaining)
        if self.encrypt {
            for i in 0 ..< n {
                input[index + i] ^= self.xor[i]
                self.xor[i] = input[index + i]
            }
        } else {
            for i in 0 ..< n {
                let b = input[index + i]
                input[index + i] ^= self.xor[i]
                self.xor[i] = b
            }
        }
        index += AES.blockSize
        remaining -= AES.blockSize
    }

}
