//
//  KIP13ConstantData.swift
//  CaverSwift
//
//  Created by won on 2021/07/27.
//

import Foundation
import GenericJSON

open class KIP13ConstantData {
    static var ABI = ""
    
    init() {
        if !KIP13ConstantData.ABI.isEmpty {
            return
        }
        
        do {
            if let file  = Bundle.module.url(forResource: "KIP13ConstantData", withExtension: "json"){
                let data  = try Data(contentsOf: file)
                let json = try JSONDecoder().decode(JSON.self, from:data)
                let jsonObj = try JSONEncoder().encode(json["ABI"])
                KIP13ConstantData.ABI = String(data: jsonObj, encoding: .utf8)!
            }else{
                print("no file")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
