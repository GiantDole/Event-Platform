//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

//OBJECTIVE
//1. MONEY IS TAKEN FROM THE OWNER OF THE JOB AND SET INTO THIS CONTRACT
//2. MONEY CAN ONLY BE WITHDRAWN BY THE CONTRACTOR ON SUCESSFUL COMPLETION OF THE JOB

/**
 * Payment follows a pull payment model i.e. payments are not automatically forwarded to the
 * accounts but kept in this contract, and the actual transfer is triggered as a separate step by calling the withdraw
 * function.
 */

// @Adrian: import OrganizationManager
import "./OrganizationManager.sol";
// @Adrian: TODO; import Job
import "./Job.sol";

contract Payment is Job, OrganizationManager {
    event PaymentReceived(address from, uint256 amount);
    event PaymentReleased(address to, uint256 amount);
    event InvoiceEvent(
        string _contractorName,
        address _contractoraddress,
        uint256 _invoiceNumber,
        uint256 _numberHours,
        string _amount,
        uint256 _invoiceSentDate
    );

    // @Adrian: JobID is known because payment inherits Job
    //@Sharique: Okay! Will remove it at the end. Keeping it for now.
    uint64 public jobID;
    address public contractoraddress;

    uint256 _invoiceNumber = 1;

    struct Invoice {
        string contractorName;
        address contractoraddress;
        uint256 invoiceNumber;
        uint256 numberHours;
        string amount;
        uint256 invoiceSentDate;
    }

    // @Adrian: Isn't budget equal to the balance locked in this smart contract?
    //@ Sharique: But if contractor withdraw money in the middle then the budget wouldn't be equal to the balance
    uint64 public budget;
    uint8 public percentCompleted;

    // @Adrian: adding units
    //          remove percentcompleted
    //          add functionality for units
    //          !! dont't forget units: contractors need to create invoice
    uint8 public unitsCompleted;
    uint8 public unitsWithdrawn = 0;
    uint8 public totalunit;
    uint8 public paymentperunit;
    bool public completed;
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
    mapping(uint256 => bool) public paymentcontractdeployed; //Maps job ID to all payment contracts
    mapping(uint256 => address) public paymentcontractaddress; //Maps job ID to all payment address
    mapping(string => Invoice[]) private contractorNameInvoiceMap; // map the name of the client to invoices
    mapping(string => uint256[]) private contractorNameInvoiceNumMap; // @dev map the client name to the invoice numbers.
    mapping(string => uint256) private contractorNameInvoiceCountMap; /// @dev map the name of the client to an invoice count

    constructor(
        uint64 _jobID,
        address _contractoraddress,
        uint8 _totaluint,
        uint8 _paymentperunit,
        uint8 _percentCompleted,
        bool _completed
    ) payable {
        jobID = _jobID; //Setting job ID
        contractoraddress = _contractoraddress;
        paymentperunit = _paymentperunit;
        budget = _totalunit * _paymentperunit;
        percentCompleted = _percentCompleted;
        completed = _completed;

        //require (!paymentcontractdeployed[_jobID],"Payment Contract Exists");
        //Don't know why this isn't working.
        require(_totaluint >= 3, "Total units should be atleast 3 units");
        require(
            msg.value >= _budget,
            "Owner should deposit money equal to the budget"
        );
        if (msg.value >= _budget) {
            (bool paidContractor, ) = payable(msg.sender).call{
                value: (address(this).balance - _budget)
            }("");
        }
        paymentcontractdeployed[_jobID] = true;
        paymentcontractaddress[_jobID] = address(this);

        emit PaymentReceived(msg.sender, _budget);
    }

    /**
     * @dev Getter for the total budget for the job
     */
    function getBudget() public view returns (uint64) {
        return budget;
    }

    /**
     * @dev Getter for the progress for the job
     */
    // @Adrian: adapt for completed units
    function getprogress() public view returns (uint8) {
        return percentCompleted;
    }

    /**
     * @dev Getter for the completion of the job
     */
    // @Adrian: we can leave a potential completed flag - rarely used though
    function iscompleted() public view returns (bool) {
        return percentCompleted == 1 ? true : false;
    }

    function getcontractaddress(_jobID) public view returns (address) {
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
    function updatePaymentPerUnit(uint8 newPaymentperunit) public onlyOwner {
        paymentperunit = newPaymentperunit;
        budget = totaluint * newPaymentperunit;
    }

    /**
     * @dev Function  to add contract invoice
     */
    function addInvoice(
        string _contractorName,
        //uint256 _invoiceNumber,
        uint256 _numberHours,
        string _amount,
        uint256 _invoiceSentDate
    ) public Onlyowner {
        Invoice memory newInvoice;
        newInvoice.contractorName = _contractorName;
        newInvoice.contractoraddress = contractoraddress;
        newInvoice.invoiceNumber = _invoiceNumber;
        newInvoice.numberHours = _numberHours;
        newInvoice.amount = _amount;
        newInvoice.invoiceSentDate = _invoiceSentDate;
        contractorNameInvoiceMap[_contractoraddress].push(newInvoice);
        contractorNameInvoiceCountMap[_contractoraddress].push(_invoiceNumber);

        emit InvoiceEvent(
            _clientName,
            contractoraddress,
            newInvoice.invoiceNumber,
            newInvoice.numberHours,
            newInvoice.amount,
            newInvoice.invoiceSentDate
        );
        _invoiceNumber++;
    }

    /**
     * @dev Increments the Invoice Count
     */
    function incremmentInvoiceCount(string memory _contractorName)
        private
        returns (uint256)
    {
        return contractorNameInvoiceCountMap[_contractorName] += 1;
    }

    /**
     * @dev Getter for the count of invoices associated with the given client name
     */
    function getInvoiceCount(string memory _contractorName)
        public
        view
        ownerOnly
        returns (uint256 count)
    {
        count = contractorNameInvoiceCountMap[_contractorName];
    }

    /**
     * @dev Getter for invoice of any particular contractor name
     */
    function getInvoiceNumbers(string memory _contractorName)
        public
        view
        ownerOnly
        returns (uint256[] memory)
    {
        return contractorNameInvoiceCountMap[_contractorName];
    }

    /**
     * @dev Function for contractor to withdraw assets if the job is completed.
     */
    // @Adrian: adapt: either completed or just withdraw commited units.
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
    function _withdrawPartially(uint8 unitsRequested) public {
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
