$env:HF_HOME = "./gguf"
$env:LLAMA_CACHE = "./gguf"

& .\dist\llama-server.exe `
    --host 0.0.0.0 `
    --port 8080 `
    --no-mmproj `
    --models-max 1 `
    --models-preset models.ini

Read-Host "Press Enter to exit..."