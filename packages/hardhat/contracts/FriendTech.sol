// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// Import the ERC20 contract from the OpenZeppelin library
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// Import the AccessControl library from OpenZeppelin to implement role-based access control
import "@openzeppelin/contracts/access/AccessControl.sol";

contract FriendTech is ERC20, AccessControl {
    address public owner;

    mapping(address => uint256) private sharePrice;
    mapping(address => uint256) public totalShares;

    // Declare roles for the contract
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");

    constructor() ERC20("FriendTech", "FTK") {
        owner = msg.sender;

        // Assign the contract owner the OWNER_ROLE
        _setupRole(OWNER_ROLE, msg.sender);
    }

    // Function to set the share price, only accessible by users with the OWNER_ROLE
    function setSharePrice(uint256 price) external onlyRole(OWNER_ROLE) {
        require(price > 0, "Price must be greater than zero");
        sharePrice[msg.sender] = price;
    }

    function getSharePrice(address user) public view returns (uint256) {
        return sharePrice[user];
    }

    function setTotalShares(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        totalShares[msg.sender] = amount;
    }

    function getTotalShares(address user) public view returns (uint256) {
        return totalShares[user];
    }

    function buyShares(address seller, uint256 amount) external payable {
        require(amount > 0, "Amount must be greater than zero");
        require(totalShares[seller] >= amount, "Seller does not have enough shares");
        require(sharePrice[seller] <= msg.value, "Insufficient payment");

        totalShares[seller] -= amount;
        totalShares[msg.sender] += amount;

        uint256 tokensToMint = (msg.value * 10**decimals()) / sharePrice[seller];
        _mint(msg.sender, tokensToMint);
    }

    function sellShares(address buyer, uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(totalShares[msg.sender] >= amount, "Insufficient shares");

        totalShares[msg.sender] -= amount;
        totalShares[buyer] += amount;

        uint256 tokensToBurn = (amount * sharePrice[msg.sender]) / 10**decimals();
        _burn(msg.sender, tokensToBurn);
        payable(buyer).transfer(tokensToBurn);
    }

    function transferShares(address to, uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(totalShares[msg.sender] >= amount, "Insufficient shares");

        totalShares[msg.sender] -= amount;
        totalShares[to] += amount;

        _transfer(msg.sender, to, amount);
    }
}