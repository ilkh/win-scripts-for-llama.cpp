# --- Configuration ---
$Repo = "ggml-org/llama.cpp"
$DistDir = Join-Path $PSScriptRoot "dist"
$GgufDir = "gguf"

# Create dist directory if it doesn't exist
if (-not (Test-Path $DistDir)) {
    New-Item -ItemType Directory -Path $DistDir | Out-Null
} else {
    Write-Host "Cleaning existing $DistDir ..."
    # Delete all files and folders inside the directory
    Get-ChildItem -Path $DistDir -Force | Remove-Item -Recurse -Force
}
if (-not (Test-Path $GgufDir)) {
    New-Item -ItemType Directory -Path $GgufDir | Out-Null
}

Write-Host "Fetching latest release info..."
$LatestRelease = Invoke-RestMethod -UseBasicParsing -Uri "https://api.github.com/repos/$Repo/releases/latest"

$Assets = $LatestRelease.assets | Where-Object {
    ($_.name -match "win.*cuda-13(\.1)?-x64\.zip$") `
    -and ($_.name -match "\.zip$")
}

if (-not $Assets -or $Assets.Count -eq 0) {
    Write-Host "No matching Windows x64 CUDA 13/13.1 assets found in latest release."
    exit 1
}

foreach ($Asset in $Assets) {
    $Url      = $Asset.browser_download_url
    $OutFile  = Join-Path $DistDir $Asset.name

    Write-Host "Downloading $($Asset.name)..."
    Invoke-WebRequest -Uri $Url -OutFile $OutFile

    Write-Host "Extracting $($Asset.name)..."
    Expand-Archive -Path $OutFile -DestinationPath $DistDir -Force

    Write-Host "Removing $($Asset.name)..."
    Remove-Item -Path $OutFile
}

Write-Host "Removing temp files in $DistDir ..."
Get-ChildItem -Path $DistDir -Filter *.zip -File | Remove-Item -Force
Write-Host "Done"