//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./OrganizationManager.sol";

///@title Owner can manage the organization team with this contract
///@dev when ownership is transferred, the owner will still be an organizer
contract JurorManager is OrganizationManager {
    //ddress[] private _organizers;
    /**
     * @dev if address maps to 0 (standard mapping) that address is not a juror
     *      if address maps to i > 0: that address is juror of category i
     *    
     */
    mapping(address => uint) _jurors;

    event JurorAdded(address indexed juror, uint category);
    event JurorRemoved(address indexed juror);

    constructor() {
        //_addOrganizer(msg.sender);
    }

    //So far no possibility to view all organizers
    //function organizers() public view returns(address[] memory) {
    //    return _organizers;
    //}

    modifier onlyJuror() {
        require(_jurors[msg.sender] != 0, "Callable: caller is not a juror");
        _;
    }

    modifier onlyJurorCategory(uint category) {
        require(category > 0, "Juror category is invalid");
        require(_jurors[msg.sender] == category, "Callable: caller is not a juror of specified category");
        _;
    }

    function isJuror(address _juror) public view returns(bool) {
        return _organizers[_juror] > 0 ? true : false;
    }

    function _addJuror(address _juror, uint _category) internal {
        _jurors[_juror] = _category;
        emit JurorAdded(_juror, _category);
    }

    function addJuror(address _juror, uint _category) public onlyOrganizer {
        require(_juror != address(0), "Jurors can't be the zero address!");
        require(_category > 0, "Juror category must be greater than zero!");
        _addJuror(_juror, _category);
    }

    function _removeJuror(address _juror) internal {
        _jurors[_juror] = 0;
        emit JurorRemoved(_juror);
    }

    function removeJuror(address _juror) public onlyOwner {
        require(_juror != msg.sender, "Juror cannot remove itself as Juror!");
        _removeJuror(_juror);
    }
}