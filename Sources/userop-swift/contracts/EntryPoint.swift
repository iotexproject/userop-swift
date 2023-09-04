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
    func queryUserOperationEvent(userOpHash: Hash) async throws -> [EventLog]
}

public class EntryPoint: IEntryPoint {
    public var web3: Web3
    public var address: EthereumAddress
    public let contract: EthereumContract

    init(web3: Web3, address: EthereumAddress) {
        self.web3 = web3
        self.address = address
        self.contract = try! EthereumContract(Abi.entryPoint, at: address)
    }

    public func getSenderAddress(initCode: Data) async throws -> EthereumAddress {
        do {
            try await contract.callStatic("getSenderAddress", parameters: [initCode], provider: web3.provider)
            throw Web3Error.dataError
        } catch Web3Error.revertCustom(_, let args) {
            guard let address =  args["sender"] as? EthereumAddress else {
                throw Web3Error.dataError
            }
            return address
        }
    }

    public func getNonce(sender: EthereumAddress, key: BigInt) async throws -> BigUInt {
        let response = try await contract.callStatic("getNonce", parameters: [sender, key], provider: web3.provider)
        guard let nonce = response["0"] as? BigUInt else {
            throw Web3Error.dataError
        }
        return nonce
    }

    public func queryUserOperationEvent(userOpHash: Hash) async throws -> [EventLog] {
        let block = try await web3.eth.block(by: .latest)
        return try await contract.queryFilter("UserOperationEvent", parameters: [userOpHash], fromBlock: .exact(block.number - 100), provider: web3.provider)
    }
}

extension ContractProtocol {
    func queryFilter(_ event: String, parameters: [Encodable], fromBlock: BlockNumber = .latest, toBlock: BlockNumber = .latest, provider: Web3Provider) async throws -> [EventLog] {
        guard let event = events[event], let address = address else {
            throw Web3Error.dataError
        }
        let topics = event.encodeParameters(parameters)
        let filter = EventFilterParameters(fromBlock: fromBlock, toBlock: toBlock, address: [address], topics: topics)
        return try await provider.send(.getLogs(filter)).result
    }
}
