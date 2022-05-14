const TaskFactory = artifacts.require("TaskFactory");
const Task = artifacts.require("Task");
const utils = require("./helpers/utils");
var Contract = require('web3-eth-contract');
const { assert } = require("console");
//const { assert } = require("console");

Contract.setProvider('ws://localhost:7545');

contract("TaskFactory", (accounts) => {
    let [owner, organizer, other, contractor1, contractor2] = accounts;

    let contractInstance;

    const task1 = {
        "name": "task1",
        "desc": "This is Task1!",
        "budgetPerUnit": 0,
        "progressUnits": 10
    }
    
    const task2 = {
        "name": "task2",
        "desc": "This is Task2!",
        "budgetPerUnit": 0,
        "progressUnits": 2
    }

    beforeEach(async () => {
        contractInstance = await TaskFactory.new({from: owner});
        await contractInstance.addOrganizer(organizer, {from: owner});
    });



    context("Task Creation: Access Rights", async () => {
        it("should create new task because createTask is called by organizer of the TaskFactory contract", async () => {
            const result = await contractInstance.createTask(task1.name, task1.desc, task1.budgetPerUnit, task1.progressUnits,{from: owner});
            const ownerOfTask = await contractInstance.getTaskOwner(0, {from: owner});
            assert(ownerOfTask == owner);
        })
        it("should set owner of task to caller of createTask", async () => {
            const result = await contractInstance.createTask(task1.name, task1.desc, task1.budgetPerUnit, task1.progressUnits,{from: organizer});
            const ownerOfTask = await contractInstance.getTaskOwner(0, {from: organizer});
            //const contractAddress = await contractInstance.getContractAddress();
            assert(ownerOfTask == organizer);
            assert(ownerOfTask != owner);
        })
        it("should NOT create new task because called by other/non-organizer", async () => {
            await utils.shouldThrow(contractInstance.createTask(task1.name, task1.desc, task1.budgetPerUnit, task1.progressUnits,{from: other}));
        })
    })


    context("Task Retrieval through TaskFactory: before assignment", async () => {
        beforeEach(async () => {
            await contractInstance.createTask(task1.name, task1.desc, task1.budgetPerUnit, task1.progressUnits, {from: owner});
            await contractInstance.createTask(task2.name, task2.desc, task2.budgetPerUnit, task2.progressUnits, {from: organizer});
        });

        it("viewAllPostings should return all tasks", async () => {
            const result = await contractInstance.viewAllPostings();
            //console.log( result );
            assert(result.length == 2);
        })

        it("viewOpenPostings should return all unassigned tasks", async () => {
            const result = await contractInstance.viewOpenPostings();
            //console.log( result );
            assert(result.length == 2);
        })

        it("viewOrganizerTask called by owner should return only owner's tasks", async () => {
            const result = await contractInstance.viewOrganizerTasks({from: owner});
            //console.log( result );
            assert(result.length == 1);
        })

        it("viewOrganizerTask called by organizer should return only organizer's tasks", async () => {
            const result = await contractInstance.viewOrganizerTasks({from: organizer});
            //console.log( result );
            assert(result.length == 1);
        })

        it("viewWorkerTasks called by worker should return empty before assignment", async () => {
            const result = await contractInstance.viewWorkerTasks();
            //console.log( result );
            assert(result.length == 0);
        })

    })

    context("Task Retrieval through TaskFactory: after assignment", async () => {
        beforeEach(async () => {
            await contractInstance.createTask(task1.name, task1.desc, task1.budgetPerUnit, task1.progressUnits, {from: owner});
            await contractInstance.createTask(task2.name, task2.desc, task2.budgetPerUnit, task2.progressUnits, {from: owner});
            
            let taskAddress1 = await contractInstance.getTaskById(0);
            let taskInstance1 = await Task.at(taskAddress1);
            await taskInstance1.applyTo({from: contractor1});
            await taskInstance1.acceptApplicant(contractor1, {from: owner});
            await taskInstance1.acceptAssignment({from: contractor1});
            await taskInstance1.updateProgress(task1.progressUnits, {from: owner});
        
        });

        it("viewAllPostings should return all tasks", async () => {
            const result = await contractInstance.viewAllPostings();
            //console.log( result );
            assert(result.length == 2);
        })

        it("viewOpenPostings should return all unassigned tasks", async () => {
            const result = await contractInstance.viewOpenPostings();
            //console.log( result );
            assert(result.length == 1);
        })

        it("viewOrganizerTask called by owner should return only owner's tasks", async () => {
            const result = await contractInstance.viewOrganizerTasks({from: owner});
            //console.log( result );
            assert(result.length == 2);
        })

        it("viewWorkerTasks called by worker should return tasks assigned to worker", async () => {
            const result = await contractInstance.viewWorkerTasks({from: contractor1});
            //console.log( result );
            assert(result.length == 1);
        })

        it("viewWorkerTasks called by worker should not return tasks that are not assigned to worker", async () => {
            const result = await contractInstance.viewWorkerTasks({from: contractor2});
            //console.log( result );
            assert(result.length == 0);
        })

    })

})