// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

contract Ballot {

    uint256 public toto = 777;
    string  private name = '';

    constructor(string memory name_, uint256 _number) {
        name = name_;
        toto = _number;
    }

    function _changeNumberofYouraddress(uint256 num, string memory _name) public {
        toto = num;
        name = _name;
    }

     function getChangedname() public view returns(string memory) {
        return name;
    }

}