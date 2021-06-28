//
//  HMAC.swift
//  Test
//
//  Created by Leif Ibsen on 02/02/2020.
//

class HMac {
    
    static let OPAD = UInt8(0x5c)
    static let IPAD = UInt8(0x36)
    
    let md: MessageDigest
    let blockSize: Int
    var iKeyPad: [UInt8] = []
    var oKeyPad: [UInt8] = []
    
    init(_ md: MessageDigest, _ key: [UInt8]) {
        self.md = md
        self.blockSize = self.md.buffer.count
        self.initialize(key)
    }
    
    func initialize(_ key: [UInt8]) {
        var macKey = [UInt8](repeating: 0, count: self.blockSize)
        if key.count > self.blockSize {
            self.md.update(key)
            macKey = self.md.digest()
        } else {
            for i in 0 ..< key.count {
                macKey[i] = key[i]
            }
        }
        self.iKeyPad = [UInt8](repeating: 0, count: self.blockSize)
        self.oKeyPad = [UInt8](repeating: 0, count: self.blockSize)
        for i in 0 ..< self.blockSize {
            self.iKeyPad[i] = macKey[i] ^ HMac.IPAD
            self.oKeyPad[i] = macKey[i] ^ HMac.OPAD
        }
        self.reset()
    }
    
    func reset() {
        self.md.reset()
        self.md.update(self.iKeyPad)
    }

    func update(_ input: [UInt8]) {
        self.md.update(input)
    }

    func doFinal() -> [UInt8] {
        let b = self.md.digest()
        self.md.update(oKeyPad)
        self.md.update(b)
        return self.md.digest()
    }
    
    func doFinal(_ input: [UInt8]) -> [UInt8] {
        self.update(input)
        return doFinal()
    }

}
