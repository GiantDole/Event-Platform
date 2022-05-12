//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "./Payment.sol";

// the script needs to include removal of assignees and they should not be included any further

contract Task is Payment { // also probably is Payable or whatever our payments contract is

    event ApplicationCompleted(address _applicant);                             // apply as a contractor
    event ApplicationWithdrawn(address _applicant);
    event ApplicantAccepted(address _applicant);
    
    event Assignment(address _assignee);
    event RejectAssignment(address _approved);
    event ProgressRequested(uint _addUnits, uint _completedUnits);
    event ProgressApproved(uint _addUnits, uint _completedUnits)  ; 
    event Completion();

    mapping(uint => address[]) public applicants;                        // list of all applicants for that task   


    ///@notice only allow an approved applicant to call the function
    function isApplicant(uint _taskId, address _applicant)              // whether the msg sender is the applicant for that id or not 
        public
        view
        returns (int)
    {
        for(uint i=0; i < applicants[_taskId].length;i++){
            if(applicants[_taskId][i] == _applicant){
                return int(i) ;
            }
        }
        return -1 ;
    }

    modifier onlyApproved(uint _taskId) {                                                           // figure this out if needed or not
        require(isApplicant(_taskId, msg.sender) != -1 , "Callable: caller's application has not been approved");
        _;
    }

    ///@notice apply for a task
    function applyTo(uint _taskId) 
        public 
    {
        require(isApplicant(_taskId,msg.sender) == -1 ," Callabe: caller has already applied for the task" ) ;
        applicants[_taskId].push(msg.sender);
        emit ApplicationCompleted(msg.sender);
    }

    ///@notice withdraw application                                             // when application withdrawn length of array not changed. Replaced with 0 to save on gas
    function withdrawApplication(uint _taskId) 
        public 
    {
        int idx = isApplicant(_taskId,msg.sender) ;
        require(idx == -1 ," Callabe: caller has not  applied for the task" ) ;
        applicants[_taskId][uint(idx)] = address(0);
        emit ApplicationWithdrawn(msg.sender);
    }

    function viewApplicants(uint _taskId ) 
        public 
        view 
        onlyTaskOrganizer(_taskId) returns (address[] memory _currApplicants) 
    {
        address[] memory currApplicants ;
        uint idx = 0; 
        for (uint i=0 ; i < applicants[_taskId].length; i++) {
            if (applicants[_taskId][i] != address(0) ) {
                currApplicants[idx] = applicants[_taskId][i];
                idx++;
            }
        }
        return currApplicants;
    }

    //@notice accept task Applicant
    function acceptApplicant(uint _taskId, address _applicant) 
        public 
        onlyTaskOrganizer(_taskId) {
        require(tasks[_taskId].isAssigned == false, "Someone has already been assigned for the task");
        require(isApplicant(_taskId,_applicant) == -1, "Callable: input address is not an existing applicant and therefore cannot be accepted.");
        tasks[_taskId].assignee = _applicant ;
        tasks[_taskId].isAssigned = true ;
        emit ApplicantAccepted(_applicant);
    }

    function requestUpdate(uint _taskId, uint _addUnits) 
        public 
        onlyAssignee(_taskId) 
    { 
        require( tasks[_taskId].uintsCompleted + _addUnits <= tasks[_taskId].totalUnits , "Additional progress units requested are more than the remaining units on the task." );
        require( _addUnits > 0 , "Additional progress units requested should be greater than 0." );
        emit ProgressRequested(_addUnits, tasks[_taskId].uintsCompleted);
    }

    function approveUpdate(uint _taskId, uint _addUnits) 
        public 
        onlyTaskOrganizer(_taskId) 
    { 
        require( tasks[_taskId].uintsCompleted + _addUnits <= tasks[_taskId].totalUnits , "Additional progress units requested are more than the remaining units on the task." );
        require( _addUnits > 0 , "Additional progress units requested should be greater than 0." );
        tasks[_taskId].uintsCompleted +=  _addUnits;
        emit ProgressApproved(_addUnits, tasks[_taskId].uintsCompleted);
        if (tasks[_taskId].uintsCompleted == tasks[_taskId].totalUnits) {
            emit Completion();
        }
    }


}
