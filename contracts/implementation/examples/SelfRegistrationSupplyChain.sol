// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "../ISupplyChain.sol";
import "./SimpleSupplyChain.sol";

// Extends Simple Supply Chain offering a way for actors to request
// Account Registration
contract SelfRegisterSimpleSupplyChain is SimpleSupplyChain{

    // The QueueRegistrant struct defines basic information to be used to create actors
    struct QueueRegistrant {
        address ethAddress;      // Node ETH address
        uint256  id;             // Queue Id
        string  name;            // Actor Name (Company name)
        string  businessAddress; // Business Address
        string  role;            // Requested Role
    }

    // Export registrant on the blockchain
    mapping(uint256 => QueueRegistrant) public Queue;
    uint256 private _queueCounter;

    function getQueueCounter() public view returns (uint256){
        return _queueCounter;
    }

    /*
    * This function now implements a functionality usable by ANY user
    * to request registration to the platform. The request still needs
    * to be approved by the owner though.
    */
    function registerActor(
        address _ethAddress,
        string memory _role,
        string memory _name,
        string memory _businessAddress
    ) virtual public {
        _queueCounter++;
        Queue[_queueCounter] = QueueRegistrant(_ethAddress, _queueCounter, _name, _businessAddress, _role);
    }

    function findRegistrantByAddress(address _address) public view returns(uint256){
        require(_queueCounter > 0);
        for (uint256 i = 1; i <= _queueCounter; i++) {
            if (Queue[i].ethAddress == _address) return Queue[i].id;
        }
        return 0;
    }

    function approveActorByAddress(
        address _address
    ) virtual public onlyByOwner() {
        uint256 _id = findRegistrantByAddress(_address);
        approveActorById(_id);
    }

    function approveActorById(
        uint256 _id
    ) virtual public onlyByOwner() {
        require(_id > 0 && _id <= _queueCounter, "Invalid Registrant ID");
        require(_queueCounter > 0, "Registrant Queue is empty");
        QueueRegistrant memory q = Queue[_id];
        addActor(q.ethAddress, q.role, q.name, q.businessAddress);
    }


}