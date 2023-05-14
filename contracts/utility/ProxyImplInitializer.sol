// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract ProxyImplInitializer {

    event Initialized(uint8);

    uint8 public initialized;
    bool _initializing;

    modifier initOnce() {
        bool isTopLevelCall = _setInitialized(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    modifier initOnceStep(uint8 version) {
        bool isTopLevelCall = _setInitialized(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "ProxyImplInitializer: not initializing");
        _;
    }

    function _setInitialized(uint8 version) private returns (bool) {
        if (_initializing) {
            require(
                version == 1 && !_isContract(address(this)),
                "ProxyImplInitializer: already initialized"
            );
            return false;
        } else {
            require(initialized < version, "ProxyImplInitializer: already intialized");
            initialized = version;
            return true;
        }
    }

    function _isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

}