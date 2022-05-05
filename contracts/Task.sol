//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./OrganizationManager.sol";


///@title Collection and creation of all task postings

contract TaskFactory is OrganizationManager{ // also probably is Payable or whatever our payments contract is

    event TaskPosted(uint id);
    event ApplicationCompleted(uint taskId, address applicant);
    event ApplicationWithdrawn(uint taskId, address applicant);
    event ApplicantAccepted(uint taskId, address applicant);
    event TaskAssigned(uint taskId, address assignee);
    event ProgressUpdated();
    event ProgressApproved();
    event TaskCompleted();

    string name;
    string desc; // description of task
    uint64 id; //id will be given through index in array -- tbd but we may not actually need this in the task
    uint64 budget; //in wei?
    uint8 time; //time to complete the task in hours: uint8 means task can have at most 255 hours
    
    uint8 percentCompleted;

    bool completed;

    uint64 private idCount;

    Task[] public tasks;
    
    // I don't actually think the below are needed -- use mappings to bool instead as we can loop through tasks array in a public view function that doesn't require gas.
    // uint64[] completedTasks; // array to store past tasks that are already completed (e.g. for tax purposes, etc.)
    // uint64[] ongoingTasks; // array to store ongoing tasks that are currently assigned
    // uint64[] unassignedTasks; // array to store posted tasks that are unassigned, i.e. in need of assignment
    // uint64[] assignedTasks; // array to store posted tasks that are unassigned, i.e. in need of assignment

    // @Adrian: can't these information be held by a task contract? As we create them anyway that might be more memory efficient
    mapping(uint64=>bool) isAssigned;
    mapping(uint64=>bool) isComplete;
    // @Adrian: mapping to an array... hopefully we keep track of the applicant id!
    mapping(uint64=>address[]) internal applicants; // maps task id to applicants for the task
    // @Adrian: why does task id have bytes32 and then uint64 format?
    mapping(bytes32=>bool) internal isApplicant; // maps hash of task id and applicant address to boolean indicating whether the address corresponds to an applicant for the task
    // @Adrian: probably again a mapping for the task contract?
    mapping(uint64=>address) internal approved; // maps task id to a SINGLE approved applicant
    mapping(uint64=>address) internal assignment; // maps task id to a SINGLE assignee

    // @Adrian: this belongs here; managing tasks!
    mapping (address => uint64[]) organizerTasks; // maps organizer address to tasks that they are an organizer of
    mapping (address => uint64[]) workerTasks; // maps worker address to tasks that they are/were assigned to

    ///@notice only allow the task assignee to call the function
    modifier onlyAssignee(_id) {
        require(assignment[_id] == msg.sender, "Callable: caller is not the task assignee");
        _;
    }

    ///@notice only allow an approved applicant to call the function
    modifier onlyApproved(_id) {
        require(approved[_id] == msg.sender, "Callable: caller's application has not been approved");
        _;
    }

    ///@notice constructor to instantiate the contract
    ///@dev for now, all we have to do is set idCount to 0
    constructor() {
        // @Adrian: wouldn't id be implicitly managed through array position?
       idCount = 0;
    }

    /* TO DO */
    ///@notice internal function creating tasks for potential calls in other places
    ///@dev may not need in the end 
    function _createTask() internal {
    }

    /* TO DO */
    ///@notice checks that owner is good for budget and witholds the budget
    ///@dev this may end up being done completely in the PaymentSplitter?
    function _withholdBudget() internal { 
    }

    ///@notice creates a new task posting
    ///@dev tasks can only be created by an organizer
    ///@dev incrementing idCount depends on overflow protection; only use with Solidity verions >0.8!
    function createTask(string memory _name, uint64 _budget, uint8 _time) public onlyOrganizer() {
        idCount++;
        tasks.push(Task(_name, idCount, _budget, _time, 0, false));
        organizerTasks[msg.sender].push(idCount);
        // call withholdBudget here
        emit TaskPosted(tasks.length-1);
    }

    ///@notice view ALL task postings, past and present
    function viewAllPostings() public view returns(Task[] tasks){
        return tasks;
    }

    ///@notice view open postings that have not been assigned yet
    function viewOpenPostings() public view returns(Task[] unassigned_tasks){
        //for task in 
    }

    ///@notice apply to accept a task
    function applyToTask(uint64 _id) public {
        applicants[_id] = msg.sender;
        keccak256(abi.encode(_id, msg.sender))] == 1
        emit ApplicationCompleted(_id, msg.sender);
    }

    ///@notice view applicants for a task
    ///@dev only an organizer of the task can do so
    ///@dev public view function -- no gas needed
    function viewApplicants(uint64 _id) public view onlyOrganizer() returns (address[] _applicants) {
        return applicants[_id];
    }

    //@notice accept task Applicant
    function acceptApplicant(uint64 _id, address _applicant) public onlyOrganizer() {
        require(isApplicant[keccak256(abi.encode(_id, _applicant))] == 1, "Callable: input address is not an existing applicant and therefore cannot be accepted.");
        approved[_id] = _applicant;
        emit ApplicantAccepted(_id, _applicant);
    }

    ///@notice accept task assignment
    ///@dev tasks can only be accepted by approved applicants
    function acceptAssignment(uint64 _id) public onlyApproved(_id) { 
        assignment[_id] = msg.sender;
        workerTasks[msg.sender].push(_id);
        emit TaskAssigned(_id, msg.sender);
    }

}