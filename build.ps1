[cmdletbinding()]
Param(
    [string]$ModuleFileName = 'CliMenu.psm1'
    ,
    [switch]$Major
    ,
    [switch]$Minor
    ,
    [switch]$LoadModule
    ,
    [string]$description = 'Easily build and edit CLI menus in Powershell'
)

END
{
    $f = $MyInvocation.InvocationName
    write-verbose -message "$f - ModuleFilename = $moduleFileName"
    Set-location -Path "$PSScriptRoot" -ErrorAction SilentlyContinue

    
    Write-Verbose -Message "$f - Starting build, getting files"

    $functionFilter = Join-Path -path . -ChildPath Functions | Join-Path -ChildPath *.ps1 
    
    $fileList = Get-ChildItem -Filter "$functionFilter" | where name -NotLike "*Tests*"

    #$ModuleName = (Get-ChildItem -Path $ModuleFileName -ErrorAction SilentlyContinue).BaseName
    $ModuleName = $ModuleFileName.Split('.') | Select-Object -first 1
    Write-Verbose -Message "$f -  Modulename is $ModuleName"

    Get-Module -Name $ModuleName | Remove-Module

    if([string]::IsNullOrEmpty($moduleName))
    {
        write-warning -message "Modulename is null or empty"
        break
    }

    $ExportedFunctions = New-Object System.Collections.ArrayList
    $fileList | foreach {
        Write-Verbose -Message "$F -  Function = $($_.BaseName) added"
        $null = $ExportedFunctions.Add($_.BaseName)
    }

    $ModuleLevelFunctions = $null

    foreach($function in $ModuleLevelFunctions)
    {
        Write-Verbose -Message "$f -  Checking function $function"
        if($ExportedFunctions -contains $function)
        {
            write-verbose -Message "$f -  Removing function $function from exportlist"
            $ExportedFunctions.Remove($function)
        }
        else
        {
            Write-Verbose -Message "$f -  Exported functions does not contain $function"
        }
    }

    Write-Verbose -Message "$f - Constructing content of module file"

    [string]$ModuleFile = ""
    foreach($file in $fileList)
    {
        $filecontent = Get-Content -Path $file.FullName -Raw -Encoding UTF8
        $filecontent = "$filecontent`n`n"
        $ModuleFile += $filecontent
    }
    [System.Version]$ver = $null

    $modulePath = $PSScriptRoot | Join-Path -ChildPath "$ModuleName.psd1"

    if((Test-Path -Path $moduleFileName -ErrorAction SilentlyContinue) -eq $true)
    {
        Write-Verbose -Message "$f - Getting version info"
        
        #Import-Module -Name $modulePath -Verbose:$false 
        $cliMenuModule = Get-Module -ListAvailable -Name $modulePath
        $ver = $cliMenuModule.Version        

        Remove-Module $ModuleName -Verbose:$false -ErrorAction SilentlyContinue   
        Write-Verbose -Message "$f - Removing previous version of $ModuleFileName"
        Remove-Item -Path $ModuleFileName
    }

    function Get-NextVersion
    {
    [cmdletbinding()]
    [outputtype([System.Version])]
    Param(
        [System.Version]$CurrentVersion
        ,
        [switch]$Major
        ,
        [switch]$Minor
    )
        [System.Version]$newVersion = $null
        $f = $MyInvocation.InvocationName
        Write-Verbose -Message "$f - START"

        if($Major)
        {
            Write-Verbose -Message "$F -  Bumping Major version"
            $build = $CurrentVersion.Build
            $ma = $CurrentVersion.Major + 1
            $mi = $CurrentVersion.Minor        
        }

        if($Minor)
        {
            Write-Verbose -Message "$f - Bumping Minor version"
            $build = $CurrentVersion.Build
            $ma = $CurrentVersion.Major
            $mi = $CurrentVersion.Minor + 1
        }

        if($Minor -and $Major)
        {
            Write-Verbose -Message "$f - Bumping Major and Minor version"
            $build = $CurrentVersion.Build
            $ma = $CurrentVersion.Major + 1
            $mi = $CurrentVersion.Minor + 1
        }

        if(-not $Minor -and -not $Major)
        {
            Write-Verbose -Message "$f - Bumping build version"
            $build = $CurrentVersion.Build + 1
            $ma = $CurrentVersion.Major
            $mi = $CurrentVersion.Minor
        }
    
        $newVersion = New-Object System.Version("$Ma.$Mi.$build.0")
        return $newVersion
    }

    function ConvertTo-PSArrayString 
    {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $InputObject
    )

        Begin 
        {
            # Initialize a buffer to hold everything coming down the pipe
            $buffer = [System.Collections.Generic.List[string]]::new()
        }

        Process 
        {
            # Collect every item as it arrives
            foreach ($item in $InputObject) 
            {
                $buffer.Add($item.ToString())
            }
        }

        end 
        {
            if ($buffer.Count -eq 0) 
            {
                return '@()'
            }
            
            # Now that we have EVERYTHING, join it into one string
            return '@("{0}")' -f ($buffer -join '","')
        }
    }

    if(-not $ver)
    {
        Write-Verbose -Message "$f - No previous version found, creating new version"
        $ver = New-Object System.Version("1.0.0.0")
    }

    if($Major)
    {    
        $ver = Get-NextVersion -CurrentVersion $ver -Major
    }

    if($Minor)
    {
        $ver = Get-NextVersion -CurrentVersion $ver -Minor
    }

    if($Minor -and $Major)
    {
         $ver = Get-NextVersion -CurrentVersion $ver -Minor -Major
    }

    if(-not $Minor -and -not $Major)
    {
        Write-Verbose -Message "$f - Defaults to bump build version"
        $ver = Get-NextVersion -CurrentVersion $ver
    }

    $versionString = [string]::Concat($ver.Major, ".", $ver.Minor, ".", $ver.Build)
    Write-Verbose -Message "$f - New version is $versionString"

    Write-Verbose -Message "$f - Writing contents to modulefile"
    Set-Content -Path $ModuleFileName -Value $ModuleFile -Encoding UTF8

    $ManifestName = "$((Get-ChildItem -Path $ModuleFileName -ErrorAction SilentlyContinue).BaseName).psd1"
    Write-Verbose -Message "$f - ManifestfileName is $ManifestName"

    if((Test-Path -Path $ManifestName -ErrorAction SilentlyContinue) -eq $true)
    {
        Write-Verbose -Message "$f - Removing previous version of $ManifestName"
        Remove-Item -Path $ManifestName
    }

    $FormatsToProcess = New-Object -TypeName System.Collections.ArrayList
    $formatsPath = $PSScriptRoot | Join-Path -ChildPath Formats
    foreach($file in (Get-ChildItem -Path $formatsPath))
    {
        Write-Verbose -Message "$f - Adding formats file $($file.FullName)"
        $null = $FormatsToProcess.Add($file.FullName)
    }

    Write-Verbose -Message "$f - Creating manifestfile"

    # $newModuleManifest = @{
    #     Path = $PSScriptRoot | Join-Path -ChildPath $ManifestName
    #     Author = "Tore Grøneng @toregroneng tore.groneng@gmail.com"
    #     Copyright = "(c) 2015 Tore Grøneng @toregroneng tore.groneng@gmail.com"
    #     CompanyName = "Rebase AS"
    #     ModuleVersion = $versionString
    #     FunctionsToExport = $ExportedFunctions
    #     RootModule = "$ModuleFileName"
    #     Description = "$description"
    #     PowerShellVersion = "4.0"
    #     ProjectUri = "https://github.com/torgro/cliMenu"
    #     FormatsToProcess = $FormatsToProcess
    # }

    $ManifestContent = @"
