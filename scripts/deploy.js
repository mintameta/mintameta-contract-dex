// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const {ethers, network} = require("hardhat");
require("dotenv").config({path: '../.env'});

const ADDRESS_PAYEE = process.env.ADDRESS_PAYEE;

async function main() {
    const WETH = getWETH();
    // factory
    const FactoryController = await ethers.getContractFactory("FactoryController");
    const factoryController = await FactoryController.deploy();
    await factoryController.deployed();
    console.log("factory deployed:", factoryController.address);
    // router
    const RouterController = await ethers.getContractFactory("RouterController");
    const routerController = await RouterController.deploy();
    await routerController.deployed();
    console.log("router deployed:", routerController.address);
    // dex
    const DexController = await ethers.getContractFactory("DexController");
    const dexController = await DexController.deploy(WETH, ADDRESS_PAYEE);
    await dexController.deployed();
    console.log("dexController deployed:", dexController.address);

    await dexController.setFactoryController(factoryController.address);
    await dexController.setRouterController(routerController.address);
    await routerController.setDexController(dexController.address);
    await factoryController.setDexController(dexController.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });

function getWETH() {
    if (network.name === "rinkeby") {
        return process.env.WETH_RINKEBY;
    }
    if (network.name === "bsctest") {
        return process.env.WETH_BSCTEST;
    }

}
