import Web3 from "web3";
import SupplyChainABI from "../artifacts/LessSimpleSupplyChain.json";
import {act} from "@testing-library/react";

export async function loadWeb3() {
    if (window.ethereum) {
        window.web3 = new Web3(window.ethereum);
        await window.ethereum.enable();
    } else if (window.web3) {
        window.web3 = new Web3(window.web3.currentProvider);
    } else {
        throw Error("This application requires an Ethereum browser to operate");
    }
};


export async function loadCurrentUser() {
    const accounts = await loadAccounts();
    if (Array.isArray(accounts) && accounts.length > 0) {
        return accounts[0];
    } else {
        throw Error("Error fetching current account");
    }
}

export async function loadAccounts() {
    const web3 = window.web3;
    const accounts = await web3.eth.getAccounts();
    if (Array.isArray(accounts) && accounts.length > 0) {
        return accounts;
    } else {
        throw Error("Error fetching accounts");
    }
}

export async function loadBlockchainDataRaw () {
    const web3 = window.web3;
    const networkId = await web3.eth.net.getId();
    const networkData = SupplyChainABI.networks[networkId];
    if (networkData) {
        return networkData;
    } else {
        throw Error("Error connecting to contract");
    }
}

export async function validateProductId (productId) {
    const web3 = window.web3;
    const networkId = await web3.eth.net.getId();
    const networkData = SupplyChainABI.networks[networkId];
    if (networkData) {
        const SupplyChain = new web3.eth.Contract(SupplyChainABI.abi, networkData.address);
        return await SupplyChain.methods.validateProductId(productId).call();
    }
    return false;
}

const product_transform = function(x){
    if(Array.isArray(x)) {
        let startIndex = 0;
        return {
            "id": x[startIndex],
            "name": x[startIndex+1],
            "description": x[startIndex+2],
            "lastModifiedBy": x[startIndex+3],
            "requireResponseBy": x[startIndex+4],
            "phase": x[startIndex+5],
            "tracking": {
                "provider": parseInt(x[startIndex+6][0], 10),
                "supplier": parseInt(x[startIndex+6][1], 10),
                "manufacturer": parseInt(x[startIndex+6][2], 10),
                "distributor": parseInt(x[startIndex+6][3], 10),
                "retailer": parseInt(x[startIndex+6][4], 10)
            }
        }
    }else{
        return x;
    }
}

const actor_transform = function(x){
    if(Array.isArray(x)) {
        let startIndex = 0;
        return {
            "ethAddress": x[startIndex],
            "id": x[startIndex + 1],
            "name": x[startIndex + 2],
            "businessAddress": x[startIndex + 3]
        }
    }else{
        return x;
    }
}


