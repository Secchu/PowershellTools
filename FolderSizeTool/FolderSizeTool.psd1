@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'FolderSizeTool.psm1'

    # Version number of this module.
    ModuleVersion = '1.0.0'

    # Supported PowerShell Host Version
    PowerShellVersion = '5.1'

    # Unique identifier for this module
    GUID = 'b4c73d9e-12fa-4567-89ab-cdef01234567'

    # Author of this module
    Author = 'Duong'

    # Company or vendor of this module
    CompanyName = 'Secchu'

    # Copyright statement for this module
    Copyright = '(c) 2026 Duong. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'Provides deep, recursive directory size diagnostics metrics.'

    # Functions to export from this module
    FunctionsToExport = @('Get-FolderSize')

    # Cmdlets to export from this module
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module
    AliasesToExport = @()

    # Private data to pass to the module specified in RootModule
    PrivateData = @{
        PSData = @{
            # Tags associated with this module
            Tags = @('Storage', 'FolderSize', 'FileManagement')
        }
    }
}
