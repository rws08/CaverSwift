//
//  KlayPeerCount.swift
//  CaverSwift
//
//  Created by won on 2021/07/30.
//

import Foundation

open class KlayPeerCount: Codable {
    public var total = BigInt(0)
    public var cn = BigInt(0)
    public var pn = BigInt(0)
    public var en = BigInt(0)
    
    private enum CodingKeys: String, CodingKey {
        case total, cn, pn, en
    }
    
    open func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(total, forKey: .total)
        try container.encode(cn, forKey: .cn)
        try container.encode(pn, forKey: .pn)
        try container.encode(en, forKey: .en)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.total = (try? container.decode(BigInt.self, forKey: .total)) ?? BigInt(0)
        self.cn = (try? container.decode(BigInt.self, forKey: .cn)) ?? BigInt(0)
        self.pn = (try? container.decode(BigInt.self, forKey: .pn)) ?? BigInt(0)
        self.en = (try? container.decode(BigInt.self, forKey: .en)) ?? BigInt(0)
    }
}
