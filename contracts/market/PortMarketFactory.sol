// SPDX-License-Identifier: MIT
// Metaline Contracts (PortMarketFactory.sol)

pragma solidity ^0.8.0;

import "./PortMarket.sol";
import "./PortMarketProxy.sol";

contract PortMarketFactory {

    event PortMarketCreated(uint16 indexed portid, address indexed portMarketAddr);

    address public owner;
    address public portMarketPairImpl;
    address public portMarketImpl;

    mapping(uint16=>address) public portMarkets;
    
    constructor(
        address pmp,
        address pm
    ) {
        owner = msg.sender;
        portMarketPairImpl = pmp;
        portMarketImpl = pm;
    }
    
    function changeOwner(address newOwner) external {
        require(msg.sender == owner, 'PortMarket: FORBIDDEN');
        owner = newOwner;
    }

    function createPortMarket(
        uint16 portid
    ) external returns(address pmAddr) {
        require(msg.sender == owner, 'PortMarket: FORBIDDEN');

        bytes32 salt = keccak256(abi.encodePacked(portid));
        pmAddr = address(
            new PortMarketProxy{salt: salt}(
                portMarketImpl
            )
        );

        PortMarket(pmAddr).initPortMarket(portid, portMarketPairImpl);
        
        PortMarket(pmAddr).setFeeTo(owner);
        PortMarket(pmAddr).changeOwner(owner);

        portMarkets[portid] = pmAddr;

        emit PortMarketCreated(portid, pmAddr);
    }
}