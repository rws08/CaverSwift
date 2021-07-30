//
//  Net.swift
//  CaverSwift
//
//  Created by won on 2021/07/30.
//

import Foundation
import BigInt
import GenericJSON

public class Net {
    var rpc: RPC
    var url: URL
    
    public init(_ rpc: RPC, _ url: URL) {
        self.rpc = rpc
        self.url = url
    }
    
    public func getNetworkID() -> (CaverError?, result: Bytes?) {
        let(error, response) = RPC.Request("net_networkID", Array<String>(), rpc, Bytes.self)!.send()
        return parseReturn(error, response)
    }
    
    public func isListening() -> (CaverError?, result: Bool?) {
        let(error, response) = RPC.Request("net_listening", Array<String>(), rpc, Bool.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getPeerCount() -> (CaverError?, result: Quantity?) {
        let(error, response) = RPC.Request("net_peerCount", Array<String>(), rpc, Quantity.self)!.send()
        return parseReturn(error, response)
    }
    
    public func getPeerCountByType() -> (CaverError?, result: KlayPeerCount?) {
        let(error, response) = RPC.Request("net_peerCountByType", Array<String>(), rpc, KlayPeerCount.self)!.send()
        return parseReturn(error, response)
    }
    
    private func parseReturn<T: Any>(_ error: JSONRPCError?, _ response: Any?) -> (CaverError?, result: T?) {
        if let resDataString = response as? T {
            return (nil, resDataString)
        } else if let error = error {
            switch error {
            case .executionError(let result):
                return (CaverError.JSONRPCError(result.error.message), nil)
            default:
                return (CaverError.JSONRPCError(error.localizedDescription), nil)
            }
        } else {
            return (CaverError.unexpectedReturnValue, nil)
        }
    }
}
