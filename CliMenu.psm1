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

$script:Menus = New-Object -TypeName System.Collections.ArrayList

$script:MenuOptions = [pscustomobject]@{
    MenuFillChar    = "*"
    MenuFillColor   = [consolecolor]::White
    Heading         = "" 
    HeadingColor    = [consolecolor]::White
    SubHeading      = ""
    SubHeadingColor = [consolecolor]::White
    FooterText      = ""
    FooterTextColor = [consolecolor]::White
    MenuItemColor   = [consolecolor]::White
    MenuNameColor   = [consolecolor]::White
    MaxWith         = 80
}

function Get-Menu
{
<#
.Synopsis
   Get a list of menus
.DESCRIPTION
   Returns a list of menus by name, id or just the main menu
.EXAMPLE
   C:> Get-Menu
   
   Returns all menus
.EXAMPLE
   C:> Get-Menu -MainMenu
   
   Returns the Main Menu only
.EXAMPLE
   C:> Get-Menu -MenuID 1
   
   Returns the menu of the specified index
.EXAMPLE
   C:> Get-Menu -Name main*
   
   Returns all the menus which has a name that starts with main
.NOTES
   NAME: Get-Menu
   AUTHOR: Tore Groneng tore@firstpoint.no @toregroneng tore.groneng@gmail.com
   LASTEDIT: Aug 2016
   KEYWORDS: General scripting Controller Menu   
#>
[cmdletbinding(DefaultParameterSetName='none')]
[OutputType([PSCustomObject])]
Param
(
    [Parameter(ParameterSetName="MainMenu")]
    [switch]
    $MainMenu
    ,
    [Parameter(ParameterSetName='ByID')]
    [int]
    $MenuID
    ,
    [Parameter(ParameterSetName="ByName")]
    [string]
    $Name
)

BEGIN
{
    $f = $MyInvocation.InvocationName
    Write-Verbose -Message "$f - START"
}

PROCESS
{
    if ($PSBoundParameters.ContainsKey("MainMenu"))
    {
        $script:Menus.Where({$_.IsMainMenu -eq $true})
    }
    
    if ($PSBoundParameters.ContainsKey("MenuID"))
    {
        $script:Menus[$MenuID]
    }

    if ($PSBoundParameters.ContainsKey("Name"))
    {
        $script:Menus.Where({$_.Name -like "$Name"})
    }
    
    if($PSCmdLet.ParameterSetName -eq "none")
    {
        $script:Menus
    }
}

END
{
    Write-Verbose -Message "$f - END"
}
}

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

function Get-MenuOption
{
<#
.Synopsis
   Get a list menu options
.DESCRIPTION
   Returns a PSCustomObject with all menu options. This CmdLet has no parameters
.EXAMPLE
   C:> Get-MenuOption
   
   Returns all menu-items for all menus
.NOTES
   NAME: Get-MenuItem
   AUTHOR: Tore Groneng tore@firstpoint.no @toregroneng tore.groneng@gmail.com
   LASTEDIT: Aug 2016
   KEYWORDS: General scripting Controller Menu   
#>
[cmdletbinding()]
[OutputType([PSCustomObject])]
Param
()
    $script:MenuOptions
}

function New-Menu
{
<#
.Synopsis
   Create a new Menu
.DESCRIPTION
   You can create as many menus you like, however you may only have one main Menu. The Menu must
   have a name, hence the Name parameter is Mandatory. The first Menu you create will become
   the main Menu even if you do not specify the IsMainMenu switch.
.PARAMETER Name
   Normally you would like to specify a name without space and Camel-case the name.
.EXAMPLE
   C:> New-Menu -Name "MainMenu"
   
   This will create a new Menu with name MainMenu. If this is the first Menu, it will be
   created as a main Menu
.EXAMPLE
   C:> New-Menu -Name "MainMenu" -IsMainMenu
   
   This will create a new Menu with name MainMenu and set is as a main Menu
.EXAMPLE
   C:> New-Menu -Name "sub1" -DisplayName "Sub-Menu for Skype"
   
   This will create a new Menu with name sub1 and DisplayName Sub-Menu for Skype
.NOTES
   NAME: New-Menu
   AUTHOR: Tore Groneng tore@firstpoint.no @toregroneng tore.groneng@gmail.com
   LASTEDIT: Aug 2016
   KEYWORDS: General scripting Controller Menu   
#>
[cmdletbinding()]
[OutputType([PSCustomObject])]
Param
(
    [Parameter(Mandatory)]
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
    $newMenu = [PSCustomObject]@{
        Name = "$Name"
        DisplayName = "$DisplayName"
        IsMainMenu = $IsMainMenu
        MenuItems = New-Object -TypeName System.Collections.ArrayList
    }

    $currentMainMenu = Get-Menu -MainMenu

    if ($PSBoundParameters.ContainsKey("IsMainMenu"))
    {        
        if ($currentMainMenu)
        {
            Write-Error -Message "$f -  You can only have one Main Menu. Currently [$($currentMainMenu.Name)] is your main menu"    
            break        
        }      
    }

    if (-not $currentMainMenu)
    {
        $newMenu.IsMainMenu = $true
    }

    write-Verbose -Message "Creating menu [$Name]"
    $null = $script:Menus.Add($newMenu)
    $newMenu
}

END
{

}
}

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

