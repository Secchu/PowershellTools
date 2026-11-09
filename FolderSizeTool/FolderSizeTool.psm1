function Get-FolderSize {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, HelpMessage="Please enter the full path to the directory.")]
        [string]$Path,
        
        [ValidateSet('B', 'MB', 'GB')]
        [string]$Unit = 'GB',

        # Optional boolean switch parameter (False by default)
        [switch]$IncludeDetails
    )

    process {
        if (-not (Test-Path -Path $Path)) {
            Write-Warning "Error: The path '$Path' does not exist."
            return
        }

        $subFiles = Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue

        if ($null -eq $subFiles) {
            Write-Warning "No files found or access was denied for items inside: $Path"
            return
        }

        # Establish unit modifiers
        switch ($Unit) {
            'B'  { $divisor = 1;   $unitLabel = "Bytes" }
            'MB' { $divisor = 1MB; $unitLabel = "MB" }
            'GB' { $divisor = 1GB; $unitLabel = "GB" }
        }

        # IF DETAILS ARE REQUESTED: Output a pure, flat array of custom file objects
        if ($IncludeDetails.IsPresent) {
            foreach ($file in $subFiles) {
                [PSCustomObject]@{
                    FileName     = $file.Name
                    Extension    = $file.Extension
                    Size         = "$([math]::Round($file.Length / $divisor, 2)) $unitLabel"
                    RawSize      = $file.Length  # Helpful for later sorting
                    RelativePath = $file.FullName.Replace($Path, "")
                }
            }
        } 
        # IF NO DETAILS REQUESTED: Output the high-level folder summary object
        else {
            $totalBytes = ($subFiles | Measure-Object -Property Length -Sum).Sum
            $finalSize = [math]::Round($totalBytes / $divisor, 2)

            [PSCustomObject]@{
                Path       = $Path
                FilesCount = $subFiles.Count
                TotalSize  = "$finalSize $unitLabel"
            }
        }
    }
}
