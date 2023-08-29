//
//  JsonRpcProvider.swift
//  
//
//  Created by liugang zhang on 2023/8/22.
//

import Foundation
import Web3Core

public class JsonRpcProvider: Web3Provider {
    public let url: URL
    public var network: Networks?
    public var policies: Policies = .auto
    public var attachedKeystoreManager: KeystoreManager?
    public var session: URLSession = {() -> URLSession in
        let config = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: config)
        return urlSession
    }()

    public init(url: URL, network: Networks? = nil) {
        self.url = url
        self.network = network
    }
}
