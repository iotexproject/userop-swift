//
//  GasPriceMiddleware.swift
//  
//
//  Created by liugang zhang on 2023/8/23.
//

import Foundation
import BigInt
import web3swift

public struct GasPriceMiddleware: UserOperationMiddleware {
    private let web3: Web3

    init(web3: Web3) {
        self.web3 = web3
    }

    public func process(_ ctx: inout UserOperationMiddlewareContext) async throws {
        do {
            let (maxFeePerGas, maxPriorityFeePerGas) = try await eip1559GasPrice()
            ctx.op.maxFeePerGas = maxFeePerGas
            ctx.op.maxPriorityFeePerGas = maxPriorityFeePerGas
            return
        } catch {
            let (maxFeePerGas, maxPriorityFeePerGas) = try await legacyGasPrice()
            ctx.op.maxFeePerGas = maxFeePerGas;
            ctx.op.maxPriorityFeePerGas = maxPriorityFeePerGas;
        }
    }

    private func eip1559GasPrice() async throws -> (BigUInt, BigUInt) {
        let fee: BigUInt = try await web3.provider.send("eth_maxPriorityFeePerGas", parameter: []).result
        let block = try await web3.eth.block(by: .latest)

        let buffer = fee / 100 * 13
        let maxPriorityFeePerGas = fee + buffer
        let maxFeePerGas = block.baseFeePerGas != nil ? block.baseFeePerGas! * 2 + maxPriorityFeePerGas : maxPriorityFeePerGas
        return (maxFeePerGas, maxPriorityFeePerGas)
    }

    private func legacyGasPrice() async throws -> (BigUInt, BigUInt) {
        let gas = try await web3.eth.gasPrice()
        return (gas, gas)
    }
}
