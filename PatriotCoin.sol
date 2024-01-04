// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract PatriotCoin is ERC20, ERC20Permit, Ownable, ReentrancyGuard {   
    // Define government wallets
    address public deployerWallet;
    address public exchangeLiquidityWallet;
    address public treasuryWallet;
    address public marketingWallet;
    address public charitiesWallet;

    // Initialize government wallets, token identifiers, and create supply
    constructor(
        address initialOwner,
        address _exchangeLiquidityWallet,
        address _treasuryWallet,
        address _marketingWallet,
        address _charitiesWallet
    )
        ERC20("PatriotCoin", "PATRIOT")
        ERC20Permit("PatriotCoin")
        Ownable(initialOwner)
    {
        deployerWallet = initialOwner;
        exchangeLiquidityWallet = _exchangeLiquidityWallet;
        treasuryWallet = _treasuryWallet;
        marketingWallet = _marketingWallet;
        charitiesWallet = _charitiesWallet;
        
        _mint(msg.sender, 700000000 * 10 ** decimals());
    }
    
    
    // Define tax rate and initialize tax amount
    uint public _tax = 10; 
    uint private taxAmount = 0; 
    
   function _update(address from, address to, uint256 value) internal override nonReentrant {
        
        // Exclude tax from token minting
        if (from == address(0) && to == deployerWallet) {
            taxAmount = 0;
        }
        // Exclude government wallets from taxes
        else if (from == deployerWallet || from == exchangeLiquidityWallet || from == treasuryWallet || from == marketingWallet || from == charitiesWallet) {
            taxAmount = 0;
        }
        // Apply tax to non-government wallets
        else {
            taxAmount = value * _tax / 10000;
        }
        // Direct taxes to treasury wallet
        if (taxAmount > 0) {
            _balances[treasuryWallet] += taxAmount;
            emit Transfer(from, treasuryWallet, taxAmount);
        }

         if (from == address(0)) {
        // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            
            if (fromBalance < value) {
            revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            
            unchecked {
            // Overflow not possible: value <= fromBalance <= totalSupply.
            _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += (value - taxAmount);
            }
        }

        emit Transfer(from, to, (value - taxAmount));
   }
}