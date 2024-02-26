// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../ISupplyChain.sol";
import "./LessSimpleSupplyChain.sol";

contract SupplyChainFeedback is LessSimpleSupplyChain {
    struct FeedbackEntry {
        uint8 rating;        // Numeric rating
        string description;  // Textual description of the feedback
    }

    struct Feedback {
        FeedbackEntry[] entries; // Array of feedback entries
    }

    mapping(address => Feedback) public feedbacks;

    // Function to add feedback
    function _addFeedback(address actor, uint8 rating, string memory description) private {
        require(_isRegistered(actor), "The user is not registered");
        require(rating >= 1 && rating <= 10, "Rating must be between 1 and 10");

        feedbacks[actor].entries.push(FeedbackEntry(rating, description));

        emit FeedbackAdded(actor, rating, description); // Event for logging new feedback
    }

    // Function to get the average rating of an actor
    function getAverageRating(address actor) public view returns (uint8) {
        require(_isRegistered(actor), "The user is not registered");
        Feedback storage f = feedbacks[actor];
        if (f.entries.length == 0) {
            return 0;
        }
        uint256 totalRating;
        for(uint256 i = 0; i < f.entries.length; i++) {
            totalRating += f.entries[i].rating;
        }
        return uint8(totalRating / f.entries.length);
    }

    // Event for logging new feedback
    event FeedbackAdded(address indexed actor, uint8 rating, string description);

    function failResourceExtractionWithReason(uint256 _productID, uint8 rating, string description) public {
        // Get last actor
        uint256 _actorIndex = Stock[_productID].lastModifiedBy;
        require(_actorIndex > 0 && _actorIndex <= getSuppliersCount(), "Wrong actor");
        // First, fail resource extraction
        failResourceExtraction(_productID);
        // If this succeeds, send a negative feedback to supplier
        _addFeedback(Suppliers[_actorIndex], rating, description);
    }


}

