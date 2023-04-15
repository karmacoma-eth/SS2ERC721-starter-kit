// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {LibString} from "solmate/utils/LibString.sol";
import {Owned} from "solmate/auth/Owned.sol";

import {SS2ERC721} from "SS2ERC721/SS2ERC721.sol";

contract SimpleSS2ERC721 is SS2ERC721, Owned {
    using LibString for uint256;

    string public baseURI;

    /// @param _owner the ownership of this contract will be transferred to this address
    /// @param _name the ERC721 name
    /// @param _symbol the ERC721 symbol
    /// @param _baseURI will be concatenated with token id to produce a tokenURI (don't forget to include the final '/')
    constructor(address _owner, string memory _name, string memory _symbol, string memory _baseURI)
        Owned(_owner)
        SS2ERC721(_name, _symbol)
    {
        baseURI = _baseURI;
    }

    function mintBatch(bytes calldata packedRecipients) public onlyOwner {
        _mint(packedRecipients);
    }

    /*//////////////////////////////////////////////////////////////
                             VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function tokenURI(uint256 id) public view override returns (string memory) {
        require(id != 0 && id <= totalSupply(), "NOT_MINTED");

        return string.concat(baseURI, id.toString());
    }

    function totalSupply() public view returns (uint256) {
        return _ownersPrimaryLength();
    }
}
