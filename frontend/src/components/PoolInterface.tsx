import React, { useState, useCallback } from 'react';
import type { FC, ChangeEvent } from 'react';
import { Web3Provider } from '@ethersproject/providers';
import { useWeb3React } from '@web3-react/core';
import { TEST_TOKENS } from '../utils/contracts';

interface TokenOption {
  address: string;
  symbol: string;
}

const tokenOptions: TokenOption[] = [
  { address: TEST_TOKENS.WETH, symbol: 'WETH' },
  { address: TEST_TOKENS.TT1, symbol: 'TT1' },
  { address: TEST_TOKENS.TT2, symbol: 'TT2' },
];

const PoolInterface: FC = () => {
  const { account, library } = useWeb3React();
  const [amount0, setAmount0] = useState('');
  const [amount1, setAmount1] = useState('');
  const [token0, setToken0] = useState<TokenOption>(tokenOptions[0]);
  const [token1, setToken1] = useState<TokenOption>(tokenOptions[1]);
  const [loading, setLoading] = useState(false);

  const handleSwap = useCallback(async () => {
    if (!library || !account) return;
    setLoading(true);
    try {
      const provider = library as Web3Provider;
      console.log('Swap initiated:', {
        token0: token0.symbol,
        token1: token1.symbol,
        amount0,
        amount1,
        provider
      });
    } catch (error) {
      console.error('Error:', error);
    } finally {
      setLoading(false);
    }
  }, [library, account, token0, token1, amount0, amount1]);

  const handleTokenSelect = useCallback((index: number, isToken0: boolean) => {
    const newToken = tokenOptions[index];
    if (isToken0) {
      setToken0(newToken);
      if (newToken.address === token1.address) {
        setToken1(token0);
      }
    } else {
      setToken1(newToken);
      if (newToken.address === token0.address) {
        setToken0(token1);
      }
    }
  }, [token0, token1]);

  return (
    <div className="max-w-lg mx-auto mt-8 p-6 bg-white rounded-lg shadow-lg">
      <h2 className="text-2xl font-bold mb-6">Swap Tokens</h2>
      
      <div className="space-y-6">
        <div className="space-y-2">
          <div className="flex justify-between items-center">
            <label className="block text-sm font-medium text-gray-700">From</label>
            <select
              value={tokenOptions.findIndex(t => t.address === token0.address)}
              onChange={(e: React.ChangeEvent<HTMLSelectElement>) => handleTokenSelect(Number(e.target.value), true)}
              className="ml-2 py-1 px-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              {tokenOptions.map((token, index) => (
                <option key={token.address} value={index}>
                  {token.symbol}
                </option>
              ))}
            </select>
          </div>
          <input
            type="number"
            value={amount0}
            onChange={(e: ChangeEvent<HTMLInputElement>) => setAmount0(e.target.value)}
            className="w-full px-4 py-2 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="0.0"
          />
        </div>

        <div className="flex justify-center">
          <button
            onClick={() => {
              const tempToken = token0;
              const tempAmount = amount0;
              setToken0(token1);
              setToken1(tempToken);
              setAmount0(amount1);
              setAmount1(tempAmount);
            }}
            className="p-2 rounded-full bg-gray-100 hover:bg-gray-200 focus:outline-none"
          >
            ↓↑
          </button>
        </div>

        <div className="space-y-2">
          <div className="flex justify-between items-center">
            <label className="block text-sm font-medium text-gray-700">To</label>
            <select
              value={tokenOptions.findIndex(t => t.address === token1.address)}
              onChange={(e: React.ChangeEvent<HTMLSelectElement>) => handleTokenSelect(Number(e.target.value), false)}
              className="ml-2 py-1 px-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              {tokenOptions.map((token, index) => (
                <option key={token.address} value={index}>
                  {token.symbol}
                </option>
              ))}
            </select>
          </div>
          <input
            type="number"
            value={amount1}
            onChange={(e: ChangeEvent<HTMLInputElement>) => setAmount1(e.target.value)}
            className="w-full px-4 py-2 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="0.0"
          />
        </div>

        <button
          onClick={handleSwap}
          disabled={loading || !account}
          className="w-full py-3 px-4 rounded-lg text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50 font-medium"
        >
          {loading ? 'Processing...' : 'Swap'}
        </button>
      </div>
    </div>
  );
};

export default PoolInterface;
