//
//  Signer.swift
//  
//
//  Created by liugang zhang on 2023/8/23.
//

import Foundation
import Web3Core

public protocol Signer {
    func getAddress() async -> EthereumAddress

    func signMessage(_ data: Data) async -> Data
}
