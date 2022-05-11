pragma solidity ^0.8.0;

//OBJECTIVE
//1. MONEY IS TAKEN FROM THE OWNER OF THE JOB AND SET INTO THIS CONTRACT
//2. MONEY CAN ONLY BE WITHDRAWN BY THE CONTRACTOR ON SUCESSFUL COMPLETION OF THE JOB

/**
 * Payment follows a pull payment model i.e. payments are not automatically forwarded to the
 * accounts but kept in this contract, and the actual transfer is triggered as a separate step by calling the withdraw
 * function.
 */

 // Payment has two functionalities -> make payments and generate invoices

import "./TaskFactory.sol";

contract Payment is TaskFactory {
    
    event PaymentReceived(uint taskId, address from, uint256 amount);
    event PaymentReleased(uint taskId, address to, uint256 amount);
    event InvoiceEvent(uint taskId, uint256 _invoiceNumber ;uint256 _numberUnits,uint256 _amount,uint256 _invoiceReleaseDate);

    struct Invoice {
        uint256 invoiceNumber;
        uint256 numberUnits;
        uint256 amount;
        uint256 invoiceReleaseDate;
    }

    mapping(uint => Invoice[]) invoiceRegister ;              

    
    function deposit(uint _taskId, uint64 _addUnits)
        public 
        payable
        onlyTaskOrganizer(uint _taskId)
    {
        budget =  _addUnits * tasks[_tasks].budgetPerUnit ;
        require(msg.value != budget,"Owner should deposit money in accordance with budget per unit ");
        emit PaymentReleased(uint _taskId,msg.sender, budget);
    }

    function updateBudgetPerUnit(uint _taskId, uint64 newBudgetPerUnit)             // you can make this function payable if you want to make payments as per new payment rate for previous work
        public 
        onlyTaskOrganizer(uint _taskId)
    {
        tasks[_taskId].budgetPerUnit = newBudgetPerUnit;
    }

    /**
     * @dev Function for contractor to withdraw assets if the job is completed.
     */
    function withdrawEverything(uint _taskId) 
        public 
        onlyAssignee(uint _taskId)
    {
        require(amountDue[taskId] > 0, "No amount left");
        (bool paidContractor, ) = payable(tasks[_taskId].assignee).call{value: amountDue[_taskId] }("");
        require(paidContractor, "Payment did not reach contractor");
        amountDue[_taskId] = 0;
        emit PaymentReceived(uint _taskId, msg.sender, amountDue[_taskId]);
    }

    /**
     * @dev Function for contractor to withdraw assets if the job has been partially completed.
     */
    function withdrawAmount(uint _taskId, uint64 unitsRequested) 
        public
        onlyAssignee(uint _taskId) 
    {
        require(amountDue[_taskId] >= unitsRequested * tasks[_taskId].budgetPerUnit  ,"Can't withdraw for more units than worked done.");
        (bool paidContractor, ) = payable(tasks[_taskId].assignee).call{value: unitsRequested * tasks[_taskId].budgetPerUnit }("");
        require(paidContractor, "Payment did not reach contractor");
        amountDue[_taskId] = amountDue[_taskId] - unitsRequested * tasks[_taskId].budgetPerUnit ;
        emit PaymentReceived(uint _taskId, msg.sender, unitsRequested * paymentperunit);
    }


    /**
     * @dev Function  to add contract invoice
     */
    function addInvoice(uint _taskId,uint256 _addUnits, uint256 _invoiceReleaseDate) 
        public 
        onlyTaskOrganizer(uint _taskId) 
    {
        Invoice memory newInvoice;
        newInvoice.invoiceNumber = invoiceRegister[_taskId].length + 1 ;
        newInvoice.numberUnits = _addUnits;
        newInvoice.amount = _addUnits * tasks[_taskId].budgetPerUnit ;
        newInvoice.invoiceReleaseDate = _invoiceReleaseDate;
        invoiceRegister[_taskId].push(newInvoice) ; 
        emit InvoiceEvent(uint _taskId, newInvoice.invoiceNumber,newInvoice.numberUnits,newInvoice.amount,newInvoice.invoiceReleaseDate);
    }

    /**
     * @dev Getter for invoice of any particular contractor address
     */
    function getInvoice(uint _taskId , uint256 _invoiceNumber)
        public
        view
        onlyAssigneeOrTaskOrganizer(_taskId)
        returns (Invoice memory)
    {
        require(_invoiceNumber >0 && _invoiceNumber <= invoiceRegister[_taskId].length, ,"No invoice for this number exists." ) ;
        return invoiceRegister[_taskId][_invoiceNumber-1] ;
    }

    /**
     * @dev Getter for invoice number of any particular contractor address
     */
    function getInvoiceByDate(uint _taskId, uint256 _invoiceReleaseDate)
        public
        view
        onlyAssigneeOrTaskOrganizer(_taskId)
        returns (Invoice memory)
    {
        for(int i=0; i++;i<invoiceRegister[_taskId].length){
            if(invoiceRegister[_taskId][i].invoiceReleaseDate == _invoiceReleaseDate){
                return invoiceRegister[_taskId][i]  ;
            }
        }
        Invoice memory emptyInvoice ;  // if incorrect invoice date provided
        return emptyInvoice ;
    }

    // /**  // Non-essential functionality - One can always look at their invoices
    //  * @dev Getter for the units withdrawn
    //  */
    // function getWithdrawnUnits() public view returns (uint64) {     // it is payment functionality
    //     return unitsWithdrawn;
    // }

    // /**
    //  * @dev Getter for the units left to be withdrawn
    //  */
    // function getUnitsLeftToBeWithdrawn() public view returns (uint64) {   
    //     return (unitsCompleted - unitsWithdrawn);
    // }



}
