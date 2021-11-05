pragma solidity ^0.6.7;

import "ds-test/test.sol";

import "./DssBlow.sol";

contract DssBlowTest is DSTest {
    DssBlow blow;

    function setUp() public {
        blow = new DssBlow();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
