/// <reference types="react" />

declare module '@web3-react/core' {
  export interface AbstractConnector {
    activate: () => Promise<{
      provider: any;
      chainId: number;
      account: string;
    }>;
    deactivate: () => void;
  }

  export interface Web3ReactContextInterface<T = any> {
    activate: (connector: AbstractConnector) => Promise<void>;
    active: boolean;
    account: string | null;
    chainId?: number;
    library?: T;
    deactivate: () => void;
    error?: Error;
    connector?: AbstractConnector;
  }

  export function useWeb3React<T = any>(): Web3ReactContextInterface<T>;
  export class Web3ReactProvider extends React.Component<{
    getLibrary: (provider: any) => any;
    children: React.ReactNode;
  }> {}
}

declare module '@web3-react/injected-connector' {
  import { AbstractConnector } from '@web3-react/core';
  
  export class InjectedConnector extends AbstractConnector {
    constructor(kwargs: { supportedChainIds: number[] });
    public activate(): Promise<{
      provider: any;
      chainId: number;
      account: string;
    }>;
    public deactivate(): void;
  }
}
