function Set-Menu
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
    [switch]
    $IsMainMenu
)

BEGIN
{
    $f = $MyInvocation.InvocationName
    Write-Verbose -Message "$f - START"
}

PROCESS
{
    $menu = Get-Menu -Name "$Name"
    
    if ($menu)
    {
        $menuIndex = $script:Menus.IndexOf($menu)

        foreach ($key in $PSBoundParameters.Keys)
        {
            Write-Verbose -Message "$f -  Setting [$key] to value $($PSBoundParameters.$key)"
            $script:Menus[$menuIndex].$key = $PSBoundParameters.$key
        }    
    }       
}

END
{
    Write-Verbose -Message "$f - END"
}
}