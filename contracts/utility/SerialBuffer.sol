// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SerialUtility.sol";

library SerialBuffer {

    struct Buffer{
        uint index;
        bytes buffer;
    }

    function _checkSpace(SerialBuffer.Buffer memory _buf, uint size) private pure returns(bool) {
        return (_buf.index >= size && _buf.index >= 32);
    }

    function enlargeBuffer(SerialBuffer.Buffer memory _buf, uint size) internal pure {
        _buf.buffer = new bytes(size);
        _buf.index = size;
    }
    function setBuffer(SerialBuffer.Buffer memory _buf, bytes memory buffer) internal pure {
        _buf.buffer = buffer;
    }
    function getBuffer(SerialBuffer.Buffer memory _buf) internal pure returns(bytes memory) {
        return _buf.buffer;
    }

    // writers
    function writeAddress(SerialBuffer.Buffer memory _buf, address _input) internal pure {
        uint size = SerialUtility.sizeOfAddress();
        require(_checkSpace(_buf, size), "writeAddress  Serial: write buffer size not enough");

        SerialUtility.addressToBytes(_buf.index, _input, _buf.buffer);
        _buf.index -= size;
    }

    function writeString(SerialBuffer.Buffer memory _buf, string memory _input) internal pure {
        uint size = SerialUtility.sizeOfString(_input);
        require(_checkSpace(_buf, size), "writeString   Serial: write buffer size not enough");

        SerialUtility.stringToBytes(_buf.index, bytes(_input), _buf.buffer);
        _buf.index -= size;
    }

    function writeBool(SerialBuffer.Buffer memory _buf, bool _input) internal pure {
        uint size = SerialUtility.sizeOfBool();
        require(_checkSpace(_buf, size), "writeBool Serial: write buffer size not enough");

        SerialUtility.boolToBytes(_buf.index, _input, _buf.buffer);
        _buf.index -= size;
    }

    function writeInt8(SerialBuffer.Buffer memory _buf, int8 _input) internal pure {
        uint size = SerialUtility.sizeOfInt8();
        require(_checkSpace(_buf, size), "writeInt8 Serial: write buffer size not enough");

        SerialUtility.intToBytes(_buf.index, _input, _buf.buffer);
        _buf.index -= size;
    }
    
    function writeInt16(SerialBuffer.Buffer memory _buf, int16 _input) internal pure {
        uint size = SerialUtility.sizeOfInt16();
        require(_checkSpace(_buf, size), "writeInt16    Serial: write buffer size not enough");

        SerialUtility.intToBytes(_buf.index, _input, _buf.buffer);
        _buf.index -= size;
    }
    
    function writeInt32(SerialBuffer.Buffer memory _buf, int32 _input) internal pure {
        uint size = SerialUtility.sizeOfInt32();
        require(_checkSpace(_buf, size), "writeInt32    Serial: write buffer size not enough");

        SerialUtility.intToBytes(_buf.index, _input, _buf.buffer);
        _buf.index -= size;
    }
    
    function writeInt64(SerialBuffer.Buffer memory _buf, int64 _input) internal pure {
        uint size = SerialUtility.sizeOfInt64();
        require(_checkSpace(_buf, size), "writeInt64    Serial: write buffer size not enough");

        SerialUtility.intToBytes(_buf.index, _input, _buf.buffer);
        _buf.index -= size;
    }
    
    function writeInt128(SerialBuffer.Buffer memory _buf, int128 _input) internal pure {
        uint size = SerialUtility.sizeOfInt128();
        require(_checkSpace(_buf, size), "writeInt128   Serial: write buffer size not enough");

        SerialUtility.intToBytes(_buf.index, _input, _buf.buffer);
        _buf.index -= size;
    }

    function writeInt256(SerialBuffer.Buffer memory _buf, int256 _input) internal pure {
        uint size = SerialUtility.sizeOfInt256();
        require(_checkSpace(_buf, size), "writeInt256   Serial: write buffer size not enough");

        SerialUtility.intToBytes(_buf.index, _input, _buf.buffer);
        _buf.index -= size;
    }

    function writeUint8(SerialBuffer.Buffer memory _buf, uint8 _input) internal pure {
        uint size = SerialUtility.sizeOfUint8();
        require(_checkSpace(_buf, size), "writeUint8    Serial: write buffer size not enough");

        SerialUtility.uintToBytes(_buf.index, _input, _buf.buffer);
        _buf.index -= size;
    }
    
    function writeUint16(SerialBuffer.Buffer memory _buf, uint16 _input) internal pure {
        uint size = SerialUtility.sizeOfUint16();
        require(_checkSpace(_buf, size), "writeUint16   Serial: write buffer size not enough");

        SerialUtility.uintToBytes(_buf.index, _input, _buf.buffer);
        _buf.index -= size;
    }
    
    function writeUint32(SerialBuffer.Buffer memory _buf, uint32 _input) internal pure {
        uint size = SerialUtility.sizeOfUint32();
        require(_checkSpace(_buf, size), "writeUint32   Serial: write buffer size not enough");

        SerialUtility.uintToBytes(_buf.index, _input, _buf.buffer);
        _buf.index -= size;
    }
    
    function writeUint64(SerialBuffer.Buffer memory _buf, uint64 _input) internal pure {
        uint size = SerialUtility.sizeOfUint64();
        require(_checkSpace(_buf, size), "writeUint64   Serial: write buffer size not enough");

        SerialUtility.uintToBytes(_buf.index, _input, _buf.buffer);
        _buf.index -= size;
    }
    
    function writeUint128(SerialBuffer.Buffer memory _buf, uint128 _input) internal pure {
        uint size = SerialUtility.sizeOfUint128();
        require(_checkSpace(_buf, size), "writeUint128  Serial: write buffer size not enough");

        SerialUtility.uintToBytes(_buf.index, _input, _buf.buffer);
        _buf.index -= size;
    }

    function writeUint256(SerialBuffer.Buffer memory _buf, uint256 _input) internal pure {
        uint size = SerialUtility.sizeOfUint256();
        require(_checkSpace(_buf, size), "writeUint256  Serial: write buffer size not enough");

        SerialUtility.uintToBytes(_buf.index, _input, _buf.buffer);
        _buf.index -= size;
    }

    // readers
    function readAddress(SerialBuffer.Buffer memory _buf) internal pure returns(address) {
        uint size = SerialUtility.sizeOfAddress();
        require(_checkSpace(_buf, size), "readAddress   Serial: read buffer size not enough");

        address addr = SerialUtility.bytesToAddress(_buf.index, _buf.buffer);
        _buf.index -= size;

        return addr;
    }
    
    function readString(SerialBuffer.Buffer memory _buf) internal pure returns(string memory) {
        uint size = SerialUtility.getStringSize(_buf.index, _buf.buffer);
        require(_checkSpace(_buf, size), "readString    Serial: read buffer size not enough");

        string memory str = new string (size);
        SerialUtility.bytesToString(_buf.index, _buf.buffer, bytes(str));
        _buf.index -= size;

        return str;
    }

    function readBool(SerialBuffer.Buffer memory _buf) internal pure returns(bool) {
        uint size = SerialUtility.sizeOfBool();
        require(_checkSpace(_buf, size), "readBool  Serial: read buffer size not enough");

        bool b = SerialUtility.bytesToBool(_buf.index, _buf.buffer);
        _buf.index -= size;

        return b;
    }

    function readInt8(SerialBuffer.Buffer memory _buf) internal pure returns(int8) {
        uint size = SerialUtility.sizeOfInt8();
        require(_checkSpace(_buf, size), "readInt8  Serial: read buffer size not enough");

        int8 i = SerialUtility.bytesToInt8(_buf.index, _buf.buffer);
        _buf.index -= size;

        return i;
    }
    
    function readInt16(SerialBuffer.Buffer memory _buf) internal pure returns(int16) {
        uint size = SerialUtility.sizeOfInt16();
        require(_checkSpace(_buf, size), "readInt16 Serial: read buffer size not enough");

        int16 i = SerialUtility.bytesToInt16(_buf.index, _buf.buffer);
        _buf.index -= size;

        return i;
    }
    
    function readInt32(SerialBuffer.Buffer memory _buf) internal pure returns(int32) {
        uint size = SerialUtility.sizeOfInt32();
        require(_checkSpace(_buf, size), "readInt32 Serial: read buffer size not enough");

        int32 i = SerialUtility.bytesToInt32(_buf.index, _buf.buffer);
        _buf.index -= size;

        return i;
    }
    
    function readInt64(SerialBuffer.Buffer memory _buf) internal pure returns(int64) {
        uint size = SerialUtility.sizeOfInt64();
        require(_checkSpace(_buf, size), "readInt64 Serial: read buffer size not enough");

        int64 i = SerialUtility.bytesToInt64(_buf.index, _buf.buffer);
        _buf.index -= size;

        return i;
    }
    
    function readInt128(SerialBuffer.Buffer memory _buf) internal pure returns(int128) {
        uint size = SerialUtility.sizeOfInt128();
        require(_checkSpace(_buf, size), "readInt128    Serial: read buffer size not enough");

        int128 i = SerialUtility.bytesToInt128(_buf.index, _buf.buffer);
        _buf.index -= size;

        return i;
    }

    function readInt256(SerialBuffer.Buffer memory _buf) internal pure returns(int256) {
        uint size = SerialUtility.sizeOfInt256();
        require(_checkSpace(_buf, size), "readInt256    Serial: read buffer size not enough");

        int256 i = SerialUtility.bytesToInt256(_buf.index, _buf.buffer);
        _buf.index -= size;

        return i;
    }

    function readUint8(SerialBuffer.Buffer memory _buf) internal pure returns(uint8) {
        uint size = SerialUtility.sizeOfUint8();
        require(_checkSpace(_buf, size), "readUint8 Serial: read buffer size not enough");

        uint8 i = SerialUtility.bytesToUint8(_buf.index, _buf.buffer);
        _buf.index -= size;

        return i;
    }
    
    function readUint16(SerialBuffer.Buffer memory _buf) internal pure returns(uint16) {
        uint size = SerialUtility.sizeOfUint16();
        require(_checkSpace(_buf, size), "readUint16    Serial: read buffer size not enough");

        uint16 i = SerialUtility.bytesToUint16(_buf.index, _buf.buffer);
        _buf.index -= size;

        return i;
    }
    
    function readUint32(SerialBuffer.Buffer memory _buf) internal pure returns(uint32) {
        uint size = SerialUtility.sizeOfUint32();
        require(_checkSpace(_buf, size), "readUint32    Serial: read buffer size not enough");

        uint32 i = SerialUtility.bytesToUint32(_buf.index, _buf.buffer);
        _buf.index -= size;

        return i;
    }
    
    function readUint64(SerialBuffer.Buffer memory _buf) internal pure returns(uint64) {
        uint size = SerialUtility.sizeOfUint64();
        require(_checkSpace(_buf, size), "readUint64    Serial: read buffer size not enough");

        uint64 i = SerialUtility.bytesToUint64(_buf.index, _buf.buffer);
        _buf.index -= size;

        return i;
    }
    
    function readUint128(SerialBuffer.Buffer memory _buf) internal pure returns(uint128) {
        uint size = SerialUtility.sizeOfUint128();
        require(_checkSpace(_buf, size), "readUint128   Serial: read buffer size not enough");

        uint128 i = SerialUtility.bytesToUint128(_buf.index, _buf.buffer);
        _buf.index -= size;

        return i;
    }

    function readUint256(SerialBuffer.Buffer memory _buf) internal pure returns(uint256) {
        uint size = SerialUtility.sizeOfUint256();
        require(_checkSpace(_buf, size), "readUint256   Serial: read buffer size not enough");

        uint256 i = SerialUtility.bytesToUint256(_buf.index, _buf.buffer);
        _buf.index -= size;

        return i;
    }

}