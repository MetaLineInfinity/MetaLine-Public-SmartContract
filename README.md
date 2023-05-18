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
npx hardhat --network localhost xgenconfigonly 
npx hardhat --network localhost xdeploy group mysterybox
npx hardhat --network localhost xgeninitonly 5
npx hardhat --network localhost xgenconfigonly 5
npx hardhat --network localhost xdeploy group game1
npx hardhat --network localhost xgeninitonly 6
npx hardhat --network localhost xgenconfigonly 6
npx hardhat --network localhost xdeploy group market
npx hardhat --network localhost xgeninitonly 7
npx hardhat --network localhost xgenconfigonly 7
```

# 🛠️ Test

```
npx hardhat --network localhost xgentest 1
```