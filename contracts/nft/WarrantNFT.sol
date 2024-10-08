// SPDX-License-Identifier: MIT
// Metaline Contracts (WarrantNFT.sol)

pragma solidity ^0.8.0;

import "../utility/ResetableCounters.sol";
import "../core/ExtendableNFT.sol";

struct WarrantNFTData {
    uint32 createTm;
    uint16 portID;
    uint16 storehouseLv;
    uint16 factoryLv;
    uint16 shopLv;
    uint16 shipyardLv;
}

/**
 * @dev Extension of {ExtendableNFT} that with fixed token data struct
 */
contract WarrantNFT is ExtendableNFT {
    using ResetableCounters for ResetableCounters.Counter;

    /**
    * @dev emit when new token has been minted, see {WarrantNFTData}
    *
    * @param to owner of new token
    * @param tokenId new token id
    * @param data token data see {WarrantNFTData}
    */
    event WarrantNFTMint(address indexed to, uint256 indexed tokenId, WarrantNFTData data);
    
    /**
    * @dev emit when token data modified
    *
    * @param tokenId token id
    * @param data token data see {WarrantNFTData}
    */
    event WarrantNFTModified(uint256 indexed tokenId, WarrantNFTData data);

    ResetableCounters.Counter internal _tokenIdTracker;
    
    mapping(uint256 => WarrantNFTData) private _nftDatas; // token id => nft data stucture

    constructor(
        uint256 idStart,
        string memory name,
        string memory symbol,
        string memory baseTokenURI) 
        ExtendableNFT(name, symbol, baseTokenURI)
    {
       _tokenIdTracker.reset(idStart);

       _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
       _setupRole(DATA_ROLE, _msgSender());
    }

    /**
     * @dev Creates a new token for `to`, emit {WarrantNFTMint}. Its token ID will be automatically
     * assigned (and available on the emitted {IERC721-Transfer} event), and the token
     * URI autogenerated based on the base URI passed at construction.
     *
     * See {ERC721-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     *
     * @param to new token owner address
     * @param data token data see {WarrantNFTData}
     * @return new token id
     */
    function mint(address to, WarrantNFTData memory data) public returns(uint256) {
        require(hasRole(MINTER_ROLE, _msgSender()), "R1");

        // We cannot just use balanceOf to create the new tokenId because tokens
        // can be burned (destroyed), so we need a separate counter.
        uint256 curID = _tokenIdTracker.current();

        _mint(to, curID);

        // Save token datas
        _nftDatas[curID] = data;

        emit WarrantNFTMint(to, curID, data);

        // increase token id
        _tokenIdTracker.increment();

        return curID;
    }

    /**
     * @dev Creates a new token for `to`, emit {WarrantNFTMint}. Its token ID give by caller
     * (and available on the emitted {IERC721-Transfer} event), and the token
     * URI autogenerated based on the base URI passed at construction.
     *
     * See {ERC721-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     *
     * @param id new token id
     * @param to new token owner address
     * @param data token data see {WarrantNFTData}
     * @return new token id
     */
    function mintFixedID(
        uint256 id,
        address to,
        WarrantNFTData memory data
    ) public returns (uint256) {
        require(hasRole(MINTER_ROLE, _msgSender()), "R1");

        require(!_exists(id), "RE");

        _mint(to, id);

        // Save token datas
        _nftDatas[id] = data;

        emit WarrantNFTMint(to, id, data);

        return id;
    }

    /**
     * @dev modify token data
     *
     * @param tokenId token id
     * @param data token data see {WarrantNFTData}
     */
    function modNftData(uint256 tokenId, WarrantNFTData memory data) external {
        require(hasRole(DATA_ROLE, _msgSender()), "R1");

        WarrantNFTData storage wdata = _nftDatas[tokenId];
        if(wdata.storehouseLv != data.storehouseLv) {
            wdata.storehouseLv = data.storehouseLv;
        }
        if(wdata.factoryLv != data.factoryLv){
            wdata.factoryLv = data.factoryLv;
        }
        if(wdata.shopLv != data.shopLv){
            wdata.shopLv = data.shopLv;
        }
        if(wdata.shipyardLv != data.shipyardLv){
            wdata.shipyardLv = data.shipyardLv;
        }

        emit WarrantNFTModified(tokenId, wdata);
    }

    /**
     * @dev get token data
     *
     * @param tokenId token id
     * @param data token data see {WarrantNFTData}
     */
    function getNftData(uint256 tokenId) external view returns(WarrantNFTData memory data){
        require(_exists(tokenId), "T1");

        data = _nftDatas[tokenId];
    }

}