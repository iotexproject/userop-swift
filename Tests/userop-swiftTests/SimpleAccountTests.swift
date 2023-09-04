//
//  SimpleAccountTests.swift
//  
//
//  Created by liugang zhang on 2023/8/25.
//

import XCTest
import Web3Core
import BigInt

@testable import userop_swift

final class SimpleAccountTests: XCTestCase {

    let rpc = URL(string: "https://babel-api.testnet.iotex.io")!
    let bundler = URL(string: "https://bundler.testnet.w3bstream.com")!
    let entryPointAddress = EthereumAddress("0xc3527348De07d591c9d567ce1998eFA2031B8675")!
    let factoryAddress = EthereumAddress("0xA8e5d5Ca2924f176BD3Bf1049550920969F23450")!
    let signer = DefaultSigner()

    func testGetAddress() async throws {

        let factory = try EthereumContract(Abi.simpleAccountFactory, at: factoryAddress)
        let sender = try await factory.callStatic("getAddress", parameters: [signer.getAddress(), 1], provider: JsonRpcProvider(url: rpc))
        XCTAssertEqual((sender["0"] as? EthereumAddress)?.address, "0x581074D2d9e50913eB37665b07CAFa9bFFdd1640")
    }

    func testGetSender() async throws {
        let account =  try await SimpleAccountBuilder(signer: signer,
                                                      rpcUrl: rpc,
                                                      bundleRpcUrl: bundler,
                                                      entryPoint: entryPointAddress,
                                                      factory: factoryAddress,
                                                      salt: 1)
        XCTAssertEqual(account.sender.address, "0x581074D2d9e50913eB37665b07CAFa9bFFdd1640")

        let op = try await account.build(entryPoint: entryPointAddress, chainId: 4690)
        XCTAssertTrue(op.callData.isEmpty)
        XCTAssertTrue(op.initCode.isEmpty)
        XCTAssertTrue(op.paymasterAndData.isEmpty)
        XCTAssertEqual(op.sender.address, "0x581074D2d9e50913eB37665b07CAFa9bFFdd1640")
        XCTAssertNotNil(op.signature)
    }

    func testCreateAccount() async throws {
        let account =  try await SimpleAccountBuilder(signer: DefaultSigner(),
                                                      rpcUrl: rpc,
                                                      bundleRpcUrl: bundler,
                                                      entryPoint: entryPointAddress,
                                                      factory: factoryAddress,
                                                      salt: 1)
        XCTAssertEqual(account.sender.address, "0x581074D2d9e50913eB37665b07CAFa9bFFdd1640")

        let client = try await Client(rpcUrl: rpc, overrideBundlerRpc: bundler, entryPoint: entryPointAddress)
        let response = try await client.sendUserOperation(builder: account)
        let eventLog = try await response.wait()
        print(eventLog)
        XCTAssertNotNil(eventLog)
    }

    func testSign() async throws {
        let data = Data(hex: "0xdead").sha3(.keccak256)
        let signed = try await signer.signMessage(data)
        let result = "0xd4145ee7c36c1d1a0d229236947dc7ae2ef889c8b1d64bbe188047d5f4768c714af68ea6f8e818ee43c2e07f17f9d409ebb988af5415ace4116703d5a483b5c01b"

        XCTAssertEqual(signed.hexString, result)
    }
}
