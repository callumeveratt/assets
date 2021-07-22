Write-Host "Installing WMI Exporter"
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install chocolatey-c​ore.extension
choco install prometheus-wmi-exporter.install --version 0.10.2 -y
Write-Host "Installed WMI Exporter"

$output = "c:\Metrics\wmiconfigstate.prom"
$stateversion  = "1.0.1"
$serviceName = "wmi_exporter"
$MSMQCollector = "msmq"
$IISCollector = "iis"
$MSSQLCollector = "mssql"
$MetricsPath = "C:\Metrics"
$ImagePathlocation = "HKLM:\SYSTEM\CurrentControlSet\Services\wmi_exporter\"
$RegString = "ImagePath"
$ImagePathstr1 = '"C:\Program Files\wmi_exporter\wmi_exporter.exe" --log.format logger:eventlog?name=wmi_exporter --telemetry.addr :9182 --collector.textfile.directory C:\Metrics --collectors.enabled '
$global:CoreCollectorsEnabled = "cpu,cs,logical_disk,net,os,process,service,textfile,system" -split ","
$CollectorServiceQuery = @"
--collector.service.services-where "Name='wmi_exporter' or Name='TermService' or Name='OctopusDeploy Tentacle' or Name='vss' or Name='Coalmine' or Name='BITS' or Name='NTD' or Name='ADWS' or Name='DFSR' or Name='DNS' or Name='ADWS' or Name='wuauserv' or Name='VMTools' or Name='W3SVC' or Name='OpenVPNService' or Name='OpenVPNServiceInteractive' or Name='amazonssmagent' or Name='splunkforwarder' or Name='MSMQ' or Name='DHCPServer' or Name='smtpsvc' or Name='RMSMessageService' or Name='sqlbrowser' or Name='chef-client' or Name='chef-client' or Name='Prizm' or Name='stunnel' or Name='Mirth Connect Service' or Name LIKE 'sqlagent%' or Name LIKE 'mssql%' or Name LIKE 'sqlbackupagent%' or Name LIKE 'evault infostage%' or Name LIKE 'e360Service%' or Name LIKE 'eAppraisal%' or Name LIKE '%gatewayfileimporter%' or Name LIKE 'healthroster%' or Name LIKE 'bankstaffmessageservice%' or Name LIKE 'bankstaffassistant%' or Name LIKE 'rosterperform_%' or Name LIKE 'rosterperform data gatherer service%' or Name LIKE 'benchmarkinghub%' or Name LIKE 'allocatenhspstuckqueuenotifierservice%' or Name LIKE 'bankstaffassistant%' or Name LIKE 'mongodb%' or Name LIKE 'postgresql%' or Name LIKE 'time care doctor common%' or Name LIKE 'time care doctor windows%' or Name LIKE 'time care pool windows service%' or Name LIKE 'tc plan common service%' or Name LIKE 'Brhizo.HealthRoster.Interfacing%' or Name LIKE 'AllocateIntegrationMiddleware.%' or Name LIKE 'PASAppMessageService%' or Name LIKE 'Horio%'"
"@
$collectorprocessqry = @"
--collector.process.processes-where "Name LIKE '%w3wp%' or Name='wmi_exporter' or Name='java' or Name='Tentacle' or Name='Coalmine.Prometheus.Service' or Name LIKE '%MSW.MAPS.RosterPerform.BackgroundTasksService%' or Name LIKE '%ASW.SAM.Web%' or Name LIKE '%ASW.Planner.Web%' or Name LIKE '%Allocate.GatewayFileImporter%' or Name LIKE '%MSW.MAPS.RosterPerform.DataGatherer%' or Name LIKE '%MSW.MAPS.HealthRoster.ConsoleClient%' or Name LIKE '%sqlservr%' or Name LIKE '%MSW.MAPS.HealthRoster.BackgroundTasksService%' or Name='amazon-ssm-agent' or Name LIKE '%KeyMessenger%' or Name LIKE '%Magnum.AssistantService.Host%' or Name='mqsvc' or Name='openvpnserv2' or Name='openvpnserv' or Name='splunkd'"
"@
$collectorsqlqry =@" 
--collectors.mssql.classes-enabled="accessmethods,bufman,databases,genstats,locks,memmgr,sqlstats"
"@

Function IsIISInstalled {

return (Get-WindowsFeature -Name Web-Server).Installed

}

Function IsMSMQInstalled {

return (Get-WindowsFeature -Name MSMQ-Server).Installed

}

Function IsMSSQLInstalled {

return (Test-Path “HKLM:\Software\Microsoft\Microsoft SQL Server\Instance Names\SQL”)

}

function BuildArgsRegValue() {
    if (IsIISInstalled) {$CoreCollectorsEnabled = $CoreCollectorsEnabled + $IISCollector}
    if (IsMSMQInstalled) {$CoreCollectorsEnabled = $CoreCollectorsEnabled + $MSMQCollector}
    if (IsMSSQLInstalled) {$CoreCollectorsEnabled = $CoreCollectorsEnabled + $MSSQLCollector}
return $CoreCollectorsEnabled -join ","


}
$allcollectors = BuildArgsRegValue
Function RegKeyCreate ($allcollectors){

$ImagePathValue = "$ImagePathstr1 $allcollectors $CollectorServiceQuery $collectorprocessqry $collectorsqlqry"
write-host "$ImagePathValue"

$value1 = (Test-Path $ImagePathlocation)
If ($value1 -eq $true) 
{

Set-ItemProperty -Path $ImagePathlocation -Name "$Regstring" "$ImagePathValue" -Force

}

else {
Write-Host "WMI Exporter Registry key does not exist!"
}

 }

 Function CreateMetricsDir () {
 
 If(!(test-path $MetricsPath)){
      write-host "Creating $MetricsPath"
      New-Item -ItemType Directory -Force -Path $MetricsPath | Out-Null
 }
    }
Function RestartService() {

If (Get-Service $serviceName -ErrorAction SilentlyContinue) {

    If ((Get-Service $serviceName).Status -eq 'Running') {

        Restart-Service $serviceName
        Write-Host "Restarting $serviceName"

    } Else {

        Write-Host "$serviceName found, but it is not running, lets attempt to restart it"
        Start-Service $serviceName
    }

} Else {

    Write-Host "$serviceName service installed"

}


}

Function Build-Metrics-Output {
    New-Item -ItemType File $output -Force | Out-Null
    Clear-Content $output -Force
    $obj1 = @"
# HELP wmi_textfile_wmi_state_version help
# TYPE wmi_textfile_wmi_state_version gauge
"@
    $obj1 | Out-File -Force -Encoding utf8 $output

        $obj2 ="wmi_textfile_wmi_state_version{version=`"$($stateversion)`"} 1" | Out-File -Encoding utf8 $output -Append
$MyFile = Get-Content $output
$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllLines($output, $MyFile, $Utf8NoBomEncoding)
    }

BuildArgsRegValue
RegKeyCreate $allcollectors
CreateMetricsDir
RestartService
$stateversion = Build-Metrics-Output
