// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract CaseStudy {
    struct Scenario {
        string description;
        string[] options;
        uint256 correctOption;
        bool completed;
    }

    struct User {
        uint256 currentScenario;
        uint256 score;
        bool completed;
    }

    mapping(address => User) public users;
    Scenario[] public scenarios;
    address public owner;

    event ScenarioCompleted(address user, uint256 scenarioId, bool success);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Add a new scenario to the case study
    function addScenario(
        string memory _description,
        string[] memory _options,
        uint256 _correctOption
    ) public onlyOwner {
        require(_correctOption < _options.length, "Invalid correct option index");
        scenarios.push(Scenario(_description, _options, _correctOption, false));
    }

    // User attempts a scenario
    function attemptScenario(uint256 _optionSelected) public {
        User storage user = users[msg.sender];
        require(!user.completed, "Case study already completed");
        require(user.currentScenario < scenarios.length, "No more scenarios");

        Scenario storage scenario = scenarios[user.currentScenario];
        require(!scenario.completed, "Scenario already completed");
        
        // Check if the selected option is correct
        if (_optionSelected == scenario.correctOption) {
            user.score++;
            emit ScenarioCompleted(msg.sender, user.currentScenario, true);
        } else {
            emit ScenarioCompleted(msg.sender, user.currentScenario, false);
        }

        scenario.completed = true;
        user.currentScenario++;

        // Check if all scenarios are completed
        if (user.currentScenario == scenarios.length) {
            user.completed = true;
            // Reward the user (could be tokens, NFTs, etc.)
            // Example: mintReward(msg.sender);
        }
    }

    // Get current scenario for the user
    function getCurrentScenario() public view returns (string memory, string[] memory) {
        User storage user = users[msg.sender];
        require(user.currentScenario < scenarios.length, "No more scenarios");
        Scenario storage scenario = scenarios[user.currentScenario];
        return (scenario.description, scenario.options);
    }

    // Get the user's score
    function getScore() public view returns (uint256) {
        User storage user = users[msg.sender];
        return user.score;
    }

    // Get the total number of scenarios
    function getTotalScenarios() public view returns (uint256) {
        return scenarios.length;
    }
}
