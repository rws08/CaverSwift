//
//  CBCCipher.swift
//  Test
//
//  Created by Leif Ibsen on 03/02/2020.
//

class CBCCipher: Cipher {

    var xor: [UInt8]

    init(_ key: [UInt8], _ iv: [UInt8], _ macKey: [UInt8]) {
        self.xor = iv
        super.init(key, macKey)
    }
    
    override func processBuffer(_ input: inout [UInt8], _ index: inout Int, _ remaining: inout Int) throws {
        var buffer = [UInt8](repeating: 0, count: AES.blockSize)
        if self.encrypt {
            if remaining < AES.blockSize {
                let padByte = UInt8(AES.blockSize - remaining)
                input.append(contentsOf: [UInt8](repeating: padByte, count: AES.blockSize - remaining))
            }
            buffer[0 ..< AES.blockSize] = input[index ..< index + AES.blockSize]
            for i in 0 ..< buffer.count {
                buffer[i] ^= self.xor[i]
            }
            self.aes.encrypt(&buffer)
            self.xor = buffer
            input[index ..< index + AES.blockSize] = buffer[0 ..< AES.blockSize]
            index += AES.blockSize
            remaining -= AES.blockSize
        } else {
            if remaining < AES.blockSize {
                throw ECException.padding
            }
            buffer[0 ..< AES.blockSize] = input[index ..< index + AES.blockSize]
            let work = buffer
            self.aes.decrypt(&buffer)
            for i in 0 ..< buffer.count {
                input[index + i] = buffer[i] ^ self.xor[i]
            }
            self.xor = work
            index += AES.blockSize
            remaining -= AES.blockSize
            if remaining <= 0 {
                let padCount = Int(input[index - 1])
                if padCount > AES.blockSize {
                    throw ECException.padding
                }
                for i in 0 ..< padCount {
                    if input[index - 1 - i] != padCount {
                        throw ECException.padding
                    }
                }
                remaining -= padCount
            }
        }
    }

    override func alignResult(_ input: inout [UInt8], _ remaining: Int) {
        input.removeLast(-remaining)
    }

}
