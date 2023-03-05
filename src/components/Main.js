import React, { useState, useEffect } from "react";
import Web3Modal from "web3modal";
import CoinbaseWalletSDK from "@coinbase/wallet-sdk";
import WalletConnect from "@walletconnect/web3-provider";
import Web3 from "web3/dist/web3.min.js";
import {useDropzone} from 'react-dropzone'
import { handleFiles, Verify_Contract } from "./upload";

export default function Main() {
  const [docBlock, setDocBlock] = useState();
  const [isLoading, setIsLoading] = useState(false);

  // useEffect(() => {
  //   const init = async () => {
    
  //   };
  //   init();
  // }, []);

  // const providerOptions = {
  //   coinbasewallet: {
  //     package: CoinbaseWalletSDK, 
  //     options: {
  //       appName: "Web 3 Modal Demo",
  //       infuraId: process.env.INFURA_KEY,
  //       rpc:"https://mainnet.infura.io/v3/"
  //     }
  //   },
  //   walletconnect: {
  //     package: WalletConnect, 
  //     options: {
  //       infuraId: "process.env.INFURA_KEY",
  //       rpc:{
  //         1:"https://mainnet.infura.io/v3/",
  //         56:"https://bsc-dataseed1.binance.org/"
  //       }
  //     }
  //   }
  // };

  // const web3Modal = new Web3Modal({
  //   cacheProvider: true, // optional
  //   providerOptions // required
  // });

  // const [showBasic, setShowBasic] = useState(false);
  // const [provider, setProvider] = useState();
  // const [library, setLibrary] = useState();

  // const slicingHash = (str) => {
  //   const first = str.slice(0, 10);
  //   const second = str.slice(56);
  //   return first + "..." + second;
  // };

  // const connectWallet = async () => {
  //   try {
  //     const provider = await web3Modal.connect();
  //     // console.log(provider)
  //     setProvider(provider)
  //     // const library = new Web3(provider)
  //     console.log(web3Modal)
  //   } catch (error) {
  //     console.error(error);
  //   }
  // };

  // const dissconnection = async()=>{
  //   try {
  //    web3Modal.clearCachedProvider()
  //   if (provider?.disconnect && typeof provider.disconnect === 'function') {
  //     await provider.disconnect()
  //   }
  //   } catch (error) {
  //     console.log(error)
  //   }
  // }



  const [selectedFiles, setSelectedFiles] = useState([]);
  const { getRootProps, getInputProps } = useDropzone({
    onDrop: async (acceptedFiles) => {
      setIsLoading(true);
      await handleFiles(acceptedFiles);
      setIsLoading(false);
    },
  });

  const handleFileChange = (event) => {
    console.log(event)
    setSelectedFiles(event);
  };



  // useEffect(() => {
  //   // if (web3Modal.cachedProvider) {
  //   //   connectWallet();
  //   // }
  // }, []);


  return (
    <>
      <div>
      <div {...getRootProps()}>
      <input {...getInputProps()} />
  
        
          <p>Drop the files here ...</p> 
          <p>Drag 'n' drop some files here, or click to select files</p>
      
    </div>
        <button onClick={()=>Verify_Contract()}>send</button>
        {/* <button onClick={()=>dissconnection()}>DissConnect</button> */}
      </div>
    </>
  );
}
