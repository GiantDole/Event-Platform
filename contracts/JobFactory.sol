//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./OrganizationManager.sol";


///@title Collection and creation of all job postings

contract JobFactory is OrganizationManager{

    event JobPosted(uint id);

    ///@dev so far a job can have at max 255 hours 
    struct Job {
        string name;
        //uint64 id; id will be given through index in array
        uint64 budget; //in wei?
        uint8 time; //in hours
        uint8 percentCompleted;
        bool completed;
    }

    //uint64 private idCount;
    Job[] public jobs;

    constructor() {
        //idCount = -1;
    }

    ///@dev internal function creating jobs for potential calls in other places
    function _createJob() internal {

    }

    ///@notice creates a new job posting
    ///@dev jobs can only be created by the owner
    ///@dev incrementing idCount depends on overflow protection; only use with Solidity verions >0.8!
    function createJob(string memory _name, uint64 _budget, uint8 _time) public onlyOwner() {
        //idCount++;
        jobs.push(Job(_name, _budget, _time, 0, false));
        emit JobPosted(jobs.length-1);
    }
}