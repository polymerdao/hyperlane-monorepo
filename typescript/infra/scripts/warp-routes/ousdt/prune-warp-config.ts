import chalk from 'chalk';
import yargs from 'yargs';

import {
  TokenStandard,
  WarpCoreConfig,
  parseTokenConnectionId,
} from '@hyperlane-xyz/sdk';

import { WarpRouteIds } from '../../../config/environments/mainnet3/warp/warpIds.js';
import { getRegistry } from '../../../config/registry.js';

const collateralChains = ['celo', 'ethereum'];
const chainsToPrune = [
  'worldchain',
  'ronin',
  'bitlayer',
  'linea',
  'mantle',
  'sonic',
];

function pruneProdConfig({ tokens, options }: WarpCoreConfig): WarpCoreConfig {
  const prunedTokens = tokens.map((token) => {
    if (chainsToPrune.includes(token.chainName)) {
      return { ...token, connections: undefined };
    }
    if (token.connections) {
      const filteredConnections = token.connections.filter((connection) => {
        const { chainName } = parseTokenConnectionId(connection.token);
        return !chainsToPrune.includes(chainName);
      });
      return { ...token, connections: filteredConnections };
    }
    return token;
  });
  return { tokens: prunedTokens, options };
}

async function main() {
  const { environment } = await yargs(process.argv.slice(2))
    .describe('environment', 'ousdt env')
    .choices('environment', ['staging', 'prod'])
    .demandOption('environment')
    .alias('e', 'environment').argv;

  const isStaging = environment === 'staging';

  const registry = getRegistry();

  const warpRouteId = isStaging ? WarpRouteIds.oUSDTSTAGE : WarpRouteIds.oUSDT;
  const warpRoute = registry.getWarpRoute(warpRouteId);
  if (!warpRoute) {
    throw new Error(`Warp route ${warpRouteId} not found`);
  }

  const prunedWarpRoute = isStaging ? warpRoute : pruneProdConfig(warpRoute);

  // Ensure the token configs are set
  prunedWarpRoute.tokens.forEach((token) => {
    if (collateralChains.includes(token.chainName)) {
      token.coinGeckoId = 'tether';
      token.name = 'USDT';
      token.symbol = 'USD₮';
      token.standard = TokenStandard.EvmHypVSXERC20Lockbox;
      token.logoURI = isStaging
        ? undefined
        : '/deployments/warp_routes/USDT/logo.svg';
    } else {
      token.name = 'OpenUSDT';
      token.symbol = isStaging ? 'oUSDTSTAGE' : 'oUSDT';
      token.standard = TokenStandard.EvmHypVSXERC20;
      token.logoURI = isStaging
        ? undefined
        : '/deployments/warp_routes/oUSDT/logo.svg';
    }
  });

  try {
    registry.addWarpRoute(prunedWarpRoute, {
      warpRouteId,
    });
  } catch (error) {
    console.error(
      chalk.red(`Failed to add warp route for ${warpRouteId}:`, error),
    );
  }

  // TODO: Use registry.getWarpRoutesPath() to dynamically generate path by removing "protected"
  console.log(
    chalk.green(
      `Warp Route successfully updated at ${registry.getUri()}/deployments/warp_routes/${warpRouteId}-config.yaml`,
    ),
  );
}

main().catch((err) => console.error(chalk.bold.red('Error:', err)));
