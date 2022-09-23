pragma solidity 0.8.11;

// SPDX-License-Identifier:	CC-BY-3.0-US
// @author BruceDev <0xbigbee@protonmail.com>

contract CardDeck {
	uint8[] public remainingIndices;

	event Card(uint8 cardIndex);

	constructor(uint8 cards) {
		for (uint8 i = 0; i < cards; i++) {
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

	function deal(uint256 randomNumber) public returns (uint8 cardIndex) {
		require(remainingIndices.length > 0, "DeckComplete");
		uint256 ix = randomNumber % remainingIndices.length;
		uint8 indexToReturn = remainingIndices[ix];
		_burn(ix);
		emit Card(indexToReturn);
		return (indexToReturn);
	}

	function remaining() public view returns (uint256 count) {
		return remainingIndices.length;
	}
}
