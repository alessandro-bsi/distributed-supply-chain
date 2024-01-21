import React, { useState, useEffect } from 'react'
import { useHistory } from "react-router-dom"
import SupplyChainABI from "../artifacts/LessSimpleSupplyChain.json"
import Loader from "../ui/simple/Loader";
import Navigator from "../ui/simple/Navigator";
import Table, {ProductTable} from "../ui/composite/Table";
import {loadCurrentUser, loadWeb3} from "../common/utils";

function Operations() {
    const history = useHistory()
    useEffect(() => {
        loadWeb3().catch((error) => {window.alert(error)});
        loadCurrentUser()
            .then((account) => setCurrentaccount(account))
            .catch((error) => {window.alert(error)});
        loadBlockchainData();
    }, [])

    const [currentAccount, setCurrentaccount] = useState("");
    const [loader, setloader] = useState(true);
    const [SupplyChain, setSupplyChain] = useState();
    const [Stock, setStock] = useState();

    const loadW3 = loadWeb3().catch((error) => {window.alert(error)});
    const loadUser = loadCurrentUser()
        .then((account) => setCurrentaccount(account))
        .catch((error) => {window.alert(error)});
    const loadBlockchainData = async () => {
        setloader(true);
        const web3 = window.web3;
        const networkId = await web3.eth.net.getId();
        const networkData = SupplyChainABI.networks[networkId];
        if (networkData) {
            const supplychain = new web3.eth.Contract(SupplyChainABI.abi, networkData.address);
            setSupplyChain(supplychain);

            supplychain.methods.getProductsArray().call()
                .then((products) => {setStock(products)})
                .catch((e) => {window.alert("Error at getProductsArray")});

            setloader(false);
        }
        else {
            window.alert('The smart contract is not deployed to current network')
        }
    }
    if (loader) {
        return <Loader></Loader>

    }

    const handlerSubmitSuccess = async (event, _id) => {
        event.preventDefault();
        SupplyChain.methods.acceptPhase(_id).send({ from: currentAccount })
            .then((success) => {window.alert("Success")})
            .catch((error) => {window.alert(error)});
    }
    const handlerSubmitFailure = async (event, _id) => {
        event.preventDefault();
        SupplyChain.methods.rejectPhase(_id).send({ from: currentAccount })
            .then((success) => {window.alert("Success")})
            .catch((error) => {window.alert(error)});
    }

    return (
        <div>
            <Navigator currentAccount={currentAccount}></Navigator>
            <div className="container">
                <ProductTable currentAccount={currentAccount} tableName={"Supply Chain Operations"} data={Stock}></ProductTable>
            </div>
        </div>
    )
}

export default Operations
