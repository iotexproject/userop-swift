//
//  Client.swift
//  
//
//  Created by liugang zhang on 2023/8/24.
//

import Foundation
import BigInt
import Web3Core
import web3swift

public struct SendUserOperationResponse {
    let userOpHash: String
    let wait: () async throws -> EventLog?
}

public protocol IClient {
    func buildUserOperation(builder: IUserOperationBuilder) async throws -> UserOperation

    func sendUserOperation(builder: IUserOperationBuilder,
                           dryRun: Bool?,
                           onBuild: ((UserOperation) -> Void)?) async throws -> SendUserOperationResponse
}

extension IClient {
    func sendUserOperation(builder: IUserOperationBuilder)  async throws -> SendUserOperationResponse {
        try await sendUserOperation(builder: builder, dryRun: false, onBuild: nil)
    }
}

public class Client: IClient {
    private let provider: JsonRpcProvider
    private let web3: Web3

    public let entryPoint: EntryPoint

    var chainId: BigUInt {
        web3.provider.network!.chainID
    }

    init(rpcUrl: URL,
         overrideBundlerRpc: URL? = nil,
         entryPoint: EthereumAddress = EthereumAddress(ERC4337.entryPoint)!) async throws {
        self.provider = try await BundlerJsonRpcProvider(url: rpcUrl, bundlerRpc: overrideBundlerRpc)
        self.web3 = Web3(provider: provider)
        self.entryPoint = EntryPoint(web3: web3, address: entryPoint)
    }

    public func buildUserOperation(builder: IUserOperationBuilder) async throws -> UserOperation {
        try await builder.build(entryPoint: entryPoint.address, chainId: chainId)
    }

    public func sendUserOperation(builder: IUserOperationBuilder, dryRun: Bool?, onBuild: ((UserOperation) -> Void)?) async throws -> SendUserOperationResponse {
        let dry = dryRun ?? false
        let op = try await buildUserOperation(builder: builder)
        onBuild?(op)

        let userOphash: String
        if dry {
            userOphash = UserOperationMiddlewareContext(op: op, entryPoint: entryPoint.address, chainId: chainId).getUserOpHash()
        } else {
            userOphash = try await provider.send("eth_sendUserOperation", parameter: [op, entryPoint.address]).result
        }
        builder.reset()

        let wait = { [self] () async throws -> EventLog? in
            if dry {
                return nil
            }

            let end = Date.now.addingTimeInterval(300)
            while Date.now.distance(to: end) > 0 {
                let events = try await entryPoint.queryUserOperationEvent(userOpHash: userOphash)
                if (!events.isEmpty) {
                    return events[0]
                }
            }

            return nil
        }

        return .init(userOpHash: userOphash, wait: wait)
    }
}
