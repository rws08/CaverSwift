//
//  SignTransaction.swift
//  CaverSwift
//
//  Created by won on 2021/07/29.
//

import Foundation

public class SignTransaction: Decodable {
    public var raw: String = ""
    public var tx: Transaction?
    
    init() {
    }
    
    internal init(raw: String = "", tx: Transaction) {
        self.raw = raw
        self.tx = tx
    }
    
    enum CodingKeys: String, CodingKey {
        case raw, tx
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.raw = (try? container.decode(String.self, forKey: .raw)) ?? ""
        self.tx = try? container.decode(Transaction.self, forKey: .tx)
    }
}
