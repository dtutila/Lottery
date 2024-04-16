// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

import {DeployRaffle} from "../script/DeployRaffle.s.sol";
import {Raffle} from "../src/Raffle.sol";
import {Test} from "forge-std/Test.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {Vm} from "forge-std/Vm.sol";
import {VRFCoordinatorV2Mock} from "./mocks/VRFCoordinatorV2Mock.sol";

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
    uint256 deployerKey;
    address alice = makeAddr("Alice");
    uint256 constant INITIAL_BALANCE = 10 ether;

    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig) = deployer.run();
        (
            interval,  
            entranceFee,
            deployerKey
        ) = helperConfig.activeNetworkConfig();
        (
            vrfCoordinator,
            linkAddress,   
            gasLane,
            subscriptionId,  
            callBackGasLimit
        ) = helperConfig.activeVFRConfig();
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

    function notestCantEnterWhenRaffleIsCalculating() public {
        vm.prank(alice);

        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        raffle.perfomUpkeep("");
        vm.prank(alice);
        raffle.enterRaffle{value: entranceFee}();

        vm.expectRevert(Raffle.Raffle__NotOpen.selector);
    }

    //upcheck

    function testCheckUpkeepReturnsFalseIfHasNoBalance() public {
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        (bool upkeepNeeded,) = raffle.checkUpKeep("");

        assert(!upkeepNeeded);
    }

    function testCheckUpkeepReturnsFalseIfRaffleIsNotOpen() public {
        vm.prank(alice);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffle.perfomUpkeep("");

        (bool upkeepNeeded,) = raffle.checkUpKeep("");

        assert(!upkeepNeeded);
    }

    //perfomUpkeep
    function testPerformUpkeepCAnOnlyRunIfCheckUpkeepIsTrue() public {
        vm.prank(alice);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        raffle.perfomUpkeep("");
    }

    function testPerformUpkeepCAnOnlyRunIfCheckUpkeepIsFalse() public {
        uint256 balance = 0;
        uint256 numPlayers = 0;
        uint256 raffleState = 0;

        vm.expectRevert(
            abi.encodeWithSelector(Raffle.Raffle__UpkeopNotNeeded.selector, balance, numPlayers, raffleState)
        );
        raffle.perfomUpkeep("");
    }

    modifier raffleEnteredAndTimePassed() {
        vm.prank(alice);

        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        _;
    }

    function testPerformUpkeekUpdateRaffleStateAndEmitRequestId() 
    public 
    raffleEnteredAndTimePassed 
    {
        vm.recordLogs();
        raffle.perfomUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();

        bytes32 requestId = entries[1].topics[1];
        Raffle.RaffleState rstate = raffle.getRaffleState();

        assert(uint256(requestId) > 0);
        assertEq(2, uint256(rstate));
    }

    //fulfill random words

    function testFulfillRandomWordsCanOnlyBeCalledAfterPerformUpkeep(
        uint256 randomTestId
        ) public  raffleEnteredAndTimePassed
    {
        vm.expectRevert("nonexistent request");
        VRFCoordinatorV2Mock(vrfCoordinator).fulfillRandomWords(randomTestId, address(raffle));
    }

    function testFulfillRandomWordsPinksAWinerResetAndSendPrize() 
    public 
    raffleEnteredAndTimePassed 
    {
        uint256 additionalEntrants = 5;
        uint256 startingIndex = 1;
        for (uint256 i = startingIndex; i < startingIndex + additionalEntrants; i++) {
            address player = address(uint160(i));
            hoax(player, INITIAL_BALANCE);
            raffle.enterRaffle{value: entranceFee}();   
        }

        uint256 prize = entranceFee * (additionalEntrants + 1);
        //getting requestId
        vm.recordLogs();
        raffle.perfomUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];
        uint256 previousTimeStamp = raffle.getLastTimeStamp();

         VRFCoordinatorV2Mock(vrfCoordinator).fulfillRandomWords(
            uint256(requestId), 
            address(raffle)
            );

        assert(uint256(raffle.getRaffleState()) == 0);
        assert(raffle.getRecentWinner() != address(0));
        assert(raffle.getLengthOfPlayers() == 0);
        assert(previousTimeStamp < raffle.getLastTimeStamp());
        assert(raffle.getRecentWinner().balance == INITIAL_BALANCE + prize - entranceFee);

    }
}
