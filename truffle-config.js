const HDWalletProvider = require('@truffle/hdwallet-provider')
require('dotenv').config()

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*"
    },
    rinkeby: {
      provider: () => new HDWalletProvider(process.env.MNEMONIC, "https://rinkeby.infura.io/v3/" + process.env.INFURA_PROJECT_ID),
      network_id: '4',
      networkCheckTimeout: '10000',
      skipDryRun: true
    },
    mumbai: {
      provider: () => new HDWalletProvider(process.env.MNEMONIC, "https://polygon-mumbai.infura.io/v3/" + process.env.INFURA_PROJECT_ID),
      network_id: '80001'
    }
  },
  compilers: {
    solc: {
      version: '0.7.5',
    },
  },
  api_keys: {
    etherscan: process.env.ETHERSCAN_API_KEY
  },
  plugins: [
    'truffle-plugin-verify'
  ]
};
