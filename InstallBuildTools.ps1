$download_url = "https://community.chocolatey.org/install.ps1"
$localPath = [System.IO.Path]::Combine($PSScriptRoot, "InstallChoco.ps1")
$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile($download_url, $localPath)

if (-not (Test-Path .\InstallChoco.ps1)) {
    Write-Debug "Failed to download Choco install script!"
    exit
}

.\InstallChoco.ps1
choco install -y git
choco install -y dotnet-sdk

