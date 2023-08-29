//
//  SimpleAccountTests.swift
//  
//
//  Created by liugang zhang on 2023/8/25.
//

import XCTest
@testable import userop_swift

final class SimpleAccountTests: XCTestCase {

    let rpc = URL(string: "https://babel-api.testnet.iotex.io")!
    let bundler = URL(string: "https://bundler.testnet.w3bstream.com")!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetSender() async throws {
        let account =  try await SimpleAccountBuilder(signer: DefaultSigner(),
                                                      rpcUrl: rpc,
                                                      bundleRpcUrl: bundler,
                                                      entryPoint: .init("0xc3527348De07d591c9d567ce1998eFA2031B8675")!,
                                                      factory: .init("0xA8e5d5Ca2924f176BD3Bf1049550920969F23450")!,
                                                      salt: 1)
        XCTAssertEqual(account.sender.address, "0x581074D2d9e50913eB37665b07CAFa9bFFdd1640")
    }

}
