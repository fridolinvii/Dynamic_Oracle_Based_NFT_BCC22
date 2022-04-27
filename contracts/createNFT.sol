// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
// import "@openzeppelin/contracts/token/ERC1155/presets/ERC1155PresetMinterPauser.sol";
import "./ERC1155_edited.sol";
import "./getPlayerSvg.sol";


import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/utils/Strings.sol";



contract createNFT is ERC1155, PlayerDetail {


    // This gives the Name on Opensea
    string public name;


    // Events
    event Minting(uint idx, address indexed nftOwner, uint numberOfPlayer);
    ///////////////////////////////////////////////////////////////////////


    playerDetail[] _playerDetail;

    // comunicates with getPlayerSvg.sol
    getPlayerSvg getPlayer;

    using Strings for uint; // Allows to convert uints to strings

    // What will be written in the NFT description and its Name;
    string img_name;
    string img_description;

    mapping (string => uint[]) playerNameToIndex;
    mapping (uint => uint) distributionForRaffel;
    mapping (uint => uint) totalScore; // Shows scores on the unique NFTs from all NFTs the person owns

    // addresses for owner and allow list
    address ownerOfContract;
    address[2] contractOfMintingProcess;

    constructor(address _getPlayerSVG, string memory _NFT_name) ERC1155("FC-Chainlink")  {

      name = _NFT_name;

      getPlayer = getPlayerSvg(_getPlayerSVG); //0x3C9d769fAf0085b98F2112117Ef124E14beB809d
      ownerOfContract = msg.sender;
      contractOfMintingProcess[0] = msg.sender;

      // Add players
      _addPlayer("player0","Goalkeeper",0,0,0,0,0,"Worms Weewax");
      _addPlayer("player1","Defence",0,0,0,0,0,"Buttocks Winterkorn");
      _addPlayer("player2","Defence",0,0,0,0,0,"Dicman Guster");
      _addPlayer("player3","Midfield",0,0,0,0,0,"TeeTee Endicott");
      _addPlayer("player4","Offense",0,0,0,0,0,"Scut Sackrider");


      // update image infos
      img_name = "FC-Chainlink";
      img_description = "Disclaimer: The scope of the project is within the Blockchain Challenge 2022 lecture offered by the University of Basel. The project will remain within the test net. The NFTs will never be sold nor is there any financial interest at hand by the owners or the course responsible.";
    }

    ////////////////////////////////////////////////////////////////////////////
    // Owner Manager
    modifier onlyOwner() {
        require(ownerOfContract == msg.sender, "Not Owner of Contract");
        _;
    }

    modifier mintingProcess() {
        require(contractOfMintingProcess[0] == msg.sender || contractOfMintingProcess[1] == msg.sender, "Not Permision to interact with createNFT");
        _;
    }


    function changeOwner(address _newOwner) external onlyOwner() {
      ownerOfContract = _newOwner;
    }

    function changeMintingProcess(address _contractOfMintingProcess, address __contractOfInterface) external onlyOwner() {
      contractOfMintingProcess[0] = _contractOfMintingProcess;
      contractOfMintingProcess[1] = __contractOfInterface;
    }





    ////////////////////////////////////////////////////////////////////////////

    // Functions for the NFT

    // update desciption of the nft
    function updateDesciption(string memory _img_description) external onlyOwner() {
      img_description = _img_description;
    }

    function mintPlayer(uint idx, address nftOwner, uint numberOfPlayer) external mintingProcess(){
        _mint(nftOwner, idx, numberOfPlayer, "");
        // _mintBatch dosen't show on opensea (at the time of testing)

        // Events
        emit Minting(idx, nftOwner, numberOfPlayer);
    }

    function burnPlayer(uint _idx, address nftOwner, uint numberOfPlayer) external mintingProcess()  {
      _burn(nftOwner,_idx, numberOfPlayer);
    }


    // _getAddresses is from ERC1155_edited.sol, it gives back all of the potential owners of NFTs.
    // This is important for the raffel
    function getAddresses() external view  mintingProcess() returns (address[] memory nft_addresses)  {
      nft_addresses = _getAddresses();
    }


    // update uri function so it can use on chain data
    function uri(uint tokenId) public view override returns (string memory output) {

        uint star;
        uint _tokenId;
        string memory _img_description;

        if (tokenId<1001) { //normal NFT
          star = _playerDetail[tokenId].level;
          _tokenId = tokenId;
          _img_description = img_description;
        }


        // Note: all these unique NFT have a dynamic svg part, meaning it changes the image over time!

       // These are the place 1-3 NFT
        if (tokenId==1001) { // Place 1:
          star = 3;
          _tokenId = 4*(uint(keccak256(abi.encodePacked(tokenId,block.timestamp,"Place 1",star)))% 5);  // which image it chooses
          _img_description = string(abi.encodePacked("Place 1! ", img_description));
        } else if  (tokenId==1002) { // Place 2:
          star = 2;
          _tokenId = 4*(uint(keccak256(abi.encodePacked(tokenId,block.timestamp,"Place 2",star)))% 5); // which image it chooses
          _img_description = string(abi.encodePacked("Place 2! ", img_description));
        } else if (tokenId==1003) { // Place 3:
          star = 1;
          _tokenId = 4*(uint(keccak256(abi.encodePacked(tokenId,block.timestamp,"Place 3",star)))% 5); // which image it chooses
          _img_description = string(abi.encodePacked("Place 3! ", img_description));
        }

        // Unique NFTs (gives total score of all player owned at time of raffle)
        if ( (tokenId>2000) && (tokenId<10000001) ) {
          star = 0;
          _tokenId = 4*(uint(keccak256(abi.encodePacked(tokenId,block.timestamp,"Team NFT")))% 5); // which image it chooses
          _img_description = string(abi.encodePacked("Unique NFT! ", img_description));
        }
        // Team NFTs (gives total score of all player owned at time of raffle)
        if ( (tokenId>10000000) ) {
          star = 0;
          _tokenId = 4*(uint(keccak256(abi.encodePacked(tokenId,block.timestamp,"Team NFT")))% 5); // which image it chooses
          _img_description = string(abi.encodePacked("Team NFT! ", img_description));
        }


        uint _score = totalScore[tokenId];
        playerDetail memory _details = _playerDetail[_tokenId];
        string memory svg = getPlayer.getSVG(_details, star, tokenId, _score);

        string memory svg2 = string(abi.encodePacked('{"name": "', _details.playersName_display, '",'
            ' "description": "', _img_description, '",'
            ' "image": "data:image/svg+xml;base64,', Base64.encode(bytes(svg)), '",'
            ' "attributes": ['));
        svg2 = string(abi.encodePacked(svg2,'{"trait_type": "Name","value": "', _details.playersName_display, '"},'
              '{"trait_type": "Position","value": "', _details.position, '"},'
              '{"trait_type": "Gameplay","value": "', Strings.toString(_details.gameplay), '"},'
              '{"trait_type": "Games","value": "', Strings.toString(_details.numberOfGames), '"},'));
        svg2 = string(abi.encodePacked(svg2,'{"trait_type": "Goals","value": "', Strings.toString(_details.goals), '"},'
              '{"trait_type": "Level","value": "', Strings.toString(_details.level), '"},'
              '{"trait_type": "Saves","value": "', Strings.toString(_details.saves), '"},'
              '{"trait_type": "Assist","value": "', Strings.toString(_details.assist), '"},'
              '{"trait_type": "Score","value": "', Strings.toString(_getScoreFromPlayer(_tokenId)), '"}'
            ']'
            '}'));

        output = string(abi.encodePacked('data:application/json;base64,', Base64.encode(bytes(svg2))));
    }

    ////////////////////////////////////////////////////////////////////////////
    // Interaction with Players
    function _addPlayer(string memory _playersName, string memory _position, uint16 _gameplay, uint16 _numberOfGames, uint16 _goals, uint16 _assist, uint16 _saves, string memory _playersName_display) internal {
        for (uint16 i = 0; i<4; i++) {
          uint16 _level = i;
          _playerDetail.push(playerDetail(_gameplay,_numberOfGames,_goals,_level,_saves,_assist,_position,_playersName, _playersName_display));
          playerNameToIndex[_playersName].push(_playerDetail.length-1);
        }
    }

    function updatePlayer(uint player, uint16 _gameplay, uint16 _numberOfGames, uint16 _goals, uint16 _assist, uint16 _saves) external mintingProcess()  {
      // player has nothing to do with tokenId!
      string memory _playerName;
      if (player == 4) {
        _playerName = "player4";
      } else if (player == 3) {
        _playerName = "player3";
      } else if (player == 2) {
        _playerName = "player2";
      } else if (player == 1) {
        _playerName = "player1";
      } else if (player == 0) {
        _playerName = "player0";
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


    ////////////////////////////////////////////////////////////////////////////
    // Data for the raffel and unique NFT

    function addDistribution(uint[] calldata _distributionForRaffel)
                                                    external mintingProcess() {
      uint count = 2001;
      for (uint i = 0; i<_distributionForRaffel.length; i++) {
        distributionForRaffel[count++] = _distributionForRaffel[i];
      }
    }

    // Add score to each unique NFT
    function addScore(uint tokenId,uint _totalScore) external mintingProcess() {
      totalScore[tokenId] = _totalScore;
    }

  // get score from player
  function getScoreFromPlayer(uint tokenId)
        external view  mintingProcess() returns (uint _score) {
          _score = _getScoreFromPlayer(tokenId);
  }

  function _getScoreFromPlayer(uint tokenId)
        internal view returns (uint _score) {
          uint mult = 1;
          if (keccak256(abi.encodePacked("Defence"))==keccak256(abi.encodePacked(_playerDetail[tokenId].position))) {
            mult = 2;
          }
          _score = 1 + _playerDetail[tokenId].numberOfGames + _playerDetail[tokenId].gameplay/10 + mult*(_playerDetail[tokenId].goals + _playerDetail[tokenId].assist) + _playerDetail[tokenId].saves;
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
