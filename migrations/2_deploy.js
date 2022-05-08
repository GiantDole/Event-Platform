const TaskFactory = artifacts.require("TaskFactory");

module.exports = function(deployer) {
    deployer.deploy(TaskFactory);
};