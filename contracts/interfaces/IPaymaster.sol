// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

interface IPaymaster {
    function fundUser(address user, uint256 amount) external;

    function getUserBalance(address user) external view returns (uint256);

    function withdraw(address payable to, uint256 amount) external;

    function withdrawStake(address payable to) external;

    function unlockStake() external;

    function addStake(uint32 unstakeDelaySec) external payable;

    function withdrawUserBalance(address user, uint256 amount) external returns (bool);

    function transferOwnership(address newOwner) external ;

    function getPosts() external view returns (address[] memory) ;
    
}
