function New-MenuItem
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
    $ConfirmBeforeInvoke = $true
    ,
    [int]
    $ParentMenuID
)

BEGIN 
{
    $f = $MyInvocation.InvocationName
    Write-Verbose -Message "$f - START"
}

PROCESS
{
    $menuItem = [PSCustomObject]@{
        Id = 0
        Name = "$Name"
        DisplayName = "$DisplayName"
        Description = "$Description"
        ActionScriptblock = $ActionScriptblock
        ConfirmBeforeInvoke = $ConfirmBeforeInvoke
        ParentMenu = 0
    }

    $nameConflict = $null
    $nameConflict = $script:menuItems.Where({$_.Name -eq "$Name"})

    if ($script:Menus.count -eq 0)
    {
        New-Menu -Name MainMenu -DisplayName "Main Menu" -IsMainMenu
    }

    if (-not $nameConflict)
    {
        $MainMenu = Get-Menu -MainMenu

        if (-not $MainMenu)
        {
            Write-Error -Message "$f -  Unable to find Main Menu"
            break
        }

        $menuItem.ParentMenu = $MainMenu.Id

        Write-Verbose -Message "$f -  Adding menuItem [$Name]"

        $insertedId = $script:menuItems.Add($menuItem)        
        $script:menuItems[$insertedId].Id = $insertedId
    }
    else
    {
        Write-Warning -Message "$f -  Menuitem with [$Name] already exists"
    }
}

END
{
    Write-Verbose -Message "$f-  END"
}
}