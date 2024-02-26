// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


// This is just a simple example of a coin-like contract.
// It is not ERC20 compatible and cannot be expected to talk to other
// coin/token contracts.

contract Metacoin {
	
	struct wallet {
        address ethAddress;      // Node ETH address
        uint256  metacoins; // Business Address
    }
	
	uint256 private counter = 0;
	mapping(uint256 => wallet) public Wallets;
	
	function addWallet(address _ethAddress) virtual public{ 
		counter++;
        Wallets[counter] = wallet(_ethAddress, 100);
    }
	
	function findByEthAddress(address _address) private view returns (uint256) {
        require(counter > 0);
        for (uint256 i = 1; i <= counter; i++) {
            if (Wallets[i].ethAddress == _address) return i;
        }
        return 0;
	}
	
	function howManyMetacoins(address _address) public view returns (uint256) {
		return Wallets[findByEthAddress(_address)].metacoins;
	}
	
	
	function sendCoin(address receiver, address sender, uint amount) public returns(bool sufficient) {
		if (howManyMetacoins(sender) < amount) return false;
		Wallets[findByEthAddress(sender)].metacoins -= amount;
		Wallets[findByEthAddress(receiver)].metacoins += amount;
		return true;
	}
	
	function payLabor(address sender, uint amount) public returns(bool sufficient) {
		if (howManyMetacoins(sender) < amount) return false;
		Wallets[findByEthAddress(sender)].metacoins -= amount;
		return true;
	}

	function sold(address sender, uint amount) public returns(bool sufficient) {
		Wallets[findByEthAddress(sender)].metacoins += amount;
		return true;
	}
	
}



