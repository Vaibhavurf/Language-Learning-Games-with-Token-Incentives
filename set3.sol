// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LanguageLearningGames {

    struct Player {
        address wallet;
        uint256 score;
        uint256 tokens;
    }

    struct Game {
        uint256 id;
        string name;
        uint256 rewardPerPoint;
    }

    address public owner;
    uint256 public totalTokens;
    mapping(address => Player) public players;
    mapping(uint256 => Game) public games;
    uint256 public gameCount;

    event GameCreated(uint256 indexed gameId, string name, uint256 rewardPerPoint);
    event PlayerScored(address indexed player, uint256 gameId, uint256 points, uint256 tokensEarned);
    event TokensRedeemed(address indexed player, uint256 tokens);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    constructor(uint256 initialTokens) {
        require(initialTokens > 0, "Initial tokens must be greater than zero.");
        owner = msg.sender;
        totalTokens = initialTokens;
    }

    function addGame(string memory name, uint256 rewardPerPoint) public onlyOwner {
        require(bytes(name).length > 0, "Game name must not be empty.");
        require(rewardPerPoint > 0, "Reward per point must be greater than zero.");

        // Ensure game name is unique
        for (uint256 i = 1; i <= gameCount; i++) {
            require(keccak256(bytes(games[i].name)) != keccak256(bytes(name)), "Game name must be unique.");
        }

        gameCount++;
        games[gameCount] = Game(gameCount, name, rewardPerPoint);
        emit GameCreated(gameCount, name, rewardPerPoint);
    }

    function scorePoints(uint256 gameId, uint256 points) public {
        require(games[gameId].id != 0, "Game does not exist.");
        require(points > 0, "Points must be greater than zero.");

        Player storage player = players[msg.sender];
        uint256 tokensEarned = points * games[gameId].rewardPerPoint;

        require(tokensEarned <= totalTokens, "Not enough tokens available.");

        player.wallet = msg.sender;
        player.score += points;
        player.tokens += tokensEarned;
        totalTokens -= tokensEarned;

        emit PlayerScored(msg.sender, gameId, points, tokensEarned);
    }

    function redeemTokens(uint256 tokenAmount) public {
        Player storage player = players[msg.sender];
        require(tokenAmount > 0, "Token amount must be greater than zero.");
        require(player.tokens >= tokenAmount, "Insufficient tokens.");

        player.tokens -= tokenAmount;

        // Here you can implement additional functionality for redeeming tokens,
        // such as transferring tokens or providing rewards.

        emit TokensRedeemed(msg.sender, tokenAmount);
    }

    function getPlayerInfo(address playerAddress) public view returns (uint256 score, uint256 tokens) {
        Player storage player = players[playerAddress];
        return (player.score, player.tokens);
    }

    function getGameInfo(uint256 gameId) public view returns (string memory name, uint256 rewardPerPoint) {
        Game storage game = games[gameId];
        return (game.name, game.rewardPerPoint);
    }
}
