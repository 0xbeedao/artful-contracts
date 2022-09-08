pragma solidity 0.8.11;

// SPDX-License-Identifier: CC-BY-3.0-US
// @author 0xBigBee <0xbigbee@protonmail.com>

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./PseudoRandomized.sol";

/**
 * Maps names to card indexes
 */
contract TarotTitledDealer is Ownable, PseudoRandomized {
	using Counters for Counters.Counter;
	Counters.Counter internal requestCounter;
	Counters.Counter internal deckCounter;
	uint256 internal _deckPrice;

	mapping(address => uint32[]) public deckOwners;
	mapping(address => uint32[]) internal cardOwners;
	mapping(uint32 => uint32) internal cardDecks;
	mapping(bytes32 => address) internal cardRequests;
	mapping(bytes32 => uint32) internal cardRequestDecks;
	mapping(uint32 => address) public cards;
	mapping(uint32 => address) public decks;
	mapping(uint32 => uint32[]) public remainingIndices; // each deck has its own remaining indices
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
	event Card(
		address owner,
		string title,
		uint32 index,
		uint32 draw,
		uint32 deck
	);

	event Deck(address owner, uint32 deckId);

	constructor(uint256 deckPrice) PseudoRandomized() {
		_deckPrice = deckPrice;
	}

	// Move the last element to the deleted spot.
	// Delete the last element, then correct the length.
	function _burn(uint32 deckId, uint256 index) internal {
		require(index < remainingIndices[deckId].length, "IndexError");
		remainingIndices[deckId][index] = remainingIndices[deckId][
			remainingIndices[deckId].length - 1
		];
		remainingIndices[deckId].pop();
	}

	function createDeck() public payable returns (uint32 deckId) {
		require(msg.sender != address(0), "NoZeroAddress");
		require(msg.value >= _deckPrice, "Fee too low");
		deckId = uint32(deckCounter.current());
		decks[deckId] = msg.sender;
		deckOwners[msg.sender].push(deckId);
		remainingIndices[deckId] = new uint8[](78);
		uint32 delta = deckId * 78;
		for (uint8 i = 0; i < 78; i++) {
			remainingIndices[deckId][i] = i + delta;
		}
		deckCounter.increment();
		emit Deck(msg.sender, deckId);
		return deckId;
	}

	function dealCard(uint32 deckId) public returns (bytes32 requestId) {
		require(remainingIndices[deckId].length > 0, "DeckComplete");
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
		cardRequestDecks[reqId] = deckId;
		requestRandomness(0x00, 0.0, requestNo);
		return reqId;
	}

	function fulfillRandomness(bytes32 requestId, uint256 randomness)
		internal
		override
	{
		address requestor = cardRequests[requestId];
		delete cardRequests[requestId];
		uint32 deckId = cardRequestDecks[requestId];
		delete cardRequestDecks[requestId];
		uint256 ix = randomness % remainingIndices[deckId].length;
		uint32 card = remainingIndices[deckId][ix];
		_burn(deckId, ix);
		cardOwners[requestor].push(card);
		cardDecks[card] = deckId;
		cards[card] = requestor;
		emit Card(
			requestor,
			titles[card % 78],
			card,
			uint8(requestCounter.current() - 1),
			deckId
		);
	}

	function getCard(address owner, uint256 index)
		public
		view
		returns (
			uint32 card,
			uint32 deckId,
			string memory title
		)
	{
		require(index < cardOwners[owner].length, "OutOfRange");
		card = cardOwners[owner][index];
		deckId = cardDecks[card];
		title = titles[card % 78];
	}

	function remaining(uint32 deckId) public view returns (uint256 count) {
		return remainingIndices[deckId].length;
	}

	function getCountByAddress(address owner)
		public
		view
		returns (uint256 count)
	{
		return cardOwners[owner].length;
	}
}
