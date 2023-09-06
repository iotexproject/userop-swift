//
//  DefaultSinger.swift
//  
//
//  Created by liugang zhang on 2023/8/25.
//

import Foundation
import Web3Core
import web3swift
import CryptoKit

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

    public func getPublicKey() async -> Data {
        Data(hex: publicKey)
    }

    public func signMessage(_ data: Data) async throws -> Data {
        try await Web3Signer.signPersonalMessage(data, keystore: self, account: getAddress(), password: "")!
    }
}

struct P256R1Signer: Signer {
    let privateKey: P256.Signing.PrivateKey

    let pk: SecKey?
    let pub: SecKey?

    let pem = """
    -----BEGIN EC PRIVATE KEY-----
    MHcCAQEEIBbDF3PMLilq5FRILqtdk5qQ2kE7JvkIY4SgRTXFTAcEoAoGCCqGSM49
    AwEHoUQDQgAEVr5gJkJlK92Xvg/TntirzTVh77/unY5bQ9j4wwMhFFOuzsip5Tgb
    aO0DKhADDz58KI8oPmqmOIjeBhf/HXWC+Q==
    -----END EC PRIVATE KEY-----
    """

    init() {
        let pp = try! P256.Signing.PrivateKey(pemRepresentation: pem)
        privateKey = pp

        let x963 = pp.x963Representation

        let params = [
            kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeyClass: kSecAttrKeyClassPrivate,
//            kSecAttrKeySizeInBits: 256
        ] as [CFString : Any]

//        pk = SecKeyCreateRandomKey([
//            kSecAttrType as String: kSecAttrKeyTypeECSECPrimeRandom,
//            kSecAttrKeySizeInBits as String: 256,
//            kSecPrivateKeyAttrs as String: [
//                kSecAttrCanDecrypt as String: true,
//                kSecAttrIsPermanent as String: false,
//              ] as [String : Any],
//          ] as CFDictionary, nil)!
        var error: Unmanaged<CFError>?
        pk = SecKeyCreateWithData(x963 as CFData, params as CFDictionary, &error)

        pub = SecKeyCopyPublicKey(pk!)
    }

    func getAddress() async -> Web3Core.EthereumAddress {
        await Utilities.publicToAddress(getPublicKey())!
    }

    func getPublicKey() async -> Data {
        privateKey.publicKey.rawRepresentation
    }

    func signMessage(_ data: Data) async throws -> Data {
        let signed = SecKeyCreateSignature(pk!, .ecdsaSignatureMessageX962SHA256, data as CFData, nil)! as Data
        let xLength = UInt(from: signed[3..<4].toHexString())!

        let signatureArray = [
            signed[4..<xLength + 4],
            signed[(xLength + 6)...]
        ]

        let encoded = ABIEncoder.encode(types: [.uint(bits: 256), .uint(bits: 256)], values: signatureArray)
        return encoded!
    }

}
