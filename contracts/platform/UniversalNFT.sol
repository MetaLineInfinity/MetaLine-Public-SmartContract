// SPDX-License-Identifier: MIT
// Metaline Contracts (UniversalNFT.sol)

pragma solidity ^0.8.0;

import "../utility/ResetableCounters.sol";
import "../core/ExtendableNFT.sol";

import "../interface/platform/IUniversalNFT.sol";

/**
 * @dev Extension of {ExtendableNFT} that with fixed token data struct
 */
contract UniversalNFT is ExtendableNFT, IUniversalNFT {
    using ResetableCounters for ResetableCounters.Counter;

    ResetableCounters.Counter internal _tokenIdTracker;

    address public _codec;
    address public _attrSource;
    
    mapping(uint256 => UniversalNFTData) private _nftDatas; // token id => nft data stucture

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
     * @dev Creates a new token for `to`, emit {UniversalNFTMint}. Its token ID will be automatically
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
     * @param data token data see {UniversalNFTData}
     * @return new token id
     */
    function mint(address to, UniversalNFTData memory data) public returns(uint256) {
        require(hasRole(MINTER_ROLE, _msgSender()), "R1");

        // We cannot just use balanceOf to create the new tokenId because tokens
        // can be burned (destroyed), so we need a separate counter.
        uint256 curID = _tokenIdTracker.current();

        _mint(to, curID);

        // Save token datas
        UniversalNFTData storage storedata = _nftDatas[curID];
        storedata.appid = data.appid;
        for(uint i=0; i< data.fixdata.length; ++i){
            storedata.fixdata.push(data.fixdata[i]);
        }
        for(uint i=0; i< data.nftdata.length; ++i){
            storedata.nftdata.push(data.nftdata[i]);
        }

        emit UniversalNFTMint(to, curID, data);

        // increase token id
        _tokenIdTracker.increment();

        return curID;
    }

    /**
     * @dev Creates a new token for `to`, emit {UniversalNFTMint}. Its token ID give by caller
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
     * @param data token data see {UniversalNFTData}
     * @return new token id
     */
    function mintFixedID(
        uint256 id,
        address to,
        UniversalNFTData memory data
    ) public returns (uint256) {
        require(hasRole(MINTER_ROLE, _msgSender()), "R1");

        require(!_exists(id), "RE");

        _mint(to, id);

        // Save token datas
        UniversalNFTData storage storedata = _nftDatas[id];
        storedata.appid = data.appid;
        for(uint i=0; i< data.fixdata.length; ++i){
            storedata.fixdata.push(data.fixdata[i]);
        }
        for(uint i=0; i< data.nftdata.length; ++i){
            storedata.nftdata.push(data.nftdata[i]);
        }

        emit UniversalNFTMint(to, id, data);

        return id;
    }

    /**
     * @dev modify token data
     *
     * @param tokenId token id
     * @param nftdata token data
     */
    function modNftData(uint256 tokenId, uint256[] memory nftdata) external {
        require(hasRole(DATA_ROLE, _msgSender()), "R1");

        UniversalNFTData storage storedata = _nftDatas[tokenId];
        for(uint i=0; i< nftdata.length; ++i){
            if(i>=storedata.nftdata.length){
                storedata.nftdata.push(nftdata[i]);
            }
            else {
                storedata.nftdata[i] = nftdata[i];
            }
        }

        emit UniversalNFTModified(tokenId, nftdata);
    }
    
    /**
     * @dev modify token data
     *
     * @param tokenId token id
     * @param index token data index
     * @param nftdata token data
     */
    function modSingleNftData(uint256 tokenId, uint32 index, uint256 nftdata) external {
        require(hasRole(DATA_ROLE, _msgSender()), "R1");

        UniversalNFTData storage storedata = _nftDatas[tokenId];
        require(index < storedata.nftdata.length, "R2");

        storedata.nftdata[index] = nftdata;

        emit UniversalNFTSingleModified(tokenId, index, nftdata);
    }

    /**
     * @dev get token data
     *
     * @param tokenId token id
     * @param data token data see {UniversalNFTData}
     */
    function getNftData(uint256 tokenId) external view returns(UniversalNFTData memory data){
        require(_exists(tokenId), "T1");

        data = _nftDatas[tokenId];
    }

}