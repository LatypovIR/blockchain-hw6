// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Callee.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";


contract TestFlashSwap is IUniswapV2Callee {
    address private constant UNISWAP_V2_FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;

    address private constant wETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant LINK = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
    address private constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    function logState(address borrow) external view {
        IERC20 token_BORROW =  IERC20(borrow);
        IERC20 token_wETH =  IERC20(wETH);
        IERC20 token_LINK =  IERC20(LINK);
        IERC20 token_DAI =  IERC20(DAI);
        address owner = address(this);

        console.log("      For owner: [%s] wallet:", owner);
        console.log("            BORROW = [%d]", token_BORROW.balanceOf(owner));
        console.log("            wETH = [%d]", token_wETH.balanceOf(owner));
        console.log("            LINK = [%d]", token_LINK.balanceOf(owner));
        console.log("            DAI = [%d]", token_DAI.balanceOf(owner));
    }

    function runFlashSwap(address borrow, uint amount) external {
        address pair = IUniswapV2Factory(UNISWAP_V2_FACTORY).getPair(borrow, wETH);
        require(pair != address(0), "pair address is 0");
        IUniswapV2Pair uniswapPair = IUniswapV2Pair(pair);

        address token0 = uniswapPair.token0();
        address token1 = uniswapPair.token1();
        uint amount0 = token0 != borrow ? amount : 0;
        uint amount1 = token1 != borrow ? amount : 0;

        bytes memory data = abi.encode(borrow);
        uniswapPair.swap(amount0, amount1, address(this), data);
    }

    function runSwap(address from, address to, uint amountFrom) external returns (uint amountTo) {
        address pair = IUniswapV2Factory(UNISWAP_V2_FACTORY).getPair(from, to);
        require(pair != address(0), "pair address is 0");

        address token0 = IUniswapV2Pair(pair).token0();
        address token1 = IUniswapV2Pair(pair).token1();

        (uint112 reserve0, uint112 reserve1, ) = IUniswapV2Pair(pair).getReserves();

        if (token0 == from) {
            amountTo =
                (997 * amountFrom * uint(reserve1)) / (1000 * uint(reserve0) + 997 * amountFrom);
        } else {
            amountTo =
                (997 * amountFrom * uint(reserve0)) / (1000 * uint(reserve1) + 997 * amountFrom);
        }

        uint amount0 = token0 != from ? amountTo : 0;
        uint amount1 = token1 != from ? amountTo : 0;

        IERC20(from).transfer(pair, amountFrom);
        IUniswapV2Pair(pair).swap(amount0, amount1, address(this), "");
    }

    function uniswapV2Call(
        address sender,
        uint amount0,
        uint amount1,
        bytes calldata data
    ) external override {
        require(amount0 == 0 || amount1 == 0, "We want get only wETH in this contract");

        address token0 = IUniswapV2Pair(msg.sender).token0();
        address token1 = IUniswapV2Pair(msg.sender).token1();
        require(token0 == wETH || token1 == wETH, "We want swap wETH in this contract");

        address pair = IUniswapV2Factory(UNISWAP_V2_FACTORY).getPair(token0, token1);
        require(msg.sender == pair, "Message sender not tokens pair");
        require(address(this) == sender, "Sender not equal this address");

        (address borrow) = abi.decode(data, (address));
        require(borrow != wETH, "We want swap wETH in this contract");

        uint amount = amount0 + amount1;
        this.logState(borrow);

        amount = this.runSwap(wETH, LINK, amount);
        this.logState(borrow);
        amount = this.runSwap(LINK, DAI, amount);
        this.logState(borrow);
        amount = this.runSwap(DAI, wETH, amount);
        this.logState(borrow);

        // about 0.3% fee, +1 to round up
        uint fee = (amount * 3) / 997 + 1;
        uint amountToRepay = amount + fee;
        IERC20(borrow).transfer(pair, amountToRepay);
        this.logState(borrow);
    }
}
