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
    
    convenience init(_ url: String = DEFAULT_URL) {
        self.init(URLSession(configuration: URLSession.shared.configuration), URL.init(string: url)!)
    }
    
    init(_ urlSession: URLSession, _ url: URL) {
        rpc = RPC(urlSession, url)
        wallet = KeyringContainer()
    }
}
