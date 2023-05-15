// SPDX-License-Identifier: MIT
// Metaline Contracts (ArrayHelper.sol)

pragma solidity ^0.8.0;

library ArrayHelper {
    function remove(uint[] storage array, uint index) external {
        require(index < array.length && array.length > 0, "out of array range");

        for(uint i=index; i < array.length - 1; ++i) {
            array[i] = array[i+1];
        }
        array.pop();
    }
}