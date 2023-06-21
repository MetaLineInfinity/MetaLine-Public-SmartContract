// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SerialUtility {

    // size of
    function sizeOfString(string memory _in) internal pure  returns(uint _size){
        _size = bytes(_in).length / 32;
         if(bytes(_in).length % 32 != 0) 
            _size++;
            
        _size++; // first 32 bytes is reserved for the size of the string     
        _size *= 32;
    }

    function sizeOfInt8() internal pure  returns(uint size){
        return 1;
    }
    function sizeOfInt16() internal pure  returns(uint size){
        return 2;
    }
    function sizeOfInt24() internal pure  returns(uint size){
        return 3;
    }
    function sizeOfInt32() internal pure  returns(uint size){
        return 4;
    }
    function sizeOfInt64() internal pure  returns(uint size){
        return 8;
    }
    // function sizeOfInt72() internal pure  returns(uint size){
    //     return 9;
    // }
    // function sizeOfInt80() internal pure  returns(uint size){
    //     return 10;
    // }
    // function sizeOfInt88() internal pure  returns(uint size){
    //     return 11;
    // }
    // function sizeOfInt96() internal pure  returns(uint size){
    //     return 12;
    // }
    // function sizeOfInt104() internal pure  returns(uint size){
    //     return 13;
    // }
    // function sizeOfInt112() internal pure  returns(uint size){
    //     return 14;
    // }
    // function sizeOfInt120() internal pure  returns(uint size){
    //     return 15;
    // }
    function sizeOfInt128() internal pure  returns(uint size){
        return 16;
    }
    // function sizeOfInt136() internal pure  returns(uint size){
    //     return 17;
    // }
    // function sizeOfInt144() internal pure  returns(uint size){
    //     return 18;
    // }
    // function sizeOfInt152() internal pure  returns(uint size){
    //     return 19;
    // }
    // function sizeOfInt160() internal pure  returns(uint size){
    //     return 20;
    // }
    // function sizeOfInt168() internal pure  returns(uint size){
    //     return 21;
    // }
    // function sizeOfInt176() internal pure  returns(uint size){
    //     return 22;
    // }
    // function sizeOfInt184() internal pure  returns(uint size){
    //     return 23;
    // }
    // function sizeOfInt192() internal pure  returns(uint size){
    //     return 24;
    // }
    // function sizeOfInt200() internal pure  returns(uint size){
    //     return 25;
    // }
    // function sizeOfInt208() internal pure  returns(uint size){
    //     return 26;
    // }
    // function sizeOfInt216() internal pure  returns(uint size){
    //     return 27;
    // }
    // function sizeOfInt224() internal pure  returns(uint size){
    //     return 28;
    // }
    // function sizeOfInt232() internal pure  returns(uint size){
    //     return 29;
    // }
    // function sizeOfInt240() internal pure  returns(uint size){
    //     return 30;
    // }
    // function sizeOfInt248() internal pure  returns(uint size){
    //     return 31;
    // }
    function sizeOfInt256() internal pure  returns(uint size){
        return 32;
    }
    
    function sizeOfUint8() internal pure  returns(uint size){
        return 1;
    }
    function sizeOfUint16() internal pure  returns(uint size){
        return 2;
    }
    function sizeOfUint24() internal pure  returns(uint size){
        return 3;
    }
    function sizeOfUint32() internal pure  returns(uint size){
        return 4;
    }
    // function sizeOfUint40() internal pure  returns(uint size){
    //     return 5;
    // }
    // function sizeOfUint48() internal pure  returns(uint size){
    //     return 6;
    // }
    // function sizeOfUint56() internal pure  returns(uint size){
    //     return 7;
    // }
    function sizeOfUint64() internal pure  returns(uint size){
        return 8;
    }
    // function sizeOfUint72() internal pure  returns(uint size){
    //     return 9;
    // }
    // function sizeOfUint80() internal pure  returns(uint size){
    //     return 10;
    // }
    // function sizeOfUint88() internal pure  returns(uint size){
    //     return 11;
    // }
    // function sizeOfUint96() internal pure  returns(uint size){
    //     return 12;
    // }
    // function sizeOfUint104() internal pure  returns(uint size){
    //     return 13;
    // }
    // function sizeOfUint112() internal pure  returns(uint size){
    //     return 14;
    // }
    // function sizeOfUint120() internal pure  returns(uint size){
    //     return 15;
    // }
    function sizeOfUint128() internal pure  returns(uint size){
        return 16;
    }
    // function sizeOfUint136() internal pure  returns(uint size){
    //     return 17;
    // }
    // function sizeOfUint144() internal pure  returns(uint size){
    //     return 18;
    // }
    // function sizeOfUint152() internal pure  returns(uint size){
    //     return 19;
    // }
    // function sizeOfUint160() internal pure  returns(uint size){
    //     return 20;
    // }
    // function sizeOfUint168() internal pure  returns(uint size){
    //     return 21;
    // }
    // function sizeOfUint176() internal pure  returns(uint size){
    //     return 22;
    // }
    // function sizeOfUint184() internal pure  returns(uint size){
    //     return 23;
    // }
    // function sizeOfUint192() internal pure  returns(uint size){
    //     return 24;
    // }
    // function sizeOfUint200() internal pure  returns(uint size){
    //     return 25;
    // }
    // function sizeOfUint208() internal pure  returns(uint size){
    //     return 26;
    // }
    // function sizeOfUint216() internal pure  returns(uint size){
    //     return 27;
    // }
    // function sizeOfUint224() internal pure  returns(uint size){
    //     return 28;
    // }
    // function sizeOfUint232() internal pure  returns(uint size){
    //     return 29;
    // }
    // function sizeOfUint240() internal pure  returns(uint size){
    //     return 30;
    // }
    // function sizeOfUint248() internal pure  returns(uint size){
    //     return 31;
    // }
    function sizeOfUint256() internal pure  returns(uint size){
        return 32;
    }

    function sizeOfAddress() internal pure  returns(uint8){
        return 20; 
    }
    
    function sizeOfBool() internal pure  returns(uint8){
        return 1; 
    }
    
    // to bytes
    
    function addressToBytes(uint _offst, address _input, bytes memory _output) internal pure {

        assembly {
            mstore(add(_output, _offst), _input)
        }
    }

    function bytes32ToBytes(uint _offst, bytes32 _input, bytes memory _output) internal pure {

        assembly {
            mstore(add(_output, _offst), _input)
            mstore(add(add(_output, _offst),32), add(_input,32))
        }
    }
    
    function boolToBytes(uint _offst, bool _input, bytes memory _output) internal pure {
        uint8 x = _input == false ? 0 : 1;
        assembly {
            mstore8(add(_output, _offst), x)
        }
    }
    
    function stringToBytes(uint _offst, bytes memory _input, bytes memory _output) internal pure {
        uint256 stack_size = _input.length / 32;
        if(_input.length % 32 > 0) stack_size++;
        
        assembly {
            stack_size := add(stack_size,1)//adding because of 32 first bytes memory as the length
            for { let index := 0 } lt(index,stack_size){ index := add(index ,1) } {
                mstore(add(_output, _offst), mload(add(_input,mul(index,32))))
                _offst := sub(_offst , 32)
            }
        }
    }

    function intToBytes(uint _offst, int _input, bytes memory  _output) internal pure {

        assembly {
            mstore(add(_output, _offst), _input)
        }
    } 
    
    function uintToBytes(uint _offst, uint _input, bytes memory _output) internal pure {

        assembly {
            mstore(add(_output, _offst), _input)
        }
    }   

    // bytes to

    function bytesToAddress(uint _offst, bytes memory _input) internal pure returns (address _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 
    
    function bytesToBool(uint _offst, bytes memory _input) internal pure returns (bool _output) {
        
        uint8 x;
        assembly {
            x := mload(add(_input, _offst))
        }
        x==0 ? _output = false : _output = true;
    }   
        
    function getStringSize(uint _offst, bytes memory _input) internal pure returns(uint size){
        
        assembly{
            
            size := mload(add(_input,_offst))
            let chunk_count := add(div(size,32),1) // chunk_count = size/32 + 1
            
            if gt(mod(size,32),0) {// if size%32 > 0
                chunk_count := add(chunk_count,1)
            } 
            
             size := mul(chunk_count,32)// first 32 bytes reseves for size in strings
        }
    }

    function bytesToString(uint _offst, bytes memory _input, bytes memory _output) internal pure {

        uint size = 32;
        assembly {
            
            let chunk_count
            
            size := mload(add(_input,_offst))
            chunk_count := add(div(size,32),1) // chunk_count = size/32 + 1
            
            if gt(mod(size,32),0) {
                chunk_count := add(chunk_count,1)  // chunk_count++
            }
               
            for { let index:= 0 }  lt(index , chunk_count){ index := add(index,1) } {
                mstore(add(_output,mul(index,32)),mload(add(_input,_offst)))
                _offst := sub(_offst,32)           // _offst -= 32
            }
        }
    }

    function bytesToBytes32(uint _offst, bytes memory  _input, bytes32 _output) internal pure {
        
        assembly {
            mstore(_output , add(_input, _offst))
            mstore(add(_output,32) , add(add(_input, _offst),32))
        }
    }
    
    function bytesToInt8(uint _offst, bytes memory  _input) internal pure returns (int8 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }
    
    function bytesToInt16(uint _offst, bytes memory _input) internal pure returns (int16 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt24(uint _offst, bytes memory _input) internal pure returns (int24 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt32(uint _offst, bytes memory _input) internal pure returns (int32 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    // function bytesToInt40(uint _offst, bytes memory _input) internal pure returns (int40 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    // function bytesToInt48(uint _offst, bytes memory _input) internal pure returns (int48 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    // function bytesToInt56(uint _offst, bytes memory _input) internal pure returns (int56 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    function bytesToInt64(uint _offst, bytes memory _input) internal pure returns (int64 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    // function bytesToInt72(uint _offst, bytes memory _input) internal pure returns (int72 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    // function bytesToInt80(uint _offst, bytes memory _input) internal pure returns (int80 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    // function bytesToInt88(uint _offst, bytes memory _input) internal pure returns (int88 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    // function bytesToInt96(uint _offst, bytes memory _input) internal pure returns (int96 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }
	
	// function bytesToInt104(uint _offst, bytes memory _input) internal pure returns (int104 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }
    
    // function bytesToInt112(uint _offst, bytes memory _input) internal pure returns (int112 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    // function bytesToInt120(uint _offst, bytes memory _input) internal pure returns (int120 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    function bytesToInt128(uint _offst, bytes memory _input) internal pure returns (int128 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    // function bytesToInt136(uint _offst, bytes memory _input) internal pure returns (int136 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    // function bytesToInt144(uint _offst, bytes memory _input) internal pure returns (int144 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    // function bytesToInt152(uint _offst, bytes memory _input) internal pure returns (int152 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    // function bytesToInt160(uint _offst, bytes memory _input) internal pure returns (int160 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    // function bytesToInt168(uint _offst, bytes memory _input) internal pure returns (int168 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    // function bytesToInt176(uint _offst, bytes memory _input) internal pure returns (int176 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    // function bytesToInt184(uint _offst, bytes memory _input) internal pure returns (int184 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    // function bytesToInt192(uint _offst, bytes memory _input) internal pure returns (int192 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    // function bytesToInt200(uint _offst, bytes memory _input) internal pure returns (int200 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    // function bytesToInt208(uint _offst, bytes memory _input) internal pure returns (int208 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    // function bytesToInt216(uint _offst, bytes memory _input) internal pure returns (int216 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    // function bytesToInt224(uint _offst, bytes memory _input) internal pure returns (int224 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    // function bytesToInt232(uint _offst, bytes memory _input) internal pure returns (int232 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    // function bytesToInt240(uint _offst, bytes memory _input) internal pure returns (int240 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    // function bytesToInt248(uint _offst, bytes memory _input) internal pure returns (int248 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    function bytesToInt256(uint _offst, bytes memory _input) internal pure returns (int256 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

	function bytesToUint8(uint _offst, bytes memory _input) internal pure returns (uint8 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

	function bytesToUint16(uint _offst, bytes memory _input) internal pure returns (uint16 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

	function bytesToUint24(uint _offst, bytes memory _input) internal pure returns (uint24 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

	function bytesToUint32(uint _offst, bytes memory _input) internal pure returns (uint32 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

	// function bytesToUint40(uint _offst, bytes memory _input) internal pure returns (uint40 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

	// function bytesToUint48(uint _offst, bytes memory _input) internal pure returns (uint48 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

	// function bytesToUint56(uint _offst, bytes memory _input) internal pure returns (uint56 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

	function bytesToUint64(uint _offst, bytes memory _input) internal pure returns (uint64 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

	// function bytesToUint72(uint _offst, bytes memory _input) internal pure returns (uint72 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

	// function bytesToUint80(uint _offst, bytes memory _input) internal pure returns (uint80 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

	// function bytesToUint88(uint _offst, bytes memory _input) internal pure returns (uint88 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

	// function bytesToUint96(uint _offst, bytes memory _input) internal pure returns (uint96 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 
	
	// function bytesToUint104(uint _offst, bytes memory _input) internal pure returns (uint104 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

    // function bytesToUint112(uint _offst, bytes memory _input) internal pure returns (uint112 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

    // function bytesToUint120(uint _offst, bytes memory _input) internal pure returns (uint120 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

    function bytesToUint128(uint _offst, bytes memory _input) internal pure returns (uint128 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    // function bytesToUint136(uint _offst, bytes memory _input) internal pure returns (uint136 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

    // function bytesToUint144(uint _offst, bytes memory _input) internal pure returns (uint144 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

    // function bytesToUint152(uint _offst, bytes memory _input) internal pure returns (uint152 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

    // function bytesToUint160(uint _offst, bytes memory _input) internal pure returns (uint160 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

    // function bytesToUint168(uint _offst, bytes memory _input) internal pure returns (uint168 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

    // function bytesToUint176(uint _offst, bytes memory _input) internal pure returns (uint176 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

    // function bytesToUint184(uint _offst, bytes memory _input) internal pure returns (uint184 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

    // function bytesToUint192(uint _offst, bytes memory _input) internal pure returns (uint192 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

    // function bytesToUint200(uint _offst, bytes memory _input) internal pure returns (uint200 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

    // function bytesToUint208(uint _offst, bytes memory _input) internal pure returns (uint208 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

    // function bytesToUint216(uint _offst, bytes memory _input) internal pure returns (uint216 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

    // function bytesToUint224(uint _offst, bytes memory _input) internal pure returns (uint224 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

    // function bytesToUint232(uint _offst, bytes memory _input) internal pure returns (uint232 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

    // function bytesToUint240(uint _offst, bytes memory _input) internal pure returns (uint240 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

    // function bytesToUint248(uint _offst, bytes memory _input) internal pure returns (uint248 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

    function bytesToUint256(uint _offst, bytes memory _input) internal pure returns (uint256 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 
    
}