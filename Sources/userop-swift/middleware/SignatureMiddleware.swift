//
//  SignatureMiddleware.swift
//  
//
//  Created by liugang zhang on 2023/8/30.
//

import Foundation

public struct SignatureMiddleware: UserOperationMiddleware {
    let signer: Signer
    
    public func process(_ ctx: inout UserOperationMiddlewareContext) async throws {
        ctx.op.signature = try await signer.signMessage(Data(hex: ctx.getUserOpHash()))
    }
}
