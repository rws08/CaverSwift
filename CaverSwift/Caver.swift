//
//  Caver.swift
//  CaverSwift
//
//  Created by won on 2021/04/20.
//

import Foundation

public class Caver {
    public static var DEFAULT_URL = "http://localhost:8551"
    public static var DEFAULT_URL_SOCKET = "ws://localhost:8552"
    
    public var rpc: RPC
    
    public var wallet: KeyringContainer
    
    public init(_ url: String = DEFAULT_URL) {
        rpc = RPC(WebService(url))
        wallet = KeyringContainer()
    }
    
    public init(_ service: WebService) {
        rpc = RPC(service)
        wallet = KeyringContainer()
    }
}
