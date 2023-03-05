import Web3 from "web3/dist/web3.min.js";

var web3 = new Web3(new Web3.providers.HttpProvider('http://172.105.60.158:10001'));

export const getBlocks = async()=>{
    const block = []
    const number = await web3.eth.getBlockNumber();
    // console.log("Lasted Block", number)
    for(let i = 0; i <= 10; i++){
        const data = await web3.eth.getBlock(number-i);
        const totaltx = await web3.eth.getBlockTransactionCount(number-i);
        data.txn = totaltx
        // console.log(data,number-i)
        block.push(data);
    }
    return block;
}

export const searchTransection =async(trx)=>{
    
}

export const getAlltransaction =async()=>{
    const block = []
    const number = await web3.eth.getBlockNumber();
    for(let i = 0; i<= 4; i++){
        
    }
}

export const TotalBlockes =async()=>{
    const number = await web3.eth.getBlockNumber();
    return Number(number);
}



