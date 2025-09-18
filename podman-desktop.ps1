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

    Get-WSLVersion
}

function StartInstaller()
{
    param(
        [String]$Name
    )
    Start-Process msiexec -ArgumentList "/i $Name /qn" -Wait
}

function Get-WSLVersion()
{
    winget list --accept-source-agreements | Select-String -Pattern "Windows Subsystem for Linux" | ForEach-Object { 
        if ( $_ -match "(\d+\.\d+\.\d+\.\d+)") {
            $WSLVersionInstalled = $matches[0]
            Write-Host ("Windows Subsystem for Linux Version " + $WSLVersionInstalled + " is Installed") -ForegroundColor Magenta
            $x64Name | ForEach-Object {
               if ($_ -match "(\d+\.\d+\.\d+\.\d+)") {
                  if ($matches[0] -ne "$WSLVersionInstalled") {
                     Write-Host ("Windows Subsystem for Linux Upgrading to Version: " + $matches[0]) -ForegroundColor Green
	                   StartInstaller -Name "$x64Name"
                     Set-VirtualMachinePlatform
                  } else {
                     Write-Host ("The Windows Linux subsystem is at the latest version") -ForegroundColor DarkGreen
                     Start-Sleep -Seconds 5
                     exit 0 
                  } 
               }
            }
        }
    }
   StartInstaller -Name "$x64Name"
   Set-VirtualMachinePlatform
}

function Set-VirtualMachinePlatform()
{
    Write-Host "Enable Feature Microsoft-Windows-Subsystem-Linux" -ForegroundColor Cyan
    Write-Host "Enable Feature VirtualMachinePlatform" -ForegroundColor Cyan
    wsl --install --no-distribution
    wsl --version
    Restart-Computer -Force
}

winget list --accept-source-agreements | Select-String -Pattern "Windows Subsystem for Linux" | ForEach-Object { 
    if ( $_ -match "(\d+\.\d+\.\d+\.\d+)") {
        Write-Host "Windows Subsystem for Linux is alright installed"
    }
}

Get-WSLRelease
