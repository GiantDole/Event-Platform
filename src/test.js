const Web3 = require("web3");
const HDWalletProvider = require("@truffle/hdwallet-provider")

let provider = new HDWalletProvider({
  mnemonic: {
    phrase: "despair clown moral report frame sheriff ill board matrix gallery equal shoulder"
  },
  providerOrUrl: "http://18.182.45.18:8765/"
});

//let Web3 = require('web3');

//let url_ganache = "HTTP://127.0.0.1:7545";

//let url_infura = "https://goerli.infura.io/v3/640740014bef4bfea63a08591e6af1c9";

//use this for queries
//let url_eth_mainnet = "https://mainnet.infura.io/v3/640740014bef4bfea63a08591e6af1c9";
//use this for subscriptions
//let url_eth_mainnet = "wss://mainnet.infura.io/ws/v3/640740014bef4bfea63a08591e6af1c9";
//let url_huygen_dev = "http://18.182.45.18:8765/";

let web3 = new Web3(provider);
//let web3 = new Web3(url_eth_mainnet);

//console.log(web3);
const abi = [
    {
      "inputs": [],
      "stateMutability": "nonpayable",
      "type": "constructor"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "address",
          "name": "organizer",
          "type": "address"
        }
      ],
      "name": "OrganizerAdded",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "address",
          "name": "organizer",
          "type": "address"
        }
      ],
      "name": "OrganizerRemoved",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "address",
          "name": "previousOwner",
          "type": "address"
        },
        {
          "indexed": true,
          "internalType": "address",
          "name": "newOwner",
          "type": "address"
        }
      ],
      "name": "OwnershipTransferred",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "taskId",
          "type": "uint256"
        },
        {
          "indexed": false,
          "internalType": "address",
          "name": "applicant",
          "type": "address"
        }
      ],
      "name": "TaskApplicantAccepted",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "taskId",
          "type": "uint256"
        },
        {
          "indexed": false,
          "internalType": "address",
          "name": "applicant",
          "type": "address"
        }
      ],
      "name": "TaskApplicationCompleted",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "taskId",
          "type": "uint256"
        },
        {
          "indexed": false,
          "internalType": "address",
          "name": "applicant",
          "type": "address"
        }
      ],
      "name": "TaskApplicationWithdrawn",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "taskId",
          "type": "uint256"
        },
        {
          "indexed": false,
          "internalType": "address",
          "name": "assignee",
          "type": "address"
        }
      ],
      "name": "TaskAssigned",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [],
      "name": "TaskCompleted",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "internalType": "contract Task",
          "name": "_task",
          "type": "address"
        }
      ],
      "name": "TaskPosted",
      "type": "event"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "_organizer",
          "type": "address"
        }
      ],
      "name": "addOrganizer",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "_organizer",
          "type": "address"
        }
      ],
      "name": "isOrganizer",
      "outputs": [
        {
          "internalType": "bool",
          "name": "",
          "type": "bool"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "owner",
      "outputs": [
        {
          "internalType": "address",
          "name": "",
          "type": "address"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "_organizer",
          "type": "address"
        }
      ],
      "name": "removeOrganizer",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "renounceOwnership",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "newOwner",
          "type": "address"
        }
      ],
      "name": "transferOwnership",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "string",
          "name": "_name",
          "type": "string"
        },
        {
          "internalType": "string",
          "name": "_desc",
          "type": "string"
        },
        {
          "internalType": "uint64",
          "name": "_budgetPerUnit",
          "type": "uint64"
        },
        {
          "internalType": "uint8",
          "name": "_progressUnits",
          "type": "uint8"
        }
      ],
      "name": "createTask",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "viewAllPostings",
      "outputs": [
        {
          "internalType": "contract Task[]",
          "name": "_tasks",
          "type": "address[]"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "_id",
          "type": "uint256"
        }
      ],
      "name": "getTaskOwner",
      "outputs": [
        {
          "internalType": "address",
          "name": "",
          "type": "address"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "viewOpenPostings",
      "outputs": [
        {
          "internalType": "contract Task[]",
          "name": "_unassignedTasks",
          "type": "address[]"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "viewOrganizerTasks",
      "outputs": [
        {
          "internalType": "contract Task[]",
          "name": "_organizerTasks",
          "type": "address[]"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "viewWorkerTasks",
      "outputs": [
        {
          "internalType": "contract Task[]",
          "name": "_workerTasks",
          "type": "address[]"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "getContractAddress",
      "outputs": [
        {
          "internalType": "address",
          "name": "contractAddress",
          "type": "address"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    }
  ];
const address ="0x4B4304A9B8F3d83f7F735340b0c55b96512794B2";

const taskFactory_contract = new web3.eth.Contract(abi, address);


//Querying balance:
/*let address = "0x00000000219ab540356cBB839Cbe05303d7705Fa";
web3.eth.getBalance(address, function(error, balance){
    if(!error){
        console.log(web3.utils.fromWei(balance));
    } else {
        console.log(error);
    }
});*/

//Creating wallet
/*let wallet = web3.eth.accounts.wallet.create(2, "my little pony");

let account = web3.eth.accounts.create();

wallet.add(account.privateKey);

console.log(wallet);*/

//Get Current Block Number and Query Block
/*web3.eth.getBlockNumber().then((result) => {
    console.log(result);
    web3.eth.getBlock(result).then((block) => {
        console.log(block);
    })
})*/

//Subscribe to block mining, pending Transactions,

/*web3.eth.subscribe("newBlockHeaders", (error, blockheader) => {
    if(!error) {
        console.log(blockheader);
    } else {
        console.log(error);
    }
})

web3.eth.subscribe("pendingTransactions", (error, txhash) => {
    console.log(txhash);
})*/

//Event Listener for:
//event TaskApplicationCompleted(uint taskId, address applicant);

/*application_completed_event = "TaskApplicationCompleted(uint, address)";
application_completed_event_hashed = web3.utils.sha3(application_completed_event);

console.log(application_completed_event_hashed);*/

web3.eth.getBalance(web3.currentProvider.addresses[0], function(error, balance){
  if(!error){
      console.log(web3.utils.fromWei(balance));
  } else {
      console.log(error);
  }
})

taskFactory_contract.methods.owner().call()
.then(function(result) {
  console.log(result);
})

taskFactory_contract.methods.viewAllPostings().call()
.then(function(result) {
  console.log(result);
})

//console.log(web3.currentProvider.addresses[0]);

taskFactory_contract.methods.createTask("Name", "None", 14, 20).send(
  {
      from: web3.currentProvider.addresses[0]
  }
)
.on('transactionHash', function(hash){
  console.log(hash);
})
.on('confirmation', function(confirmationNumber, receipt){
  console.log(confirmationNumber);
})
.on("TaskPosted", (id) => {
  console.log(id);
});

function createTask() {
    let name = name_input.value;
    let units = parseFloat(units_input.value);
    let amount_per_unit = parseFloat(amount_per_unit_input.value);
    let date = date_input.value;

    console.log(web3);

    //string memory _name, string memory _desc, uint64 _budgetPerUnit, uint8 _progressUnits
    taskFactory_contract.methods.createTask(name, "None", Math.round(amount_per_unit), Math.round(units)).send(
        {
            from: web3.currentProvider.selectedAddress,
        }
    )
    .on("TaskPosted", (id) => {
        console.log(id);
    });
}

function login() {
    if (window.web3) {
        window.web3 = new Web3(window.web3.currentProvider);
        window.ethereum.enable();
        console.log("logged in");
    }
    else {
        console.log("not logged in");
    }
  }