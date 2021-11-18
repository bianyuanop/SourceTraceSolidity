// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

contract Main is AccessControlEnumerable {
    using Counters for Counters.Counter;
    struct Action {
        uint256 time;
        string location;
        string ev;
    }

    struct User {
        string name;
        string describe;
    }

    struct Commodity {
        string name;
        uint256 produce_time;
        string describe;
        Action[] deliver_chain;
    }

    mapping(address => User) public users;
    mapping(uint256 => Commodity) public commodities;

    bytes32 constant DELIVER = keccak256("DELIVER");
    bytes32 constant SELLOR = keccak256("SELLOR");
    bytes32 constant PRODUCER = keccak256("PRODUCER");

    Counters.Counter public counter;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setDeliver(address target) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(DELIVER, target);
    }

    function setSellor(address target) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(SELLOR, target);
    }

    function setProducer(address target) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(PRODUCER, target);
    }

    function register(string memory _name, string memory _describe) public returns (address) {
        users[msg.sender].name = _name;
        users[msg.sender].describe = _describe;

        return msg.sender;
    }

    function produce(string memory name, string memory describe, string memory loc, string memory ev) public onlyRole(PRODUCER) returns (uint256) {
        uint256 id = counter.current();

        Commodity storage comm = commodities[id];
        comm.name = name;
        comm.produce_time = block.timestamp;
        comm.describe = describe;

        Action[] storage actions = comm.deliver_chain;
        actions.push(Action(block.timestamp, loc, ev));

        counter.increment();

        return id;
    }

    function deliver(uint256 id, string memory location, string memory ev) public onlyRole(DELIVER) {
        Action memory action;
        action.time = block.timestamp;
        action.location = location;
        action.ev = ev;

        Commodity storage commodity = commodities[id];
        commodity.deliver_chain.push(action);
    }

    function sell(uint256 id, string memory loc, string memory ev) public onlyRole(SELLOR) {
        Commodity storage commodity = commodities[id];
        Action memory action = Action(block.timestamp, loc, ev);
        commodity.deliver_chain.push(action);
    }

    function getCommodity(uint256 id) public view returns (Commodity memory) {
        return commodities[id];
    }

    function getDeliverChain(uint256 id) public view returns (Action[] memory) {
        return commodities[id].deliver_chain;
    }
}