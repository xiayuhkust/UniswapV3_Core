import type { AppProps } from 'next/app';
import { Web3ReactProvider } from '@web3-react/core';
import { providers } from 'ethers';
import '../styles/globals.css';

type GetLibrary = (provider: any) => providers.Web3Provider;

const getLibrary: GetLibrary = (provider) => {
  const library = new providers.Web3Provider(provider);
  library.pollingInterval = 12000;
  return library;
}

function MyApp({ Component, pageProps }: AppProps) {
  return (
    <Web3ReactProvider getLibrary={getLibrary}>
      <Component {...pageProps} />
    </Web3ReactProvider>
  );
}

export default MyApp;
