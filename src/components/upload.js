import bytes from "bytes";
const UI_MAX_FILE_SIZE = 30 * 1024 * 1024;
const SERVER_URL = "http://localhost:5555"
const ADD_FILES_URL = `${SERVER_URL}/session/input-files`;
const VERIFY_VALIDATED_URL = `${SERVER_URL}/session/verify-validated`;
const verificationID = "0xf7fa9a2325117c9765c43ea62289a367634d531fd6df29dfa0251348d40d9a7b"


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
                address : "0x40eD56F577C142dE7D135E9F1C36dCCb5c730e77",
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