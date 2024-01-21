import {ShowTrackingModal} from "../ui/simple/Modals";

import React, { useState, useEffect } from 'react'
import { useHistory } from "react-router-dom"
import Web3 from "web3";
import SupplyChainABI from "../artifacts/LessSimpleSupplyChain.json"
import Loader from "../ui/simple/Loader";
import {loadCurrentUser, loadWeb3} from "../common/utils";
import Navigator from "../ui/simple/Navigator";
import SearchBar from "../ui/simple/SearchBar";
import Table, {ProductTable} from "../ui/composite/Table";

function Tracking() {
    const [currentAccount, setCurrentaccount] = useState("");
    const [loader, setloader] = useState(true);
    const [SupplyChain, setSupplyChain] = useState();
    const [Stock, setStock] = useState();
    const [Stage, setStage] = useState();
    const [Providers, setProviders] = useState();
    const [Suppliers, setSuppliers] = useState();
    const [Manufacturers, setManufacturers] = useState();
    const [Distributors, setDistributors] = useState();
    const [Retailers, setRetailers] = useState();
    const [Actors, setActors] = useState([]);
    const [Product, setProduct] = useState();
    const [modalShow, setModalShow] = useState(false);

    useEffect(() => {
        loadWeb3().catch((error) => {window.alert(error);});
        loadCurrentUser()
            .then((account) => setCurrentaccount(account))
            .catch((error) => {window.alert(error);});
        loadBlockchainData();
        setModalShow(false);
    }, [])

    const loadW3 = loadWeb3().catch((error) => {window.alert(error)});
    const loadUser = loadCurrentUser()
        .then((account) => setCurrentaccount(account))
        .catch((error) => {window.alert(error)});

    const loadBlockchainData = async () => {
        setloader(true);
        const web3 = window.web3;
        const accounts = await web3.eth.getAccounts();
        const account = accounts[0];
        setCurrentaccount(account);
        const networkId = await web3.eth.net.getId();
        const networkData = SupplyChainABI.networks[networkId];
        if (networkData) {
            const supplyChain = new web3.eth.Contract(SupplyChainABI.abi, networkData.address);
            setSupplyChain(supplyChain);

            supplyChain.methods.getProductsArray().call()
                .then((products) => {setStock(products)})
                .catch((e) => {window.alert("Error at getProductsArray")});

            supplyChain.methods.getProvidersArray().call()
                .then((array) => {setProviders(array)})
                .catch((e) => {window.alert("Error at getProvidersArray")});

            supplyChain.methods.getSuppliersArray().call()
                .then((array) => {setSuppliers(array)})
                .catch((e) => {window.alert("Error at getSuppliersArray")});

            supplyChain.methods.getManufacturersArray().call()
                .then((array) => {setManufacturers(array)})
                .catch((e) => {window.alert("Error at getManufacturersArray")});

            supplyChain.methods.getDistributorsArray().call()
                .then((array) => {setDistributors(array)})
                .catch((e) => {window.alert("Error at getDistributorsArray")});

            supplyChain.methods.getRetailersArray().call()
                .then((array) => {setRetailers(array)})
                .catch((e) => {window.alert("Error at getRetailersArray")});

            setloader(false);
        }
        else {
            window.alert('The smart contract is not deployed to current network')
        }
    }
    if (loader) {
        return (
            <Loader></Loader>
        )
    }

    const handlerSubmit = async (event, _id) => {
        event.preventDefault();
        setModalShow(true);
    }


    return (
        <div>
            <Navigator currentAccount={currentAccount}></Navigator>
            <div className="container">
                <SearchBar currentAccount={currentAccount} ></SearchBar>
                <ProductTable currentAccount={currentAccount} tableName={"Products"} data={Stock}/>
            </div>
        </div>
    )
}

export default Tracking
