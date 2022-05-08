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

import "./Ownable.sol";

contract Payment is Ownable {
    event PaymentReceived(address from, uint256 amount);
    event PaymentReleased(address to, uint256 amount);
    event InvoiceEvent(
        address _contractoraddress,
        uint256 _invoiceNumber,
        uint256 _numberUnits,
        uint256 _amount,
        uint256 _invoiceReleaseDate
    );

    uint64 public jobID;
    address public contractoraddress;
    uint64 public paymentperunit;
    uint64 public progressUnits;
    uint256 _invoiceNumber = 1;

    struct Invoice {
        address contractoraddress;
        uint256 invoiceNumber;
        uint256 numberUnits;
        uint256 amount;
        uint256 invoiceReleaseDate;
    }

    uint64 public budget;
    uint8 public percentCompleted;
    uint64 public unitsCompleted;
    uint64 public unitsWithdrawn = 0;
    bool public completed;
    // @Adrian: adding units
    //          remove percentcompleted
    //          add functionality for units
    //          !! dont't forget units: contractors need to create invoice

    //uint16 public progressUnits;
    //uint64 public budgetPerUnit;

    // @Adrian: Instead of percentCompleted: unit counter & paymentperunit
    //          Have a unit counter that captures completed work
    //          Units can be requested by contractor and confirmed by organizer
    //          If contractor wished to withdraw funds, they can withdraw completed units * paymentperunit
    //          Maybe two variables: unitsWithdrawn and unitsCompleted
    //          --> we can differ between units that have been worked and accepted by organizers and units that have been withdrawn already

    mapping(uint256 => bool) public paymentcontractdeployed; //Maps job ID to whether payment contract deployed
    mapping(uint256 => address) public paymentcontractaddress; //Maps job ID to payment contract address
    mapping(address => Invoice[]) private contractorAddressInvoiceMap; // map the name of the client to invoices
    mapping(address => uint256[]) private contractorAddressInvoiceNumMap; //map the client address to the invoice numbers.    mapping(address => uint256) private contractorAddressInvoiceCountMap; //map the name of the address to an invoice count

    /**
     * @dev Function for owner to deposit
     */
    function deposit(
        uint64 _jobID,
        address _contractoraddress,
        uint64 _progressUnits,
        uint64 _paymentperunit,
        bool _completed
    ) public payable {
        jobID = _jobID; //Setting job ID
        contractoraddress = _contractoraddress;
        paymentperunit = _paymentperunit;
        progressUnits = _progressUnits;
        budget = _progressUnits * _paymentperunit;
        completed = _completed;

        require(
            msg.value >= budget,
            "Owner should deposit money equal to the budget"
        );
        if (msg.value >= budget) {
            (bool paidContractor, ) = payable(msg.sender).call{
                value: (address(this).balance - budget)
            }("");
        }

        paymentcontractdeployed[_jobID] = true;
        paymentcontractaddress[_jobID] = address(this);

        emit PaymentReceived(msg.sender, budget);
    }

    /**
     * @dev Getter for the total budget for the job
     */
    function getBudget() public view returns (uint64) {
        return budget;
    }

    /**
     * @dev Getter for the units completed
     */
    function getCompletedUnits() public view returns (uint64) {
        return unitsCompleted;
    }

    /**
     * @dev Getter for the units withdrawn
     */
    function getWithdrawnUnits() public view returns (uint64) {
        return unitsWithdrawn;
    }

    /**
     * @dev Getter for the units left to be withdrawn
     */
    function getUnitsLeftToBeWithdrawn() public view returns (uint64) {
        return (unitsCompleted - unitsWithdrawn);
    }

    /**
     * @dev Getter for the completion of the job
     */
    // @Adrian: we can leave a potential completed flag - rarely used though
    function iscompleted() public view returns (bool) {
        return completed;
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
     * @dev Getter to update paymentperuint
     */
    function updatePaymentPerUnit(uint64 newPaymentperunit) public onlyOwner {
        paymentperunit = newPaymentperunit;
        budget = progressUnits * newPaymentperunit;
    }

    function updateunitscompleted(uint64 _completedunits) public onlyOwner {
        require(
            progressUnits > _completedunits,
            "Completed units can't be more than total units"
        );
        unitsCompleted = _completedunits;
    }

    /**
     * @dev Function  to add contract invoice
     */
    function addInvoice(
        uint256 _numberUnits,
        uint256 _amount,
        uint256 _invoiceReleaseDate
    ) public onlyOwner {
        Invoice memory newInvoice;
        newInvoice.contractoraddress = contractoraddress;
        newInvoice.invoiceNumber = _invoiceNumber;
        newInvoice.numberUnits = _numberUnits;
        newInvoice.amount = _amount;
        newInvoice.invoiceReleaseDate = _invoiceReleaseDate;
        contractorAddressInvoiceMap[contractoraddress].push(newInvoice);
        contractorAddressInvoiceNumMap[contractoraddress].push(_invoiceNumber);

        emit InvoiceEvent(
            contractoraddress,
            newInvoice.invoiceNumber,
            newInvoice.numberUnits,
            newInvoice.amount,
            newInvoice.invoiceReleaseDate
        );
        _invoiceNumber++;
    }

    /**
     * @dev Getter for invoice of any particular contractor address
     */
    function getInvoice(address _contractoraddress)
        public
        view
        onlyOwner
        returns (Invoice[] memory)
    {
        return contractorAddressInvoiceMap[_contractoraddress];
    }

    /**
     * @dev Getter for invoice number of any particular contractor address
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
     * @dev Function for contractor to withdraw assets if the job is completed.
     */
    function _withdrawOnEntireJobCompletion() public {
        require(
            msg.sender == contractoraddress,
            "Only the contractor can withdraw the payment."
        );

        require(iscompleted() == true, "Job still not completed");
        (bool paidContractor, ) = payable(contractoraddress).call{
            value: address(this).balance
        }("");
        require(paidContractor, "Payment did not reach contractor");
        emit PaymentReleased(msg.sender, address(this).balance);
    }

    /**
     * @dev Function for contractor to withdraw assets if the job has been partially completed.
     */
    function _withdrawPartially(uint64 unitsRequested) public {
        require(
            msg.sender == contractoraddress,
            "Only the contractor can withdraw the payment."
        );
        require(
            (unitsCompleted - unitsWithdrawn) >= unitsRequested,
            "Can't withdraw for more units than worked done."
        );

        (bool paidContractor, ) = payable(contractoraddress).call{
            value: unitsRequested * paymentperunit
        }("");
        require(paidContractor, "Payment did not reach contractor");

        unitsWithdrawn = unitsWithdrawn + unitsRequested;

        emit PaymentReleased(msg.sender, unitsRequested * paymentperunit);
    }
}
