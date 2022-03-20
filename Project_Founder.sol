// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract FoundProject {
    uint256 id;
    string name;
    string description;
    address payable onwer;
    bool isFoundable;
    uint256 goal;
    uint256 requiredFounds;
    uint256 totalFounds;

    constructor(
        string memory _name,
        string memory _description,
        uint256 _id
    ) {
        id = _id;
        name = _name;
        description = _description;
        onwer = payable(msg.sender);
        isFoundable = true;
        goal = 0;
        totalFounds = 0;
    }

    modifier onlyOnwer() {
        require(msg.sender == onwer, "Only onwer can change project status");

        _;
    }

    modifier notOnlyOnwer() {
        require(
            msg.sender != onwer,
            "the owner cannot contribute to his own project"
        );

        _;
    }

    function setGoal(uint256 _goal) public {
        goal = _goal;
    }

    function changeProjectState(bool change) public onlyOnwer {
        isFoundable = change;
    }

    function fundProject() public payable notOnlyOnwer {
        require(isFoundable, "The founder has decided to stop collecting");
        require(
            msg.value != uint256(0),
            "You do not have sufficient ETH to complete the transaction"
        );
        require(
            totalFounds < goal,
            "The necessary funds have already been obtained."
        );
        require(
            totalFounds + goal >= goal,
            "unable to add more funds, check amount remaining for our goal"
        );

        onwer.transfer(msg.value);
        totalFounds += msg.value;
    }

    function missingFunds() public view returns (uint256) {
        uint256 data = goal - totalFounds;
        return data;
    }
}
