# Dynamic Oracle Based NFT BCC22
![trading cards](https://github.com/fridolinvii/Dynamic_Oracle_Based_NFT_BCC22/blob/main/docs/tradingcards.png)

#### Disclamer
This project is from the Blockchain Challenge 2022 #BCC22 in cooperation with Chainlink.
https://wwz.unibas.ch/de/dltfintech/blockchain-challenge . These contracts are solely for private use.
If you have any questions, please contact one of the developers (#BCC22, Team Chainlink).

We create dynamic football trading cards. Which dynamically updates the statistics of the player.
Having 3 of the same cards gives the option to upgrade the cards (up to 3 times).

The trading cards are randomly selected. To ensure a fair random selection, we use the VRF from Chainlink (https://vrf.chain.link/).
A keeper (https://keepers.chain.link/) automatically updates the statistic of the players.
After a given time, the Keeper activates the raffle. This deactivates the possibility of buying new trading cards and upgrading these.

The raffle uses again VRF from Chainlink to ensure a fair random number. The raffle will select 3 Winners, which mints them a unique NFT.
In addition, owning the whole team will give you a unique NFT, and all owners of the NFTs will get unique NFTs with their scores from all the collected players (the higher the score, the higher the chance to win the raffle).
These unique NFTs, have dynamic metadata of the images, meaning the images changes between the football players.

We note: The statistic is currently simulated with random numbers. However, an Oracle or Datafeed from Chainlink can be set up to update the players (https://chain.link/data-feeds).

It is also possible to run the Program without Keeper and VRF. Keeper can then be simulated and executed manually. The VRF will also be simulated, and a random number is chosen (but it will not be a fair random number).

## How to set up the contacts with Remix ##
The parameters are set so that they can be executed on the Rinkeby Network. If you plan to use the services of Chainlink, you can get free LINK here: https://faucets.chain.link/rinkeby
* Note: Rinkeby Network is down. You will need to find an alternative.

### Step 1
Deploy the contracts with the SVG information of the football players from *players.sol*:
- Player0
- Player1
- Player2
- Player3
- Player4

### Step 2
Deploy the contract in *getPlayerSvg.sol*, where the player statistic is implemented in the SVG. Add during the deployment all the contract addresses of the players from Step 1.
- getPlayerSvg

### Step 3
Deploy the contract in *createNFT.sol* with the address from Step 2. This sets up the ERC1155 tokens. And the interaction with the SVG information.
- createNFT

### Step 4
Deploy the contract in *mintingProcess.sol* with the address from Step 3. After deploying the contract register your contract on https://vrf.chain.link/. If you want to use the VRF, you need to add the subscription.
- mintingProcess

### Step 5
Deploy the contract in *interface.sol* with the addresses of the contracts from Step 3 and Step 4. When you want to use VRF, set `vrf=true`, and if you're going to use the Keeper, use `keeper=true`. Register this address in https://keepers.chain.link/. Currently, only a simulation of Oracle exists. Therefore you should set `oracle=false`. In addition, you can set after how many minutes the raffle should begin and after how many minutes the player's statistic should be updated. It is currently set to minutes to see the progress easily. To ensure that the Keeper is working, a high enough Gaslimit should be set, e.g., 1'000'000 GAS.
- Interface

### Step 6
Give access to the contract so that they can communicate with each other.
- *mintingProcess* run the function *changeInterfaceAddress("Interface address")*
- *createNFT* run the function *changeMintingProcess("mintingProcess address", "Interface address")*

### Step 7
Now you can buy and upgrade NFTs until the raffle in *Interface*. You can also send 0.1-0.3 ETH to the contract address from *Interface* to get the trading cards. To upgrade the trading cards, send 0 ETH to the contract address.



## Brownie
For a better overview of where VRF and Keeper are deactivated, you can checkout *interface.py* or run `brownie run interface` (https://eth-brownie.readthedocs.io/)

#### Special Thanks
We used https://github.com/matnad/SVG-MVP for the infrastructure to save the NFTs on-chain and https://github.com/fridolinvii/mystery_game to communicate between the smart contracts.
