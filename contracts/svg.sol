// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/presets/ERC1155PresetMinterPauser.sol";
import "./getPlayerSvg.sol";


import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";



contract SVG is ERC1155PresetMinterPauser {
// contract SVG is ERC1155 {

    getPlayerSvg getPlayer;
    using Strings for uint; // Allows to convert uints to strings

    string img_name = "FC-Basel";
    string img_description = "Disclaimer: The scope of the project is within the Blockchain Challenge 2022 lecture offered by the University of Basel. The project will remain within the test et. The NFTs will never be sold nor is there any financial interest at hand by the owners or the course responsible."; // The images used are proprietary of https://www.fcb.ch . ";
    bool flag; // Determines the background color of the NFT


    // Informations for the NFT
    uint[] gameplay;
    uint[] numberOfGames;
    uint[] goals;
    uint[] level;
    string[] position;
    string[] playersName;
    mapping (string => uint[]) playerNameToIndex;


    address ownerOfContract;
    address[2] contractOfMintingProcess;

    constructor(address _getPlayerSVG) ERC1155PresetMinterPauser("FC-Basel")  {
    // constructor(address _getPlayerSVG) ERC1155("FC-Basel")  {
      getPlayer = getPlayerSvg(_getPlayerSVG); //0x570674c3f93208524F77967d1aA967FbDbD27198
      ownerOfContract = msg.sender;
      contractOfMintingProcess[0] = msg.sender;
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










    function addPlayer(string memory _playersName, string memory _position, uint _gameplay, uint _numberOfGames, uint _goals ) external onlyOwner() {

        for (uint i = 0; i<4; i++) {
          playersName.push(_playersName);
          position.push(_position);
          gameplay.push(_gameplay);
          numberOfGames.push(_numberOfGames);
          goals.push(_goals);
          level.push(i);
          playerNameToIndex[_playersName].push(playersName.length-1);
        }
    }






    function updatePlayer(string memory _playerName, uint _gameplay, uint _numberOfGames, uint _goals) external onlyOwner() {

      uint[] memory tokenId = playerNameToIndex[_playerName];
      for (uint i=0; i<tokenId.length; i++){
        gameplay[tokenId[i]] = _gameplay;
        numberOfGames[tokenId[i]] = _numberOfGames;
        goals[tokenId[i]] = _goals;
      }
    }


    function uri(uint tokenId) public view override returns (string memory output) {

        string memory svg = getPlayer.getSVG(gameplay[tokenId], numberOfGames[tokenId], goals[tokenId], playersName[tokenId], position[tokenId], level[tokenId]);


        output = string(abi.encodePacked('data:application/json;base64,', Base64.encode(bytes(string(abi.encodePacked(
            '{"name": "', playersName[tokenId], '", "description": "', img_description, '", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(svg)), '"}'
        ))))));

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
