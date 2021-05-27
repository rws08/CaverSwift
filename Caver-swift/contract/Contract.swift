//
//  Contract.swift
//  Caver-swift
//
//  Created by won on 2021/05/10.
//

import Foundation
import SwiftyJSON

class Contract {
    var caver: Caver
    var abi: String
    var contractAddress: String? = nil
    var methods: [String:ContractMethod] = [:]
    var events: [String:ContractEvent] = [:]
    var constructor: ContractMethod?
    var defaultSendOptions: SendOptions?
    var wallet: IWallet?
    
    init(_ caver: Caver, _ abi: String, _ contractAddress: String? = nil) throws {
        self.abi = abi
        self.caver = caver
        self.contractAddress = contractAddress
        
        try setAbi(abi)
        setCaver(caver)
        setContractAddress(contractAddress)
        setDefaultSendOptions(SendOptions())
        setWallet(caver.wallet)
    }
    
    func setCaver(_ caver: Caver) {
        self.caver = caver
        methods.values.forEach {
            $0.caver = caver
        }
    }
    
    func setAbi(_ abi: String) throws {
        self.abi = abi
        try initAbi()
    }
    
    func setContractAddress(_ contractAddress: String?) {
        self.contractAddress = contractAddress
        methods.values.forEach {
            $0.contractAddress = contractAddress ?? ""
        }
    }
    
    func setDefaultSendOptions(_ defaultSendOptions: SendOptions) {
        self.defaultSendOptions = defaultSendOptions
        methods.values.forEach {
            $0.defaultSendOptions = defaultSendOptions
        }
    }
    
    func setWallet(_ wallet: IWallet) {
        self.wallet = wallet
        methods.values.forEach {
            $0.wallet = wallet
        }
    }
    
    func getMethod(_ methodName: String) throws -> ContractMethod {
        guard let method = methods[methodName] else {
            throw CaverError.NoSuchMethodException("\(methodName) method is not exist.")
        }
        return method
    }
    
    func getEvent(_ eventName: String) throws -> ContractEvent {
        guard let event = events[eventName] else {
            throw CaverError.NoSuchMethodException("\(eventName) method is not exist.")
        }
        return event
    }
    
    private func initAbi() throws {
        methods.removeAll()
        let data = abi.data(using: .utf8, allowLossyConversion: false)!
        let json = try JSON(data: data)
        try json.array?.forEach {
            guard let type = $0["type"].string else { return }
            
            if type == "function" {
                let newMethod = try JSONDecoder().decode(ContractMethod.self, from: $0.rawData())
                newMethod.signature = try ABI.encodeFunctionSignature(newMethod)
                if let existedMethod = self.methods[newMethod.name] {
                    let isWarning = existedMethod.nextContractMethods.contains {
                        return $0.inputs.count == newMethod.inputs.count
                    }
                    if existedMethod.inputs.count == newMethod.inputs.count || isWarning {
                        WARNING(message: "An overloaded function with the same number of parameters may not be executed normally. Please use *withSolidityWrapper methods in ContractMethod class.")
                    }
                    
                    existedMethod.nextContractMethods.append(newMethod)
                } else {
                    self.methods[newMethod.name] = newMethod
                }
            } else if type == "event" {
                let event = try JSONDecoder().decode(ContractEvent.self, from:$0.rawData())
                event.signature = try ABI.encodeEventSignature(event)
                events[event.name] = event
            } else if type == "constructor" {
                let method = try JSONDecoder().decode(ContractMethod.self, from: $0.rawData())
                self.constructor = method
            }
        }
    }
}
