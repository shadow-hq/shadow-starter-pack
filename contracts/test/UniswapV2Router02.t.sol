// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.6.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/UniswapV2Router02/contracts/UniswapV2Router02.sol";

contract UniswapV2Router02Test is Test {
    event Trade(
        string project,
        string version,
        TokenAmount tokenA,
        TokenAmount tokenB,
        uint256 amountUsd,
        address taker,
        address maker,
        address exchangeContractAddress
    );

    struct TokenAmount {
        address tokenAddress;
        string symbol;
        uint256 decimals;
        uint256 amount;
    }

    function testSwapExactTokensForETH_emitsTrade() public {
        // Replay transaction: 0x833f712deda53fa12f632de4c03d2e3110a0539d2fc2b709cd305f5943eb3321
        IUniswapV2Router02 router = deployAtBlock(17724607);
        address msgSender = address(0x351307bf5b6B3FecCf0f325536626E90093a7BC2);

        // Tokens and amounts
        address tokenIn = address(0x9732EE9a44938cce991Ba4dE5F86BB4aFC18b6aD);
        address tokenOut = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
        uint256 amountIn = 26534189234151358333689522;
        uint256 amountOutMin = 257924828650822463;
        uint256 amountOutExpected = 260662035875015518;

        // Set up the VM
        vm.startPrank(msgSender);
        IERC20(tokenIn).approve(address(router), amountIn);

        // Construct arguments
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;

        // Expect the Trade event to be emitted
        vm.expectEmit(address(router));
        emit Trade(
            "uniswap",
            "v2",
            TokenAmount(tokenIn, "PAUL", 18, amountIn),
            TokenAmount(tokenOut, "WETH", 18, amountOutExpected),
            498335242,
            address(0x351307bf5b6B3FecCf0f325536626E90093a7BC2),
            address(0x30B486075dcd057B4959cF1aAf733870cbe936c8),
            address(router)
        );

        // Execute the swap
        router.swapExactTokensForETH(amountIn, amountOutMin, path, msgSender, 1689739559);
    }

    function deployAtBlock(uint256 blockNumber) internal returns (IUniswapV2Router02 router) {
        // Set up the VM at the block
        vm.createSelectFork(vm.envString("ETH_RPC_URL"), blockNumber);

        // Build constructor arguments and bytecode
        address factory = address(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
        address weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
        bytes memory args = abi.encode(factory, weth);
        bytes memory bytecode = abi.encodePacked(vm.getCode("UniswapV2Router02.sol:UniswapV2Router02"), args);

        // Deploy
        address deployed;
        assembly {
            deployed := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        router = IUniswapV2Router02(deployed);
    }
}
