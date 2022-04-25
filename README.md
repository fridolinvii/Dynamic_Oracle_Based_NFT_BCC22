# Dynamic Oracle Based NFT BCC22

#### Disclamer
This project is from the Blockchain Challenge 2022 #BCC22 in cooperation with Chainlink.
https://wwz.unibas.ch/de/dltfintech/blockchain-challenge/ . This contract is solely for private use.
If you have any questions, please contact one of the developer (#BCC22, Team 2 (Chainlink)).

We create dynamic football trading cards. Which dynamically updates the statistics of the player.
Having 3 of the same cards gives the option to upgrade the cards (up to 3 times).

The trading cards are randomly selected. To ensure a fair random selection, we use the VRF2 from Chainlink (https://vrf.chain.link/).
A keeper (https://keepers.chain.link/) automatically updates the statistic of the players.
After a given time, the Keeper activates the Raffel. This deactivates the possibility to buy new trading cards and upgrading these.

The raffle uses again VRF2 from Chainlink to ensure a fair random number. The raffle will give 3 Winners, which mints them a unique NFT.
In addition, owning the whole team will give you a unique NFT, and all owners of the NFTs will get unique NFTs with their scores from all the collected players (the higher the score, the higher the chance to win the raffle).
These unique NFTs, have dynamic metadata of the images, meaning the images changes between the football players.

We note: The statistic is currently simulated with random numbers. However, an Oracle or Datafeed from Chainlink can be set up to update the players (https://chain.link/data-feeds).

It is also possible to run the Program without Keeper and VRF. Keeper can then be simulated and executed manually. The VRF will also be simulated, and a random number is chosen (but it will not be a fair random number).

## How to set up the contacts with Remix ##
The parameters are set so that it can be executed on the Rinkeby Network. If you plan to use the services of Chainlink, you can get free LINK here: https://faucets.chain.link/rinkeby


### Step 1
Deploy the contracts with the svg information of the football players from *players.sol*:
- NoahKatterbach
- AndyPelmard
- PajtimKasami
- LiamMillar
- HeinzLindner

### Step 2
Deploy the contract in *getPlayerSvg.sol*, where the player statistic is implemented in the svg. Add during the deployment all the contract addresses of the players from Step 1.
- getPlayerSvg

### Step 3
Deploy the contract in *SVG.sol* with the address from Step 2. This setups the ERC1155 Tokens. And the interaction with the svg information.
- SVG

### Step 4
Deploy the contract in *mintingProcess.sol* with the address from Step 3. After deploying the contract register your contract on https://vrf.chain.link/. If you want to use the VRF you need to add the subscriptionId.
- mintingProcess

### Step 5
Deploy the contract in *interface.sol* with the addresses of the contracts from Step 3 and Step 4. When you want to use VRF set `vrf=true`, and if you want to use the Keeper, use `keeper=true`. Currently, only a simulation of Oracle exists. Therefore you should set `oracle=false`. In addition, you can set after how many minutes the raffle should begin and after how many minutes the player's statistic should be updated. It is currently set to minutes to see the progress easily. However, in the constructor, it can change to days after deploying the contract. Register this address in https://keepers.chain.link/. To ensure that the Keeper is working, set the maximum Gasprice to its maximum (2'500'000).
- Interface

### Step 6
Give access to the contract so that they can communicate with each other.
- *mintingProcess* run the function *changeInterfaceAddress("Interface address")*
- *SVG* run the function *changeMintingProcess("mintingProcess address", "Interface address")*

### Step 7
Now you can buy and upgrade NFTs until the raffle in *Interface*. You can also send 0.1-0.3 ETH to the contract address to get the trading cards.



## Brownie
For a better overview of where VRF and Keeper are deactivated, you can checkout *interface.py* or run `brownie run interface` (https://eth-brownie.readthedocs.io/)
