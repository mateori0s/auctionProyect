# auctionProyect Smart Contract

This smart contract implements a secure and dynamic auction in Solidity. It includes features such as increasing bids, withdrawals, automatic time extension, partial refunds, manual termination and commissionable deposit returns.

---

## Deployment

1. Copy the contract to [Remix IDE](https://remix.ethereum.org).
2. Select `Solidity 0.8.x` compiler.
3. Compile and deploy using a VM network.
4. Interact with the contract functions from the Remix interface.

---

## Features

### `constructor()`

- Initializes the auction with a duration of 14 days.
- Sets the start time (`startTime`) and end time (`stopTime`).

---

### `function bid() external payable`

Allows you to place a bid during the auction.

- The bid must be at least 5% higher than the current bid.
- Records the most recent valid bid per user.
- Extends the auction 10 minutes if the bid is placed within the last 10 minutes.
- Emits the `NewOffer` event.

---

### `function showWinner() external view returns (address, uint256)`

Returns the current winner (address) and the value of their bid.

---

### `function showOffers() external view returns (Bider[] memory)`

Returns the list of all registered bids with their values and bidders.
---

### `function endAuction() external`

Manually end the auction before its time limit.

- It can only be executed once.
- It emits the `AuctionEnded` event.

---

### `function withdraw() external onlyAfterEnd`

Allows **offers losers** to withdraw their deposit **at a 2% discount**.

- The winner cannot use this feature.
- Issues the `FullRefund` event.

---

### `function partialRefound() external auctionActive`

Allows a bidder to withdraw excess ETH deposited **above their last valid bid** while the auction is still active.

- Emits the `PartialRefund` event.

---

## Variables
| Variable | Type | Description |
|----------|------|-------------|
| `startTime` | `uint256` | Auction start time. |
| `stopTime` | `uint256` | End time. |
| `ended` | `bool` | Indicates if the auction was ended manually. |
| `winner` | `Bider` | Saves the current highest bidder. |
| `allBids` | `Bider[]` | List of all bids placed. |
| `deposits` | `mapping` | ETH deposited by each bidder. |
| `latestValidBid` | `mapping` | Last valid bid per address. |

---

## Events

| Event | Description |
|--------|-------------|
| `NewOffer(address indexed bidder, uint256 amount)` | Issued when a new valid bid is placed. |
| `AuctionEnded(address winner, uint256 amount)` | Issued when the auction ends. |
| `PartialRefund(address indexed bidder, uint256 amount)` | Issued when a user withdraws excess funds. |
| `FullRefund(address indexed bidder, uint256 amount)` | Issued when a loser withdraws his deposit (98%). |

