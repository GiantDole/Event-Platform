const Task = artifacts.require("Task");
const utils = require("./helpers/utils");

contract("Task", (accounts) => {
    let [owner, other, organizer, assignee, approved, applicant] = accounts;

    let contractInstance;
    beforeEach(async () => {
        contractInstance = await Task.new({from: owner});
    });

    context( "check that basic organizer functionality is inherited (note that organizer functionality is tested seprately in Organizer.js)")
    it("should set owner (sender) as organizer as well", async () => {
        const ownerIsOrganizer = await contractInstance.isOrganizer(owner);
        const otherIsOrganizer = await contractInstance.isOrganizer(other);
        assert.equal(ownerIsOrganizer, true);
        assert.equal(otherIsOrganizer, false);
    })

    xcontext( "check application functionality")
    xit("check that application leads to applicant being added to applicant list", async () => {
        await contractInstance.apply(organizer, {from: owner}); 
    })

    xcontext("adding an organizer", async () => {
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

    xcontext("changing owner", async () => {
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

    xcontext("removing organizers", async () => {
        it("should successfully remove an organizer: called by owner", async() => {
            await contractInstance.addOrganizer(organizer, {from: owner});
            assert.equal(await contractInstance.isOrganizer(organizer), true);
            await contractInstance.removeOrganizer(organizer, {from: owner});
            assert.equal(await contractInstance.isOrganizer(organizer), false);
        })

        it("should not remove organizer: not called by owner", async() => {
            await contractInstance.addOrganizer(organizer, {from: owner});
            await contractInstance.addOrganizer(other, {from: owner});
            assert.equal(await contractInstance.isOrganizer(organizer), true);
            assert.equal(await contractInstance.isOrganizer(other), true);
            await utils.shouldThrow(contractInstance.removeOrganizer(organizer, {from: other}));
        })

        it("should not remove organizer: is owner", async() => {
            await contractInstance.addOrganizer(organizer, {from: owner});
            await contractInstance.addOrganizer(other, {from: owner});
            assert.equal(await contractInstance.isOrganizer(organizer), true);
            assert.equal(await contractInstance.isOrganizer(other), true);
            await utils.shouldThrow(contractInstance.removeOrganizer(owner, {from: owner}));
        })
    })

})
