// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Proxy {

    struct AddressSlot {
        address value;
    }

    // keccak-256 of eip1967.proxy.implementation - 1
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    constructor(address impl) payable
    {
        require(_isContract(impl), "Proxy: impl must be contract");
        _getAddressSlot(_IMPLEMENTATION_SLOT).value = impl;
    }

    function _isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function _getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    function _delegate(address impl) internal {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
    
    fallback() external payable {
        _delegate(_getAddressSlot(_IMPLEMENTATION_SLOT).value);
    }

    receive() external payable {
        _delegate(_getAddressSlot(_IMPLEMENTATION_SLOT).value);
    }
}