function Get-NetworkSpeed {
    <#
    .SYNOPSIS
        Performs an accurate internet speed test using Ookla's native CLI engine.
    .DESCRIPTION
        Automates bandwidth profiling, returns a clean PowerShell object,
        and translates raw bytes into readable Megabits per second (Mbps).
    .EXAMPLE
        Get-NetworkSpeed
    #>
    [CmdletBinding()]
    param()

    # Ensure the required engine is present on the computer path
    if (-not (Get-Command "speedtest.exe" -ErrorAction Ignore)) {
        Write-Error "The required speedtest.exe engine was not found. Please install it using: winget install --id=Ookla.Speedtest.CLI -e"
        return
    }

    Write-Host "[*] Running live internet speed test... Please wait." -ForegroundColor Yellow

    try {
        # Execute engine silently requiring JSON structured data back
        $RawJson = & "speedtest.exe" --format=json --accept-license --accept-gdpr
        $Data = $RawJson | ConvertFrom-Json

        # Extract bits and mathematically convert bytes/bandwidth array data into clean Mbps
        # Bandwidth from the engine is in bytes per second. Formula: (Bytes * 8) / 1,000,000 = Mbps
        [PSCustomObject]@{
            ISP         = $Data.isp
            ServerName  = "$($Data.server.name) ($($Data.server.location))"
            PingMs      = $Data.ping.latency
            JitterMs    = $Data.ping.jitter
            DownloadMbps = [math]::Round(($Data.download.bandwidth * 8) / 1000000, 2)
            UploadMbps   = [math]::Round(($Data.upload.bandwidth * 8) / 1000000, 2)
        }
    }
    catch {
        Write-Error "Failed to process the speed test execution stream. Details: $($_.Exception.Message)"
    }
}

Export-ModuleMember -Function Get-NetworkSpeed
