//
//  EntryPoint.swift
//  
//
//  Created by liugang zhang on 2023/8/23.
//

import Foundation
import BigInt
import Web3Core
import web3swift

public protocol IEntryPoint {
    var contract: EthereumContract { get }

    func getSenderAddress(initCode: Data) async throws -> EthereumAddress
    func getNonce(sender: EthereumAddress, key: BigInt) async throws -> BigUInt
}

public class EntryPoint: IEntryPoint {
    public var web3: Web3
    public var address: EthereumAddress
    public let contract: EthereumContract

    init(web3: Web3, address: EthereumAddress) {
        self.web3 = web3
        self.address = address
        self.contract = try! EthereumContract(Abi.entryPoint, at: address)
//        contract.events
    }

    public func getSenderAddress(initCode: Data) async throws -> EthereumAddress {
        let data = contract.method("getSenderAddress", parameters: [initCode], extraData: nil)!

        let res = try await web3.eth.callTransaction(.init(to: address, data: data))
        guard let decoded = contract.decodeEthError(res), let sender = decoded["sender"] as? EthereumAddress else {
            throw Web3Error.valueError(desc: "call getSenderAddress failed: can not decode sender address")
        }

        return sender
    }

    public func getNonce(sender: EthereumAddress, key: BigInt) async throws -> BigUInt {
        fatalError("TODO")
    }

    public func userOperationEvent() -> [EventFilterParameters.Topic?]? {
        let result = contract.events["UserOperationEvent"]?.encodeParameters([
            "0x2c16c07e1c68d502e9c7ad05f0402b365671a0e6517cb807b2de4edd95657042",
        ])

        return result
    }

    public func queryFilter() async throws -> [EventLog] {
        let topics = userOperationEvent()!
        let block = try await web3.eth.block(by: .latest)

        let parameters = EventFilterParameters(fromBlock: .exact(block.number - 10000), address: [address], topics: topics)
        let result = try await web3.eth.getLogs(eventFilter: parameters)
        return result
    }
}
