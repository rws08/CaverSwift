//
//  Caver.swift
//  CaverSwift
//
//  Created by won on 2021/04/20.
//

import Foundation

public class Caver {
    public static var DEFAULT_URL = "http://localhost:8551";
    
    var rpc: RPC
    
    var wallet: KeyringContainer
    
    public init(_ url: String = DEFAULT_URL) {
        rpc = RPC(URLSession(configuration: URLSession.shared.configuration), URL.init(string: url)!)
        wallet = KeyringContainer()
    }
    
    public init(_ urlSession: URLSession, _ url: URL) {
        rpc = RPC(urlSession, url)
        wallet = KeyringContainer()
    }
}
