// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import "forge-std/Test.sol";
import "../../contracts/lesson2/ConstantProductPool.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 1000000 ether);
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract ConstantProductPoolTest is Test {
    ConstantProductPool pool;
    TestERC20 token0;
    TestERC20 token1;
    address user = address(1);

    function setUp() public {
        // Deploy test tokens
        token0 = new TestERC20("Token0", "TK0");
        token1 = new TestERC20("Token1", "TK1");

        // Deploy pool
        pool = new ConstantProductPool(address(token0), address(token1));

        // Setup initial liquidity
        token0.transfer(address(pool), 100 ether);
        token1.transfer(address(pool), 100 ether);
        pool._update(100 ether, 100 ether);

        // Setup test user
        token0.transfer(user, 10 ether);
        token1.transfer(user, 10 ether);
    }

    function testSwap() public {
        vm.startPrank(user);
        uint256 amountIn = 1 ether;
        token0.transfer(address(pool), amountIn);
        
        uint256 expectedOut = pool.getOutputAmount(amountIn, 100 ether, 100 ether);
        pool.swap(amountIn, 0, user);

        (uint256 reserve0, uint256 reserve1) = pool.getReserves();
        assertEq(reserve0, 101 ether);
        assertTrue(reserve1 < 100 ether);
        vm.stopPrank();
    }

    function testFailZeroInput() public {
        pool.swap(0, 0, user);
    }

    function testFailInsufficientLiquidity() public {
        pool.swap(1000000 ether, 0, user);
    }
}
