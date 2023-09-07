//
//  P256AccountFactory.swift
//  
//
//  Created by liugang zhang on 2023/8/30.
//

import Foundation
import BigInt
import Web3Core
import web3swift

public protocol IP256AccountFactory {
    var contract: EthereumContract { get }

    func getAddress(publicKey: Data, salt: BigInt) async throws -> EthereumAddress
}

public class P256AccountFactory: IP256AccountFactory {
    public var web3: Web3
    public var address: EthereumAddress
    public let contract: EthereumContract

    init(web3: Web3, address: EthereumAddress) {
        self.web3 = web3
        self.address = address
        self.contract = try! EthereumContract(Abi.p256AccountFactory, at: address)
    }

    public func getAddress(publicKey: Data, salt: BigInt) async throws -> EthereumAddress {
        let data = contract.method("getAddress", parameters: [publicKey, salt], extraData: nil)!
        let transaction = CodableTransaction(to: address, data: data)
        let result = try await web3.eth.callTransaction(transaction)
        let decoded = try contract.decodeReturnData("getAddress", data: result)
        guard let returnAddress = decoded[""] as? EthereumAddress else {
            throw Web3Error.typeError
        }
        return returnAddress
    }
}
