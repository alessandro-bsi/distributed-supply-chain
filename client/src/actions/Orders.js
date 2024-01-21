import React, { useState, useEffect } from 'react'
import SupplyChainABI from "../artifacts/LessSimpleSupplyChain.json"
import {loadCurrentUser, loadWeb3} from "../common/utils";
import Loader from "../ui/simple/Loader";
import Navigator from "../ui/simple/Navigator";
import NewOrder from "../ui/simple/NewOrder";
import {ProductTable} from "../ui/composite/Table";
import Products from "../ui/composite/Products";

function Orders() {
    const [currentAccount, setCurrentAccount] = useState("");
    const [loader, setLoader] = useState(true);
    const [supplyChain, setSupplyChain] = useState();
    const [Stock, setStock] = useState();

    useEffect(() => {
        loadWeb3().catch((error) => {window.alert(error)});
        loadCurrentUser()
            .then((account) => setCurrentAccount(account))
            .catch((error) => {window.alert(error)});
        loadBlockchainData();
    }, [])


    const loadW3 = loadWeb3().catch((error) => {window.alert(error);});
    const loadUser = loadCurrentUser()
        .then((account) => setCurrentAccount(account))
        .catch((error) => {window.alert(error);});

    const loadBlockchainData = async () => {
        setLoader(true);
        const web3 = window.web3;
        const networkId = await web3.eth.net.getId();
        const networkData = SupplyChainABI.networks[networkId];
        if (networkData) {
            const supplychain = new web3.eth.Contract(SupplyChainABI.abi, networkData.address);
            setSupplyChain(supplychain);

            supplychain.methods.getProductsArray().call()
                .then((products) => { setStock(products); })
                .catch((e) => { window.alert("Error at getProductsArray"); });

            // TODO: Transform product stage:int into human readable product stage:string
            setLoader(false);
        }
        else {
            window.alert('The smart contract is not deployed to current network');
        }
    }
    if (loader) {
        return <Loader></Loader>

    }


    const handlerSubmitOrder = async (event, _productName, _productDescription) => {
        event.preventDefault();
        const web3 = window.web3;
        const networkId = await web3.eth.net.getId();
        const networkData = SupplyChainABI.networks[networkId];
        if (networkData) {
            const supplychain = new web3.eth.Contract(SupplyChainABI.abi, networkData.address);
            supplychain.methods.addNewProduct(_productName, _productDescription).send({from: currentAccount})
                .then((success) => {
                    window.alert(`Successfully added product ${_productName}`);
                    loadBlockchainData();
                })
                .catch((error) => window.alert(error));
        }
    }

    return (
        <div>
            <Navigator
                currentAccount={currentAccount}
            />
            <Products
                newProductHandler={handlerSubmitOrder}
                editProductHandler={undefined}
                products={Stock}
                currentAccount={currentAccount}
            />

        </div>
    )
}

export default Orders
