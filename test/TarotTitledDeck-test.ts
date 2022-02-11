describe("TarotTitledDeck", function () {
  const { ethers } = require("hardhat");
  const { expect } = require("chai");

  const getCardEvent = (events: Array<any>) => events.find((e: any) => e.event === 'Card');
  const DEFAULT_ADDRESS = '0x0000000000000000000000000000000000000000';

  const byIndex = (a: Array<number>, b: Array<number>) => {
    if (a[0] === b[0]) return 0;
    return a[0] - b[0];
  };

  it("Should deal the whole deck", async function () {
    const TarotTitledDeck = await ethers.getContractFactory("TarotTitledDeck");
    const tarot = await TarotTitledDeck.deploy();

    await tarot.deployed();
    const pulls = [];
    const remaining = await tarot.remaining();

    for (let i = 0; i < remaining; i++) {
      const tx = await tarot.dealCard();
      const rv = await tx.wait();
      const { args: { index, title, draw } } = rv.events[0];
      expect(draw).to.equal(i);
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
        "King of Pentacles"
      ].map((val, ix) => [ix, val]));
  });

  it("Should deal exactly the number of cards in the deck", async function () {
    const TarotTitledDeck = await ethers.getContractFactory("TarotTitledDeck");
    const tarot = await TarotTitledDeck.deploy();

    await tarot.deployed();
    const remaining = await tarot.remaining();

    for (let i = 0; i < remaining; i++) {
      const tx = await tarot.dealCard();
      const rv = await tx.wait();
    }

    expect(await tarot.remaining()).to.equal(0);
    await expect(tarot.dealCard()).to.be.revertedWith("DeckComplete");
    expect(await tarot.remaining()).to.equal(0);
  });

  it("Should get a card by owner", async function () {
    const TarotTitledDeck = await ethers.getContractFactory("TarotTitledDeck");
    const tarot = await TarotTitledDeck.deploy();

    await tarot.deployed();

    const [owner, addr1, addr2] = await ethers.getSigners();

    // deal one to addr1
    let tx = await tarot.connect(addr1).dealCard();
    let rv = await tx.wait();
    let event = getCardEvent(rv.events);
    expect(event).not.to.be.undefined;
    const { args: { index: card1, title: title1 } } = event;
    const check1 = await tarot.getCard(addr1.address, 0);
    expect(check1).to.deep.equal([card1, title1]);

    // deal one to addr2
    tx = await tarot.connect(addr2).dealCard();
    rv = await tx.wait();
    event = getCardEvent(rv.events);
    expect(event).not.to.be.undefined;
    const { args: { index: card2, title: title2 } } = event;
    const check2 = await tarot.getCard(addr2.address, 0);
    expect(check2).to.deep.equal([card2, title2]);

    expect(card2).not.to.equal(card1);
  });

  it("Should not get a card for a mismatched owner", async function () {
    const TarotTitledDeck = await ethers.getContractFactory("TarotTitledDeck");
    const tarot = await TarotTitledDeck.deploy();

    await tarot.deployed();

    const [owner, addr1, addr2] = await ethers.getSigners();

    // deal one to addr1
    const tx = await tarot.connect(addr1).dealCard();
    const rv = await tx.wait();
    const event = getCardEvent(rv.events);
    expect(event).not.to.be.undefined;

    // try to get a card for addr2, should fail
    await expect(tarot.getCard(addr2.address, 0)).to.be.revertedWith("OutOfRange");

    // try to get more cards than we have, should fail
    await expect(tarot.getCard(addr1.address, 1)).to.be.revertedWith("OutOfRange");
  });
});