function Set-MenuOption
{
[cmdletbinding()]
Param
(
    [string]
    $MenuFillChar = "*"
    ,
    [ConsoleColor]
    $MenuFillColor = [consolecolor]::white
    ,
    [string]
    $Heading = "[Heading not set]"
    ,
    [ConsoleColor]
    $HeadingColor = [consolecolor]::white
    ,
    [string]
    $SubHeading = "[SubHeading not set]"
    ,
    [ConsoleColor]
    $SubHeadingColor = [consolecolor]::white
    ,
    [string]
    $FooterText
    ,
    [ConsoleColor]
    $FooterTextColor = [consolecolor]::white
    ,
    [consolecolor]
    $MenuItemColor = [consolecolor]::white
    ,
    [consolecolor]
    $MenuNameColor = [consolecolor]::white
    ,
    [int]
    $MaxWith = 80
)

BEGIN
{
    $f = $MyInvocation.InvocationName
    Write-Verbose -Message "$f - START"

    foreach ($key in $PSBoundParameters.Keys)
    {
        Write-Verbose -Message "$f -  Setting [$key] to value $($PSBoundParameters.$key)"
        $script:MenuOptions.$key = $PSBoundParameters.$key
    }
    
    if ([string]::IsNullOrEmpty($script:MenuOptions.FooterText))
    {        
        $script:MenuOptions.FooterText = "$(Get-date) - Running as $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"
    }
}

END
{
    Write-Verbose -Message "$f - END"
}
}

