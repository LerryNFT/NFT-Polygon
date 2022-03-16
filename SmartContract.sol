// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/// @custom:security-contact metawhalez@gmail.com
contract Fleming is ERC721, ERC721Enumerable, Pausable, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;
    Counters.Counter private _tokenIdCounter;
    
    constructor() ERC721("<Name>", "<Symbol>") {} //change name and symbol

    string baseExtension = ".json"; //change if needed
    string baseURI = "<baseURI>"; //change
    string notRevealedURI = "<notRevealedURI>"; //change

    bool public revealed = false;

    uint256 public maxSupply = 10000; //change if needed

    function reveal() public onlyOwner {
        revealed = true;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }
    
    function _baseURI() internal view override returns (string memory) {
        if (revealed == true){
            return baseURI;
        } else {
            return notRevealedURI;
        }
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
 
        string memory currentBaseURI = _baseURI();
        if (revealed == true){
            return bytes(currentBaseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString(), baseExtension)) : "";
        } 
        else {
            return bytes(currentBaseURI).length > 0 ? string(abi.encodePacked(notRevealedURI, baseExtension)) : "";

        }
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function safeMint(address to, uint256 mintAmount) public onlyOwner {
        require (mintAmount <= maxSupply - totalSupply());
        for (uint256 i = 1; i <= mintAmount; i++){
        uint256 tokenId = _tokenIdCounter.current() + 1;
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function withdraw() public payable onlyOwner {
    (bool lock, ) = payable(owner()).call{value: address(this).balance}("");
    require(lock);
  }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}