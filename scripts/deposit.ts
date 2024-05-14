import hre from "hardhat"
import { abi as ENTRYPOINT_ABI } from "../EntryPoint.json";
import { sleep } from "./utils/helpers";
import { paymaster } from "../deployments/lisk_sepolia/output.json"

async function main() {

    const EP_ADDRESS = "0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789";
    const [signer1] = await hre.ethers.getSigners();

    const entryPoint = new hre.ethers.Contract(EP_ADDRESS, ENTRYPOINT_ABI, signer1);

    await entryPoint.depositTo(paymaster, {
      value: hre.ethers.parseEther("0.01"),
    });

    console.log("deposit was successful!");

    await sleep(20);

    const bal = await entryPoint.balanceOf(paymaster);
    console.log(bal);

}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
