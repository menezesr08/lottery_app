# Decentralized Lottery App

A simple decentralized lottery app demonstration using Flutter + Web3

Particpate by sending 0.1 eth to the contract and once 3 participants or more have placed their bids, then the owner/manager of the lottery can assign a winner and send the total prize amount to the winner.

# Features

- Connect to Metamask with Flutter
- Use different metamask accounts to interact with the lottery app
- Send eth to the smart contract via transactions
- Call smart contract functions with Flutter and receive data

# Step by step demonstration: 

1) Connect to metamask.
2) Manager (aka person who deployed the contract) can send eth to participate in the lottery.
3) 3 other accounts will also send eth to participate in the lottery.
4) Manager can check the total balance (prize pool) and the randomly pick a winner
5) Smart contract sends the prize to the winner.

# Video demonstration: 
https://streamable.com/hp7c2h

# Test the project yourself
1) Download the project from github and run the dependencies with the command `flutter pub get`
2) You will then update the variables in the `constants.dart` file.
3) First you will need to deploy your own version of the contract. This is so that you become the manager. You can find the smart contract code here:         -- https://gist.github.com/menezesr08/c7cdae90220f73ada01a6a68b696c4ab
- Copy the code from the gist into remix and deploy the contract. You can then update the `contractAddress` with your own contract address.
- You can also update the `managerPublicKey` with the public address of the account that you used to deploy the contract.
- You are now the manager of the smart contract!
4) You can also grab your own `infuraUrl` from https://infura.io/
5) And that's it. You can begin sending ether to the smart contract and randomly pick a winner!

  
### The smart contract was inspired by the course: https://www.udemy.com/course/master-ethereum-and-solidity-programming-with-real-world-apps
