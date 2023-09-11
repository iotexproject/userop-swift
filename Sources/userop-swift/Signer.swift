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

    func getPublicKey() async throws -> Data

    func signMessage(_ data: Data) async throws -> Data
}
