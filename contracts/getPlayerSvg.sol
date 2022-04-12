// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "./players.sol";

contract getPlayerSvg {

  using Strings for uint; // Allows to convert uints to strings

  AndyPelmard andyPelmard;
  LiamMillar liamMillar;
  NoahKatterbach noahKatterbach;
  PajtimKasami pajtimKasami;
  HeinzLindner heinzLindner;


  constructor(address _AndyPelmard, address _LiamMillar, address _NoahKatterbach, address _PajtimKasami, address _HeinzLindner) {
      andyPelmard = AndyPelmard(_AndyPelmard); // 0x84919768c2dDAc6a6202eefFBa3ec47bDC760e0E
      liamMillar = LiamMillar(_LiamMillar); // 0x55D6d5ab809c402454f5Da78F78fF54861c29834       // This one has problems
      noahKatterbach = NoahKatterbach(_NoahKatterbach); // 0x82cA5529B5D888444eE596260040BEa5A49AA30d
      pajtimKasami = PajtimKasami(_PajtimKasami); // 0x82cA5529B5D888444eE596260040BEa5A49AA30d // wrong svg
      heinzLindner = HeinzLindner(_HeinzLindner); // 0xAC40388dC15E52A63Fed7D5421f2a1961aD20A08
  }



  function getSVG(uint gameplay, uint numberOfGames, uint goals, string memory name, string memory position, uint level) external view  returns (string memory svg) {

    svg = '<svg width="390" height="435" fill="green" xmlns="http://www.w3.org/2000/svg">';
    svg = string(abi.encodePacked(svg,
        '<style>',
        'text { font-family: Arial, Helvetica, sans-serif; font-weight:  bold; fill: #ffe500; font-size: 1em; }',
        '.title { text-anchor: left; font-weight: bold; font-size: 1.5em; }',
        '</style>'
    ));
    svg = string(abi.encodePacked(svg, '<rect width="100%" height="100%" fill="', "#e40227" ,'" />'));

    svg = addImage(svg, name, level);

    /*
    if (level>0) {
      //svg = string(abi.encodePacked(svg, '<path type="star" ; fill="#9c5221";  d="m 63.5,82.309523 -8.284327,-4.308591 -8.245826,4.381825 1.537715,-9.210291 -6.715463,-6.488189 9.234687,-1.383682 4.095442,-8.391746 4.169636,8.355129 9.246585,1.301804 -6.657711,6.547436 z" transform="translate(230 -100) scale(2)"/>'));
      svg = string(abi.encodePacked(svg, '<path style="fill:#9c5221"  d="m -3.2016949e-6,1159 c 2.1344633e-6,0 1.0672316e-6,0 0,0 z M 0.1268068,289.75 c -0.08453787,579.5 -0.04226893,289.75 0,0 z m 207.1905932,4.52111 34.8174,-25.34859 34.429,25.03754 c 18.936,13.77065 34.9931,25.15058 35.6826,25.28874 0.6895,0.13816 1.1307,-0.49554 0.9806,-1.40821 -0.1502,-0.91268 -6.1101,-19.57424 -13.2442,-41.47013 -10.1878,-31.26816 -12.7041,-40.05127 -11.727,-40.93175 0.6843,-0.61657 17.14983,-11.79288 35.7009,-26.02987 L 358.4134,184.5 314.0711,184 269.7287,183.5 256.4878,142.70675 c -4.72603,-13.49006 -10.17035,-29.31454 -14.43246,-42.32564 -0.265,0.26498 -6.90204,19.41565 -14.09254,41.61917 -7.1905,22.20352 -13.3003,40.73671 -13.5772,41.18488 C 214.1086,183.63332 194.3335,184 170.441,184 c -23.89257,0 -43.42888,0.3375 -43.41405,0.75 0.0148,0.4125 15.76483,12.1502 35.00005,26.08379 19.2351,13.93359 34.9725,25.63359 34.972,26 -6e-4,0.36642 -6.0752,19.34121 -13.499,42.16621 -7.4239,22.825 -13.4984,41.63906 -13.499,41.80902 0,0.58693 2.63612,-1.28915 37.3164,-26.53791 z" transform="translate(300,0) scale(0.2)"/>'));
    if (level>1) {
      // svg = string(abi.encodePacked(svg, '<path type="star" ; fill="#b2b9bc";  d="m 63.5,82.309523 -8.284327,-4.308591 -8.245826,4.381825 1.537715,-9.210291 -6.715463,-6.488189 9.234687,-1.383682 4.095442,-8.391746 4.169636,8.355129 9.246585,1.301804 -6.657711,6.547436 z" transform="translate(230 -40) scale(2)"/>'));
      svg = string(abi.encodePacked(svg, '<path style="fill:#b2b9bc"  d="m -3.2016949e-6,1159 c 2.1344633e-6,0 1.0672316e-6,0 0,0 z M 0.1268068,289.75 c -0.08453787,579.5 -0.04226893,289.75 0,0 z m 207.1905932,4.52111 34.8174,-25.34859 34.429,25.03754 c 18.936,13.77065 34.9931,25.15058 35.6826,25.28874 0.6895,0.13816 1.1307,-0.49554 0.9806,-1.40821 -0.1502,-0.91268 -6.1101,-19.57424 -13.2442,-41.47013 -10.1878,-31.26816 -12.7041,-40.05127 -11.727,-40.93175 0.6843,-0.61657 17.14983,-11.79288 35.7009,-26.02987 L 358.4134,184.5 314.0711,184 269.7287,183.5 256.4878,142.70675 c -4.72603,-13.49006 -10.17035,-29.31454 -14.43246,-42.32564 -0.265,0.26498 -6.90204,19.41565 -14.09254,41.61917 -7.1905,22.20352 -13.3003,40.73671 -13.5772,41.18488 C 214.1086,183.63332 194.3335,184 170.441,184 c -23.89257,0 -43.42888,0.3375 -43.41405,0.75 0.0148,0.4125 15.76483,12.1502 35.00005,26.08379 19.2351,13.93359 34.9725,25.63359 34.972,26 -6e-4,0.36642 -6.0752,19.34121 -13.499,42.16621 -7.4239,22.825 -13.4984,41.63906 -13.499,41.80902 0,0.58693 2.63612,-1.28915 37.3164,-26.53791 z" transform="translate(300,60) scale(0.2)"/>'));
    if (level>2) {
      // svg = string(abi.encodePacked(svg, '<path type="star" ; fill="#ffe449";  d="m 63.5,82.309523 -8.284327,-4.308591 -8.245826,4.381825 1.537715,-9.210291 -6.715463,-6.488189 9.234687,-1.383682 4.095442,-8.391746 4.169636,8.355129 9.246585,1.301804 -6.657711,6.547436 z" transform="translate(230 20) scale(2)"/>'));
      svg = string(abi.encodePacked(svg, '<path style="fill:#ffe449"  d="m -3.2016949e-6,1159 c 2.1344633e-6,0 1.0672316e-6,0 0,0 z M 0.1268068,289.75 c -0.08453787,579.5 -0.04226893,289.75 0,0 z m 207.1905932,4.52111 34.8174,-25.34859 34.429,25.03754 c 18.936,13.77065 34.9931,25.15058 35.6826,25.28874 0.6895,0.13816 1.1307,-0.49554 0.9806,-1.40821 -0.1502,-0.91268 -6.1101,-19.57424 -13.2442,-41.47013 -10.1878,-31.26816 -12.7041,-40.05127 -11.727,-40.93175 0.6843,-0.61657 17.14983,-11.79288 35.7009,-26.02987 L 358.4134,184.5 314.0711,184 269.7287,183.5 256.4878,142.70675 c -4.72603,-13.49006 -10.17035,-29.31454 -14.43246,-42.32564 -0.265,0.26498 -6.90204,19.41565 -14.09254,41.61917 -7.1905,22.20352 -13.3003,40.73671 -13.5772,41.18488 C 214.1086,183.63332 194.3335,184 170.441,184 c -23.89257,0 -43.42888,0.3375 -43.41405,0.75 0.0148,0.4125 15.76483,12.1502 35.00005,26.08379 19.2351,13.93359 34.9725,25.63359 34.972,26 -6e-4,0.36642 -6.0752,19.34121 -13.499,42.16621 -7.4239,22.825 -13.4984,41.63906 -13.499,41.80902 0,0.58693 2.63612,-1.28915 37.3164,-26.53791 z" transform="translate(300,120) scale(0.2)"/>'));
    }}}*/
    svg = string(abi.encodePacked(svg, '<text x="80" y="40" class="title">', name ,'</text>'));
    svg = string(abi.encodePacked(svg, '<text x="20" y="320" >Gameplay: ', Strings.toString(gameplay), 'min', '</text>'));
    svg = string(abi.encodePacked(svg, '<text x="20" y="340" >Games: ', Strings.toString(numberOfGames),'</text>'));
    svg = string(abi.encodePacked(svg, '<text x="20" y="360" >Goals: ', Strings.toString(goals), '</text>'));
    svg = string(abi.encodePacked(svg, '<text x="20" y="380" >Position: ', position, '</text>'));
    //svg = string(abi.encodePacked(svg, '<text x="20" y="80">NFT ID: ', tokenId.toString(), '</text>'));

    svg = string(abi.encodePacked(svg, '</svg>'));
  }





function addImage(string memory svg, string memory name, uint level) internal view returns (string memory _svg) {
  if (keccak256(abi.encodePacked("Noah Katterbach")) == keccak256(abi.encodePacked(name)) ) {
  //_svg = string(abi.encodePacked(svg, noahKatterbach.svg(level)));
     _svg = string(abi.encodePacked(svg, noahKatterbach.getSVG(level)));
}

if (keccak256(abi.encodePacked("Andy Pelmard")) == keccak256(abi.encodePacked(name)) ) {
  _svg = string(abi.encodePacked(svg, andyPelmard.getSVG(level)));
}

if (keccak256(abi.encodePacked("Pajtim Kasami")) == keccak256(abi.encodePacked(name)) ) {
  _svg = string(abi.encodePacked(svg, pajtimKasami.getSVG(level)));
}

if (keccak256(abi.encodePacked("Liam Millar")) == keccak256(abi.encodePacked(name)) ) {
  _svg = string(abi.encodePacked(svg, liamMillar.getSVG(level)));
}

if (keccak256(abi.encodePacked("Heinz Lindner")) == keccak256(abi.encodePacked(name)) ) {
  _svg = string(abi.encodePacked(svg, heinzLindner.getSVG(level)));
}

}











}
