const SupplyChain = artifacts.require("ISupplyChain");
const LessSimpleSupplyChain = artifacts.require("LessSimpleSupplyChain");

module.exports = function (deployer) {
    deployer.deploy(SupplyChain);
    deployer.deploy(LessSimpleSupplyChain);
};
