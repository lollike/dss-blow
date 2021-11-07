# dss-blow
DssBlow makes it easy to send Dai to the `vow` aka the Maker surplus buffer. This is the opposite of `suck`ing Dai from `vow`, hence the meme `blow`.

## Functionality

### `blow()`
Calling `blow()` function will automatically `join` any Dai deposited in `DssBlow` to the `vow`.
Therefore in order to repay Dai to the Maker surplus buffer, you simply send Dai to the DssBlow contract, and subsequentially call `blow()`.

### `blow(uint256 wad)`
You can also call `blow(uint256 wad)` to send a specified amount of Dai directly from your wallet to the Maker surplus buffer. To do this, you must first approve DssBlow to spend your Dai.
