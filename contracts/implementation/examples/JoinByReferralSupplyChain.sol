// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../ISupplyChain.sol";
import "./SimpleSupplyChain.sol";

contract SelfRegisterSimpleSupplyChain is SimpleSupplyChain {

    struct QueueRegistrant {
        address ethAddress;
        uint256 id;
        string name;
        string businessAddress;
        string role;
        uint256 referralCount;
    }

    mapping(uint256 => QueueRegistrant) public Queue;
    uint256 private _queueCounter;
    mapping(address => address[]) public referrals; // New mapping to store referrals
    uint256 public referralThreshold = 3; // Example threshold

    function _approveActorById(uint256 _id) private {
        require(_id > 0 && _id <= _queueCounter, "Invalid Registrant ID");
        require(_queueCounter > 0, "Registrant Queue is empty");
        QueueRegistrant memory q = Queue[_id];
        addActor(q.ethAddress, q.role, q.name, q.businessAddress);
    }


    function registerActor(
        address _ethAddress,
        string memory _role,
        string memory _name,
        string memory _businessAddress
    ) virtual public {
        _queueCounter++;
        Queue[_queueCounter] = QueueRegistrant(
            _ethAddress, _queueCounter, _name, _businessAddress, _role, 0
        );
    }

    function referActor(uint256 _registrantId) public {
        require(_isRegistered(msg.sender), "Only existing actors of can refer");
        QueueRegistrant storage registrant = Queue[_registrantId];

        // Avoid duplicate referrals
        for (uint256 i = 0; i < referrals[msg.sender].length; i++) {
            require(
                referrals[msg.sender][i] != registrant.ethAddress,
                "Already referred this registrant"
            );
        }

        referrals[msg.sender].push(registrant.ethAddress);
        registrant.referralCount++;

        if (registrant.referralCount >= referralThreshold) {
            _approveActorById(_registrantId);
        }
    }
}
