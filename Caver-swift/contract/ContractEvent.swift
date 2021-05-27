//
//  ContractEvent.swift
//  Caver-swift
//
//  Created by won on 2021/05/11.
//

import Foundation

class ContractEvent: Codable {
    var type: String
    var name: String
    var inputs: [ContractIOType] = []
    var signature: String = ""
    
    enum CodingKeys: CodingKey {
        case type, name, inputs, signature
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(String.self, forKey: .type)
        self.name = try container.decode(String.self, forKey: .name)
        self.inputs = (try? container.decode([ContractIOType].self, forKey: .inputs)) ?? []
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(name, forKey: .name)
        try container.encode(inputs, forKey: .inputs)
        try container.encode(signature, forKey: .signature)
    }
    
    init(_ type: String, _ name: String,
         _ inputs: Array<ContractIOType>,
         _ signature: String) {
        self.type = type
        self.name = name
        self.inputs = inputs
        self.signature = signature
    }
}
