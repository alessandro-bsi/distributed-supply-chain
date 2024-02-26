// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "../ISupplyChain.sol";
import "./Metacoin.sol";

// Inherits Super Interface for a generic supply chain
contract MetacoinSupplyChain is ISupplyChain, Metacoin{

    uint256 priceOfExtraction = 55;
    uint256 priceOfOperations = 6;
    uint256 priceOfManifacturing = 6;
    uint256 priceOfDistribution = 7;
    uint256 priceOfRetail = 8;

    uint256 priceOfExtracted = 55;
    uint256 priceOfOperated = 7;
    uint256 priceOfManifactured = 6;
    uint256 priceOfDistributed = 6;
    uint256 priceOfRetailed = 5;    

    /*
    * This kind of supply chain supports only 5 operations
    * Each Actor just notifies the completion of its own step
    * Once the step is notified, the product goes to next stage
    */
	
	function addActor (
        address _ethAddress,
        string memory _role,
        string memory _name,
        string memory _businessAddress
    ) override(ISupplyChain) public onlyByOwner(){
        super.addActor(_ethAddress, _role, _name, _businessAddress);
		Metacoin.addWallet(_ethAddress);
	}
	
	
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
		address wallet = msg.sender;
		uint256 metacoins = Metacoin.howManyMetacoins(wallet);
		require(
            metacoins > uint256(priceOfExtraction),
            "You don't have enough metacoins"
        );
		Metacoin.payLabor(msg.sender, priceOfExtraction);
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
        address wallet = msg.sender;
		uint256 metacoins = Metacoin.howManyMetacoins(wallet);
		require(
            metacoins > uint256(priceOfOperations) + uint256(priceOfExtracted),
            "You don't have enough metacoins"
        );
		Metacoin.payLabor(msg.sender, priceOfOperations);
        Metacoin.sendCoin(getProviderById(Stock[_productID].lastModifiedBy).ethAddress,msg.sender, priceOfExtracted);
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
        address wallet = msg.sender;
		uint256 metacoins = Metacoin.howManyMetacoins(wallet);
		require(
            metacoins > uint256(priceOfManifacturing) + uint256(priceOfOperated),
            "You don't have enough metacoins"
        );
		Metacoin.payLabor(msg.sender, priceOfManifacturing);
        Metacoin.sendCoin(getProviderById(Stock[_productID].lastModifiedBy).ethAddress,msg.sender, priceOfOperated);
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
        address wallet = msg.sender;
		uint256 metacoins = Metacoin.howManyMetacoins(wallet);
		require(
            metacoins > uint256(priceOfDistribution),
            "You don't have enough metacoins"
        );
		Metacoin.payLabor(msg.sender, priceOfDistribution);
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
        function retail(uint256 _productID) override(ISupplyChain) public {
        // Ensure that the product ID is within the ones present in Stock (i.e., have been ordered)
        require(validateProductId(_productID), "The product is not in the Blockchain");
        // Ensure that the caller is a Retailer
        (uint256 _id, bool _isValid) = isRetailer();
        require(_isValid, "The user is not a registered retailer");
        // Ensure that the product is in correct stage
        require(Stock[_productID].phase == PHASE.Distribution_Completed, "You don't have the right to modify the product at this stage");
        address wallet = msg.sender;
		uint256 metacoins = Metacoin.howManyMetacoins(wallet);
		require(
            metacoins > uint256(priceOfRetail) + uint256(priceOfDistributed) + uint256(priceOfManifactured),
            "You don't have enough metacoins"
        );
		Metacoin.payLabor(msg.sender, priceOfManifacturing);
        Metacoin.sendCoin(getProviderById(Stock[_productID].lastModifiedBy).ethAddress,msg.sender, priceOfDistributed);
        Metacoin.sendCoin(getProviderById(Stock[_productID].Stock[_productID].tracking.manufacturerID).ethAddress,msg.sender, priceOfManifactured);
        // Mark the distributor
        Stock[_productID].tracking.distributorID = Stock[_productID].lastModifiedBy;
        // Mark latest modified by
        Stock[_productID].lastModifiedBy = _id;
        // Mark product as ready for retail
        Stock[_productID].phase = PHASE.Retail;

    }

    function sell(uint256 _productID) override(ISupplyChain) public {
        // Ensure that the product ID is within the ones present in Stock (i.e., have been ordered)
        require(validateProductId(_productID), "The product is not in the Blockchain");
        // Ensure that the caller is a Retailer
        (uint256 _id, bool _isValid) = isRetailer();
        require(_isValid, "The user is not a registered retailer");
        // Ensure that the product is in correct stage
        require(Stock[_productID].phase == PHASE.Retail, "You don't have the right to modify the product at this stage");
        Metacoin.sold(msg.sender, priceOfRetailed);
        // Mark the retailer as well
        Stock[_productID].tracking.retailerID = _id;
        // Mark latest modified by
        Stock[_productID].lastModifiedBy = _id;
        // Mark product as sold
        Stock[_productID].phase = PHASE.Sold;
    }


}