describe("TarotNFTDeck", function () {
  const { expect } = require("chai");
  const { ethers } = require('hardhat');
  
  const byIndex = (a: Array<number>, b: Array<number>) => {
    if (a[0] === b[0]) return 0;
    return a[0] - b[0];
  };
  
  const getCardEvent = (events: Array<any>) => events.find((e: any) => e.event === 'Card');

  let tarot: any;
  let tarotNFTDeck: any = null;
  let owner: any;
  let addr1: any;
  let addr2: any;

  before(async () => {
    tarotNFTDeck = await ethers.getContractFactory("TarotNFTDeck");
    const signers = await ethers.getSigners();
    owner = signers[0];
    expect(owner.address).not.to.be.properHex(0);
    addr1 = signers[1];
    addr2 = signers[2];
  });

  beforeEach(async () => {
    tarot = await tarotNFTDeck.deploy('test/', 0, "test", "TAROT");
    await tarot.deployed();
  });

  it("Should have a symbol", async function () {
    expect(await tarot.symbol()).to.equal('TAROT');
  });

  it("Should emit card events", async function () {
    await expect(tarot.connect(addr1).dealCard()).to.emit(tarot, 'Card');
  });

  it("Should deal the whole deck", async function () {
    const pulls = [];
    const rawRemaining = await tarot.remaining();
    const remaining = parseInt(rawRemaining, 10);

    for (let i = 0; i < remaining; i++) {
      const tx = await tarot.connect(addr1).dealCard();
      const rv = await tx.wait();
      const event = getCardEvent(rv.events);
      expect(event).not.to.be.undefined;
      const { args: { owner: cardOwner, index, uri, draw } } = event;
      expect(cardOwner).to.equal(addr1.address);
      expect(draw).to.equal(i);
      pulls.push([index, uri]);
    }

    // grab the third draw
    const thirdCard = pulls[2][0];

    pulls.sort(byIndex);
    // the response map is [index, url]
    // and since we sorted it, all indices 0-77 should be there,
    // along with the "URI", which we set to "test/" above.  So the
    // derived URI is "test/{index}"
    const expected = [];
    for (let i = 0; i < remaining; i++) {
      expected.push([i, `test/${i}`]);
    }

    expect(pulls).to.deep.equal(expected);
    expect(await tarot.totalSupply()).to.equal(remaining);

    // test retrieving by draw number/index using that third draw
    const draw3 = await tarot.tokenByIndex(2);
    expect(draw3).to.equal(thirdCard);
  });

  it("Should retrieve by owner", async function () {
    let tx = await tarot.connect(addr1).dealCard();
    let rv = await tx.wait();
    let event = getCardEvent(rv.events);
    const card1 = event.args.index;


    tx = await tarot.connect(addr2).dealCard();
    rv = await tx.wait();
    event = getCardEvent(rv.events);
    const card2 = event.args.index;

    const check1 = await tarot.tokenOfOwnerByIndex(addr1.address, 0);
    expect(check1).to.equal(card1);

    const check2 = await tarot.tokenOfOwnerByIndex(addr2.address, 0);
    expect(check2).to.equal(card2);

    // Only has one, so error here
    await expect(tarot.tokenOfOwnerByIndex(addr2.address, 1)).to.be.reverted;

    // check URI
    expect(await tarot.tokenURI(card1)).to.equal(`test/${card1}`);
  });

  it("Should set prices", async function () {
    const someGas = { gasPrice: ethers.utils.parseEther('0.000006') };
    expect(await tarot.getPrice()).to.equal(0);
    const half = ethers.utils.parseUnits("0.5", "ether");
    const one = ethers.utils.parseUnits("1", "ether");
    let tx = await tarot.setPrice(one, someGas);
    await tx.wait();

    // only owner
    await expect(tarot.connect(addr2).setPrice(0, someGas)).to.be.reverted;

    // and now no one can deal without payment
    await expect(tarot.connect(addr1).dealCard(someGas)).to.be.revertedWith("Fee too low");
    const startBal = await addr1.getBalance();

    // send with payment - first too low
    await expect(tarot.connect(addr1).dealCard({ ...someGas, value: half }))
      .to.be.revertedWith("Fee too low");

    // then with enough
    await expect(await tarot.connect(addr1).dealCard({
      ...someGas,
      value: one,
    })).to.changeEtherBalance(addr1, one.mul(-1));;
  });

  it("Should withdraw profits", async function () {
    const someGas = { gasPrice: ethers.utils.parseEther('0.000006') };
    const one = ethers.utils.parseUnits("1", "ether");
    let tx = await tarot.setPrice(one, { gasPrice: ethers.utils.parseEther('0.000006') });
    await tx.wait();
    for (let i = 0; i < 10; i++) {
      tx = await tarot.connect(addr1).dealCard({
        ...someGas,
        value: one,
      });
      await tx.wait();
    }
    // woohoo 10 profit
    await expect(await tarot.withdrawFees(someGas)).to.changeEtherBalance(owner, one.mul(10));
  });
});
