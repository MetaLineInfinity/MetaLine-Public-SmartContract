// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import "./OracleCharger.sol";

contract TokenPrices is 
    Context,
    AccessControl,
    TokenPriceOracle 
{
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    mapping(address=>AggregatorV3Interface) _chainLinkFeeds;
    mapping(address=>address) _defiPools;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MANAGER_ROLE, _msgSender());
    }

    /**
     * (ETH)Arbitrum Goerli Testnet : 0x62CAe0FA2da220f43a51F86Db2EDb36DcA9A5A08
     * (ETH)Arbitrum One : 0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612
     */
    function setChainLinkTokenPriceSource(address tokenAddr, address feedAddr) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "MTTMinePool: must have manager role");

        _chainLinkFeeds[tokenAddr] = AggregatorV3Interface(feedAddr);
    }
    
    function setDefiPoolSource(address tokenAddr, address defiPoolSource) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "MTTMinePool: must have manager role");

        _defiPools[tokenAddr] = defiPoolSource;
    }

    /**
     * Returns the latest price.
     */
    function getERC20TokenUSDPrice(address tokenAddr) public override view returns (uint256) {

        if(address(_chainLinkFeeds[tokenAddr]) != address(0)){

            // prettier-ignore
            (
                /* uint80 roundID */,
                int price,
                /*uint startedAt*/,
                /*uint timeStamp*/,
                /*uint80 answeredInRound*/
            ) = _chainLinkFeeds[tokenAddr].latestRoundData();
            require(price > 0, "price error");

            return uint256(price);
        }

        if(_defiPools[tokenAddr] != address(0)){

            // TO DO : get price from defi pool

            // for Debug ...
            return 9000000; // 0.09 u
        }

        revert("token price source not set");
    }
}