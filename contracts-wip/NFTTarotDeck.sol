pragma solidity 0.8.11;

// SPDX-License-Identifier:	CC-BY-3.0-US

// TODO: convert and finish me - this will be the VRF version of TarotNFTDeck

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/dev/VRFConsumerBase.sol";
import "./CardDeck.sol";

contract NFTTarotDeck is VRFConsumerBase, Ownable {
    mapping(address => uint8[]) public cardOwners;
    mapping(bytes32 => address) internal cardRequests;
    mapping(uint8 => address) public cards;

    // ropsten keyHash = 0xced103054e349b8dfb51352f0f8fa9b5d20dde3d06f9f43cb2b85bc64b238205;
    bytes32 internal keyHash =
        0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
    uint256 internal linkFee;
    CardDeck internal deck;

    event CardDealt(address owner, uint8 val);

    /**
     * @notice Constructor inherits VRFConsumerBase
     * @dev Ropsten deployment params:
     * @dev   _vrfCoordinator: 0xf720CF1B963e0e7bE9F58fd471EFa67e7bF00cfb
     * @dev   _link:           0x20fE562d797A42Dcb3399062AE9546cd06f63280
     *
     *
     * Ropsten: VRFConsumerBase(
     *   0xf720CF1B963e0e7bE9F58fd471EFa67e7bF00cfb,  // VRF
     *   0x20fE562d797A42Dcb3399062AE9546cd06f63280   // LINK
     * ) public
     * Kovan: VRFConsumerBase(
     *   0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9,  // VRF
     *   0xa36085F69e2889c224210F603D836748e7dC0088   // LINK
     * )
     * Mainnet: VRFConsumerBase(
     *   0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9,  // VRF Coordinator
     *   0xa36085F69e2889c224210F603D836748e7dC0088   // LINK Token
     * )
     *
     * Find Matic/Arbitrum values
     *
     */
    constructor()
        VRFConsumerBase(
            // Kovan
            0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9, // VRF
            0xa36085F69e2889c224210F603D836748e7dC0088 // LINK
        )
        Ownable()
    {
        linkFee = 0.0001 * 10**18; // 0.1 LINK
        deck = CardDeck(78);
    }

    function dealCard() public returns (bytes32 requestId) {
        require(deck.remaining() > 0, "Deck is complete");
        require(LINK.balanceOf(address(this)) > linkFee, "LinkBalanceError");
        // require(!cardRequests[msg.address], "Only one request at a time");
        bytes32 _requestId = requestRandomness(keyHash, linkFee, 1);
        cardRequests[_requestId] = msg.sender;
        return _requestId;
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness)
        internal
        override
    {
        address requestor = cardRequests[requestId];
        delete cardRequests[requestId];
        uint8 card = deck.deal(randomness);
        cardOwners[requestor].push(card);
        cards[card] = requestor;
        emit CardDealt(requestor, card);
    }

    function terminate() public onlyOwner {
        uint256 balance = LINK.balanceOf(address(this));
        address owner = this.owner();
        if (balance > 0) {
            LINK.transfer(owner, balance);
        }
        // Transfer Eth to owner and terminate contract
        selfdestruct(payable(owner));
    }
}
