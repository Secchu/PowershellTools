function Set-OptimizeAdapter {
    <#
    .SYNOPSIS
        Optimizes Windows TCP/IP settings based on speed, ping, and network card.
    .PARAMETER AdapterName
        The explicit name of your network card (e.g., WiFi). This parameter is required.
    .PARAMETER DownloadSpeed
        Your download speed in Mbps (e.g., 24).
    .PARAMETER PingMs
        Your latency in milliseconds (e.g., 484).
    .PARAMETER RestartComputer
        Optional switch flag. If included, forces an immediate computer restart upon completion.
    .EXAMPLE
        Set-OptimizeAdapter -AdapterName WiFi -DownloadSpeed 24 -PingMs 484
    #>
    [CmdletBinding()]
        Param (
        [Parameter(Mandatory=$true)]
        [string]$AdapterName,

        # Enabled pipeline capabilities for direct speed test injection
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [alias("DownloadMbps")]
        [int]$DownloadSpeed,

        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [alias("領ngMs")]
        [int]$PingMs,
        
        [switch]$RestartComputer = $false
    )


    # Check for Administrative Privileges
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Warning "This function must be run as an Administrator!"
        return
    }

    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host " AUTOMATED TCP NETWORK OPTIMIZATION" -ForegroundColor Cyan
    Write-Host "==================================================" -ForegroundColor Cyan

    # Verify Specified Adapter Exists
    $Interface = Get-NetAdapter | Where-Object { $_.Name -eq $AdapterName }
    if (-not $Interface) {
        Write-Error "Specified adapter '$AdapterName' not found on this system. Please check the name and try again."
        return
    }
	
	# 3. Analyze Connection Profile
    Write-Host "[*] Telemetry Received -> Download Speed: $DownloadSpeed Mbps | Latency: $PingMs ms" -ForegroundColor Cyan
    Write-Host "[*] Analyzing parameters..." -ForegroundColor Yellow

    # Analyze Connection Profile
    Write-Host "[*] Analyzing parameters..." -ForegroundColor Yellow
    if ($DownloadSpeed -and $DownloadSpeed -lt 50) {
        Write-Host "[-] Speed profile: Under 50 Mbps. Optimizing for lower bandwidth overhead." -ForegroundColor Magenta
    }
    if ($PingMs -and $PingMs -gt 150) {
        Write-Host "[!] Ping profile: High Latency ($PingMs ms Bufferbloat detected). Enforcing strict low-delay packet rules." -ForegroundColor Red
    }

    # Global TCP Infrastructure Optimizations
    Write-Host "[*] Configuring Global TCP Stack..." -ForegroundColor Yellow

    Set-NetTCPSetting -SettingName InternetCustom -AutoTuningLevelLocal Normal
    Set-NetTCPSetting -SettingName InternetCustom -CongestionProvider Cubic
    Set-NetTCPSetting -SettingName InternetCustom -EcnCapability Enabled
    Set-NetTCPSetting -SettingName InternetCustom -Timestamps Disabled

    if ($PingMs -gt 300) {
        Set-NetTCPSetting -SettingName InternetCustom -InitialRtoMs 3000
    } else {
        Set-NetTCPSetting -SettingName InternetCustom -InitialRtoMs 2000
    }

    # Targeted Advanced Settings on your actual Network Adapter Hardware
    Write-Host "[*] Tweaking hardware registry offloads for '$AdapterName'..." -ForegroundColor Yellow

    Disable-NetAdapterLso -Name $AdapterName -IPv4 -Confirm:$false -ErrorAction SilentlyContinue
    Enable-NetAdapterRss -Name $AdapterName -Confirm:$false -ErrorAction SilentlyContinue
    Set-NetAdapterAdvancedProperty -Name $AdapterName -DisplayName "Interrupt Moderation" -DisplayValue "Disabled" -Confirm:$false -ErrorAction SilentlyContinue

    # Windows Multimedia Throttling Bypass
    $RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
    if (Test-Path $RegistryPath) {
        Set-ItemProperty -Path $RegistryPath -Name "NetworkThrottlingIndex" -Value 4294967295 -Type DWord
        Set-ItemProperty -Path $RegistryPath -Name "SystemResponsiveness" -Value 0 -Type DWord
    }

    Write-Host "==================================================" -ForegroundColor Green
    Write-Host " SUCCESS: Settings applied to $AdapterName!" -ForegroundColor Green
    Write-Host "==================================================" -ForegroundColor Green

    # Optional Immediate Forced Restart Block
    if ($RestartComputer) {
        Write-Host "[!] RestartComputer flag detected. Forcing immediate system restart..." -ForegroundColor Red
        Start-Sleep -Seconds 2
        Restart-Computer -Force
    } else {
        Write-Host " Please manually REBOOT your computer to complete setup." -ForegroundColor Yellow
    }
}

# Explicitly export the function to the session shell
Export-ModuleMember -Function Set-OptimizeAdapter
