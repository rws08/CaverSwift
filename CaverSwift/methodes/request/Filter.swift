//
//  Filter.swift
//  CaverSwift
//
//  Created by won on 2021/07/21.
//

import Foundation
public protocol FilterTopic {
    associatedtype element
    func getValue() -> element?
}

public class Filter: Codable {
    var topics: [SingleTopic] = []
    
    enum CodingKeys: String, CodingKey {
        case topics
    }
    
    init() {}
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if !self.topics.isEmpty {
            let topics = self.topics.map {
                $0.getValue()
            }
            try container.encode(topics, forKey: .topics)
        }                
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let topics = try? container.decode([SingleTopic].self, forKey: .topics) {
            self.topics = topics
        }
    }
        
    public func addSingleTopic(_ topic: String) -> Filter {
        topics.append(SingleTopic(topic))
        return self
    }
    
    public func addNullTopic() -> Filter{
        topics.append(SingleTopic())
        return self
    }
        
    public func getThis() -> Filter {
        return self
    }
    
    
    public struct SingleTopic: FilterTopic, Codable {
        private var topic: String?
        
        init(_ topic: String? = nil) {
            self.topic = topic
        }
        
        public func getValue() -> String? {
            return topic
        }
    }
    
    public struct ListTopic: FilterTopic, Codable {
        private var topics: [SingleTopic]?
                
        init(_ optionalTopics: String?...) {
            self.topics = optionalTopics.map({
                SingleTopic($0)
            })
        }
        
        init(_ optionalTopics: [String?]) {
            self.topics = optionalTopics.map({
                SingleTopic($0)
            })
        }
        
        public func getValue() -> [SingleTopic]? {
            return topics
        }
    }
}
