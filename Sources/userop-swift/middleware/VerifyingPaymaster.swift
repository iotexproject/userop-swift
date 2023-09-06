//
//  VerifyingPaymaster.swift
//  
//
//  Created by liugang zhang on 2023/8/22.
//

import BigInt
import Foundation
import web3swift
import Web3Core

struct VerifyingPaymasterResult: APIResultType {
    var paymasterAndData: Data
    var preVerificationGas: BigUInt;
    var verificationGasLimit: BigUInt;
    var callGasLimit: BigUInt;
}


extension VerifyingPaymasterResult {
    enum CodingKeys: CodingKey {
        case paymasterAndData
        case preVerificationGas
        case verificationGasLimit
        case callGasLimit
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let paymasterAndData = try container.decodeHex(Data.self, forKey: .paymasterAndData)
        do {
            let preVerificationGas = try container.decodeHex(BigUInt.self, forKey: .preVerificationGas)
            let verificationGasLimit = try container.decodeHex(BigUInt.self, forKey: .verificationGasLimit)
            let callGasLimit = try container.decodeHex(BigUInt.self, forKey: .callGasLimit)
            self.init(paymasterAndData: paymasterAndData,
                      preVerificationGas: preVerificationGas,
                      verificationGasLimit: verificationGasLimit,
                      callGasLimit: callGasLimit)
        } catch {
            let preVerificationGas = try container.decode(Int.self, forKey: .preVerificationGas)
            let verificationGasLimit = try container.decode(Int.self, forKey: .verificationGasLimit)
            let callGasLimit = try container.decode(Int.self, forKey: .callGasLimit)
            self.init(paymasterAndData: paymasterAndData,
                      preVerificationGas: BigUInt(preVerificationGas),
                      verificationGasLimit: BigUInt(verificationGasLimit),
                      callGasLimit: BigUInt(callGasLimit))
        }
    }
}


public struct VerifyingPaymasterMiddleware: UserOperationMiddleware {
    let paymasterRpc: URL

    public func process(_ ctx: inout UserOperationMiddlewareContext) async throws {
        ctx.op.verificationGasLimit = ctx.op.verificationGasLimit * 3
        let provider = try await JsonRpcProvider(url: paymasterRpc, ignoreNet: true)

        let response: VerifyingPaymasterResult = try await provider.send("pm_sponsorUserOperation", parameter: [ctx.op, ctx.entryPoint, ""]).result

        ctx.op.paymasterAndData = response.paymasterAndData
        ctx.op.preVerificationGas = response.preVerificationGas
        ctx.op.verificationGasLimit = response.verificationGasLimit
        ctx.op.callGasLimit = response.callGasLimit
    }
}
