// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract GetTime {

    function getTime() external view returns(uint time) {
        time = block.timestamp;
    }
}