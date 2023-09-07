//
//  UserOperation.swift
//  
//
//  Created by liugang zhang on 2023/8/21.
//

import BigInt
import Foundation
import Web3Core

let defaultVerificationGasLimit = BigUInt(70000)
let defaultCallGasLimit = BigUInt(35000)
let defaultPreVerificationGas = BigUInt(21000)

public struct UserOperation: Encodable {
    var sender: EthereumAddress
    var nonce: BigUInt
    var initCode: Data
    var callData: Data
    var callGasLimit: BigUInt
    var verificationGasLimit: BigUInt
    var preVerificationGas: BigUInt
    var maxFeePerGas: BigUInt
    var maxPriorityFeePerGas: BigUInt
    var paymasterAndData: Data
    var signature: Data

    static var `default`: Self {
        UserOperation(
            sender: EthereumAddress.zero,
            nonce: 0,
            initCode: Data(),
            callData: Data(),
            callGasLimit: defaultCallGasLimit,
            verificationGasLimit: defaultVerificationGasLimit,
            preVerificationGas: defaultPreVerificationGas,
            maxFeePerGas: 0,
            maxPriorityFeePerGas: 0,
            paymasterAndData: Data(),
            signature: Data()
        )
    }

    enum CodingKeys: CodingKey {
        case sender
        case nonce
        case initCode
        case callData
        case callGasLimit
        case verificationGasLimit
        case preVerificationGas
        case maxFeePerGas
        case maxPriorityFeePerGas
        case paymasterAndData
        case signature
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sender, forKey: .sender)
        try container.encodeHex(nonce, forKey: .nonce)
        try container.encodeHex(initCode, forKey: .initCode)
        try container.encodeHex(callData, forKey: .callData)
        try container.encodeHex(callGasLimit, forKey: .callGasLimit)
        try container.encodeHex(verificationGasLimit, forKey: .verificationGasLimit)
        try container.encodeHex(preVerificationGas, forKey: .preVerificationGas)
        try container.encodeHex(maxFeePerGas, forKey: .maxFeePerGas)
        try container.encodeHex(maxPriorityFeePerGas, forKey: .maxPriorityFeePerGas)
        try container.encodeHex(paymasterAndData, forKey: .paymasterAndData)
        try container.encodeHex(signature, forKey: .signature)
    }
}

public protocol IUserOperationBuilder {
    var sender: EthereumAddress { get set }
    var nonce: BigUInt { get set }
    var initCode: Data { get set }
    var callData: Data { get set }
    var callGasLimit: BigUInt { get set }
    var verificationGasLimit: BigUInt { get set }
    var preVerificationGas: BigUInt { get set }
    var maxFeePerGas: BigUInt { get set }
    var maxPriorityFeePerGas: BigUInt { get set }
    var paymasterAndData: Data { get set }
    var signature: Data { get set }

    func useMiddleware(_ middleware: UserOperationMiddleware)
    func resetMiddleware()

    func build(entryPoint: EthereumAddress, chainId: BigUInt) async throws -> UserOperation

    func reset()
}

open class UserOperationBuilder: IUserOperationBuilder {
    private var op: UserOperation
    private var middlewares = [UserOperationMiddleware]()

    init(
        op: UserOperation? = nil
    ) {
        self.op = op ?? UserOperation.default
    }

    public var sender: EthereumAddress {
        get { return op.sender }
        set { op.sender = newValue }
    }

    public var nonce: BigUInt {
        get { return op.nonce }
        set { op.nonce = newValue }
    }

    public var initCode: Data {
        get { return op.initCode }
        set { op.initCode = newValue }
    }

    public var callData: Data {
        get { return op.callData }
        set { op.callData = newValue }
    }

    public var callGasLimit: BigUInt {
        get { return op.callGasLimit }
        set { op.callGasLimit = newValue }
    }

    public var verificationGasLimit: BigUInt {
        get { return op.verificationGasLimit }
        set { op.verificationGasLimit = newValue}
    }

    public var preVerificationGas: BigUInt {
        get { return op.preVerificationGas}
        set { op.preVerificationGas = newValue }
    }

    public var maxFeePerGas: BigUInt {
        get { return op.maxFeePerGas }
        set { op.maxFeePerGas = newValue }
    }

    public var maxPriorityFeePerGas: BigUInt {
        get { return op.maxPriorityFeePerGas }
        set { op.maxPriorityFeePerGas = newValue }
    }

    public var paymasterAndData: Data {
        get { return op.paymasterAndData }
        set { op.paymasterAndData = newValue }
    }

    public var signature: Data {
        get { return op.signature }
        set { op.signature = newValue }
    }

    public func useMiddleware(_ middleware: UserOperationMiddleware) {
        middlewares.append(middleware)
    }

    public func resetMiddleware() {
        middlewares = []
    }

    public func build(entryPoint: EthereumAddress, chainId: BigUInt) async throws -> UserOperation {
        var ctx = UserOperationMiddlewareContext(op: op, entryPoint: entryPoint, chainId: chainId)

        for middleware in middlewares {
            try await middleware.process(&ctx)
        }

        return ctx.op
    }

    public func reset() {
        op = UserOperation.default
    }
}
