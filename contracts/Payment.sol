//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

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
    
    event PaymentReceived(uint taskId, address from, uint amount);
    event PaymentReleased(uint taskId, address to, uint amount);
    event InvoiceEvent(uint taskId, uint _invoiceNumber ,uint _numberUnits,uint _amount,uint _invoiceReleaseDate);

    struct Invoice {
        uint invoiceNumber;
        uint numberUnits;
        uint amount;
        uint invoiceReleaseDate;
    }

    mapping(uint => Invoice[]) invoiceRegister ;              

    
    function deposit(uint _taskId, uint _addUnits)
        public 
        payable
        onlyTaskOrganizer(_taskId)
    {
        uint budget =  _addUnits * tasks[_taskId].budgetPerUnit ;
        require(msg.value != budget,"Owner should deposit money in accordance with budget per unit ");
        amountDue[_taskId] += tasks[_taskId].budgetPerUnit * _addUnits ;
        emit PaymentReleased(_taskId,msg.sender, budget);
    }

    function updateBudgetPerUnit(uint _taskId, uint newBudgetPerUnit)             // you can make this function payable if you want to make payments as per new payment rate for previous work
        public 
        onlyTaskOrganizer(_taskId)
    {
        tasks[_taskId].budgetPerUnit = newBudgetPerUnit;
    }

    /**
     * @dev Function for contractor to withdraw assets if the job is completed.
     */
    function withdrawEverything(uint _taskId) 
        public 
        onlyAssignee(_taskId)
    {
        require(amountDue[_taskId] > 0, "No amount left");
        (bool paidContractor, ) = payable(tasks[_taskId].assignee).call{value: amountDue[_taskId] }("");
        require(paidContractor, "Payment did not reach contractor");
        amountDue[_taskId] = 0;
        emit PaymentReceived(_taskId, msg.sender, amountDue[_taskId]);
    }

    /**
     * @dev Function for contractor to withdraw assets if the job has been partially completed.
     */
    function withdrawAmount(uint _taskId, uint unitsRequested) 
        public
        onlyAssignee(_taskId) 
    {
        require(amountDue[_taskId] >= unitsRequested * tasks[_taskId].budgetPerUnit  ,"Can't withdraw for more units than worked done.");
        (bool paidContractor, ) = payable(tasks[_taskId].assignee).call{value: unitsRequested * tasks[_taskId].budgetPerUnit }("");
        require(paidContractor, "Payment did not reach contractor");
        amountDue[_taskId] = amountDue[_taskId] - unitsRequested * tasks[_taskId].budgetPerUnit ;
        emit PaymentReceived(_taskId, msg.sender, unitsRequested * tasks[_taskId].budgetPerUnit);
    }


    /**
     * @dev Function  to add contract invoice
     */
    function addInvoice(uint _taskId,uint _addUnits, uint _invoiceReleaseDate) 
        public 
        onlyTaskOrganizer(_taskId) 
    {
        Invoice memory newInvoice;
        newInvoice.invoiceNumber = invoiceRegister[_taskId].length + 1 ;
        newInvoice.numberUnits = _addUnits;
        newInvoice.amount = _addUnits * tasks[_taskId].budgetPerUnit ;
        newInvoice.invoiceReleaseDate = _invoiceReleaseDate;
        invoiceRegister[_taskId].push(newInvoice) ; 
        emit InvoiceEvent(_taskId, newInvoice.invoiceNumber,newInvoice.numberUnits,newInvoice.amount,newInvoice.invoiceReleaseDate);
    }

    /**
     * @dev Getter for invoice of any particular contractor address
     */
    function getInvoice(uint _taskId , uint _invoiceNumber)
        public
        view
        onlyAssigneeOrTaskOrganizer(_taskId)
        returns (Invoice memory)
    {
        require( _invoiceNumber >0 && _invoiceNumber <= invoiceRegister[_taskId].length , "No invoice for this number exists." ) ;
        return invoiceRegister[_taskId][_invoiceNumber-1] ;
    }

    /**
     * @dev Getter for invoice number of any particular contractor address
     */
    function getInvoiceByDate(uint _taskId, uint _invoiceReleaseDate)
        public
        view
        onlyAssigneeOrTaskOrganizer(_taskId)
        returns (Invoice memory _invoiceByDate)
    {
        for(uint i=0; i < invoiceRegister[_taskId].length ; i++ ){
            if(invoiceRegister[_taskId][i].invoiceReleaseDate == _invoiceReleaseDate){
                return invoiceRegister[_taskId][i]  ;
            }
        }
        Invoice memory emptyInvoice ;  // if incorrect invoice date provided
        return emptyInvoice ;
    }


}
