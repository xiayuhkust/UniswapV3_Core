# Lesson 43: NFT Manager - Learning Notes

## Core Concepts (核心概念)

### NFT Manager Contract (NFT管理合约)
1. Purpose (目的)
   - Merge NFTs with liquidity positions (合并NFT和流动性头寸)
   - Manage position ownership (管理头寸所有权)
   - Handle liquidity operations (处理流动性操作)

2. Contract Structure (合约结构)
   - ERC721 implementation (ERC721实现)
   - Position tracking (头寸跟踪)
   - Factory integration (工厂集成)

### Position Management (头寸管理)
1. Position Data (头寸数据)
   ```solidity
   struct TokenPosition {
       address pool;
       int24 lowerTick;
       int24 upperTick;
   }
   ```

2. Storage Layout (存储布局)
   - Token ID mapping (代币ID映射)
   - Position tracking (头寸跟踪)
   - Supply management (供应管理)

## Technical Implementation Details (技术实现细节)

### Contract Implementation (合约实现)
```solidity
contract UniswapV3NFTManager is ERC721 {
    // State variables (状态变量)
    address public immutable factory;
    mapping(uint256 => TokenPosition) public positions;
    uint256 private nextTokenId;
    uint256 public totalSupply;

    // Constructor (构造函数)
    constructor(address factoryAddress) 
        ERC721("UniswapV3 NFT Positions", "UNIV3") 
    {
        factory = factoryAddress;
    }

    // Token URI (代币URI)
    function tokenURI(uint256 tokenId) 
        public 
        view 
        override 
        returns (string memory) 
    {
        return "";  // Implemented in NFT renderer
    }
}
```

### Minting Implementation (铸造实现)
```solidity
struct MintParams {
    address recipient;
    address tokenA;
    address tokenB;
    uint24 fee;
    int24 lowerTick;
    int24 upperTick;
    uint256 amount0Desired;
    uint256 amount1Desired;
    uint256 amount0Min;
    uint256 amount1Min;
}

function mint(MintParams calldata params)
    public
    returns (uint256 tokenId)
{
    // Get pool (获取池)
    IUniswapV3Pool pool = getPool(
        params.tokenA,
        params.tokenB,
        params.fee
    );

    // Add liquidity (添加流动性)
    (uint128 liquidity, uint256 amount0, uint256 amount1) = 
        _addLiquidity(AddLiquidityInternalParams({
            pool: pool,
            lowerTick: params.lowerTick,
            upperTick: params.upperTick,
            amount0Desired: params.amount0Desired,
            amount1Desired: params.amount1Desired,
            amount0Min: params.amount0Min,
            amount1Min: params.amount1Min
        }));

    // Mint NFT (铸造NFT)
    tokenId = nextTokenId++;
    _mint(params.recipient, tokenId);
    totalSupply++;

    // Store position (存储头寸)
    positions[tokenId] = TokenPosition({
        pool: address(pool),
        lowerTick: params.lowerTick,
        upperTick: params.upperTick
    });
}
```

### Liquidity Management (流动性管理)
```solidity
struct AddLiquidityParams {
    uint256 tokenId;
    uint256 amount0Desired;
    uint256 amount1Desired;
    uint256 amount0Min;
    uint256 amount1Min;
}

function addLiquidity(AddLiquidityParams calldata params)
    public
    returns (
        uint128 liquidity,
        uint256 amount0,
        uint256 amount1
    )
{
    // Verify token (验证代币)
    TokenPosition memory tokenPosition = positions[params.tokenId];
    if (tokenPosition.pool == address(0x00)) revert WrongToken();

    // Add liquidity (添加流动性)
    return _addLiquidity(AddLiquidityInternalParams({
        pool: IUniswapV3Pool(tokenPosition.pool),
        lowerTick: tokenPosition.lowerTick,
        upperTick: tokenPosition.upperTick,
        amount0Desired: params.amount0Desired,
        amount1Desired: params.amount1Desired,
        amount0Min: params.amount0Min,
        amount1Min: params.amount1Min
    }));
}

struct RemoveLiquidityParams {
    uint256 tokenId;
    uint128 liquidity;
}

function removeLiquidity(RemoveLiquidityParams memory params)
    public
    isApprovedOrOwner(params.tokenId)
    returns (uint256 amount0, uint256 amount1)
{
    // Verify token (验证代币)
    TokenPosition memory tokenPosition = positions[params.tokenId];
    if (tokenPosition.pool == address(0x00)) revert WrongToken();

    // Get pool (获取池)
    IUniswapV3Pool pool = IUniswapV3Pool(tokenPosition.pool);

    // Check liquidity (检查流动性)
    (uint128 availableLiquidity,,,,) = pool.positions(
        poolPositionKey(tokenPosition)
    );
    if (params.liquidity > availableLiquidity) 
        revert NotEnoughLiquidity();

    // Remove liquidity (移除流动性)
    return pool.burn(
        tokenPosition.lowerTick,
        tokenPosition.upperTick,
        params.liquidity
    );
}
```

