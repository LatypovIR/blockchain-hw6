const { ethers } = require('hardhat');
const { expect } = require("chai");

const USDC = '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48';
const wETH = '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2';

const BANK_AMOUNT = 10000;
const BORROW_AMOUNT = 9000;

describe("Uniswap", function () {
  
  let usdc
  let weth
  let owner
  let testFlashSwap
  this.beforeEach(async () => {
    usdc = await ethers.getContractAt('IERC20', USDC);
    weth = await ethers.getContractAt('IERC20', wETH);
    [owner,] = await ethers.getSigners();
    
    expect(await usdc.balanceOf(owner.address) >= BANK_AMOUNT, 
                                  "Not enough money. Please restart fork :-)");
                                  
    let TestFlashSwap = await ethers.getContractFactory('TestFlashSwap');
    testFlashSwap = await TestFlashSwap.deploy();

    await usdc.transfer(testFlashSwap.address, BANK_AMOUNT, {from: owner.address});
  })

  async function logState(address) {
    let usdcBalance = await usdc.balanceOf(address);
    let wethBalance = await weth.balanceOf(address);
    console.log("    For [%s] has USDC = [%d], wETH = [%d]", address, usdcBalance, wethBalance);
  }

  it("Flash swapped", async function () {

    await logState(testFlashSwap.address);
    console.log("    \nStart flash swap");
    await testFlashSwap.runFlashSwap(usdc.address, BORROW_AMOUNT, {from: owner.address});
    console.log("    Finished flash swap\n");
    await logState(testFlashSwap.address);

    let usdcBalance = await usdc.balanceOf(testFlashSwap.address);
    let wethBalance = await weth.balanceOf(testFlashSwap.address);
    expect((BANK_AMOUNT - BORROW_AMOUNT) * 0.997 + 1 >= usdcBalance, "We should pay fee");
    expect(BORROW_AMOUNT >= wethBalance, "You can get no more than BORROW amount");
  });
});
