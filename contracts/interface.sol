// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";
import "./mintingProcess.sol";
import "./createNFT.sol";

// Here is the main contract. In addition the weeker work in this smart contract
contract Interface is KeeperCompatibleInterface {



  // Events
  event BuyPlayers(uint price, uint numberOfNewPlayers, address indexed owner);
  event UpgradeAllTokens(address indexed owner);
  event DrawWinnerOfRaffel();
  event UpdatePlayer();
  event TeanNFT(uint tokenId, address indexed owner);
  event UniqueNFT(uint tokenId, address indexed owner);

  //////////////////////////////////////////


    // use vrf/keeper/oracle (true) or simulate vrf/keeper/oracle (false)
    bool vrf;
    bool keeper;
    bool oracle;

    // It interacts with the smart Contract to mint players with VRF2
    mintingProcess _mintingProcess;
    createNFT _createNFT;


    // price of 1 Panini
    uint price = 0.001 * (1 ether);

    // earnings and owner can withDraw ether
    uint accumaltedPayment;
    address ownerAddress;

    // parameters for stopping the process;
    bool minting;
    bool upgrading;

    // Parameters for Raffel  (maybe not needed to define here, but problems with push if defined in function)
    uint[] distributionForRaffel;
    address[] nft_addresses;
    bool[] has_team;


    // parameter for keeper
    uint startTime;
    uint startRaffel;
    uint checkOracle;
    uint lastOracle;


    // update player statistic for oracle simulation
    uint16[5] time;
    uint16[5] games;
    uint16[5] score;
    uint16[5] assist;
    uint16 saves = 0; // only goalkeeper


    constructor(address mintingProcess_address, address createNFT_address, bool _vrf, bool _keeper, bool _oracle, uint _startRaffel, uint _checkOracle) {   //0x39B4F3cA83CE0f9C2e4Cd903fABDf3871D4AbcB1

      _mintingProcess = mintingProcess(mintingProcess_address); //
      _createNFT = createNFT(createNFT_address);  //
      ownerAddress = msg.sender;

      vrf = _vrf;
      keeper = _keeper;
      oracle = _oracle;

      startTime = block.timestamp;
      lastOracle = 0;
      startRaffel = _startRaffel * (1 minutes);
      checkOracle = _checkOracle * (1 minutes);

      minting = true;
      upgrading = true;
    }



    ////////////////////////////////////////////////////////////////////////////
    // OWNER MANAGEMENT

    function changeOwner(address _newOwner) external onlyOwner() {
      ownerAddress = _newOwner;
    }

    modifier onlyOwner() {
      require(msg.sender == ownerAddress);
      _;
    }

    function withDraw(address _payout) external onlyOwner() {
      require(accumaltedPayment>0,"No funds.");
      payable(_payout).transfer(accumaltedPayment);
      accumaltedPayment = 0;
    }

    // Change if you use VRF (true) or simulation of VRF (false)
    function changeSimulation(bool _vrf,bool _keeper,bool _oracle) external onlyOwner() {
      vrf = _vrf;
      keeper = _keeper;
      oracle = _oracle;
    }


    ////////////////////////////////////////////////////////////////////////////
    // Buy and Upgrading Trading Cards

    // Buy players with sending 0.001-0.3 eth to this smart contract
    // upgrade players when sending 0 eth  to this smart contract
    receive() external payable {
        if (msg.value>0) {
          _buyPlayer(msg.value, msg.sender);
        } else {
          _upgradeAllToMax();
        }
    }

    // Buy player and upgrade player as function
    function buyPlayer() external payable {
        _buyPlayer(msg.value, msg.sender);
    }

    function upgradeAllToMax() external {
      _upgradeAllToMax();
    }


    // buy player
    function _buyPlayer(uint msgvalue, address msgsender) internal {
        require(minting==true,"No more buying is possible.");
        require(msgvalue>=price,"Insufficent Funds, please send more ETH.");
        require(msgvalue<=0.3*(1 ether),"Please buy for less than .3 ETH");

        uint newPlayers = msgvalue/price;
        // pay back the to much paid
        if (newPlayers*price<msgvalue) {
          payable(msgsender).transfer(msgvalue-newPlayers*price);
        }

        accumaltedPayment += newPlayers*price;

        // mint random players with the help of vrf
        _mintingProcess.buyPlayer(msgsender,newPlayers, vrf);
        // Drawback: vrf=true, NFT are hidden when from Airdrop in opensea
        // have to verfiy contract

        // Event
        emit BuyPlayers(newPlayers*price, newPlayers, msgsender);

    }

    function _upgradeAllToMax() internal {
      require(upgrading==true,"No more upgrades are possible.");

      // Check if it can be upgraded
      bool upgradeable = false;
      for (uint i = 0; i<5; i++){
        if ( (_createNFT.balanceOf(msg.sender,4*i)>=3) || (_createNFT.balanceOf(msg.sender,4*i+1)>=3) || (_createNFT.balanceOf(msg.sender,4*i+2)>=3) )  {
            upgradeable = true;
            break;
        }
      }
      require(upgradeable==true, "All cards are at maximum.");


      // Upgrade Cards
      for (uint i = 0; i<5; i++) {

          /*
            no Star Upgrades
          */
          // calculated directly how many we can do
          uint noStar = _createNFT.balanceOf(msg.sender,4*i);
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
          uint burn_noStar = _createNFT.balanceOf(msg.sender,4*i)-noStar;

          /*
            bronze Star Upgrades
          */
          bronzeStar = bronzeStar+_createNFT.balanceOf(msg.sender,4*i+1);
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
          if (_createNFT.balanceOf(msg.sender,4*i+1)>bronzeStar) {
            burn_bronzeStar = _createNFT.balanceOf(msg.sender,4*i+1)-bronzeStar;
          } else {
            mint_bronzeStar = bronzeStar-_createNFT.balanceOf(msg.sender,4*i+1);
          }

          /*
            silver Star upgrade
          */
          silverStar = silverStar + _createNFT.balanceOf(msg.sender,4*i+2);
          goldStar_ = silverStar/3;
          goldStar = goldStar + goldStar_;
          silverStar = silverStar - goldStar_*3;
          // check how many burn and mint
          uint burn_silverStar = 0;
          uint mint_silverStar = 0;
          if (_createNFT.balanceOf(msg.sender,4*i+2)>silverStar) {
            burn_silverStar = _createNFT.balanceOf(msg.sender,4*i+2)-silverStar;
          } else {
            mint_silverStar = silverStar-_createNFT.balanceOf(msg.sender,4*i+2);
          }


          // Burn all NFTs which needs to be burned
          // therortically it can be done with _mintBatch but this has some problems
          if (burn_noStar>0) {
            _createNFT.burnPlayer(4*i, msg.sender, burn_noStar);
          }
          if (burn_bronzeStar>0) {
            _createNFT.burnPlayer(4*i+1, msg.sender, burn_bronzeStar);
          }
          if (burn_silverStar>0) {
            _createNFT.burnPlayer(4*i+2, msg.sender, burn_silverStar);
          }
          // Mint all NFTs which need to be minted
          if (mint_bronzeStar>0) {
            _createNFT.mintPlayer(4*i+1, msg.sender, mint_bronzeStar);
          }
          if (mint_silverStar>0) {
            _createNFT.mintPlayer(4*i+2, msg.sender, mint_silverStar);
          }
          if (goldStar>0) {
            _createNFT.mintPlayer(4*i+3, msg.sender, goldStar);
          }
      }

      emit UpgradeAllTokens(msg.sender);

    }



      //////////////////////////////////////////////////////////////////////////
      // RAFFLE

      // get addresses from all possible owner from NFT (modified in ERC1155_edited.)
      function getAddresses() external view  onlyOwner() returns (address[] memory _nft_addresses)  {
        _nft_addresses = _createNFT.getAddresses();
      }

      // This will use the raffle
      function _createDistributionForRaffel() internal {
        require(minting==true,"Raffel was done.");
        require(upgrading=true,"Raffel was done.");

        // Deactivate Mining and Upgrading possibilty
        minting = false;
        upgrading = false;

        address[] memory _nft_addresses = _createNFT.getAddresses();
        for (uint a = 0; a<_nft_addresses.length; a++) {

          uint points = 0;
          uint player_count = 0;
          for (uint i = 0; i<5; i++) {
            uint _points = 1*_createNFT.balanceOf(_nft_addresses[a],i*4);
            _points += 4*_createNFT.balanceOf(_nft_addresses[a],i*4+1);
            _points += 15*_createNFT.balanceOf(_nft_addresses[a],i*4+2);
            _points += 30*_createNFT.balanceOf(_nft_addresses[a],i*4+3);

            _points *= _createNFT.getScoreFromPlayer(i*4);

            // Check if they have a player
            if (_points>0) {
              player_count += 1;
            }

            points += _points;
          }
          // Only people who own a nft can be part of the raffle
          if (points>0) {
            distributionForRaffel.push(points);
            nft_addresses.push(_nft_addresses[a]);

            // Team here has 5 players. True, if own whole team
            if (player_count == 5) {
              has_team.push(true);
            } else {
              has_team.push(false);
            }
          }

        }

        _mintingProcess.drawWinnerOfRaffel(distributionForRaffel,nft_addresses,has_team,vrf);
        // Drawback: vrf=true, NFT are hidden when from Airdrop in opensea
        // have to verfiy contract

        emit DrawWinnerOfRaffel();

      }




      //////////////////////////////////////////////////////////////////////////
      // ORACLE

      // update players
      function _updatePlayer() internal {
        // Here should be access to the Oracle

        //  simulate Oracle
        if (oracle==false){

            for (uint i=0; i<time.length; i++) {
              uint16 randomNumber = uint16(uint((keccak256(abi.encodePacked(block.timestamp,i)))));
              games[i] += randomNumber % 2;
              if ((randomNumber % 2)>0) { // only update if the player plaid
                  time[i] += 30+(randomNumber % 60);
                  score[i] += (randomNumber % 3);
                  assist[i] += (randomNumber % 4);
                  if (i==0) { //This is goalkeeper
                      saves += 10+(randomNumber % 50);
                      _createNFT.updatePlayer(i, time[i], games[i], score[i], 0, saves);
                  } else {
                      _createNFT.updatePlayer(i, time[i], games[i], score[i], assist[i], 0);
                  }
              }

            }

          }

          emit UpdatePlayer();

      }


    ////////////////////////////////////////////////////////////////////////////
    // Keeper manager

    // keeper check this condition
    function checkUpkeep(bytes calldata) external view override returns (bool upkeepNeeded, bytes memory performData) {
        require(keeper);
        upkeepNeeded  = _checkUpkeep();
      }

    // will execute when upkeepNeeded=true (by keeper)
    function performUpkeep(bytes calldata performData ) external override {
        require(keeper);
        _performUpkeep();
    }


    function _checkUpkeep() internal view returns (bool upkeepNeeded) {
        // Stops everything after raffle
        require(minting && upgrading);
        // Update Oracle
        if ( (block.timestamp-lastOracle)>checkOracle) {
          upkeepNeeded = true;
        }
        // Raffel
        if ( (block.timestamp-startTime)>startRaffel) {
          upkeepNeeded = true;
        }


      }

      function _performUpkeep() internal {
          require(minting && upgrading);
          // Stops everything after raffle

          // Check Oracle
          if  ( (block.timestamp-lastOracle)>checkOracle) {
            lastOracle = block.timestamp;
            _updatePlayer();
          }
          //Start Raffel
          if ( (block.timestamp-startTime)>startRaffel) {
            _createDistributionForRaffel();
          }
        }

      // simulate keeper
      function simulateKeeper() external onlyOwner() {
        require(keeper == false, "Please set keeper to false.");
        bool upkeepNeeded;
        upkeepNeeded  = _checkUpkeep();

        if (upkeepNeeded) {
          _performUpkeep();
        }

      }

}