### Token Collection (代币收集)
```solidity
struct CollectParams {
    uint256 tokenId;
    uint128 amount0;
    uint128 amount1;
}

function collect(CollectParams memory params)
    public
    isApprovedOrOwner(params.tokenId)
    returns (uint128 amount0, uint128 amount1)
{
    // Verify token (验证代币)
    TokenPosition memory tokenPosition = positions[params.tokenId];
    if (tokenPosition.pool == address(0x00)) revert WrongToken();

    // Get pool (获取池)
    IUniswapV3Pool pool = IUniswapV3Pool(tokenPosition.pool);

    // Collect tokens (收集代币)
    return pool.collect(
        msg.sender,
        tokenPosition.lowerTick,
        tokenPosition.upperTick,
        params.amount0,
        params.amount1
    );
}
```

### Token Burning (代币销毁)
```solidity
function burn(uint256 tokenId) 
    public 
    isApprovedOrOwner(tokenId)
{
    // Verify token (验证代币)
    TokenPosition memory tokenPosition = positions[tokenId];
    if (tokenPosition.pool == address(0x00)) revert WrongToken();

    // Check position (检查头寸)
    IUniswapV3Pool pool = IUniswapV3Pool(tokenPosition.pool);
    (
        uint128 liquidity,
        ,
        ,
        uint128 tokensOwed0,
        uint128 tokensOwed1
    ) = pool.positions(poolPositionKey(tokenPosition));

    // Verify empty position (验证空头寸)
    if (liquidity > 0 || tokensOwed0 > 0 || tokensOwed1 > 0)
        revert PositionNotCleared();

    // Burn token (销毁代币)
    delete positions[tokenId];
    _burn(tokenId);
    totalSupply--;
}
```

## Test Coverage (测试覆盖)

### Test Cases (测试用例)
1. NFT Management (NFT管理)
   ```solidity
   function testNFTManagement() public {
       // Setup parameters (设置参数)
       MintParams memory params = MintParams({
           recipient: address(this),
           tokenA: address(token0),
           tokenB: address(token1),
           fee: FEE,
           lowerTick: TICK_LOWER,
           upperTick: TICK_UPPER,
           amount0Desired: AMOUNT0,
           amount1Desired: AMOUNT1,
           amount0Min: 0,
           amount1Min: 0
       });

       // Mint NFT (铸造NFT)
       uint256 tokenId = nftManager.mint(params);
       assertEq(nftManager.ownerOf(tokenId), address(this));

       // Verify position (验证头寸)
       TokenPosition memory position = nftManager.positions(tokenId);
       assertEq(position.pool, address(pool));
       assertEq(position.lowerTick, TICK_LOWER);
       assertEq(position.upperTick, TICK_UPPER);
   }
   ```

2. Liquidity Operations (流动性操作)
   ```solidity
   function testLiquidityOperations() public {
       // Mint position (铸造头寸)
       uint256 tokenId = createPosition();

       // Add liquidity (添加流动性)
       AddLiquidityParams memory params = AddLiquidityParams({
           tokenId: tokenId,
           amount0Desired: AMOUNT0,
           amount1Desired: AMOUNT1,
           amount0Min: 0,
           amount1Min: 0
       });
       (uint128 liquidity,,) = nftManager.addLiquidity(params);

       // Remove liquidity (移除流动性)
       RemoveLiquidityParams memory removeParams = 
           RemoveLiquidityParams({
               tokenId: tokenId,
               liquidity: liquidity
           });
       (uint256 amount0, uint256 amount1) = 
           nftManager.removeLiquidity(removeParams);

       // Collect tokens (收集代币)
       CollectParams memory collectParams = CollectParams({
           tokenId: tokenId,
           amount0: uint128(amount0),
           amount1: uint128(amount1)
       });
       nftManager.collect(collectParams);

       // Burn token (销毁代币)
       nftManager.burn(tokenId);
   }
   ```

### Test Setup (测试设置)
```solidity
// Test parameters (测试参数)
uint24 constant FEE = 3000;  // 0.3%
int24 constant TICK_LOWER = -887272;
int24 constant TICK_UPPER = 887272;
uint256 constant AMOUNT0 = 1 ether;
uint256 constant AMOUNT1 = 1 ether;

// Setup function (设置函数)
function setUp() public {
    // Deploy tokens (部署代币)
    token0 = new ERC20Mock();
    token1 = new ERC20Mock();

    // Deploy factory (部署工厂)
    factory = new UniswapV3Factory();

    // Deploy NFT manager (部署NFT管理器)
    nftManager = new UniswapV3NFTManager(address(factory));
}
```

## Next Steps (下一步)
- Implement NFT renderer (实现NFT渲染器)
- Add token metadata (添加代币元数据)
- Create visual representation (创建视觉表示)

## Environment Prerequisites (环境先决条件)
- Solidity ^0.8.14 (使用Solidity ^0.8.14)
- Solmate ERC721 (Solmate ERC721)
- UniswapV3Factory contract (UniswapV3Factory合约)
