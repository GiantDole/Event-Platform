//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./OrganizationManager.sol";


///@title Collection and creation of all job postings

contract JobFactory is OrganizationManager{ // also probably is Payable or whatever our payments contract is

    event JobPosted(uint id);
    event ApplicationCompleted(uint jobId, address applicant);
    event ApplicationWithdrawn(uint jobId, address applicant);
    event ApplicantAccepted(uint jobId, address applicant);
    event JobAssigned(uint jobId, address assignee);
    event ProgressUpdated();
    event ProgressApproved();
    event JobCompleted();

    ///@dev so far a job can have at max 255 hours 
    struct Job {
        string name;
        string desc; // description of job
        uint64 id; //id will be given through index in array -- tbd but we may not actually need this in the job
        uint64 budget; //in wei?
        uint8 time; //time to complete the job in hours
        uint8 percentCompleted;
        bool completed;
    }

    uint64 private idCount;

    Job[] public jobs;
    
    // I don't actually think the below are needed -- use mappings to bool instead as we can loop through jobs array in a public view function that doesn't require gas.
    // uint64[] completedJobs; // array to store past jobs that are already completed (e.g. for tax purposes, etc.)
    // uint64[] ongoingJobs; // array to store ongoing jobs that are currently assigned
    // uint64[] unassignedJobs; // array to store posted jobs that are unassigned, i.e. in need of assignment
    // uint64[] assignedJobs; // array to store posted jobs that are unassigned, i.e. in need of assignment

    // @Adrian: can't these information be held by a job contract? As we create them anyway that might be more memory efficient
    mapping(uint64=>bool) isAssigned;
    mapping(uint64=>bool) isComplete;
    // @Adrian: mapping to an array... hopefully we keep track of the applicant id!
    mapping(uint64=>address[]) internal applicants; // maps job id to applicants for the job
    // @Adrian: why does job id have bytes32 and then uint64 format?
    mapping(bytes32=>bool) internal isApplicant; // maps hash of job id and applicant address to boolean indicating whether the address corresponds to an applicant for the job
    // @Adrian: probably again a mapping for the job contract?
    mapping(uint64=>address) internal approved; // maps job id to a SINGLE approved applicant
    mapping(uint64=>address) internal assignment; // maps job id to a SINGLE assignee

    // @Adrian: this belongs here; managing jobs!
    mapping (address => uint64[]) organizerJobs; // maps organizer address to jobs that they are an organizer of
    mapping (address => uint64[]) workerJobs; // maps worker address to jobs that they are/were assigned to

    ///@notice only allow the job assignee to call the function
    modifier onlyAssignee(_id) {
        require(assignment[_id] == msg.sender, "Callable: caller is not the job assignee");
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
    ///@notice internal function creating jobs for potential calls in other places
    ///@dev may not need in the end 
    function _createJob() internal {
    }

    /* TO DO */
    ///@notice checks that owner is good for budget and witholds the budget
    ///@dev this may end up being done completely in the PaymentSplitter?
    function _withholdBudget() internal { 
    }

    ///@notice creates a new job posting
    ///@dev jobs can only be created by an organizer
    ///@dev incrementing idCount depends on overflow protection; only use with Solidity verions >0.8!
    function createJob(string memory _name, uint64 _budget, uint8 _time) public onlyOrganizer() {
        idCount++;
        jobs.push(Job(_name, idCount, _budget, _time, 0, false));
        organizerJobs[msg.sender].push(idCount);
        // call withholdBudget here
        emit JobPosted(jobs.length-1);
    }

    ///@notice view ALL job postings, past and present
    function viewAllPostings() public view returns(Job[] jobs){
        return jobs;
    }

    ///@notice view open postings that have not been assigned yet
    function viewOpenPostings() public view returns(Job[] unassigned_jobs){
        //for job in 
    }

    ///@notice apply to accept a job
    function applyToJob(uint64 _id) public {
        applicants[_id] = msg.sender;
        keccak256(abi.encode(_id, msg.sender))] == 1;
        emit ApplicationCompleted(_id, msg.sender);
    }

    ///@notice view applicants for a job
    ///@dev only an organizer of the job can do so
    ///@dev public view function -- no gas needed
    function viewApplicants(uint64 _id) public view onlyOrganizer() returns (address[] _applicants) {
        return applicants[_id];
    }

    //@notice accept job Applicant
    function acceptApplicant(uint64 _id, address _applicant) public onlyOrganizer() {
        require(isApplicant[keccak256(abi.encode(_id, _applicant))] == 1, "Callable: input address is not an existing applicant and therefore cannot be accepted.");
        approved[_id] = _applicant;
        emit ApplicantAccepted(_id, _applicant);
    }

    ///@notice accept job assignment
    ///@dev jobs can only be accepted by approved applicants
    function acceptAssignment(uint64 _id) public onlyApproved(_id) { 
        assignment[_id] = msg.sender;
        workerJobs[msg.sender].push(_id);
        emit JobAssigned(_id, msg.sender);
    }

}