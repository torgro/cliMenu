$script:Menus = New-Object -TypeName System.Collections.ArrayList

$script:MenuOptions = [pscustomobject]@{
    MenuFillChar    = "*"
    MenuFillColor   = [consolecolor]::White
    Heading         = "" 
    HeadingColor    = [consolecolor]::White
    SubHeading      = ""
    SubHeadingColor = [consolecolor]::White
    FooterText      = ""
    FooterTextColor = [consolecolor]::White
    MenuItemColor   = [consolecolor]::White
    MenuNameColor   = [consolecolor]::White
    MaxWith         = 80
}

function Get-Menu
{
<#
.Synopsis
   Get a list of menus
.DESCRIPTION
   Returns a list of menus by name, id or just the main menu
.EXAMPLE
   C:> Get-Menu
   
   Returns all menus
.EXAMPLE
   C:> Get-Menu -MainMenu
   
   Returns the Main Menu only
.EXAMPLE
   C:> Get-Menu -MenuID 1
   
   Returns the menu of the specified index
.EXAMPLE
   C:> Get-Menu -Name main*
   
   Returns all the menus which has a name that starts with main
.NOTES
   NAME: Get-Menu
   AUTHOR: Tore Groneng tore@firstpoint.no @toregroneng tore.groneng@gmail.com
   LASTEDIT: Aug 2016
   KEYWORDS: General scripting Controller Menu   
#>
[cmdletbinding(DefaultParameterSetName='none')]
[OutputType([PSCustomObject])]
Param
(
    [Parameter(ParameterSetName="MainMenu")]
    [switch]
    $MainMenu
    ,
    [Parameter(ParameterSetName='ByID')]
    [int]
    $MenuID
    ,
    [Parameter(ParameterSetName="ByName")]
    [string]
    $Name
)

BEGIN
{
    $f = $MyInvocation.InvocationName
    Write-Verbose -Message "$f - START"
}

PROCESS
{
    if ($PSBoundParameters.ContainsKey("MainMenu"))
    {
        $script:Menus.Where({$_.IsMainMenu -eq $true})
    }
    
    if ($PSBoundParameters.ContainsKey("MenuID"))
    {
        $script:Menus[$MenuID]
    }

    if ($PSBoundParameters.ContainsKey("Name"))
    {
        $script:Menus.Where({$_.Name -like "$Name"})
    }
    
    if($PSCmdLet.ParameterSetName -eq "none")
    {
        $script:Menus
    }
}

END
{
    Write-Verbose -Message "$f - END"
}
}