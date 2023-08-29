//
//  SimpleAccount.swift
//  
//
//  Created by liugang zhang on 2023/8/23.
//

import Foundation
import Web3Core
import web3swift

public protocol ISimpleAccount {
    var contract: EthereumContract { get }
}

public class SimpleAccount {
    public var web3: Web3
    public var address: EthereumAddress
    public let contract: EthereumContract

    init(web3: Web3, address: EthereumAddress) {
        self.web3 = web3
        self.address = address
        self.contract = try! EthereumContract(Abi.entryPoint, at: address)
    }
}
