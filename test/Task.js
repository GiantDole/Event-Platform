const Task = artifacts.require("Task");
// const { assert } = require("console");
const utils = require("./helpers/utils");

contract("Task", (accounts) => {
    let [owner, other, organizer, assignee, applicant1, applicant2] = accounts;

    let contractInstance;
    beforeEach(async () => {
        _name = 'Important Task #1'
        _desc = 'We need to do a very exciting task!'
        _idCount = 0;
        _budgetPerUnit = 1;
        _progressUnits = 4;
        contractInstance = await Task.new( _name, _desc, _idCount, _budgetPerUnit, _progressUnits, {from: owner});
        await contractInstance.addOrganizer(organizer, {from: owner});
    });

    context( "check that basic organizer functionality is inherited", async () => {
    // note that organizer functionality is tested seprately in Organizer.js. This is just one simple test to check inheritance.
        it("should set owner (sender) as organizer as well", async () => {
            const ownerIsOrganizer = await contractInstance.isOrganizer(owner);
            const otherIsOrganizer = await contractInstance.isOrganizer(other);
            assert.equal(ownerIsOrganizer, true);
            assert.equal(otherIsOrganizer, false);
        })
    })

    context( "check application functionality", async () => {

        beforeEach(async () => {
            await contractInstance.applyTo({from: applicant1});
            await contractInstance.applyTo({from: applicant2});
        });

        it("check that applyTo adds sender to applicant list", async () => {  
            const applicants = await contractInstance.viewApplicants({from: owner});
            assert.equal( applicants.length, 2);
            // let indicator = 0;
            // for( let i=0; i<applicants.length; i++) {
            //     if (applicants[i] == applicant1) {
            //         indicator++;
            //     }
            // }
            // assert.equal(indicator, 2);
        })
        it("check that owner can view applicants", async () => {
            const applicants = await contractInstance.viewApplicants({from: owner});
            assert.equal(applicants.length, 2);
        })
        it("check that organizer can view applicants", async () => {
            const applicants = await contractInstance.viewApplicants({from: organizer});
            assert.equal(applicants.length, 2);
        })
        it("check that non-organizer CANNOT view applicants", async () => {
            await utils.shouldThrow(contractInstance.viewApplicants({from: other}));
        })
        it("check that applicants cannot view other applicants", async () => {
            await utils.shouldThrow(contractInstance.viewApplicants({from: applicant1}));
        })
        it("check that withdrawApplication removes the applicant from the list", async () => {
            await contractInstance.withdrawApplication({from: applicant1});
            const applicants = await contractInstance.viewApplicants({from: organizer});
            assert.equal(applicants.length, 1);
        })
        it("check that acceptApplicant sets the applicant to approved", async () => {
            await contractInstance.acceptApplicant(applicant1, {from: organizer});
            const approved = await contractInstance.approved();
            assert.equal(approved, applicant1);
        })
        it("check that non-organizer CANNOT approve an applicant", async () => {
            await contractInstance.acceptApplicant(applicant1, {from: organizer});
            const approved = await contractInstance.approved();
            assert.equal(approved, applicant1);
        })
        it("check that approved applicant can accept the assignment", async () => {
            await contractInstance.acceptApplicant(applicant1, {from: organizer});
            await contractInstance.acceptAssignment({from: applicant1});
            const assigned = await contractInstance.assignment();
            assert.equal(assigned, applicant1);
        })
        it("check that non-approved applicant CANNOT accept the assignment", async () => {
            await contractInstance.acceptApplicant(applicant1, {from: organizer});
            utils.shouldThrow(contractInstance.acceptAssignment({from: applicant2}));
        })
    })

    context( "check task progress interactions", async () => {
        beforeEach(async () => {
            await contractInstance.applyTo({from: assignee});
            await contractInstance.acceptApplicant(assignee, {from: organizer});
            await contractInstance.acceptAssignment({from: assignee});
        });
        it("check that progress gets updated when updateProgress() called by assignee", async () => {
            assert.equal(contractInstance.completedUnits() == 0);
            await contractInstance.updateProgress(1, {from: assignee});
            assert.equal(contractInstance.completedUnits() == 1);
        })
        it("check that progress remains unapproved until organizer approves it", async () => {
            await contractInstance.updateProgress(1, {from: assignee});
            assert.equal(contractInstance.approvedUnits() == 0);
            await contractInstance.approveProgress({from: organizer});
            assert.equal(contractInstance.approvedUnits() == 1);
        })
        it("check that progress CANNOT be updated by non-organizer or non-assignee", async () => {
            utils.shouldThrow(contractInstance.updateProgress({from: other}));
        })
        it("check that progress gets updated AND approved when updateProgress() called by organizer", async () => {
            await contractInstance.updateProgress(1, {from: organizer});
            assert.equal(contractInstance.completedUnits() == 1);
            assert.equal(contractInstance.approvedUnits() == 1);
        })
        it("check that progress CANNOT be approved by non-organizer", async () => {
            await contractInstance.updateProgress(1, {from: assignee});
            utils.shouldThrow(contractInstance.approveProgress({from: other}));
            utils.shouldThrow(contractInstance.approveProgress({from: assignee}));
        })
    })

})
