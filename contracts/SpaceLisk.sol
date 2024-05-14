// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "./interfaces/IPaymaster.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SpaceLisk is Ownable {
    event SubscriptionActive(address account, string package);
    event UpdatedPackage(string package, uint256 price);
    event Received(address sender, uint256 amount);
    event PaymasterUserTopup(address user, uint256 amount);
    event PaymasterUserWithdraw(address user, uint256 amount);

    IPaymaster private immutable paymaster;
    address private constant entrypoint = 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789;

    struct Subscription {
        string packageId;
        uint256 timestamp;
    }

    mapping(string id => uint256 price) packages;
    mapping(address user => Subscription) subscriptions;

    constructor(address _paymaster) {
        paymaster = IPaymaster(_paymaster);
    }

    // purchase a spacelisk rpc subscription package
    function purchaseSubscription(
        string memory package,
        address account
    ) external payable {
        require(packages[package] != 0, "Invalid package");
        require(msg.value >= packages[package], "Insufficient funds");
        Subscription memory currentSub = subscriptions[account];
        if (
            (keccak256(abi.encode(currentSub.packageId)) ==
                keccak256(abi.encode(package))) &&
            (hasThirtyDaysPassed(currentSub.timestamp) == false)
        ) {
            revert("User already has an active subscription on this package");
        }
        Subscription memory newpackage = Subscription(
            package,
            currentSub.timestamp + 30 days
        );
        subscriptions[account] = newpackage;
        emit SubscriptionActive(account, package);
    }

    // topup user paymaster balance
    function fundUserPaymasterBalance(address user) external payable {
        paymaster.fundUser(user, msg.value);
        emit PaymasterUserTopup(user, msg.value);
    }

    // withdraw user funds deposited in paymaster
    function withdrawUserPaymasterBalance(
        address payable to,
        uint256 amount
    ) external {
        require(
            address(this).balance >= amount,
            "insuffient funds in contract"
        );
        bool success = paymaster.withdrawUserBalance(msg.sender, amount);
        require(success, "Error occured while withdrawing balance");
        to.transfer(amount);
        emit PaymasterUserWithdraw(msg.sender, amount);
    }

    // get user paymaster balance
    function getUserBalance(address user) external view returns (uint256) {
        return paymaster.getUserBalance(user);
    }

    //update package
    function updatePackage(string memory package, uint256 price) external onlyOwner {
        packages[package] = price;
        emit UpdatedPackage(package, price);
    }

    //get package price
    function getPackagePrice(string memory package) external view returns (uint256) {
        return packages[package];
    }

    //get subscription info
    function getSubscriptionInfo(address user) external view returns (Subscription memory) {
        return subscriptions[user];
    }

    function hasThirtyDaysPassed(
        uint256 storedTimestamp
    ) private view returns (bool) {
        uint256 currentBlockTimestamp = block.timestamp;
        uint256 secondsInThirtyDays = 30 days;
        if (storedTimestamp > currentBlockTimestamp) {
            return false;
        }
        return (currentBlockTimestamp - storedTimestamp) >= secondsInThirtyDays;
    }

    // helper functions to withdraw funds from contract

    function withdrawEther(
        address payable recipient,
        uint256 amount
    ) external onlyOwner {
        require(msg.sender == owner(), "Only owner can withdraw Ether");
        require(amount <= address(this).balance, "Insufficient funds");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Failed to withdraw Ether");
    }

    function withdrawERC20(
        IERC20 token,
        address recipient,
        uint256 amount
    ) external onlyOwner {
        require(msg.sender == owner(), "Only owner can withdraw ERC20 tokens");
        require(
            token.transfer(recipient, amount),
            "ERC20 token transfer failed"
        );
    }

    // Below are paymaster admin functions

    // withdraw paymaster funds deposited in entrypoint contract
    function paymasterWithdraw(
        address payable to,
        uint256 amount
    ) external onlyOwner {
        paymaster.withdraw(to, amount);
    }

    // witrhdraw paymaster funds staked in entrypoint contract
    function paymasterWithdrawStake(address payable to) external onlyOwner {
        paymaster.withdrawStake(to);
    }

    // unlock staked paymaster funds in entrypoint contract
    function paymasterUnlockStake() external onlyOwner {
        paymaster.unlockStake();
    }

    // add more staked to entrypoint contract
    function paymasterDeposit() external payable onlyOwner {
        (bool success, ) = entrypoint.call{value: msg.value}(
            abi.encodeWithSignature("depositTo(address)", address(paymaster))
        );
        require(success, "Call failed");
    }

    function paymasterAddStake(
        uint32 unstakeDelaySec
    ) external payable onlyOwner {
        (bool success, ) = address(paymaster).call{value: msg.value}(
            abi.encodeWithSignature("addStake(uint32)", unstakeDelaySec)
        );
        require(success, "Call failed");
    }

    function paymasterTransferOwnership(address to) external onlyOwner {
        paymaster.transferOwnership(to);
    }

    function getPosts() external view returns (address[] memory) {
        return paymaster.getPosts();
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}
