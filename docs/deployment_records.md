# Deployment Records

## Milestone 2 - Tick Bitmap Implementation
### Date: February 22, 2025

Network: Tura Testnet
- Chain ID: 1337
- RPC URL: https://rpc-beta1.turablockchain.com
- Owner: 0x08Bb6eA809A2d6c13D57166Fa3ede48C0ae9a70e

### Deployed Contracts
1. BitMath Library
   - Address: 0xE14F638eEc6E25517D7B0c270DabF43cdcAa3Ec1
   - Status: Successfully deployed and verified
   - Verification: Passed all test cases
   - Test Contract: 0x2Fd1Fcc4721D7e6621B2f5CAb90706Bfbc7de017

2. TickBitmap Library
   - Address: 0xC9FfACB6A1a38bA4428318093F08B954C9Cd471f
   - Status: Deployed but verification failed
   - Test Contract: 0x14a37237C54c063b9848a8c8a9b444F9e33017e6
   - Issues:
     * Tick initialization check failing in testFlipTick
     * Possible issue with tick spacing or bitmap position calculation

### Test Tokens Used
1. WETH (TuraWETH)
   - Address: 0xF0e8a104Cc6ecC7bBa4Dc89473d1C64593eA69be
   - Status: Available on network

2. Test Token 1 (TT1)
   - Address: 0x3F26F01Fa9A5506c9109B5Ad15343363909fc0b9
   - Status: Available on network

3. Test Token 2 (TT2)
   - Address: 0x8FDCE0D41f0A99B5f9FbcFAfd481ffcA61d01122
   - Status: Available on network

### Implementation Notes
1. Course Progression Issue:
   - Current implementation is part of Lesson 16 (Tick Bitmap Index)
   - Need to follow course progression from Milestone 1 first
   - Awaiting guidance on whether to continue or rollback

2. Verification Results:
   - BitMath library successfully verified with test cases
   - TickBitmap verification failed due to initialization issues
   - LSB and MSB calculations working as expected

3. Next Steps:
   - Review course progression and adjust implementation order
   - Debug TickBitmap initialization issues if continuing with current implementation
   - Consider rolling back to follow course sequence if required

### Known Issues
1. TickBitmap Initialization:
   - Error: "Tick should be initialized after flip"
   - Possible causes:
     * Incorrect tick spacing validation
     * Wrong bitmap position calculation
     * Issue with test implementation
   - Status: Unresolved, awaiting course progression guidance

