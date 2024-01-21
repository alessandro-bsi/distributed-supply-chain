// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "../ISupplyChain.sol";

// Inherits Super Interface for a generic supply chain
contract SimpleSupplyChain is ISupplyChain{
    /*
    * This kind of supply chain supports only 5 operations
    * Each Actor just notifies the completion of its own step
    * Once the step is notified, the product goes to next stage
    */
    function startResourceExtraction(uint256 _productID) override(ISupplyChain) public {
        // Ensure that the product ID is within the ones present in Stock (i.e., have been ordered)
        require(validateProductId(_productID), "The product is not in the Blockchain");
        // Ensure that the caller is a Provider
        (uint256 _id, bool _isValid) = isProvider();
        require(_isValid, "The user is not a registered provider");
        // Ensure that the product is in correct stage
        require(
            Stock[_productID].phase == PHASE.Init ||
            // This stage is not possible in this supply chain but it's kept for consistency
            Stock[_productID].phase == PHASE.ResourceExtraction_Failed,
            "You don't have the right to modify the product at this stage"
        );
        // Finally, update product stage
        Stock[_productID].lastModifiedBy = _id;
        Stock[_productID].requireResponseBy = 0;
        Stock[_productID].phase = PHASE.ResourceExtraction_Completed;
    }

    function completeResourceExtraction(uint256 _productID) override(ISupplyChain) public{
        // Same effect as startResourceExtraction
        startResourceExtraction(_productID);
    }

    function startResourceSupply(uint256 _productID) override(ISupplyChain) public {
        // Ensure that the product ID is within the ones present in Stock (i.e., have been ordered)
        require(validateProductId(_productID), "The product is not in the Blockchain");
        // Ensure that the caller is a Provider
        (uint256 _id, bool _isValid) = isSupplier();
        require(_isValid, "The user is not a registered supplier");
        // Ensure that the product is in correct stage
        require(
            Stock[_productID].phase == PHASE.ResourceExtraction_Completed,
            "You don't have the right to modify the product at this stage"
        );
        // Mark provider
        Stock[_productID].tracking.providerID = Stock[_productID].lastModifiedBy;

        // Finally, update product stage
        Stock[_productID].lastModifiedBy = _id;
        Stock[_productID].requireResponseBy = 0;
        Stock[_productID].phase = PHASE.ResourceSupply_Completed;
    }
    function completeResourceSupply(uint256 _productID) override(ISupplyChain) public {
        startResourceSupply(_productID);
    }

    function startManufacturing(uint256 _productID) override(ISupplyChain) public {
        // Ensure that the product ID is within the ones present in Stock (i.e., have been ordered)
        require(validateProductId(_productID), "The product is not in the Blockchain");
        // Ensure that the caller is a Manufacturer
        (uint256 _id, bool _isValid) = isManufacturer();
        require(_isValid, "The user is not a registered manufacturer");
        // Ensure that the product is in correct stage
        require(
            Stock[_productID].phase == PHASE.ResourceSupply_Completed,
            "You don't have the right to modify the product at this stage"
        );
        // Mark supplier
        Stock[_productID].tracking.supplierID = Stock[_productID].lastModifiedBy;

        // Finally, update product stage
        Stock[_productID].lastModifiedBy = _id;
        Stock[_productID].requireResponseBy = 0;
        Stock[_productID].phase = PHASE.Manufacturing_Completed;
    }
    function completeManufacturing(uint256 _productID) override(ISupplyChain) public {
        startManufacturing(_productID);
    }

    function startDistribution(uint256 _productID) override(ISupplyChain) public {
        // Ensure that the product ID is within the ones present in Stock (i.e., have been ordered)
        require(validateProductId(_productID), "The product is not in the Blockchain");
        // Ensure that the caller is a Manufacturer
        (uint256 _id, bool _isValid) = isDistributor();
        require(_isValid, "The user is not a registered manufacturer");
        // Ensure that the product is in correct stage
        require(
            Stock[_productID].phase == PHASE.Manufacturing_Completed,
            "You don't have the right to modify the product at this stage"
        );
        // Mark manufacturer
        Stock[_productID].tracking.manufacturerID = Stock[_productID].lastModifiedBy;

        // Finally, update product stage
        Stock[_productID].lastModifiedBy = _id;
        Stock[_productID].requireResponseBy = 0;
        Stock[_productID].phase = PHASE.Distribution_Completed;

    }
    function completeDistribution(uint256 _productID) override(ISupplyChain) public {
        startDistribution(_productID);
    }

}