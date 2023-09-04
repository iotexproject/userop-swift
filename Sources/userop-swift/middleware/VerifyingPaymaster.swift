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
        let provider = try await BundlerJsonRpcProvider(url: paymasterRpc)
        let response: VerifyingPaymasterResult = try await provider.send("pm_sponsorUserOperation", parameter: []).result

        ctx.op.paymasterAndData = response.paymasterAndData
        ctx.op.preVerificationGas = response.preVerificationGas
        ctx.op.verificationGasLimit = response.verificationGasLimit
        ctx.op.callGasLimit = response.callGasLimit
    }
}
