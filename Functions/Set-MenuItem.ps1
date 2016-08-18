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
    $ActionScriptblock
    ,
    [bool]
    $DisableConfirm
    ,
    [int]
    $MenuID
)

BEGIN
{
    $f = $MyInvocation.InvocationName
    Write-Verbose -Message "$f - START"
}

PROCESS
{
    $menuItem = $script:Menus[$MenuID].MenuItems.Where({$_.Name -eq "$Name"})

    if ($menuItem)
    {
        $menuItemIndex = $script:Menus[$MenuID].IndexOf($menuItem)
        foreach ($key in $PSBoundParameters.Keys)
        {
            Write-Verbose -Message "$f -  Setting [$key] to value $($PSBoundParameters.$key)"
            $script:Menus[$MenuID].MenuItems[$menuItemIndex].$key = $PSBoundParameters.$key
        }
    }
    else    
    {
        Write-Error -Message "$f -  Unable to find menuItem with name [$Name]"
    }
}

END
{
    Write-Verbose -Message "$f - END"
}
}