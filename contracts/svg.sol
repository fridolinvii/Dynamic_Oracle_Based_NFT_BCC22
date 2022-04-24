// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
// import "@openzeppelin/contracts/token/ERC1155/presets/ERC1155PresetMinterPauser.sol";
import "./ERC1155_edited.sol";
import "./getPlayerSvg.sol";


import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";



contract SVG is ERC1155, PlayerDetail {




    playerDetail[] _playerDetail;

    getPlayerSvg getPlayer;
    using Strings for uint; // Allows to convert uints to strings

    string img_name = "FC-Basel";
    string img_description = "Disclaimer: The scope of the project is within the Blockchain Challenge 2022 lecture offered by the University of Basel. The project will remain within the test net. The NFTs will never be sold nor is there any financial interest at hand by the owners or the course responsible."; // The images used are proprietary of https://www.fcb.ch . ";
    bool flag; // Determines the background color of the NFT





    mapping (string => uint[]) playerNameToIndex;
    mapping (uint => uint) distributionForRaffel;
    mapping(uint => uint) score; // Shows scores on the unique NFTs

    address ownerOfContract;
    address[2] contractOfMintingProcess;

    constructor(address _getPlayerSVG) ERC1155("FC-Basel")  {
      getPlayer = getPlayerSvg(_getPlayerSVG); //0x7d1Afa9ef8C19214D93CB27e5E4f5bc3708ed689
      ownerOfContract = msg.sender;
      contractOfMintingProcess[0] = msg.sender;

      // Add players

      _addPlayer("Heinz Lindner","Goalkeeper",0,0,0,0,0);
      _addPlayer("Noah Katterbach","Defence",0,0,0,0,0);
      _addPlayer("Andy Pelmard","Defence",0,0,0,0,0);
      _addPlayer("Pajtim Kasami","Midfield",0,0,0,0,0);
      _addPlayer("Liam Millar","Offense",0,0,0,0,0);

      /* _addPlayer("Heinz Lindner","Goalkeeper",2489,26,0);
      _addPlayer("Noah Katterbach","Defence",766,8,1);
      _addPlayer("Andy Pelmard","Defence",2267,24,0);
      _addPlayer("Pajtim Kasami","Midfield",1734,24,3);
      _addPlayer("Liam Millar","Offense",1611,25,5); */
    }

    modifier onlyOwner() {
        require(ownerOfContract == msg.sender, "Not Owner of Contract");
        _;
    }

    modifier mintingProcess() {
        require(contractOfMintingProcess[0] == msg.sender || contractOfMintingProcess[1] == msg.sender, "Not Owner of Contract");
        _;
    }



    function updateDesciption(string memory _img_description) external onlyOwner() {
      img_description = _img_description;
    }

    function changeOwner(address _newOwner) external onlyOwner() {
      ownerOfContract = _newOwner;
    }

    function changeMintingProcess(address _contractOfMintingProcess, address __contractOfInterface) external onlyOwner() {
      contractOfMintingProcess[0] = _contractOfMintingProcess;
      contractOfMintingProcess[1] = __contractOfInterface;
    }



    // _mintBatch dosen't show on opensea
    /*function mintPlayer(uint[] memory idx, address nftOwner, uint[] memory numberOfPlayer) external mintingProcess() {
      // requirement should be added that only player n%4 can be minted here
        //_mint(nftOwner, idx, numberOfPlayer, "");
      _mintBatch(nftOwner, idx, numberOfPlayer, "");
    }*/
    function mintPlayer(uint idx, address nftOwner, uint numberOfPlayer) external mintingProcess(){
      // requirement should be added that only player n%4 can be minted here
        _mint(nftOwner, idx, numberOfPlayer, "");
    }

    function addDistribution(uint[] calldata _distributionForRaffel) external mintingProcess() {
      uint count = 2001;
      for (uint i = 0; i<_distributionForRaffel.length; i++) {
        distributionForRaffel[count++] = _distributionForRaffel[i];
      }

    }






    function burnPlayer(uint _idx, address nftOwner, uint numberOfPlayer) external mintingProcess()  {
      _burn(nftOwner,_idx, numberOfPlayer);
    }

    function upgradePlayer(string memory _playerName, uint _level, uint _numberOfUpgrades) external {
      require(_level<3, "Wrong value. It should be 0<=level<3");
      uint[] memory tokenId = playerNameToIndex[_playerName];
      uint numberOfPlayerNeeded = 3*_numberOfUpgrades;
      require( balanceOf(msg.sender, tokenId[_level])>=numberOfPlayerNeeded, "Insuficent Players to upgrade");
      _burn(msg.sender,tokenId[_level],numberOfPlayerNeeded);
      _mint(msg.sender,tokenId[_level]+1, _numberOfUpgrades, "");
    }





    function getAddresses() external view  mintingProcess() returns (address[] memory nft_addresses)  {
      nft_addresses = _getAddresses();
    }









    function _addPlayer(string memory _playersName, string memory _position, uint _gameplay, uint _numberOfGames, uint _goals, uint _assist, uint _saves ) internal {

        for (uint i = 0; i<4; i++) {
          uint _level = i;
          _playerDetail.push(playerDetail(_gameplay,_numberOfGames,_goals,_level,_saves,_assist,_position,_playersName));
          playerNameToIndex[_playersName].push(_playerDetail.length-1);
        }
    }






    // function updatePlayer(string calldata _playerName, uint _gameplay, uint _numberOfGames, uint _goals) external mintingProcess()  {
    function updatePlayer(uint player, uint _gameplay, uint _numberOfGames, uint _goals, uint _assist, uint _saves) external mintingProcess()  {

      // player has nothing to do with tokenId!
      string memory _playerName;
      if (player == 4) {
        _playerName = "Noah Katterbach";
      } else if (player == 3) {
        _playerName = "Andy Pelmard";
      } else if (player == 2) {
        _playerName = "Pajtim Kasami";
      } else if (player == 1) {
        _playerName = "Liam Millar";
      } else if (player == 0) {
        _playerName = "Heinz Lindner";
      }


      uint[] memory tokenId = playerNameToIndex[_playerName];
      for (uint i=0; i<tokenId.length; i++){
        _playerDetail[tokenId[i]].gameplay = _gameplay;
        _playerDetail[tokenId[i]].numberOfGames = _numberOfGames;
        _playerDetail[tokenId[i]].goals = _goals;
        _playerDetail[tokenId[i]].saves = _saves;
        _playerDetail[tokenId[i]].assist = _assist;
      }
    }


    function uri(uint tokenId) public view override returns (string memory output) {

        uint star;
        uint _tokenId;
        string memory _img_description;


        if (tokenId<1001) { //normal NFT
          star = _playerDetail[tokenId].level;
          _tokenId = tokenId;
          _img_description = img_description;
        }

       // These are the place 1-3 NFT
        if (tokenId==1001) { // Place 1:
          star = 3;
          _tokenId = 4*(uint(keccak256(abi.encodePacked(tokenId,block.timestamp,"Place 1",star)))% 5);
          _img_description = string(abi.encodePacked("Place 1! ", img_description));
        } else if  (tokenId==1002) { // Place 2:
          star = 2;
          _tokenId = 4*(uint(keccak256(abi.encodePacked(tokenId,block.timestamp,"Place 2",star)))% 5);
          _img_description = string(abi.encodePacked("Place 2! ", img_description));
        } else if (tokenId==1003) { // Place 3:
          star = 1;
          _tokenId = 4*(uint(keccak256(abi.encodePacked(tokenId,block.timestamp,"Place 3",star)))% 5);
          _img_description = string(abi.encodePacked("Place 3! ", img_description));
        }

        if ( (tokenId>2000) && (tokenId<10000001) ) {
          star = 0;
          _tokenId = 4*(uint(keccak256(abi.encodePacked(tokenId,block.timestamp,"Team NFT")))% 5);
          _img_description = string(abi.encodePacked("Unique NFT! ", img_description));
        }
        if ( (tokenId>10000000) ) {
          star = 0;
          _tokenId = 4*(uint(keccak256(abi.encodePacked(tokenId,block.timestamp,"Team NFT")))% 5);
          _img_description = string(abi.encodePacked("Team NFT! ", img_description));
        }

        uint _score = score[tokenId];
        // details calldata _details = details(gameplay[_tokenId],numberOfGames[_tokenId],goals[_tokenId],playersName[_tokenId], position[_tokenId],assist[_tokenId],saves[_tokenId]);

        playerDetail memory _details = _playerDetail[_tokenId];
        string memory svg = getPlayer.getSVG(_details, star, tokenId, _score);
        output = string(abi.encodePacked('data:application/json;base64,', Base64.encode(bytes(string(abi.encodePacked(
            '{"name": "', _playerDetail[_tokenId].playersName, '", "description": "', _img_description, '", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(svg)), '"}'
        ))))));

    }

  // Add score to each unique NFT
  function addScore(uint tokenId,uint _score) external mintingProcess() {
    score[tokenId] = _score;
  }

  // get score from player
  /*
    for all player (except defence) mult = 1, for defence mult = 2
    score = 1 + numberOfGames + gameplay/10 + mult*(goals + assist) + saves/20

    */
  function getScoreFromPlayer(uint tokenId)
        external view  mintingProcess() returns (uint score) {
          uint mult = 1;
          if (keccak256(abi.encodePacked("Defence"))==keccak256(abi.encodePacked(_playerDetail[tokenId].position))) {
            mult = 2;
          }
          score = 1 + _playerDetail[tokenId].numberOfGames + _playerDetail[tokenId].gameplay/10 + mult*(_playerDetail[tokenId].goals + _playerDetail[tokenId].assist) + _playerDetail[tokenId].saves;
  }
}
/// [MIT License]
/// @title Base64
/// @notice Provides a function for encoding some bytes in base64
/// @author Brecht Devos <brecht@loopring.org>
library Base64 {
    bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /// @notice Encodes some bytes to the base64 representation
    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((len + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}
