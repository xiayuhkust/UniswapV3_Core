# Lesson 44: NFT Renderer - Learning Notes

## Core Concepts (核心概念)

### NFT Rendering (NFT渲染)
1. Token URI Implementation (代币URI实现)
   - JSON metadata (JSON元数据)
   - SVG template (SVG模板)
   - Base64 encoding (Base64编码)

2. Visual Components (视觉组件)
   - Background colors (背景颜色)
   - Token symbols (代币符号)
   - Position details (头寸详情)
   - Tick values (刻度值)

## Technical Implementation Details (技术实现细节)

### NFT Renderer Library (NFT渲染器库)
```solidity
library NFTRenderer {
    // Render parameters (渲染参数)
    struct RenderParams {
        address pool;
        address owner;
        int24 lowerTick;
        int24 upperTick;
        uint24 fee;
    }

    // Main render function (主渲染函数)
    function render(
        RenderParams memory params
    ) internal view returns (string memory) {
        // Get pool tokens (获取池代币)
        IUniswapV3Pool pool = IUniswapV3Pool(params.pool);
        IERC20 token0 = IERC20(pool.token0());
        IERC20 token1 = IERC20(pool.token1());
        string memory symbol0 = token0.symbol();
        string memory symbol1 = token1.symbol();

        // Generate SVG (生成SVG)
        string memory image = string.concat(
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 300 480">',
            renderStyle(),
            renderBackground(params.owner, params.lowerTick, params.upperTick),
            renderTop(symbol0, symbol1, params.fee),
            renderBottom(params.lowerTick, params.upperTick),
            '</svg>'
        );

        // Generate description (生成描述)
        string memory description = renderDescription(
            symbol0,
            symbol1,
            params.fee,
            params.lowerTick,
            params.upperTick
        );

        // Generate JSON (生成JSON)
        string memory json = string.concat(
            '{"name":"Uniswap V3 Position",',
            '"description":"',
            description,
            '",',
            '"image":"data:image/svg+xml;base64,',
            Base64.encode(bytes(image)),
            '"}'
        );

        // Return encoded URI (返回编码URI)
        return string.concat(
            "data:application/json;base64,",
            Base64.encode(bytes(json))
        );
    }
}
```

### SVG Components (SVG组件)
```solidity
// Style definition (样式定义)
function renderStyle() internal pure returns (string memory) {
    return string.concat(
        '<style>',
        '.tokens { font: bold 30px sans-serif; }',
        '.fee { font: normal 26px sans-serif; }',
        '.tick { font: normal 18px sans-serif; }',
        '</style>'
    );
}

// Background rendering (背景渲染)
function renderBackground(
    address owner,
    int24 lowerTick,
    int24 upperTick
) internal pure returns (string memory) {
    // Generate unique hue (生成唯一色调)
    bytes32 key = keccak256(
        abi.encodePacked(owner, lowerTick, upperTick)
    );
    uint256 hue = uint256(key) % 360;

    return string.concat(
        '<rect width="300" height="480" fill="hsl(',
        Strings.toString(hue),
        ',40%,40%)" />',
        '<rect x="30" y="30" width="240" height="420" rx="15" ry="15" ',
        'fill="hsl(',
        Strings.toString(hue),
        ',90%,50%)" stroke="#000" />'
    );
}

// Top section rendering (顶部部分渲染)
function renderTop(
    string memory symbol0,
    string memory symbol1,
    uint24 fee
) internal pure returns (string memory) {
    return string.concat(
        '<rect x="30" y="87" width="240" height="42" />',
        '<text x="39" y="120" class="tokens" fill="#fff">',
        symbol0,
        '/',
        symbol1,
        '</text>',
        '<rect x="30" y="132" width="240" height="30" />',
        '<text x="39" y="120" dy="36" class="fee" fill="#fff">',
        feeToText(fee),
        '</text>'
    );
}

// Bottom section rendering (底部部分渲染)
function renderBottom(
    int24 lowerTick,
    int24 upperTick
) internal pure returns (string memory) {
    return string.concat(
        '<rect x="30" y="342" width="240" height="24" />',
        '<text x="39" y="360" class="tick" fill="#fff">Lower tick: ',
        tickToText(lowerTick),
        '</text>',
        '<rect x="30" y="372" width="240" height="24" />',
        '<text x="39" y="360" dy="30" class="tick" fill="#fff">Upper tick: ',
        tickToText(upperTick),
        '</text>'
    );
}
```

