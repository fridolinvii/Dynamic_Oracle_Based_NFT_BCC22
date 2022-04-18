# Dynamic Oracle Based NFT BCC22

This project is from the Blockchain Challange 2022 #BCC22 in cooperation with Chainlink.
https://wwz.unibas.ch/de/dltfintech/blockchain-challenge/

We create a dynamic football trading cards. Which dynamically update the statistik of the player. 
Having 3 of the same cards, gives the option to upgrade the cards (up to 3 times). 

The trading cards are randomoly selected. To ensure a fair random selection, we use the VRF2 from Chainlink (https://vrf.chain.link/). 
A keeper (https://keepers.chain.link/) automatically updates the statisktik of the players. 
After a given time, the keeper aktivates the Raffel. This deactivates the possibilites to buy new trading cards and to upgrade these. 

The raffle uses again VRF2 from Chainlink to ensure a fair random number. The raffle will give 3 Winners, which gives all of them a unique NFT. 
In addition owning the whole team will give you a unique NFT, and all owner of the NFTs will get a unique NFTs with there score from all the collected players (the higher the score, the higher the chance to win the raffle). 
These unique NFTs, have a dynamic metadata of the images, meaning, the images changes between the football players. 

We note: The statisc is currently simulated with random numbers. However, an Oracle or Datafeed from Chainlink can be set up to update the players (https://chain.link/data-feeds).

## How to set up the contacts with Remix ## 

