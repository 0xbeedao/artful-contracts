pragma solidity >=0.8.11 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./PseudoRandomized.sol";

contract HeroicNamer is ERC721Enumerable, Ownable, PseudoRandomized {
	using Strings for uint256;
	using Counters for Counters.Counter;

	Counters.Counter internal requestCounter;
	mapping(bytes32 => address) internal nameRequests;
	mapping(uint256 => string) internal heroicNames;
	uint256 public price = 0;

	event HeroicName(string name, uint256 tokenId, address owner);

	string[] private n1 = [
		"Accidental",
		"Ancient",
		"Aqua",
		"Awesome",
		"Black",
		"Blue",
		"Brass",
		"Brave",
		"Broad",
		"Broken",
		"Bronze",
		"Calm",
		"Clever",
		"Cold",
		"Colossal",
		"Confident",
		"Cool",
		"Copper",
		"Crimson",
		"Dapper",
		"Dark",
		"Defiant",
		"Dramatic",
		"Eager",
		"Earth",
		"Earthen",
		"Electric",
		"Electron",
		"Elegant",
		"Ethereal",
		"Fabulous",
		"Famous",
		"Fancy",
		"Fantastic",
		"Fast",
		"Fearless",
		"Fiery",
		"Fire",
		"Galactic",
		"Gentle",
		"Giant",
		"Gigantic",
		"Glorious",
		"Godly",
		"Golden",
		"Good",
		"Gorgeous",
		"Gray",
		"Green",
		"Heavenly",
		"Heavy",
		"Honorable",
		"Hot",
		"Huge",
		"Hypnotic",
		"Ice",
		"Impossible",
		"Incredible",
		"Infamous",
		"Intelligent",
		"Iron",
		"Jade",
		"Jolly",
		"Kind",
		"Light",
		"Long",
		"Loud",
		"Lucky",
		"Macho",
		"Magical",
		"Magnificent",
		"Majestic",
		"Mammoth",
		"Marked",
		"Marvelous",
		"Merciful",
		"Mighty",
		"Misty",
		"Mysterious",
		"Nifty",
		"Nimble",
		"Nuclear",
		"Old",
		"Orange",
		"Outrageous",
		"Pink",
		"Proud",
		"Purple",
		"Quantum",
		"Quick",
		"Quiet",
		"Rapid",
		"Red",
		"Righteous",
		"Royal",
		"Scarlet",
		"Silver",
		"Smooth",
		"Spectacular",
		"Steel",
		"Storm",
		"Swift",
		"Tan",
		"Terrific",
		"Thunder",
		"Vengeful",
		"Voiceless",
		"Wacky",
		"Water",
		"Whispering",
		"White",
		"Wise",
		"Yellow"
	];

	string[] private n2 = [
		"Agent",
		"Amazon",
		"Angel",
		"Ant",
		"Antman",
		"Armadillo",
		"Assassin",
		"Axeman",
		"Baron",
		"Bat",
		"Bear",
		"Beetle",
		"Captain",
		"Cat",
		"Catman",
		"Champion",
		"Charmer",
		"Cheetah",
		"Chief",
		"Commando",
		"Condor",
		"Conjurer",
		"Crane",
		"Cricket",
		"Crow",
		"Cultist",
		"Dagger",
		"Daggers",
		"Defender",
		"Detective",
		"Devil",
		"Doctor",
		"Dragonfly",
		"Duke",
		"Eagle",
		"Elephantman",
		"Enchanter",
		"Falcon",
		"Fighter",
		"Fox",
		"Gamer",
		"General",
		"Genius",
		"Gladiator",
		"Gloom",
		"Gorilla",
		"Grasshopper",
		"Guard",
		"Guardian",
		"Gunner",
		"Hammer",
		"Hawk",
		"Hornet",
		"Ibis",
		"Illusionist",
		"Jackal",
		"Katana",
		"Keeper",
		"Killer",
		"Knuckles",
		"Leader",
		"Leopard",
		"Lion",
		"Lord",
		"Lynx",
		"Macaw",
		"Mage",
		"Magician",
		"Mantis",
		"Marksman",
		"Master",
		"Mastermind",
		"Mercenary",
		"Merlin",
		"Mole",
		"Monarch",
		"Mongoose",
		"Moth",
		"Mothman",
		"Nighthawk",
		"Nightowl",
		"Owl",
		"Ox",
		"Oxman",
		"Panther",
		"Phoenix",
		"Prince",
		"Prodigy",
		"Prophet",
		"Protector",
		"Puma",
		"Queen",
		"Raccoon",
		"Raven",
		"Rhino",
		"Rhinoceros",
		"Robin",
		"Sage",
		"Saviour",
		"Scepter",
		"Scimitar",
		"Scorpion",
		"Scout",
		"Seer",
		"Sentinel",
		"Shade",
		"Shadow",
		"Shaman",
		"Shepherd",
		"Shield",
		"Siren",
		"Slayer",
		"Smasher",
		"Snipe",
		"Sniper",
		"Soldier",
		"Sparrow",
		"Spectacle",
		"Spider",
		"Spirit",
		"Spy",
		"Starling",
		"Swallow",
		"Swan",
		"Sword",
		"Swordsman",
		"Termite",
		"Tiger",
		"Trident",
		"Veteran",
		"Vindicator",
		"Vulture",
		"Warden",
		"Warrior",
		"Wasp",
		"Waspman",
		"Watcher",
		"Watchman",
		"Whiz",
		"Wizard",
		"Wolf",
		"Wolfman",
		"Wolverine",
		"Wonder"
	];

	string[] private n3 = [
		"Agent",
		"Captain",
		"Chief",
		"Commander",
		"Doctor",
		"General",
		"Lord",
		"Madame",
		"Master",
		"Mister",
		"Mistress",
		"Officer",
		"Prince",
		"Prof",
		"Professor",
		"Queen",
		"Senator",
		"Shaman",
		"Sheriff",
		"Sir",
		"Soldier",
		"Steward",
		"Swami",
		"Teacher",
		"Viceroy",
		"Viking",
		"Warden"
		"Warlord",
		"Whiz",
		"Wizard"
	];

	string[] private n4 = [
		"Accidental",
		"Ancient",
		"Aqua",
		"Armed",
		"Awesome",
		"Black",
		"Blue",
		"Brass",
		"Brave",
		"Broad",
		"Broken",
		"Bronze",
		"Calm",
		"Clever",
		"Cold",
		"Colossal",
		"Confident",
		"Cool",
		"Copper",
		"Crimson",
		"Dapper",
		"Dark",
		"Defiant",
		"Dramatic",
		"Eager",
		"Eager",
		"Earth",
		"Earthen",
		"Electric",
		"Electron",
		"Elegent",
		"Ethereal",
		"Fabulous",
		"Famous",
		"Fancy",
		"Fancy",
		"Fantastic",
		"Fast",
		"Fearless",
		"Fiery",
		"Fire",
		"Galactic",
		"Gentle",
		"Giant",
		"Gigantic",
		"Glorious",
		"Godly",
		"Golden",
		"Good",
		"Gorgeous",
		"Gray",
		"Green",
		"Heavenly",
		"Heavy",
		"Honorable",
		"Hot",
		"Huge",
		"Hypnotic",
		"Ice",
		"Impossible",
		"Incredible",
		"Infamous",
		"Intelligent",
		"Iron",
		"Jolly",
		"Kind",
		"Light",
		"Long",
		"Lucky",
		"Macho",
		"Magical",
		"Magnificent",
		"Majestic",
		"Mammoth",
		"Marked",
		"Marvelous",
		"Merciful",
		"Messy",
		"Mighty",
		"Misty",
		"Mysterious",
		"Nifty",
		"Nimble",
		"Nuclear",
		"Old",
		"Orange",
		"Outrageous",
		"Pink",
		"Proud",
		"Purple",
		"Quantum",
		"Quick",
		"Quiet",
		"Rapid",
		"Red",
		"Righteous",
		"Royal",
		"Scarlet",
		"Silver",
		"Smooth",
		"Spectacular",
		"Steel",
		"Storm",
		"Swift",
		"Terrific",
		"Thunder",
		"Thundering",
		"Unarmed",
		"Vengeful",
		"Voiceless",
		"Wacky",
		"Water",
		"Whispering",
		"White",
		"Wise",
		"Yellow"
	];

	string[] private n5 = [
		"Amazon",
		"Angel",
		"Ant",
		"Antman",
		"Armadillo",
		"Assassin",
		"Axeman",
		"Bat",
		"Bear",
		"Beetle",
		"Cat",
		"Catman",
		"Champion",
		"Charmer",
		"Cheetah",
		"Condor",
		"Conjurer",
		"Crane",
		"Cricket",
		"Crow",
		"Dagger",
		"Daggers",
		"Defender",
		"Devil",
		"Dragonfly",
		"Eagle",
		"Elder God",
		"Enchanter",
		"Falcon",
		"Fighter",
		"Fox",
		"Genius",
		"Gloom",
		"Gorilla",
		"Grasshopper",
		"Guardian",
		"Hammer",
		"Hart",
		"Hawk",
		"Hornet",
		"Ibis",
		"Illusionist",
		"Jackal",
		"Katana",
		"Killer",
		"Knuckles",
		"Leopard",
		"Lion",
		"Lord",
		"Lynx",
		"Macaw",
		"Magician",
		"Mantis",
		"Masquerade",
		"Mastermind",
		"Merlin",
		"Mole",
		"Monarch",
		"Mongoose",
		"Moth",
		"Nighthawk",
		"Nightowl",
		"Owl",
		"Ox",
		"Oxman",
		"Panther",
		"Phoenix",
		"Prodigy",
		"Prophet",
		"Protector",
		"Puma",
		"Raccoon",
		"Raven",
		"Rhino",
		"Rhinoceros",
		"Robin",
		"Sage",
		"Saviour",
		"Scepter",
		"Scimitar",
		"Scorpion",
		"Sentinel",
		"Shade",
		"Shadow",
		"Shepherd",
		"Shield",
		"Slayer",
		"Smasher",
		"Snipe",
		"Sparrow",
		"Spectacle",
		"Spider"
		"Spirit",
		"Starling",
		"Swallow",
		"Swan",
		"Sword",
		"Swordsman",
		"Tentacle",
		"Termite",
		"Tiger",
		"Trident",
		"Vulture",
		"Warrior",
		"Wasp",
		"Waspman",
		"Watcher",
		"Wolf",
		"Wolverine",
		"Wonder"
	];

	constructor(uint256 cost)
		ERC721("Heroic Name", "HERO")
		Ownable()
		PseudoRandomized()
	{
		price = cost;
	}

	function nextRandom(uint256 seed, uint256 delta)
		internal
		pure
		returns (uint256)
	{
		return uint256(keccak256(abi.encodePacked(seed, delta)));
	}

	function generateName(uint256 randomness)
		internal
		view
		returns (string memory)
	{
		uint256 choice = nextRandom(randomness, 0) % 2;
		if (choice == 0) {
			return
				string(
					abi.encodePacked(
						"The ",
						n1[nextRandom(randomness, 1) % n1.length],
						" ",
						n2[nextRandom(randomness, 2) % n2.length]
					)
				);
		} else {
			return
				string(
					abi.encodePacked(
						n3[nextRandom(randomness, 3) % n3.length],
						" ",
						n4[nextRandom(randomness, 4) % n4.length],
						" ",
						n5[nextRandom(randomness, 5) % n5.length]
					)
				);
		}
	}

	function setPrice(uint256 cost) public onlyOwner {
		price = cost;
	}

	// public
	function mint() public payable {
		if (msg.sender != owner()) {
			require(msg.value >= price, "Insufficient funds");
		}
		require(msg.sender != address(0), "NoZeroAddress");

		uint256 requestNo = requestCounter.current();
		requestCounter.increment();
		bytes32 reqId = bytes32(requestNo);
		nameRequests[reqId] = msg.sender;
		requestRandomness(0x00, 0.0, requestNo);
	}

	function fulfillRandomness(bytes32 requestId, uint256 randomness)
		internal
		override
	{
		require(nameRequests[requestId] != address(0), "Request ID Not Found");
		address requestor = nameRequests[requestId];
		delete nameRequests[requestId];
		uint256 supply = totalSupply();
		string memory name = generateName(randomness);
		heroicNames[supply + 1] = name;
		_safeMint(requestor, supply + 1);
		emit HeroicName(name, supply + 1, requestor);
	}

	function buildImage(uint256 _tokenId) private view returns (string memory) {
		string memory name = heroicNames[_tokenId];
		return
			Base64.encode(
				bytes(
					abi.encodePacked(
						'<svg width="500" height="100" xmlns="http://www.w3.org/2000/svg"><text font-size="18" y="35%" x="50%" text-anchor="middle">Heroic Name</text><text font-size="22" y="65%" x="50%" text-anchor="middle">',
						name,
						"</text></svg>"
					)
				)
			);
	}

	function buildMetadata(uint256 _tokenId)
		private
		view
		returns (string memory)
	{
		string memory name = heroicNames[_tokenId];
		return
			string(
				abi.encodePacked(
					"data:application/json;base64,",
					Base64.encode(
						bytes(
							abi.encodePacked(
								'{"name":"',
								name,
								'", "description":"Heroic Name", ',
								'"image": "',
								"data:image/svg+xml;base64,",
								buildImage(_tokenId),
								'"}'
							)
						)
					)
				)
			);
	}

	function tokenURI(uint256 _tokenId)
		public
		view
		virtual
		override
		returns (string memory)
	{
		require(
			_exists(_tokenId),
			"ERC721Metadata: URI query for nonexistent token"
		);
		return buildMetadata(_tokenId);
	}

	//only owner
	function withdraw() public payable onlyOwner {
		(bool success, ) = payable(msg.sender).call{
			value: address(this).balance
		}("");
		require(success);
	}
}
