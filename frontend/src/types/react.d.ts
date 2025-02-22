import 'react';

declare module 'react' {
  interface CSSProperties {
    [key: string]: any;
  }

  interface HTMLAttributes<T> extends AriaAttributes, DOMAttributes<T> {
    className?: string;
  }

  interface InputHTMLAttributes<T> extends HTMLAttributes<T> {
    type?: string;
    value?: string | number;
    placeholder?: string;
    onChange?: (event: ChangeEvent<HTMLInputElement>) => void;
  }

  interface ButtonHTMLAttributes<T> extends HTMLAttributes<T> {
    onClick?: (event: MouseEvent<HTMLButtonElement>) => void;
    disabled?: boolean;
  }
}
