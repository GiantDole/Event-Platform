const express = require('express');
const Web3 = require('web3');
const app = express();
const path = require('path');
const router = express.Router();
const port = 3000;
const HDWalletProvider = require("@truffle/hdwallet-provider");
const bodyParser = require("body-parser");
const Task_JSON = require("./build/contracts/Task.json");
const TaskFactory_JSON = require("./build/contracts/TaskFactory.json");

let provider = new HDWalletProvider({
  mnemonic: {
    phrase: "despair clown moral report frame sheriff ill board matrix gallery equal shoulder"
  },
  providerOrUrl: "http://18.182.45.18:8765/"
});

let web3 = new Web3(provider);


const abi = TaskFactory_JSON.abi;

const abi_task = Task_JSON.abi;

const address ="0x4B4304A9B8F3d83f7F735340b0c55b96512794B2";

const taskFactory_contract = new web3.eth.Contract(abi, address);

router.get('/',function(req,res){
  res.sendFile(path.join(__dirname+'/src/index.html'));
  //__dirname : It will resolve to your project folder.
});

router.get('/index.js',function(req,res){
    res.sendFile(path.join(__dirname+'/src/index.js'));
    //__dirname : It will resolve to your project folder.
});

app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

router.post('/newTask',function(req,res){
    //string memory _name, string memory _desc, uint64 _budgetPerUnit, uint8 _progressUnits
  taskFactory_contract.methods.createTask(req.body.name.toString(), "None", parseInt(req.body.apu), parseInt(req.body.units)).send(
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
      res.send(id);
  });
});

router.post('/syncTasks', function(req, res) {
  taskFactory_contract.methods.viewAllPostings().call()
  .then( function (receipt) {
    console.log(receipt);
    res.send(receipt);
    //let ret = [];
    
    /*for(let i=0; i<receipt.length; i++){
      let next_contract = receipt[i];
      let task_contract = new web3.eth.Contract(abi_task, next_contract);
      let name = "";
      task_contract.methods.name().call()
      .then(function(result){
        res.send(result);
      });
      console.log(ret);
      res.send(ret);
    }*/
  })
});

app.use('/', router);


app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
});
