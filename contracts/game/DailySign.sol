// SPDX-License-Identifier: MIT
// Metaline Contracts (DailySign.sol)

pragma solidity >=0.8.0 <=0.9.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "../utility/TransferHelper.sol";

contract DailySign is
    Context,
    AccessControl
{
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    
    address public TokenAddr;
    uint256 public TokenValuePerSign;
    uint32 public TimeSlice; // time in seconds

    mapping(address=>uint32) public _lastSignTime;

    constructor(
        address _tokenAddr,
        uint256 _perSign,
        uint32 _timeSlice
    ) {
        require(_perSign > 0, "DailySign: perSign must >0");

        TokenAddr = _tokenAddr;
        TokenValuePerSign = _perSign;
        TimeSlice = _timeSlice;

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MANAGER_ROLE, _msgSender());
    } 

    function setConf(
        uint256 _perSign,
        uint32 _timeSlice
    ) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "DailySign: must have manager role");
        
        TokenValuePerSign = _perSign;
        TimeSlice = _timeSlice;
    }

    function sign() external {
        require(_lastSignTime[_msgSender()] + TimeSlice <= block.timestamp, "DailySign: Cool Down");

        // TransferHelper.safeTransferFrom(TokenAddr, address(this), _msgSender(), TokenValuePerSign);
        TransferHelper.safeTransfer(TokenAddr, _msgSender(), TokenValuePerSign);

        _lastSignTime[_msgSender()] = uint32(block.timestamp);
    }
}