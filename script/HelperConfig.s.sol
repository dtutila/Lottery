// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2Mock} from "../test/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";

contract HelperConfig is Script {
    uint256 public constant DEFAULT_ANVIL_PRIVATEKEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    struct NetworkCofig {
        uint256 interval;
        uint256 entranceFee;
        uint256 deployerKey;
    }
    struct VFRNetworkConfig {
        address vrfCoordinator;
        address linkAddress;
        bytes32 gasLane;
        uint64 subscriptionId;
        uint32 callBackGasLimit;
        
       
    }

    NetworkCofig public activeNetworkConfig;
    VFRNetworkConfig public activeVFRConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaConfig();
            activeVFRConfig = getSepoliaVRFConfig();
        } else {
            activeNetworkConfig = getAnvilConfig();
            activeVFRConfig = getAnvilVRFConfig();
        }
    }

    function getSepoliaVRFConfig() public pure returns (VFRNetworkConfig memory) {
        return VFRNetworkConfig({
            vrfCoordinator: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            subscriptionId: 0, //11082
            callBackGasLimit: 500000,
            linkAddress: 0x779877A7B0D9E8603169DdbD7836e478b4624789
        });
    }
    function getSepoliaConfig() public view returns (NetworkCofig memory) {
        return NetworkCofig({
            interval: 30,
            entranceFee: 0.01 ether,
            deployerKey : vm.envUint("PRIVATE_KEY")
        });
    }
    function getAnvilConfig() public view returns (NetworkCofig memory) {
        if (activeNetworkConfig.interval != 0) {
            return activeNetworkConfig;
        }
        return NetworkCofig({
            interval: 30,
            entranceFee: 0.01 ether,
            deployerKey : DEFAULT_ANVIL_PRIVATEKEY
        });
    }
    function getAnvilVRFConfig() public returns (VFRNetworkConfig memory) {
        if (activeVFRConfig.vrfCoordinator != address(0)) {
            return activeVFRConfig;
        }
        uint96 _baseFee = 0.25 ether;
        uint96 _gasPriceLink = 1e9;
        vm.startBroadcast();
        VRFCoordinatorV2Mock vrfMock = new VRFCoordinatorV2Mock(_baseFee, _gasPriceLink);
        LinkToken linkToken = new LinkToken();
        vm.stopBroadcast();
        return VFRNetworkConfig({
            vrfCoordinator: address(vrfMock),
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            subscriptionId: 0,
            callBackGasLimit: 500000,
            linkAddress: address(linkToken)
        });
    }
    
}
