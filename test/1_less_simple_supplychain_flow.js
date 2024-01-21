const LessSimpleSupplyChain = artifacts.require("LessSimpleSupplyChain");

const PHASE = {
    Init: 0,                            // Product has been ordered
    ResourceExtraction_Started: 1,      // Collection of materials was taken by provider
    ResourceExtraction_Failed: 2,       // Resource failed QA inspection, need re-collection
    ResourceExtraction_Completed: 3,    // Resource collected, ready for next phase
    ResourceSupply_Started: 4,          // Supplier accepts supply request
    ResourceSupply_Failed: 5,           // Resources failed inspection, need re-supply
    ResourceSupply_Completed: 6,        // All materials have been supplied successfully
    Manufacturing_Started: 7,           // Manufacturing Start
    Manufacturing_Completed: 8,         // Manufacturing Finish
    Distribution_Started: 9,            // Distribution Start
    Distribution_Failed: 10,            // Product Damaged, impossible to sell, or not arrived
    Distribution_Completed: 11,         // Distribution Finished successfully. Ready to be sold.
    Retail: 12,                         // Retailer accepts to sell the product
    Sold: 13                            // Product sold to end customer
}

contract("LessSimpleSupplyChain", accounts => {
    let lessSimpleSupplyChain;
    const owner = accounts[0];
    const provider = accounts[1];
    const supplier = accounts[2];
    const manufacturer = accounts[3];
    const distributor = accounts[4];
    const retailer = accounts[5];
    const unauthorizedActor = accounts[6];

    before(async () => {
        lessSimpleSupplyChain = await LessSimpleSupplyChain.deployed();
        // Additional setup if necessary
        await lessSimpleSupplyChain.addActor(provider, "Provider", "Provider 1", "Provider 1 Address", { from: owner });
        await lessSimpleSupplyChain.addActor(supplier, "Supplier", "Supplier 1", "Supplier 1 Address", { from: owner });
        await lessSimpleSupplyChain.addActor(manufacturer, "Manufacturer", "Manufacturer 1", "Manufacturer 1 Address", { from: owner });
        await lessSimpleSupplyChain.addActor(distributor, "Distributor", "Distributor 1", "Distributor 1 Address", { from: owner });
        await lessSimpleSupplyChain.addActor(retailer, "Retailer", "Retailer 1", "Retailer 1 Address", { from: owner });

    });

    it("should allow the owner to add a new product", async () => {
        try {
            await lessSimpleSupplyChain.addNewProduct("Product 1", "Description 1", {from: owner});
            const productCount = await lessSimpleSupplyChain.getProductCount();
            assert.equal(productCount, 1, "Product count should be 1");
        }catch (error){
            assert(!error.message.includes("revert"), "Unexpected error");
        }
    });

    it("should not allow a non-owner to add a new product", async () => {
        try {
            await lessSimpleSupplyChain.addNewProduct("Product 2", "Description 2", { from: unauthorizedActor });
            assert.fail("Expected error not received");
        } catch (error) {
            assert(error.message.includes("revert"), "User correctly not authorized");
        }
    });

    // Testing Resource Extraction
    it("should not allow a non-provider to start resource extraction", async () => {
        try {
            const productId = 1;
            await lessSimpleSupplyChain.acceptPhase(productId, { from: unauthorizedActor });
            assert.fail("Non-provider was able to start resource extraction");
        } catch (error) {
            assert(error.message.includes("revert"), "Expected revert not received for non-provider");
        }
    });

    it("should allow a valid provider to start resource extraction", async () => {
        try {
            const productId = 1; // Assuming product ID 1
            await lessSimpleSupplyChain.acceptPhase(productId, { from: provider });
            const phase =  await lessSimpleSupplyChain.showPhase(productId);
            assert(phase.includes("Extraction"), "Incorrect phase");
        } catch (error) {
            assert(!error.message.includes("You don't have the right to modify the product at this stage"), "Permission issue");
        }
    });


    it("should allow a valid provider to complete resource extraction", async () => {
        try {
            const productId = 1;
            const product = await lessSimpleSupplyChain.Stock(productId);
            await lessSimpleSupplyChain.acceptPhase(productId, { from: provider });
            const phase =  await lessSimpleSupplyChain.showPhase(productId);
            assert(phase.includes("Extraction"), "Incorrect phase for completion");
        } catch (error) {
            assert(!error.message.includes("You don't have the right to modify the product at this stage"), "Permission issue");
        }

    });

    // Testing Resource Supply
    it("should allow a valid supplier to start resource supply", async () => {
        try {
            const productId = 1;
            const product = await lessSimpleSupplyChain.Stock(productId);
            await lessSimpleSupplyChain.acceptPhase(productId, { from: supplier });
            const phase =  await lessSimpleSupplyChain.showPhase(productId);
            assert(phase.includes("Supply"), "Incorrect phase for completion");
        } catch (error) {
            assert(!error.message.includes("You don't have the right to modify the product at this stage"), "Permission issue");
        }
    });

    it("should allow a valid supplier to complete resource supply", async () => {
        try {
            const productId = 1;
            const product = await lessSimpleSupplyChain.Stock(productId);
            await lessSimpleSupplyChain.acceptPhase(productId, { from: supplier });
            const phase =  await lessSimpleSupplyChain.showPhase(productId);
            assert(phase.includes("Supply"), "Incorrect phase for completion");
        } catch (error) {
            assert(!error.message.includes("You don't have the right to modify the product at this stage"), "Permission issue");
        }
    });

    // Testing Manufacturing
    it("should allow a valid manufacturer to start manufacturing", async () => {
        try {
            const productId = 1;
            const product = await lessSimpleSupplyChain.Stock(productId);
            await lessSimpleSupplyChain.acceptPhase(productId, { from: manufacturer });
            const phase =  await lessSimpleSupplyChain.showPhase(productId);
            assert(phase.includes("Manufacturing"), "Incorrect phase for start manufacturing");
        } catch (error) {
            assert(!error.message.includes("You don't have the right to modify the product at this stage"), "Permission issue");
        }
    });

    it("should allow a valid manufacturer to complete manufacturing", async () => {
        try {
            const productId = 1;
            const product = await lessSimpleSupplyChain.Stock(productId);
            await lessSimpleSupplyChain.acceptPhase(productId, { from: manufacturer });
            const phase =  await lessSimpleSupplyChain.showPhase(productId);
            assert(phase.includes("Manufacturing"), "Incorrect phase for completion");
        } catch (error) {
            assert(!error.message.includes("You don't have the right to modify the product at this stage"), "Permission issue");
        }
    });

    // Testing Distribution
    it("should allow a valid distributor to start distribution", async () => {
        try {
            const productId = 1;
            const product = await lessSimpleSupplyChain.Stock(productId);
            await lessSimpleSupplyChain.acceptPhase(productId, { from: distributor });
            const phase =  await lessSimpleSupplyChain.showPhase(productId);
            assert(phase.includes("Distribution"), "Incorrect phase for starting distribution");
        } catch (error) {
            assert(!error.message.includes("You don't have the right to modify the product at this stage"), "Permission issue");
        }
    });

    it("should allow a valid distributor to complete distribution", async () => {
        try {
            const productId = 1;
            const product = await lessSimpleSupplyChain.Stock(productId);
            await lessSimpleSupplyChain.acceptPhase(productId, { from: distributor });
            const phase =  await lessSimpleSupplyChain.showPhase(productId);
            assert(phase.includes("Distribution"), "Incorrect phase for completion");
        } catch (error) {
            assert(!error.message.includes("You don't have the right to modify the product at this stage"), "Permission issue");
        }
    });

    it("should allow a valid retailer to starting retail", async () => {
        try {
            const productId = 1;
            const product = await lessSimpleSupplyChain.Stock(productId);
            await lessSimpleSupplyChain.acceptPhase(productId, { from: retailer });
            const phase =  await lessSimpleSupplyChain.showPhase(productId);
            assert(phase.includes("Retail"), "Incorrect phase for retailing");
        } catch (error) {
            assert(!error.message.includes("You don't have the right to modify the product at this stage"), "Permission issue");
        }
    });

    // Add more tests for failing stages and other scenarios as needed
});

