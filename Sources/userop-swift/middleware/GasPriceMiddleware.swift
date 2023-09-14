//
//  GasPriceMiddleware.swift
//  
//
//  Created by liugang zhang on 2023/8/23.
//

import Foundation
import BigInt
import Web3Core

/// Middleware to get gas price from rpc server.
///
/// If rpc server did not provider `eth_maxPriorityFeePerGas` method, user `eth_getPrice` instead.
public struct GasPriceMiddleware: UserOperationMiddleware {
    private let provider: JsonRpcProvider

    public init(provider: JsonRpcProvider) {
        self.provider = provider
    }

    public func process(_ ctx: inout UserOperationMiddlewareContext) async throws {
        do {
            let (maxFeePerGas, maxPriorityFeePerGas) = try await eip1559GasPrice()
            ctx.op.maxFeePerGas = maxFeePerGas
            ctx.op.maxPriorityFeePerGas = maxPriorityFeePerGas
        } catch {
            let (maxFeePerGas, maxPriorityFeePerGas) = try await legacyGasPrice()
            ctx.op.maxFeePerGas = maxFeePerGas
            ctx.op.maxPriorityFeePerGas = maxPriorityFeePerGas
        }
    }

    private func eip1559GasPrice() async throws -> (BigUInt, BigUInt) {
        let fee: BigUInt = try await provider.send("eth_maxPriorityFeePerGas", parameter: []).result
        let block: Block = try await provider.send(.getBlockByNumber(.latest, false)).result

        let buffer = fee / 100 * 13
        let maxPriorityFeePerGas = fee + buffer
        let maxFeePerGas = block.baseFeePerGas != nil ? block.baseFeePerGas! * 2 + maxPriorityFeePerGas : maxPriorityFeePerGas
        return (maxFeePerGas, maxPriorityFeePerGas)
    }

    private func legacyGasPrice() async throws -> (BigUInt, BigUInt) {
        let gas: BigUInt = try await provider.send(.gasPrice).result
        return (gas, gas)
    }
}
