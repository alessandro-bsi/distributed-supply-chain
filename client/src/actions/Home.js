import React, {useEffect, useState} from 'react'
import { useHistory } from "react-router-dom"
import Navigator from "../ui/simple/Navigator";
import HeaderCard from "../ui/simple/Card";
import {loadCurrentUser, loadWeb3} from "../common/utils";
import SupplyChainABI from "../artifacts/LessSimpleSupplyChain.json";
import Web3 from "web3";
import {generateData} from "../common/autogen";

function Home() {
    const history = useHistory()
    const [currentAccount, setCurrentAccount] = useState("");

    useEffect(() => {
        loadWeb3().catch((error) => {window.alert(error)});
        loadCurrentUser()
            .then((account) => setCurrentAccount(account))
            .catch((error) => {window.alert(error)});
    }, [])


    const redirect_to_roles = () => {
        history.push('/roles')
    }
    const redirect_to_orders = () => {
        history.push('/orders')
    }
    const redirect_to_operations = () => {
        history.push('/operations')
    }
    const redirect_to_track = () => {
        history.push('/tracking')
    }


    const autogenerateHandler = async (event) => {
        event.preventDefault();
        await generateData();
    }

    return (
        <div>
            <Navigator
                currentAccount={currentAccount}
                mainHandler={autogenerateHandler}
            >
            </Navigator>
            <div className="container">

                <HeaderCard
                    header="Step 1 (Onwer only)"
                    title="Add users to the supply chain"
                    footer="Note: <<Owner>> is the person who deployed the
                    smart contract on the blockchain."
                    content="Owner Should Register material Providers, Suppliers, Manufacturers,
                        Distributors, and Retailers."
                    linkDisplay="Users & Roles"
                    linkAction={redirect_to_roles}
                ></HeaderCard>

                <HeaderCard
                    header="Step 2 (Onwer only)"
                    title="Order Products"
                    content="Request products through the supply chain."
                    linkDisplay="Orders"
                    linkAction={redirect_to_orders}
                ></HeaderCard>

                <HeaderCard
                    header="Step 3 (Supply chain Actors only)"
                    title="Manage operations"
                    content="Perform Supply Chain operations on existing products."
                    linkDisplay="Operations"
                    linkAction={redirect_to_operations}
                ></HeaderCard>

                <HeaderCard
                    header="Step 4 (Anyone)"
                    title="Tracking products"
                    content="Tracking products in the supply chain, showing current phase of production and actors involved."
                    linkDisplay="Tracking"
                    linkAction={redirect_to_track}
                ></HeaderCard>

            </div>
        </div>
    )
}

export default Home
