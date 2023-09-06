//
//  EntryPointTests.swift
//  
//
//  Created by liugang zhang on 2023/8/24.
//

import XCTest
import Web3Core
import web3swift
@testable import userop_swift

let TestEvent = """
[{
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "bytes32",
          "name": "userOpHash",
          "type": "bytes32"
        },
        {
          "indexed": true,
          "internalType": "address",
          "name": "sender",
          "type": "address"
        },
        {
          "indexed": true,
          "internalType": "string",
          "name": "a",
          "type": "string"
        },
        {
          "indexed": true,
          "internalType": "bool",
          "name": "b",
          "type": "bool"
        },
        {
          "indexed": true,
          "internalType": "bytes",
          "name": "c",
          "type": "bytes"
        },
        {
          "indexed": true,
          "internalType": "uint256",
          "name": "d",
          "type": "uint256"
        },
      ],
      "name": "UserOperationEvent",
      "type": "event"
    }
]
"""

final class EntryPointTests: XCTestCase {
    func testEncodeLogs() throws {
        let contract = try EthereumContract(TestEvent)
        let logs = contract.events["UserOperationEvent"]?.encodeParameters(
            [
                "0x2c16c07e1c68d502e9c7ad05f0402b365671a0e6517cb807b2de4edd95657042",
                "0x581074D2d9e50913eB37665b07CAFa9bFFdd1640",
                "hello,world",
                true,
                "0x02c16c07e1c68d50",
                nil
            ]
        )
        
        XCTAssertEqual(logs?.count, 6)
    }
}
