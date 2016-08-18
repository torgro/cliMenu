function New-MenuItem
{
<#
.Synopsis
   Create a new Menu-Item for a Menu.
.DESCRIPTION
   Menu-Items are the action elements of the Menu. You add Menu-Items to a Menu. 
.EXAMPLE
   C:> New-MenuItem -Name "PasswordReset" -DisplayName "Reset a user password" -ActionScriptblock { Set-UserPassword }
   
   This will create a new Menu-Item. If selected it will execute the custom cmdlet Set-UserPassword. 
   Since no MenuId is specified, it will be added to the Main-Menu. The switch parameter DisableConfirm
   is not specified and the user will have to confirm the invokation after it has been selected. 
.EXAMPLE
   C:> $menu = Get-Menu -Name sub1
   C:> $NewMenuItem = @{
           Name = "UnlockUser"
           DisplayName = "Unlock a user"
           ActionScriptblock = { Unlock-UserObject }
           DisableConfirm = $true
       }
   C:> $menu | New-MenuItem @NewMenuItem
   
   This will create a new Menu-Item for the menu named sub1. The Menu-object is piped into the New-MenuItem cmdlet.
   It will invoke a custom cmdlet Unlock-UserObject and it will not confirm with the user before invokation.
.EXAMPLE
   C:> $NewMenuItem = @{
           Name = "UnlockUser"
           DisplayName = "Unlock a user"
           ActionScriptblock = { Unlock-UserObject }
           DisableConfirm = $true
       }
   C:> New-Menu -Name "sub1" -DisplayName "Sub-Menu for Skype" | New-MenuItem @NewMenuItem
   
   This will create a new Sub-Menu and add the UnlockUser Menu-Item to it using the pipeline.
   It will invoke a custom cmdlet Unlock-UserObject and it will not confirm with the user before invokation.
.EXAMPLE
   C:> $NewMenuItem = @{
           Name = "UnlockUser"
           DisplayName = "Unlock a user"
           ActionScriptblock = { Show-Command -Name Unlock-UserObject }
           DisableConfirm = $true
       }
   C:> New-Menu -Name "sub1" -DisplayName "Sub-Menu for Skype" | New-MenuItem @NewMenuItem
   
   This will create a new Sub-Menu and add the UnlockUser Menu-Item to it using the pipeline.
   It will invoke the Show-Command cmdlet which will show a windows form with the parameters of the custom 
   cmdlet Unlock-UserObject. It will not confirm with the user before invokation. The user may cancel the
   windows form without executing the cmdlet.
.NOTES
   NAME: New-MenuItem
   AUTHOR: Tore Groneng tore@firstpoint.no @toregroneng tore.groneng@gmail.com
   LASTEDIT: Aug 2016
   KEYWORDS: General scripting Controller Menu   
#>
[cmdletbinding(DefaultParameterSetName="ByValue")]
[OutputType([PSCustomObject])]
Param
(
    [Parameter(Mandatory, ParameterSetName="ByValue")]
    [Parameter(Mandatory,ParameterSetName="ByObject")]
    [string]
    $Name
    ,
    [Parameter(ParameterSetName="ByValue")]
    [Parameter(ParameterSetName="ByObject")]
    [string]
    $DisplayName
    ,
    [Parameter(ParameterSetName="ByValue")]
    [Parameter(ParameterSetName="ByObject")]
    [string]
    $Description
    ,
    [Parameter(ParameterSetName="ByValue")]
    [Parameter(ParameterSetName="ByObject")]
    [scriptblock]
    $ActionScriptblock
    ,
    [Parameter(ParameterSetName="ByValue")]
    [Parameter(ParameterSetName="ByObject")]
    [switch]
    $DisableConfirm
    ,
    
    [Parameter(ParameterSetName="ByValue")]
    [int]
    $MenuID
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
        ActionScriptblock = $ActionScriptblock
        ConfirmBeforeInvoke = -not $DisableConfirm
    }

    if ($script:Menus.count -eq 0)
    {
        Write-Verbose -Message "$f -  Creating main menu"
        $null = New-Menu -Name MainMenu -DisplayName "Main Menu" -IsMainMenu
    }

    if ($PSBoundParameters.ContainsKey("MenuID"))
    {
        $menu = Get-Menu -MenuID $MenuID
    }
    else
    {
        $menu = Get-Menu -MainMenu    
    }

    if ($PSBoundParameters.ContainsKey("MenuObject"))
    {
        $menu = $MenuObject
    }

    foreach ($Item in $menu.MenuItems)
    {
        if ($Item.Name -eq "$Name")
        {
            Write-Error -Message "$f -  Unable to find Main Menu"
            break
        }
    }

    $menuIndex = $script:Menus.IndexOf($menu)

    if ($menuIndex -eq -1)
    {
        throw "$f - Error, unable to find menu"
    }

    $null = $script:Menus[$menuIndex].MenuItems.Add($menuItem)
}

END
{
    Write-Verbose -Message "$f - END"
}
}