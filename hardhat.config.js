require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  networks: {
    hardhat: {
      forking: {
        url: "https://eth-mainnet.g.alchemy.com/v2/1pY6SgHEIf_6Wy52HqFNz9de6qt2xuPQ",
        blockNumber: 16213847
      }
    }
  }
};
