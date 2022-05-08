//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "./OrganizationManager.sol";


///@title Task contracts

contract Task is OrganizationManager{ // also probably is Payable or whatever our payments contract is

    event TaskCreated(address _contract);
    //TODO: rename to ApplicationSubmitted?
    event ApplicationCompleted(address _applicant);
    event ApplicationWithdrawn(address _applicant);
    event ApplicantAccepted(address _applicant);
    event Assignment(address _assignee);
    event RejectAssignment(address _approved);
    event ProgressUpdated(uint16 _addUnits, uint16 _completedUnits, uint16 _progressUnits);
    event ProgressApproved(uint16 _addUnits, uint16 _completedUnits, uint16 _progressUnits);
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
    uint16 public completedUnits;
    uint16 public approvedUnits; // total units of progress that has been approved by the organizer for payment
    //uint16 withdrawnUnits; // do we need to keep track of this? believe we do if transfer is not automatic upon progress approval.
    bool public isAssigned;

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
        approvedUnits = 0;
        isAssigned = false;

        emit TaskCreated(address(this));
    }

    ///@notice only allow the task assignee to call the function
    modifier onlyAssignee() {
        require(assignment == msg.sender, "Callable: caller is not the task assignee");
        _;
    }

    ///@notice only allow the task assignee to call the function
    modifier onlyAssigneeOrOrganizer() {
        require( assignment == msg.sender || _organizers[msg.sender] == 1, "Callable: caller is not the task assignee or organizer");
        _;
    }

    ///@notice only allow an approved applicant to call the function
    modifier onlyApproved() {
        require(approved == msg.sender, "Callable: caller's application has not been approved");
        _;
    }

    ///@notice apply for a task
    function applyTo() public {
        isApplicant[msg.sender] = true;
        applicants.push(msg.sender);
        emit ApplicationCompleted(msg.sender);
    }

    ///@notice withdraw application
    function withdrawApplication() public {
        isApplicant[msg.sender] = false;
        emit ApplicationWithdrawn(msg.sender);
    }

    ///@notice view applicants for the task
    ///@dev only an organizer of the task can do so
    ///@dev public view function -- no gas needed
    ///@dev BUT NOTE THAT WE MAY JUST WANT TO RETURN ALL APPLICANTS (EVEN WITHDRAWN) AND LOOP THROUGH ON FRONT-END IN THE END!!!!!
    function viewApplicants() public view onlyOrganizer() returns (address[] memory _currApplicants) {
        address[] memory currApplicants;
        uint16 currId = 0;
        for (uint i; i < applicants.length; i++) {
            if (isApplicant[applicants[i]]) {
                currApplicants[currId] = applicants[i];
                currId++;
            }
        } 
        return currApplicants;
    }

    //@notice accept task Applicant
    function acceptApplicant(address _applicant) public onlyOrganizer() {
        require(isApplicant[_applicant] == true, "Callable: input address is not an existing applicant and therefore cannot be accepted.");
        approved = _applicant;
        emit ApplicantAccepted(_applicant);
    }

    ///@notice accept task assignment
    ///@dev tasks can only be accepted by approved applicants
    function acceptAssignment() public onlyApproved() { 
        assignment = msg.sender;
        isAssigned = true;
        emit Assignment(msg.sender);
    }

    ///@notice update progress
    ///@dev progress can only be updated by the assignee.
    ///@dev note that if progress is updated by the assignee, progress still needs to be approved by an organizer before money can be transferred.
    function updateProgress(uint8 _addUnits) public onlyAssigneeOrOrganizer() { 
        require( _addUnits <= progressUnits - completedUnits, "Additional progress units requested are more than the remaining units on the task." );
        completedUnits = completedUnits + _addUnits;
        emit ProgressUpdated(_addUnits, completedUnits, progressUnits);
        if (_organizers[msg.sender] == 1) {
            approvedUnits += _addUnits;
            emit ProgressApproved(_addUnits, approvedUnits, progressUnits);
            // should we transfer the $$ automatically here? If we don't do it automatically, we need to keep track of how much assignee has already withdrawn.
            // transferAmt = addUnits * budgetPerUnits;
            if (approvedUnits == progressUnits) {
                emit Completion();
            }   
        }
    }

    ///@notice approve progress
    ///@dev progress can only be approved by the organizer
    function approveProgress() public onlyOrganizer() { 
        uint16 addUnits = completedUnits - approvedUnits;
        // automatically withdraw transfer amount?
        // transferAmt = addUnits * budgetPerUnits;
        approvedUnits = completedUnits;
        emit ProgressApproved(addUnits, approvedUnits, progressUnits);
        if (approvedUnits == progressUnits) {
            emit Completion();
        }
    }


}