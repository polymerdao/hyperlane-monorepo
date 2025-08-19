module.exports = {
  networks: {
    // Dynamic network configuration using environment variables
    // Use RPC_URL and PRIVATE_KEY environment variables
    // Example: RPC_URL=https://api.trongrid.io PRIVATE_KEY=your_key tronbox migrate --network dynamic
    dynamic: {
      privateKey: process.env.PRIVATE_KEY,
      userFeePercentage: 100,
      feeLimit: 1000 * 1e6,
      fullHost: process.env.RPC_URL || 'https://nile.trongrid.io',
      network_id: '*', // Match any network id
    },
    // Legacy network configurations (kept for backwards compatibility)
    mainnet: {
      privateKey: process.env.PRIVATE_KEY_MAINNET || process.env.PRIVATE_KEY,
      userFeePercentage: 100,
      feeLimit: 1000 * 1e6,
      fullHost: 'https://api.trongrid.io',
      network_id: '1',
    },
    shasta: {
      privateKey: process.env.PRIVATE_KEY_SHASTA || process.env.PRIVATE_KEY,
      userFeePercentage: 50,
      feeLimit: 1000 * 1e6,
      fullHost: 'https://api.shasta.trongrid.io',
      network_id: '2',
    },
    nile: {
      privateKey: process.env.PRIVATE_KEY_NILE || process.env.PRIVATE_KEY,
      userFeePercentage: 100,
      feeLimit: 1000 * 1e6,
      fullHost: 'https://nile.trongrid.io',
      network_id: '3',
    },
    development: {
      privateKey:
        '0000000000000000000000000000000000000000000000000000000000000001',
      userFeePercentage: 0,
      feeLimit: 1000 * 1e6,
      fullHost: 'http://127.0.0.1:9090',
      network_id: '9',
    },
  },
  compilers: {
    solc: {
      version: '0.8.6',
      // An object with the same schema as the settings entry in the Input JSON.
      // See https://docs.soliditylang.org/en/latest/using-the-compiler.html#input-description
      settings: {
        optimizer: {
          enabled: true,
          runs: 200,
        },
        // evmVersion: 'istanbul',
        // viaIR: true,
      },
    },
  },
};
