//
//  P256AccountTests.swift
//  
//
//  Created by liugang zhang on 2023/8/30.
//

import XCTest
import Web3Core
import web3swift
import BigInt

@testable import userop_swift

final class P256AccountTests: XCTestCase {
    let rpc = URL(string: "https://babel-api.testnet.iotex.io")!
    let bundler = URL(string: "https://bundler.testnet.w3bstream.com")!
    let entryPointAddress = EthereumAddress("0xc3527348De07d591c9d567ce1998eFA2031B8675")!
    let factoryAddress = EthereumAddress("0xed28ce54B09Ba99B131264306b44a665C1b8a465")!
    let emailGuardian = EthereumAddress("0xd8F31BC1E49d800D8B6B2AAE27219f47b94F5890")!

    let api_key = ""
    var paymaster: URL { URL(string: "https://paymaster.testnet.w3bstream.com/rpc/\(api_key)")! }

    func testGetSender() async throws {
        let account =  try await P256AccountBuilder(signer: P256R1Signer(),
                                                    rpcUrl: rpc,
                                                    bundleRpcUrl: bundler,
                                                    entryPoint: entryPointAddress,
                                                    factory: factoryAddress,
                                                    salt: 1)
        XCTAssertEqual(account.sender.address.lowercased(), "0x816117a3e3a909947e9835d3904a2991696f1fd2")

        try await account.build(entryPoint: entryPointAddress, chainId: 4690)

        let client = try await Client(rpcUrl: rpc, overrideBundlerRpc: bundler, entryPoint: entryPointAddress)
        let response = try await client.sendUserOperation(builder: account)
        let log = try await response.wait()
        print(log?.transactionHash as Any)
        XCTAssertNotNil(log)
//        XCTAssertTrue(op.callData.isEmpty)
//        XCTAssertFalse(op.initCode.isEmpty)
//        XCTAssertTrue(op.paymasterAndData.isEmpty)
//        XCTAssertEqual(op.sender.address, "0x816117a3e3a909947e9835d3904a2991696f1fd2")
//        XCTAssertEqual(op.signature.hexString, "0x077ae42d51634978fc63d49288abe559be2065c5ddad1a39a069875dda8fda901697dbc4fc63afb26e3dc26ee09f53f4994b5b4b1574edd20fa5b735cee1ab2d1c")
    }

    func testGetAddress2() async throws {
        let factory = try EthereumContract(Abi.p256AccountFactory, at: factoryAddress)
        let sender = try await factory.callStatic("getAddress", parameters: [P256R1Signer().getPublicKey(), 1], provider: JsonRpcProvider(url: rpc))
        XCTAssertEqual((sender["0"] as? EthereumAddress)?.address.lowercased(), "0x816117a3e3a909947e9835d3904a2991696f1fd2")
    }

    func testSigner() async throws {
        let signer = P256R1Signer()
        let pub = SecKeyCopyExternalRepresentation(signer.pub!, nil)! as Data
        let pub2 = await signer.getPublicKey()
        XCTAssertEqual(pub[1...].hexString, pub2.hexString)

        let data = Data(hex: "0xdead").sha3(.keccak256)
        let s2 = try signer.privateKey.signature(for: data)
        print(s2.rawRepresentation.hexString)
        print(s2.derRepresentation.hexString)
        let signed = try await signer.signMessage(data)

        let validate = ABI.Element.Function(name: "validateSignature",
                                            inputs: [
                                                .init(name: "message", type: .bytes(length: 32)),
                                                .init(name: "signature", type: .dynamicBytes),
                                                .init(name: "publicKey", type: .dynamicBytes)
                                            ],
                                            outputs: [
                                                .init(name: "result", type: .bool)
                                            ],
                                            constant: false,
                                            payable: false)
        let secpValidator = try EthereumContract(abi: [.function(validate)], at: .init("0x96e40ccE751E289c3a861C87947445acC772c292")!)
        let valid = try await secpValidator.callStatic("validateSignature", parameters: [data.sha256(), signed, pub2], provider: JsonRpcProvider(url: rpc))

        XCTAssertEqual(valid["0"] as? Bool, true)
    }

    func testTransfer() async throws {
        let account =  try await P256AccountBuilder(signer: P256R1Signer(),
                                                    rpcUrl: rpc,
                                                    bundleRpcUrl: bundler,
                                                    entryPoint: entryPointAddress,
                                                    factory: factoryAddress,
                                                    salt: 1,
                                                    paymasterMiddleware: VerifyingPaymasterMiddleware(paymasterRpc: paymaster))
        XCTAssertEqual(account.sender.address.lowercased(), "0x816117a3e3a909947e9835d3904a2991696f1fd2")

        account.execute(to: .init("0x2eE1d96CB76579e2c64C9BB045443Fb3849491D2")!, value: Utilities.parseToBigUInt("1", units: .ether)!, data: Data())
        let client = try await Client(rpcUrl: rpc, overrideBundlerRpc: bundler, entryPoint: entryPointAddress)
        let response = try await client.sendUserOperation(builder: account)
        let log = try await response.wait()
        print(log?.transactionHash.hexString)
        print(log)
        XCTAssertNotNil(log)
    }

    func testBindEmail() async throws {
        let account =  try await P256AccountBuilder(signer: P256R1Signer(),
                                                    rpcUrl: rpc,
                                                    bundleRpcUrl: bundler,
                                                    entryPoint: entryPointAddress,
                                                    factory: factoryAddress,
                                                    salt: 1)
        let data = account.proxy.contract.method("addEmailGuardian", parameters: [
            "0x36387ffce3ddd8c35b790148d6e6134689f74fe32471a27e8a243634ce213098",
            "0x416bf2958e0965619fe574411312d6963673c87443f2ca65b34cc4415badc96749b5509d0ef2c43000e34fdd9ef5503bf2a12963c0190c25c1f56889d2efb9031b"
        ], extraData: nil)!
        account.execute(to: account.sender, value: 0, data: data)

        let client = try await Client(rpcUrl: rpc, overrideBundlerRpc: bundler, entryPoint: entryPointAddress)
        let response = try await client.sendUserOperation(builder: account)
        let log = try await response.wait()
        print(log?.blockHash.hexString)
        print(log?.transactionHash.hexString)
    }

    func testRemoveEmail() async throws {
        let account =  try await P256AccountBuilder(signer: P256R1Signer(),
                                                    rpcUrl: rpc,
                                                    bundleRpcUrl: bundler,
                                                    entryPoint: entryPointAddress,
                                                    factory: factoryAddress,
                                                    salt: 1)
        let data = account.proxy.contract.method("removeEmailGuardian", parameters: [], extraData: nil)!
        account.execute(to: account.sender, value: 0, data: data)

        let client = try await Client(rpcUrl: rpc, overrideBundlerRpc: bundler, entryPoint: entryPointAddress)
        let response = try await client.sendUserOperation(builder: account)
        let log = try await response.wait()
        print(log?.transactionHash.hexString)
    }
}
