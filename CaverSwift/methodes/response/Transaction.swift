//
//  Transaction.swift
//  CaverSwift
//
//  Created by won on 2021/07/29.
//

import Foundation

open class Transaction: Codable {
    public var blockHash: String?
    public var blockNumber: String?
    public var codeFormat: String?
    public var feePayer: String?
    public var feePayerSignatures: [SignatureData]?
    public var feeRatio: String?
    public var from: String?
    public var gas: String?
    public var gasPrice: String?
    public var hash: String?
    public var humanReadable: Bool?
    public var key: String?
    public var input: String?
    public var nonce: String?
    public var senderTxHash: String?
    public var signatures: [SignatureData]?
    public var to: String?
    public var transactionIndex: String?
    public var type: String?
    public var typeInt: String?
    public var value: String?
    
    init() {
    }
    
    internal init(blockHash: String? = nil, blockNumber: String? = nil, codeFormat: String? = nil, feePayer: String? = nil, feePayerSignatures: [SignatureData]? = nil, feeRatio: String? = nil, from: String? = nil, gas: String? = nil, gasPrice: String? = nil, hash: String? = nil, humanReadable: Bool? = nil, key: String? = nil, input: String? = nil, nonce: String? = nil, senderTxHash: String? = nil, signatures: [SignatureData]? = nil, to: String? = nil, transactionIndex: String? = nil, type: String? = nil, typeInt: String? = nil, value: String? = nil) {
        self.blockHash = blockHash
        self.blockNumber = blockNumber
        self.codeFormat = codeFormat
        self.feePayer = feePayer
        self.feePayerSignatures = feePayerSignatures
        self.feeRatio = feeRatio
        self.from = from
        self.gas = gas
        self.gasPrice = gasPrice
        self.hash = hash
        self.humanReadable = humanReadable
        self.key = key
        self.input = input
        self.nonce = nonce
        self.senderTxHash = senderTxHash
        self.signatures = signatures
        self.to = to
        self.transactionIndex = transactionIndex
        self.type = type
        self.typeInt = typeInt
        self.value = value
    }
    
    enum CodingKeys: String, CodingKey {
        case blockHash, blockNumber, codeFormat, feePayer, feePayerSignatures,
        feeRatio, from, gas, gasPrice, hash, humanReadable,
        key, input,
        nonce, senderTxHash, signatures,
        to, transactionIndex, type, typeInt, value
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.blockHash = try? container.decode(String.self, forKey: .blockHash)
        self.blockNumber = try? container.decode(String.self, forKey: .blockNumber)
        self.codeFormat = try? container.decode(String.self, forKey: .codeFormat)
        self.feePayer = try? container.decode(String.self, forKey: .feePayer)
        self.feePayerSignatures = try? container.decode([SignatureData].self, forKey: .feePayerSignatures)
        self.feeRatio = try? container.decode(String.self, forKey: .feeRatio)
        self.from = try? container.decode(String.self, forKey: .from)
        self.gas = try? container.decode(String.self, forKey: .gas)
        self.gasPrice = try? container.decode(String.self, forKey: .gasPrice)
        self.hash = try? container.decode(String.self, forKey: .hash)
        self.humanReadable = try? container.decode(Bool.self, forKey: .humanReadable)
        self.key = try? container.decode(String.self, forKey: .key)
        self.input = try? container.decode(String.self, forKey: .input)
        self.nonce = try? container.decode(String.self, forKey: .nonce)
        self.senderTxHash = try? container.decode(String.self, forKey: .senderTxHash)
        self.signatures = try? container.decode([SignatureData].self, forKey: .signatures)
        self.to = try? container.decode(String.self, forKey: .to)
        self.transactionIndex = try? container.decode(String.self, forKey: .transactionIndex)
        self.type = try? container.decode(String.self, forKey: .type)
        self.typeInt = try? container.decode(String.self, forKey: .typeInt)
        self.value = try? container.decode(String.self, forKey: .value)
    }
}
