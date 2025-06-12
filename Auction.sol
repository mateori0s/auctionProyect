// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

contract Auction {
    uint256 startTime;
    uint256 stopTime;
    struct Biders {
        uint256 offer;
        address bider;
    }

    Biders winner;
    Biders[] biders;

    event newOffer(address indexed bider, uint256 amount);
    event AuctionEnded();

    constructor() {
        startTime = block.timestamp;
        stopTime = startTime + 14 days;
    }

    modifier auctionActive() {
        require(block.timestamp < stopTime, "Auction is over!");
        _;
    }

    function bid() external payable auctionActive {
        if (msg.value > ((winner.offer * 105) / 100)) {
            winner.offer = msg.value;
            winner.bider = msg.sender;
            emit newOffer(msg.sender, msg.value);
        }
        if (block.timestamp < stopTime - 10 minutes) {
            stopTime += 10 minutes;
        }
    }

    function showWinner() external view returns (Biders memory) {
        return winner;
    }

    function showOffers() external view returns (Biders[] memory) {
        return biders;
    }

    function refound() external {
        uint256 actualOffer = (winner.offer * 108) / 100;
        payable(msg.sender).transfer(actualOffer);
        emit AuctionEnded();
    }

    function partialRefound() external auctionActive {}
}
