//
//  ContractDeployParams.swift
//  CaverSwift
//
//  Created by won on 2021/07/19.
//

import Foundation

open class ContractDeployParams {
    var bytecode: String {
        willSet(v) {
            do {
                if v.isEmpty {
                    throw CaverError.RuntimeException("binary data is missing.")
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    var deployParams: [Any] = []
    
    init(_ bytecode: String) throws {
        self.bytecode = bytecode
    }
    
    init(_ bytecode: String, _ deployParams: Any...) throws {
        self.bytecode = bytecode
        setDeployParams(deployParams.flatCompactMapForVariadicParameters())
    }
    
    init(_ bytecode: String, _ deployParams: [Any]) throws {
        self.bytecode = bytecode
        setDeployParams(deployParams)
    }
    
    public func setDeployParams(_ deployParams: [Any]) {
        if !deployParams.isEmpty {
            self.deployParams.append(contentsOf: deployParams)
        }
    }
}
