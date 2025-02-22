import { Contract } from '@ethersproject/contracts';
import { Web3Provider } from '@ethersproject/providers';

// ABI imports will be added later when we have the final contract ABIs
const POOL_ABI = [];
const TOKEN_ABI = [];

export const TURA_CHAIN_ID = 1337;
export const RPC_URL = 'https://rpc-beta1.turablockchain.com';

export const TEST_TOKENS = {
  WETH: '0xF0e8a104Cc6ecC7bBa4Dc89473d1C64593eA69be',
  TT1: '0x3F26F01Fa9A5506c9109B5Ad15343363909fc0b9',
  TT2: '0x8FDCE0D41f0A99B5f9FbcFAfd481ffcA61d01122',
};

export function getPoolContract(address: string, library: Web3Provider) {
  return new Contract(address, POOL_ABI, library.getSigner());
}

export function getTokenContract(address: string, library: Web3Provider) {
  return new Contract(address, TOKEN_ABI, library.getSigner());
}
