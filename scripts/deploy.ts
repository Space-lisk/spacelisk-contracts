import hre from "hardhat"
import { saveDeploymentFile } from "./utils/helpers";

async function main() {

  const paymaster = await hre.ethers.deployContract("Paymaster");

  await paymaster.waitForDeployment();

  console.log(`Paymaster deployed to ${paymaster.target}`);

  const spacelisk = await hre.ethers.deployContract("SpaceLisk", [paymaster.target]);

  await spacelisk.waitForDeployment();

  console.log(`spacelisk deployed to ${spacelisk.target}`);

  await paymaster.transferOwnership(spacelisk.target);

  console.log("Paymaster ownership transfered to spacelisk contract successfully");
  
  const output = {
    spacelisk: spacelisk.target,
    paymaster: paymaster.target,
  }

  await saveDeploymentFile(output, "lisk_sepolia");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
