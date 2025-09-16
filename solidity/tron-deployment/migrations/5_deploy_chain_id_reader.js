const ChainIdReader = artifacts.require('./ChainIdReader.sol');

module.exports = function (deployer) {
  deployer.deploy(ChainIdReader);
};