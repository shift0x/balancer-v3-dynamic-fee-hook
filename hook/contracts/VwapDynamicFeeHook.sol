// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {
    PoolInfo, 
    PoolKey
} from  './Types.sol';

import { 
    LiquidityManagement,
    RemoveLiquidityKind,
    TokenConfig,
    PoolSwapParams,
    AfterSwapParams,
    HookFlags
} from "./ext/balancer-v3-monorepo/interfaces/vault/VaultTypes.sol";

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { BaseHooks } from "./ext/balancer-v3-monorepo/vault/BaseHooks.sol";
import { VaultGuard } from "./ext/balancer-v3-monorepo/vault/VaultGuard.sol";
import { IHooks } from "./ext/balancer-v3-monorepo/interfaces/vault/IHooks.sol";
import { IVault } from "./ext/balancer-v3-monorepo/interfaces/vault/IVault.sol";
import { IBasePoolFactory } from "./ext/balancer-labs/v3-interfaces/vault/IBasePoolFactory.sol";

import { PoolInfos } from "./lib/PoolInfos.sol";

contract VwapDynamicFeeHook is VaultGuard, BaseHooks  {
    using PoolInfos for mapping(PoolKey => PoolInfo);

    // Mapping of keccak256(poolAddress, tokenA, tokenB) => PoolInfo
    // using tokenIn / tokenOut in the key allows management of pools with > 2 tokens
    mapping(PoolKey => PoolInfo) private poolInfos;

    // Only pools from a specific factory are able to register and use this hook.
    address private immutable _allowedFactory;

    /**
     * @notice A new `VwapDynamicFeeHookRegistered` contract has been registered successfully for a given factory and pool.
     * @dev If the registration fails the call will revert, so there will be no event.
     * @param hooksContract This contract
     * @param pool The pool on which the hook was registered
     */
    event VwapDynamicFeeHookRegistered(address indexed hooksContract, address indexed pool);

    constructor(
        IVault vault,
        address factory
    ) VaultGuard(vault) { 
        _allowedFactory = factory;
    }

    /// @inheritdoc IHooks
    function onRegister(
        address factory,
        address pool,
        TokenConfig[] memory,
        LiquidityManagement calldata
    ) public override returns (bool) {
        emit VwapDynamicFeeHookRegistered(address(this), pool);

        return factory == _allowedFactory && IBasePoolFactory(factory).isPoolFromFactory(pool);
    }

    /// @inheritdoc IHooks
    function getHookFlags() public pure override returns (HookFlags memory hookFlags) {
        hookFlags.shouldCallComputeDynamicSwapFee = true;
        hookFlags.shouldCallAfterSwap = true;
    }

    /// @inheritdoc IHooks
    function onComputeDynamicSwapFeePercentage(
        PoolSwapParams calldata params,
        address pool,
        uint256 staticSwapFeePercentage
    ) public view override onlyVault returns (bool, uint256) {
        return (true, staticSwapFeePercentage);
    }

    /// @inheritdoc IHooks
    function onAfterSwap(AfterSwapParams calldata params) public override returns (bool, uint256) {
        // store the swap volumes and update the vwap
        poolInfos.store(params.pool, params.tokenIn, params.tokenOut, params.amountInScaled18, params.amountOutScaled18);
        
        // return the amountCalculated with no modifications. The compute dynamic swap fee method
        // already took care of adjusting the swap fee for this swap.
        return (true, params.amountCalculatedRaw);
    }

}