# Space Lisk Contract

rename or copy .env.example to .env

```bash
copy .env.example .env
```

fill in the required in the required info like TEST_PRIVATE_KEY

## deploying

before deploying run 

```bash
npm i
```

to install the necessary dependencies. After that run the deploy command

```bash
npm run deploy
```

the contract addresses will be saved in a "deployments" folder.

## Deposit to entrypont

after deployment you will find a paymaster contract address. this is your own version of space lisk paymaster. before using the address in you userop you need to stake/deposit to the entry point. first navigate to /scripts/deposit.ts to edit the amount you will like to deposit the default is 0.01 ETH. after verifying the amount you can run the below command to deposit to the entry point

```bash
npm run deposit
```

 note you can manage your paymaster contract from the space lisk contract. the space lisk contract becomes the admin of the paymaster contract after deployment. checkout the test folder in scripts (/scripts/tests/test.ts), you will find various commented test operations.