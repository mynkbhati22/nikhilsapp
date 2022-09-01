import Web3 from "web3/dist/web3.min.js";

var doc = new Web3(new Web3.providers.HttpProvider('http://172.105.60.158:10001'));

export const getBlocks = async()=>{
    const block = []
    const number = await doc.eth.getBlockNumber();
    console.log("Lasted Block", number)
    for(let i = 0; i <= 10; i++){
        const data = await doc.eth.getBlock(number-i);
        const totaltx = await doc.eth.getBlockTransactionCount(number-i);
        data.txn = totaltx
        console.log(data,number-i)
        block.push(data);
    }
    return block;
}

export const searchTransection =async(trx)=>{
    
}