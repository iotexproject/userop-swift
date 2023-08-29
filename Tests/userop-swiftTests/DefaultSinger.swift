//
//  DefaultSinger.swift
//  
//
//  Created by liugang zhang on 2023/8/25.
//

import Foundation
import Web3Core

@testable import userop_swift

public class DefaultSigner: Signer {
    public func getAddress() async -> EthereumAddress {
        .init("0x3D642A3ED429dF4B4D2d318e6b9B21EA7B680b83")!
    }

    public func signMessage(_ data: Data) async -> Data {
        Data()
    }
}
