// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract CarbonCredits {
    address public owner;
    mapping(address => bool) public providers;
    mapping(address => uint256) public credits;
    mapping(address => string) public providerNames;
    address[] public providerList;

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

    function addCredits(address provider, uint256 amount) public onlyOwner {
        require(providers[provider] == true);
        credits[provider] += amount;
        
        emit CreditsAdded(provider, amount);
    }

    function buyCredits(address provider, uint256 amount) public payable {
        require(providers[provider] == true);
        require(credits[provider] >= amount);
        require(msg.value >= amount);

        credits[provider] -= amount;

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

    function getCreditBalance(address provider) public view returns (uint256) {
        return credits[provider];
    }

    function getProviderByIndex(uint index) public view returns (address) {
        return providerList[index];
    }

    function getTotalProviders() public view returns (uint) {
        return providerList.length;
    }
}