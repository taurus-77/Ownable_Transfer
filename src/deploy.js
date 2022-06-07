const ethers = require('ethers');
const AWSTERC1155 = require(`../build/contracts/AWSTERC1155.json`);
const { mnemonic } = require("../secret.json");

//Read bin and abi file to object; names of the solcjs-generated files renamed
bytecode = AWSTERC1155.bytecode;
abi = AWSTERC1155.abi;

//to create 'signer' object;here 'account'
const provider = new ethers.providers.JsonRpcProvider("https://speedy-nodes-nyc.moralis.io/e3771a4194ca1a8d20c96277/polygon/mumbai");
const wallet = ethers.Wallet.fromMnemonic(mnemonic);
const account = wallet.connect(provider);

const myContract = new ethers.ContractFactory(abi, bytecode, account);

//Ussing async-await for deploy method
async function main() {
    // If your contract requires constructor args, you can specify them here
    let _newOwner = account.address;
    const contract = await myContract.deploy(_newOwner);

    console.log(contract.address);
    console.log(contract.deployTransaction);
}

main();