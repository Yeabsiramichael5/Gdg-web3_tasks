// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CrowdFund {
    /* =============================================================
                            STEP 1: Struct
    ============================================================= */
    struct Campaign {
        address owner;
        uint256 goal;
        uint256 pledged;
        uint256 startAt;
        uint256 endAt;
        bool claimed;
    }

    /* =============================================================
                            STEP 2: State Variables
    ============================================================= */
    uint256 public campaignCount;
    mapping(uint256 => Campaign) public campaigns;
    mapping(uint256 => mapping(address => uint256)) public pledgedAmount;

    /* =============================================================
                            STEP 3: Create Function
    ============================================================= */
    function create(uint256 _goal, uint32 _duration) external {
        campaignCount++;
        
        campaigns[campaignCount] = Campaign({
            owner: msg.sender,
            goal: _goal,
            pledged: 0,
            startAt: block.timestamp,
            endAt: block.timestamp + _duration,
            claimed: false
        });
    }

    /* =============================================================
                            STEP 4: Pledge Function
    ============================================================= */
    function pledge(uint256 _id) external payable {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp < campaign.endAt, "Ended");

        campaign.pledged += msg.value;
        pledgedAmount[_id][msg.sender] += msg.value;
    }

    /* =============================================================
                            STEP 5: Claim Function
    ============================================================= */
    function claim(uint256 _id) external {
        Campaign storage campaign = campaigns[_id];
        require(msg.sender == campaign.owner, "Not owner");
        require(block.timestamp >= campaign.endAt, "Not ended");
        require(campaign.pledged >= campaign.goal, "Goal not reached");
        require(!campaign.claimed, "Already claimed");

        campaign.claimed = true;
        payable(campaign.owner).transfer(campaign.pledged);
    }

    /* =============================================================
                            STEP 6: Refund Function
    ============================================================= */
    function refund(uint256 _id) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp >= campaign.endAt, "Not ended");
        require(campaign.pledged < campaign.goal, "Goal reached");

        uint256 balance = pledgedAmount[_id][msg.sender];
        require(balance > 0, "No funds to refund");

        pledgedAmount[_id][msg.sender] = 0;
        payable(msg.sender).transfer(balance);
    }
}