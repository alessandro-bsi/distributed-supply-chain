import SupplyChainABI from "../artifacts/LessSimpleSupplyChain.json";
import Web3 from "web3";
import {loadCurrentUser} from "./utils";

export async function loadGanacheAccounts() {
    const options = { a: 20 };
    let accounts= await new Web3(new Web3.providers.HttpProvider('http://172.27.96.1:7545', options)).eth
        .getAccounts((err, accounts) => {
            console.log(err, accounts);
        });

    if(Array.isArray(accounts) && accounts.length > 0){
        return accounts;
    }
    return [];
}

export async function generateData(){
    const web3 = window.web3;
    let owner = await loadCurrentUser();

    let accounts= await loadGanacheAccounts();
    accounts = accounts.slice(1,)

    const networkId = await web3.eth.net.getId();
    const networkData = SupplyChainABI.networks[networkId];

    if (networkData) {
        const supplychain = new web3.eth.Contract(SupplyChainABI.abi, networkData.address);
        let roles = ['Provider', 'Supplier', 'Manufacturer', 'Distributor', 'Retailer'];
        let j = 0;
        for (const role of roles) {
            for (let i = 0; i < 2; i++){
                let name = `${role} ${i}`;
                let businessAddress = `${role} ${i} Address`;
                let ethAddress = accounts[j];
                try {
                    let success = await supplychain.methods.addActor(ethAddress, role, name, businessAddress).send({from: owner});
                    console.log(`Successfully added ${name} as ${role}`);
                }catch(error){
                    console.log(`Error ${error.message} invoking addActor with (${ethAddress}, ${role}, ${name}, ${businessAddress}) from ${owner}`);
                }
                j++;
            }
        }

        for (let index = 0; index < 5; index++) {

            try {
                let success = await supplychain.methods.addNewProduct(`Product N${index}`, `Description of product N${index}`).send({from: owner});
                console.log(`Successfully added product N${index}`);
            } catch (error) {
                console.log(`Error invoking addNewProduct (Product N${index})`);
            }
        }
    } else {
        window.alert("Failed to auto generate elements");
    }


}