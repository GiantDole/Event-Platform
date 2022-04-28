//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./OrganizationManager.sol";


///@title Collection and creation of all job postings

contract JobFactory is OrganizationManager{

    event JobPosted(uint id);
    event ApplicationCompleted();
    event ApplicantAccepted();
    event JobAssigned();
    event ProgressUpdated();
    event ProgressApproved();
    event JobCompleted();

    ///@dev so far a job can have at max 255 hours 
    struct Job {
        string name;
        //uint64 id; id will be given through index in array
        uint64 budget; //in wei?
        uint8 time; //time to complete the job in hours
        uint8 percentCompleted;
        bool completed;
    }

    //uint64 private idCount;
    Job[] public jobs;
    mapping(uint=>address[]) internal applicants; //maps job id to applicants for the job
    mapping(uint=>address) internal approved; //maps job id to approved applicant
    mapping(uint=>address) internal assignment; //maps job id to assignee

    constructor() {
        //idCount = -1;
    }

    ///@dev internal function creating jobs for potential calls in other places
    function _createJob() internal {
    }

    ///@notice checks that owner is good for budget and witholds the budget
    function _withholdBudget() internal {
    }

    ///@notice creates a new job posting
    ///@dev jobs can only be created by the owner
    ///@dev incrementing idCount depends on overflow protection; only use with Solidity verions >0.8!
    function createJob(string memory _name, uint64 _budget, uint8 _time) public onlyOwner() {
        //idCount++;
        jobs.push(Job(_name, _budget, _time, 0, false));
        // call withholdBudget here
        emit JobPosted(jobs.length-1);
    }

    ///@notice apply to accept a job
    function applyToJob() public {
        emit ApplicationCompleted();
    }

    //@notice accept job Applicant
    function acceptApplicant() public onlyOwner() {
        emit ApplicantAccepted();
    }

    ///@notice accept job assignment
    ///@dev jobs can only be accepted by approved applicants -- maybe implement via modifier.
    function acceptAssignment() public { 
        emit JobAssigned();
    }

}