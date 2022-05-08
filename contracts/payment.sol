//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

//OBJECTIVE
//1. MONEY IS TAKEN FROM THE OWNER OF THE JOB AND SET INTO THIS CONTRACT
//2. MONEY CAN ONLY BE WITHDRAWN BY THE CONTRACTOR ON SUCESSFUL COMPLETION OF THE JOB

/**
 * Payment follows a pull payment model i.e. payments are not automatically forwarded to the
 * accounts but kept in this contract, and the actual transfer is triggered as a separate step by calling the withdraw
 * function.
 */

// @Adrian: import OrganizationManager
//@Sharique: Since Task is inheriting Payment we don't need to inherit Organization Manager

import "./OrganizationManager.sol";

contract Payment is OrganizationManager {
    event PaymentReceived(address from, uint256 amount);
    event PaymentReleased(address to, uint256 amount);
    event InvoiceEvent(
        string _contractorName,
        address _contractoraddress,
        uint256 _invoiceNumber,
        uint256 _numberHours,
        string _amount,
        uint256 _invoiceReleaseDate
    );

    //jobId is known through Task inheriting Payment
    //uint64 public jobID;
    //contractorAddress known in Task
    //address public contractoraddress;
    uint256 _invoiceNumber = 1;

    struct Invoice {
        string contractorName;
        address contractoraddress;
        uint256 invoiceNumber;
        uint256 numberHours;
        string amount;
        uint256 invoiceReleaseDate;
    }

    // @Adrian: Isn't budget equal to the balance locked in this smart contract?
    //@ Sharique: But if contractor partiallly withdraws money  then the budget wouldn't be equal to the balance
    uint64 public budget;
    uint8 public percentCompleted;

    // @Adrian: adding units
    //          remove percentcompleted
    //          add functionality for units
    //          !! dont't forget units: contractors need to create invoice
    //uint64 public unitsCompleted;
    //uint64 public unitsWithdrawn = 0;
    //uint64 public totalunit;
    //uint64 public paymentperunit;
    //bool public completed;
    // @Adrian: Instead of percentCompleted: unit counter & paymentperunit
    //          Have a unit counter that captures completed work
    //          Units can be requested by contractor and confirmed by organizer
    //          If contractor wished to withdraw funds, they can withdraw completed units * paymentperunit
    //          Maybe two variables: unitsWithdrawn and unitsCompleted
    //          --> we can differ between units that have been worked and accepted by organizers and units that have been withdrawn already
    //

    // @Adrian: Missing functionality:
    //          add budget to this job
    //          implement units and requesting units + accepting units
    //          create invoice
    //          change paymentperunit

    ///@notice creates a new instance of Payment
    ///@dev jobs can only be created by the owner

    // @Adrian: require that budget is at least e.g. 3 units * paymentperunit
    //@Sharique: How to make sure only one payment contract is made for each job ID. We could have a situation where mutliple payment contracts could be build for
    // each job ID
    mapping(uint256 => bool) public paymentcontractdeployed; //Maps job ID to whether payment contract deployed
    mapping(uint256 => address) public paymentcontractaddress; //Maps job ID to payment contract address
    mapping(address => Invoice[]) private contractorAddressInvoiceMap; // map the name of the client to invoices
    mapping(address => uint256[]) private contractorAddressInvoiceNumMap; //map the client address to the invoice numbers.
    mapping(address => uint256) private contractorAddressInvoiceCountMap; //map the name of the address to an invoice count

    /**
     * @dev Getter for the total budget for the job
     */
    function getBudget() public view returns (uint) {
        return address(this).balance;
    }

    /**
     * @dev Getter for the progress for the job
     */
    // @Adrian: adapt for completed units
    //function getProgress() public view returns (uint64) {
    //    return percentCompleted;
    //}

    /**
     * @dev Getter for the completion of the job
     */
    // @Adrian: we can leave a potential completed flag - rarely used though
    function iscompleted() public view returns (bool) {
        return percentCompleted == 1 ? true : false;
    }

    /**
     * @dev Getter for the contract address associated with a job ID
     */
    function getcontractaddress(uint64 _jobID) public view returns (address) {
        return paymentcontractaddress[_jobID];
    }

    /**
     * @dev Getter for the contract balance
     */
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev Increments the Invoice Count
     */
    function incremmentInvoiceCount(address _contractoraddress)
        private
        returns (uint256)
    {
        return contractorAddressInvoiceCountMap[_contractoraddress] += 1;
    }

    /**
     * @dev Getter for the count of invoices associated with the given client address
     */
    function getInvoiceCount(address _contractoraddress)
        public
        view
        onlyOwner
        returns (uint256 count)
    {
        count = contractorAddressInvoiceCountMap[_contractoraddress];
    }

    /**
     * @dev Getter for invoice of any particular contractor address
     */
    function getInvoiceNumbers(address _contractoraddress)
        public
        view
        onlyOwner
        returns (uint256[] memory)
    {
        return contractorAddressInvoiceNumMap[_contractoraddress];
    }

    /**
     * @dev Function for contractor to withdraw assets if the job has been partially completed.
     */
    //function _withdrawPartially(uint64 unitsRequested) public {
    //    require(
    //        msg.sender == contractoraddress,
    //        "Only the contractor can withdraw the payment."
    //    );
    //    require(
    //        (unitsCompleted - unitsWithdrawn) >= unitsRequested,
    //        "Can't withdraw for more units than worked done."
    //    );

    //    (bool paidContractor, ) = payable(contractoraddress).call{
    //        value: unitsRequested * paymentperunit
    //    }("");
    //    require(paidContractor, "Payment did not reach contractor");

    //    unitsWithdrawn = unitsWithdrawn + unitsRequested;

    //    emit PaymentReleased(msg.sender, unitsRequested * paymentperunit);
    //}
}