@{

# Script module or binary module file associated with this manifest.
RootModule = '$ModuleFileName'

# Version number of this module.
ModuleVersion = '$versionString'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = 'cf5f7609-0631-472e-8617-19f58a2adef4'

# Author of this module
Author = 'Tore Grøneng @toregroneng tore.groneng@gmail.com'

# Company or vendor of this module
CompanyName = 'Rebase AS'

# Copyright statement for this module
Copyright = '(c) 2015 Tore Groneng @toregroneng tore.groneng@gmail.com'

# Description of the functionality provided by this module
Description = '$Description'

# Minimum version of the PowerShell engine required by this module
PowerShellVersion = '4.0'

# Name of the PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# ClrVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
ProcessorArchitecture = 'None'

# Modules that must be imported into the global environment prior to importing this module
RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
FormatsToProcess = $($FormatsToProcess | ConvertTo-PSArrayString)

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
NestedModules = @()

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = $($ExportedFunctions | ConvertTo-PSArrayString)

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = @()

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @()

# DSC resources to export from this module
DscResourcesToExport = @()

# List of all modules packaged with this module
ModuleList = @()

# List of all files packaged with this module
FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        # Tags = @()

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/torgro/cliMenu'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        # ReleaseNotes = ''

        # Prerelease string of this module
        # Prerelease = ''

        # Flag to indicate whether the module requires explicit user acceptance for install/update/save
        # RequireLicenseAcceptance = $false

        # External dependent modules of this module
        # ExternalModuleDependencies = @()

    } # End of PSData hashtable

 } # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}
"@

    #New-ModuleManifest @newModuleManifest

    #Update-ModuleManifest -Path $newModuleManifest.Path -FunctionsToExport ($ExportedFunctions | ConvertTo-PSArrayString) -Verbose

    $manifestPath = $PSScriptRoot | Join-Path -ChildPath $ManifestName

    Write-Verbose -Message "$f -  Saving manifest [$manifestPath]"
    Set-Content -Path $manifestPath -Value $ManifestContent -Encoding UTF8

    #Write-Verbose -Message "$f -  Reading back content to convert to UTF8 (content management tracking)"
    #Set-Content -Path $ManifestName -Value (Get-Content -Path $ManifestName -Raw) -Encoding UTF8

    $Answer = "n"

    if(-not $LoadModule)
    {
        $Answer = Read-Host -Prompt "Load module $ModuleName? (Yes/No)"
    }

    if($Answer -eq "y" -or $Answer -eq "yes" -or $LoadModule)
    {
        Write-Verbose -Message "$f - Loading module"
        if(Test-Path -Path $ManifestName)
        {
            Import-Module -Name $modulePath
        }
        else
        {
            Write-Warning -Message "Modulefile [$modulePath] not found, module not imported!"
        }
    }
    else
    {
        Write-Verbose -Message "$f - Module not loaded"
    }

    Write-Verbose -Message "$f - END"
}
