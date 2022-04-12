// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract translateNumber {

    function getRandomNumber(uint randomNumber, uint i, uint modulo) external pure returns (uint newNumber) {
        newNumber = uint(keccak256(abi.encodePacked(randomNumber,i))) % modulo;
    }


}