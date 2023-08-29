//
// Created by liugang zhang on 2023/8/21.
//
import BigInt
import Foundation

public protocol UserOperationMiddleware {
    func process(_  ctx: inout UserOperationMiddlewareContext) async throws
}
