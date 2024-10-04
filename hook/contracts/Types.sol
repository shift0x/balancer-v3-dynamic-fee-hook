// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

type PoolMetadata is bytes24;
type PoolKey is bytes32;

struct Observation {
    uint256 token0VolumeAccumulator;
    uint256 token1VolumeAccumulator;
}

struct PoolInfo {
    PoolMetadata metadata;
    Observation[] observations;
}