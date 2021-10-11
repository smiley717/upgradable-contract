// SPDX-License-Identifier: MIT
pragma solidity ^0.6.5;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./provableAPI_0.6.sol";

contract UpgradableContract is ERC721Upgradeable, usingProvable {
    using CountersUpgradeable for CountersUpgradeable.Counter;

    CountersUpgradeable.Counter internal toyTokenIDs;
    CountersUpgradeable.Counter internal paintingTokenIDs;
    CountersUpgradeable.Counter internal statuetteTokenIDs;

    uint256 internal toyTokenIDBase;
    uint256 internal paintingTokenIDBase;
    uint256 internal statuetteTokenIDBase;
    uint256 internal maxSupply;

    address internal _owner;
    bool public isOpenPayment;
    string internal royaltyPath;
    mapping(bytes32 => address payable) internal queryIdToCaller;
    ERC721 bloot;

    modifier onlyOwner() {
        require( _owner == msg.sender, "Ownable: caller is not the owner" );
        _;
    }

    function initialize() initializer external {
        __ERC721_init("Albert", "Albert");
        _owner = msg.sender;

        toyTokenIDBase = 0;
        paintingTokenIDBase = 173;
        statuetteTokenIDBase = 211;
        maxSupply = 1695;
        bloot = ERC721(0xDA1Ca34d7C71d4fB4E5719cAE1A0F5fDcaC6A84b);
    }

    function claim(uint8 _category, uint8 _count) external payable {
        require(_category >= 1, "category out of range");
        require(_category <= 3, "category out of range");
        require(super.totalSupply() < maxSupply, "total supply is reached maximum limit");
        uint256 blootBalance = bloot.balanceOf(msg.sender);

        uint8 blootTokenCount = 0;
        uint256 blootTokenMin = 0;
        uint256 blootTokenMax = 0;
        if (_category == 1) {
            blootTokenMin = 4790;
            blootTokenMax = 4962;
        } else if (_category == 2) {
            blootTokenMin = 4963;
            blootTokenMax = 5000;
        } else if (_category == 3) {
            blootTokenMin = 1;
            blootTokenMax = 1484;
        }

        for (uint8 i = 0; i < blootBalance; i++) {
            uint256 blootTokenAtIndex = bloot.tokenOfOwnerByIndex(msg.sender, i);
            if (blootTokenAtIndex >= blootTokenMin && blootTokenAtIndex <= blootTokenMax)
                blootTokenCount ++;
        }
        require(blootTokenCount >= _count, "claim count mismatch");

        uint256 tokenID = 0;
        for (uint8 i = 0; i < _count; i++) {
            if (_category == 1) {
                toyTokenIDs.increment();
                tokenID = toyTokenIDs.current() + toyTokenIDBase;
            } else if (_category == 2) {
                paintingTokenIDs.increment();
                tokenID = paintingTokenIDs.current() + paintingTokenIDBase;
            } else if (_category == 3) {
                statuetteTokenIDs.increment();
                tokenID = statuetteTokenIDs.current() + statuetteTokenIDBase;
            }
            _safeMint(msg.sender, tokenID);
            _setTokenURI(tokenID, uint2str(tokenID));
        }
    }

    function setBaseURI(string calldata _baseURI) external onlyOwner {
        super._setBaseURI(_baseURI);
    }

    function setTokenURI(uint256 _tokenID, string calldata _tokenURI) external onlyOwner {
        super._setTokenURI(_tokenID, _tokenURI);
    }

    function openPayment(bool _open, string calldata _royaltyPath) external onlyOwner {
        isOpenPayment = _open;
        if (_open)
            royaltyPath = _royaltyPath;
    }

    function withdrawRoyalty() external payable{
        require(isOpenPayment == true, "Payment is closed");
        string memory myRoyalty = string(abi.encodePacked("json(", royaltyPath, ").addr_0x", toAsciiString(msg.sender)));

        bytes32 queryId = provable_query("URL", myRoyalty);
        queryIdToCaller[queryId] = msg.sender;
    }

    function __callback(
        bytes32 _myid,
        string memory _result
    )
        public override
    {
        require(msg.sender == provable_cbAddress());        
        require(parseInt(_result) > 0, "You don't have any royalties");
        require(address(this).balance >= parseInt(_result), "Insufficient balance in the contract");
        require(queryIdToCaller[_myid] != address(0x0), "invalid caller");

        (bool success, ) = queryIdToCaller[_myid].call{value: parseInt(_result)}("");
        require(success, "Failed to send sol");
    }

    function toAsciiString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);            
        }
        return string(s);
    }
    
    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }
}