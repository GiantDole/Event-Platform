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

// @Adrian: import OrganizationManager
import "./OrganizationManager.sol";
// @Adrian: TODO; import Job
contract Payment is OrganizationManager{
    event PaymentReceived(address from, uint256 amount);
    event PaymentReleased(address to, uint256 amount);

    //Will check later the view part of the variables and the reduncies of few varibales
    // @Adrian: JobID is known because payment inherits Job
    uint64 public jobID;
    address public contractoraddress;
    // @Adrian: Isn't budget equal to the balance locked in this smart contract?
    uint64 public budget;
    uint8 public percentCompleted;
    // @Adrian: adding units
    //          remove percentcompleted
    //          add functionality for units
    //          !! dont't forget units: contractors need to create invoice
    uint8 public unitsCompleted;
    uint8 public unitsWithdrawn;

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
    constructor(
        uint64 _jobID,
        address _contractoraddress,
        uint64 _budget,
        uint8 _percentCompleted,
        bool _completed
    ) payable onlyOwner() {
        jobID = _jobID; //Setting job ID
        contractoraddress = _contractoraddress;
        budget = _budget;
        percentCompleted = _percentCompleted;
        completed = _completed;
        require(
            msg.value == _budget,
            "Owner should deposit money equal to the budget"
        );

        emit PaymentReceived(msg.sender, msg.value);
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

    /**
     * @dev Getter for the contract balance
     */
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev Function for contractor to withdraw assets if the job has been fulfilled
     */
     // @Adrian: adapt: either completed or just withdraw commited units.
    function _withdraw() public {
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

    //JOB FACTORY
    //MSG.VALUE>BUDGET PAY THE REST
    //CHECK TJE NAMING CONVENTION
    //JOB ARRAY, JOB ID , CONTRCATOT ADDRESS
}
