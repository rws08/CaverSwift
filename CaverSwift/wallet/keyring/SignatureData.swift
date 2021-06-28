//
//  SignatureData.swift
//  CaverSwift
//
//  Created by won on 2021/06/25.
//

import Foundation

open class SignatureData {
    var v: String = ""
    var r: String = ""
    var s: String = ""
    
    init(_ v: String, _ r: String, _ s: String) {
        self.v = v
        self.r = r
        self.s = s
    }
}
