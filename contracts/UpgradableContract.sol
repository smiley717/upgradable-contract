// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

contract UpgradableContract is ERC721Upgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter internal _tokenIDs;
    address internal _owner;
    bool internal isOpenPayment;
    mapping(address => uint256) public royalties;

    modifier onlyOwner() {
        require( _owner == msg.sender, "Ownable: caller is not the owner" );
        _;
    }

    function initialize() initializer external {
        __ERC721_init("Albert", "Albert");
        _owner = msg.sender;
    }

    function claim(
    ) external payable {
        _tokenIDs.increment();
        uint256 tokenID = _tokenIDs.current();
        _safeMint(msg.sender, tokenID);
        _setTokenURI(tokenID, uint2str(tokenID));
    }

    function setBaseURI(string calldata _baseURI) external onlyOwner {
        super._setBaseURI(_baseURI);
    }

    function setTokenURI(uint256 tokenID, string calldata _tokenURI) external onlyOwner {
        super._setTokenURI(tokenID, _tokenURI);
    }

    receive () external payable {
        royalties[msg.sender] = msg.value;
    }

    function openPayment(bool _open) external onlyOwner {
        isOpenPayment = _open;
    }

    // function withdraw() external onlyOwner {
    //     (bool success, ) = _owner.call{value: address(this).balance}("");
    //     require(success, "Failed to send sol");
    // }

    function withdrawRoyalty() external {
        require(isOpenPayment == true, "Payment is closed");
        require(royalties[msg.sender] > 0, "You don't have any royalties");
        (bool success, ) = msg.sender.call{value: royalties[msg.sender]}("");
        require(success, "Failed to send sol");
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}