### Helper Functions (辅助函数)
```solidity
// Fee text conversion (费用文本转换)
function feeToText(
    uint24 fee
) internal pure returns (string memory) {
    if (fee == 500) {
        return "0.05%";
    } else if (fee == 3000) {
        return "0.3%";
    } else if (fee == 10000) {
        return "1%";
    }
    return "Invalid fee";
}

// Tick text conversion (刻度文本转换)
function tickToText(
    int24 tick
) internal pure returns (string memory) {
    return string.concat(
        tick < 0 ? "-" : "",
        tick < 0
            ? Strings.toString(uint256(uint24(-tick)))
            : Strings.toString(uint256(uint24(tick)))
    );
}

// Description rendering (描述渲染)
function renderDescription(
    string memory symbol0,
    string memory symbol1,
    uint24 fee,
    int24 lowerTick,
    int24 upperTick
) internal pure returns (string memory) {
    return string.concat(
        symbol0,
        "/",
        symbol1,
        " ",
        feeToText(fee),
        ", Lower tick: ",
        tickToText(lowerTick),
        ", Upper tick: ",
        tickToText(upperTick)
    );
}
```

### Integration with NFT Manager (与NFT管理器集成)
```solidity
contract UniswapV3NFTManager is ERC721 {
    // Token URI implementation (代币URI实现)
    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        TokenPosition memory tokenPosition = positions[tokenId];
        if (tokenPosition.pool == address(0x00)) 
            revert WrongToken();

        IUniswapV3Pool pool = IUniswapV3Pool(tokenPosition.pool);

        return NFTRenderer.render(
            NFTRenderer.RenderParams({
                pool: tokenPosition.pool,
                owner: address(this),
                lowerTick: tokenPosition.lowerTick,
                upperTick: tokenPosition.upperTick,
                fee: pool.fee()
            })
        );
    }
}
```

## Test Coverage (测试覆盖)

### Test Cases (测试用例)
1. Token URI Generation (代币URI生成)
   ```solidity
   function testTokenURIGeneration() public {
       // Create position (创建头寸)
       uint256 tokenId = createPosition();

       // Get token URI (获取代币URI)
       string memory uri = nftManager.tokenURI(tokenId);

       // Verify URI format (验证URI格式)
       assertTokenURI(
           uri,
           "tokenuri0",
           "invalid token URI"
       );
   }
   ```

2. SVG Rendering (SVG渲染)
   ```solidity
   function testSVGRendering() public {
       // Setup render params (设置渲染参数)
       NFTRenderer.RenderParams memory params = NFTRenderer.RenderParams({
           pool: address(pool),
           owner: address(this),
           lowerTick: TICK_LOWER,
           upperTick: TICK_UPPER,
           fee: FEE
       });

       // Render SVG (渲染SVG)
       string memory svg = NFTRenderer.render(params);

       // Verify SVG content (验证SVG内容)
       assertTrue(
           bytes(svg).length > 0,
           "SVG should not be empty"
       );
   }
   ```

### Test Setup (测试设置)
```solidity
// Test parameters (测试参数)
uint24 constant FEE = 3000;  // 0.3%
int24 constant TICK_LOWER = -887272;
int24 constant TICK_UPPER = 887272;

// Custom assertion (自定义断言)
function assertTokenURI(
    string memory actual,
    string memory expectedFixture,
    string memory errMessage
) internal {
    string memory expected = vm.readFile(
        string.concat("./test/fixtures/", expectedFixture)
    );
    assertEq(actual, string(expected), errMessage);
}

// Setup function (设置函数)
function setUp() public {
    // Deploy contracts (部署合约)
    token0 = new ERC20Mock();
    token1 = new ERC20Mock();
    factory = new UniswapV3Factory();
    nftManager = new UniswapV3NFTManager(address(factory));
}
```

## Next Steps (下一步)
- Deploy contracts (部署合约)
- Test in production (生产环境测试)
- Monitor performance (监控性能)

## Environment Prerequisites (环境先决条件)
- Solidity ^0.8.14 (使用Solidity ^0.8.14)
- OpenZeppelin Base64 (OpenZeppelin Base64)
- OpenZeppelin Strings (OpenZeppelin Strings)
