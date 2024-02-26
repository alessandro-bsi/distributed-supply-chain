// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Super Interface for a generic supply chain
contract ISupplyChain {
    // Smart Contract owner will be the person who deploys the
    // contract only he can authorize various roles like Retailer,
    // Manufacturer,etc
    address public Owner;

    // This constructor will be called when the smart contract
    // will be deployed on blockchain
    constructor() {
        Owner = msg.sender;
    }

    modifier onlyByOwner() {
        require(msg.sender == Owner);
        _;
    }

    /* =============================================
    **  STRUCTS & ENUMS
    ** ============================================= */
    // This tacking info is used to store information of the actors that completed each step
    // and produced the product till it-s finally sold to the customer
    // This structure is "OPTIONAL" and used to improve visibility.
    // Indeed, the tracking information may be just recovered using the transactions on the blockchain
    // related to a certain productID
    struct Tracking {
        uint256 providerID;
        uint256 supplierID;
        uint256 manufacturerID;
        uint256 distributorID;
        uint256 retailerID;
    }

    // The product structure is used to keep trac of an ordered product
    struct Product {
        uint256 id;                 // Product id (S/N)
        string  name;               // Product name
        string  description;        // Product description
        uint256 lastModifiedBy;     // Last Actor Id
        uint256 requireResponseBy;  // In case of exchange, it might bind he
        PHASE phase;                // Current Product Phase
        Tracking tracking;          // Final Tracking information
    }

    // The Actor struct defines basic information about supply chain actors
    struct Actor {
        address ethAddress;      // Node ETH address
        uint256 id;              // ID - Might be a P.IVA
        string  name;            // Actor Name (Company name)
        string  businessAddress; // Business Address
    }

    // Enumerator to keep track of current phase
    enum PHASE {
        Init,                           // Product has been ordered
        ResourceExtraction_Started,     // Collection of materials was taken by provider
        ResourceExtraction_Failed,      // Resource failed QA inspection, need re-collection
        ResourceExtraction_Completed,   // Resource collected, ready for next phase
        ResourceSupply_Started,         // Supplier accepts supply request
        ResourceSupply_Failed,          // Resources failed inspection, need re-supply
        ResourceSupply_Completed,       // All materials have been supplied successfully
        Manufacturing_Started,          // Manufacturing Start
        Manufacturing_Completed,        // Manufacturing Finish
        Distribution_Started,           // Distribution Start
        Distribution_Failed,            // Product Damaged, impossible to sell, or not arrived
        Distribution_Completed,         // Distribution Finished successfully. Ready to be sold.
        Retail,                         // Retailer accepts to sell the product
        Sold                            // Product sold to end customer
    }

    /* =============================================
    **  GLOBALS
    ** ============================================= */

    // Mappings
    // Store all products on the blockchain
    mapping(uint256 => Product) public Stock;
    // Export material logistic providers on the blockchain
    mapping(uint256 => Actor) public Providers;
    // Export suppliers on the blockchain
    mapping(uint256 => Actor) public Suppliers;
    // Export manufacturers on the blockchain
    mapping(uint256 => Actor) public Manufacturers;
    // Export distributors on the blockchain
    mapping(uint256 => Actor) public Distributors;
    // Export retailers on the blockchain
    mapping(uint256 => Actor) public Retailers;

    // Counters

    // Keeps Product count
    uint256 private _productCounter = 0;
    // Raw material provider count
    uint256 private _providersCounter = 0;
    // Raw material supplier count
    uint256 private _suppliersCounter = 0;
    // Manufacturer count
    uint256 private _manufacturersCounter = 0;
    // Distributor count
    uint256 private _distributorsCounter = 0;
    // Retailer count
    uint256 private _retailersCounter = 0;

    /* =============================================
    ** PRODUCT
    ** ============================================= */
    // Expose Method to get Product phase
    function getProductPhase(uint256 _productID) public view returns(PHASE phase) {
        require(_productID > 0 && _productID <= _providersCounter, "Invalid Product ID");
        return Stock[_productID].phase;
    }

    // Expose Method to get Product count
    function getProductCount() public view returns(uint256 count) {
        return _productCounter;
    }

    // Expose Method to get Products as an array
    function getProductsArray() public view returns(Product[] memory) {
        Product[] memory products = new Product[](_productCounter);
        for (uint256 i = 0; i < _productCounter; i++) {
            products[i] = Stock[i + 1];
        }
        return products;
    }

    // Expose Method to get Product by ID
    function getProductById(uint256 _productID) public view returns(Product memory) {
        require(validateProductId(_productID), "Invalid Product Id");
        return Stock[_productID];
    }

    // Expose Product order status to client applications
    function showPhase(uint256 _productID) public view returns (string memory)
    {
        require(_productID > 0 && _productID <= _productCounter, "Invalid Product ID");
        if (Stock[_productID].phase == PHASE.Init)
            return "Product Ordered";
        else if (
            Stock[_productID].phase == PHASE.ResourceExtraction_Started ||
            Stock[_productID].phase == PHASE.ResourceExtraction_Completed ||
            Stock[_productID].phase == PHASE.ResourceExtraction_Failed
        )
            return "Resource Extraction Phase";
        else if (
            Stock[_productID].phase == PHASE.ResourceSupply_Started ||
            Stock[_productID].phase == PHASE.ResourceSupply_Completed ||
            Stock[_productID].phase == PHASE.ResourceSupply_Failed
        )
            return "Resource Supply Phase";
        else if (
            Stock[_productID].phase == PHASE.Manufacturing_Started ||
            Stock[_productID].phase == PHASE.Manufacturing_Completed
        )
            return "Manufacturing Phase";
        else if (
            Stock[_productID].phase == PHASE.Distribution_Started ||
            Stock[_productID].phase == PHASE.Distribution_Completed ||
            Stock[_productID].phase == PHASE.Distribution_Failed
        )
            return "Distribution Phase";
        else if (Stock[_productID].phase == PHASE.Retail)
            return "Retail Phase";
        else if (Stock[_productID].phase == PHASE.Sold)
            return "Product Sold";
        else
            return "Unknown State";
    }

    /* =============================================
    ** ACTORS
    ** ============================================= */

    function getProvidersCount() public view returns(uint256 count) {
        return _providersCounter;
    }

    function getDistributorsCount() public view returns(uint256 count) {
        return _distributorsCounter;
    }

    function getSuppliersCount() public view returns(uint256 count) {
        return _suppliersCounter;
    }

    function getManufacturersCount() public view returns(uint256 count) {
        return _manufacturersCounter;
    }

    function getRetailersCount() public view returns(uint256 count) {
        return _retailersCounter;
    }

    // Expose Method to get Retailers as an array
    function getRetailersArray() public view returns(Actor[] memory) {
        Actor[] memory actors = new Actor[](_retailersCounter);
        for (uint256 i = 0; i < _retailersCounter; i++) {
            actors[i] = Retailers[i + 1];
        }
        return actors;
    }

    // Expose Method to get Suppliers as an array
    function getSuppliersArray() public view returns(Actor[] memory) {
        Actor[] memory actors = new Actor[](_suppliersCounter);
        for (uint256 i = 0; i < _suppliersCounter; i++) {
            actors[i] = Suppliers[i + 1];
        }
        return actors;
    }

    // Expose Method to get Manufacturers as an array
    function getManufacturersArray() public view returns(Actor[] memory) {
        Actor[] memory actors = new Actor[](_manufacturersCounter);
        for (uint256 i = 0; i < _manufacturersCounter; i++) {
            actors[i] = Manufacturers[i + 1];
        }
        return actors;
    }

    // Expose Method to get Providers as an array
    function getProvidersArray() public view returns(Actor[] memory) {
        Actor[] memory actors = new Actor[](_providersCounter);
        for (uint256 i = 0; i < _providersCounter; i++) {
            actors[i] = Providers[i + 1];
        }
        return actors;
    }

    // Expose Method to get Distributors as an array
    function getDistributorsArray() public view returns(Actor[] memory) {
        Actor[] memory actors = new Actor[](_distributorsCounter);
        for (uint256 i = 0; i < _distributorsCounter; i++) {
            actors[i] = Distributors[i + 1];
        }
        return actors;
    }

    function _addProvider(
        address _ethAddress,
        string memory _name,
        string memory _businessAddress
    ) private onlyByOwner() {
        _providersCounter++;
        Providers[_providersCounter] = Actor(_ethAddress, _providersCounter, _name, _businessAddress);
    }

    function _addSupplier(
        address _ethAddress,
        string memory _name,
        string memory _businessAddress
    ) private onlyByOwner() {
        _suppliersCounter++;
        Suppliers[_suppliersCounter] = Actor(_ethAddress, _suppliersCounter, _name, _businessAddress);
    }

    function _addManufacturer(
        address _ethAddress,
        string memory _name,
        string memory _businessAddress
    ) private onlyByOwner() {
        _manufacturersCounter++;
        Manufacturers[_manufacturersCounter] = Actor(_ethAddress, _manufacturersCounter, _name, _businessAddress);
    }

    function _addDistributor(
        address _ethAddress,
        string memory _name,
        string memory _businessAddress
    ) private onlyByOwner() {
        _distributorsCounter++;
        Distributors[_distributorsCounter] = Actor(_ethAddress, _distributorsCounter, _name, _businessAddress);
    }

    function _addRetailer(
        address _ethAddress,
        string memory _name,
        string memory _businessAddress
    ) private onlyByOwner() {
        _retailersCounter++;
        Retailers[_retailersCounter] = Actor(_ethAddress, _retailersCounter, _name, _businessAddress);
    }

    function _isRegistered(
        address _ethAddress
    ) private view onlyByOwner() returns(bool){
        uint256 _id = 0;
        bool _valid = false;
        if(atLeastOneDistributor()) {
            (_id, _valid) = _isDistributor(_ethAddress);
            if (_valid) return _valid;
        }
        if(atLeastOneRetailer()) {
            (_id, _valid) = _isRetailer(_ethAddress);
            if (_valid) return _valid;
        }
        if(atLeastOneManufacturer()) {
            (_id, _valid) = _isManufacturer(_ethAddress);
            if (_valid) return _valid;
        }
        if(atLeastOneSupplier()) {
            (_id, _valid) = _isSupplier(_ethAddress);
            if (_valid) return _valid;
        }
        if(atLeastOneProvider()) {
            (_id, _valid) = _isProvider(_ethAddress);
            if (_valid) return _valid;
        }

        return false;

    }

    function _addActor(
        address _ethAddress,
        string memory _role,
        string memory _name,
        string memory _businessAddress
    ) private onlyByOwner() {
        require(_isRegistered(_ethAddress) == false, "User Already Registered");

        if(keccak256(bytes(_role)) == keccak256(bytes("Provider"))){
            _addProvider(_ethAddress, _name, _businessAddress);
        } else if (keccak256(bytes(_role)) == keccak256(bytes("Supplier"))) {
            _addSupplier(_ethAddress, _name, _businessAddress);
        } else if (keccak256(bytes(_role)) == keccak256(bytes("Manufacturer"))) {
            _addManufacturer(_ethAddress, _name, _businessAddress);
        } else if (keccak256(bytes(_role)) == keccak256(bytes("Distributor"))) {
            _addDistributor(_ethAddress, _name, _businessAddress);
        } else if (keccak256(bytes(_role)) == keccak256(bytes("Retailer"))) {
            _addRetailer(_ethAddress, _name, _businessAddress);
        } else {
            revert("Unknown Role Specified");
        }
    }

    function addActor(
        address _ethAddress,
        string memory _role,
        string memory _name,
        string memory _businessAddress
    ) virtual public onlyByOwner(){

        _addActor(_ethAddress, _role, _name, _businessAddress);
    }

    function _updateSupplier(
        uint256 _id,
        string memory _name,
        string memory _businessAddress
    ) private {
        require(
            _id > 0 && _id < _manufacturersCounter,
            "No actor found that matches the specifications"
        );
        Actor memory actor = Suppliers[_id];
        require(
            msg.sender == Owner ||
            msg.sender == actor.ethAddress,
            "Unauthorized to update this actor"
        );
        if (
            keccak256(bytes(_name)) != keccak256(bytes(actor.name)) ||
			keccak256(bytes(_businessAddress)) != keccak256(bytes(actor.businessAddress))
			){
            Suppliers[_id].name = _name;
            Suppliers[_id].businessAddress = _businessAddress;
        }
    }
    function _updateManufacturer(
        uint256 _id,
        string memory _name,
        string memory _businessAddress
    ) private {
        require(
            _id > 0 && _id < _manufacturersCounter,
            "No actor found that matches the specifications"
        );
        Actor memory actor = Manufacturers[_id];
        require(
            msg.sender == Owner ||
            msg.sender == actor.ethAddress,
            "Unauthorized to update this actor"
        );
        if (
            keccak256(bytes(_name)) != keccak256(bytes(actor.name)) ||
			keccak256(bytes(_businessAddress)) != keccak256(bytes(actor.businessAddress))
			){
            Manufacturers[_id].name = _name;
            Manufacturers[_id].businessAddress = _businessAddress;
        }
    }
    function _updateProvider(
        uint256 _id,
        string memory _name,
        string memory _businessAddress
    ) private {
        require(_id > 0 && _id < _providersCounter, "No actor found that matches the specifications");
        Actor memory actor = Providers[_id];
        require(
            msg.sender == Owner ||
            msg.sender == actor.ethAddress,
            "Unauthorized to update this actor"
        );
        if (
            keccak256(bytes(_name)) != keccak256(bytes(actor.name)) ||
			keccak256(bytes(_businessAddress)) != keccak256(bytes(actor.businessAddress))
			){
            Providers[_id].name = _name;
            Providers[_id].businessAddress = _businessAddress;
        }
    }
    function _updateDistributor(
        uint256 _id,
        string memory _name,
        string memory _businessAddress
    ) private {
        require(_id > 0 && _id < _distributorsCounter, "No actor found that matches the specifications");
        Actor memory actor = Distributors[_id];
        require(
            msg.sender == Owner ||
            msg.sender == actor.ethAddress,
            "Unauthorized to update this actor"
        );
        if (
            keccak256(bytes(_name)) != keccak256(bytes(actor.name)) ||
			keccak256(bytes(_businessAddress)) != keccak256(bytes(actor.businessAddress))
			){
            Distributors[_id].name = _name;
            Distributors[_id].businessAddress = _businessAddress;
        }
    }
    function _updateRetailer(
        uint256 _id,
        string memory _name,
        string memory _businessAddress
    ) private {
        require(_id > 0 && _id < _retailersCounter, "No actor found that matches the specifications");
        Actor memory actor = Retailers[_id];
        require(
            msg.sender == Owner ||
            msg.sender == actor.ethAddress,
            "Unauthorized to update this actor"
        );
        if (
            keccak256(bytes(_name)) != keccak256(bytes(actor.name)) ||
			keccak256(bytes(_businessAddress)) != keccak256(bytes(actor.businessAddress))
			){
            Retailers[_id].name = _name;
            Retailers[_id].businessAddress = _businessAddress;
        }
    }

    function updateActor(
        address _ethAddress,
        string memory _role,
        string memory _name,
        string memory _businessAddress
    ) virtual public {
        uint256 _id;
        require(msg.sender == Owner || msg.sender == _ethAddress, "Access Denied");

        if(keccak256(bytes(_role)) == keccak256(bytes("Provider"))){
             _updateProvider(_id, _name, _businessAddress);
        } else if (keccak256(bytes(_role)) == keccak256(bytes("Supplier"))) {
            _updateSupplier(_id, _name, _businessAddress);
        } else if (keccak256(bytes(_role)) == keccak256(bytes("Manufacturer"))) {
            _updateManufacturer(_id, _name, _businessAddress);
        } else if (keccak256(bytes(_role)) == keccak256(bytes("Distributor"))) {
            _updateDistributor(_id, _name, _businessAddress);
        } else if (keccak256(bytes(_role)) == keccak256(bytes("Retailer"))) {
            _updateRetailer(_id, _name, _businessAddress);
        } else {
            revert("Unknown Role Specified");
        }
    }

    function getProviderById(uint256 _id) public view returns(Actor memory) {
        require(_providersCounter > 0);
        require(_id > 0 && _id <= _providersCounter, "Invalid actor ID");
        return Providers[_id];
    }
    function getSupplierById(uint256 _id) public view returns(Actor memory) {
        require(_suppliersCounter > 0);
        require(_id > 0 && _id <= _suppliersCounter, "Invalid actor ID");
        return Suppliers[_id];
    }
    function getManufacturerById(uint256 _id) public view returns(Actor memory) {
        require(_manufacturersCounter > 0);
        require(_id > 0 && _id <= _manufacturersCounter, "Invalid actor ID");
        return Manufacturers[_id];
    }
    function getDistributorById(uint256 _id) public view returns(Actor memory) {
        require(_distributorsCounter > 0);
        require(_id > 0 && _id <= _distributorsCounter, "Invalid actor ID");
        return Distributors[_id];
    }

    function getRetailerById(uint256 _id) public view returns(Actor memory) {
        require(_retailersCounter > 0);
        require(_id > 0 && _id <= _retailersCounter, "Invalid actor ID");
        return Retailers[_id];
    }

    function findRetailerByEthAddress(address _address) private view returns (uint256) {
        require(_retailersCounter > 0);
        for (uint256 i = 1; i <= _retailersCounter; i++) {
            if (Retailers[i].ethAddress == _address) return Retailers[i].id;
        }
        return 0;
    }

    function findActorByEthAddress(address _address) private view returns (uint256, string memory) {
        require(atLeastOneActor(), "No actor registered");

        uint256 actor = findRetailerByEthAddress(_address);
        if(actor > 0) return (actor, "Retailer");

        actor = findProviderByEthAddress(_address);
        if(actor > 0) return (actor, "Provider");

        actor = findSupplierByEthAddress(_address);
        if(actor > 0) return (actor, "Supplier");

        actor = findManufacturerByEthAddress(_address);
        if(actor > 0) return (actor, "Manufacturer");

        actor = findDistributorByEthAddress(_address);
        if(actor > 0) return (actor, "Distributor");

        return (0, "");
    }

    function findSupplierByEthAddress(address _address) private view returns (uint256) {
        require(_suppliersCounter > 0);
        for (uint256 i = 1; i <= _suppliersCounter; i++) {
            if (Suppliers[i].ethAddress == _address) return Suppliers[i].id;
        }
        return 0;
    }

    function findManufacturerByEthAddress(address _address) private view returns (uint256) {
        require(_manufacturersCounter > 0);
        for (uint256 i = 1; i <= _manufacturersCounter; i++) {
            if (Manufacturers[i].ethAddress == _address) return Manufacturers[i].id;
        }
        return 0;
    }

    function findProviderByEthAddress(address _address) private view returns (uint256) {
        require(_providersCounter > 0);
        for (uint256 i = 1; i <= _providersCounter; i++) {
            if (Providers[i].ethAddress == _address) return Providers[i].id;
        }
        return 0;
    }

    function findDistributorByEthAddress(address _address) private view returns (uint256) {
        require(_distributorsCounter > 0);
        for (uint256 i = 1; i <= _distributorsCounter; i++) {
            if (Distributors[i].ethAddress == _address) return Distributors[i].id;
        }
        return 0;
    }

    function atLeastOneRetailer() private view returns(bool){
        return _retailersCounter > 0;
    }

    function atLeastOneSupplier() private view returns(bool){
        return _suppliersCounter > 0;
    }

    function atLeastOneManufacturer() private view returns(bool){
        return _manufacturersCounter > 0;
    }

    function atLeastOneProvider() private view returns(bool){
        return _providersCounter > 0;
    }

    function atLeastOneDistributor() private view returns(bool){
        return _distributorsCounter > 0;
    }

    function atLeastOneActor() private view returns(bool){
        return (
            atLeastOneDistributor() &&
            atLeastOneManufacturer() &&
            atLeastOneProvider() &&
            atLeastOneSupplier() &&
            atLeastOneRetailer()
        );
    }

    function _validateProductId(uint256 _productID) private view returns(bool){
        return (_productID > 0 && _productID <= _productCounter);
    }

    function _isRetailer(address _ethAddress) private view returns(uint256, bool){
        uint256 _id = findRetailerByEthAddress(_ethAddress);
        return (_id, _id > 0);
    }

    function _isSupplier(address _ethAddress) private view returns(uint256, bool){
        uint256 _id = findSupplierByEthAddress(_ethAddress);
        return (_id, _id > 0);
    }

    function _isManufacturer(address _ethAddress) private view returns(uint256, bool){
        uint256 _id = findManufacturerByEthAddress(_ethAddress);
        return (_id, _id > 0);
    }

    function _isProvider(address _ethAddress) private view returns(uint256, bool){
        uint256 _id = findProviderByEthAddress(_ethAddress);
        return (_id, _id > 0);
    }

    function _isDistributor(address _ethAddress) private view returns(uint256, bool){
        uint256 _id = findDistributorByEthAddress(_ethAddress);
        return (_id, _id > 0);
    }

    function validateProductId(uint256 _productID) public view returns(bool){
        require(_productID > 0 && _productID <= _productCounter, "Invalid Product Id");
        return true;
    }

    function isRetailer() public view returns(uint256, bool){
        return _isRetailer(msg.sender);
    }

    function isSupplier() public view returns(uint256, bool){
        return _isSupplier(msg.sender);
    }

    function isManufacturer() public view returns(uint256, bool){
        return _isManufacturer(msg.sender);
    }

    function isProvider() public view returns(uint256, bool){
        return _isProvider(msg.sender);
    }

    function isDistributor() public view returns(uint256, bool){
        return _isDistributor(msg.sender);
    }

    /* =============================================
    ** Phase Update Functions
    ** ============================================= */
    function retail(uint256 _productID) public {
        // Ensure that the product ID is within the ones present in Stock (i.e., have been ordered)
        require(validateProductId(_productID), "The product is not in the Blockchain");
        // Ensure that the caller is a Retailer
        (uint256 _id, bool _isValid) = isRetailer();
        require(_isValid, "The user is not a registered retailer");
        // Ensure that the product is in correct stage
        require(Stock[_productID].phase == PHASE.Distribution_Completed, "You don't have the right to modify the product at this stage");
        // Mark the distributor
        Stock[_productID].tracking.distributorID = Stock[_productID].lastModifiedBy;
        // Mark latest modified by
        Stock[_productID].lastModifiedBy = _id;
        // Mark product as ready for retail
        Stock[_productID].phase = PHASE.Retail;

    }

    function sell(uint256 _productID) public {
        // Ensure that the product ID is within the ones present in Stock (i.e., have been ordered)
        require(validateProductId(_productID), "The product is not in the Blockchain");
        // Ensure that the caller is a Retailer
        (uint256 _id, bool _isValid) = isRetailer();
        require(_isValid, "The user is not a registered retailer");
        // Ensure that the product is in correct stage
        require(Stock[_productID].phase == PHASE.Retail, "You don't have the right to modify the product at this stage");
        // Mark the retailer as well
        Stock[_productID].tracking.retailerID = _id;
        // Mark latest modified by
        Stock[_productID].lastModifiedBy = _id;
        // Mark product as sold
        Stock[_productID].phase = PHASE.Sold;
    }

    function startResourceExtraction(uint256 _productID) virtual public {
        // Ensure that the product ID is within the ones present in Stock (i.e., have been ordered)
        require(validateProductId(_productID), "The product is not in the Blockchain");
        // Ensure that the caller is a Provider
        (uint256 _id, bool _isValid) = isProvider();
        require(_isValid, "The user is not a registered provider");
        // Ensure that the product is in correct stage
        require(
            Stock[_productID].phase == PHASE.Init ||
            Stock[_productID].phase == PHASE.ResourceExtraction_Failed,
            "You don't have the right to modify the product at this stage"
        );
        uint256 _responseAssignedTo = 0;
        // If we are in the Init stage, any provider can take ownership
        // Otherwise, the owning provider needs to adjust
        if(Stock[_productID].phase == PHASE.ResourceExtraction_Failed) {
            require(findProviderByEthAddress(msg.sender) == Stock[_productID].requireResponseBy, "Access Denied");
            // This step depends by a design choice
            // It is possible to either re-send the resource to the same supplier:
            //     Stock[_productID].requireResponseBy = Stock[_productID].lastModifiedBy;
            //     Stock[_productID].lastModifiedBy = _id;
            // Or it is possible to just re-send to QA step and to ANY supplier, in which case
            //     Stock[_productID].requireResponseBy = 0;
            require(
                getSupplierById(Stock[_productID].lastModifiedBy).id > 0,
                "Error. Request not coming from a Provider"
            );
            // After updating the stage, the materials will be resent to the same provider
            _responseAssignedTo = Stock[_productID].lastModifiedBy;
        }
        // Finally, update product stage
        Stock[_productID].lastModifiedBy = _id;
        Stock[_productID].requireResponseBy = _responseAssignedTo;
        Stock[_productID].phase = PHASE.ResourceExtraction_Started;
    }

    function addNewProduct(string memory _name, string memory _description) public onlyByOwner()
    {
        require(
            atLeastOneActor(),
            "The supply chain is missing the required entities to operate"
        );
        _productCounter++;

        Stock[_productCounter] = Product(
            _productCounter,
            _name,
            _description,
            0,
            0,
            PHASE.Init,
            Tracking(0, 0, 0, 0, 0)
        );
    }

    /* =============================================
    ** Abstract Phase Update Functions
    ** ============================================= */
    // These functions need to be implemented by sub-contracts

    // Although not fully customisable, this configuration allows
    // the user to define different kind of supply chains

    function completeResourceExtraction(uint256 _productID) virtual public{}
    function failResourceExtraction(uint256 _productID) virtual public{}

    function startResourceSupply(uint256 _productID) virtual public{}
    function completeResourceSupply(uint256 _productID) virtual public{}
    function failResourceSupply(uint256 _productID) virtual public{}

    function startManufacturing(uint256 _productID) virtual public{}
    function completeManufacturing(uint256 _productID) virtual public{}

    function startDistribution(uint256 _productID) virtual public{}
    function completeDistribution(uint256 _productID) virtual public{}
    function failDistribution(uint256 _productID) virtual public{}

    /*
    * Wrapper functions: These embeds the functionality to advance or revert
    * the supply chain state
    */

    function acceptPhase(uint256 _productID) virtual public{
        require(_productID > 0 && _productID <= _productCounter, "Invalid Product ID");

        (uint256 _operator, string memory _operatorRole) = findActorByEthAddress(msg.sender);
        require(_operator > 0, "Actor not found");

        Product memory product = Stock[_productID];
        if(keccak256(bytes(_operatorRole)) == keccak256(bytes("Provider"))){
            if (product.phase == PHASE.Init) startResourceExtraction(_productID);
            else if (
                product.phase == PHASE.ResourceExtraction_Failed ||
                product.phase == PHASE.ResourceExtraction_Started
            ) completeResourceExtraction(_productID);
        }
        else if(keccak256(bytes(_operatorRole)) == keccak256(bytes("Supplier"))){
            if (product.phase == PHASE.ResourceExtraction_Completed) startResourceSupply(_productID);
            else if (
                product.phase == PHASE.ResourceSupply_Failed ||
                product.phase == PHASE.ResourceSupply_Started
            ) completeResourceSupply(_productID);
        }
        else if(keccak256(bytes(_operatorRole)) == keccak256(bytes("Manufacturer"))){
            if (product.phase == PHASE.ResourceSupply_Completed) startManufacturing(_productID);
            else if (
                product.phase == PHASE.Manufacturing_Started
            ) completeManufacturing(_productID);
        }
        else if(keccak256(bytes(_operatorRole)) == keccak256(bytes("Distributor"))){
            if (product.phase == PHASE.Manufacturing_Completed) startDistribution(_productID);
            else if (
                product.phase == PHASE.Distribution_Started ||
                product.phase == PHASE.Distribution_Failed
            ) completeDistribution(_productID);
        }
        else if(keccak256(bytes(_operatorRole)) == keccak256(bytes("Retailer"))){
            if (product.phase == PHASE.Distribution_Completed) retail(_productID);
            else if (
                product.phase == PHASE.Retail
            ) sell(_productID);
        }
    }

    function rejectPhase(uint256 _productID) virtual public{
        require(_productID > 0 && _productID <= _productCounter, "Invalid Product ID");

        (uint256 _operator, string memory _operatorRole) = findActorByEthAddress(msg.sender);
        require(_operator > 0, "Actor not found");

        require(
            keccak256(bytes(_operatorRole)) != keccak256(bytes("Distributor")) &&
            keccak256(bytes(_operatorRole)) != keccak256(bytes("Provider")),
            "The FAIL operation is not available to Providers and Distributors"
        );

        Product memory product = Stock[_productID];
        if(keccak256(bytes(_operatorRole)) == keccak256(bytes("Supplier"))){
            if (product.phase == PHASE.ResourceExtraction_Completed) failResourceExtraction(_productID);
        }
        else if(keccak256(bytes(_operatorRole)) == keccak256(bytes("Manufacturer"))){
            if (product.phase == PHASE.ResourceSupply_Completed) failResourceSupply(_productID);
        }
        else if(keccak256(bytes(_operatorRole)) == keccak256(bytes("Retailer"))){
            if (product.phase == PHASE.Distribution_Completed) failDistribution(_productID);
        }
    }



}