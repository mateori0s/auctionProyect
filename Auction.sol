// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Auction Proyect Smart Contract
/// @author mateori0s
/// @notice Implements an auction with bid tracking, automatic refunds, and time extension
/// @dev Includes features like automatic 2% fee on refunds and emergency withdrawal

contract Auction {
    struct Bid {
        address bidder;
        uint256 amount;
    }

    struct BidInfo {
        uint256 lastBid;
        uint256 totalDeposited;
    }

    mapping(address => BidInfo) public bidsInfo;
    Bid[] public allBids;

    address public owner;
    uint256 public endTime;
    uint256 public initialValue;
    bool public auctionEnded;

    /// @notice Emitted when a new valid bid is placed
    /// @param bidder Address of the user who placed the bid
    /// @param amount Amount of ETH sent with the bid
    event NewBid(address bidder, uint256 amount);

    /// @notice Emitted when the auction is finalized
    /// @param winner Address of the winning bidder
    /// @param amount Final winning bid amount
    event AuctionFinalized(address winner, uint256 amount);

    /// @notice Emitted when a full refund (minus 2%) is sent to a non-winning bidder
    /// @param bidder Address of the user who receives the refund
    /// @param amount Amount of ETH refunded
    event RefundIssued(address bidder, uint256 amount);

    /// @notice Emitted when a partial refund is processed during the auction
    /// @param bidder Address of the user who receives the partial refund
    /// @param amount Amount of ETH refunded
    event PartialRefund(address bidder, uint256 amount);

    /// @notice Ensures the auction has not ended yet
    modifier onlyBeforeEnd() {
        require(block.timestamp < endTime, "Ended");
        require(!auctionEnded, "Ended manually");
        _;
    }

    /// @notice Ensures the auction has already ended
    modifier onlyAfterEnd() {
        require(block.timestamp >= endTime || auctionEnded, "Not ended");
        _;
    }

    /// @notice Ensures that only the contract owner can call a function
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    /// @notice Initializes the auction with default settings
    constructor() {
        owner = msg.sender;
        initialValue = 1 ether;
        endTime = block.timestamp + 7 days;
    }

    /// @notice Place a new bid during the auction
    /// @dev Bid must be 5% higher than the previous
    /// @custom:extension Adds 10 minutes if bid is placed near the end
    function bid() external payable onlyBeforeEnd {
        require(msg.value > 0, "Must send ETH");

        uint256 minValue = allBids.length == 0 ? initialValue : allBids[allBids.length - 1].amount;
        require(msg.value > (minValue * 105) / 100, "Insufficient bid");

        if (block.timestamp + 10 minutes > endTime) {
            endTime += 10 minutes;
        }

        bidsInfo[msg.sender].lastBid = msg.value;
        bidsInfo[msg.sender].totalDeposited += msg.value;

        allBids.push(Bid(msg.sender, msg.value));
        emit NewBid(msg.sender, msg.value);
    }

    /// @notice Returns the address and amount of the current winning bid
    /// @return Address of the winner and the winning bid amount
    function showWinner() external view returns (address, uint256) {
        require(allBids.length > 0, "No winner");
        Bid memory topBid = allBids[allBids.length - 1];
        return (topBid.bidder, topBid.amount);
    }

    /// @notice Returns the list of all bids placed
    /// @return Array of Bid structs containing bidder addresses and amounts
    function showAllBids() external view returns (Bid[] memory) {
        return allBids;
    }

    /// @notice Finalize the auction and refund non-winning bidders automatically
    /// @dev Applies a 2% fee to refunded amounts
    function finalizeAuction() external onlyAfterEnd onlyOwner {
        require(!auctionEnded, "Already finalized");
        auctionEnded = true;

        address winner = allBids[allBids.length - 1].bidder;
        uint256 bidCount = allBids.length;

        for (uint256 i = 0; i < bidCount; i++) {
            address bidder = allBids[i].bidder;
            if (bidder == winner) continue;

            uint256 refundAmount = (bidsInfo[bidder].totalDeposited * 98) / 100;
            if (refundAmount > 0) {
                bidsInfo[bidder].totalDeposited = 0;
                payable(bidder).transfer(refundAmount);
                emit RefundIssued(bidder, refundAmount);
            }
        }

        emit AuctionFinalized(winner, allBids[allBids.length - 1].amount);
    }

    /// @notice Withdraw the excess ETH sent in previous bids (not the latest)
    /// @dev Can only be called before auction ends
    function partialRefund() external onlyBeforeEnd {
        BidInfo storage info = bidsInfo[msg.sender];
        uint256 excess = info.totalDeposited - info.lastBid;
        require(excess > 0, "Nothing to refund");

        info.totalDeposited = info.lastBid;
        payable(msg.sender).transfer(excess);

        emit PartialRefund(msg.sender, excess);
    }

    /// @notice Withdraw all ETH from the contract in case of emergency, in this case onlyAfterEnd was not necessary (for practical purposes)
    /// @dev Only callable by the owner
    function emergencyWithdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    /// @notice Allows the contract to receive ETH directly
    receive() external payable {}
}
