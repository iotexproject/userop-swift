//
//  P256Account.swift
//  
//
//  Created by liugang zhang on 2023/8/30.
//

import Foundation
import Web3Core
import web3swift

public protocol IP256Account {
    var contract: EthereumContract { get }
}

public class P256Account: IP256Account {
    public var web3: Web3
    public var address: EthereumAddress
    public let contract: EthereumContract

    init(web3: Web3, address: EthereumAddress) {
        self.web3 = web3
        self.address = address
        self.contract = try! EthereumContract(Abi.p256Account, at: address)
    }
}
