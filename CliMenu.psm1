$script:menuItems = New-Object -TypeName System.Collections.ArrayList

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
[cmdletbinding()]
Param
(
    [switch]
    $MainMenu
)

BEGIN
{}

PROCESS
{
    if ($PSBoundParameters.ContainsKey("MainMenu"))
    {
        $script:Menus.Where({$_.IsMainMenu -eq $true})
    }
    else
    {
        $script:Menus
    }
}

END
{}
}

function Get-MenuItem
{
[cmdletbinding(DefaultParameterSetName='none')]
Param
(
    [Parameter(ParameterSetName="ByName")]
    [string[]]
    $Name = "*"
    ,
    [Parameter(ValueFromPipeline,ParameterSetName="ById")]
    [int[]]
    $Id 
)

BEGIN
{
    $f = $MyInvocation.InvocationName
    Write-Verbose -Message "$f - START"
}

PROCESS
{
    if (-not $PSBoundParameters.ContainsKey("Name") -and -not $PSBoundParameters.ContainsKey("Id"))
    {
        $script:menuItems
    }

    if ($PSBoundParameters.ContainsKey("Name"))
    {
        foreach ($menuName in $Name)
        {
            $script:menuItems.Where({$_.Name -like $Name})
        }
    }

    if ($PSBoundParameters.ContainsKey("Id"))
    {
        $script:menuItems.Where({$_.Id -in $id})
    }
}

END
{
    Write-Verbose -Message "$f-  END"
}
}

function Get-MenuOption
{
[cmdletbinding()]
Param
()

    $script:MenuOptions
}

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

        if ($PSBoundParameters.ContainsKey("ParentMenuID"))
        {
             $menuItem.ParentMenu = $ParentMenuID
        }
        else
        {
            $menuItem.ParentMenu = $MainMenu.Id
        }        

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
    $ConfirmBeforeInvoke
)

BEGIN
{
    $f = $MyInvocation.InvocationName
    Write-Verbose -Message "$f - START"
}

PROCESS
{
    $menuItem = $script:menuItems.GetEnumerator().Where({$_.Name -eq "$Name"})

    if ($menuItem)
    {
        foreach ($key in $PSBoundParameters.Keys)
        {
            Write-Verbose -Message "$f -  Setting [$key] to value $($PSBoundParameters.$key)"
            $script:menuItems[$menuItem.id].$key = $PSBoundParameters.$key
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
    $SubHeading = "[SubHeading not set ]"
    ,
    [ConsoleColor]
    $SubHeadingColor = [consolecolor]::white
    ,
    [string]
    $FooterText = "[FooterText not set]"
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
        Write-Warning -Message "Please add a menu first"
        break
    }
}

PROCESS
{
    if ($PSBoundParameters.ContainsKey("InvokeItem"))
    {
        $menuSelected = $script:menuItems.Where({$_.ID -eq $InvokeItem})

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
        $mainMenu = Get-Menu | where Id -eq $MenuID
        if (-not $mainMenu)
        {
            Write-Error -Exception "$f -  Could not find menu with ID [$MenuID]"
        }
    }    
   
    $menuFrame = $script:MenuOptions.MenuFillChar * ($maxWith - 2)
    $null = $menuLines.Add((Get-MenuLine -Text $menuFrame -color $script:MenuOptions.MenuFillColor))

    $null = $menuLines.Add((Get-MenuLine -Text $mainMenu.DisplayName -Color $script:MenuOptions.MenuNameColor))
    
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

    $currentMenuItems = Get-MenuItem | Where-Object ParentMenu -eq $mainMenu.id

    foreach ($item in $currentMenuItems)
    {  
        $menuColor = $script:MenuOptions.MenuItemColor
        $null = $menuLines.Add((Get-MenuLine -Text "$($item.Id). $($item.DisplayName)" -IsMenuItem $true -Color $menuColor))
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
        $actionItemSelectionIndex = [int]$userSelection
    }
    catch
    {
        Write-Host -Object "Menuitem not found [$userSelection]" -ForegroundColor DarkYellow
        break
    }

    $menuSelected = $script:menuItems.Where({$_.ID -eq $actionItemSelectionIndex})

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


