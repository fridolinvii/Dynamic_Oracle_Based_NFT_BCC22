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

It is also possible to run the Program without Keeper and VRF. Keeper can be then be simulated and executed manually and the VRF will also be simulated and a random number is chosen (but it will not be a fair random number).

## How to set up the contacts with Remix ##
The parameters are set, so that it can be executed on the Rinkeby Network. If you plan to use the services of Chainlink, you can get free LINK here: https://faucets.chain.link/rinkeby


### Step 1
Deploy the contracts with the svg information of the football players from *players.sol*:
- NoahKatterbach
- AndyPelmard
- PajtimKasami
- LiamMillar
- HeinzLindner

### Step 2
Deploy the contract in *getPlayerSvg.sol*, where the player statistic is implemented in the svg. Add during the deployment all the contract address of the players from Step 1.
- getPlayerSvg

### Step 3
Deploy the contract in *SVG.sol* with the address from Step 2. This setups the ERC1155 Tokens. And the interaction with the svg information.
- SVG

### Step 4
Deploy the contract in *mintingProcess.sol* with the address from Step 3. If you want to use the VRF you need to add the subscriptionId (https://vrf.chain.link/). After deploying the contract register your contract on https://vrf.chain.link/.
- mintingProcess

### Step 5
Deploy the contract in *interface.sol* with the addresses of the contracts from Step 3 and Step 4. When you want to use VRF set `vrf=true` and if you want to use the Keeper use `keeper=true`. Currently only simulation of Oracle exists, therefore you should set `oracle=false`. In addition you can set after how man minutes the raffle should begin and after how many minutes the statistic of the player should be updated. It is currently set to minutes, to easily see the progress. However it can be changes in the constructor to days. After deploing the contract register this addres in https://keepers.chain.link/. To ensure, that the keeper is working, set the maximum Gasprice to its maximum (2'500'000).
- Interface

### Step 6
Give access to the contract, so they can comunicate with each other.
- *mintingProcess* run the function *changeInterfaceAddress("Interface address")*
- *SVG* run the function *changeMintingProcess("mintingProcess address", "Interface address")*

### Step 7
Now you can buy and upgrade NFTs until the raffle in *Interface*



## Brownie
For a better overview, where VRF and Keeper are deactivate you can checkout *interface.py* or run `brownie run interface` (https://eth-brownie.readthedocs.io/)
