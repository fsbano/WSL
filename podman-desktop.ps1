function Get-WSLRelease()
{
    Clear-Host
    Write-Host "************************************************" -ForegroundColor Green
    Write-Host "*             Automated Installer              *" -ForegroundColor DarkGreen
    Write-Host "*       Current Date: $(Get-Date)      *" -ForegroundColor Yellow
    Write-Host "************************************************" -ForegroundColor Green
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "[*] Getting the latest version of Windows Subsystem Linux" -ForegroundColor Cyan
    $github = Invoke-RestMethod -Uri https://api.github.com/repos/microsoft/WSL/releases/latest
    $x64Name = $github.assets | Where-Object { $_.browser_download_url -like "*x64.msi" } | Select-Object -ExpandProperty name 
    $x64Url = $github.assets | Where-Object { $_.browser_download_url -like "*x64.msi" } | Select-Object -ExpandProperty browser_download_url

    Write-Host "$x64Url"
    Invoke-WebRequest -Uri $x64Url -OutFile $x64Name -UseBasicParsing

    StartInstaller -Name "$x64Name"
}

function StartInstaller()
{
    param(
        [String]$Name
    )
    Start-Process msiexec -ArgumentList "/i $Name /qn" -Wait

    Get-WSLVersion
}

function Get-WSLVersion()
{
    winget list --accept-source-agreements | Select-String -Pattern "Windows Subsystem for Linux" | ForEach-Object { 
        if ( $_ -match "(\d+\.\d+\.\d+\.\d+)") {
            Set-VirtualMachinePlatform
        }
    }
}

function Set-VirtualMachinePlatform()
{
    Write-Host "Enable Feature Microsoft-Windows-Subsystem-Linux" -ForegroundColor Cyan
    Write-Host "Enable Feature VirtualMachinePlatform" -ForegroundColor Cyan
    wsl --install --no-distribution
}

winget list --accept-source-agreements | Select-String -Pattern "Windows Subsystem for Linux" | ForEach-Object { 
    if ( $_ -match "(\d+\.\d+\.\d+\.\d+)") {
        Write-Host "Windows Subsystem for Linux is alright installed"
        [Environment]::Exit(0)
    }
}

Get-WSLRelease
