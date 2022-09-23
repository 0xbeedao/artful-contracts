pragma solidity 0.8.11;

// SPDX-License-Identifier: CC-BY-3.0-US
// @author BruceDev <0xbigbee@protonmail.com>

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./PseudoRandomized.sol";

/**
 * Maps names to card indexes
 */
contract TarotTitledDeck is Ownable, PseudoRandomized {
	using Counters for Counters.Counter;
	Counters.Counter internal requestCounter;

	mapping(address => uint8[]) public cardOwners;
	mapping(bytes32 => address) internal cardRequests;
	mapping(uint8 => address) public cards;
	uint8[] public remainingIndices;
	string[] public titles = [
		"The Fool",
		"The Magician",
		"The High Priestess",
		"The Empress",
		"The Emperor",
		"The Hierophant",
		"The Lovers",
		"The Chariot",
		"Strength",
		"The Hermit",
		"Wheel of Fortune",
		"Justice",
		"The Hanged Man",
		"Death",
		"Temperance",
		"The Devil",
		"The Tower",
		"The Star",
		"The Moon",
		"The Sun",
		"Judgment",
		"The World",
		"Ace of Wands",
		"Two of Wands",
		"Three of Wands",
		"Four of Wands",
		"Five of Wands",
		"Six of Wands",
		"Seven of Wands",
		"Eight of Wands",
		"Nine of Wands",
		"Ten of Wands",
		"Page of Wands",
		"Knight of Wands",
		"Queen of Wands",
		"King of Wands",
		"Ace of Cups",
		"Two of Cups",
		"Three of Cups",
		"Four of Cups",
		"Five of Cups",
		"Six of Cups",
		"Seven of Cups",
		"Eight of Cups",
		"Nine of Cups",
		"Ten of Cups",
		"Page of Cups",
		"Knight of Cups",
		"Queen of Cups",
		"King of Cups",
		"Ace of Swords",
		"Two of Swords",
		"Three of Swords",
		"Four of Swords",
		"Five of Swords",
		"Six of Swords",
		"Seven of Swords",
		"Eight of Swords",
		"Nine of Swords",
		"Ten of Swords",
		"Page of Swords",
		"Knight of Swords",
		"Queen of Swords",
		"King of Swords",
		"Ace of Pentacles",
		"Two of Pentacles",
		"Three of Pentacles",
		"Four of Pentacles",
		"Five of Pentacles",
		"Six of Pentacles",
		"Seven of Pentacles",
		"Eight of Pentacles",
		"Nine of Pentacles",
		"Ten of Pentacles",
		"Page of Pentacles",
		"Knight of Pentacles",
		"Queen of Pentacles",
		"King of Pentacles"
	];

	/**
	 * Fired on card draw
	 * @param owner {address} owner of card
	 * @param title {string} of card
	 * @param index {uint8} position of card in unshuffled deck. Ex: "0" for "The Fool"
	 * @param draw {uint8} sequential number of draw, e.g. "0" for first draw.
	 */
	event Card(address owner, string title, uint8 index, uint8 draw);

	constructor() PseudoRandomized() {
		for (uint8 i = 0; i < titles.length; i++) {
			remainingIndices.push(i);
		}
	}

	// Move the last element to the deleted spot.
	// Delete the last element, then correct the length.
	function _burn(uint256 index) internal {
		require(index < remainingIndices.length, "IndexError");
		remainingIndices[index] = remainingIndices[remainingIndices.length - 1];
		remainingIndices.pop();
	}

	function dealCard() public returns (bytes32 requestId) {
		require(remainingIndices.length > 0, "DeckComplete");
		// here we are cheating and using the counter from PseudoRandomized
		// as the request ID.
		// For the real VRF, we need to set the cardRequest from the reqId
		// e.g.
		// uint256 reqId = this.reqRandomness(...)
		// cardRequests[reqId] = msg.sender;
		uint256 requestNo = requestCounter.current();
		requestCounter.increment();
		bytes32 reqId = bytes32(requestNo);
		cardRequests[reqId] = msg.sender;
		requestRandomness(0x00, 0.0, requestNo);
		return reqId;
	}

	function fulfillRandomness(bytes32 requestId, uint256 randomness)
		internal
		override
	{
		address requestor = cardRequests[requestId];
		delete cardRequests[requestId];
		uint256 ix = randomness % remainingIndices.length;
		uint8 card = remainingIndices[ix];
		_burn(ix);
		cardOwners[requestor].push(card);
		cards[card] = requestor;
		emit Card(
			requestor,
			titles[card],
			card,
			uint8(requestCounter.current() - 1)
		);
	}

	function getCard(address owner, uint256 index)
		public
		view
		returns (uint8 card, string memory title)
	{
		require(index < cardOwners[owner].length, "OutOfRange");
		card = cardOwners[owner][index];
		title = titles[card];
	}

	function remaining() public view returns (uint256 count) {
		return remainingIndices.length;
	}
}
