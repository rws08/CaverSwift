//
//  EthereumKeyStorage.swift
//  web3swift
//
//  Created by Matt Marshall on 06/03/2018.
//  Copyright © 2018 Argent Labs Limited. All rights reserved.
//

import Foundation

public protocol EthereumKeyStorageProtocol {
    func storePrivateKey(key: Data) throws -> Void
    func loadPrivateKey() throws -> Data
}

public enum EthereumKeyStorageError: Error {
    case notFound
    case failedToSave
    case failedToLoad
}

public class EthereumKeyLocalStorage: EthereumKeyStorageProtocol {
    public init() {}
    
    private var localPath: URL? {
        if let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            return url.appendingPathComponent("EthereumKey")
        }
        return nil
    }
    
    public func storePrivateKey(key: Data) throws -> Void {
        guard let localPath = self.localPath,
              let archiver = try? NSKeyedArchiver.archivedData(withRootObject: key, requiringSecureCoding: false),
              let _ = try? archiver.write(to: localPath) else {
            throw EthereumKeyStorageError.failedToSave
        }
    }
    
    public func loadPrivateKey() throws -> Data {
        guard let localPath = self.localPath else {
            throw EthereumKeyStorageError.failedToLoad
        }
        
        guard let data = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(Data(contentsOf: localPath)) as? Data else {
            throw EthereumKeyStorageError.failedToLoad
        }

        return data
    }
}
