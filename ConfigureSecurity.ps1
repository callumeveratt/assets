# Function to set an environment variable
# $environmentVariable = the name of the env variable, $environmentValue = value of the environment variable
function Set-EnvironmentVariable ([string] $environmentVariable, [string] $environmentValue) {
    $target=[System.EnvironmentVariableTarget]::Machine
    Write-Host "Setting environment value for $environmentVariable to $environmentValue"
    [System.Environment]::SetEnvironmentVariable("$environmentVariable","$environmentValue",$target)
}

# Function to set a registry key value
# $keyName = path to the key value, $valueName = key to change, $value = value to set
function Set-RegistryKey([string] $keyName, [string] $valueName, [string] $value, [string] $kind)
{
    [Microsoft.Win32.Registry]::SetValue($keyName, $valueName, $value, $kind)
}

# Function to TLS defaults for .Net
function Set-DotNetFrameworkDefaultTLSVersion() {
    Write-Host "Starting Set Dot Net Framework Default TLS Version"
    Set-RegistryKey -keyName "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319" -valueName "SystemDefaultTlsVersions" -value "1" -kind "dword"
    Set-RegistryKey -keyName "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319" -valueName "SchUseStrongCrypto" -value "1" -kind "dword"
    Set-RegistryKey -keyName "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\.NETFramework\v4.0.30319" -valueName "SystemDefaultTlsVersions" -value "1" -kind "dword"
    Set-RegistryKey -keyName "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\.NETFramework\v4.0.30319" -valueName "SchUseStrongCrypto" -value "1" -kind "dword"
    Write-Host "Finished Set Dot Net Framework Default TLS Version"
}

# Function to disable windows firewall
function Disable-WindowsFirewall() {
    Write-Host "Running Disable Windows Firewall"
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
    Write-Host "Completed Disable Windows Firewall"
}

# Function to disable IE enhanced security
function Disable-IEesc() {
    Write-Host "Running Disable IE Enhanced Security"
    Set-RegistryKey -keyName "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" -valueName "IsInstalled" -value "0" -kind "dword"
    Set-RegistryKey -keyName "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" -valueName "IsInstalled" -value "0" -kind "dword"
    Write-Host "Completed Disable IE Enhanced Security"
}

# Function to disable weak SSL Ciphers (SSL 2.0 and SSL 3.0)
function Disable-SSLCipher() {
    Write-Host "Running Disable SSL 2.0"
    Set-RegistryKey -keyName "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server" -valueName "Enabled" -value "0" -kind "dword"
    Set-RegistryKey -keyName "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server" -valueName "DisabledByDefault" -value "1" -kind "dword"
    Set-RegistryKey -keyName "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Client" -valueName "Disabled" -value "0" -kind "dword"
    Set-RegistryKey -keyName "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Client" -valueName "DisabledByDefault" -value "1" -kind "dword"
    Write-Host "Completed Disable SSL 2.0"

    Write-Host "Running Disable SSL 3.0"
    Set-RegistryKey -keyName "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server" -valueName "Enabled" -value "0" -kind "dword"
    Set-RegistryKey -keyName "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server" -valueName "DisabledByDefault" -value "1" -kind "dword"
    Set-RegistryKey -keyName "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Client" -valueName "Disabled" -value "0" -kind "dword"
    Set-RegistryKey -keyName "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Client" -valueName "DisabledByDefault" -value "1" -kind "dword"
    Write-Host "Completed Disable SSL 3.0"
}

# Function to disable weak TLS Ciphers (TLS 1.0 and TLS 1.1)
function Disable-TLS() {
    Write-Host "Running Disable TLS 1.0"
    Set-RegistryKey -keyName "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -valueName "Enabled" -value "0" -kind "dword"
    Set-RegistryKey -keyName "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -valueName "DisabledByDefault" -value "1" -kind "dword"
    Set-RegistryKey -keyName "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client" -valueName "Disabled" -value "0" -kind "dword"
    Set-RegistryKey -keyName "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client" -valueName "DisabledByDefault" -value "1" -kind "dword"
    Write-Host "Completed Disable TLS 1.0"

    Write-Host "Running Disable TLS 1.1"
    Set-RegistryKey -keyName "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server" -valueName "Enabled" -value "0" -kind "dword"
    Set-RegistryKey -keyName "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server" -valueName "DisabledByDefault" -value "1" -kind "dword"
    Set-RegistryKey -keyName "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client" -valueName "Disabled" -value "0" -kind "dword"
    Set-RegistryKey -keyName "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client" -valueName "DisabledByDefault" -value "1" -kind "dword"
    Write-Host "Completed Disable TLS 1.1"
}
