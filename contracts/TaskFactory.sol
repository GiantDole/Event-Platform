//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "./OrganizationManager.sol";
import "./Task.sol";



///@title Collection and creation of all task postings
contract TaskFactory is OrganizationManager { 
 
    event TaskPosted(Task _task);
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
        // @Adrian: wouldn't id be implicitly managed through array position?
        // @Hannah: yes, we can probably just manage ids through array push. but leaving it for now.
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
    
    // I don't actually think the below are needed -- use mappings to bool instead as we can loop through tasks array in a public view function that doesn't require gas.
    // uint64[] completedTasks; // array to store past tasks that are already completed (e.g. for tax purposes, etc.)
    // uint64[] ongoingTasks; // array to store ongoing tasks that are currently assigned
    // uint64[] unassignedTasks; // array to store posted tasks that are unassigned, i.e. in need of assignment
    // uint64[] assignedTasks; // array to store posted tasks that are unassigned, i.e. in need of assignment

    // @Adrian: can't these information be held by a task contract? As we create them anyway that might be more memory efficient
    // @Hannah: we may not need these in the end but leaving the ones I'm not positive we DON"T need here for now.
    // mapping(uint64=>bool) isAssigned;
    // mapping(uint64=>bool) isComplete;
    // mapping(uint64=>address) internal assignment; // maps task id to a SINGLE assignee

    // @Adrian: this belongs here; managing tasks!
    //mapping (address => uint64[]) organizerTasks; // maps organizer address to tasks that they are an organizer of
    //mapping (address => uint64[]) workerTasks; // maps worker address to tasks that they are/were assigned to

    ///@notice creates a new task posting
    ///@dev tasks can only be created by an organizer
    ///@dev incrementing idCount depends on overflow protection; only use with Solidity verions >0.8!
    function createTask(string memory _name, string memory _desc, uint64 _budgetPerUnit, uint8 _progressUnits) public onlyOrganizer() returns(uint64 _taskId){
        tasks.push( new Task(_name, _desc, idCount, _budgetPerUnit, _progressUnits) );
        tasks[idCount].transferOwnership(msg.sender);
        // organizerTasks[msg.sender].push(idCount);
        /// withhold budgetPerUnit * progressUnits here
        emit TaskPosted(tasks[idCount]);
        idCount++;
        return idCount-1;
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
            if (tasks[i].isAssigned()) {
                filtArr[currId] = getTaskDetailsById(i);
                currId++;
            }
        }
        TaskDetails[] memory unassignedTaskDetails = new TaskDetails[](currId+1);
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
    ///@dev SHOULD THIS JUST BE DONE ON FRONT-END? I THINK MAYBE!!!
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