// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./mintingProcess.sol";
import "./svg.sol";

contract Interface {

    // It interacts with the smart Contract to mint players with VRF2
    mintingProcess _mintingProcess;
    SVG _svg;


    // price of 1 Panini
    uint price = 0.01 * (1 ether);

    // earnings and owner can withDraw ether
    uint accumaltedPayment;
    address ownerAddress;

    // parameters for stopping the process;
    bool minting;
    bool upgrading;


    // parameter for the raffle
    address[] ownerOfNft;

    constructor(address mintingProcess_address, address svg_address) {
      _mintingProcess = mintingProcess(mintingProcess_address);
      _svg = SVG(svg_address);
      ownerAddress = msg.sender;

      minting = true;
      upgrading = true;
    }



    // Everybody can get a player
    function buyPlayer() external payable {
        require(minting==true,"No more buying is possible.");
        require(msg.value>price,"Insufficent Funds, please send more ETH.");
        require(msg.value<=(3 ether),"Please buy for less than 3 ETH");

        uint newPlayers = msg.value/price;
        // pay back the to much paid
        if (newPlayers*price<msg.value) {
          payable(msg.sender).transfer(msg.value-newPlayers*price);
        }

        accumaltedPayment += newPlayers*price;

        // mint random players with the help of vrf
        // _mintingProcess.buyPlayer(msg.sender,newPlayers);

        // mint random players with no vrf  (testing with brownie)
        _mintingProcess.buyPlayer_noVrf(msg.sender,newPlayers);
    }


    function upgradeAllToMax() external {
      require(upgrading==true,"No more upgrades are possible.");
      for (uint i = 0; i<5; i++) {

          /*
            no Star Upgrades
          */
          // calculated directly how many we can do
          uint noStar = _svg.balanceOf(msg.sender,4*i);
          // how many gold stars
          uint goldStar = noStar/27;
          // how many noStar are left
          noStar = noStar-27*goldStar;
          // how many silver Star
          uint silverStar = noStar/9;
          // how many no Star are left
          noStar = noStar-9*silverStar;
          // how many bronze Stars
          uint bronzeStar = noStar/3;
          // how many no Star are left
          noStar = noStar - 3*bronzeStar;
          uint burn_noStar = _svg.balanceOf(msg.sender,4*i)-noStar;

          /*
            bronze Star Upgrades
          */
          bronzeStar = bronzeStar+_svg.balanceOf(msg.sender,4*i+1);
          // how many gold stars
          uint goldStar_ = bronzeStar/9;
          goldStar = goldStar + goldStar_;
          bronzeStar = bronzeStar - goldStar_*9;
          // how many silver stars
          uint silverStar_ = bronzeStar/3;
          silverStar = silverStar + silverStar_;
          bronzeStar = bronzeStar - silverStar_*3;
          // check how many burn and mint
          uint burn_bronzeStar = 0;
          uint mint_bronzeStar = 0;
          if (_svg.balanceOf(msg.sender,4*i+1)>bronzeStar) {
            burn_bronzeStar = _svg.balanceOf(msg.sender,4*i+1)-bronzeStar;
          } else {
            mint_bronzeStar = bronzeStar-_svg.balanceOf(msg.sender,4*i+1);
          }

          /*
            silver Star upgrade
          */
          silverStar = silverStar + _svg.balanceOf(msg.sender,4*i+2);
          goldStar_ = silverStar/3;
          goldStar = goldStar + goldStar_;
          silverStar = silverStar - goldStar_*3;
          // check how many burn and mint
          uint burn_silverStar = 0;
          uint mint_silverStar = 0;
          if (_svg.balanceOf(msg.sender,4*i+2)>silverStar) {
            burn_silverStar = _svg.balanceOf(msg.sender,4*i+2)-silverStar;
          } else {
            mint_silverStar = silverStar-_svg.balanceOf(msg.sender,4*i+2);
          }


          // Burn all NFTs which needs to be burned
          // therortically it can be done with _mintBatch but this has some problems
          if (burn_noStar>0) {
            _svg.burnPlayer(4*i, msg.sender, burn_noStar);
          }
          if (burn_bronzeStar>0) {
            _svg.burnPlayer(4*i+1, msg.sender, burn_bronzeStar);
          }
          if (burn_silverStar>0) {
            _svg.burnPlayer(4*i+2, msg.sender, burn_silverStar);
          }
          // Mint all NFTs which need to be minted
          if (mint_bronzeStar>0) {
            _svg.mintPlayer(4*i+1, msg.sender, mint_bronzeStar);
          }
          if (mint_silverStar>0) {
            _svg.mintPlayer(4*i+2, msg.sender, mint_silverStar);
          }
          if (goldStar>0) {
            _svg.mintPlayer(4*i+3, msg.sender, goldStar);
          }
      }

    }




    // Function for just the owner


    /* To dos:
       - Transfer stop
          - raffle
          - burn
          - create a unique nft as combination of the previous ones

      - Keeper:
          - automatic initiate function of players
          - Update Players (simulation of Oracle)
          - automatically update player

      - Direct Swap between players
    */




    function stopMinting() external onlyOwner() {
        minting = false;
    }
    function stopUpgrading() external onlyOwner() {
      upgrading = false;
    }



    function withDraw(address _payout) external onlyOwner() {
      require(accumaltedPayment>0,"No funds.");
      payable(_payout).transfer(accumaltedPayment);
      accumaltedPayment = 0;
    }



    function changeOwner(address _newOwner) external onlyOwner() {
      ownerAddress = _newOwner;
    }

    modifier onlyOwner() {
      require(msg.sender == ownerAddress);
      _;
    }



}
