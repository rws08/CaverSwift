//
//  DefaultFunctionReturnDecoder.swift
//  CaverSwift
//
//  Created by won on 2021/07/22.
//

import Foundation

public class DefaultFunctionReturnDecoder: FunctionReturnDecoder{
    public func decodeFunctionResult(_ rawInput: String, _ outputParameters: [Type]) -> [Type] {
        let input = rawInput.cleanHexPrefix
        
        if input.isEmpty {
            return []
        } else {
            return build(input, outputParameters)
        }
    }
    
    public func build(_ input: String, _ outputParameters: [Type]) -> [Type] {
        var offset = 0
        
        outputParameters.forEach { type in
            let hexStringDataOffset = getDataOffset
        }
        
        return []
    }
    
    public func getDataOffset(_ input: String, _ offset: Int, _ typeReference: Type) -> Int {
//        let typeABI = typeReference.rawType
//        if typeABI.isDynamic {
//            return TypeDecoder.
//        }
        return 0
    }
}
