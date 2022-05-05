//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./OrganizationManager.sol";


///@title Task contracts

contract TaskFactory is OrganizationManager{ // also probably is Payable or whatever our payments contract is

    event ApplicationCompleted(address _applicant);
    event ApplicationWithdrawn(address _applicant);
    event ApplicantAccepted(address _applicant);
    event Assignment(address _assignee);
    event RejectAssignment(address _approved);
    event ProgressUpdated();
    event ProgressApproved();
    event Completion();

    // variables set at instantiation
    string public name;
    string public desc; // description of task
    uint64 public id; //id will be given through index in array -- tbd but we may not actually need this in the task
    uint64 public budget; //in wei?
    uint8 public time; //time to complete the task in hours: uint8 means task can have at most 255 hours

    // variables that are always set to the same value at instantiation
    uint8 public percentCompleted;
    bool public isCompleted;
    bool public isAssigned;

    mapping(address=>bool) public isApplicant;
    address[] public applicants; 
    address public approved;
    address public assignment;


    ///@notice constructor to instantiate the contract
    constructor(string memory _name, string memory _desc, uint64 _id, uint64 _budget, uint8 _time) {
        
        // input variables
        name = _name;
        desc = _desc;
        id = _id;
        budget = _budget;
        time = _time;

        // variables that are always the same at instantiation
        percentCompleted = 0;
        isCompleted = 0;
        isAssigned = 0;

    }

    ///@notice only allow the task assignee to call the function
    modifier onlyAssignee() {
        require(assignment == msg.sender, "Callable: caller is not the task assignee");
        _;
    }

    ///@notice only allow an approved applicant to call the function
    modifier onlyApproved() {
        require(approved == msg.sender, "Callable: caller's application has not been approved");
        _;
    }

    ///@notice apply for a task
    function apply(address _applicant) public {
        isApplicant[_applicant] = 1;
        applicants.push(_applicant);
        emit ApplicationCompleted(_applicant);
    }

    ///@notice withdraw application
    function withdrawApplication(address _applicant) public {
        isApplicant[_applicant] = 0;
        emit ApplicationWithdrawn(_applicant);
    }

    ///@notice view applicants for the task
    ///@dev only an organizer of the task can do so
    ///@dev public view function -- no gas needed
    ///@dev BUT NOTE THAT WE MAY JUST WANT TO RETURN ALL APPLICANTS (EVEN WITHDRAWN) AND LOOP THROUGH ON FRONT-END IN THE END!!!!!
    function viewApplicants() public view onlyOrganizer() returns (address[] _currApplicants) {
        address[] currApplicants;
        for (uint i; i < applicants.length; i++) {
            if (isApplicant[applicants[i]]) {
                currApplicants.push(applicants[i]);
            }
        } 
        return currApplicants;
    }

    //@notice accept task Applicant
    function acceptApplicant(address _applicant) public onlyOrganizer() {
        require(isApplicant[_applicant] == 1, "Callable: input address is not an existing applicant and therefore cannot be accepted.");
        approved = _applicant;
        emit ApplicantAccepted(_applicant);
    }

    ///@notice accept task assignment
    ///@dev tasks can only be accepted by approved applicants
    function acceptAssignment(uint64 _address) public onlyApproved() { 
        assignment = _address;
        isAssigned = 1;
        emit Assignment(_address);
    }


}