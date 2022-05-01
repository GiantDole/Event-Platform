//SPDX-License-Identifier: MIT
pragma solidity ^0.8;

//OBJECTIVE
//1. MONEY IS TAKEN FROM THE OWNER OF THE JOB AND SET INTO THIS CONTRACT
//2. MONEY CAN ONLY BE WITHDRAWN BY THE CONTRACTOR ON SUCESSFUL COMPLETION OF THE JOB

/**
 *Ref:https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/finance/PaymentSplitter.sol
 * @title Payment
 * Payment follows a _pull payment_ model i.e. payments are not automatically forwarded to the
 * accounts but kept in this contract, and the actual transfer is triggered as a separate step by calling the withdraw
 * function.
 */

contract Payment is OrganizationManager {
    event PaymentReceived(address from, uint256 amount);
    event PaymentReleased(address to, uint256 amount);

    //Will check later the view part of the variables and the reduncies of few varibales
    uint256 public jobID;
    address public contractoraddress;
    uint256 public progress;

    ///@notice creates a new instance of Payment
    ///@dev jobs can only be created by the owner

    constructor(uint256 _jobID) payable onlyOwner() {
        jobID = _jobID; //Setting job ID
        contractoraddress = assignment[_jobID];

        require(
            msg.value == Job[_jobID].budget,
            "Owner should deposit money equal to the budget"
        );

        emit PaymentReceived(msg.sender, msg.value);
    }

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
    function iscompleted() public returns (bool) {
        return jobs[jobID].percentCompleted == 1 ? true : false;
    }

    /**
     * @dev Getter for the contract balance
     */
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev Getter for the job budget
     */
    function getBudget() public view returns (uint256) {
        return Job[jobID].budget;
    }

    /**
     * @dev Function for contractor to withdraw assets if the job has been fulfilled
     */
    function _withdraw() public {
        require(
            msg.sender == contractoraddress,
            "Only the contractor can withdraw the payment."
        );
        require(iscompleted(_jobID) == true, "Job still not completed");
        msg.sender.transfer(address(this).balance);
        //(bool paidContractor, ) = payable(contractoraddress).call{value: address(this).balance}("");
        //require(paidContractor, "Payment did not reach contractor");
        emit PaymentReleased(msg.sender, address(this).balance);
    }

    //QUESIONS:
    //1. Do we want to make payment if time taken is more than time limit. For that we need to introduce time componet
    //2. Do we need a function to revert money back to the owner in case the job is not fulfilled.

    //GENERAL GUIDELINES:
    //ADD SOME MODIFIERS
    //THINK ABOUT MORE FUNCTIONS
    //PUBLIC VS PRIVATE, INTERNAL VS EXTERNAL
    //IF FOR SOME REASON IF THE JOB IS NOT COMPLETED ADD SOME FUNCTIONALITY TO REVERT MONEY
    //ADD FUNCTIONALITY TO UPDATE BUDGET AND % COMPLETED
    //EMIT SOME EVENTS
    //CHECK SOME PROPER IMPLEMENTAIONS ON YOUTUBE
}
