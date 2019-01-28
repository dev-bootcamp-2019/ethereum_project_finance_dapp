const SimpleStorage = artifacts.require("SimpleStorage");

contract("SimpleStorage", accounts => {
  it("...should store the value 89.", async () => {
    const simpleStorageInstance = await SimpleStorage.deployed();

    // Set value of 89
    await simpleStorageInstance.set(89, { from: accounts[0] });

    // Get stored value
    const storedData = await simpleStorageInstance.storedData.call();

    assert.equal(storedData, 89, "The value 89 was not stored.");
  });
});

const ProjectDelivery = artifacts.require("ProjectDelivery");

contract("ProjectDelivery", accounts => {
  it("...project count should be the value 1.", async () => {
    const projectDeliveryInstance = await ProjectDelivery.deployed();


    // Get stored value
    const projectCount = await projectDeliveryInstance.projectCount.call();

    assert.equal(projectCount, 1, "The initial project count is not 1.");
  });
});