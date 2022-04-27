// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "./players.sol";


contract PlayerDetail {
    struct playerDetail {
      // Informations for the NFT
      uint gameplay;
      uint numberOfGames;
      uint goals;
      uint level;
      uint saves;
      uint assist;
      string position;
      string playersName;
      string playersName_display;
    }
  }

contract getPlayerSvg is PlayerDetail {

  using Strings for uint; // Allows to convert uints to strings

  Player0 player0;
  Player1 player1;
  Player2 player2;
  Player3 player3;
  Player4 player4;

  //  player.sol contracts, where the svg image of the players saved
  constructor(address _Player0, address _Player1, address _Player2, address _Player3, address _Player4) {
      player0 = Player0(_Player0); // 0xe92539b1D48d01e689Dd3EfD015b555bb2E2387c
      player1 = Player1(_Player1); // 0x71B49A0eEc70426B747A7DB4F11a08f6e3D5efBE
      player2 = Player2(_Player2); // 0x93667BB564E25cdC2718bEAbaC7551108960023f
      player3 = Player3(_Player3); // 0x7887Fef2A1Bc934B0cca633F9c2A53C482Cd9169
      player4 = Player4(_Player4); // 0xfC14D3d9CeA7fA93b22DD329aECf42531Aa77514
  }


  // Gives back svg which will be later used for the NFT
  function getSVG(playerDetail calldata _details,  uint level, uint tokenId, uint score) external view  returns (string memory svg) {

    uint gameplay = _details.gameplay;
    uint numberOfGames = _details.numberOfGames;
    uint goals = _details.goals;
    string memory name = _details.playersName;
    string memory name_display = _details.playersName_display;
    string memory position = _details.position;
    uint assist = _details.assist;
    uint saves = _details.saves;

    svg = '<svg width="390" height="435" fill="green" xmlns="http://www.w3.org/2000/svg">';
    svg = string(abi.encodePacked(svg,
        '<style>',
        'text { font-family: Arial, Helvetica, sans-serif; font-weight:  bold; fill: #ffe500; font-size: 1em; }',
        '.title { text-anchor: left; font-weight: bold; font-size: 1.5em; }',
        '</style>'
    ));
    svg = string(abi.encodePacked(svg, '<rect width="100%" height="100%" fill="', "#e40227" ,'" />'));

    // get part of the svg image from player.sol
    svg = _addImage(svg, name, level);

    // add text on the NFT
    svg = string(abi.encodePacked(svg, '<text x="80" y="40" class="title">', name_display ,'</text>'));
    svg = string(abi.encodePacked(svg, '<text x="20" y="320" >Position: ', position, '</text>'));
    svg = string(abi.encodePacked(svg, '<text x="20" y="340" >Gameplay: ', Strings.toString(gameplay), 'min', '</text>'));
    svg = string(abi.encodePacked(svg, '<text x="20" y="360" >Games: ', Strings.toString(numberOfGames),'</text>'));
    svg = string(abi.encodePacked(svg, '<text x="20" y="380" >Goals: ', Strings.toString(goals), '</text>'));

    // Goalkeeper has tokenid < 4
    if (keccak256(abi.encodePacked("Goalkeeper"))==keccak256(abi.encodePacked(position))) {
      svg = string(abi.encodePacked(svg, '<text x="20" y="400" >Saves: ', Strings.toString(saves), '</text>'));
    } else {
      svg = string(abi.encodePacked(svg, '<text x="20" y="400" >Assist: ', Strings.toString(assist), '</text>'));
    }

    if (tokenId == 1001) { // Place 1!
      svg = string(abi.encodePacked(svg, '<text transform="translate(380,415) rotate(-90)" >Place 1 </text>'));
    }
    if (tokenId == 1002) { // Place 2!
      svg = string(abi.encodePacked(svg, '<text transform="translate(380,415) rotate(-90)" >Place 2 </text>'));
    }
    if (tokenId == 1003) { // Place 3!
      svg = string(abi.encodePacked(svg, '<text transform="translate(380,415) rotate(-90)" >Place 3 </text>'));
    }
    if (tokenId > 10000000) {
      svg = string(abi.encodePacked(svg, '<text transform="translate(380,415) rotate(-90)" >Team NFT </text>'));
    }
    if ( (tokenId>2000) && (tokenId<10000001) ) {
      svg = string(abi.encodePacked(svg, '<text transform="translate(380,415) rotate(-90)" >Total Score: ' , Strings.toString(score) , ' </text>'));
    }
    svg = string(abi.encodePacked(svg, '</svg>'));
  }

// gets part of the svg (image part)
function _addImage(string memory svg, string memory name, uint level) internal view returns (string memory _svg) {
  if (keccak256(abi.encodePacked("player0")) == keccak256(abi.encodePacked(name)) ) {
     _svg = string(abi.encodePacked(svg, player0.getSVG(level)));
  }

  if (keccak256(abi.encodePacked("player1")) == keccak256(abi.encodePacked(name)) ) {
    _svg = string(abi.encodePacked(svg, player1.getSVG(level)));
  }

  if (keccak256(abi.encodePacked("player2")) == keccak256(abi.encodePacked(name)) ) {
    _svg = string(abi.encodePacked(svg, player2.getSVG(level)));
  }

  if (keccak256(abi.encodePacked("player3")) == keccak256(abi.encodePacked(name)) ) {
    _svg = string(abi.encodePacked(svg, player3.getSVG(level)));
  }

  if (keccak256(abi.encodePacked("player4")) == keccak256(abi.encodePacked(name)) ) {
    _svg = string(abi.encodePacked(svg, player4.getSVG(level)));
  }
}

}
