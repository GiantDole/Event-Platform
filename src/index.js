//import HDWalletProvider from '@truffle/hdwallet-provider';

const create_button = document.getElementById("create-button").addEventListener ("click", createTask, false);
const name_input = document.getElementById("name-input");
const units_input = document.getElementById("units-input");
const amount_per_unit_input = document.getElementById("amount-input");
const date_input = document.getElementById("date-input");
const task_list = document.getElementById("task-list");
const update_button = document.getElementById("update-button").addEventListener ("click", updateTaskList, false);

function createTask() {
    let name = name_input.value;
    let units = parseFloat(units_input.value);
    let amount_per_unit = parseFloat(amount_per_unit_input.value);
    let date = date_input.value;
  
    axios.post('/newTask', {
      name: name,
      units: units,
      apu: amount_per_unit,
      date: date
    })
    .then((response) => {
      console.log(response);
    }, (error) => {
      console.log(error);
    });
}

function updateTaskList() {
    axios.post('/syncTasks', {})
    .then((response) => {
      console.log(response);
      for(let i=0; i<response.data.length;i++) {
        var li = addLi(response.data[i]);
        task_list.appendChild(li);
      }
    }, (error) => {
      console.log(error);
    });
}

function getTaskInfo() {

}

function addLi(inp) {
    //var name = inp.name;
    //var contract = inp.contract;

    var li = document.createElement('li');
    li.appendChild(document.createTextNode(inp));
    li.innerHTML += ' <button class="btn btn-primary">Accept Applicant</button> &nbsp\n';
    li.innerHTML += '<button class="btn btn-primary">Withdraw Applicant</button> &nbsp';
    //li.appendChild(document.createTextNode(contract));
    return li;
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
