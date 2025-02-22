import { InjectedConnector } from '@web3-react/injected-connector';
import { Web3Provider } from '@ethersproject/providers';

declare module '@web3-react/core' {
  export interface Web3ReactContextInterface<T = any> {
    activate: (connector: InjectedConnector) => Promise<void>;
    active: boolean;
    account: string | null;
    chainId?: number;
    library?: Web3Provider;
  }
}
