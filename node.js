const Web3 = require('web3')
const web3 = new Web3(new Web3.providers.HttpProvider("https://goerli.infura.io/v3/6e1530cd10fb4631a54c14a5f07b25a6"));
const UI_MAX_FILE_SIZE = 30 * 1024 * 1024;

const handleFiles = async (files) => {
    // const handleeFiles = async (files: DropzoneFile[]) => {
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
        await fetchAndUpdate(ADD_FILES_URL, {
          method: "POST",
          body: formData,
        });
      } else {
        jsonBody.files[filePath] = await file.text();
      }
    }
    
    if (Object.keys(jsonBody.files).length > 0) {
      await fetchAndUpdate(ADD_FILES_URL, {
        method: "POST",
        body: JSON.stringify(jsonBody),
        headers: { "Content-Type": "application/json" },
      });
    }
  };