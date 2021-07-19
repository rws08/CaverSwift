//
//  ContractIOType.swift
//  CaverSwift
//
//  Created by won on 2021/05/10.
//

import Foundation

open class ContractIOType: Codable {
    var name: String
    var type: String
    var indexed: Bool
    
    var components: [ContractIOType] = []
    
    enum CodingKeys: CodingKey {
        case type, name, indexed, components
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(String.self, forKey: .type)
        self.name = try container.decode(String.self, forKey: .name)
        self.indexed = (try? container.decode(Bool.self, forKey: .indexed)) ?? false
        self.components = (try? container.decode([ContractIOType].self, forKey: .components)) ?? []
    }
    
    public init(name: String, type: String, indexed: Bool) {
        self.name = name
        self.type = type
        self.indexed = indexed
    }
    
    private let TUPLE = "tuple"
    public func getTypeAsString() -> String {
        if type.contains(TUPLE) {
            let typeString = getComponentAsString()
            return type.replacingOccurrences(of: TUPLE, with: TUPLE + typeString)
        }
        
        return type
    }
    
    private func getComponentAsString() -> String {
        guard !components.isEmpty else { return "" }
        
        var retString = "("
        components.enumerated().forEach {
            retString += $0.element.getTypeAsString()
            if $0.offset < components.count - 1 {
                retString += ","
            }
        }
        retString += ")"
        
        return retString
    }
}
