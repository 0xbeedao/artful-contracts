describe("TarotTitledDealer", function () {
	const { ethers } = require("hardhat");
	const { expect } = require("chai");
	let dealer: any;
	let dealerContract: any = null;
	let deckId: number = -1;
	let owner: any;
	let addr1: any;
	let addr2: any;
	let noCards: any;

	const getCardEvent = (events: Array<any>) =>
		events.find((e: any) => e.event === "Card");
	const DEFAULT_ADDRESS = "0x0000000000000000000000000000000000000000";

	const byIndex = (a: Array<number>, b: Array<number>) => {
		if (a[0] === b[0]) return 0;
		return a[0] - b[0];
	};

	before(async () => {
		dealerContract = await ethers.getContractFactory("TarotTitledDealer");
		const signers = await ethers.getSigners();
		owner = signers[0];
		expect(owner.address).not.to.be.properHex(0);
		addr1 = signers[1];
		addr2 = signers[2];
		noCards = signers[3];
		dealer = await dealerContract.deploy(0);
	});

	this.beforeEach(async () => {
		const deckTx = await dealer.connect(addr1).createDeck();
		const deckRv = await deckTx.wait();
		deckId = deckRv.events[0].args.deckId;
	});

	it("Should deal the whole deck", async function () {
		const pulls = [];
		const remaining = await dealer.remaining(deckId);
		expect(remaining).to.equal(78);

		for (let i = 0; i < remaining; i++) {
			const tx = await dealer.dealCard(deckId);
			const rv = await tx.wait();
			const {
				args: { index, title, draw },
			} = rv.events[0];
			expect(draw).to.equal(i);
			let rem = await dealer.remaining(deckId);
			expect(rem).to.equal(remaining - i - 1);
			pulls.push([index, title]);
		}

		pulls.sort(byIndex);
		expect(pulls).to.deep.equal(
			[
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
				"King of Pentacles",
			].map((val, ix) => [ix, val])
		);
	});

	it("Should deal exactly the number of cards in the deck", async function () {
		const remaining = await dealer.remaining(deckId);

		for (let i = 0; i < remaining; i++) {
			const tx = await dealer.dealCard(deckId);
			await tx.wait();
		}

		expect(await dealer.remaining(deckId)).to.equal(0);
		await expect(dealer.dealCard(deckId)).to.be.revertedWith("DeckComplete");
		expect(await dealer.remaining(deckId)).to.equal(0);
	});

	it("Should get a card by owner", async function () {
		// deal one to addr1
		let tx = await dealer.connect(addr1).dealCard(deckId);
		let rv = await tx.wait();
		let event = getCardEvent(rv.events);
		expect(event).not.to.be.undefined;
		const {
			args: { index: card1, title: title1 },
		} = event;
		const check1 = await dealer.getCard(addr1.address, 0);
		expect(check1).to.deep.equal([card1, deckId, title1]);

		// deal one to addr2
		tx = await dealer.connect(addr2).dealCard(deckId);
		rv = await tx.wait();
		event = getCardEvent(rv.events);
		expect(event).not.to.be.undefined;
		const {
			args: { index: card2, title: title2 },
		} = event;
		const check2 = await dealer.getCard(addr2.address, 0);
		expect(check2).to.deep.equal([card2, deckId, title2]);

		expect(card2).not.to.equal(card1);
	});

	it("Should not get a card for a mismatched owner", async function () {
		// deal one to addr1
		const tx = await dealer.connect(addr1).dealCard(deckId);
		const rv = await tx.wait();
		const event = getCardEvent(rv.events);
		expect(event).not.to.be.undefined;

		// try to get a card for noCards, should fail
		await expect(dealer.getCard(noCards.address, 0)).to.be.revertedWith(
			"OutOfRange"
		);
	});

	it("Should not get a card the owner doesn't have", async function () {
		// deal one to addr1
		const tx = await dealer.connect(addr1).dealCard(deckId);
		const rv = await tx.wait();
		const event = getCardEvent(rv.events);
		expect(event).not.to.be.undefined;

		const currentLength = await dealer.getCountByAddress(addr1.address);

		// try to get more cards than we have, should fail
		await expect(
			dealer.getCard(addr1.address, currentLength)
		).to.be.revertedWith("OutOfRange");
	});
});
