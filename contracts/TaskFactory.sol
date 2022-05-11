//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "./OrganizationManager.sol";


// task factory has one and only one use - to create tasks . No other functionality

contract TaskFactory is OrganizationManager { 
 
    event TaskPosted(Task _task);                                           

    struct Task {
        string public name;
        string public desc;          
        uint64 public id;            
        uint64 public budgetPerUnit; //rate of the task
        uint16 public totalUnits;    
        bool isAssigned ;
    }

    Task[] private tasks;
    mapping (uint => address) public taskToOwner;
    mapping (uint => address) public taskToContractor ;
    uint64 private idCount = 0 ;


    function createTask(string memory _name, string memory _desc, uint64 _budgetPerUnit, uint8 _totalUnits) 
        public 
        onlyOrganizer() 
    {
        tasks.push( new Task(_name, _desc, idCount, _budgetPerUnit, _totalUnits,false,msg.sender)) ;
        taskToOwner[idCount] = msg.sender;
        emit TaskPosted(tasks[idCount]);
        idCount++;
    }

    function viewAllPostings() 
        public 
        view returns(Task[] memory _tasks)
    {
        return tasks;
    }

    function getTaskOwner(uint _id) 
        public 
        view returns(address)
    {
        return taskToOwner[_id];
    }

    ///@notice view open postings that have not been assigned yet
    ///@dev SHOULD THIS JUST BE DONE ON FRONT-END? I THINK MAYBE!!!

    function viewOpenPostings() 
        public 
        view returns(Task[] memory _unassignedTasks)
    {
        Task[] memory unassignedTasks ;
        for (uint i; i < tasks.length; i++) {
            if (tasks[i].isAssigned == false) {
                unassignedTasks.push(tasks[i]);
            }
        }
        return unassignedTasks;
    }

    function viewOrganizerTasks()                                               // organizer can view all his tasks
        public 
        view returns(Task[] memory _organizerTasks)
    {
        Task[] memory organizerTasks ;
        for (uint i; i < tasks.length; i++) {
            if (taskToOwner[i] == msg.sender) {
                organizerTasks.push(tasks[i]);
            }
        }
        return organizerTasks;
    }

    ///@notice view worker tasks
    ///@dev SHOULD THIS JUST BE DONE ON FRONT-END? I THINK MAYBE!!!
    function viewContractorTasks()                                              // contractor can view all his tasks
        public 
        view returns(Task[] memory _workerTasks)
    {
        Task[] memory contractorTasks ;
        for (uint i; i < tasks.length; i++) {
            if (taskToContractor[i] == msg.sender) {
                contractorTasks.push(tasks[i]) ;
            }
        }

        return contractorTasks;
    }



    ///@notice apply to accept a task
    // function applyToTask(uint64 _id) public {
    //     tasks[_id].applyTo(msg.sender);
    //     emit TaskApplicationCompleted(_id, msg.sender);
    // }

    ///@notice withdraw application to task
    // function withdrawTaskApplication(uint64 _id) public {
    //     tasks[_id].withdrawApplication(msg.sender);
    //     emit TaskApplicationWithdrawn(_id, msg.sender);
    // }

    ///@notice view applicants for a task
    ///@dev only an organizer of the task can do so
    ///@dev public view function -- no gas needed
    // function viewApplicants(uint64 _id) public view returns (address[] memory _applicants) {
    //     return tasks[_id].viewApplicants();
    // }

    //@notice accept task Applicant
    // function acceptTaskApplicant(uint64 _id, address _applicant) public {
    //     tasks[_id].acceptApplicant(_applicant);
    //     emit TaskApplicantAccepted(_id, _applicant);
    // }

    ///@notice accept task assignment
    ///@dev tasks can only be accepted by approved applicants
    // function acceptTaskAssignment(uint64 _id) public { 
    //     tasks[_id].acceptAssignment(msg.sender);
    //     workerTasks[msg.sender].push(_id);
    //     emit TaskAssigned(_id, msg.sender);
    // }

}
