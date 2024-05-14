import { ethers } from "hardhat"
import { spacelisk as spaceliskAddress } from "../../deployments/lisk_sepolia/output.json"
import { sleep } from "../utils/helpers";
import { parseEther } from "ethers";

async function main() {
    const spacelisk = await ethers.getContractAt("SpaceLisk", spaceliskAddress);

    // await spacelisk.updatePackage("abcd", ethers.parseEther("0.002"));
    // console.log("package updated")

    // await spacelisk.purchaseSubscription("abcd", "0xc80B282Cc68BF8ee6f70fEc96d1D9f7ab5dc3b3c", {value: parseEther("0.0001")});
    // console.log("subscription purchased")

    // await sleep(15);

    // const resp = await spacelisk.getSubscriptionInfo("0xc80B282Cc68BF8ee6f70fEc96d1D9f7ab5dc3b3c");
    // console.log(resp);

    const resp = await spacelisk.getUserBalance("0x22441385da0f1c4bd08073b322303ae496fbb35c");
    console.log(resp);

    // await spacelisk.fundUserPaymasterBalance("0x22441385da0f1c4bd08073b322303ae496fbb35c", {value: parseEther("0.002")});
    // console.log("paymaster funded on behalf of user")

    // await spacelisk.paymasterDeposit({value: parseEther("0.002")});
    // console.log("deposited successfully");

    //  await spacelisk.paymasterWithdraw("0xc80B282Cc68BF8ee6f70fEc96d1D9f7ab5dc3b3c", parseEther("0.002"));
    // console.log("withdrawal successfully");

    // await spacelisk.withdrawEther("0xc80B282Cc68BF8ee6f70fEc96d1D9f7ab5dc3b3c", ethers.parseEther("0.002"));
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});