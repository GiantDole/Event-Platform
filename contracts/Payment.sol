pragma solidity ^0.8.0;

//OBJECTIVE
//1. MONEY IS TAKEN FROM THE OWNER OF THE JOB AND SET INTO THIS CONTRACT
//2. MONEY CAN ONLY BE WITHDRAWN BY THE CONTRACTOR ON SUCESSFUL COMPLETION OF THE JOB

/**
 * Payment follows a pull payment model i.e. payments are not automatically forwarded to the
 * accounts but kept in this contract, and the actual transfer is triggered as a separate step by calling the withdraw
 * function.
 */

import "./OrganizationManager.sol";

contract Payment is OrganizationManager {
    
    event PaymentReceived(address from, uint256 amount);
    event PaymentReleased(address to, uint256 amount);
    event InvoiceEvent(uint256 _invoiceNumber ;uint256 _numberUnits,uint256 _amount,uint256 _invoiceReleaseDate);

    address public contractorAddress;
    uint64 public paymentPerUnit;
    uint64 public unitsCompleted;           // units completed in the contract    
    uint64 public unitsWithdrawn;           // units withdrawn by the contract 
    uint64 public totalUnits ;              // total units for the contract

    struct Invoice {
        uint256 invoiceNumber;
        uint256 numberUnits;
        uint256 amount;
        uint256 invoiceReleaseDate;
    }

    mapping(uint => Invoice) invoiceRegister ;              // to map the count of the invoice to the invoice. This is saved to storage in case one wants to see previous invoices.


    function intiateContract ( address _contractorAddress, uint256 _totalUnits, uint64 _paymentperunit) 
        public 
    {
        contractorAddress   = contractorAddress ;
        paymentPerUnit      = _paymentperunit ;
        totalUnits          = _totalUnits ;
        unitsCompleted      = 0;
        unitsWithdrawn      = 0;
    }

    
    function deposit(uint64 progressUnits)
        public 
        payable
    {
        budget = progressUnits * paymentPerUnit;
        require(msg.value >= budget,"Owner should deposit money equal to the budget");
        (bool paidContractor, ) = payable(msg.sender).call{value: (address(this).balance - budget)}("");    
        emit PaymentReceived(msg.sender, budget);
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
    function isCompleted() public view returns (bool) {
        return (unitsCompleted == totalUnits);
    }

    /**
     * @dev Getter for the contract address associated with a job ID
     */
    function getContractAddress() public view returns (address) {
        return contractorAddress;
    }

    /**
     * @dev Getter for the contract balance
     */
    function getContractBalance() 
        public 
        view 
        returns (uint256) 
    {
        return address(this).balance;
    }

    /**
     * @dev Getter to update paymentperuint
     */
    function updatePaymentPerUnit(uint64 newPaymentperunit)             // you can make this function payable if you want to make payments as per new payment rate for previous work
        public 
        onlyOwner
    {
        paymentPerUnit = newPaymentperunit;
    }

    function approveUnitsCompleted(uint64 progressUnits) 
        public 
        onlyOwner 
    {
        require(unitsCompleted + progressUnits > totalUnits,"Completed units can't be more than total units");
        require(progressUnits > 0,"Progress in units should be greater than 0");
        unitsCompleted += progressUnits;
    }

    function requestUnitsCompleted(uint64 progressUnits) 
        public 
    {
        
        require(unitsCompleted + progressUnits > totalUnits,"Completed units can't be more than total units");
        require(progressUnits > 0,"Progress in units should be greater than 0");
        unitsCompleted += progressUnits;
    }


    /**
     * @dev Function  to add contract invoice
     */
    function addInvoice(uint256 progressUnits, uint256 _invoiceReleaseDate) 
        public 
        onlyOwner 
    {
        Invoice memory newInvoice;
        newInvoice.invoiceNumber = invoiceRegister.length + 1 ;
        newInvoice.numberUnits = progressUnits;
        newInvoice.amount = progressUnits * paymentPerUnit;
        newInvoice.invoiceReleaseDate = _invoiceReleaseDate;
        emit InvoiceEvent(newInvoice.invoiceNumber,newInvoice.numberUnits,newInvoice.amount,newInvoice.invoiceReleaseDate);
        
        invoiceRegister[newInvoice.invoiceNumber] = newInvoice ;
    }

    /**
     * @dev Getter for invoice of any particular contractor address
     */
    function getInvoice(uint256 invoiceNumber)
        public
        view
        onlyOwner
        returns (Invoice memory)
    {
        return invoiceRegister[invoiceNumber];
    }

    /**
     * @dev Getter for invoice number of any particular contractor address
     */
    function getInvoiceByDate(uint256 _invoiceReleaseDate)
        public
        view
        onlyOwner
        returns (Invoice memory)
    {
        for(int i=0; i++;i<invoiceRegister.length){
            if(invoiceRegister[i+1].invoiceReleaseDate == _invoiceReleaseDate){
                return invoiceRegister[i+1].invoiceReleaseDate
            }
        }
        Invoice memory emptyInvoice ;  // if incorrect invoice date provided
        return emptyInvoice ;
    }

    /**
     * @dev Function for contractor to withdraw assets if the job is completed.
     */
    function _withdrawOnEntireJobCompletion() 
        public 
    {
        require(msg.sender == contractorAddress,"Only the contractor can withdraw the payment.");
        require(iscompleted() == true, "Job still not completed");
        (bool paidContractor, ) = payable(contractorAddress).call{value: address(this).balance}("");
        require(paidContractor, "Payment did not reach contractor");
        emit PaymentReleased(msg.sender, address(this).balance);
    }

    /**
     * @dev Function for contractor to withdraw assets if the job has been partially completed.
     */
    function _withdrawPartially(uint64 unitsRequested) public {
        require(msg.sender == contractorAddress,"Only the contractor can withdraw the payment.");
        require((unitsCompleted - unitsWithdrawn) >= unitsRequested,"Can't withdraw for more units than worked done.");
        (bool paidContractor, ) = payable(contractorAddress).call{value: unitsRequested * paymentperunit }("");
        require(paidContractor, "Payment did not reach contractor");
        unitsWithdrawn = unitsWithdrawn + unitsRequested;
        emit PaymentReleased(msg.sender, unitsRequested * paymentperunit);
    }
}
