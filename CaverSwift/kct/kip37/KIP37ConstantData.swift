//
//  KIP37ConstantData.swift
//  CaverSwift
//
//  Created by won on 2021/07/27.
//

import Foundation
import GenericJSON

open class KIP37ConstantData {
    static var BINARY = ""
    static var ABI = ""
    
    init() {
        if !KIP37ConstantData.BINARY.isEmpty {
            return
        }
        
        do {
            if let file  = Bundle.module.url(forResource: "KIP37ConstantData", withExtension: "json"){
                let data  = try Data(contentsOf: file)
                let json = try JSONDecoder().decode(JSON.self, from:data)
                KIP37ConstantData.BINARY = json["BINARY"]?.stringValue ?? ""
                let jsonObj = try JSONEncoder().encode(json["ABI"])
                KIP37ConstantData.ABI = String(data: jsonObj, encoding: .utf8)!
            }else{
                print("no file")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

