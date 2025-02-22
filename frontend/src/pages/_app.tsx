import type { AppProps } from 'next/app';
import { Web3ReactProvider } from '@web3-react/core';
import { Web3Provider } from '@ethersproject/providers';
import { InjectedConnector } from '@web3-react/injected-connector';
import '../styles/globals.css';

function getLibrary(provider: any): Web3Provider {
  const library = new Web3Provider(provider);
  library.pollingInterval = 12000;
  return library;
}

const injected = new InjectedConnector({
  supportedChainIds: [1337], // Tura testnet
});

function MyApp({ Component, pageProps }: AppProps) {
  return (
    <Web3ReactProvider getLibrary={getLibrary} connectors={[[injected, {}]]}>
      <Component {...pageProps} />
    </Web3ReactProvider>
  );
}

export default MyApp;
