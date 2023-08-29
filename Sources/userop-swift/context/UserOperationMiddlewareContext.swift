//
//  UserOperationMiddlewareContext.swift
//  
//
//  Created by liugang zhang on 2023/8/21.
//
import BigInt
import Foundation
import Web3Core

public protocol UserOperationMiddlewareContextType {
    var op: UserOperation { get set }
    var entryPoint: EthereumAddress { get }
    var chainId: BigUInt { get }

    func getUserOpHash() -> String
}

public class UserOperationMiddlewareContext: UserOperationMiddlewareContextType {
    public var op: UserOperation

    public let entryPoint: EthereumAddress

    public let chainId: BigUInt

    public init(op: UserOperation, entryPoint: EthereumAddress, chainId: BigUInt) {
        self.op = op
        self.entryPoint = entryPoint
        self.chainId = chainId
    }

    public func getUserOpHash() -> String {
        let packed = ABIEncoder.encode(types: [
            .address,
            .uint(bits: 256),
            .bytes(length: 32),
            .bytes(length: 32),
            .uint(bits: 256),
            .uint(bits: 256),
            .uint(bits: 256),
            .uint(bits: 256),
            .uint(bits: 256),
            .bytes(length: 32)
        ], values: [
            op.sender,
            op.nonce,
            op.initCode.sha3(.keccak256),
            op.callData.sha3(.keccak256),
            op.callGasLimit,
            op.verificationGasLimit,
            op.preVerificationGas,
            op.maxFeePerGas,
            op.maxPriorityFeePerGas,
            op.paymasterAndData.sha3(.keccak256)
        ])!

        let enc = ABIEncoder.encode(types: [
            .bytes(length: 32),
            .address,
            .uint(bits: 256)
        ], values: [
            packed.sha3(.keccak256),
            entryPoint,
            chainId
        ])!

        return enc.sha3(.keccak256).toHexString()
    }


}
