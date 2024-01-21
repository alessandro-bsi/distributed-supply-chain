import React, {useState, useEffect} from 'react';
import Nodes from "../ui/composite/Nodes";
import SupplyChainABI from "../artifacts/LessSimpleSupplyChain.json"
import {useHistory} from "react-router-dom"
import Navigator from "../ui/simple/Navigator";
import Loader from "../ui/simple/Loader";
import {loadCurrentUser, loadWeb3} from "../common/utils";

function Roles() {
    const history = useHistory()

    useEffect(() => {
        loadWeb3();
        loadCurrentUser();
        loadBlockchainData();
    }, [])

    const [CurrentAccount, setCurrentAccount] = useState("");
    const [loader, setloader] = useState(true);
    const [SupplyChain, setSupplyChain] = useState();
    const [Providers, setProviders] = useState([]);
    const [Suppliers, setSuppliers] = useState([]);
    const [Manufacturers, setManufacturers] = useState([]);
    const [Distributors, setDistributors] = useState([]);
    const [Retailers, setRetailers] = useState([]);

    const loadW3 = loadWeb3().catch((error) => {window.alert(error);});
    const loadUser = loadCurrentUser()
        .then((account) => setCurrentAccount(account))
        .catch((error) => {window.alert(error);});

    const loadBlockchainData = async () => {
        setloader(true);
        const web3 = window.web3;
        const networkId = await web3.eth.net.getId();
        const networkData = SupplyChainABI.networks[networkId];
        if (networkData) {
            const supplyChain = new web3.eth.Contract(SupplyChainABI.abi, networkData.address);
            setSupplyChain(supplyChain);


            supplyChain.methods.getProvidersArray().call()
                .then((actors) => {
                    console.log(actors);
                    setProviders(actors);
                })
                .catch((error) => window.alert(error));

            supplyChain.methods.getSuppliersArray().call()
                .then((actors) => {
                    console.log(actors);
                    setSuppliers(actors);
                })
                .catch((error) => window.alert(error));

            supplyChain.methods.getManufacturersArray().call()
                .then((actors) => {
                    console.log(actors);
                    setManufacturers(actors);
                })
                .catch((error) => window.alert(error));

            supplyChain.methods.getDistributorsArray().call()
                .then((actors) => {
                    console.log(actors);
                    setDistributors(actors);
                })
                .catch((error) => window.alert(error));

            supplyChain.methods.getRetailersArray().call()
                .then((actors) => {
                    console.log(actors);
                    setRetailers(actors);
                })
                .catch((error) => window.alert(error));


            setloader(false);
        } else {
            window.alert('The smart contract is not deployed to current network')
        }
    }
    if (loader) {
        return <Loader></Loader>

    }

    const editActorHandler = async (event, id, role, name, businessAddress) => {
        event.preventDefault();
        SupplyChain.methods.updateActor(id, role, name, businessAddress).send({from: CurrentAccount})
            .then((success) => {
                window.alert("Successfully changed");
                loadBlockchainData();
            })
            .catch((error) => {
                window.alert(`Error ${error.name} invoking updateActor with (${id}, ${role}, ${name}, ${businessAddress}) from ${CurrentAccount}`);
            })
    }

    const addActorHandler = async (event, ethAddress, role, name, businessAddress) => {
        event.preventDefault();
        console.log(SupplyChain);
        console.log(SupplyChain.methods);
        console.log(SupplyChain.methods.addActor);
        SupplyChain.methods.addActor(ethAddress, role, name, businessAddress).send({from: CurrentAccount})
            .then((success) => {
                window.alert(`Successfully added ${name}`);
                loadBlockchainData();
            })
            .catch((error) => {
                console.log(error);
                window.alert(`Error ${error.message} invoking addActor with (${ethAddress}, ${role}, ${name}, ${businessAddress}) from ${CurrentAccount}`);
            })
    }


    return (

        <div>
            <Navigator
                currentAccount={CurrentAccount}
            />
            <Nodes
                addActorHandler={addActorHandler}
                editActorHandler={editActorHandler}
                currentAccount={CurrentAccount}
                providers={Providers}
                suppliers={Suppliers}
                manufacturers={Manufacturers}
                distributors={Distributors}
                retailers={Retailers}
            />
        </div>
)
}

export default Roles
