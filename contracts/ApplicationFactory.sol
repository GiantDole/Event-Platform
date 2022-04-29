//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./OrganizationManager.sol";


/**
 * @dev start with application system that stores ratings on another database
 */
contract ApplicationFactory is OrganizationManager {

    event ApplicationSubmitted(uint id);
    event ApplicationAccepted(uint id);

    struct Application {
        string name;
        //enforce: max length of 5
        string[] links;
        //enforce: max length of 10
        //can a person be on several teams?
        //create person struct?
        address[] team;
        /**
         * @dev status can take the following values:
         *     -1: withdrawn; denies
         *      0: applied
         *      1: under review
         *      2: moving to next reviewing phase
         *      3: denied
         *      4: accepted to event
         */
        uint8 status;
    }

    Application[] public applications;

    /**
     *  @dev indicates the number of reviewing rounds including pitch competition
     */
    uint private rounds;

    modifier validStatus(uint _id){
        uint status = applications[_id].status;
        require(status >= 0; "Application was rejected!");
        require(status <= rounds; "Application has already final status!");
        _;
    }

    constructor(uint _rounds) {
        rounds = _rounds;
    }

    function _createApplication(string memory _name, string[] memory _links, address[] memory _team) public{
        applications.push(Application(_name, _links, _team,0));
        emit ApplicationSubmitted(applications.length-1);
    }

    /**
     *  @dev setting status to under review
     */
    function _acceptApplication(uint _id) public onlyOrganizer(),validStatus(_id){
        applications[_id].status=1;
        emit ApplicationAccepted(_id);
    }

    function _rejectApplication(uint _id) public onlyOrganizer(){
        applications[_id].status=-1;
    }

    function _moveToNextPhase(uint _id) public onlyOrganizer(),validStatus(_id){
        uint status = applications[_id].status;
        require(status <= rounds,"this project is ");
        applications[_id].status+=1;
    }

    function _
}