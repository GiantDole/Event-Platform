//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../libraries/Ownable.sol";

///@title Owner can manage the organization team with this contract
///@dev when ownership is transferred, the owner will still be an organizer
contract OrganizationManager is Ownable {
    //ddress[] private _organizers;
    /**
     * @dev if address maps to 1 that address is an organizer
     *      if it maps to 0 (standard mapping) that address is not an organizer
     *    
     */
    mapping(address => uint) _organizers;

    event OrganizerAdded(address indexed organizer);
    event OrganizerRemoved(address indexed organizer);

    /**
     * @dev organizer is already transferred through the constructor of Ownable
     *      and the overwritten function _transferOwnership
     *      the implementation makes sure that the owner is also always an organizer
     */
    constructor() {
        //_addOrganizer(msg.sender);
    }

    //So far no possibility to view all organizers
    //function organizers() public view returns(address[] memory) {
    //    return _organizers;
    //}

    modifier onlyOrganizer() {
        require(_organizers[msg.sender] == 1, "Callable: caller is not an organizer");
        _;
    }

    function isOrganizer(address _organizer) public view returns(bool) {
        return _organizers[_organizer] == 1 ? true : false;
    }


    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Overrides and complements ownership transfer in Ownable contract by adding new owner as organizer
     * This method leaves the old owner as organizer though.
     * What happens if we call the public transferOwnership function in Ownable?
     * Will this method be used?
     */
    function _transferOwnership(address _newOwner) internal override {
        Ownable._transferOwnership(_newOwner);
        _addOrganizer(_newOwner);
    }

    function _addOrganizer(address _organizer) internal {
        _organizers[_organizer] = 1;
        emit OrganizerAdded(_organizer);
    }

    function addOrganizer(address _organizer) public onlyOwner {
        require(_organizer != address(0), "Organizer can't be the zero address!");
        _addOrganizer(_organizer);
    }

    function _removeOrganizer(address _organizer) internal {
        _organizers[_organizer] = 0;
        emit OrganizerRemoved(_organizer);
    }

    function removeOrganizer(address _organizer) public onlyOwner {
        require(_organizer != msg.sender, "Owner cannot remove itself as Organizer!");
        _removeOrganizer(_organizer);
    }
}
