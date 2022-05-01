//SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract Payment is OrganizationManager {

    event PaymentReceived(address from, uint256 amount);
    event PaymentReleased(address to, uint256 amount);

    //Will check later the view part of the variables and the reduncies of few varibales
    address public owner;
    uint public jobID;
    address public contractoraddress;
    uint public progress;

    ///@notice creates a new instance of Payment 
    ///@dev jobs can only be created by the owner

    constructor(uint _jobID) payable onlyOwner() {

      jobID=_jobID; //Setting job ID
      contractoraddress=  workerJobs[_jobID];

    require(
        msg.value == Job[_jobID].budget,
        'Owner should deposit money equal to the budget'
        );
    
    emit PaymentReceived(msg.sender,msg.value);
//ORemit PaymentReceived(_owner,msg.value);
    }

    }

//ADD SOME MODIFIERS
//THINK ABOUT MORE FUNCTIONS
//PUBLIC VS PRIVATE, INTERNAL VS EXTERNAL
//IF FOR SOME REASON IF THE JOB IS NOT COMPLETED ADD SOME FUNCTIONALITY TO REVERT MONEY
//ADD FUNCTIONALITY TO UPDATE BUDGET AND % COMPLETED
//EMIT SOME EVENTS
//CHECK SOME PROPER IMPLEMENTAIONS ON YOUTUBE

//OBJECTIVE
//1. MONEY IS TAKEN FROM THE OWNER OF THE JOB AND SET INTO THIS CONTRACT
//2. MONEY CAN ONLY BE WITHDRAWN BY THE CONTRACTOR ON SUCESSFUL COMPLETION OF THE JOB




    /**
     * @dev Getter for the total budget for the job
     */
    function getBudget() public view returns (uint256) {
        return Job[jobID].budget;
    }

    /**
     * @dev Getter for the progress for the job
     */
    function getprogress() public view returns (uint256) {
        return Job[jobID].percentCompleted;
    }

    /**
     * @dev Getter for the completion of the job
     */
    function iscompleted() returns (bool) {
        return jobs[jobID].percentCompleted == 1 ? true : false;
    }

    /**
     * @dev Getter for the contract balance
     */
    function getContractBalance() public view returns (uint){
         return address(this).balance;
     }

    /**
     * @dev Getter for the job budget
     */     
    function getBudget() public view returns (uint256) {
        return Job[jobID].budget;
    }

    /**
     * @dev Getter for the contract balance
     */     
    function _getContractBalance() public view returns(uint) {
    //Shows current balance of the contract
    return address(this).balance;
    }

    /**
     * @dev 
     */  
    function _withdraw() public {
        require(
            msg.sender == contractoraddress,
            'Only the contractor can withdraw the payment.'
         );
        require(
            iscompleted(_jobID) == true,
            'Job still not completed'
        );
        msg.sender.transfer(address(this).balance);

        event PaymentReleased(msg.sender, address(this).balance);
    }



}