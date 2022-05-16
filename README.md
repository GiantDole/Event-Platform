# Web3Connects Freelancer Employment Platform
**Description**: Freelancing employment platform for employers to post jobs ("tasks"), for freelancers to apply to jobs/tasks, employers to review applications and accept an applicant for a job, and for employers and contractors alike to acknowledge job progress and exchange payment. Our immediate goal is to use such a platform to allow organizers of an event to keep track of tasks and find the most experienced person to fulfill each task that is needed, and pay them for their service. Implementing such a system on the blockchain allows for dynamic assignment and organization of resources and efficient tracking of all work and payments.


**Contract Types**: 
* **TaskFactory contracts**: Each instance of a TaskFactory contract represents one complete employment system, where jobs (“tasks”) are posted and viewed by any account with the appropriate permissions.
* **Task contracts**: Each instance of a Task contract represents one binding employment contract between employers and contractors. When a task is created within a TaskFactory instance, the task creator must specify the name and description of the job, the number of “progress units” that progress and compensation is to be specified in (e.g. if the contractor will be paid by the hour, this would be the total hours required for the job; or if the contractor will be paid in full once the job is complete, there would be only one “progress unit”), and the budget per unit (e.g. hourly wage in the former example or full compensation available for the task in the latter example). When the job is posted, the total budget required for the task is immediately debited from the task creator, such that freelancers have an assurance that the specified amount of payment will be available to them when and if they perform the task.  After the task contract is created, freelancers can apply for the position, and task organizers then can accept a single applicant for the task. Once an applicant is accepted, they can accept the job assignment. Once the task is assigned to a worker, both the worker and the employer can update their progress on the task, and finally, subject to approval by the employer, be paid for their progress.
* **OrganizationManager contracts**: Both TaskFactory and Task inherit from OrganizationManager to manage permissions across different functionality.

**Contract state variables:**
* **TaskFactory state variables**:
    * int64 private idCount: variable to keep track of how many tasks have been posted
    * Task[] private tasks: array of task contracts
*	**Task state variables**:
    * string public name: task name
    * string public desc: task description
    * uint64 public id: task ID
    * uint64 public budgetPerUnit: task budget per unit of progress
    * uint16 public progressUnits: number of “progress units” that the task requires to complete, with payment (in the amount of budgetPerUnit) available after a unit of progress is complete
    * uint16 public completedUnits: number of completed progress units (though these may not be approved for payment yet by an organizer)
    * uint16 public approvedUnits: number of progress units approved as complete by an organizer
    * uint16 withdrawnUnits: number of progress units for which payment has already been withdrawn
    * bool public isAssigned: indicator for whether the task has been assigned to a worker or not
* **OrganizationManager state variables**:
   * mapping(address => bool) _organizers: mapping to keep track of whether or not an address is an organizer


**Contract functions:**
* **TaskFactory functions**:
   * createTask(string memory _name, string memory _desc, uint64 _budgetPerUnit, uint8 _progressUnits) public onlyOrganizer() payable: creates a new task and deposits the total promised budget directly in the task contract
getTaskDetailsById(uint64 _id) public view returns(TaskDetails memory _taskDetails): retrieves task details by task ID
   * getTaskById(uint64 _id) public view returns(Task _task): retrieves task contract by task ID
   * viewOpenPostings() public view returns(TaskDetails[] memory _unassignedTaskDetails): returns details of all tasks that are currently unassigned to a worker
   * viewOrganizerTasks() public view returns(TaskDetails[] memory _organizerTaskDetails): returns details of all tasks of which the caller has task organizer privileges
   * viewWorkerTasks() public view returns(TaskDetails[] memory _workerTaskDetails): returns details of all tasks assigned to the caller (i.e. caller is the worker)
* **Task functions**:
   * function applyTo() public: function for the caller to apply for the task
   * function withdrawApplication() public: function for the caller to withdraw their application from the task
   * function viewApplicants() public view onlyOrganizer() returns (address[] memory _currApplicants): returns the list of current applicants for the job
   * function acceptApplicant(address _applicant) public onlyOrganizer(): function to accept an applicant for the task
   * function acceptAssignment() public onlyApproved(): function for the caller to accept assignment to the task (once they are approved)
   * function updateProgress(uint8 _addUnits) public onlyAssigneeOrOrganizer(): function for either the assigned worker or the organizer to update the completed progress units
   * function approveProgress() public onlyOrganizer(): function for the organizer to approve a progress update, if requested by the assigned worker
   * function withdrawAmount(uint16 unitsRequested) public onlyAssignee(): function for the caller (who can only be the task assignee) to withdraw payment from the contract, if approved to do so based on progress
* **OrganizationManager functions**:
   * isOrganizer(address _organizer) public view returns(bool): return Boolean indicator of whether the input address is an organizer
   * addOrganizer(address _organizer) public onlyOwner: add an organizer of the contract
   * removeOrganizer(address _organizer) public onlyOwner: remove an organizer from the contract


