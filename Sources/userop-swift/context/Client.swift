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
    let entryPoint: IEntryPoint

    func wait() async throws -> EventLog? {
        let end = Date.now.addingTimeInterval(300)
        while Date.now.distance(to: end) > 0 {
            let events = try await entryPoint.queryUserOperationEvent(userOpHash: userOpHash)
            if (!events.isEmpty) {
                return events[0]
            }
        }

        return nil
    }
}

public protocol IClient {
    func buildUserOperation(builder: IUserOperationBuilder) async throws -> UserOperation

    func sendUserOperation(builder: IUserOperationBuilder, onBuild: ((UserOperation) -> Void)?) async throws -> SendUserOperationResponse
}

extension IClient {
    func sendUserOperation(builder: IUserOperationBuilder)  async throws -> SendUserOperationResponse {
        try await sendUserOperation(builder: builder, onBuild: nil)
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

    public func sendUserOperation(builder: IUserOperationBuilder, onBuild: ((UserOperation) -> Void)?) async throws -> SendUserOperationResponse {
        let op = try await buildUserOperation(builder: builder)
        onBuild?(op)

        let userOphash: String  = try await provider.send("eth_sendUserOperation", parameter: [op, entryPoint.address]).result
        builder.reset()

        return .init(userOpHash: userOphash, entryPoint: entryPoint)
    }
}
