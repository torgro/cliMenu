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
{}

PROCESS
{
    $menu = $script:Menus.Where({$_.Name -eq "$Name"})

    if ($menu)
    {
        foreach ($key in $PSBoundParameters.Keys)
        {
            Write-Verbose -Message "$f -  Setting [$key] to value $($PSBoundParameters.$key)"
            $script:Menus[$menu.id].$key = $PSBoundParameters.$key
        }    
    }       
}

END
{}
}