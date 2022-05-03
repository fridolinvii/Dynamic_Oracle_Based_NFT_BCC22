//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

/**
 * Request testnet LINK and ETH here: https://faucets.chain.link/
 * Find information on LINK Token Contracts and get the latest ETH and LINK faucets here: https://docs.chain.link/docs/link-token-contracts/
 */

 /**
     * Network: Kovan
     * Link: 	0xa36085F69e2889c224210F603D836748e7dC0088
     * Oracle: 0xc57B33452b4F7BB189bB5AfaE9cc4aBa1f7a4FD8 (Chainlink Devrel   
     * Node)
     * Job ID: d5270d1c311941d0b08bead21fea7747
     * Fee: 0.1 LINK
*/


/**
 * @notice DO NOT USE THIS CODE IN PRODUCTION. This is an example contract.
 */
contract MultiWordConsumer is ChainlinkClient {
  using Chainlink for Chainlink.Request;

  // variable bytes returned in a signle oracle response
  bytes public data;

  // multiple params returned in a single oracle response
  uint256 public usd;
  uint256 public eur;
  uint256 public jpy;

  /**
   * @notice Initialize the link token and target oracle
   * @dev The oracle address must be an Operator contract for multiword response
   */
  // constructor(address link,address oracle) {
    bytes32 specId;
    uint256 payment;
    constructor() {
        address link = 0xa36085F69e2889c224210F603D836748e7dC0088;
        address oracle = 0xc57B33452b4F7BB189bB5AfaE9cc4aBa1f7a4FD8;
        specId = "d5270d1c311941d0b08bead21fea7747";
        payment = 0.1 * 10 ** 18; // (Varies by network and job)
                
        setChainlinkToken(link);
        setChainlinkOracle(oracle);
    }


  /*
   * @notice Request mutiple parameters from the oracle in a single transaction
   * @param specId bytes32 representation of the jobId in the Oracle
   * @param payment uint256 cost of request in LINK (JUELS)
   */
  function requestMultipleParameters() public {
    Chainlink.Request memory req = buildChainlinkRequest(specId, address(this), this.fulfillMultipleParameters.selector);
    req.addUint("times", 10000);
    sendChainlinkRequest(req, payment);
  }

  event RequestMultipleFulfilled(
    bytes32 indexed requestId,
    uint256 indexed usd,
    uint256 indexed eur,
    uint256 jpy
  );

  /**
   * @notice Fulfillment function for multiple parameters in a single request
   * @dev This is called by the oracle. recordChainlinkFulfillment must be used.
   */
  function fulfillMultipleParameters(
    bytes32 requestId,
    uint256 usdResponse,
    uint256 eurResponse,
    uint256 jpyResponse
  )
    public
    recordChainlinkFulfillment(requestId)
  {
    emit RequestMultipleFulfilled(requestId, usdResponse, eurResponse, jpyResponse);
    usd = usdResponse;
    eur = eurResponse;
    jpy = jpyResponse;
  }
}