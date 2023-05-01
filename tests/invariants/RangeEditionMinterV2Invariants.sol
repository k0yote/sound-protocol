// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import { SoundEditionV1_2 } from "@core/SoundEditionV1_2.sol";
import { MintInfo } from "@modules/interfaces/IRangeEditionMinterV2.sol";
import { RangeEditionMinterV2 } from "@modules/RangeEditionMinterV2.sol";
import { BaseMinterV2 } from "@modules/BaseMinterV2.sol";
import { RangeEditionMinterV2Tests } from "../modules/RangeEditionMinterV2.t.sol";
import { InvariantTest } from "./InvariantTest.sol";

contract RangeEditionMinterV2Invariants is RangeEditionMinterV2Tests, InvariantTest {
    RangeEditionMinterV2Updater minterUpdater;
    RangeEditionMinterV2 minter;
    SoundEditionV1_2 edition;

    function setUp() public override {
        super.setUp();

        edition = createGenericEdition();

        minter = new RangeEditionMinterV2();

        edition.grantRoles(address(minter), edition.MINTER_ROLE());

        minter.createEditionMint(
            address(edition),
            PRICE,
            START_TIME,
            CUTOFF_TIME,
            END_TIME,
            AFFILIATE_FEE_BPS,
            MAX_MINTABLE_LOWER,
            MAX_MINTABLE_UPPER,
            MAX_MINTABLE_PER_ACCOUNT
        );

        minterUpdater = new RangeEditionMinterV2Updater(edition, minter);

        addTargetContract(address(minter));
    }

    function invariant_maxMintableRange() public {
        MintInfo memory data = minter.mintInfo(address(edition), MINT_ID);
        assertTrue(data.maxMintableLower <= data.maxMintableUpper);
    }

    function invariant_timeRange() public {
        MintInfo memory mintInfo = minter.mintInfo(address(edition), MINT_ID);

        uint32 startTime = mintInfo.startTime;
        uint32 cutoffTime = mintInfo.cutoffTime;
        uint32 endTime = mintInfo.endTime;
        assertTrue(startTime < cutoffTime && cutoffTime < endTime);
    }
}

contract RangeEditionMinterV2Updater {
    uint128 constant MINT_ID = 0;

    SoundEditionV1_2 edition;
    RangeEditionMinterV2 minter;

    constructor(SoundEditionV1_2 _edition, RangeEditionMinterV2 _minter) {
        edition = _edition;
        minter = _minter;
    }

    function setTimeRange(
        uint32 startTime,
        uint32 cutoffTime,
        uint32 endTime
    ) public {
        minter.setTimeRange(address(edition), MINT_ID, startTime, cutoffTime, endTime);
    }

    function setMaxMintableRange(uint32 maxMintableLower, uint32 maxMintableUpper) public {
        minter.setMaxMintableRange(address(edition), MINT_ID, maxMintableLower, maxMintableUpper);
    }
}
