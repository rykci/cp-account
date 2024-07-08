// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract AggregatedTask is Initializable, OwnableUpgradeable, UUPSUpgradeable{
    // Task blob CID stored in the contract
    string public taskBlobCID;

    // Event to log registration
    event RegisteredToTaskRegistry(address indexed taskContract, address indexed owner);
    event TaskCreated(string taskBlobCID);

     /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    
    // initialize the contract and register with task registry
    function initialize (
        string memory _taskBlobCID,
        address _taskRegistryContract
    ) initializer public {
        require(bytes(_taskBlobCID).length > 0, "Task Blob CID must not be empty");
        require(_taskRegistryContract != address(0), "Task registry contract address must be provided");

        taskBlobCID = _taskBlobCID;

        // Emit event to record task creation
        emit TaskCreated(_taskBlobCID);

        // Register this contract with the TaskRegistry
        registerToTaskRegistry(_taskRegistryContract);
    }

    // Private function to register this contract with the TaskRegistry
    function registerToTaskRegistry(address _taskRegistryContract) private {
        (bool success, ) = _taskRegistryContract.call(
            abi.encodeWithSignature(
                "registerTaskContract(address,address)",
                address(this),
                msg.sender
            )
        );
        require(success, "Failed to register task contract to TaskRegistry");

        // Emit the event after successful registration
        emit RegisteredToTaskRegistry(address(this), msg.sender);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}
}
