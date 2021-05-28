//
//  RPC.swift
//  CaverSwift
//
//  Created by won on 2021/05/10.
//

import Foundation

public class RPC {
    private var session: URLSession
    private var url: URL
    
    public var klay: Klay
    
    public init(_ web3jService: URLSession, _ url: URL) {
        self.session = web3jService
        self.url = url
        klay = Klay(web3jService, url)
    }
    
    deinit {
        self.session.invalidateAndCancel()
    }
}
