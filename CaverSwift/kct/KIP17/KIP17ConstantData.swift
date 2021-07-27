//
//  KIP17ConstantData.swift
//  CaverSwift
//
//  Created by won on 2021/07/27.
//

import Foundation
import GenericJSON

open class KIP17ConstantData {
    static var BINARY = ""
    static var ABI = ""
    
    init() {
        if !KIP17ConstantData.BINARY.isEmpty {
            return
        }
        
        do {
            if let file  = Bundle(for: type(of: self)).url(forResource: "KIP17ConstantData", withExtension: "json"){
                let data  = try Data(contentsOf: file)
                let json = try JSONDecoder().decode(JSON.self, from:data)
                KIP17ConstantData.BINARY = json["BINARY"]?.stringValue ?? ""
                let jsonObj = try JSONEncoder().encode(json["ABI"])
                KIP17ConstantData.ABI = String(data: jsonObj, encoding: .utf8)!
            }else{
                print("no file")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

