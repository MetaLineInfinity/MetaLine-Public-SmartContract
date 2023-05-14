// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Proxy.sol";

abstract contract ProxyUpgradeable is Proxy {

    // keccak-256 of eip1967.proxy.admin - 1
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    event Upgraded(address indexed implementation);
    event AdminChanged(address previousAdmin, address newAdmin);

    constructor(address impl)
        payable
        Proxy(impl)
    {
        _delegateCall(
            impl, 
            abi.encodeWithSignature("initialize()", 0), 
            "ProxyUpgradeable: delegate call initialize failed"
        );

        _changeAdmin(msg.sender);
    }

    function upgradeTo(address impl) public {
        require(
            msg.sender == _getAdmin(),
            "ProxyUpgradeable: Only admin can do this."
        );
        _upgradeTo(impl);
    }
 
    function getAdmin() public view returns (address) {
        return _getAdmin();
    }

    function changeAdmin(address newAdmin) public {
        require(
            msg.sender == _getAdmin(),
            "ProxyUpgradeable: Only admin can do this."
        );
        _changeAdmin(newAdmin);
    }

    function _delegateCall(
        address impl,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory)
    {
        (bool success, bytes memory returndata) = impl.delegatecall(data);

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }

    function _upgradeTo(address newImpl) internal {
        _getAddressSlot(_IMPLEMENTATION_SLOT).value = newImpl;
        emit Upgraded(newImpl);
    }

    function _getAdmin() internal view returns (address) {
        return _getAddressSlot(_ADMIN_SLOT).value;
    }

    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ProxyUpgradeable: newAdmin = 0");
        _getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

}