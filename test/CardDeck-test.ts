// const util = require('util');
describe("CardDeck", function() {
  const { expect } = require("chai");
  const { ethers } = require('hardhat');

  it("Should deal a card", async function() {
    const CardDeck = await ethers.getContractFactory("CardDeck");
    const cards = await CardDeck.deploy(10);
    
    await cards.deployed();

    expect(await cards.remaining()).to.equal(10);
    
    let cardIx;
    await cards.deal(1)
               .then((tx: any) => tx.wait())
               .then((rv: any) => {
                 //console.log(util.inspect(rv.events[0]));
                 cardIx = rv.events[0].args[0];
                 expect(cardIx).to.equal(1);
                 return cards.remaining();
               })
               .then((remaining: Array<any>) => {
                 expect(remaining).to.equal(9)
               });

    await cards.deal(0)
               .then((tx: any) => tx.wait())
               .then((rv: any) => {
                 //console.log(util.inspect(rv.events[0]));
                 cardIx = rv.events[0].args[0];
                 expect(cardIx).to.equal(0);
               });

    await cards.deal(1)
               .then((tx: any) => tx.wait())
               .then((rv: any) => {
                 //console.log(util.inspect(rv.events[0]));
                 cardIx = rv.events[0].args[0];
                 expect(cardIx).to.equal(9);
                 return cards.remaining();
               })
               .then((remaining: Array<any>) => {
                 expect(remaining).to.equal(7)
               });
  });

  it("Should deal exactly the number of cards in the deck", async function() {
    const CardDeck = await ethers.getContractFactory("CardDeck");
    const cards = await CardDeck.deploy(5);
    
    await cards.deployed();

    expect(await cards.remaining()).to.equal(5);

    const txWait = (tx: any) => tx.wait();

    await cards.deal(0).then(txWait);
    await cards.deal(0).then(txWait);
    await cards.deal(0).then(txWait);
    expect(await cards.remaining()).to.equal(2);
    await cards.deal(0).then(txWait);
    await cards.deal(0).then(txWait);
    expect(await cards.remaining()).to.equal(0);
    await expect(cards.deal(0)).to.be.revertedWith("DeckComplete");
    expect(await cards.remaining()).to.equal(0);
    
  });
});
