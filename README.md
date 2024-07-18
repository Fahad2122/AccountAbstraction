## Account Abstraction

**This project implements an advanced account abstraction contract leveraging paymasters to allow gas payments for their users or using ERC20 tokens instead of the native blockchain currency. The contract is designed to work seamlessly with a bundler to aggregate and manage transactions.**

Features:

-   **Account Abstraction**: Simplifies user interactions with the blockchain by abstracting account management.
-   **Paymaster Integration**: Allows third-party entities to sponsor gas fees, enhancing user experience.
-   **ERC20 Token Gas Payment**: Enables gas payments with ERC20 tokens, making the platform more flexible and user-friendly.
-   **Bundler Support**: Aggregates multiple transactions into one, reducing gas costs and improving efficiency.

## EtherScan

https://sepolia.etherscan.io/address/0xa402b8006cA4890B5912d2829489F4244E443137#code

## Usage

### Clone the repo

```shell
$ git clone https://github.com/Fahad2122/AccountAbstraction
$ cd AccountAbstraction
```

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil for local Testing Account

```shell
$ anvil
```

### Deploy

```shell
$ forge create --constructor-args <entryPoint_contract_address_for_your_network> --rpc-url <your_rpc_url> --private-key <your_private_key> src/Ethereum/AccountAbstraction.sol:AccountAbstraction
```

## Contribution

Update the _validateSignature code to modify it according to your usecase
