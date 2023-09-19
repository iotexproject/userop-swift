![Iotex-IoPay](https://github.com/iotexproject/userop-swift/assets/16026265/46911948-aa87-4fd3-9ddb-0a504f801f3f)


# userop-swift



## Summary
An account abstraction proposal which completely avoids the need for consensus-layer protocol changes. Instead of adding new protocol features and changing the bottom-layer transaction type, this proposal instead introduces a higher-layer pseudo-transaction object called a UserOperation. Users send UserOperation objects into a separate mempool. A special class of actor called bundlers package up a set of these objects into a transaction making a handleOps call to a special contract, and that transaction then gets included in a block.
 
[ERC-4337: Account Abstraction Using Alt Mempool](https://eips.ethereum.org/EIPS/eip-4337)     


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

> Once you activeated your account, you can pass it as `senderAddress` into AccountBuilder. In this case, `salt` will be ignored.

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
