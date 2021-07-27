//
//  KIP7ConstantData.swift
//  CaverSwift
//
//  Created by won on 2021/07/26.
//

import Foundation
import GenericJSON

open class KIP7ConstantData {
    static var BINARY = ""
    static var ABI = ""
    
    init() {
        if !KIP7ConstantData.BINARY.isEmpty {
            return
        }
        
        do {
            if let file  = Bundle(for: type(of: self)).url(forResource: "KIP7ConstantData", withExtension: "json"){
                let data  = try Data(contentsOf: file)
                let json = try JSONDecoder().decode(JSON.self, from:data)
                KIP7ConstantData.BINARY = json["BINARY"]?.stringValue ?? ""
                let jsonObj = try JSONEncoder().encode(json["jsonObj"])
                KIP7ConstantData.ABI = String(data: jsonObj, encoding: .utf8)!
            }else{
                print("no file")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
