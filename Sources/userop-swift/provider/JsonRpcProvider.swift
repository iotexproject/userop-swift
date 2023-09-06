//
//  JsonRpcProvider.swift
//  
//
//  Created by liugang zhang on 2023/8/22.
//

import Foundation
import Web3Core
import BigInt

public class JsonRpcProvider: Web3Provider {
    public let url: URL
    public var network: Networks?
    public var policies: Policies = .auto
    public var attachedKeystoreManager: KeystoreManager? = nil
    public var session: URLSession = {() -> URLSession in
        let config = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: config)
        return urlSession
    }()

    public init(url: URL, network net: Networks? = nil, ignoreNet: Bool = false) async throws {
        guard url.scheme == "http" || url.scheme == "https" else {
            throw Web3Error.inputError(desc: "Web3HttpProvider endpoint must have scheme http or https. Given scheme \(url.scheme ?? "none"). \(url.absoluteString)")
        }

        self.url = url
        if let net = net {
            network = net
        } else if !ignoreNet {
            /// chain id could be a hex string or an int value.
            let response: String = try await APIRequest.send(APIRequest.getNetwork.call, parameter: [], with: self).result
            let result: UInt
            if response.hasHexPrefix() {
                result = UInt(BigUInt(response, radix: 16) ?? Networks.Mainnet.chainID)
            } else {
                result = UInt(response) ?? UInt(Networks.Mainnet.chainID)
            }
            self.network = Networks.fromInt(result)
        }
    }

    public func send<Result>(_ method: String, parameter: [Encodable]) async throws -> APIResponse<Result> {
        return try await APIRequest.send(method, parameter: parameter, with: self)
    }
}
