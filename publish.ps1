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

$functionFilter =  Join-Path -path . -ChildPath Functions | Join-Path -ChildPath *.ps1

$fileList = Get-ChildItem -Filter $functionFilter | where name -NotLike "*Tests*"
$ExportedFunctions = New-Object System.Collections.ArrayList
$fileList | foreach {
    $null = $ExportedFunctions.Add($_.BaseName)
}
$moduleFilter = Join-Path -Path . -ChildPath *.psd1
$modulePath = Get-ChildItem -Filter $moduleFilter | Select-Object -ExpandProperty FullName
# Handled in build
#Update-ModuleManifest -Path $modulePath -Tags $tags -FunctionsToExport $ExportedFunctions

Publish-Module -NuGetApiKey $APIkey -Name $modulePath 