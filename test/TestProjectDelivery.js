const ProjectDelivery = artifacts.require("ProjectDelivery");

contract("ProjectDelivery", accounts => {
  it("...project count should be the value 1.", async () => {
    const projectDeliveryInstance = await ProjectDelivery.deployed();


    // Get stored value
    const projectCount = await projectDeliveryInstance.projectCount.call();

    assert.equal(projectCount, 1, "The initial project count is not 1.");
  });
  
  it("...the contract should be unpaused.", async () => {
    const projectDeliveryInstance = await ProjectDelivery.deployed();


    // Get stored value
    const isPaused = await projectDeliveryInstance.paused.call();

    assert.equal(isPaused, 0, "The initialized contract is not paused.");
  });
});