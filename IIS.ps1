# Function to download a file
# $url = path to url, $localPath = path to download the file, $sha256Hash = hash to verify the download if required 
function DownloadFile([string] $url, [string] $localPath, [string] $sha256Hash = "") {
    Write-Host "Download of $url starting"
    Invoke-WebRequest -Uri $url -OutFile $localPath
    if (!(Test-Path -Path $localPath)) {
        $Error = "Download of $url failed"
        exit;
    }

    if ($sha256Hash -ne "") {
        $localPathHash = (Get-FileHash $localPath -Algorithm "SHA256").Hash

        if ($sha256Hash -ne $localPathHash) {
            $Error = ("Download of $url failed due to invalid hash (" + $localPathHash + ")")
            Remove-Item -Path $localPath
            exit;            
        }
    }
    Write-Host "Download of $url complete"    
}

# Function to install an msi
# $msiPath = path to the MSI install, $extraArguments = any additional command line arguments
function Install-Msi([string] $msiPath, [string] $extraArguments) {
    Write-Host "Install of $msiPath starting"
    if (!(Test-Path -Path $msiPath))
    {
        $Error = "Install of $msiPath failed - file does not exist"
        exit;
    }

    $exitCode = (Start-Process -FilePath msiexec.exe -NoNewWindow -Wait -PassThru -ArgumentList "/i $msiPath /qn /norestart /L*v $msiPath.install.log $extraArguments").ExitCode

    if ($exitCode -ne 0 -and $exitCode -ne 1641 -and $exitCode -ne 3010)
    {
        $Error = "Failed to install $msiPath (exit code: $exitCode)"
        exit;
    }
    Write-Host "Install of $msiPath complete"
}

# Function to install and set up IIS
function Install-IISWindowsFeature() {
    # Add IIS as a Windows Feature
    Write-Host "IIS Windows Feature installation starting"
    Add-WindowsFeature -Name Web-Server -IncludeAllSubFeature

    # Disable IIS WebDAV and Directory Browsing
    Disable-WindowsOptionalFeature -Online -FeatureName IIS-WebDAV
    Disable-WindowsOptionalFeature -Online -FeatureName IIS-DirectoryBrowsing

    # Remove X-Powered-By header from IIS (top level)
    Remove-WebConfigurationProperty -PSPath MACHINE/WEBROOT/APPHOST -Filter system.webServer/httpProtocol/customHeaders -Name . -AtElement @{name='X-Powered-By'}

    # Set default for logging
    Set-WebConfigurationProperty "/system.applicationHost/sites/siteDefaults" -name logfile.directory -value "C:\Logs"

    # Remove default website
    Remove-WebSite -Name "Default Web Site"
    Remove-WebAppPool -Name "DefaultAppPool"

    Write-Host "IIS Windows Feature installation complete"
}

# Function to install IIS mod rewrite module
function Install-IISModReWrite([string] $downloadFolder) {
    $rewriteDownloadUrl = "https://download.microsoft.com/download/1/2/8/128E2E22-C1B9-44A4-BE2A-5859ED1D4592/rewrite_amd64_en-US.msi"
    $rewriteDownloadPath = "$downloadFolder\rewrite_amd64_en-US.msi"
    DownloadFile -url $rewriteDownloadUrl -localPath $rewriteDownloadPath -sha256Hash "37342FF2F585F263F34F48E9DE59EB1051D61015A8E967DBDE4075716230A32A"
    Install-Msi -msiPath $rewriteDownloadPath    
}

Install-IISWindowsFeature
Install-IISModRewrite
