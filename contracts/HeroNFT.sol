// SPDX-License-Identifier: MIT
// Mateline Contracts (HeroNFT.sol)

pragma solidity ^0.8.0;

import "./utility/ResetableCounters.sol";

import "./core/ExtendableNFT.sol";
import "./HeroNFTCodec.sol";

/**
 * @dev Extension of {ExtendableNFT} that with fixed token data struct
 */
contract HeroNFT is ExtendableNFT {
    using ResetableCounters for ResetableCounters.Counter;

    /**
    * @dev emit when new token has been minted, see {HeroNFTDataBase}
    *
    * @param to owner of new token
    * @param tokenId new token id
    * @param data token data see {HeroNFTDataBase}
    */
    event HeroNFTMint(address indexed to, uint256 indexed tokenId, HeroNFTDataBase data);

    ResetableCounters.Counter internal _tokenIdTracker;

    address public _codec;
    address public _attrSource;
    
    mapping(uint256 => HeroNFTDataBase) private _nftDatas; // token id => nft data stucture

    constructor(
        uint256 idStart,
        string memory name,
        string memory symbol,
        string memory baseTokenURI) 
        ExtendableNFT(name, symbol, baseTokenURI)
    {
       _tokenIdTracker.reset(idStart);

        mint(_msgSender(), HeroNFTDataBase({
            fixedData:0,
            writeableData:0
        })); // mint first token to notify event scan
        
       _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
       _setupRole(DATA_ROLE, _msgSender());
    }

    function setAttrSource(address a) external {
        require(
            hasRole(DATA_ROLE, _msgSender()),
            "R1"
        );

        _attrSource = a;
    }
    function getAttrSource() external view returns(address a) {
        return _attrSource;
    }

    function setCodec(address c) external {
        require(
            hasRole(DATA_ROLE, _msgSender()),
            "R1"
        );

        _codec = c;
    }
    function getCodec() external view returns(address c) {
        return _codec;
    }

    /**
     * @dev Creates a new token for `to`, emit {HeroNFTMint}. Its token ID will be automatically
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
     * @param data token data see {HeroNFTDataBase}
     * @return new token id
     */
    function mint(address to, HeroNFTDataBase memory data) public returns(uint256) {
        require(hasRole(MINTER_ROLE, _msgSender()), "R1");

        // We cannot just use balanceOf to create the new tokenId because tokens
        // can be burned (destroyed), so we need a separate counter.
        uint256 curID = _tokenIdTracker.current();

        _mint(to, curID);

        // Save token datas
        _nftDatas[curID] = data;

        emit HeroNFTMint(to, curID, data);

        // increase token id
        _tokenIdTracker.increment();

        return curID;
    }

    /**
     * @dev Creates a new token for `to`, emit {HeroNFTMint}. Its token ID give by caller
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
     * @param data token data see {HeroNFTDataBase}
     * @return new token id
     */
    function mintFixedID(
        uint256 id,
        address to,
        HeroNFTDataBase memory data
    ) public returns (uint256) {
        require(hasRole(MINTER_ROLE, _msgSender()), "R1");

        require(!_exists(id), "RE");

        _mint(to, id);

        // Save token datas
        _nftDatas[id] = data;

        emit HeroNFTMint(to, id, data);

        return id;
    }

    /**
     * @dev modify token data
     *
     * @param tokenId token id
     * @param writeableData token data see {HeroNFTDataBase}
     */
    function modNftData(uint256 tokenId, uint256 writeableData) external {
        require(hasRole(DATA_ROLE, _msgSender()), "R1");

        _nftDatas[tokenId].writeableData = writeableData;
    }

    /**
     * @dev get token data
     *
     * @param tokenId token id
     * @param data token data see {HeroNFTDataBase}
     */
    function getNftData(uint256 tokenId) external view returns(HeroNFTDataBase memory data){
        require(_exists(tokenId), "T1");

        data = _nftDatas[tokenId];
    }

}