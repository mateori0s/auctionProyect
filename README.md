# Auction Project Smart Contract

This smart contract implements a secure and dynamic auction system in Solidity. It supports incrementally increasing bids, automatic refunds for non-winning bidders, partial refunds during the auction, and an emergency fund recovery mechanism.

## Deployment

1. Copy the content of `Auction.sol` into [Remix IDE](https://remix.ethereum.org).
2. Compile using Solidity version `^0.8.0`.
3. Deploy with **no constructor parameters**.
4. The auction lasts **7 days** from deployment and automatically extends by **10 minutes** if a valid bid is placed near the end.

## Interaction

- Call `bid()` to place a bid. The new bid must be at least **5% higher** than the previous one.
- The auction tracks the current winner based on the latest valid bid.
- Once finalized, non-winning bidders are automatically refunded **98%** of their total deposits.
- Partial refunds for past bids (excluding the latest one) are available via `partialRefund()` during the auction.

## Main Functions

| Function              | Description                                                                 |
|-----------------------|-----------------------------------------------------------------------------|
| `bid()`               | Places a new bid. Must send ETH and meet the 5% increment rule.            |
| `showWinner()`        | Returns the address and amount of the current winning bid.                 |
| `showAllBids()`       | Returns the full list of all placed bids.                                  |
| `finalizeAuction()`   | Finalizes the auction. Refunds all non-winners (only callable by the owner).|
| `partialRefund()`     | Allows users to retrieve funds from older bids, excluding the last one.    |
| `emergencyWithdraw()` | Allows the owner to withdraw all contract funds in case of emergency.      |

## Events

- `NewBid(address bidder, uint256 amount)`
- `AuctionFinalized(address winner, uint256 amount)`
- `RefundIssued(address bidder, uint256 amount)`
- `PartialRefund(address bidder, uint256 amount)`

## Refunds

- **Automatic**: After `finalizeAuction()` is called, non-winners receive 98% of their total deposited ETH.
- **Manual (Partial)**: Bidders may call `partialRefund()` during the auction to withdraw excess ETH from past bids.

## Notes

- All critical functions are protected using access control (`onlyOwner`, `onlyBeforeEnd`, etc.).
- The `emergencyWithdraw()` function is intended only for recovery if funds are stuck. For practical purposes, it does not check if the auction has ended.
- ETH is received directly through the `receive()` function.

## Author

**Mateo Rios**  
[@mateori0s](https://github.com/mateori0s)
