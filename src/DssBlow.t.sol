pragma solidity ^0.6.7;

import "ds-test/test.sol";

import "./DssBlow.sol";

interface Hevm {
    function warp(uint256) external;
    function store(address,bytes32,bytes32) external;
    function load(address,bytes32) external view returns (bytes32);
}

contract DssBlowTest is DSTest {

    uint256 constant WAD = 10 ** 18;
    uint256 constant RAY = 10 ** 27;
    uint256 constant RAD = 10 ** 45;

    Hevm hevm;

    DssBlow blow;
    address vow = 0xA950524441892A31ebddF91d3cEEFa04Bf454466;
    address daiJoin = 0x9759A6Ac90977b93B58547b4A71c78317f391A28;
    address dai_ = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    function setUp() public {
        hevm = Hevm(address(bytes20(uint160(uint256(keccak256('hevm cheat code'))))));
        blow = new DssBlow(daiJoin, vow);
        dai = DaiLike(dai_);
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }

    function test_blow_contract_balance(uint256 amount) public {
        assertEq(dai.balanceOf(addres(this)) == 0);
        _giveTokens(dai, amount);

    }

    function _giveTokens(DSTokenAbstract token, uint256 amount) internal {
        // Edge case - balance is already set for some reason
        if (token.balanceOf(address(this)) == amount) return;

        for (int i = 0; i < 100; i++) {
            // Scan the storage for the balance storage slot
            bytes32 prevValue = hevm.load(
                address(token),
                keccak256(abi.encode(address(this), uint256(i)))
            );
            hevm.store(
                address(token),
                keccak256(abi.encode(address(this), uint256(i))),
                bytes32(amount)
            );
            if (token.balanceOf(address(this)) == amount) {
                // Found it
                return;
            } else {
                // Keep going after restoring the original value
                hevm.store(
                    address(token),
                    keccak256(abi.encode(address(this), uint256(i))),
                    prevValue
                );
            }
        }

        // We have failed if we reach here
        assertTrue(false);
    }
}
