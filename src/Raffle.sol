// Layout of Contract:
// license
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
// internal & private view & pure functions
// external & public view & pure functions

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {
    VRFConsumerBaseV2Plus
} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";

import {
    VRFV2PlusClient
} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/**
 * @title Raffle Contract
 * @notice This contract is not intended for production use.
 * @author Oluwa-Laughter
 * @dev This contract implements a simple raffle system where users can enter by paying an entrance fee.
 */

contract Raffle is VRFConsumerBaseV2Plus {
    error Raffle__SendEnoughETH();

    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    uint256 private immutable ENTRANCE_FEE;
    uint256 private immutable INTERVAL;
    bytes32 private immutable KEY_HASH;
    uint256 private immutable SUB_ID;
    uint32 private immutable CALLBACK_GAS_LIMIT;

    address payable[] private s_players;
    uint256 private s_lastTimeStamp;

    event RaffleEntered(address indexed player);

    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 gasLane,
        uint256 subId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        ENTRANCE_FEE = entranceFee;
        INTERVAL = interval;
        s_lastTimeStamp = block.timestamp;
        KEY_HASH = gasLane;
        SUB_ID = subId;
        CALLBACK_GAS_LIMIT = callbackGasLimit;
    }

    function enterRaffle() external payable {
        // require(msg.value >= ENTRANCE_FEE, "Not Enough ETH sent");
        // require(msg.value >= ENTRANCE_FEE, Raffle__SendEnoughETH());

        if (msg.value < ENTRANCE_FEE) {
            revert Raffle__SendEnoughETH();
        }

        s_players.push(payable(msg.sender));

        emit RaffleEntered(msg.sender);
    }

    function pickWinner() external {
        if ((block.timestamp - s_lastTimeStamp) > INTERVAL) {
            revert();
        }

        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient
            .RandomWordsRequest({
                keyHash: KEY_HASH,
                subId: SUB_ID,
                requestConfirmations: REQUEST_CONFIRMATIONS,
                callbackGasLimit: CALLBACK_GAS_LIMIT,
                numWords: NUM_WORDS,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: true})
                )
            });

        uint256 requestId = s_vrfCoordinator.requestRandomWords(request);
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] calldata randomWords
    ) internal virtual override {}

    /**
     * Getter Functions
     */

    function getEntranceFee() public view returns (uint256) {
        return ENTRANCE_FEE;
    }
}
