// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@account-abstraction/contracts/interfaces/IPaymaster.sol";
import "@account-abstraction/contracts/interfaces/IEntryPoint.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Paymaster is IPaymaster, Ownable {
    address constant ENTRYPOINT = 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789;
    mapping(address => uint256) balances;
    address[] posts;

    function validatePaymasterUserOp(
        UserOperation calldata userOp,
        bytes32,
        uint256
    )
        external
        view
        override
        returns (bytes memory context, uint256 validationData)
    {
        require(
            balances[userOp.sender] > 0,
            "Paymaster: Insufficient staked funds for gas"
        );
        require(
            balances[userOp.sender] >=
                userOp.callGasLimit * userOp.maxFeePerGas,
            "Paymaster: Insufficient staked funds for gas"
        );
        context = abi.encode(userOp);
        validationData = 0;
    }

    /**
     * post-operation handler.
     * Must verify sender is the entryPoint
     * @param mode enum with the following options:
     *      opSucceeded - user operation succeeded.
     *      opReverted  - user op reverted. still has to pay for gas.
     *      postOpReverted - user op succeeded, but caused postOp (in mode=opSucceeded) to revert.
     *                       Now this is the 2nd call, after user's op was deliberately reverted.
     * @param context - the context value returned by validatePaymasterUserOp
     * @param actualGasCost - actual gas used so far (without this postOp call).
     */
    function postOp(
        PostOpMode mode,
        bytes calldata context,
        uint256 actualGasCost
    ) external {
        UserOperation memory userOp = abi.decode(context, (UserOperation));
        if (balances[userOp.sender] > 0) {
            uint256 newBalance = balances[userOp.sender] - actualGasCost;
            balances[userOp.sender] = newBalance;
        }
    }

    function getPosts() external view returns (address[] memory) {
        return posts;
    }

    function fundUser(address user, uint256 amount) external onlyOwner {
        uint256 newBalance = balances[user] + amount;
        balances[user] = newBalance;
    }

    function withdrawUserBalance(
        address user,
        uint256 amount
    ) external onlyOwner returns (bool) {
        require(balances[user] >= amount);
        uint256 balanceBefore = balances[user];
        uint256 newBalance = balances[user] - amount;
        balances[user] = newBalance;
        return balanceBefore - newBalance == balances[user];
    }

    function getUserBalance(address user) external view returns (uint256) {
        return balances[user];
    }

    // Functions to interact with entrypoint

    function withdraw(address payable to, uint256 amount) external onlyOwner {
        IEntryPoint(ENTRYPOINT).withdrawTo(to, amount);
    }

    function withdrawStake(address payable to) external onlyOwner {
        IEntryPoint(ENTRYPOINT).withdrawStake(to);
    }

    function unlockStake() external onlyOwner {
        IEntryPoint(ENTRYPOINT).unlockStake();
    }

    function addStake(uint32 unstakeDelaySec) external payable onlyOwner {
        (bool success, ) = address(ENTRYPOINT).call{value: msg.value}(
            abi.encodeWithSignature("addStake(uint32)", unstakeDelaySec)
        );
        require(success, "Call failed");
    }
}
