const OrganizationManager = artifacts.require("OrganizationManager");
const utils = require("./helpers/utils");

contract("OrganizationManager", (accounts) => {
    let [owner, other, organizer] = accounts;

    let contractInstance;
    beforeEach(async () => {
        contractInstance = await OrganizationManager.new({from: owner});
    });


    it("should set owner (sender) as organizer as well", async () => {
        const ownerIsOrganizer = await contractInstance.isOrganizer(owner);
        const otherIsOrganizer = await contractInstance.isOrganizer(other);
        assert.equal(ownerIsOrganizer, true);
        assert.equal(otherIsOrganizer, false);
    })

    context("adding an organizer", async () => {
        it("should add an organizer: called by owner", async () => {
            await contractInstance.addOrganizer(organizer, {from: owner});
            const isOrganizer = await contractInstance.isOrganizer(organizer);
            assert.equal(isOrganizer, true);
        })

        it("should not add an organizer: called by another organizer", async() => {
            await contractInstance.addOrganizer(organizer, {from: owner});
            await utils.shouldThrow(contractInstance.addOrganizer(other, {from: organizer}));
        })
    })

    context("changing owner", async () => {
        it("should transfer ownership and add the new owner as organizer", async() => {
            assert.equal(await contractInstance.owner(), owner);
            await contractInstance.transferOwnership(organizer, {from: owner});
            const isOrganizer = await contractInstance.isOrganizer(organizer);
            assert.equal(isOrganizer, true);
            assert.equal(await contractInstance.owner(), organizer);
        })

        it("should not transfer ownership: called by another organizer", async() => {
            await contractInstance.addOrganizer(organizer, {from: owner});
            assert.equal(await contractInstance.isOrganizer(organizer), true);
            await utils.shouldThrow(contractInstance.transferOwnership(other, {from: organizer}));
        })
    })



})
