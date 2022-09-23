pragma solidity 0.8.11;

// SPDX-License-Identifier: CC-BY-3.0-US
// @author BruceDev <0xbigbee@protonmail.com>

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./PseudoRandomized.sol";

/**
 * Maps names to card indexes
 */
contract TarotNFTDeck is Ownable, PseudoRandomized, ERC721Enumerable {
	using Counters for Counters.Counter;
	Counters.Counter internal requestCounter;
	mapping(bytes32 => address) internal cardRequests;
	string internal _baseURIStorage;
	uint256 internal _drawPrice;
	uint256 internal _deckSize = 78;

	uint8[] public remainingIndices = [
		0,
		1,
		2,
		3,
		4,
		5,
		6,
		7,
		8,
		9,
		10,
		11,
		12,
		13,
		14,
		15,
		16,
		17,
		18,
		19,
		20,
		21,
		22,
		23,
		24,
		25,
		26,
		27,
		28,
		29,
		30,
		31,
		32,
		33,
		34,
		35,
		36,
		37,
		38,
		39,
		40,
		41,
		42,
		43,
		44,
		45,
		46,
		47,
		48,
		49,
		50,
		51,
		52,
		53,
		54,
		55,
		56,
		57,
		58,
		59,
		60,
		61,
		62,
		63,
		64,
		65,
		66,
		67,
		68,
		69,
		70,
		71,
		72,
		73,
		74,
		75,
		76,
		77
	];

	/**
	 * Fired on card draw
	 * @param owner {address} owner of card
	 * @param uri {string} of JSON for card
	 * @param index {uint8} position of card in unshuffled deck. Ex: "0" for "The Fool"
	 * @param draw {uint8} sequencial number of draw, e.g. "0" for first draw.
	 */
	event Card(address owner, string uri, uint8 index, uint8 draw);

	constructor(
		string memory baseURI,
		uint256 price,
		string memory title,
		string memory symbol
	) PseudoRandomized() Ownable() ERC721(title, symbol) {
		setBaseURI(baseURI);
		_drawPrice = price;
	}

	function _baseURI() internal view override returns (string memory) {
		return _baseURIStorage;
	}

	// Move the last element to the deleted spot.
	// Delete the last element, then correct the length.
	function _burnAt(uint256 index) internal {
		require(index < remainingIndices.length, "IndexError");
		remainingIndices[index] = remainingIndices[remainingIndices.length - 1];
		remainingIndices.pop();
	}

	function dealCard() public payable returns (bytes32 requestId) {
		require(remainingIndices.length > 0, "DeckComplete");
		require(msg.sender != address(0), "NoZeroAddress");
		require(msg.value >= _drawPrice, "Fee too low");
		// here we are cheating and using the counter as the request ID.
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
		require(cardRequests[requestId] != address(0), "Request ID Not Found");
		address requestor = cardRequests[requestId];
		delete cardRequests[requestId];
		uint256 ix = randomness % remainingIndices.length;
		uint8 card = remainingIndices[ix];
		_burnAt(ix);
		_mint(requestor, card);
		emit Card(
			requestor,
			tokenURI(card),
			card,
			uint8(requestCounter.current() - 1)
		);
	}

	function remaining() public view returns (uint256 count) {
		return remainingIndices.length;
	}

	function getDeckSize() public view returns (uint256 size) {
		return _deckSize;
	}

	function getPrice() public view returns (uint256 drawPrice) {
		return _drawPrice;
	}

	function setPrice(uint256 newPrice) public onlyOwner {
		_drawPrice = newPrice;
	}

	function setBaseURI(string memory newBaseURI) public onlyOwner {
		_baseURIStorage = newBaseURI;
	}

	function withdrawFees() public onlyOwner {
		// get the amount of Ether stored in this contract
		uint256 amount = address(this).balance;

		// send all Ether to owner
		// Owner can receive Ether since the address of owner is payable
		(bool success, ) = owner().call{value: amount}("");
		require(success, "Failed to send fees");
	}
}
