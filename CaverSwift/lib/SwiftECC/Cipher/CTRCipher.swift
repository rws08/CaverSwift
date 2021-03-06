//
//  CTRCipher.swift
//  AEC
//
//  Created by Leif Ibsen on 04/02/2020.
//

class CTRCipher: Cipher {

    var xor: [UInt8]

    init(_ key: [UInt8], _ iv: [UInt8], _ macKey: [UInt8]) {
        self.xor = iv
        super.init(key, macKey)
    }
    
    override func processBuffer(_ input: inout [UInt8], _ index: inout Int, _ remaining: inout Int) throws {
        var work = self.xor
        self.aes.encrypt(&work)
        let n = min(AES.blockSize, remaining)
        for i in 0 ..< n {
            input[index + i] ^= work[i]
        }
        // Counter += 1
        for i in (0 ..< self.xor.count).reversed() {
            if self.xor[i] == 0xff {
                self.xor[i] = 0
            } else {
                self.xor[i] += 1
                break
            }
        }
        index += AES.blockSize
        remaining -= AES.blockSize
    }

}
