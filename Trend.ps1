$managerUrl="https://app.deepsecurity.trendmicro.com:443/"
$env:LogPath = "$env:appdata\Trend Micro\Deep Security Agent\installer"
New-Item -path $env:LogPath -type directory
Start-Transcript -path "$env:LogPath\dsa_deploy.log" -append
echo "$(Get-Date -format T) - DSA download started"

if ( [intptr]::Size -eq 8 ) { 
    $sourceUrl=-join($managerUrl, "software/agent/Windows/x86_64/agent.msi") 
} else {
    $sourceUrl=-join($managerUrl, "software/agent/Windows/i386/agent.msi") 
}

echo "$(Get-Date -format T) - Download Deep Security Agent Package" $sourceUrl

$ACTIVATIONURL="dsm://agents.deepsecurity.trendmicro.com:443/"
$WebClient = New-Object System.Net.WebClient
$WebClient.Headers.Add("Agent-Version-Control", "on")
$WebClient.QueryString.Add("tenantID", "57898")
$WebClient.QueryString.Add("windowsVersion", (Get-CimInstance Win32_OperatingSystem).Version)
$WebClient.QueryString.Add("windowsProductType", (Get-CimInstance Win32_OperatingSystem).ProductType)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;

Try {
    $WebClient.DownloadFile($sourceUrl,  "$env:temp\agent.msi")
} Catch [System.Net.WebException] {
    echo " Please check that your Workload Security Manager TLS certificate is signed by a trusted root certificate authority."
    exit 2;
}

if ( (Get-Item "$env:temp\agent.msi").length -eq 0 ) {
    echo "Failed to download the Deep Security Agent. Please check if the package is imported into the Workload Security Manager. "
    exit 1
}


echo "$(Get-Date -format T) - DSA install started"
echo "$(Get-Date -format T) - Installer Exit Code:" (Start-Process -FilePath msiexec -ArgumentList "/i $env:temp\agent.msi /qn ADDLOCAL=ALL /l*v `"$env:LogPath\dsa_install.log`"" -Wait -PassThru).ExitCode 
echo "$(Get-Date -format T) - DSA activation started"
Start-Sleep -s 50
& $Env:ProgramFiles"\Trend Micro\Deep Security Agent\dsa_control" -r
& $Env:ProgramFiles"\Trend Micro\Deep Security Agent\dsa_control" -a $ACTIVATIONURL "tenantID:074C1A63-DCB8-727D-3FDA-1E4F7F169C08" "token:021AA142-BC3D-F9E4-3D70-1851A423FF02" "policyid:2601"
Stop-Transcript
echo "$(Get-Date -format T) - DSA Deployment Finished"

