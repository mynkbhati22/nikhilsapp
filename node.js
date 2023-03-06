const Web3 = require('web3')
//https://node1.maalscan.io/
// const web3 = new Web3(new Web3.providers.HttpProvider("https://goerli.infura.io/v3/6e1530cd10fb4631a54c14a5f07b25a6"));
const web3 = new Web3(new Web3.providers.HttpProvider("https://node1.maalscan.io"));

//0xC2918db7b2b5D7963E092b9a8b31062AAd5043c8

const contractAddress = '0xC2918db7b2b5D7963E092b9a8b31062AAd5043c8'; 
const metadataSlot = '0x0'; 

const storage = async() =>{
    console.log("Running")
    const data = await web3.eth.getStorageAt(contractAddress, metadataSlot);
    console.log(data);
}

storage();
