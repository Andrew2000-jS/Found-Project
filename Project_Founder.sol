// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract FoundProject {
    enum ProjectState {
        Opened,
        Closed
    }

    struct Contribution {
        address Contributor;
        uint256 value;
    }

    struct Project {
        string id;
        string name;
        string description;
        address payable onwer;
        ProjectState state;
        uint256 goal;
        uint256 requiredFounds;
        uint256 totalFounds;
    }

    Project[] public projects;
    mapping(string => Contribution[]) public contributions;

    event ChangeState(ProjectState newState);

    event ProjectFound(string id, address sender, uint256 value);

    event ProjectCreated(
        string id,
        string name,
        string description,
        uint256 goal
    );

    event NewGoal(uint256 previousGoal, uint256 goal);

    modifier onlyOnwer(uint256 index) {
        require(
            msg.sender == projects[index].onwer,
            "Only onwer can change project status"
        );

        _;
    }

    modifier notOnlyOnwer(uint256 index) {
        require(
            msg.sender != projects[index].onwer,
            "the owner cannot contribute to his own project"
        );

        _;
    }

    function createProject(
        string calldata _id,
        string calldata _name,
        string calldata _description,
        uint256 _goal
    ) public {
        require(_goal > 0, "The goal must be greater than 0");
        Project memory newProject = Project(
            _id,
            _name,
            _description,
            payable(msg.sender),
            ProjectState.Opened,
            _goal,
            0,
            0
        );
        projects.push(newProject);
        emit ProjectCreated(_id, _name, _description, _goal);
    }

    function setGoal(uint256 index, uint256 _goal) public {
        Project memory project = projects[index];
        require(_goal > 0, "The goal must be greater than 0");

        uint256 previousGoal = project.goal;

        project.goal = _goal;
        projects[index] = project;

        emit NewGoal(previousGoal, project.goal);
    }

    function changeProjectState(uint256 index, ProjectState state)
        public
        onlyOnwer(index)
    {
        Project memory project = projects[index];
        require(project.state != state, "The state must be diferent");

        project.state = state;
        projects[index] = project;
        emit ChangeState(state);
    }

    function fundProject(index) public payable notOnlyOnwer(index) {
        Project memory project = projects[index];

        require(
            project.state == ProjectState.Opened,
            "The founder has decided to stop collecting"
        );
        require(
            msg.value != uint256(0),
            "You do not have sufficient ETH to complete the transaction"
        );
        require(
            project.totalFounds < project.goal,
            "The necessary funds have already been obtained."
        );
        require(
            project.totalFounds + project.goal >= project.goal,
            "unable to add more funds, check amount remaining for our goal"
        );

        project.onwer.transfer(msg.value);
        project.totalFounds += msg.value;
        projects[index] = project;

        contributions[project.id].push(Contribution(msg.sender, msg.value));
        emit ProjectFound(project.id, msg.sender, msg.value);
    }

    function missingFunds(uint256 index) public view returns (uint256) {
        Project memory project = projects[index];

        uint256 data = project.goal - project.totalFounds;
        return data;
    }
}