export async function loadActorInfo (actorId) {
    const web3 = window.web3;
    const networkId = await web3.eth.net.getId();
    const networkData = SupplyChainABI.networks[networkId];
    if (networkData) {
        const SupplyChain = new web3.eth.Contract(SupplyChainABI.abi, networkData.address);
        let actor = null;
        let formatted = null;
        const roles = [
            "Provider",
            "Supplier",
            "Manufacturer",
            "Distributor",
            "Retailer"
        ];
        let i = 0;

        for (const f of [
            SupplyChain.methods.getRetailerById,
            SupplyChain.methods.getDistributorById,
            SupplyChain.methods.getManufacturerById,
            SupplyChain.methods.getSupplierById,
            SupplyChain.methods.getProviderById
        ]) {
            try {
                actor = await f(actorId).call();
                if (actor !== null && actor !== undefined) {
                    console.log();
                    formatted = actor_transform(actor);
                    formatted["role"] = roles[i];
                    return formatted;
                }
            } catch (e) {
                console.log(e);
            }
            i++;
        }
    }
    return null;
}
export async function loadProductInfo (productId) {
    const web3 = window.web3;
    const networkId = await web3.eth.net.getId();
    const networkData = SupplyChainABI.networks[networkId];
    if (networkData) {
        const SupplyChain = new web3.eth.Contract(SupplyChainABI.abi, networkData.address);
        let valid = await SupplyChain.methods.validateProductId(productId).call();
        if(!valid){
            console.log(`Product N${productId} is invalid`);
            return null;
        }
        console.log(`Product N${productId} is a valid product`);

        let rawProduct = await SupplyChain.methods.getProductById(productId).call();

        if(rawProduct === undefined || rawProduct === null){
            console.log(`Product N${productId} could not be recovered`);
            return null;
        }
        console.log(rawProduct);

        let product = product_transform(rawProduct);
        let actor = null;

        product.phase = await SupplyChain.methods.showPhase(productId).call();
        console.log(product);

        if (!isNaN(product.tracking.provider) && product.tracking.provider !== 0) {
            actor = await SupplyChain.methods.getProviderById(product.tracking.provider).call();
            if(actor !== null){
                product.tracking.provider = actor_transform(actor);
            }
        }

        if (!isNaN(product.tracking.supplier) && product.tracking.supplier !== 0) {
            actor = await SupplyChain.methods.getSupplierById(product.tracking.supplier).call();
            if(actor !== null){
                product.tracking.supplier = actor_transform(actor);
            }
        }
        if (!isNaN(product.tracking.manufacturer) && product.tracking.manufacturer !== 0) {
            actor = await SupplyChain.methods.getManufacturerById(product.tracking.manufacturer).call();
            if(actor !== null){
                product.tracking.manufacturer = actor_transform(actor);
            }
        }
        if (!isNaN(product.tracking.distributor) && product.tracking.distributor !== 0) {
            actor = await SupplyChain.methods.getDistributorById(product.tracking.distributor).call();
            if(actor !== null){
                product.tracking.distributor = actor_transform(actor);
            }
        }
        if (!isNaN(product.tracking.retailer) && product.tracking.retailer !== 0) {
            actor = await SupplyChain.methods.getRetailerById(product.tracking.retailer).call();
            if(actor !== null){
                product.tracking.retailer = actor_transform(actor);
            }
        }

        console.log(product);
        return product;

    }
    return null;
}

export async function acceptPhase(_productID, _from) {
    const web3 = window.web3;
    const networkId = await web3.eth.net.getId();
    const networkData = SupplyChainABI.networks[networkId];
    if (networkData) {
        const SupplyChain = new web3.eth.Contract(SupplyChainABI.abi, networkData.address);
        try {
            let _ = await SupplyChain.methods.acceptPhase(_productID).send({from: _from});
            return true;
        } catch (e){
            console.log("Failed to reject stage")
            return false;
        }
    }
}
export async function rejectPhase(_productID, _from) {
    const web3 = window.web3;
    const networkId = await web3.eth.net.getId();
    const networkData = SupplyChainABI.networks[networkId];
    if (networkData) {
        const SupplyChain = new web3.eth.Contract(SupplyChainABI.abi, networkData.address);
        try {
            let _ =  await SupplyChain.methods.rejectPhase(_productID).send({from: _from});
            return true;
        } catch (e){
            console.log("Failed to reject stage")
            return false;
        }
    }
}

export async function updateProduct(_productID, _productName, _productDescription, _from) {
    const web3 = window.web3;
    const networkId = await web3.eth.net.getId();
    const networkData = SupplyChainABI.networks[networkId];
    if (networkData) {
        const SupplyChain = new web3.eth.Contract(SupplyChainABI.abi, networkData.address);
        try {
            let _ =  await SupplyChain.methods.updateProduct(_productID).send({from: _from});
            return true;
        } catch (e){
            console.log(`Failed to update Product ${_productID}`)
            return false;
        }
    }
}

export async function updateActor(_actorObject, _actorName, _actorAddress, _from) {
    if(_actorObject.name.trim() ===_actorName.trim() && _actorObject.businessAddress.trim() === _actorAddress){
        console.log("Data has not changed");
        return true;
    }
    const web3 = window.web3;
    const networkId = await web3.eth.net.getId();
    const networkData = SupplyChainABI.networks[networkId];
    if (networkData) {
        const SupplyChain = new web3.eth.Contract(SupplyChainABI.abi, networkData.address);
        try {
            let _ =  await SupplyChain.methods.updateActor(_actorObject.ethAddress, _actorObject.role, _actorName, _actorAddress).send({from: _from});
            return true;
        } catch (e){
            console.log(`Failed to update ${_actorObject.role} Actor ${_actorObject.id} at ${_actorObject.ethAddress}`)
            return false;
        }
    }
}
