function New-Menu
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
}

PROCESS
{
    $newMenu = [PSCustomObject]@{
        Id  =0
        Name = "$Name"
        DisplayName = "$DisplayName"
        IsMainMenu = $false
    }

    if ($PSBoundParameters.ContainsKey("IsMainMenu"))
    {
        $currentMainMenu = $script:Menus.Where({$_.IsMainMenu -eq $true})
        if ($currentMainMenu)
        {
            Write-Error -Message "$f -  You can only have one Main Menu. Currently [$($currentMainMenu.Name)] is your main menu"    
            break        
        }
        else
        {
            $newMenu.IsMainMenu = $true
        }
    }

    $index = $script:Menus.Add($newMenu)
    $script:Menus[$index].Id = $index

}

END
{

}
}