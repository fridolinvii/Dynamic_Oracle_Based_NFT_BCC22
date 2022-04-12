// SPDX-License-Identifier: MIT
// An example of a consumer contract that relies on a subscription for funding.
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "./svg.sol";
// import "./translateNumber.sol";

contract mintingProcess is VRFConsumerBaseV2 {
  VRFCoordinatorV2Interface COORDINATOR;
  SVG svg;
  // translateNumber randNumber;

  // Your subscription ID.
  uint64 s_subscriptionId;

  // Rinkeby coordinator. For other networks,
  // see https://docs.chain.link/docs/vrf-contracts/#configurations
  address vrfCoordinator = 0x6168499c0cFfCaCD319c818142124B7A15E857ab;

  // The gas lane to use, which specifies the maximum gas price to bump to.
  // For a list of available gas lanes on each network,
  // see https://docs.chain.link/docs/vrf-contracts/#configurations
  bytes32 keyHash = 0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;

  // Depends on the number of requested values that you want sent to the
  // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
  // so 100,000 is a safe default for this example contract. Test and adjust
  // this limit based on the network that you select, the size of the request,
  // and the processing of the callback request in the fulfillRandomWords()
  // function.
  uint32 callbackGasLimit = 1000000;

  // The default is 3, but you can set this higher.
  uint16 requestConfirmations = 3;

  // For this example, retrieve 2 random values in one request.
  // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
  uint32 numWords =  1;



  // change this to private
  uint256[] public s_randomWords;
  uint256 public s_requestId;
  address s_owner;
  address interface_address;


  address[] minting;
  uint[] numberOfPlayer;
  uint mintingCounter = 0;
  uint price = 0.01 * (1 ether);
  uint accumaltedPayment = 0;


  constructor(uint64 subscriptionId, address svg_address) VRFConsumerBaseV2(vrfCoordinator) { //2103
    COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
    svg = SVG(svg_address); // 0xd08A73a705070F394389a0656eDeF85D410c7d16
    // randNumber = translateNumber(translateNumber_address);
    s_owner = msg.sender;
    interface_address = msg.sender;
    s_subscriptionId = subscriptionId;
  }



  // Assumes the subscription is funded sufficiently.
  // get Random number, if it arrives minting will start in fulfillRandomWords
  function buyPlayer(address _newOwner, uint newPlayers) external  interfaceAddress() {


    // Will revert if subscription is not set and funded.
    s_requestId = COORDINATOR.requestRandomWords(
      keyHash,
      s_subscriptionId,
      requestConfirmations,
      callbackGasLimit,
      numWords
    );

    // push new owner of NFT
    minting.push(_newOwner);

    // Compute automatically number of NFT bought, and return the rest
    numberOfPlayer.push(newPlayers);



  }




  // Here the random number is given back
  // After getting random number minting starts
  function fulfillRandomWords(
    uint256, /* requestId */
    uint256[] memory randomWords
  ) internal override {
    s_randomWords = randomWords;

    // give random number of players
    uint player0 = 0;
    uint player1 = 0;
    uint player2 = 0;
    uint player3 = 0;
    uint player4 = 0;

    for (uint i = 0; i<numberOfPlayer[mintingCounter]; i++) {
      uint idx = uint(keccak256(abi.encodePacked(randomWords[0],i))) % 5;
      // uint idx = randNumber.getRandomNumber(randomNumber,i,5);
      // This gives an error
      //player[idx] += 1;
      if (idx == 0 ) {
        player0++;
      } else if (idx == 1 ){
        player1++;
      } else if (idx == 2 ){
        player2++;
      } else if (idx == 3 ){
        player3++;
      } else if (idx == 4 ){
        player4++;
      }
    }

    uint[5] memory player = [player0,player1,player2,player3,player4];


    for (uint i = 0; i<player.length; i++){
      if (player[i]>0){
        svg.mintPlayer(i*4,minting[mintingCounter],player[i]);
        }
    }
    mintingCounter += 1;

  }


  // For Brownie: No VRF but simulates minting process
  function buyPlayer_noVrf(address _newOwner, uint newPlayers) external interfaceAddress() {

    minting.push(_newOwner);
    numberOfPlayer.push(newPlayers);
    uint randomNumber = block.timestamp;



    uint player0 = 0;
    uint player1 = 0;
    uint player2 = 0;
    uint player3 = 0;
    uint player4 = 0;

    for (uint i = 0; i<numberOfPlayer[mintingCounter]; i++) {
      uint idx = uint(keccak256(abi.encodePacked(randomNumber,i))) % 5;
      // uint idx = randNumber.getRandomNumber(randomNumber,i,5);
      // This gives an error
      //player[idx] += 1;
      if (idx == 0 ) {
        player0++;
      } else if (idx == 1 ){
        player1++;
      } else if (idx == 2 ){
        player2++;
      } else if (idx == 3 ){
        player3++;
      } else if (idx == 4 ){
        player4++;
      }
    }

    uint[5] memory player = [player0,player1,player2,player3,player4];


    for (uint i = 0; i<player.length; i++){
      if (player[i]>0){
        svg.mintPlayer(i*4,minting[mintingCounter],player[i]);
        }
    }


    mintingCounter += 1;

  }



  // Access to contract

  function changeInterfaceAddress(address _interface_address) external onlyOwner() {
    interface_address = _interface_address;
  }

  function changeOwner(address newOwner) external onlyOwner() {
    s_owner = newOwner;
  }


  modifier interfaceAddress() {
    require(msg.sender == interface_address);
    _;
  }


  modifier onlyOwner() {
    require(msg.sender == s_owner);
    _;
  }
}
