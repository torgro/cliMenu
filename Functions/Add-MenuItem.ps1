function Add-MenuItem
{
<#
.Synopsis
   Add a Menu Item to a menu. 
.DESCRIPTION
   Add a Menu Item to a menu. This cmdlet support input (Menu Items) from the pipeline. 
.EXAMPLE
   C:> $items = Get-MenuItem -MenuName main
   C:> $items | Add-MenuItem -Menu subMenu
   
   This will copy Menu Items from the main Menu and add them to the Menu subMenu.
.EXAMPLE
   C:> $newMenuItem = @{
           Name = "UnlockUser"
           DisplayName = "Unlock a user"
           Action = { Show-Command -Name Unlock-UserObject }
           DisableConfirm = $true
       }
   C:> $item = New-MenuItem @newMenuItem
   C:> $item | Add-MenuItem -Menu main
   
   This will create a new Menu Item and add it to the main Menu using the pipeline.
.EXAMPLE
   C:> $newMenuItem = @{
           Name = "UnlockUser"
           DisplayName = "Unlock a user"
           Action = { Show-Command -Name Unlock-UserObject }
           DisableConfirm = $true
       }
   C:> $item = New-MenuItem @newMenuItem
   C:> Add-MenuItem -Menu main -MenuItem $item
   
   This will create a new Menu Item and add it to the main Menu.
.NOTES
   NAME: Add-MenuItem
   AUTHOR: Tore Groneng tore@firstpoint.no @toregroneng tore.groneng@gmail.com
   LASTEDIT: Aug 2016
   KEYWORDS: General scripting Controller Menu   
#>
[cmdletbinding()]
Param 
(
    [Parameter(Mandatory)]
    [string]
    $Menu
    ,
    [Parameter(Mandatory, ValueFromPipeline)]
    [PSCustomObject]
    $MenuItem
)

BEGIN
{
    $f = $MyInvocation.InvocationName
    Write-Verbose -Message "$f - START"
}

PROCESS
{
    Write-Verbose "getting menu"
    $menuObject = Get-Menu -Name "$Menu"
    
    if ($menuObject)
    {
        write-verbose "found menu"
        foreach ($Item in $menuObject.MenuItems)
        {
            if ($Item.Name -eq $MenuItem.Name)
            {
                Write-Error -Message "$f -  Duplicate MenuItem name detected in menu [$($menuObject.Name)]"
                break
            }
        }

        $menuIndex = $script:Menus.IndexOf($menuObject)
        write-verbose "menuindex [$menuIndex]"
        if ($menuIndex -ge 0)
        {
            $null = $script:Menus[$menuIndex].MenuItems.Add($MenuItem)
        }
    }
    else {
        Write-Verbose "no menuobject"
    } 
}

END
{
    Write-Verbose -Message "$f - END"
}
}