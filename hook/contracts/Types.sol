// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

struct Observation {
    uint256 token0VolumeAccumulator;
    uint256 token1VolumeAccumulator;
}

struct PoolInfo {
    uint8 head;
    uint8 tail;
    uint8 maxObservations;
    Observation[] observations;
}