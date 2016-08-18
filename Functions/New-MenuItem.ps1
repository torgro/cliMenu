function New-MenuItem
{
<#
.Synopsis
   Create a new Menu-Item for a Menu.
.DESCRIPTION
   Menu-Items are the action elements of the Menu. You add Menu-Items to a Menu. 
.EXAMPLE
   C:> New-MenuItem -Name "PasswordReset" -DisplayName "Reset a user password" -Action { Set-UserPassword }
   
   This will create a new Menu-Item. 
   Since no MenuId is specified, it return the new object to the console. The switch parameter 
   DisableConfirm is not specified and the user will have to confirm the invokation after it 
   has been selected.
.EXAMPLE
   C:> $menu = Get-Menu -Name sub1
   C:> $newMenuItem = @{
           Name = "UnlockUser"
           DisplayName = "Unlock a user"
           Action = { Unlock-UserObject }
           DisableConfirm = $true
       }
   C:> $menu | New-MenuItem @newMenuItem
   
   This will create a new Menu-Item for the menu named sub1. The Menu-object is piped into the New-MenuItem cmdlet.
   It will invoke a custom cmdlet Unlock-UserObject and it will not confirm with the user before invokation.
.EXAMPLE
   C:> $newMenuItem = @{
           Name = "UnlockUser"
           DisplayName = "Unlock a user"
           Action = { Unlock-UserObject }
           DisableConfirm = $true
       }
   C:> New-Menu -Name "sub1" -DisplayName "Sub-Menu for Skype" | New-MenuItem @newMenuItem
   
   This will create a new Sub-Menu and add the UnlockUser Menu-Item to it using the pipeline.
   It will invoke a custom cmdlet Unlock-UserObject and it will not confirm with the user before invokation.
.EXAMPLE
   C:> $newMenuItem = @{
           Name = "UnlockUser"
           DisplayName = "Unlock a user"
           Action = { Show-Command -Name Unlock-UserObject }
           DisableConfirm = $true
       }
   C:> New-Menu -Name "sub1" -DisplayName "Sub-Menu for Skype" | New-MenuItem @newMenuItem
   
   This will create a new Sub-Menu and add the UnlockUser Menu-Item to it using the pipeline.
   It will invoke the Show-Command cmdlet which will show a windows form with the parameters of the custom 
   cmdlet Unlock-UserObject. It will not confirm with the user before invokation. The user may cancel the
   windows form without executing the cmdlet.
.EXAMPLE
   C:> $mainMenu = New-Menu -Name Main -DisplayName "Main Menu" -IsMainMenu
   C:> $newMenuItem = @{
           Name = "UnlockUser"
           DisplayName = "Unlock a user"
           Action = { Show-Command -Name Unlock-UserObject }
           DisableConfirm = $true
       }
   C:> $item = New-MenuItem $newMenuItem
   C:> $item | Add-MenuItem -Menu Main

   This will create a new Sub-Menu and add the UnlockUser Menu-Item to it using the pipeline.
.NOTES
   NAME: New-MenuItem
   AUTHOR: Tore Groneng tore@firstpoint.no @toregroneng tore.groneng@gmail.com
   LASTEDIT: Aug 2016
   KEYWORDS: General scripting Controller Menu   
#>
[cmdletbinding(DefaultParameterSetName="none")]
[OutputType([PSCustomObject])]
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
    [switch]
    $DisableConfirm
    ,    
    [Parameter(ParameterSetName="ByName")]
    [string]
    $MenuName
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
    $menuItem = [PSCustomObject]@{        
        Name = "$Name"
        DisplayName = "$DisplayName"
        Description = "$Description"
        Action = $Action
        ConfirmBeforeInvoke = -not $DisableConfirm
    }

    if ($PSBoundParameters.ContainsKey("MenuName"))
    {
        $MenuObject = Get-Menu -Name $MenuName
    }
    else
    {
        #$menu = Get-Menu -MainMenu    
    }    

    foreach ($Item in $menu.MenuItems)
    {
        if ($Item.Name -eq "$Name")
        {
            Write-Error -Message "$f -  Duplicate MenuItem name detected in menu [$($menu.Name)]"
            break
        }
    }

    if ($PSBoundParameters.ContainsKey("MenuObject") -or $MenuObject)
    {
        $menuIndex = $script:Menus.IndexOf($MenuObject)
        $null = $script:Menus[$menuIndex].MenuItems.Add($menuItem)
    }

    #

    #if ($menuIndex -eq -1)
    #{
    #    throw "$f - Error, unable to find menu"
    #}

    #
    $menuItem
}

END
{
    Write-Verbose -Message "$f - END"
}
}