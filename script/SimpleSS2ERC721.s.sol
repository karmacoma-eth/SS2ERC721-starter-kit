// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Script.sol";

import {SimpleSS2ERC721} from "src/SimpleSS2ERC721.sol";

contract SimpleSS2ERC721Deploy is Script {
    function mockAddresses(address startAddr, uint256 num) internal pure returns (bytes memory packedRecipients) {
        for (uint160 i = 0; i < num; i++) {
            packedRecipients = abi.encodePacked(packedRecipients, address(uint160(startAddr) + (1 << 128) * i));
        }
    }

    function pack(address[] memory recipients) internal pure returns (bytes memory packedRecipients) {
        require(recipients.length != 0, "NO_RECIPIENTS");
        require(recipients.length < 1228, "RECIPENTS_TOO_BIG");

        // pack the recipients into a single bytes array
        // this is just a script, so we don't need the loop to be gas efficient
        for (uint256 i = 0; i < recipients.length; i++) {
            packedRecipients = abi.encodePacked(packedRecipients, recipients[i]);
        }
    }

    function run() public returns (SimpleSS2ERC721 token) {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address deployerAddr = vm.addr(pk);

        // read the contract parameters from the config file
        string memory config = vm.readFile(string.concat(vm.projectRoot(), "/token-config.json"));
        address owner = vm.parseJsonAddress(config, ".owner");
        string memory name = vm.parseJsonString(config, ".name");
        string memory symbol = vm.parseJsonString(config, ".symbol");
        string memory baseURI = vm.parseJsonString(config, ".baseURI");
        address[] memory recipients = vm.parseJsonAddressArray(config, ".recipients");

        // pack the recipients into a single bytes array
        // bytes memory packedRecipients = pack(recipients);
        bytes memory packedRecipients = mockAddresses(recipients[0], 1200);


        vm.startBroadcast(pk);

        // 1st transaction: deploy the contract
        token = new SimpleSS2ERC721(deployerAddr, name, symbol, baseURI);
        console2.log("Deployed SimpleSS2ERC721 at", address(token));

        // 2nd transaction: mint the tokens in 1 batch
        token.mintBatch(packedRecipients);

        // optionally, transfer ownership to the owner if it's not the deployer
        if (owner != deployerAddr) {
            token.transferOwnership(owner);
        }

        vm.stopBroadcast();
    }
}
