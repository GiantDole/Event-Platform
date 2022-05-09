//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract test2 {
    uint64 public budget;
    uint8 public percentCompleted;
    uint64 public jobID;
    address public contractoraddress;

    // @Adrian: adding units
    //          remove percentcompleted
    //          add functionality for units
    //          !! dont't forget units: contractors need to create invoice
    uint64 public unitsCompleted;
    uint64 public unitsWithdrawn = 0;
    uint64 public totalunit;
    uint64 public paymentperunit;
    bool public completed;

    function deposit(
        uint64 _jobID,
        address _contractoraddress,
        uint64 _totalunit,
        uint64 _paymentperunit,
        uint8 _percentCompleted,
        bool _completed
    ) public payable {
        jobID = _jobID; //Setting job ID
        contractoraddress = _contractoraddress;
        paymentperunit = _paymentperunit;
        budget = _totalunit * _paymentperunit;
        percentCompleted = _percentCompleted;
        completed = _completed;

        require(
            msg.value >= budget,
            "XYZ should deposit money equal to the budget"
        );
        if (msg.value >= budget) {
            (bool paidContractor, ) = payable(msg.sender).call{
                value: (address(this).balance - budget)
            }("");
        }
    }

    function _withdrawOnEntireJobCompletion() public {
        require(
            msg.sender == contractoraddress,
            "Only the contractor can withdraw the payment."
        );

        (bool paidContractor, ) = payable(contractoraddress).call{
            value: address(this).balance
        }("");
        require(paidContractor, "Payment did not reach contractor");
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
    }
}
