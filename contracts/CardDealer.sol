pragma solidity 0.8.11;

// SPDX-License-Identifier: CC-BY-3.0-US
// @author 0xBigBee <0xbigbee@protonmail.com>

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./PseudoRandomized.sol";

/**
 * Maps names to card indexes
 */
contract CardDealer is Ownable, PseudoRandomized {
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

	/**
	 * Fired on card draw
	 * @param owner {address} owner of card
	 * @param title {string} of card
	 * @param index {uint8} position of card in unshuffled deck. Ex: "0" for "The Fool"
	 * @param draw {uint8} sequential number of draw, e.g. "0" for first draw.
	 * @param deck {uint32} deck index
	 */
	event Card(
		address owner,
		string title,
		uint32 index,
		uint32 draw,
		uint32 deck
	);

	/**
	 * Fired on deck creation
	 * @param owner {address} owner of card
	 * @param deckId {uint32} deck index
	 */
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

	function _title(uint32 cardId) internal pure returns (string memory title) {
		uint8 card = uint8(cardId % 52);
		string memory suit;
		if (card < 13) {
			suit = unicode"♣";
		} else if (card < 26) {
			suit = unicode"♦";
		} else if (card < 39) {
			suit = unicode"♥";
		} else {
			suit = unicode"♠";
		}
		uint8 rank = card % 13;
		string memory rankVal = "";
		if (rank == 10) {
			rankVal = "J";
		} else if (rank == 11) {
			rankVal = "Q";
		} else if (rank == 12) {
			rankVal = "K";
		} else {
			rankVal = Strings.toString(rank + 1);
		}
		return string(bytes.concat(bytes(rankVal), bytes(suit)));
	}

	function createDeck() public payable returns (uint32 deckId) {
		require(msg.sender != address(0), "NoZeroAddress");
		require(msg.value >= _deckPrice, "Fee too low");
		deckId = uint32(deckCounter.current());
		decks[deckId] = msg.sender;
		deckOwners[msg.sender].push(deckId);
		remainingIndices[deckId] = new uint8[](52);
		uint32 delta = deckId * 52;
		for (uint8 i = 0; i < 52; i++) {
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
			_title(card),
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
		title = _title(card);
		return (card, deckId, title);
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
