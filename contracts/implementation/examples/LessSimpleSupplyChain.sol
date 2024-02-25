// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../ISupplyChain.sol";

// Inherits Super Interface for a generic supply chain
contract LessSimpleSupplyChain is ISupplyChain{

    function _ensureStatePermissions(uint256 _caller, uint256 _productID, PHASE _phase) internal view returns(bool) {

        // If this state is a recover from a failure, then
        // we need to ensure the caller is the original provider
        if(Stock[_productID].phase == _phase) {
            return Stock[_productID].requireResponseBy == _caller;
        }
        // Else if the user is trying to complete a phase, we want to ensure
        // the actor is the same who started it
        else {
            // Ensure that the Provider is the same who started the extraction
            return Stock[_productID].lastModifiedBy == _caller;
        }

    }

    /*
    * This kind of supply chain supports all operations
    */

    function startResourceExtraction(uint256 _productID) override(ISupplyChain) public {
        // Ensure that the product ID is within the ones present in Stock (i.e., have been ordered)
        require(validateProductId(_productID), "The product is not in the Blockchain");
        // Ensure that the caller is a Provider
        (uint256 _id, bool _isValid) = isProvider();
        require(_isValid, "The user is not a registered provider");
        // Ensure that the product is in correct stage
        require(
            Stock[_productID].phase == PHASE.Init,
            "You don't have the right to modify the product at this stage"
        );
        // Finally, update product stage
        Stock[_productID].lastModifiedBy = _id;
        Stock[_productID].requireResponseBy = 0;
        Stock[_productID].phase = PHASE.ResourceExtraction_Started;
    }

    function completeResourceExtraction(uint256 _productID) override(ISupplyChain) public {
        // Ensure that the product ID is within the ones present in Stock (i.e., have been ordered)
        require(validateProductId(_productID), "The product is not in the Blockchain");
        // Ensure that the caller is a Provider
        (uint256 _id, bool _isValid) = isProvider();
        require(_isValid, "The user is not a registered provider");
        // Ensure that the product is in correct stage
        require(
            Stock[_productID].phase == PHASE.ResourceExtraction_Started ||
            Stock[_productID].phase == PHASE.ResourceExtraction_Failed,
            "You don't have the right to modify the product at this stage"
        );

        require(_ensureStatePermissions(_id, _productID, PHASE.ResourceExtraction_Failed), "Access Denied");

        Stock[_productID].lastModifiedBy = _id;
        Stock[_productID].requireResponseBy = 0;
        Stock[_productID].phase = PHASE.ResourceExtraction_Completed;
    }

    function failResourceExtraction(uint256 _productID) override(ISupplyChain) public{
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
        // The quality (or whatever else) of the materials was not compliant
        // Sending back to provider
        Stock[_productID].requireResponseBy =  Stock[_productID].lastModifiedBy;
        Stock[_productID].lastModifiedBy = _id;
        Stock[_productID].phase = PHASE.ResourceExtraction_Failed;
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
        /*
        ==============================================================================
        CUSTOMISATION SAMPLE: This code may be enabled if we want to make fail->pass
        interaction fixed. In the current implementation, if an actor supplied wrong
        resources, he is held responsible, but he is not bound to resend resources to
        the same actor.
        ==============================================================================

        // If this state was a recovery from a failed state, then the same
        // provider needs to confirm that the resources are good
        if(Stock[_productID].requireResponseBy != 0){
            require(Stock[_productID].requireResponseBy == _id, "Access Denied");
        }
        */

        // Finally, update product stage
        // The provider was confirmed to be the one who sent this resource set
        Stock[_productID].tracking.providerID = Stock[_productID].lastModifiedBy;
        Stock[_productID].lastModifiedBy = _id;
        Stock[_productID].requireResponseBy = 0;
        Stock[_productID].phase = PHASE.ResourceSupply_Completed;
    }
    function completeResourceSupply(uint256 _productID) override(ISupplyChain) public {
        // Ensure that the product ID is within the ones present in Stock (i.e., have been ordered)
        require(validateProductId(_productID), "The product is not in the Blockchain");
        // Ensure that the caller is a Supplier
        (uint256 _id, bool _isValid) = isSupplier();
        require(_isValid, "The user is not a registered manufacturer");
        // Ensure that the product is in correct stage
        require(
            Stock[_productID].phase == PHASE.ResourceSupply_Started ||
            Stock[_productID].phase == PHASE.ResourceSupply_Failed,
            "You don't have the right to modify the product at this stage"
        );

        require(_ensureStatePermissions(_id, _productID, PHASE.ResourceSupply_Failed), "Access Denied");

        // Finally, update product stage
        Stock[_productID].lastModifiedBy = _id;
        Stock[_productID].requireResponseBy = 0;
        Stock[_productID].phase = PHASE.ResourceSupply_Completed;
    }
    function failResourceSupply(uint256 _productID) override(ISupplyChain) public{
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
        // Supplied resources not compliant, back to supplier
        Stock[_productID].requireResponseBy = Stock[_productID].lastModifiedBy;

        // Finally, update product stage
        Stock[_productID].lastModifiedBy = _id;
        Stock[_productID].phase = PHASE.ResourceSupply_Failed;
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
        // The supplier is indeed the one that supplied this resource set
        Stock[_productID].tracking.supplierID = Stock[_productID].lastModifiedBy;

        // Finally, update product stage
        Stock[_productID].lastModifiedBy = _id;
        Stock[_productID].requireResponseBy = 0;
        Stock[_productID].phase = PHASE.Manufacturing_Started;
    }
    function completeManufacturing(uint256 _productID) override(ISupplyChain) public {
        // Ensure that the product ID is within the ones present in Stock (i.e., have been ordered)
        require(validateProductId(_productID), "The product is not in the Blockchain");
        // Ensure that the caller is a Manufacturer
        (uint256 _id, bool _isValid) = isManufacturer();
        require(_isValid, "The user is not a registered manufacturer");
        // Ensure that the product is in correct stage
        require(
            Stock[_productID].phase == PHASE.Manufacturing_Started,
            "You don't have the right to modify the product at this stage"
        );

        // Ensure that the Actor is the same who started the phase
        require(
        _id ==  Stock[_productID].lastModifiedBy,
        "The actor is not the same who started the phase");

        // Finally, update product stage
        Stock[_productID].lastModifiedBy = _id;
        Stock[_productID].requireResponseBy = 0;
        Stock[_productID].phase = PHASE.Manufacturing_Completed;
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
        // Manufacturer across the chain is confirmed to be latest to work on the product
        Stock[_productID].tracking.manufacturerID = Stock[_productID].lastModifiedBy;
        // Finally, update product stage
        Stock[_productID].lastModifiedBy = _id;
        Stock[_productID].requireResponseBy = 0;
        Stock[_productID].phase = PHASE.Distribution_Started;

    }
    function completeDistribution(uint256 _productID) override(ISupplyChain) public {
        // Ensure that the product ID is within the ones present in Stock (i.e., have been ordered)
        require(validateProductId(_productID), "The product is not in the Blockchain");
        // Ensure that the caller is a Manufacturer
        (uint256 _id, bool _isValid) = isDistributor();
        require(_isValid, "The user is not a registered manufacturer");
        // Ensure that the product is in correct stage
        // Ensure that the product is in correct stage
        require(
            Stock[_productID].phase == PHASE.Distribution_Started ||
            Stock[_productID].phase == PHASE.Distribution_Failed,
            "You don't have the right to modify the product at this stage"
        );

        require(_ensureStatePermissions(_id, _productID, PHASE.Distribution_Failed), "Access Denied");

        // Finally, update product stage
        Stock[_productID].lastModifiedBy = _id;
        Stock[_productID].requireResponseBy = 0;
        Stock[_productID].phase = PHASE.Distribution_Completed;
    }
    function failDistribution(uint256 _productID) override(ISupplyChain) public {
        // Ensure that the product ID is within the ones present in Stock (i.e., have been ordered)
        require(validateProductId(_productID), "The product is not in the Blockchain");
        // Ensure that the caller is a Manufacturer
        (uint256 _id, bool _isValid) = isDistributor();
        require(_isValid, "The user is not a registered manufacturer");
        // Ensure that the product is in correct stage
        require(
            Stock[_productID].phase == PHASE.Distribution_Started,
            "You don't have the right to modify the product at this stage"
        );
        // Finally, update product stage
        Stock[_productID].lastModifiedBy = _id;
        Stock[_productID].requireResponseBy = 0;
        Stock[_productID].phase = PHASE.Distribution_Completed;
    }


}