pragma solidity 0.8.11;

// SPDX-License-Identifier: CC-BY-3.0-US
// @author 0xBigBee <0xbigbee@protonmail.com>

/**
 * A contract that returns a random number, just like the LINK VRF one does,
 * only with a pseudorandom.  This should allow me to swap them out for testing.
 */
abstract contract PseudoRandomized {
    bytes32 internal ignoreHash = 0x00;
    uint256 internal linkFee;

    constructor() {
        linkFee = 0;
    }

    function requestRandomness(
        bytes32,
        uint256,
        uint256 seed
    ) internal returns (bytes32 requestId) {
        bytes32 reqId = bytes32(seed);
        uint256 pseudoRand = uint256(
            keccak256(
                abi.encodePacked(block.timestamp, blockhash(block.number)) // solhint-disable-line
            )
        ); 
        fulfillRandomness(reqId, pseudoRand);
        return reqId;
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness)
        internal
        virtual;
}
