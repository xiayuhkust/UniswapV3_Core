# Lesson 42: Overview of ERC721 - Learning Notes

## Core Concepts (核心概念)

### ERC721 Standard (ERC721标准)
1. Key Differences from ERC20 (与ERC20的主要区别)
   - Non-fungible tokens (非同质化代币)
   - Unique token IDs (唯一代币ID)
   - Extended ownership tracking (扩展所有权跟踪)

2. Token Properties (代币属性)
   - Unique identification (唯一标识)
   - Individual ownership (个人所有权)
   - Metadata support (元数据支持)

### Token Metadata (代币元数据)
1. Off-chain Storage (链下存储)
   - JSON metadata format (JSON元数据格式)
   - External asset links (外部资产链接)
   - URI-based access (基于URI的访问)

2. On-chain Storage (链上存储)
   - Template-based storage (基于模板的存储)
   - SVG image format (SVG图像格式)
   - Data URI encoding (数据URI编码)

## Technical Implementation Details (技术实现细节)

### ERC721 Interface (ERC721接口)
```solidity
interface IERC721 {
    // Core functions (核心函数)
    function balanceOf(address owner) external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
    function transferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address);
    function setApprovalForAll(address operator, bool approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    // Metadata extension (元数据扩展)
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
```

### Metadata Implementation (元数据实现)
```solidity
// Off-chain metadata (链下元数据)
function tokenURI(uint256 tokenId) public view returns (string memory) {
    require(_exists(tokenId), "Token does not exist");
    return string(
        abi.encodePacked(
            baseURI,
            tokenId.toString()
        )
    );
}

// On-chain metadata (链上元数据)
function tokenURI(uint256 tokenId) public view returns (string memory) {
    require(_exists(tokenId), "Token does not exist");
    
    // Generate metadata JSON (生成元数据JSON)
    string memory json = Base64.encode(
        bytes(string(abi.encodePacked(
            '{"name":"Position #',
            tokenId.toString(),
            '","description":"Uniswap V3 LP Position",',
            '"image":"data:image/svg+xml;base64,',
            Base64.encode(bytes(generateSVG(tokenId))),
            '"}'
        )))
    );

    return string(
        abi.encodePacked(
            'data:application/json;base64,',
            json
        )
    );
}
```

### SVG Generation (SVG生成)
```solidity
function generateSVG(uint256 tokenId) internal view returns (string memory) {
    Position memory position = positions[tokenId];
    
    return string(
        abi.encodePacked(
            '<svg width="290" height="500" viewBox="0 0 290 500" xmlns="http://www.w3.org/2000/svg">',
            '<rect width="290" height="500" fill="',
            position.color,
            '"/>',
            '<text x="32" y="64" fill="white">',
            position.token0Symbol,
            '/',
            position.token1Symbol,
            '</text>',
            '<text x="32" y="120" fill="white">',
            'Fee tier: ',
            uint2str(position.fee),
            '</text>',
            '</svg>'
        )
    );
}
```

### Token Management (代币管理)
```solidity
contract ERC721Token is IERC721 {
    // Token data (代币数据)
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Mint function (铸造函数)
    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0), "Invalid recipient");
        require(!_exists(tokenId), "Token already exists");

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    // Transfer function (转账函数)
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal {
        require(ownerOf(tokenId) == from, "Not token owner");
        require(to != address(0), "Invalid recipient");

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }
}
```

## Test Coverage (测试覆盖)

### Test Cases (测试用例)
1. Token Operations (代币操作)
   ```solidity
   function testTokenOperations() public {
       // Mint token (铸造代币)
       token.mint(address(this), 1);
       assertEq(token.ownerOf(1), address(this));

       // Transfer token (转账代币)
       token.transferFrom(address(this), user, 1);
       assertEq(token.ownerOf(1), user);
   }
   ```

2. Metadata Handling (元数据处理)
   ```solidity
   function testMetadataHandling() public {
       // Mint token (铸造代币)
       token.mint(address(this), 1);

       // Verify metadata (验证元数据)
       string memory uri = token.tokenURI(1);
       assertTrue(bytes(uri).length > 0);
   }
   ```

### Test Setup (测试设置)
```solidity
// Test parameters (测试参数)
address user = address(1);
ERC721Token token;

// Setup function (设置函数)
function setUp() public {
    token = new ERC721Token();
}
```

## Next Steps (下一步)
- Implement NFT manager (实现NFT管理器)
- Add NFT renderer (添加NFT渲染器)
- Integrate with liquidity positions (与流动性头寸集成)

## Environment Prerequisites (环境先决条件)
- Solidity ^0.8.14 (使用Solidity ^0.8.14)
- OpenZeppelin contracts (OpenZeppelin合约)
- Base64 encoding library (Base64编码库)
