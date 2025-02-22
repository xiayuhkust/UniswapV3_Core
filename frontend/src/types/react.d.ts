/// <reference types="react" />

declare module 'react' {
  export type FC<P = {}> = React.FunctionComponent<P>;
  export type ChangeEvent<T> = React.ChangeEvent<T>;
  export const useState: typeof React.useState;
  export const useCallback: typeof React.useCallback;
  interface CSSProperties {
    [key: string]: any;
  }

  interface AriaAttributes {
    [key: string]: any;
  }

  interface DOMAttributes<T> {
    children?: React.ReactNode;
    dangerouslySetInnerHTML?: {
      __html: string;
    };
    onClick?: (event: React.MouseEvent<T>) => void;
    onChange?: (event: React.ChangeEvent<T>) => void;
  }

  interface HTMLAttributes<T> extends AriaAttributes, DOMAttributes<T> {
    className?: string;
  }

  interface InputHTMLAttributes<T> extends HTMLAttributes<T> {
    type?: string;
    value?: string | number;
    placeholder?: string;
    onChange?: (event: React.ChangeEvent<HTMLInputElement>) => void;
  }

  interface ButtonHTMLAttributes<T> extends HTMLAttributes<T> {
    onClick?: (event: React.MouseEvent<HTMLButtonElement>) => void;
    disabled?: boolean;
  }

  interface JSX {
    IntrinsicElements: {
      div: HTMLAttributes<HTMLDivElement>;
      button: ButtonHTMLAttributes<HTMLButtonElement>;
      input: InputHTMLAttributes<HTMLInputElement>;
      label: HTMLAttributes<HTMLLabelElement>;
      h1: HTMLAttributes<HTMLHeadingElement>;
      h2: HTMLAttributes<HTMLHeadingElement>;
      p: HTMLAttributes<HTMLParagraphElement>;
    };
  }
}
