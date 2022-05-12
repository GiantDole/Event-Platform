//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "./OrganizationManager.sol";

// task factory has only one job -> to create tasks

contract TaskFactory is OrganizationManager { 
 
    event TaskPosted(Task _task);                                           

    struct Task {
        string name;
        string desc;          
        uint64 id;            
        uint64 budgetPerUnit; //rate of the task
        uint16 totalUnits;    
        uint uintsCompleted ;
        address organizer ;
        address assignee ;
        bool isAssigned ;
    }

    Task[] internal tasks;
    mapping( uint => uint ) amountDue ;
    uint64 private idCount = 0 ;

    ///@notice only allow the task assignee to call the function
    modifier onlyAssignee(uint _taskId) {
        require(tasks[_taskId].assignee == msg.sender, "Callable: caller is not the task assignee");
        _;
    }

    modifier onlyTaskOrganizer(uint _taskId){
        require(tasks[_taskId].organizer == msg.sender, "Callable: caller is not the task organizer");
        _;
    }

    modifier onlyAssigneeOrTaskOrganizer(uint _taskId){
        require(tasks[_taskId].organizer == msg.sender || tasks[_taskId].assignee == msg.sender , "Callable: caller is neither the task assignee nor the task organizer");
        _;
    }


    function createTask(string memory _name, string memory _desc, uint64 _budgetPerUnit, uint8 _totalUnits) 
        public 
        onlyOrganizer() 
    {
        tasks.push( Task(_name, _desc, idCount, _budgetPerUnit, _totalUnits,0,msg.sender,address(0),false)) ;
        emit TaskPosted(tasks[idCount]);
        idCount++;
    }

    function viewAllPostings() 
        public 
        view returns(Task[] memory _tasks)
    {
        return tasks;
    }

    function getTaskOwner(uint _taskId) 
        public 
        view returns(address)
    {
        return tasks[_taskId].organizer ;
    }


    function viewOpenPostings() 
        public 
        view returns(Task[] memory _unassignedTasks)
    {
        Task[] memory unassignedTasks ;
        uint idx = 0 ;
        for (uint i; i < tasks.length; i++) {
            if (tasks[i].isAssigned == false) {
                unassignedTasks[idx] = tasks[i];
                idx++ ;
            }
        }
        return unassignedTasks;
    }

    function viewOrganizerTasks()                                               // organizer can view all his tasks
        public 
        view returns(Task[] memory _organizerTasks)
    {
        Task[] memory organizerTasks ;
        uint idx = 0 ;
        for (uint i; i < tasks.length; i++) {
            if (tasks[i].organizer == msg.sender) {
                organizerTasks[idx] = tasks[i];
                idx ++ ;
            }
        }
        return organizerTasks;
    }

    function viewAssigneeTasks()                                              // contractor can view all his tasks
        public 
        view returns(Task[] memory _workerTasks)
    {
        Task[] memory assigneeTasks ;
        uint idx = 0;
        for (uint i; i < tasks.length; i++) {
            if (tasks[i].assignee == msg.sender) {
                assigneeTasks[idx] =  tasks[i] ;
                idx ++ ;
            }
        }

        return assigneeTasks;
    }

}
