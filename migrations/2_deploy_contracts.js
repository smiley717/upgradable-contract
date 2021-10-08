const { deployProxy, upgradeProxy } = require('@openzeppelin/truffle-upgrades');

const UpgradableContract = artifacts.require('UpgradableContract');
const UpgradableContract2 = artifacts.require('UpgradableContract2');

module.exports = async function (deployer) {
  // const existing = await deployProxy(UpgradableContract, [], { deployer });
  // console.log("Deployed", existing.address);

  const existing = await UpgradableContract.deployed();
  const upgraded = await upgradeProxy(existing.address, UpgradableContract2, { deployer });
  console.log("Upgraded", upgraded.address);
}