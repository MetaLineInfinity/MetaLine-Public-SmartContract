# MetaLine-Public-SmartContract

MetaLine public smartcontracts

# 🚀 Quickstart

clone this repository and run

```
yarn
npx hardhat compile
npx hardhat node
npx hardhat --network localhost xgento 1
npx hardhat --network localhost xdeploy group MTT
npx hardhat --network localhost xgeninitonly 2
npx hardhat --network localhost xgenconfigonly 2
npx hardhat --network localhost xdeploy group mysteryboxShopV1
npx hardhat --network localhost xgeninitonly 3
npx hardhat --network localhost xgenconfigonly 3
npx hardhat --network localhost xdeploy group mysteryboxShopV2
npx hardhat --network localhost xgeninitonly 4
npx hardhat --network localhost xgenconfigonly 4
```

# 🛠️ Test

```
npx hardhat --network localhost xgentest 1
```