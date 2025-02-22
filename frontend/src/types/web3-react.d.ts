import { AbstractConnector } from '@web3-react/abstract-connector';
import { Web3Provider } from '@ethersproject/providers';

declare module '@web3-react/core' {
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
}

declare module 'react' {
  interface HTMLAttributes<T> extends AriaAttributes, DOMAttributes<T> {
    className?: string;
  }
}
