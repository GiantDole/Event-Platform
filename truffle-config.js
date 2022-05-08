const HDWalletProvider = require('@truffle/hdwallet-provider');
const privateKey= require('./secrets.json').privateKey;
const mnemonic = require('./secrets.json').mnemonic;

    

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*"
    },

    huygen_dev: {
      provider: () => new HDWalletProvider([privateKey], `http://18.182.45.18:8765/,`),
      network_id: 804,
      confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true
    },

    matic: {
      provider: () => new HDWalletProvider(mnemonic, `https://rpc-mumbai.maticvigil.com`),
      network_id: 80001,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true
    }
  },
  compilers: {
    solc: {
      version: "^0.8.6"
    }
 }
};