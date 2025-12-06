// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/// @title LottyVRF
/// @notice Chainlink VRF integration for fair prize draws
abstract contract LottyVRF is VRFConsumerBaseV2Plus {

    // Chainlink VRF Config for Base
    // Note: Check docs.chain.link for current Base addresses
    uint256 public subscriptionId;
    bytes32 public keyHash;
    uint32 public callbackGasLimit = 100000;
    uint16 public requestConfirmations = 3;
    uint32 public numWords = 1;

    mapping(uint256 => uint256) public vrfRequestToDrawId;
    mapping(uint256 => uint256) public drawRandomWords;

    event RandomnessRequested(uint256 requestId, uint256 drawId);
    event RandomnessFulfilled(uint256 requestId, uint256 drawId, uint256 randomWord);

    constructor(
        address _vrfCoordinator,
        uint256 _subscriptionId,
        bytes32 _keyHash
    ) VRFConsumerBaseV2Plus(_vrfCoordinator) {
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
    }

    function _requestRandomness(uint256 drawId) internal returns (uint256 requestId) {
        requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: keyHash,
                subId: subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                extraArgs: ""
            })
        );

        vrfRequestToDrawId[requestId] = drawId;
        emit RandomnessRequested(requestId, drawId);
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] calldata randomWords
    ) internal override {
        uint256 drawId = vrfRequestToDrawId[requestId];
        drawRandomWords[drawId] = randomWords[0];

        emit RandomnessFulfilled(requestId, drawId, randomWords[0]);

        // Call internal function to complete draw
        _onRandomnessReceived(drawId, randomWords[0]);
    }

    function _onRandomnessReceived(uint256 drawId, uint256 randomWord) internal virtual;
}
