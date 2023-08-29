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

public struct VerifyingPaymasterMiddleware: UserOperationMiddleware {
    let paymasterRpc: URL

    public func process(_ ctx: inout UserOperationMiddlewareContext) async throws {
        ctx.op.verificationGasLimit = ctx.op.verificationGasLimit * 3
        let provider = BundlerJsonRpcProvider(url: paymasterRpc)
        let response: APIResponse<VerifyingPaymasterResult> = try await provider.send("pm_sponsorUserOperation", parameter: [])

        ctx.op.paymasterAndData = response.result.paymasterAndData
        ctx.op.preVerificationGas = response.result.preVerificationGas
        ctx.op.verificationGasLimit = response.result.verificationGasLimit
        ctx.op.callGasLimit = response.result.callGasLimit
    }
}
