// SPDX-License-Identifier: MIT
// Mateline Contracts (MysteryBoxShop.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";

import "./MysteryBox1155.sol";

contract MysteryBoxShop is 
    Context, 
    Pausable, 
    AccessControl
{
    struct OnSaleMysterBox{
        // config data --------------------------------------------------------
        address mysteryBox1155Addr; // mystery box address
        uint256 mbTokenId; // mystery box token id

        address tokenAddr; // charge token addr, could be 20 or 1155
        uint256 tokenId; // =0 means 20 token, else 1155 token
        uint256 price; // price value

        bool isBurn; // = ture means charge token will be burned, else charge token save in this contract

        uint256 beginBlock; // start sale block, =0 ignore this condition
        uint256 endBlock; // end sale block, =0 ignore this condition

        uint256 renewBlocks; // how many blocks for each renew
        uint256 renewCount; // how many count put on sale for each renew

        uint32 whitelistId; // = 0 means open sale, else will check if buyer address in white list
        address nftholderCheck; // = address(0) won't check, else will check if buyer hold some other nft

        uint32 perAddrLimit; // = 0 means no limit, else means each user address max buying count
    }

    struct OnSaleMysterBoxRunTime {
        // runtime data -------------------------------------------------------
        uint256 nextRenewBlock; // after this block num, will put at max [renewCount] on sale

        // config & runtime data ----------------------------------------------
        uint256 countLeft; // how many boxies left
    }

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    event DIOnSaleMysterBox(string pairName, OnSaleMysterBox saleConfig, OnSaleMysterBoxRunTime saleData);
    event DIOffSaleMysterBox(string pairName, OnSaleMysterBox saleConfig, OnSaleMysterBoxRunTime saleData);
    event DIBuyMysteryBox(address userAddr, string pairName, OnSaleMysterBox saleConfig, OnSaleMysterBoxRunTime saleData);
    event DIBatchBuyMysteryBox(address userAddr, string pairName, OnSaleMysterBox saleConfig, OnSaleMysterBoxRunTime saleData, uint256 count);

    mapping(string=>OnSaleMysterBox) public _onSaleMysterBoxes;
    mapping(string=>OnSaleMysterBoxRunTime) public _onSaleMysterBoxDatas;
    mapping(string=>mapping(address=>uint32)) public _perAddrBuyCount;
    address public _receiveIncomAddress;

    mapping(uint32=>mapping(address=>bool)) public _whitelists;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
    }

    function pause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "P1");
        _pause();
    }
    function unpause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "P2");
        _unpause();
    }

    function addWitheList(uint32 wlId, address[] memory whitelist) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "MysteryBoxShop: must have manager role to manage");

        mapping(address=>bool) storage wl = _whitelists[wlId];

        for(uint i=0; i< whitelist.length; ++i){
            wl[whitelist[i]] = true;
        }
    }

    function removeWhiteList(uint32 wlId, address[] memory whitelist) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "MysteryBoxShop: must have manager role to manage");

        mapping(address=>bool) storage wl = _whitelists[wlId];

        for(uint i=0; i< whitelist.length; ++i){
            delete wl[whitelist[i]];
        }
    }

    function setOnSaleMysteryBox(string calldata pairName, OnSaleMysterBox memory saleConfig, OnSaleMysterBoxRunTime memory saleData) external whenNotPaused {
        require(hasRole(MANAGER_ROLE, _msgSender()), "MysteryBoxShop: must have manager role to manage");

        if(saleConfig.renewBlocks > 0)
        {
            saleData.nextRenewBlock = block.number + saleConfig.renewBlocks;
        }

        _onSaleMysterBoxes[pairName] = saleConfig;
        _onSaleMysterBoxDatas[pairName] = saleData;

        emit DIOnSaleMysterBox(pairName, saleConfig, saleData);
    }

    function unsetOnSaleMysteryBox(string calldata pairName) external whenNotPaused {
        require(hasRole(MANAGER_ROLE, _msgSender()), "MysteryBoxShop: must have manager role to manage");

        OnSaleMysterBox storage onSalePair = _onSaleMysterBoxes[pairName];
        OnSaleMysterBoxRunTime storage onSalePairData = _onSaleMysterBoxDatas[pairName];

        emit DIOffSaleMysterBox(pairName, onSalePair, onSalePairData);

        delete _onSaleMysterBoxes[pairName];
        delete _onSaleMysterBoxDatas[pairName];
    }

    function setOnSaleMBCheckCondition(string calldata pairName, uint32 whitelistId, address nftholderCheck) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "MysteryBoxShop: must have manager role to manage");

        OnSaleMysterBox storage onSalePair = _onSaleMysterBoxes[pairName];

        onSalePair.whitelistId = whitelistId;
        onSalePair.nftholderCheck = nftholderCheck;
    }

    function setOnSaleMBCountleft(string calldata pairName, uint countLeft) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "MysteryBoxShop: must have manager role to manage");

        OnSaleMysterBoxRunTime storage onSalePairData = _onSaleMysterBoxDatas[pairName];

        onSalePairData.countLeft = countLeft;
    }

    function setReceiveIncomeAddress(address incomAddr) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "MysteryBoxShop: must have manager role to manage");

        _receiveIncomAddress = incomAddr;
    }

    function _checkSellCondition(OnSaleMysterBox storage onSalePair, OnSaleMysterBoxRunTime storage onSalePairData) internal {
        if(onSalePair.beginBlock > 0)
        {
            require(block.number >= onSalePair.beginBlock, "MysteryBoxShop: sale not begin");
        }
        if(onSalePair.endBlock > 0)
        {
            require(block.number <= onSalePair.endBlock, "MysteryBoxShop: sale finished");
        }
        if(onSalePair.whitelistId > 0)
        {
            require(_whitelists[onSalePair.whitelistId][_msgSender()], "MysteryBoxShop: not in whitelist");
        }
        if(onSalePair.nftholderCheck != address(0))
        {
            require(IERC721(onSalePair.nftholderCheck).balanceOf(_msgSender()) > 0, "MysteryBoxShop: no authority");
        }

        if(onSalePair.renewBlocks > 0)
        {
            if(block.number > onSalePairData.nextRenewBlock)
            {
                onSalePairData.nextRenewBlock = onSalePairData.nextRenewBlock + onSalePair.renewBlocks * (1 + ((block.number - onSalePairData.nextRenewBlock) / onSalePair.renewBlocks));
                onSalePairData.countLeft = onSalePair.renewCount;
            }
        }
    }

    function _chargeByDesiredCount(
        string calldata pairName, OnSaleMysterBox storage onSalePair, OnSaleMysterBoxRunTime storage onSalePairData, uint256 count) 
        internal returns (uint256 realCount)
    {

        realCount = count;
        if(realCount > onSalePairData.countLeft)
        {
            realCount = onSalePairData.countLeft;
        }

        if(onSalePair.perAddrLimit > 0)
        {
            uint32 buyCount = _perAddrBuyCount[pairName][_msgSender()];
            uint32 buyCountLeft = (onSalePair.perAddrLimit > buyCount)? (onSalePair.perAddrLimit - buyCount) : 0;
            if(buyCountLeft < realCount){
                realCount = buyCountLeft;
            }

            if(realCount > 0){
                _perAddrBuyCount[pairName][_msgSender()] += uint32(realCount);
            }
        }

        require(realCount > 0, "MysteryBoxShop: insufficient mystery box");

        onSalePairData.countLeft -= realCount;

        if(onSalePair.price > 0){
            uint256 realPrice = onSalePair.price * realCount;

            if(onSalePair.tokenId > 0)
            {
                // 1155
                require(IERC1155(onSalePair.tokenAddr).balanceOf( _msgSender(), onSalePair.tokenId) >= realPrice , "MysteryBoxShop: erc1155 insufficient token");

                if(onSalePair.isBurn) {
                    // burn
                    ERC1155Burnable(onSalePair.tokenAddr).burn(_msgSender(), onSalePair.tokenId, realPrice);
                }
                else {
                    // charge
                    IERC1155(onSalePair.tokenAddr).safeTransferFrom(_msgSender(), address(this), onSalePair.tokenId, realPrice, "buy mb");
                }
            }
            else{
                // 20
                require(IERC20(onSalePair.tokenAddr).balanceOf(_msgSender()) >= realPrice , "MysteryBoxShop: erc20 insufficient token");

                if(onSalePair.isBurn) {
                    // burn
                    ERC20Burnable(onSalePair.tokenAddr).burnFrom(_msgSender(), realPrice);
                }
                else {
                    // charge
                    TransferHelper.safeTransferFrom(onSalePair.tokenAddr, _msgSender(), address(this), realPrice);
                }
            }
        }

    }

    function buyMysteryBox(string calldata pairName) external whenNotPaused {
        OnSaleMysterBox storage onSalePair = _onSaleMysterBoxes[pairName];
        OnSaleMysterBoxRunTime storage onSalePairData = _onSaleMysterBoxDatas[pairName];
        require(address(onSalePair.mysteryBox1155Addr) != address(0), "MysteryBoxShop: mystery box not on sale");

        _checkSellCondition(onSalePair, onSalePairData);

        _chargeByDesiredCount(pairName, onSalePair, onSalePairData, 1);

        MysteryBox1155(onSalePair.mysteryBox1155Addr).mint(_msgSender(), onSalePair.mbTokenId, 1, "buy mb");

        emit DIBuyMysteryBox(_msgSender(), pairName, onSalePair, onSalePairData);
    }

    function batchBuyMysterBox(string calldata pairName, uint32 count) external whenNotPaused {

        OnSaleMysterBox storage onSalePair = _onSaleMysterBoxes[pairName];
        OnSaleMysterBoxRunTime storage onSalePairData = _onSaleMysterBoxDatas[pairName];
        require(address(onSalePair.mysteryBox1155Addr) != address(0), "MysteryBoxShop: mystery box not on sale");

        _checkSellCondition(onSalePair, onSalePairData);

        uint256 realCount = _chargeByDesiredCount(pairName, onSalePair, onSalePairData, count);

        MysteryBox1155(onSalePair.mysteryBox1155Addr).mint(_msgSender(), onSalePair.mbTokenId, realCount, "buy mb");

        emit DIBatchBuyMysteryBox(_msgSender(), pairName, onSalePair, onSalePairData, realCount);
    }

    function fetchIncome(address tokenAddr, uint256 value) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "MysteryBoxShop: must have manager role to manage");
        IERC20 token = IERC20(tokenAddr);

        if(value <= 0){
            value = token.balanceOf(address(this));
        }

        require(value > 0, "MysteryBoxShop: zero value");

        TransferHelper.safeTransfer(tokenAddr, _receiveIncomAddress, value);
    }

    function fetchIncome1155(address tokenAddr, uint256 tokenId, uint256 value) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "MysteryBoxShop: must have manager role to manage");
        IERC1155 token = IERC1155(tokenAddr);

        if(value <= 0){
            value = token.balanceOf(address(this), tokenId);
        }

        require(value > 0, "MysteryBoxShop: zero value");

        token.safeTransferFrom(address(this), _receiveIncomAddress, tokenId, value, "fetch income");
    }
}