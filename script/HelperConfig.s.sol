// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2Mock} from "../test/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";

contract HelperConfig is Script {
    struct NetworkCofig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint64 subscriptionId;
        uint32 callBackGasLimit;
        address linkAddress;
    }

    NetworkCofig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaConfig();
        } else {
            activeNetworkConfig = getAnvilConfig();
        }
    }

    function getSepoliaConfig() public pure returns (NetworkCofig memory) {
        return NetworkCofig({
            entranceFee: 0.01 ether,
            interval: 30,
            vrfCoordinator: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            subscriptionId: 0,
            callBackGasLimit: 500000,
            linkAddress: 0x779877A7B0D9E8603169DdbD7836e478b4624789
        });
    }

    function getAnvilConfig() public returns (NetworkCofig memory) {
        if (activeNetworkConfig.vrfCoordinator != address(0)) {
            return activeNetworkConfig;
        }
        uint96 _baseFee = 0.25 ether;
        uint96 _gasPriceLink = 1e9;
        vm.startBroadcast();
        VRFCoordinatorV2Mock vrfMock = new VRFCoordinatorV2Mock(_baseFee, _gasPriceLink);
        LinkToken linkToken = new LinkToken();
        vm.stopBroadcast();
        return NetworkCofig({
            entranceFee: 0.01 ether,
            interval: 30,
            vrfCoordinator: address(vrfMock),
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            subscriptionId: 0,
            callBackGasLimit: 500000,
            linkAddress: address(linkToken)
        });
    }
}
