// SPDX-License-Identifier: MIT
// Metaline Contracts (GuildPackTicket1155.sol)

pragma solidity ^0.8.0;

import "../core/Extendable1155.sol";

// 1155 id : combine with randomType(uint32) << 32 | mysteryType(uint32)
contract GuildPackTicket1155 is Extendable1155 {

    constructor(string memory uri) Extendable1155("MetaLine Guild Package Ticket Semi-fungible Token", "MLGPT", uri) {
        mint(_msgSender(), 0, 1, new bytes(0)); // mint first token to notify event scan
    }
}