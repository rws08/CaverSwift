//
//  IAccountType.swift
//  CaverSwift
//
//  Created by won on 2021/07/30.
//

import Foundation

open class IAccountType: Codable {
    public var accType: AccType = .EOA
    
    enum CodingKeys: String, CodingKey {
        case accType
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.accType = AccType(rawValue: (try? container.decode(Int.self, forKey: .accType)) ?? 0) ?? .EOA
    }
    
    public init() {
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.accType.rawValue, forKey: .accType)
    }
    
    public enum AccType: Int {
        case EOA = 0x1
        case SCA = 0x2
                
        var string: String {
            get{ String(rawValue) }
        }
        
        var accType: Int {
            get { rawValue }
        }
    }
}
