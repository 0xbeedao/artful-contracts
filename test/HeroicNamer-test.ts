describe("HeroicNamer", function () {
	const { ethers } = require("hardhat");
	const { expect } = require("chai");
	let namer: any;
	let contract: any = null;
	let owner: any;
	let addr1: any;
	let addr2: any;
	let noNames: any;

	const getNamingEvent = (events: Array<any>) =>
		events.find((e: any) => e.event === "HeroicName");

	const DEFAULT_ADDRESS = "0x0000000000000000000000000000000000000000";

	const byIndex = (a: Array<number>, b: Array<number>) => {
		if (a[0] === b[0]) return 0;
		return a[0] - b[0];
	};

	before(async () => {
		contract = await ethers.getContractFactory("HeroicNamer");
		const signers = await ethers.getSigners();
		owner = signers[0];
		expect(owner.address).not.to.be.properHex(0);
		addr1 = signers[1];
		addr2 = signers[2];
		noNames = signers[3];
		namer = await contract.deploy(0);
	});

	it("Should make a name", async function () {
		await expect(namer.connect(addr1).mint()).to.emit(namer, "HeroicName");
	});

	it("Should make different names", async function () {
		const names = [];
		for (let i = 0; i < 50; i++) {
			const tx = await namer.connect(addr1).mint();
			const rv = await tx.wait();
			const { name, tokenId } = getNamingEvent(rv.events).args;
			names.push(name);
			console.log(`name ${i} [#${tokenId}]: ${name}`);
		}
		const unique = new Set(names);
		expect(unique.size).to.equal(50);
	});

	it("Should retrieve names", async function () {
		const names = [];
		const startCt = await namer.totalSupply();
		for (let i = 0; i < 10; i++) {
			const tx = await namer.connect(addr1).mint();
			const rv = await tx.wait();
			const { name, tokenId } = getNamingEvent(rv.events).args;
			names.push(name);
			console.log(`name ${i} [#${tokenId}]: ${name}`);
		}
		const endCt = await namer.totalSupply();
		expect(endCt - startCt).to.equal(10);
		for (let i = 1; i < 11; i++) {
			const name = await namer.nameOfOwnerByIndex(addr1, i + startCt);
			expect(name).to.equal(names[i]);
		}
	});

	it("Should render SVG for tokenURI", async function () {
		const tx = await namer.connect(addr1).mint();
		const rv = await tx.wait();
		const { tokenId } = getNamingEvent(rv.events).args;
		const uri = await namer.tokenURI(tokenId);
		// console.log("URI: " + uri);
		expect(uri).to.match(/^data:application\/json;base64/);
		const rawJson = Buffer.from(uri.split(",")[1], "base64").toString();
		const json = JSON.parse(rawJson);
		expect(json).to.have.property("name");
		expect(json).to.have.property("description");
		expect(json).to.have.property("image");
		expect(json.image).to.match(/^data:image\/svg\+xml;base64/);
		const rawSvg = Buffer.from(json.image.split(",")[1], "base64").toString();
		expect(rawSvg).to.match(/^<svg/);
	});

	it("Should burn tokens", async function () {
		const startCt = await namer.totalSupply();
		const tokens = [];
		const names = [];
		for (let i = 0; i < 4; i++) {
			const tx = await namer.connect(addr1).mint();
			const rv = await tx.wait();
			const { name, tokenId } = getNamingEvent(rv.events).args;
			names.push(name);
			tokens.push(tokenId);
			console.log(`name ${i} [#${tokenId}]: ${name}`);
		}
		const delTx = await namer.connect(addr1).burn(tokens[1]);
		await delTx.wait();

		const finalNames = [];
		for (let i = 1; i < 4; i++) {
			const name = await namer.nameOfOwnerByIndex(addr1, startCt + i);
			finalNames.push(name);
		}
		expect(finalNames).to.deep.equal([names[0], names[2], names[3]]);
	});
});
