// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {PoolKey, PoolInfo} from '../Types.sol';

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library PoolInfos {

    function getId(
        address pool,
        IERC20 tokenIn,
        IERC20 tokenOut
    ) private pure returns (bytes32) {
        (IERC20 tokenA, IERC20 tokenB) = tokenIn > tokenOut ? 
            (tokenIn, tokenOut) :
            (tokenOut, tokenIn);
        
        return keccak256(abi.encodePacked(pool, address(tokenA), address(tokenB)));
    }

    function store(
        mapping(PoolKey => PoolInfo) storage self,
        address pool,
        IERC20 tokenIn,
        IERC20 tokenOut,
        uint256 amountIn,
        uint256 amountOut
    ) internal {
        
    }
}