require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require('hardhat-contract-sizer');
require("dotenv").config();


const SECRET_DEPLOYER = process.env.SECRET_DEPLOYER;


/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.6.6",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      }
    ]
  },
  networks: {
    rinkeby: {
      url: process.env.URL_RINKEBY,
      accounts: [SECRET_DEPLOYER]
    },
    bsctest: {
      url: process.env.URL_BSCTEST,
      chainId: 97,
      accounts: [SECRET_DEPLOYER]
    }
  },
  contractSizer: {
    alphaSort: true,
    disambiguatePaths: false,
    runOnCompile: true,
    strict: true,
    only: [],
  },

  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: ""
  }
};
