#$script:menuItems = New-Object -TypeName System.Collections.ArrayList

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
        $script:Menus.Where({$_.Name -eq "$MenuName"})
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
    $menu = $script:Menus.Where({$_.Name -eq "$Name"})
    
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
    [int]
    $MenuID
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
        $menuSelected = $script:Menus[$MenuID].MenuItems[$InvokeItem]

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

            if ($menuSelected.ActionScriptblock)
            {
                Write-Host -Object "Invoking [$($menuSelected.Name)]" -ForegroundColor DarkYellow
                $menuSelected.ActionScriptblock.Invoke()
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

    if ($PSBoundParameters.ContainsKey("MenuID"))
    {
        $menu = Get-Menu -MenuId $MenuID
        if (-not $menu)
        {
            Write-Error -Exception "$f -  Could not find menu with ID [$MenuID]"
        }
    }
    else 
    {
        $menu = Get-Menu -MainMenu
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
        if ($menuSelected.ActionScriptblock)
        {
            Write-Host -Object "Invoking [$($menuSelected.Name)]" -ForegroundColor DarkYellow
            $menuSelected.ActionScriptblock.Invoke()
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


