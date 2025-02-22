import React, { useState } from 'react';
import { Web3Provider } from '@ethersproject/providers';
import { useWeb3React } from '@web3-react/core';
import { InjectedConnector } from '@web3-react/injected-connector';
import dynamic from 'next/dynamic';

const PoolInterface = dynamic(() => import('../components/PoolInterface'), {
  ssr: false,
});

const injected = new InjectedConnector({
  supportedChainIds: [1337], // Tura testnet
});

export default function Home() {
  const { account, activate, active, chainId } = useWeb3React();
  const [loading, setLoading] = useState(false);

  const connectWallet = async () => {
    try {
      await activate(injected);
    } catch (error) {
      console.error('Error connecting wallet:', error);
    }
  };

  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-4xl font-bold mb-8">Uniswap V3 Pool Interface</h1>
      
      {!active ? (
        <button
          onClick={connectWallet}
          className="bg-blue-500 text-white px-4 py-2 rounded"
        >
          Connect Wallet
        </button>
      ) : (
        <div>
          <p className="mb-4">Connected Account: {account}</p>
          <PoolInterface />
        </div>
      )}
    </div>
  );
}
