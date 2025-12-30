//SPDX-License-Identifier: UNLICENSED


pragma solidity ^0.8.9;

contract Auction {
    struct AuctionDetails {
        uint256 datetime;
        uint256 reservePrice;
        uint256 endPrice;
        address seller;
        address buyer;
    }
    uint256[] public activeAuctions;
    mapping (uint256 => AuctionDetails) public auctionDetails;
    mapping (address => uint256) tokenOwners;
    mapping (address => bool) accounts;
    mapping (address => uint256) balances;


    function newBid(uint256 auction, uint256 amount) external returns (uint16) {
        address buyer = msg.sender;
        if ((auctionDetails[auction].reservePrice >= amount) || auctionDetails[auction].endPrice > amount) {// || balances[buyer]< amount) {
            return 1; // Insufficient funds
        } else {
            auctionDetails[auction].buyer = buyer;
            auctionDetails[auction].endPrice = amount;
            return 0; // Success
        }
    }

    function newAuction(uint256 auction, uint256 datetime, uint256 reservePrice) external returns (uint16) {
        address seller = msg.sender;
        activeAuctions.push(auction);
        auctionDetails[auction].datetime = datetime;
        auctionDetails[auction].seller = seller;
        auctionDetails[auction].reservePrice = reservePrice;
        return 0; // Auction success
    }

    function newAccount() external returns (bool) {
        if (accounts[msg.sender]) {
            return true; // Account exists already
        } else {
            tokenOwners[msg.sender] = 1;
            accounts[msg.sender] = true;
            //balances[msg.sender] = 999999;
            return false;
        }
    }

    function checkAccount(address account) external view returns (bool) {
        if (accounts[account] == true) {
            return true;
        }
        return false;
    }

    function transferToken(address buyer, address seller, uint256 auction) internal {
        tokenOwners[seller] -= 1;
        balances[seller] += auctionDetails[auction].endPrice;
        balances[buyer] -= auctionDetails[auction].endPrice;
        tokenOwners[buyer] += 1;
    }

    function checkComplete(uint256 datetime, uint256 auction) external {
        if (auctionDetails[activeAuctions[auction]].datetime <= (datetime - 900)) {
            transferToken(auctionDetails[activeAuctions[auction]].buyer, auctionDetails[activeAuctions[auction]].seller, auction);
            delete activeAuctions[auction];
        }
    }

    function getBalance() external view returns (uint256){
        address owner = msg.sender;
        return tokenOwners[owner];
    }

    function getAccountCount() external view returns (uint256) {
        return activeAuctions.length;
    }
}