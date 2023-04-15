// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import {SimpleSS2ERC721Deploy} from "script/SimpleSS2ERC721.s.sol";
import {SimpleSS2ERC721} from "src/SimpleSS2ERC721.sol";

contract SimpleSS2ERC721Test is Test {
    SimpleSS2ERC721 token;

    function setUp() public {
        SimpleSS2ERC721Deploy deployer = new SimpleSS2ERC721Deploy();
        token = deployer.run();
    }

    function test_name() public {
        assertEq(token.name(), "Cool Name");
    }

    function test_symbol() public {
        assertEq(token.symbol(), "COOL");
    }

    function test_tokenURI_goodTokenId() public {
        assertEq(token.tokenURI(1), "ipfs://<directory-cid>/1");
    }

    function test_tokenURI_badTokenId() public {
        vm.expectRevert("NOT_MINTED");
        token.tokenURI(0);

        vm.expectRevert("NOT_MINTED");
        token.tokenURI(11);
    }

    function test_totalSupply() public {
        assertEq(token.totalSupply(), 10);
    }

    function test_owner() public {
        assertEq(token.owner(), 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    }

    function test_ownerOf() public {
        assertEq(token.ownerOf(1), 0x1111111111111111111111111111111111111111);
    }

    function test_balanceOf() public {
        assertEq(token.balanceOf(0x1111111111111111111111111111111111111111), 1);
    }
}
