// SPDX-License_Identifier: MIT

pragma solidity 0.8.25;

import "./SimpleStorage.sol"/*importing*/; 

contract StorageFactory is SimpleStorage  /*inheritance*/ {
    
    SimpleStorage[] public simpleStorageArray; // to keep track of all simple storage contracts deployed
    
    function createSimpleStorageContract() public {
        //type        variablename
        SimpleStorage simpleStorage = new SimpleStorage();
        simpleStorageArray.push(simpleStorage);
    }
    
    // Deploying Contract from another contract.
    // Get the index of a contract, store a number in that contract.
    function sfStore(uint256 _simpleStorageIndex, uint256 _simpleStorageNumber) public{
        //Address
        //ABI (Application Binary Interface)
        SimpleStorage(address(simpleStorageArray[_simpleStorageIndex])).store(_simpleStorageNumber);
    }

    function sfGet(uint256 _simpleStorageIndex) public view returns (uint256){
        return SimpleStorage(address(simpleStorageArray[_simpleStorageIndex])).retrieve();
    }
} 