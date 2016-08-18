[cmdletbinding()]
Param(
    [Parameter(Mandatory)]
    [string]
    $APIkey
)

$tags = @(
    "Menu"
    , 
    "Cli"
    , 
    "Sub-Menu"
    , 
    "Main-Menu"
    , 
    "Show-Command"
    ,
    "Console"
    ,
    "Menus"
    ,
    "Main"
    ,
    "Sub"
    ,
    "User"
    ,
    "Menu"
)

$fileList = Get-ChildItem -Filter .\functions\*.ps1 | where name -NotLike "*Tests*"
$ExportedFunctions = New-Object System.Collections.ArrayList
$fileList | foreach {
    $null = $ExportedFunctions.Add($_.BaseName)
}

Update-ModuleManifest -Path .\CliMenu.psd1 -Tags $tags -FunctionsToExport $ExportedFunctions

Publish-Module -NuGetApiKey $APIkey -Name .\CliMenu.psd1