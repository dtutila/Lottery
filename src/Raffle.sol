// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

contract Raffle {

    error Raffle__NotEnoughtETHSent();
    
    uint256 private immutable i_entranceFee;
    // @dev duration of lottery in seconds
    uint256 private immutable i_interval;
    
    address payable[] private s_players;
    uint256 private s_lastTimeStamp;
    /** Events */
    event  EnteredRaffle (address indexed player);


    constructor(uint256 entrance, uint256 interval) {
        i_entranceFee = entrance;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
    }

    function enterRaffle() external payable {
        if(msg.value < i_entranceFee) {
            revert Raffle__NotEnoughtETHSent();
        } 
        s_players.push(payable(msg.sender));
        emit EnteredRaffle(msg.sender);

    }

    function pickWinner() public {

    }

    /**
     * getters and setters
     */

    function getEntranceFee() external view returns(uint256 ) {
        return i_entranceFee;
    }


  
}