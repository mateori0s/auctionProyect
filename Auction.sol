// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Auction {
    uint256 public startTime;
    uint256 public stopTime;
    bool public ended;

    struct Bider {
        uint256 offer;
        address bidder;
    }

    Bider public winner;
    Bider[] public allBids;

    mapping(address => uint256) public deposits;
    mapping(address => uint256) public latestValidBid;

    event NewOffer(address indexed bidder, uint256 amount);
    event AuctionEnded(address winner, uint256 amount);
    event PartialRefund(address indexed bidder, uint256 amount);
    event FullRefund(address indexed bidder, uint256 amount);

    constructor() {
        startTime = block.timestamp;
        stopTime = startTime + 14 days;
        ended = false;
    }

    modifier auctionActive() {
        require(block.timestamp < stopTime, "The auction has ended");
        require(!ended, "Auction ended manually");
        _;
    }

    modifier onlyAfterEnd() {
        require(
            block.timestamp >= stopTime || ended,
            "The auction is not over yet"
        );
        _;
    }

    function bid() external payable auctionActive {
        require(msg.value > 0, "You must send more than 0 ETH");

        uint256 minBid = winner.offer + (winner.offer * 5) / 100;
        require(
            msg.value >= minBid || winner.bidder == address(0),
            "You must exceed the current offer by at least 5%"
        );

        uint256 previousBid = latestValidBid[msg.sender];
        if (previousBid > 0) {
            deposits[msg.sender] += previousBid;
        }

        latestValidBid[msg.sender] = msg.value;
        deposits[msg.sender] += msg.value;

        winner = Bider(msg.value, msg.sender);
        allBids.push(winner);

        emit NewOffer(msg.sender, msg.value);

        if (stopTime - block.timestamp <= 10 minutes) {
            stopTime += 10 minutes;
        }
    }

    function showWinner() external view returns (address, uint256) {
        return (winner.bidder, winner.offer);
    }

    function showOffers() external view returns (Bider[] memory) {
        return allBids;
    }

    //Test para terminar subasta manualmente
    function endAuction() external {
        require(!ended, "Auction ended");
        ended = true;
        emit AuctionEnded(winner.bidder, winner.offer);
    }

    function withdraw() external onlyAfterEnd {
        require(msg.sender != winner.bidder, "Winner cannot withdraw");
        uint256 amount = deposits[msg.sender];
        require(amount > 0, "You have no funds to withdraw");

        deposits[msg.sender] = 0;
        uint256 refund = (amount * 98) / 100;
        payable(msg.sender).transfer(refund);
        emit FullRefund(msg.sender, refund);
    }

    function partialRefound() external auctionActive {
        uint256 total = deposits[msg.sender];
        uint256 currentBid = latestValidBid[msg.sender];
        require(total > currentBid, "You have no excess to reimburse");

        uint256 refund = total - currentBid;
        deposits[msg.sender] = currentBid;
        payable(msg.sender).transfer(refund);
        emit PartialRefund(msg.sender, refund);
    }
}
