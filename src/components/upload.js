import bytes from "bytes";


const UI_MAX_FILE_SIZE = 30 * 1024 * 1024;
const SERVER_URL = "http://localhost:5555"
const ADD_FILES_URL = `${SERVER_URL}/session/input-files`;
const VERIFY_VALIDATED_URL = `${SERVER_URL}/session/verify-validated`;
const RESTART_SESSION_URL = `${SERVER_URL}/session/clear`;
const verificationID = "0x444e45c877a1930c5151965ce4a206172cd3c9e7b8c56d4e10ceb64ce6e87e12"


const fetchAndUpdate = async (URL, fetchOptions) => {
      try {
        const rawRes = await fetch(URL, {
          credentials: "include",
          method: fetchOptions?.method || "GET", // default GET
          ...fetchOptions,
        });
        const res = await rawRes.json();
        console.log("Verify API response ", res);
        return res;
      } catch (e) {
        console.log(e);
      }
}

export const Verify_Contract = async() =>{
    const data = { 
                address : "0xb9aA8BB1D19E9DCf1AB7148ed12FcBf36972e6DE",
                chainId : "880",
                contextVariables: {
                    abiEncodedConstructorArguments: "",
                    msgSender: ""
                },
                verificationId: verificationID}
    await fetchAndUpdate(VERIFY_VALIDATED_URL, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          contracts: [data],
        }),
      })
}

export const restart_session = async()=>{
   const data = await fetch(RESTART_SESSION_URL, {
        credentials: "include",
        method: "POST",
      });
    console.log("Clear file", data)
}



export const handleFiles = async (files) => {
    // const handleeFiles = async (files: DropzoneFile[]) => {
    console.log("Running")
    const jsonBody = { files: {} };

    for (const file of files) {
      if (file.size > UI_MAX_FILE_SIZE) {
        const humanReadableSize = bytes(file.size);
        return;
      }
      let filePath = file.path;
      if (file.path.startsWith("/")) filePath = file.path.substring(1);
      if (file.type === "application/zip" || file.type === "application/x-zip-compressed") {
        const formData = new FormData();
        formData.append("files", file);
        console.log("Files ", formData)
        await fetchAndUpdate(ADD_FILES_URL, {
          method: "POST",
          body: formData,
        });
      } else {
        jsonBody.files[filePath] = await file.text();
      }
    }
    
    if (Object.keys(jsonBody.files).length > 0) {
        console.log("FILE", (jsonBody))
      await fetchAndUpdate(ADD_FILES_URL, {
        method: "POST",
        body: JSON.stringify(jsonBody),
        headers: { "Content-Type": "application/json" },
      });
    }
  };