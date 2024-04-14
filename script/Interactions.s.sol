// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";

contract CreateSubscription is Script {

    function createSunscriptionusingConfig() public returns (uint64) {
        HelperConfig helperConfig = new HelperConfig();
         (
            ,
            ,
            address vrfCoordinator,
            ,
            ,
            ,
            address linkAddress
        ) = helperConfig.activeNetworkConfig();
        return createSubscription(vrfCoordinator);
    }

    function createSubscription(address vrfCoordinator) public returns (uint64) {
        console.log('creating subscription for chainid: ', block.chainid);
        vm.startBroadcast();
        uint64 subscriptionId = VRFCoordinatorV2Mock(vrfCoordinator).createSubscription();
       
        vm.stopBroadcast();

        console.log('subscriptionId: ', subscriptionId);
        return subscriptionId;    
    }

    function run() external returns (uint64){
        return createSunscriptionusingConfig();
    }


}

contract FundSubscription is Script {
    uint96 public constant FUND_AMOUNT = 3 ether;
    
    function fundSubscriptionUsingConfig() public {
        HelperConfig helperConfig = new HelperConfig();
        (
            ,
            ,
            address vrfCoordinator,
            ,
            uint64 subscriptionId,
            ,
            address linkAddress
        ) = helperConfig.activeNetworkConfig();
        fundSubscription(vrfCoordinator, subscriptionId, linkAddress);

    }

    function fundSubscription(address vrfCoordinator, uint64 subscriptionId, address linkAddress) public {
        console.log('vrfCoordinator > ', vrfCoordinator);
        console.log('subscriptionId > ', subscriptionId);
        console.log('linkAddress > ', linkAddress);
        console.log('chainId > ', block.chainid);
        if (block.chainid == 31337) {
            vm.startBroadcast();
            VRFCoordinatorV2Mock(vrfCoordinator).fundSubscription(subscriptionId, FUND_AMOUNT);
            vm.stopBroadcast();
        } else {
            LinkToken(linkAddress).transferAndCall(
                vrfCoordinator,
                FUND_AMOUNT,
                abi.encode(subscriptionId)
            );
        }
        
       
    }

    function run() external {
        fundSubscriptionUsingConfig();
    }

}
