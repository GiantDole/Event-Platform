const TaskFactory = artifacs.require("TaskFactory");
const utils = require("./helpers/utils");

contract("TaskFactory", (accounts) => {
    let [owner, organizer, other] = accounts;

    let contractInstance;

    const task1 = {
        "name": "task1",
        "desc": "This is Task1!",
        "budgetPerUnit": 5,
        "progressUnits": 10
    }

    beforeEach(async () => {
        contractInstance = await TaskFactory.new({from: owner});
    });

    it("should set owner of task correctly", async () => {
        const ownerTask = contractInstance.createTask(task1.name, task1.desc, task1.budgetPerUnit, task1.progressUnits);
        const ownerOfTask = ownerTask.isOwner(owner);
        assert(ownerOfTask == true);
    })

    xcontext("Task Creation", async () => {
        xit("should create a new task open for applicaton", async () => {
            const ownerTask = contractInstance.createTask(task1.name, task1.desc, task1.budgetPerUnit, task1.progressUnits);
            
        })

        xit("should create a new task with assigned contractor", async () => {

        })
    })

    xcontext("Job Assigning", async () => {

    })

}) 