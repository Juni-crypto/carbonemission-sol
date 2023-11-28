// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract CarbonCredits {
    address public owner;
    mapping(address => bool) public providers;
    mapping(address => bool) public buyers;
    mapping(address => uint256) public credits;
    mapping(address => string) public providerNames;
    mapping(address => string) public buyerNames;
    address[] public providerList;
    address[] public buyerList;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    event CreditsAdded(address indexed provider, uint256 amount);
    event CreditsBought(address indexed buyer, address indexed provider, uint256 amount);

    function addProvider(address provider, string memory name) public onlyOwner {
        providers[provider] = true;
        providerNames[provider] = name;
        providerList.push(provider);
    }

    function addBuyer(address buyer, string memory name) public onlyOwner {
        buyers[buyer] = true;
        buyerNames[buyer] = name;
        buyerList.push(buyer);
    }

    function addCredits(address provider, uint256 amount) public onlyOwner {
        require(providers[provider] == true);
        credits[provider] += amount;
        
        emit CreditsAdded(provider, amount);
    }

    uint256 public creditPriceInWei = 100000000000000; // 0.0001 Ether

    function buyCredits(address provider, uint256 amount) public payable {
        require(providers[provider] == true);
        require(buyers[msg.sender] == true);
        require(credits[provider] >= amount);
    
        uint256 cost = creditPriceInWei * amount;
        require(msg.value >= cost, "Not enough Ether sent");

        credits[provider] -= amount;
        credits[msg.sender] += amount; // Credit the buyer's account
        payable(provider).transfer(cost); // Transfer the Ether to the provider

        emit CreditsBought(msg.sender, provider, amount);
    }

    function transferCredits(address to, uint256 amount) public {
        require(providers[msg.sender] == true, "Only providers can transfer credits");
        require(credits[msg.sender] >= amount, "Not enough credits to transfer");

        credits[msg.sender] -= amount;
        credits[to] += amount;
    }

    function sellCredits(uint256 amount) public {
        require(providers[msg.sender] == true, "Only providers can sell credits");
        require(credits[msg.sender] >= amount, "Not enough credits to sell");

        credits[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }

    function getCreditBalance(address account) public view returns (uint256) {
        return credits[account];
    }

    function getProviderByIndex(uint index) public view returns (address) {
        return providerList[index];
    }

    function getBuyerByIndex(uint index) public view returns (address) {
        return buyerList[index];
    }

    function getTotalProviders() public view returns (uint) {
        return providerList.length;
    }

    function getTotalBuyers() public view returns (uint) {
        return buyerList.length;
    }
}