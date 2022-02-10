# Artful-Contracts

Contains my experimental/art contracts and their deployment scripts.

# Deployments

- Matic Testnet: BeeMinter/ArtfulOne/BEE 0xBdb6677e2de8fc3F61fd5D1Bba8DC0cd51B57641

# Examples:

## deploy contract
`npx hardhat deploy --cid bafybeif26ij5w57tfwg2g5taia25fm7xuvoxcsl4em66kultw7wo62js3i --network matic_testnet`

## minting

`npx hardhat mint-gallery --cid bafybeif26ij5w57tfwg2g5taia25fm7xuvoxcsl4em66kultw7wo62js3i --contract 0xBdb6677e2de8fc3F61fd5D1Bba8DC0cd51B57641 --network matic_testnet`

## On Polygon Testnet:
`npx hardhat verify --network matic_testnet 0xBdb6677e2de8fc3F61fd5D1Bba8DC0cd51B57641 "ArtfulOne" "BEE" "bafybeif26ij5w57tfwg2g5taia25fm7xuvoxcsl4em66kultw7wo62js3i"`
