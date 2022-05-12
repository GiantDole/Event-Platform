const TaskFactory = artifacts.require("TaskFactory");
const Task = artifacts.require("Task");
const utils = require("./helpers/utils");
var Contract = require('web3-eth-contract');

Contract.setProvider('ws://localhost:7545');

contract("TaskFactory", (accounts) => {
    let [owner, organizer, taskowner, other, applicantone, applicanttwo] = accounts;

    let contractInstance;

    const task1 = {
        "name": "task1",
        "desc": "This is Task1!",
        "budgetPerUnit": 5,
        "progressUnits": 10
    }
    
    const task2 = {
        "name": "task2",
        "desc": "This is Task2!",
        "budgetPerUnit": 100,
        "progressUnits": 2
    }

    beforeEach(async () => {
        contractInstance = await TaskFactory.new({from: owner});
    });

    xcontext("Task Creation: Access Rights", async () => {
        it("should create new task because called by organizer", async () => {
            //await contractInstance.addOrganizer(organizer, {from: owner});
            const result = await contractInstance.createTask(task1.name, task1.desc, task1.budgetPerUnit, task1.progressUnits,{from: owner});
            //const taskContract = new web3.eth.Contract(Task.abi, ownerTaskAddress)
            const ownerOfTask = await contractInstance.getTaskOwner(0, {from: owner});
            const contractAddress = await contractInstance.getContractAddress();
    
            assert(ownerOfTask == contractAddress);
        })

        it("should NOT create new task because called by other", async () => {
            await utils.shouldThrow(contractInstance.createTask(task1.name, task1.desc, task1.budgetPerUnit, task1.progressUnits,{from: other}));
        })

        it("should set owner of task to JobFactory address", async () => {
            const result = await contractInstance.createTask(task1.name, task1.desc, task1.budgetPerUnit, task1.progressUnits,{from: owner});
            //const taskContract = new web3.eth.Contract(Task.abi, ownerTaskAddress)
            const ownerOfTask = await contractInstance.getTaskOwner(0, {from: owner});
            const contractAddress = await contractInstance.getContractAddress();
    
            assert(ownerOfTask == contractAddress,"owner of the contract is not Task Factory");
        })
    })



    xit("should set owner of task to job creator", async () => {
        const result = await contractInstance.createTask(task1.name, task1.desc, task1.budgetPerUnit, task1.progressUnits, {from: other});
        //const taskContract = new web3.eth.Contract(Task.abi, ownerTaskAddress)
        const ownerOfTask = await contractInstance.getTaskOwner(0, {from: owner});
        const contractAddress = await contractInstance.getContractAddress();

        assert(ownerOfTask == other);
    })


    xcontext("Task Interaction through TaskFactory", async () => {
        let addressTask1;
        let addressTask2;
        beforeEach(async () => {
            //const result = await contractInstance.createTask(task1.name, task1.desc, task1.budgetPerUnit, task1.progressUnits, {from: owner});
            //const taskAddress = await result.logs[2].args.from;
            //var task = await new web3.eth.Contract(Task.abi, taskAddress);
            //task = TaskContract.at(taskAddress);
            //task.options.address = taskAddress;
            await contractInstance.addOrganizer(organizer, {from: owner});
            await contractInstance.createTask(task1.name, task1.desc, task1.budgetPerUnit, task1.progressUnits, {from: owner});
            await contractInstance.createTask(task2.name, task2.desc, task2.budgetPerUnit, task2.progressUnits, {from: organizer});
            //addressTask1 = contractInstance.getContractAddress(0);
            //addressTask2 = contractInstance.getContractAddress(1);
        });

        xit("should return all tasks", async () => {
            const result = contractInstance.viewAllPostings().then(function (value) {
                console.log(value);
            });
            assert(result.length == 2)
        });

    })

    
    xcontext("Task Creation: direct assignment", async () => {
        xit("should create a new task with assigned contractor", async () => {

        })
    })

    xcontext("Job Assigning", async () => {

    })

}) 