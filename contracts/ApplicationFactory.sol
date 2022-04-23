//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./OrganizationManager.sol";

contract ApplicationFactory is OrganizationManager {

    struct Application {
        string name;
        //enforce: max length of 5
        string[] links;
        //enforce: max length of 10
        //can a person be on several teams?
        //create person struct?
        string[] team;
        uint32 id;
        /**
         * @dev status can take the following values:
         *      0: applied
         *      1: under review
         *      2: moving to next reviewing phase
         *      3: denied
         *      4: accepted to event
         */
        uint8 status;
    }

    constructor() {

    }

    function _createApplication(string memory _name, string[] memory _links, string[] memory _team) public{

    }


}