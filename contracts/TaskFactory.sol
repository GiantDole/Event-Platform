//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./OrganizationManager.sol";
import "./Task.sol";



///@title Collection and creation of all task postings
contract TaskFactory is OrganizationManager { 
 
    event TaskPosted(uint taskId);
    event TaskApplicationCompleted(uint taskId, address applicant);
    event TaskApplicationWithdrawn(uint taskId, address applicant);
    event TaskApplicantAccepted(uint taskId, address applicant);
    event TaskAssigned(uint taskId, address assignee);
    // event ProgressUpdated();
    // event ProgressApproved();
    event TaskCompleted();

    uint64 private idCount;

    ///@notice constructor to instantiate the contract
    ///@dev for now, all we have to do is set idCount to 0
    constructor() {
        idCount=0;
    }

    Task[] private tasks;

    ///@notice creates a new task posting
    ///@dev tasks can only be created by an organizer
    ///@dev incrementing idCount depends on overflow protection; only use with Solidity verions >0.8!
    function createTask(string memory _name, string memory _desc, uint64 _budgetPerUnit, uint8 _progressUnits) public onlyOrganizer() {
        tasks.push( new Task(_name, _desc, idCount, _budgetPerUnit, _progressUnits) );
        tasks[idCount].transferOwnership(msg.sender);
        // organizerTasks[msg.sender].push(idCount);
        /// withhold budgetPerUnit * progressUnits here
        emit TaskPosted(idCount);
        idCount++;
    }

    ///@notice view ALL task postings, past and present
    function viewAllPostings() public view returns(Task[] memory _tasks){
        return tasks;
    }

    function getTaskOwner(uint _id) public view returns(address){
        return tasks[_id].owner();
    }

    ///@notice view open postings that have not been assigned yet
    ///@dev SHOULD THIS JUST BE DONE ON FRONT-END? I THINK MAYBE!!!
    function viewOpenPostings() public view returns(Task[] memory _unassignedTasks){
        Task[] memory filtTasks = new Task[](tasks.length);
        uint16 currId = 0;
        for (uint i; i < tasks.length; i++) {
            if (tasks[i].isAssigned()) {
                filtTasks[currId] = tasks[i];
                currId++;
            }
        }
        Task[] memory unassignedTasks = new Task[](currId+1);
        for (uint j = 0; j < unassignedTasks.length; j++) {
            unassignedTasks[j] = filtTasks[j];
        }      
        return unassignedTasks;
    }

    ///@notice view organizer tasks
    ///@dev SHOULD THIS JUST BE DONE ON FRONT-END? I THINK MAYBE!!!
    function viewOrganizerTasks() public view returns(Task[] memory _organizerTasks){
        Task[] memory filtTasks = new Task[](tasks.length);
        uint16 currId = 0;
        for (uint i; i < tasks.length; i++) {
            if (tasks[i].isOrganizer(msg.sender)) {
                filtTasks[currId] = tasks[i];
                currId++;
            }
        }
        Task[] memory organizerTasks = new Task[](currId);
        for (uint j = 0; j < organizerTasks.length; j++) {
            organizerTasks[j] = filtTasks[j];
        }      
        return organizerTasks;
    }

    ///@notice view worker tasks
    ///@dev SHOULD THIS JUST BE DONE ON FRONT-END? I THINK MAYBE!!!
    function viewWorkerTasks() public view returns(Task[] memory _workerTasks){
        Task[] memory filtTasks = new Task[](tasks.length);
        uint16 currId = 0;
        for (uint i; i < tasks.length; i++) {
            if (tasks[i].assignment() == msg.sender) {
                filtTasks[currId] = tasks[i];
                currId++;
            }
        }
        Task[] memory workerTasks = new Task[](currId);
        for (uint j = 0; j < workerTasks.length; j++) {
            workerTasks[j] = filtTasks[j];
        }      
        return workerTasks;
    }

    function getContractAddress() public view returns(address contractAddress){
        return address(this);
    }

    ///@notice apply to accept a task
    // function applyToTask(uint64 _id) public {
    //     tasks[_id].applyTo(msg.sender);
    //     emit TaskApplicationCompleted(_id, msg.sender);
    // }

    ///@notice withdraw application to task
    // function withdrawTaskApplication(uint64 _id) public {
    //     tasks[_id].withdrawApplication(msg.sender);
    //     emit TaskApplicationWithdrawn(_id, msg.sender);
    // }

    ///@notice view applicants for a task
    ///@dev only an organizer of the task can do so
    ///@dev public view function -- no gas needed
    // function viewApplicants(uint64 _id) public view returns (address[] memory _applicants) {
    //     return tasks[_id].viewApplicants();
    // }

    //@notice accept task Applicant
    // function acceptTaskApplicant(uint64 _id, address _applicant) public {
    //     tasks[_id].acceptApplicant(_applicant);
    //     emit TaskApplicantAccepted(_id, _applicant);
    // }

    ///@notice accept task assignment
    ///@dev tasks can only be accepted by approved applicants
    // function acceptTaskAssignment(uint64 _id) public { 
    //     tasks[_id].acceptAssignment(msg.sender);
    //     workerTasks[msg.sender].push(_id);
    //     emit TaskAssigned(_id, msg.sender);
    // }

}