// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2021 Dai Foundation
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

pragma solidity ^0.6.12;

import "ds-test/test.sol";
import "ds-math/math.sol";
import "dss-interfaces/Interfaces.sol";
import "./DssBlow.sol";

interface Hevm {
    function warp(uint256) external;
    function store(address,bytes32,bytes32) external;
    function load(address,bytes32) external view returns (bytes32);
}

contract DssBlowTest is DSTest, DSMath {

    Hevm hevm;

    DssBlow blow;
    DSTokenAbstract dai;
    VatAbstract vat;
    address vow;
    address daiJoin;

    function setUp() public {
        hevm    = Hevm(address(bytes20(uint160(uint256(keccak256('hevm cheat code'))))));
        dai     = DSTokenAbstract(0x6B175474E89094C44Da98b954EedeAC495271d0F);
        vat     = VatAbstract(0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B);
        vow     = 0xA950524441892A31ebddF91d3cEEFa04Bf454466;
        daiJoin = 0x9759A6Ac90977b93B58547b4A71c78317f391A28;
        blow    = new DssBlow(daiJoin, vow);
    }

    function test_blow_contract_balance(uint64 amount) public {
        assertEq(dai.balanceOf(address(blow)), 0);
        uint256 vowBalance = vat.dai(vow);

        _giveTokens(dai, amount);
        assertEq(dai.balanceOf(address(this)), amount);

        dai.approve(address(blow), amount);
        dai.transferFrom(address(this), address(blow), amount);
        assertEq(dai.balanceOf(address(blow)), amount);

        blow.blow();
        assertEq(dai.balanceOf(address(blow)), 0);
        assertEq(vat.dai(vow), add(vowBalance, amount*RAY));
    }

    function test_blow_direct_call(uint64 amount) public {
        assertEq(dai.balanceOf(address(this)), 0);
        uint256 vowBalance = vat.dai(vow);
        
        _giveTokens(dai, amount);
        assertEq(dai.balanceOf(address(this)), amount);
        
        dai.approve(address(blow), amount);
        blow.blow(amount);
        assertEq(dai.balanceOf(address(this)), 0);
        assertEq(vat.dai(vow), add(vowBalance, amount*RAY));
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