function Show-Menu
{
<#
.Synopsis
   Show a Menu.
.DESCRIPTION
   If executed without parameters, it will build and show the main Menu. If the MenuID parameter is 
   specified, it will show the menu with that ID. You may also use the cmdlet to invoke a specific 
   Menu-Item on a specific menu.
.EXAMPLE
   C:> Show-Menu
   
   This will show the main Menu if defined.
.EXAMPLE
   C:> Show-Menu -MenuId 1
   
   This will show the menu at index 1. Use Get-Menu to find the index (zero-based array)
.EXAMPLE
   C:> Show-Menu -InvokeItem 2 -MenuId 0
   
   This will invoke the Menu-Item at index 2 on the form at index 0. If the Menu-Item requires
   confirmation before invoking it, the user will be prompted before invokation.
.EXAMPLE
   C:> Show-Menu -InvokeItem 2 -MenuId 0 -force
   
   This will invoke the Menu-Item at index 2 on the form at index 0. If the Menu-Item requires
   confirmation before invoking it, the user will not be prompted before invokation since the
   force flag has been specified.
.NOTES
   NAME: Show-Menu
   AUTHOR: Tore Groneng tore@firstpoint.no @toregroneng tore.groneng@gmail.com
   LASTEDIT: Aug 2016
   KEYWORDS: General scripting Controller Menu   
#>
[cmdletbinding()]
Param
(
    [int]
    $InvokeItem
    ,
    [switch]
    $Force
    ,
    [string]
    $MenuName
)

BEGIN
{
    $f = $MyInvocation.InvocationName
    Write-Verbose -Message "$f - START"

    $mainMenu = Get-Menu -MainMenu

    if (-not $mainMenu)
    {
        Write-Warning -Message "Please add a menu first using the New-Menu cmdlet"
        break
    }
}

PROCESS
{
    if ($PSBoundParameters.ContainsKey("InvokeItem"))
    {
        $menuSelected = (Get-Menu -Name $MenuName).MenuItems[$InvokeItem] #$script:Menus[$MenuID].MenuItems[$InvokeItem]

        if($menuSelected)
        {
            if ($menuSelected.ConfirmBeforeInvoke)
            {
                if (-not $Force)
                {                    
                    $Continue = Read-Host -Prompt "Are you sure you want to execute [$($menuSelected.Name)] Y/N?"
                    If ($Continue -ne "y")
                    {
                        Write-Host -Object "Execution aborted" -ForegroundColor DarkYellow
                        break
                    }
                }                
            }

            if ($menuSelected.Action)
            {
                Write-Host -Object "Invoking [$($menuSelected.Name)]" -ForegroundColor DarkYellow
                $menuSelected.Action.Invoke()
                Write-Host -Object "Invoke DONE!" -ForegroundColor DarkYellow
                break
            }            
        }                     
    }
}

END
{
    $menuLines = New-Object -TypeName System.Collections.ArrayList
    $maxWith = $script:MenuOptions.MaxWith

    function Get-MenuLine
    {
    Param
    (
        [string]
        $Text
        ,
        [consolecolor]
        $Color = [System.ConsoleColor]::White
        ,
        [bool]
        $IsMenuItem = $false
    )
        if ($IsMenuItem)
        {
            $textLine = "  " + "$Text"
            $textLine += " " * (($maxWith - 1) - $textLine.length - 1)
        }
        else 
        {
            $maxWith = $script:MenuOptions.MaxWith
            $textLength = $Text.Length
            $textBlanks = (($maxWith - 2) - $textLength) / 2
            $textLine = " " * $textBlanks + $Text
            $textLine += " " * (($maxWith - 1) - $textLine.Length - 1)
        }
        
        [pscustomobject]@{
            Text = "$textLine"
            Color = $color
        }
    }

    if ($PSBoundParameters.ContainsKey("MenuName"))
    {
        $menu = Get-Menu -Name $MenuName        
    }
    else 
    {
        $menu = Get-Menu -MainMenu
    }

    if (-not $menu)
    {
        Write-Error -Exception "$f -  Could not find menu"
    }

    $menuIndex = $script:Menus.IndexOf($menu)
   
    $menuFrame = $script:MenuOptions.MenuFillChar * ($maxWith - 2)
    $null = $menuLines.Add((Get-MenuLine -Text $menuFrame -color $script:MenuOptions.MenuFillColor))

    $null = $menuLines.Add((Get-MenuLine -Text $menu.DisplayName -Color $script:MenuOptions.MenuNameColor))
    
    $menuEmptyLine = " " * ($maxWith - 2)
    $null = $menuLines.Add((Get-MenuLine -Text $menuEmptyLine -color $script:MenuOptions.MenuFillColor))
    $null = $menuLines.Add((Get-MenuLine -Text $menuEmptyLine -color $script:MenuOptions.MenuFillColor))

    $null = $menuLines.Add((Get-MenuLine -Text $script:MenuOptions.Heading -color $script:MenuOptions.HeadingColor))
    $null = $menuLines.Add((Get-MenuLine -Text $menuEmptyLine -color $script:MenuOptions.MenuFillColor))

    $null = $menuLines.Add((Get-MenuLine -Text $script:MenuOptions.SubHeading -color $script:MenuOptions.SubHeadingColor))
    $null = $menuLines.Add((Get-MenuLine -Text $menuEmptyLine -color $script:MenuOptions.MenuFillColor))
    $null = $menuLines.Add((Get-MenuLine -Text $menuEmptyLine -color $script:MenuOptions.MenuFillColor))

    $null = $menuLines.Add((Get-MenuLine -Text $menuFrame -color $script:MenuOptions.MenuFillColor))
    $null = $menuLines.Add((Get-MenuLine -Text $menuEmptyLine -color $script:MenuOptions.MenuFillColor))

    foreach ($item in $menu.MenuItems)
    {  
        $menuColor = $script:MenuOptions.MenuItemColor
        $menuItemIndex = $script:menus[$menuIndex].MenuItems.IndexOf($item)
        $null = $menuLines.Add((Get-MenuLine -Text "$menuItemIndex. $($item.DisplayName)" -IsMenuItem $true -Color $menuColor))
    }

    $null = $menuLines.Add((Get-MenuLine -Text $menuEmptyLine -color $script:MenuOptions.MenuFillColor))
    $null = $menuLines.Add((Get-MenuLine -Text $menuEmptyLine -color $script:MenuOptions.MenuFillColor))

    $null = $menuLines.Add((Get-MenuLine -Text $script:MenuOptions.FooterText -color $script:MenuOptions.FooterTextColor))
    $null = $menuLines.Add((Get-MenuLine -Text $menuEmptyLine -color $script:MenuOptions.MenuFillColor))

    $null = $menuLines.Add((Get-MenuLine -Text $menuFrame -color $script:MenuOptions.MenuFillColor))

    foreach ($line in $menuLines)
    {
        Write-Host -Object $script:MenuOptions.MenuFillChar -ForegroundColor $script:MenuOptions.MenuFillColor -NoNewline
        Write-Host -Object $line.Text -ForegroundColor $line.Color -NoNewline
        Write-Host -Object $script:MenuOptions.MenuFillChar -ForegroundColor $script:MenuOptions.MenuFillColor
    }

    $userSelection = (Read-Host -Prompt "Please enter number to execute action")

    try
    {
        $actionItemSelectionIndex = [int]($userSelection)
    }
    catch
    {
        Write-Error -Message $_.Exception.Message
        Write-Host -Object "Menuitem not found [$userSelection]" -ForegroundColor DarkYellow
        break
    }

    $menuSelected = $menu.MenuItems[$actionItemSelectionIndex]

    if ($menuSelected)
    {
        if ($menuSelected.ConfirmBeforeInvoke)
        {
            $Continue = Read-Host -Prompt "Are you sure you want to execute [$($menuSelected.Name)] Y/N?"
            If ($Continue -ne "y")
            {
                Write-Host -Object "Execution aborted" -ForegroundColor DarkYellow
                break
            }
        }
        if ($menuSelected.Action)
        {
            Write-Host -Object "Invoking [$($menuSelected.Name)]" -ForegroundColor DarkYellow
            $menuSelected.Action.Invoke()
            Write-Host -Object "Invoke DONE!" -ForegroundColor DarkYellow
        }
    }
    else
    {
        Write-Host -Object "Menuitem not found [$userSelection]" -ForegroundColor DarkYellow
    }

    Write-Verbose -Message "$f-  END"
}
}


