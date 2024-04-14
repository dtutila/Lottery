// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "test/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract CreateSubscription is Script {
    function createSunscriptionusingConfig() public returns (uint64) {
        HelperConfig helperConfig = new HelperConfig();
        (,, address vrfCoordinator,,,,) = helperConfig.activeNetworkConfig();
        return createSubscription(vrfCoordinator);
    }

    function createSubscription(address vrfCoordinator) public returns (uint64) {
        console.log("creating subscription for chainid: ", block.chainid);

        vm.startBroadcast();
        uint64 subscriptionId = VRFCoordinatorV2Mock(vrfCoordinator).createSubscription();
        vm.stopBroadcast();

        return subscriptionId;
    }

    function run() external returns (uint64) {
        return createSunscriptionusingConfig();
    }
}

contract FundSubscription is Script {
    uint96 public constant FUND_AMOUNT = 3 ether;

    function fundSubscriptionUsingConfig() public {
        HelperConfig helperConfig = new HelperConfig();
        (,, address vrfCoordinator,, uint64 subscriptionId,, address linkAddress) = helperConfig.activeNetworkConfig();

        if (subscriptionId == 0) {
            CreateSubscription createSubscription = new CreateSubscription();
            uint64 updatedSubscriptionId = createSubscription.run();
            subscriptionId = updatedSubscriptionId;
            //vrfCoordinator = updatedVRFCoordinator;
        }

        fundSubscription(vrfCoordinator, subscriptionId, linkAddress);
    }

    function fundSubscription(address vrfCoordinator, uint64 subscriptionId, address linkAddress) public {
        console.log("fundSubscription_vrfCoordinator > ", vrfCoordinator);
        console.log("fundSubscription_subscriptionId > ", subscriptionId);
        console.log("fundSubscription_linkAddress > ", linkAddress);
        console.log("fundSubscription_chainId > ", block.chainid);
        if (block.chainid == 31337) {
            vm.startBroadcast();
            VRFCoordinatorV2Mock(vrfCoordinator).fundSubscription(subscriptionId, FUND_AMOUNT);
            vm.stopBroadcast();
        } else {
            LinkToken(linkAddress).transferAndCall(vrfCoordinator, FUND_AMOUNT, abi.encode(subscriptionId));
        }
    }

    function run() external {
        fundSubscriptionUsingConfig();
    }
}

contract AddConsumer is Script {
    function addConsumerUsingConfig(address raffleAddress) public {
        HelperConfig helperConfig = new HelperConfig();
        (,, address vrfCoordinator,, uint64 subscriptionId,,) = helperConfig.activeNetworkConfig();
        addConsumer(raffleAddress, vrfCoordinator, subscriptionId);
    }

    function addConsumer(address consumer, address vrfCoordinator, uint64 subscriptionId) public {
        console.log("addConsumer_vrfCoordinator > ", vrfCoordinator);
        console.log("addConsumer_subscriptionId > ", subscriptionId);
        console.log("addConsumer_consumer > ", consumer);
        console.log("addConsumer_chainId > ", block.chainid);

        vm.startBroadcast();
        VRFCoordinatorV2Mock(vrfCoordinator).addConsumer(subscriptionId, consumer);
        vm.stopBroadcast();
    }

    function run() external {
        address raffle = DevOpsTools.get_most_recent_deployment("Raffle", block.chainid);

        addConsumerUsingConfig(address(raffle));
    }
}
