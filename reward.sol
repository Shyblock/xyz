pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract rewardeth is ERC20 {
    constructor() ERC20("Reward eth","RETH") {
        _mint(msg.sender, 100 * 10**18);
    }

}
