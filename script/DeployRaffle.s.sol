// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfog.s.sol";

contract DeployRaffle is Script {

    function run () external returns (Raffle){
        HelperConfig helperConfig = new HelperConfig();
        (
            uint256 entranceFee, 
        uint256 interval, 
        address vrfCoordinator, 
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callBackGasLimit
        ) = helperConfig.activeNetworkConfig();
    }

}