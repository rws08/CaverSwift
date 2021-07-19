//
//  EventFilterOptions.swift
//  CaverSwift
//
//  Created by won on 2021/07/19.
//

import Foundation

open class EventFilterOptions {
    var filterOptions: [IndexedParameter] = []
    var topics: [String] = []
    
    init(_ filterOptions: [IndexedParameter], _ topics: [String]) {
        self.filterOptions = filterOptions
        self.topics = topics
    }
    
    static public func convertsTopic(_ event: ContractEvent, _ options: EventFilterOptions) throws -> [Any] {
        let filterOptions = options.filterOptions
        let indexed = event.inputs.filter {
            $0.indexed
        }.count
        
        var topics: [Any] = Array.init(repeating: (Any).self, count: indexed + 1)
        topics[0] = try ABI.encodeEventSignature(event)
        try filterOptions.forEach { indexedParameter in
            guard let (index, contractIOType) = try event.inputs.enumerated().first(where: {
                if $0.element.name == indexedParameter.indexedParamName {
                    if !$0.element.indexed {
                        throw CaverError.IllegalArgumentException("Non indexed event parameter : \(indexedParameter.indexedParamName)")
                    }
                    return true
                }
                return false
            })
            else {
                throw CaverError.IllegalArgumentException("Non indexed event parameter : \(indexedParameter.indexedParamName)")
            }
            
            let topicValue = try indexedParameter.makeTopic(contractIOType.getTypeAsString())
            if topicValue.count == 1 {
                topics[index + 1] = topicValue[0]
            } else {
                topics[index + 1] = topicValue
            }
        }
        return topics
    }
    
    
    public class IndexedParameter {
        var indexedParamName: String
        var filterValue: [Any] = []
        
        init(_ indexedParamName: String, _ filterValue: [Any]) {
            self.indexedParamName = indexedParamName
            self.filterValue = filterValue
        }
        
        public func makeTopic(_ solType: String) throws -> [String] {
            var topicValue: [String] = []
            
            try self.filterValue.forEach {
                if let filter = $0 as? [Any] {
                    try filter.forEach {
                        let encoded = try ABI.encodeParameter(solType, $0)
                        topicValue.append(encoded.addHexPrefix)
                    }
                } else {
                    let encoded = try ABI.encodeParameter(solType, $0)
                    topicValue.append(encoded.addHexPrefix)
                }
            }
            
            return topicValue
        }
    }
}
