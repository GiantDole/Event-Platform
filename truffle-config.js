const HDWalletProvider = require('@truffle/hdwallet-provider');
const privateKey= require('./secrets.json').privateKey;
//const mnemonic = require('./secrets.json').mnemonic;
//const privateKey = "486F64B006D7B00301164A6C5DB0BE3290E7528A1322FBAF6A2B74226BC9ABF3";
const mnemonic = "despair clown moral report frame sheriff ill board matrix gallery equal shoulder";

    

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*"
    },

    huygen_dev: {
      //https://test-huygens.computecoin.info/
      //provider: () => new HDWalletProvider([privateKey], `https://test-huygens.computecoin.info/`),
      //provider: () => new HDWalletProvider([privateKey], `http://18.182.45.18:8765/`),
      provider: () => new HDWalletProvider([privateKey], `http://18.182.45.18:8765/`),
      network_id: 828,
      //confirmations: 10,
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
      version: "^0.8.0"
    }
 }
};