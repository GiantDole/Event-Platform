//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "./OrganizationManager.sol";
import "./Task.sol";



///@title Collection and creation of all task postings
contract TaskFactory is OrganizationManager { 
 
    event TaskPosted(Task _task);

    uint64 private idCount;

    ///@notice constructor to instantiate the contract
    ///@dev for now, all we have to do is set idCount to 0
    constructor() {
        idCount=0;
    }

    Task[] private tasks;

    struct TaskDetails {

        string name;
        string desc; // description of task
        uint64 id; //id will be given through index in array -- tbd but we may not actually need this in the task
        uint64 budgetPerUnit; //in wei?
        uint16 progressUnits; // total units of progress that the task involves

        uint16 completedUnits;
        uint16 approvedUnits; // total units of progress that has been approved by the organizer for payment
        bool isAssigned;
    }
    ///@notice creates a new task posting
    ///@dev tasks can only be created by an organizer
    ///@dev incrementing idCount depends on overflow protection; only use with Solidity verions >0.8!
    function createTask(string memory _name, string memory _desc, uint64 _budgetPerUnit, uint8 _progressUnits) 
        public 
        onlyOrganizer()
        payable 
    {
        require(msg.value >= _budgetPerUnit*_progressUnits,"Caller : Insufficent fund transferred") ;
        Task newContract = new Task(_name, _desc, idCount, _budgetPerUnit, _progressUnits) ;

        (bool paidContract,) = payable(address(newContract)).call{value: _budgetPerUnit*_progressUnits }("");
        (bool repaidOrganizer,)= payable(address(msg.sender)).call{value: msg.value - _budgetPerUnit*_progressUnits }("");

        tasks.push( newContract );
        tasks[idCount].transferOwnership(msg.sender);
        // organizerTasks[msg.sender].push(idCount);
        /// withhold budgetPerUnit * progressUnits here
        emit TaskPosted(tasks[idCount]);
        idCount++;
    }

    //@notice retrieve task details by id
    function getTaskDetailsById(uint64 _id) public view returns(TaskDetails memory _taskDetails){
        TaskDetails memory taskDetails = TaskDetails( 
            tasks[_id].name(), tasks[_id].desc(), tasks[_id].id(), 
            tasks[_id].budgetPerUnit(), tasks[_id].progressUnits(), tasks[_id].completedUnits(), tasks[_id].approvedUnits(), 
            tasks[_id].isAssigned() 
            );
        return taskDetails;
    }

    //@notice retrieve task details by id
    function getTaskById(uint64 _id) public view returns(Task _task){
        return tasks[_id];
    }

    function getTaskOwner(uint64 _id) public view returns(address){
        return tasks[_id].owner();
    }

    ///@notice view ALL task postings, past and present
    function viewAllPostings() public view returns(TaskDetails[] memory _taskDetailsArr){
        TaskDetails[] memory taskDetailsArr = new TaskDetails[](tasks.length);
        for (uint64 i; i < tasks.length; i++) {
            taskDetailsArr[i] = getTaskDetailsById(i);
        }
        return taskDetailsArr;
    }

    ///@notice view open postings that have not been assigned yet
    ///@dev SHOULD THIS JUST BE DONE ON FRONT-END? I THINK MAYBE!!!
    function viewOpenPostings() public view returns(TaskDetails[] memory _unassignedTaskDetails){
        TaskDetails[] memory filtArr = new TaskDetails[](tasks.length);
        uint64 currId = 0;
        for (uint64 i; i < tasks.length; i++) {
            if (!tasks[i].isAssigned()) {
                filtArr[currId] = getTaskDetailsById(i);
                currId++;
            }
        }
        TaskDetails[] memory unassignedTaskDetails = new TaskDetails[](currId);
        for (uint64 j = 0; j < unassignedTaskDetails.length; j++) {
            unassignedTaskDetails[j] = filtArr[j];
        }      
        return unassignedTaskDetails;
    }

    ///@notice view organizer tasks
    ///@dev SHOULD THIS JUST BE DONE ON FRONT-END? I THINK MAYBE!!!
    function viewOrganizerTasks() public view returns(TaskDetails[] memory _organizerTaskDetails){
        TaskDetails[] memory filtArr = new TaskDetails[](tasks.length);
        uint64 currId = 0;
        for (uint64 i; i < tasks.length; i++) {
            if (tasks[i].isOrganizer(msg.sender)) {
                filtArr[currId] = getTaskDetailsById(i);
                currId++;
            }
        }
        TaskDetails[] memory organizerTaskDetails = new TaskDetails[](currId);
        for (uint64 j = 0; j < organizerTaskDetails.length; j++) {
            organizerTaskDetails[j] = filtArr[j];
        }      
        return organizerTaskDetails;
    }

    ///@notice view worker tasks
    function viewWorkerTasks() public view returns(TaskDetails[] memory _workerTaskDetails){
        TaskDetails[] memory filtArr = new TaskDetails[](tasks.length);
        uint64 currId = 0;
        for (uint64 i; i < tasks.length; i++) {
            if (tasks[i].assignment() == msg.sender) {
                filtArr[currId] = getTaskDetailsById(i);
                currId++;
            }
        }
        TaskDetails[] memory workerTaskDetails = new TaskDetails[](currId);
        for (uint64 j = 0; j < workerTaskDetails.length; j++) {
            workerTaskDetails[j] = filtArr[j];
        }      
        return workerTaskDetails;
    }

    function getContractAddress() public view returns(address contractAddress){
        return address(this);
    }
}
