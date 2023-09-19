![Iotex-IoPay](https://github.com/iotexproject/userop-swift/assets/16026265/46911948-aa87-4fd3-9ddb-0a504f801f3f)


# userop-swift



## About Account Abstraction Using Alt Mempool
An account abstraction proposal which completely avoids the need for consensus-layer protocol changes. Instead of adding new protocol features and changing the bottom-layer transaction type, this proposal instead introduces a higher-layer pseudo-transaction object called a UserOperation. Users send UserOperation objects into a separate mempool. A special class of actor called bundlers package up a set of these objects into a transaction making a handleOps call to a special contract, and that transaction then gets included in a block.
 
[ERC-4337: Account Abstraction Using Alt Mempool](https://eips.ethereum.org/EIPS/eip-4337)     


## Advanced Supported P256 Account for Trusted Environment

On the basis of [userop.js](https://github.com/stackup-wallet/userop.js) signature, we advanced supported secp256r1-based signature.

The "secp256r1" elliptic curve is a standardized curve by NIST which has the same calculations by different input parameters with""secp256k1” elliptic curve used by the "ecrecover" precompiled contract. The cost of combined attacks and the security conditions are almost the same for both curves. Adding a precompiled contract which is similar to "ecrecover" can provide signature verifications using the "secp256r1" elliptic curve in the smart contracts and multi-faceted benefits can occur. One important factor is that this curve is widely used and supported in many modern devices such as Apple’s Secure Enclave, Webauthn, Android Keychain which proves the user adoption. Additionally, the introduction of this precompile could enable valuable features in the account abstraction which allows more efficient and flexible management of accounts by transaction signs in mobile devices. Most of the modern devices and applications rely on the "secp256r1" elliptic curve. The addition of this precompiled contract enables the verification of device native transaction signing mechanisms. For example:

+ **Apple’s Secure Enclave** :shipit:: There is a separate "Trusted Execution Environment" in Apple hardware which can sign arbitrary messages and can only be accessed by biometric identification.
Webauthn: Web Authentication (WebAuthn) is a web standard published by the World Wide Web Consortium (W3C). WebAuthn aims to standardize an interface for authenticating users to web-based applications and services using public-key cryptography. It is being used by almost all of the modern web browsers.
* **Android Keystore**: Android Keystore is an API that manages the private keys and signing methods. The private keys are not processed while using Keystore as the applications’ signing method. Also, it can be done in the "Trusted Execution Environment" in the microchip.

  
[Reffer to EIP-7212](https://eips.ethereum.org/EIPS/eip-7212)


## Install

```swift
.package(url: "https://github.com/iotexproject/userop-swift.git", from: "x.y.z")
```

## Usage

### Signer
For `SimpleAccount`, sign UserOpHash by `Web3Signer` method, pass `useHash` as true:
```swift
static func signPersonalMessage<T>(Data, keystore: T, account: EthereumAddress, password: String, useHash: Bool, useExtraEntropy: Bool) throws -> Data?
```

For `P256Account`, sign UserOpHash as follows: 
```swift
func signMessage(_ data: Data) async throws -> Data {
    let signed = SecKeyCreateSignature(pk, .ecdsaSignatureMessageX962SHA256, data as CFData, nil)! as Data
    let xLength = UInt(from: signed[3..<4].toHexString())!

    let signatureArray = [
        signed[4..<xLength + 4],
        signed[(xLength + 6)...]
    ]

    let encoded = ABIEncoder.encode(types: [.uint(bits: 256), .uint(bits: 256)], values: signatureArray)
    return encoded!
}
```

### Get Sender Address
```swift
let accountBuilder =  try await SimpleAccountBuilder(
    signer: signer,
    rpcUrl: rpc,
    bundleRpcUrl: bundler,
    entryPoint: entryPointAddress,
    factory: factoryAddress,
    salt: 1
)
let senderAddress = accountBuilder.sender.address
```

### Active Account
```swift
let client = try await Client(rpcUrl: rpc, overrideBundlerRpc: bundler, entryPoint: entryPointAddress)
let response = try await client.sendUserOperation(builder: accountBuilder)
let eventLog = try await response.wait()
let hash = eventLog?.transactionHash
```

### Send ETH
```swift
accountBuilder.execute(to: address, value: Utilities.parseToBigUInt("1", units: .ether)!, data: Data())

let response = try await client.sendUserOperation(builder: accountBuilder)
```

### Send ERC20
```swift
let erc20 = try EthereumContract(erc20_abi)
let data = erc20.method("transfer", parameters: [to, value])

accountBuilder.execute(to: erc20_address, value: 0, data: data)

let response = try await client.sendUserOperation(builder: accountBuilder)
```
