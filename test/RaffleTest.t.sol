// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

import {DeployRaffle} from "../script/DeployRaffle.s.sol";
import {Raffle} from "../src/Raffle.sol";
import {Test, console} from "forge-std/Test.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract RaffleTest is Test {
    Raffle raffle;
    HelperConfig helperConfig;
    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint64 subscriptionId;
    uint32 callBackGasLimit;
    address linkAddress;

    address alice = makeAddr("Alice");
    address bob = makeAddr("Bob");
    uint256 constant INITIAL_BALANCE = 10 ether;

    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig) = deployer.run();
        (entranceFee, interval, vrfCoordinator, gasLane, subscriptionId, callBackGasLimit, linkAddress) =
            helperConfig.activeNetworkConfig();
        vm.deal(alice, INITIAL_BALANCE);
    }

    function testRaffleInitialStateIsOpen() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    function testRaffleRevertsWhenYouDontPayEnough() public {
        vm.prank(alice);
        vm.expectRevert(Raffle.Raffle__NotEnoughtETHSent.selector);

        raffle.enterRaffle();
    }

    function testRafflesAddsPlayersWhenTheyEnter() public {
        vm.prank(alice);

        raffle.enterRaffle{value: entranceFee}();
        address firstPlayer = raffle.getPlayer(0);

        assertEq(alice, firstPlayer);
    }

    function testEmitsEventOnEnter() public {
        vm.prank(alice);
        vm.expectEmit(true, false, false, false, address(raffle));
        emit Raffle.EnteredRaffle(alice);
        
        raffle.enterRaffle{value: entranceFee}();
        address firstPlayer = raffle.getPlayer(0);

        assertEq(alice, firstPlayer);
    }

    function testCantEnterWhenRaffleIsCalculating() public {
        vm.prank(alice);
       
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval +1);
        vm.roll(block.number + 1 );

        raffle.perfomUpkeep("");      
        vm.prank(alice);
        raffle.enterRaffle{value: entranceFee}();

        vm.expectRevert(Raffle.Raffle__NotOpen.selector);    


    }
}
