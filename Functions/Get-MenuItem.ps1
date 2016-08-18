function Get-MenuItem
{
<#
.Synopsis
   Get a list of menu-items
.DESCRIPTION
   Returns a list of menus by Menu-name, Menu-ID or the menu object
.EXAMPLE
   C:> Get-MenuItem
   
   Returns all menu-items for all menus
.EXAMPLE
   C:> Get-MenuItem -MenuName MainMenu
   
   Returns the menu-items for the menu with name MainMenu
.EXAMPLE
   C:> Get-MenuItem -MenuId 1
   
   Returns the menu-items for the menu with id 1
.EXAMPLE
   C:> $Menu = Get-Menu -Name SubMenuSkype
   C:> Get-MenuItem -MenuObject $Menu
   
   Returns all the menu-items for the menu with name SubMenuSkype
.EXAMPLE   
   C:> Get-Menu -Name SubMenuSkype | Get-MenuItem
   
   Returns all the menu-items for the menu with name SubMenuSkype
.NOTES
   NAME: Get-MenuItem
   AUTHOR: Tore Groneng tore@firstpoint.no @toregroneng tore.groneng@gmail.com
   LASTEDIT: Aug 2016
   KEYWORDS: General scripting Controller Menu   
#>
[cmdletbinding(DefaultParameterSetName='none')]
[OutputType([PSCustomObject])]
Param
(
    [Parameter(ParameterSetName="ByName")]
    [string[]]
    $MenuName
    ,
    [Parameter(ParameterSetName="ById")]
    [int]
    $MenuId
    ,
    [Parameter(ValueFromPipeline, ParameterSetName="ByObject")]
    [PSCustomObject]
    $MenuObject
)

BEGIN
{
    $f = $MyInvocation.InvocationName
    Write-Verbose -Message "$f - START"
}

PROCESS
{    
    if ($PSCmdlet.ParameterSetName -eq "none")
    {        
        $script:Menus.MenuItems 
    }

    if ($PSBoundParameters.ContainsKey("MenuName"))
    {
        write-verbose -message "$f -  Getting by MenuName"
        $script:Menus.Where({$_.Name -eq "$MenuName"}) | Select-Object -ExpandProperty MenuItems
    }

    if ($PSBoundParameters.Containskey("MenuId"))
    {
        $script:Menus[$MenuId].MenuItems
    }

    if ($PSCmdlet.ParameterSetName -eq "ByObject")
    {
        $MenuObject.MenuItems
    }
}

END
{
    Write-Verbose -Message "$f - END"
}
}