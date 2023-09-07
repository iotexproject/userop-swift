//
//  BundlerJsonRpcProvider.swift
//  
//
//  Created by liugang zhang on 2023/8/23.
//

import Foundation
import web3swift
import Web3Core

public class BundlerJsonRpcProvider: JsonRpcProvider {
    private var bundlerProvider: JsonRpcProvider? = nil
    private let bundlerMethods = [
        "eth_sendUserOperation",
        "eth_estimateUserOperationGas",
        "eth_getUserOperationByHash",
        "eth_getUserOperationReceipt",
        "eth_supportedEntryPoints"
    ]

    public init(url: URL, bundlerRpc: URL? = nil, network net: Networks? = nil, ignoreNet: Bool = false) async throws {
        try await super.init(url: url, network: net, ignoreNet: ignoreNet)
        if let bundlerRpc = bundlerRpc {
            self.bundlerProvider = try await JsonRpcProvider(url: bundlerRpc, network: network)
        }
    }

    public override func send<Result>(_ method: String, parameter: [Encodable]) async throws -> APIResponse<Result> {
        if bundlerMethods.contains(method) && bundlerProvider != nil {
            return try await bundlerProvider!.send(method, parameter: parameter)
        }
        return try await super.send(method, parameter: parameter)
    }
}
