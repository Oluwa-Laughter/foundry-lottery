//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubscription} from "./Interactions.s.sol";

contract DeployRaffle is Script {
    function run() external returns (Raffle) {}

    function deployRaffle() external returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();

        HelperConfig.NetworkConfig memory networkConfig = helperConfig.getConfig();

        if (networkConfig.subId == 0) {
            CreateSubscription createSubscription = new CreateSubscription();
            (networkConfig.subId, networkConfig.vrfCoordinator) =
                createSubscription.createSubscription(networkConfig.vrfCoordinator);
        }

        vm.startBroadcast();
        Raffle raffle = new Raffle(
            networkConfig.entranceFee,
            networkConfig.interval,
            networkConfig.vrfCoordinator,
            networkConfig.gasLane,
            networkConfig.subId,
            networkConfig.callbackGasLimit
        );
        vm.stopBroadcast();

        return (raffle, helperConfig);
    }
}
