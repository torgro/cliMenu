function Set-MenuItem
{
[cmdletbinding()]
Param
(
    [string]
    $Name
    ,
    [string]
    $DisplayName
    ,
    [string]
    $Description
    ,
    [scriptblock]
    $Action
    ,
    [bool]
    $DisableConfirm
    ,
    [int]
    $MenuName
)

BEGIN
{
    $f = $MyInvocation.InvocationName
    Write-Verbose -Message "$f - START"
}

PROCESS
{
    $menu = (Get-Menu -Name "$MenuName")

    If (-not $menu)
    {
        write-error -Message "Unable to find menu with name [$MenuName]"
        break
    }
    
    $menuIndex = $script:Menus.IndexOf($menu)
    $menuItem = $script:Menus[$menuIndex].MenuItems.Where({$_.Name -eq "$Name"})

    if (-not $menuItem)
    {
        Write-Error -Message "$f -  Unable to find menuItem with name [$Name]"
        break
    }

    $menuItemIndex = $script:Menus[$menuIndex].IndexOf($menuItem)
    foreach ($key in $PSBoundParameters.Keys)
    {
        Write-Verbose -Message "$f -  Setting [$key] to value $($PSBoundParameters.$key)"
        $script:Menus[$menuIndex].MenuItems[$menuItemIndex].$key = $PSBoundParameters.$key
    }
}

END
{
    Write-Verbose -Message "$f - END"
}
}