//
//  GasEstimateMiddleware.swift
//  
//
//  Created by liugang zhang on 2023/8/23.
//

import Foundation
import BigInt
import Web3Core

struct GasEstimate: APIResultType {
    let preVerificationGas: BigUInt
    let verificationGasLimit: BigUInt
    let callGasLimit: BigUInt
}

extension GasEstimate {
    enum CodingKeys: CodingKey {
        case preVerificationGas
        case verificationGasLimit
        case callGasLimit
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            let preVerificationGas = try container.decodeHex(BigUInt.self, forKey: .preVerificationGas)
            let verificationGasLimit = try container.decodeHex(BigUInt.self, forKey: .verificationGasLimit)
            let callGasLimit = try container.decodeHex(BigUInt.self, forKey: .callGasLimit)
            self.init(preVerificationGas: preVerificationGas,
                      verificationGasLimit: verificationGasLimit,
                      callGasLimit: callGasLimit)
        } catch {
            let preVerificationGas = try container.decode(Int.self, forKey: .preVerificationGas)
            let verificationGasLimit = try container.decode(Int.self, forKey: .verificationGasLimit)
            let callGasLimit = try container.decode(Int.self, forKey: .callGasLimit)
            self.init(preVerificationGas: BigUInt(preVerificationGas),
                      verificationGasLimit: BigUInt(verificationGasLimit),
                      callGasLimit: BigUInt(callGasLimit))
        }
    }
}

/// Middleware to estiamte `UserOperation` gas from bundler server.
public struct GasEstimateMiddleware: UserOperationMiddleware {
    let rpcProvider: JsonRpcProvider

    public func process(_ ctx: inout UserOperationMiddlewareContext) async throws {
        let estimate: GasEstimate = try await rpcProvider.send("eth_estimateUserOperationGas", parameter: [ctx.op, ctx.entryPoint]).result

        ctx.op.preVerificationGas = estimate.preVerificationGas
        ctx.op.verificationGasLimit = estimate.verificationGasLimit
        ctx.op.callGasLimit = estimate.callGasLimit
    }
}
