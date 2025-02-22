/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  swcMinify: true,
  env: {
    RPC_URL: 'https://rpc-beta1.turablockchain.com',
    CHAIN_ID: '1337'
  }
}

module.exports = nextConfig
