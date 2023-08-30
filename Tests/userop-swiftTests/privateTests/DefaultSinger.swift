//
//  DefaultSinger.swift
//  
//
//  Created by liugang zhang on 2023/8/25.
//

import Foundation
import Web3Core
import web3swift

@testable import userop_swift

public class DefaultSigner: Signer, AbstractKeystore {
    public var addresses: [Web3Core.EthereumAddress]?

    public var isHDKeystore = false

    public func UNSAFE_getPrivateKeyData(password: String, account: Web3Core.EthereumAddress) throws -> Data {
        Data(hex: privatekey)
    }

    let privatekey = "0x837b48d5f618332e91058b669f8c580d92e0d5c5781ea3b9b2b49676dde75e8a"
    let publicKey = "0x03cb5151e0ce1b7a6654582256759326e30bf6986ef4e6f1f62dccedab6ed034be"

    public func getAddress() async -> EthereumAddress {
        .init("0x3D642A3ED429dF4B4D2d318e6b9B21EA7B680b83")!
    }

    public func signMessage(_ data: Data) async throws -> Data {
        try await Web3Signer.signPersonalMessage(data, keystore: self, account: getAddress(), password: "")!
    }
}
