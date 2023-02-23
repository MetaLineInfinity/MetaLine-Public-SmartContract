// SPDX-License-Identifier: MIT
// Mateline Contracts (MysteryBoxShopV1.sol)

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

contract MysteryBoxShopV1 is 
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

        //bool isBurn; // = ture means charge token will be burned, else charge token save in this contract

        uint64 beginTime; // start sale timeStamp in seconds since unix epoch, =0 ignore this condition
        uint64 endTime; // end sale timeStamp in seconds since unix epoch, =0 ignore this condition

        uint64 renewTime; // how long in seconds for each renew
        uint256 renewCount; // how many count put on sale for each renew

        uint32 whitelistId; // = 0 means open sale, else will check if buyer address in white list
        address nftholderCheck; // = address(0) won't check, else will check if buyer hold some other nft

        uint32 perAddrLimit; // = 0 means no limit, else means each user address max buying count

        uint32 discountId; // = 0 means not discount, else will give discout to buyer which in discount address list
    }

    struct OnSaleMysterBoxRunTime {
        // runtime data -------------------------------------------------------
        uint64 nextRenewTime; // after this timeStamp in seconds since unix epoch, will put at max [renewCount] on sale

        // config & runtime data ----------------------------------------------
        uint256 countLeft; // how many boxies left
    }

    struct DiscountAddress {
        uint16 discount; // discountPrice = price * discount / 10000;
        uint32 maxCount; // must > 0, max buyin discount mb allowed

        mapping(address=>bool) addrmap; // is in discount address list
    }

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant OPERATER_ROLE = keccak256("OPERATER_ROLE");

    event SetOnSaleMysterBox(string indexed pairName, OnSaleMysterBox saleConfig, OnSaleMysterBoxRunTime saleData);
    event UnsetOnSaleMysterBox(string indexed pairName, OnSaleMysterBox saleConfig, OnSaleMysterBoxRunTime saleData);
    event SetOnSaleMBCheckCondition(
        string indexed pairName, 
        uint256 price, 
        uint32 whitelistId, 
        address nftholderCheck, 
        uint32 perAddrLimit,
        uint32 discountId);
    event SetOnSaleMBCountleft(string indexed pairName, uint countLeft);
    event PerAddrBuyCountChange(string indexed pairName, address indexed userAddr, uint32 count);
    event BuyMysteryBox(address indexed userAddr, string indexed pairName, OnSaleMysterBox saleConfig, OnSaleMysterBoxRunTime saleData);
    event BatchBuyMysteryBox(address indexed userAddr, string indexed pairName, OnSaleMysterBox saleConfig, OnSaleMysterBoxRunTime saleData, uint256 count);
    event PerAddrDiscountCountChange(uint32 discountId, address indexed userAddr, uint32 count);

    mapping(string=>OnSaleMysterBox) public _onSaleMysterBoxes;
    mapping(string=>OnSaleMysterBoxRunTime) public _onSaleMysterBoxDatas;
    mapping(string=>mapping(address=>uint32)) public _perAddrBuyCount;
    address public _receiveIncomAddress;

    mapping(uint32=>mapping(address=>bool)) public _whitelists;
    mapping(uint32=>DiscountAddress) public _discountAddress;
    mapping(uint32=>mapping(address=>uint32)) public _discountBuyCount;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
        _setupRole(OPERATER_ROLE, _msgSender());
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
    
    function addDiscountAddress(uint32 daId, uint16 discount, uint32 maxCount, address[] memory discountAddrList) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "MysteryBoxShop: must have manager role to manage");
        require(discount<10000, "MysteryBoxShop: discount overflow");

        DiscountAddress storage da = _discountAddress[daId];
        da.discount = discount;
        da.maxCount = maxCount;

        for(uint i=0; i< discountAddrList.length; ++i){
            da.addrmap[discountAddrList[i]] = true;
        }
    }

    function removeDiscountAddress(uint32 daId, address[] memory discountAddrList) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "MysteryBoxShop: must have manager role to manage");

        DiscountAddress storage da = _discountAddress[daId];

        for(uint i=0; i< discountAddrList.length; ++i){
            delete da.addrmap[discountAddrList[i]];
        }
    }

    function getDiscountInfo(uint32 daId) external view returns(uint16 discount, uint32 maxCount) {
        DiscountAddress storage da = _discountAddress[daId];
        discount = da.discount;
        maxCount = da.maxCount;
    }

    function isDiscountAddress(uint32 daId, address addr) external view returns(bool){
        DiscountAddress storage da = _discountAddress[daId];
        return da.addrmap[addr];
    }

    function getDiscountCountLeft(uint32 daId, address addr) external view returns(uint32) {
        return _discountBuyCount[daId][addr];
    }

    function clearDiscountAddress(uint32 daId) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "MysteryBoxShop: must have manager role to manage");

        delete _discountAddress[daId];
    }

    function setOnSaleMysteryBox(string calldata pairName, OnSaleMysterBox memory saleConfig, OnSaleMysterBoxRunTime memory saleData) external whenNotPaused {
        require(hasRole(MANAGER_ROLE, _msgSender()), "MysteryBoxShop: must have manager role to manage");

        if(saleConfig.renewTime > 0)
        {
            saleData.nextRenewTime = (uint64)(block.timestamp + saleConfig.renewTime);
        }

        _onSaleMysterBoxes[pairName] = saleConfig;
        _onSaleMysterBoxDatas[pairName] = saleData;

        emit SetOnSaleMysterBox(pairName, saleConfig, saleData);
    }

    function unsetOnSaleMysteryBox(string calldata pairName) external whenNotPaused {
        require(hasRole(MANAGER_ROLE, _msgSender()), "MysteryBoxShop: must have manager role to manage");

        OnSaleMysterBox storage onSalePair = _onSaleMysterBoxes[pairName];
        OnSaleMysterBoxRunTime storage onSalePairData = _onSaleMysterBoxDatas[pairName];

        emit UnsetOnSaleMysterBox(pairName, onSalePair, onSalePairData);

        delete _onSaleMysterBoxes[pairName];
        delete _onSaleMysterBoxDatas[pairName];
    }

    function setOnSaleMBCheckCondition(
        string calldata pairName, 
        uint256 price, 
        uint32 whitelistId, 
        address nftholderCheck, 
        uint32 perAddrLimit,
        uint32 discountId
    ) external {
        require(hasRole(OPERATER_ROLE, _msgSender()), "MysteryBoxShop: must have operater role");

        OnSaleMysterBox storage onSalePair = _onSaleMysterBoxes[pairName];

        onSalePair.price = price;
        onSalePair.whitelistId = whitelistId;
        onSalePair.nftholderCheck = nftholderCheck;
        onSalePair.perAddrLimit = perAddrLimit;
        onSalePair.discountId = discountId;

        emit SetOnSaleMBCheckCondition(pairName, price, whitelistId, nftholderCheck, perAddrLimit, discountId);
    }

    function setOnSaleMBCountleft(string calldata pairName, uint countLeft) external {
        require(hasRole(OPERATER_ROLE, _msgSender()), "MysteryBoxShop: must have operater role");

        OnSaleMysterBoxRunTime storage onSalePairData = _onSaleMysterBoxDatas[pairName];

        onSalePairData.countLeft = countLeft;

        emit SetOnSaleMBCountleft(pairName, countLeft);
    }

    function setReceiveIncomeAddress(address incomAddr) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "MysteryBoxShop: must have manager role to manage");

        _receiveIncomAddress = incomAddr;
    }

    function _checkSellCondition(OnSaleMysterBox storage onSalePair, OnSaleMysterBoxRunTime storage onSalePairData) internal {
        if(onSalePair.beginTime > 0)
        {
            require(block.timestamp >= onSalePair.beginTime, "MysteryBoxShop: sale not begin");
        }
        if(onSalePair.endTime > 0)
        {
            require(block.timestamp <= onSalePair.endTime, "MysteryBoxShop: sale finished");
        }
        if(onSalePair.whitelistId > 0)
        {
            require(_whitelists[onSalePair.whitelistId][_msgSender()], "MysteryBoxShop: not in whitelist");
        }
        if(onSalePair.nftholderCheck != address(0))
        {
            require(IERC721(onSalePair.nftholderCheck).balanceOf(_msgSender()) > 0, "MysteryBoxShop: no authority");
        }

        if(onSalePair.renewTime > 0)
        {
            if(block.timestamp > onSalePairData.nextRenewTime)
            {
                onSalePairData.nextRenewTime = (uint64)(onSalePairData.nextRenewTime + onSalePair.renewTime * (1 + ((block.timestamp - onSalePairData.nextRenewTime) / onSalePair.renewTime)));
                onSalePairData.countLeft = onSalePair.renewCount;
            }
        }
    }

    function _checkDiscount(uint256 realPrice, uint256 realCount, OnSaleMysterBox storage onSalePair) internal returns(uint256) {

        if(onSalePair.discountId == 0){
            return realPrice;
        }
        
        // check discount
        DiscountAddress storage discountAddr = _discountAddress[onSalePair.discountId];
        if(discountAddr.maxCount == 0) {
            return realPrice;
        }

        if(!discountAddr.addrmap[_msgSender()]) {
            return realPrice;
        }
        
        uint32 discountCount = _discountBuyCount[onSalePair.discountId][_msgSender()];
        require(discountAddr.maxCount > discountCount, "MysteryBoxShop: already done");

        uint32 discountCountLeft = discountAddr.maxCount - discountCount;
        if(discountCountLeft >= realCount){
            discountCount += uint32(realCount);
            realPrice = realPrice * discountAddr.discount / 10000;
        }
        else {
            discountCount = discountAddr.maxCount;
            realPrice = 
                (onSalePair.price * discountCountLeft * discountAddr.discount / 10000)  // discount part
                + onSalePair.price * (realCount - discountCountLeft); // no discount part
        }

        _discountBuyCount[onSalePair.discountId][_msgSender()] = discountCount;
        emit PerAddrDiscountCountChange(onSalePair.discountId, _msgSender(), discountCount);

        return realPrice;
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
                buyCount += uint32(realCount);
                _perAddrBuyCount[pairName][_msgSender()] = buyCount;

                emit PerAddrBuyCountChange(pairName, _msgSender(), buyCount);
            }
        }

        require(realCount > 0, "MysteryBoxShop: insufficient mystery box");

        onSalePairData.countLeft -= realCount;

        if(onSalePair.price > 0){
            uint256 realPrice = onSalePair.price * realCount;

            realPrice = _checkDiscount(realPrice, realCount, onSalePair);

            if(onSalePair.tokenAddr == address(0)){
                require(msg.value >= realPrice, "MysteryBoxShop: insufficient value");

                // receive eth
                (bool sent, ) = _receiveIncomAddress.call{value:msg.value}("");
                require(sent, "MysteryBoxShop: transfer income error");
            }
            else if(onSalePair.tokenId > 0)
            {
                // 1155
                require(IERC1155(onSalePair.tokenAddr).balanceOf( _msgSender(), onSalePair.tokenId) >= realPrice , "MysteryBoxShop: erc1155 insufficient token");

                // if(onSalePair.isBurn) {
                //     // burn
                //     ERC1155Burnable(onSalePair.tokenAddr).burn(_msgSender(), onSalePair.tokenId, realPrice);
                // }
                //else {
                    // charge
                    IERC1155(onSalePair.tokenAddr).safeTransferFrom(_msgSender(), address(this), onSalePair.tokenId, realPrice, "buy mb");
                //}
            }
            else{
                // 20
                require(IERC20(onSalePair.tokenAddr).balanceOf(_msgSender()) >= realPrice , "MysteryBoxShop: erc20 insufficient token");

                // if(onSalePair.isBurn) {
                //     // burn
                //     ERC20Burnable(onSalePair.tokenAddr).burnFrom(_msgSender(), realPrice);
                // }
                //else {
                    // charge
                    TransferHelper.safeTransferFrom(onSalePair.tokenAddr, _msgSender(), address(this), realPrice);
                //}
            }
        }

    }

    function buyMysteryBox(string calldata pairName) external payable whenNotPaused {
        OnSaleMysterBox storage onSalePair = _onSaleMysterBoxes[pairName];
        OnSaleMysterBoxRunTime storage onSalePairData = _onSaleMysterBoxDatas[pairName];
        require(address(onSalePair.mysteryBox1155Addr) != address(0), "MysteryBoxShop: mystery box not on sale");

        _checkSellCondition(onSalePair, onSalePairData);

        _chargeByDesiredCount(pairName, onSalePair, onSalePairData, 1);

        MysteryBox1155(onSalePair.mysteryBox1155Addr).mint(_msgSender(), onSalePair.mbTokenId, 1, "buy mb");

        emit BuyMysteryBox(_msgSender(), pairName, onSalePair, onSalePairData);
    }

    function batchBuyMysterBox(string calldata pairName, uint32 count) external payable whenNotPaused {

        OnSaleMysterBox storage onSalePair = _onSaleMysterBoxes[pairName];
        OnSaleMysterBoxRunTime storage onSalePairData = _onSaleMysterBoxDatas[pairName];
        require(address(onSalePair.mysteryBox1155Addr) != address(0), "MysteryBoxShop: mystery box not on sale");

        _checkSellCondition(onSalePair, onSalePairData);

        uint256 realCount = _chargeByDesiredCount(pairName, onSalePair, onSalePairData, count);

        MysteryBox1155(onSalePair.mysteryBox1155Addr).mint(_msgSender(), onSalePair.mbTokenId, realCount, "buy mb");

        emit BatchBuyMysteryBox(_msgSender(), pairName, onSalePair, onSalePairData, realCount);
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