//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "./OrganizationManager.sol";

// the script needs to include removal of assignees and they should not be included any further

contract Task is Payment { // also probably is Payable or whatever our payments contract is

    event ApplicationCompleted(address _applicant);                             // apply as a contractor
    event ApplicationWithdrawn(address _applicant);
    event ApplicantAccepted(address _applicant);
    
    event Assignment(address _assignee);
    event RejectAssignment(address _approved);
    event ProgressRequested(uint16 _addUnits, uint16 _completedUnits, uint16 _progressUnits);
    event ProgressApproved(uint16 _addUnits, uint16 _completedUnits, uint16 _progressUnits);
    event Completion();

    mapping(uint => address[]) public applicants;                        // list of all applicants for that task   
    mapping (uint => uint) public amountDeposited ;         // amount deposited for that task. If amount has not been deposited for that task id. One cannot withdraw 



    ///@notice only allow an approved applicant to call the function
    function isApplicant(uint _taskId, address sender)              // whether the msg sender is the applicant for that id or not 
        public
        view
        returns (int index)
    {
        for(int i=0;i<applicants[_taskId].length;i++){
            if(applicants[_taskId][i]==sender){
                return i ;
            }
        }
        return -1 ;
    }

    modifier onlyApproved(uint _taskId) {                                                           // figure this out if needed or not
        require(isApplicant(uint _taskId, msg.sender) != -1 , "Callable: caller's application has not been approved");
        _;
    }

    ///@notice apply for a task
    function applyTo(uint _taskId) 
        public 
    {
        require(isApplicant(_taskId,msg.sender) != -1 ," Callabe: caller has already applied for the task" ) ;
        applicants[_taskId].push(msg.sender);
        emit ApplicationCompleted(msg.sender);
    }

    ///@notice withdraw application                                             // when application withdrawn length of array not changed. Replaced with 0 to save on gas
    function withdrawApplication(uint _taskId) 
        public 
    {
        int idx = isApplicant(_taskId,msg.sender) 
        require(idx == -1 ," Callabe: caller has not  applied for the task" ) ;
        applicants[_taskId][idx] = address(0);
        emit ApplicationWithdrawn(msg.sender);
    }

    function viewApplicants(uint _taskId ) 
        public 
        view 
        onlyTaskOrganizer() returns (address[] memory _currApplicants) 
    {
        address[] memory currApplicants ;
        for (uint i=0 ; i < applicants[_taskId].length; i++) {
            if (applicants[_taskId][i] != address(0) ) {
                currApplicants.push(applicants[_taskId][i]);
            }
        }
        return currApplicants;
    }

    //@notice accept task Applicant
    function acceptApplicant(uint _taskId, address _applicant) 
        public 
        onlyTaskOrganizer(uint _taskId) {
        require(isApplicant(_tasks,_applicant) == -1, "Callable: input address is not an existing applicant and therefore cannot be accepted.");
        tasks[_taskId].assignee = _applicant ;
        emit ApplicantAccepted(_applicant);
    }

    function requestUpdate(uint _taskId, uint8 _addUnits) 
        public 
        onlyAssignee(uint _taskId) 
    { 
        require( tasks[_taskId].completedUnits + _addUnits <= tasks[_taskId].totalUnits , "Additional progress units requested are more than the remaining units on the task." );
        require( _addUnits > 0 , "Additional progress units requested should be greater than 0." );
        emit ProgressRequested(_addUnits, completedUnits, progressUnits);
    }

    function approveUpdate(uint _taskId, uint8 _addUnits) 
        public 
        onlyTaskOrganizer(uint _taskId) 
    { 
        require( tasks[_taskId].completedUnits + _addUnits <= tasks[_taskId].totalUnits , "Additional progress units requested are more than the remaining units on the task." );
        require( _addUnits > 0 , "Additional progress units requested should be greater than 0." );
        tasks[_taskId].completedUnits +=  _addUnits;
        amountDue[_taskId] += tasks[_taskId].budgetPerUnit * _addUnits ;
        emit ProgressApproved(_addUnits, completedUnits, progressUnits);
        if (tasks[_taskId].completedUnits == tasks[_taskId].totalUnits) {
            emit Completion();
        }
    }

    /**
     * @dev Getter for the units completed
     */
    function getCompletedUnits() public view returns (uint64) {    // no req here
        return unitsCompleted;     
    }



    function isCompleted() public view returns (bool) {         // no place here
        return (unitsCompleted == totalUnits);
    }


    function getContractBalance() 
        public 
        view 
        returns (uint256) 
    {
        return address(this).balance;
    }


}
