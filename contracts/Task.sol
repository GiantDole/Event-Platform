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
    // progressUnits = number of units that the work for the task will be measured in, and for which payment can be transferred to the assignee.
    // e.g. if the task is a task that will be paid by the hour, this should be the number of hours, and the assignee will be able to request
    // approval to withdraw budgetPerUnit for each hour they complete. 
    // if the task is to be paid in in four chunks, progressUnits = 4 and the assignee will be able to request approval to withdraw budgetPerUnit
    // each of the 4 units are completed.
    string public name;
    string public desc; // description of task
    uint64 public id; //id will be given through index in array -- tbd but we may not actually need this in the task
    uint64 public budgetPerUnit; //in wei?
    uint16 public progressUnits; // total units of progress that the task involves

    // variables that are always set to the same value at instantiation
    uint8 public completedUnits;
    bool public isAssigned;
    bool public progressApproved;

    mapping(address=>bool) public isApplicant;
    address[] public applicants; 
    address public approved;
    address public assignment;


    ///@notice constructor to instantiate the contract
    constructor(string memory _name, string memory _desc, uint64 _id, uint64 _budgetPerUnit, uint8 _progressUnits) {
        
        // input variables
        name = _name;
        desc = _desc;
        id = _id;
        budgetPerUnit = _budgetPerUnit;
        progressUnits = _progressUnits;

        // variables that are always the same at instantiation
        completedUnits = 0;
        isAssigned = 0;
        progressApproved = 1;

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

    ///@notice update progress
    ///@dev progress can only be updated by the assignee.
    ///@dev note that money cannot be withdrawn based on progress until progress has been separately approved by an organizer.
    function updateProgress(uint8 _completedUnits) public onlyAssigned() { 
        assignment = _address;
        isAssigned = 1;
        emit ProgressUpdated(_address);
    }

}