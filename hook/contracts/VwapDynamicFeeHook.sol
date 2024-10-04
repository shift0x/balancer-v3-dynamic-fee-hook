// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {PoolInfo} from  './Types.sol';

import { VaultGuard } from "./ext/balancer-v3-monorepo/vault/VaultGuard.sol";
import { BaseHooks } from "./ext/balancer-v3-monorepo/vault/BaseHooks.sol";

contract VwapDynamicFeeHook  {

    mapping(bytes32 => PoolInfo) poolInfos;
}