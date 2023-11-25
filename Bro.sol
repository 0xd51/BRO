// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 _______   _______    ______  
|       \ |       \  /      \ 
| $$$$$$$\| $$$$$$$\|  $$$$$$\
| $$__/ $$| $$__| $$| $$  | $$
| $$    $$| $$    $$| $$  | $$
| $$$$$$$\| $$$$$$$\| $$  | $$
| $$__/ $$| $$  | $$| $$__/ $$
| $$    $$| $$  | $$ \$$    $$
 \$$$$$$$  \$$   \$$  \$$$$$$  

BRO Token was made by a bunch of BROs for fun
We suggest you do not buy this token
1% max transfer / 1% max wallet on launch
*/

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BRO is ERC20, Ownable {
    uint256 private constant MAX_SUPPLY = 32_000_000 * 10**18;
    // Percentage limits for transfers and wallet holdings
    uint256 public maxTransferLimitPercent = 1; // Default to 1%, Max 10%
    uint256 public maxWalletLimitPercent = 1; // Default to 1%, Max 10%
    address public router = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // Pancakeswap router address
    address public pancakeswapPair; // PancakeswapPair address

    event MaxTransferLimitChanged(uint256 newPercent);
    event MaxWalletLimitChanged(uint256 newPercent);

    constructor() ERC20("BRO", "BRO") Ownable() {
        _mint(msg.sender, MAX_SUPPLY);
    }

    modifier checkTransferLimits(address to, uint256 amount) {
        if (msg.sender != owner() && msg.sender != router) {
            uint256 maxTransferLimit = (MAX_SUPPLY * maxTransferLimitPercent) / 100;

            // Exclude the PancakeSwap Pair from balance checks
            if (to != pancakeswapPair) {
                uint256 currentBalance = balanceOf(to);
                uint256 maxWalletLimit = (MAX_SUPPLY * maxWalletLimitPercent) / 100;

                require((currentBalance + amount) <= maxWalletLimit, "Transfer amount exceeds max wallet limit");
                require(amount <= maxTransferLimit, "Transfer amount exceeds max allowed for users");
            }
        }
        _;
    }

    function transfer(address recipient, uint256 amount) public virtual override checkTransferLimits(recipient, amount) returns (bool) {
        return super.transfer(recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override checkTransferLimits(recipient, amount) returns (bool) {
        return super.transferFrom(sender, recipient, amount);
    }

    function setMaxTransferLimitPercent(uint256 newPercent) external onlyOwner {
    require(newPercent >= 1 && newPercent <= 10, "Invalid Limit");
        maxTransferLimitPercent = newPercent;
        emit MaxTransferLimitChanged(newPercent);
    }

    function setMaxWalletLimitPercent(uint256 newPercent) external onlyOwner {
    require(newPercent >= 1 && newPercent <= 10, "Invalid Limit");
    maxWalletLimitPercent = newPercent;
    emit MaxWalletLimitChanged(newPercent);
    }

    function setRouter(address _router) external onlyOwner {
        router = _router;
    }

    function setPancakeSwapPairAddress(address _pancakeSwapPair) external onlyOwner {
        pancakeswapPair = _pancakeSwapPair;
    }

    function renounceOwnership() public override onlyOwner {
        super.renounceOwnership();
    }
}