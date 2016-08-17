$str = @'
<root>
	<Header>
		<Customer Name="Customer1">
			<clientExceptionNotes>Execption delivery address</clientExceptionNotes >
		</Customer>
	</Header>
	<Header>
		<Customer Name="Customer2">
			<clientExceptionNotes></clientExceptionNotes >
		</Customer>
	</Header>
</root>
'@

$script:menuItems = New-Object -TypeName System.Collections.ArrayList

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

$script:Menus = New-Object -TypeName System.Collections.ArrayList

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
        if ($PSBoundParameters.ContainsKey("DisplayName"))
        {
            $script:Menus[$menu.id].DisplayName = "$DisplayName"
        }

        if ($PSBoundParameters.ContainsKey("IsMainMenu"))
        {
            $script:Menus[$menu.id].IsMainMenu = $true
            # FIXME need to check if we have a main menu
        }
        else
        {
            $script:Menus[$menu.id].IsMainMenu = $false
        }
    }
}

END
{}
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
        
    if(-not $menuItem)
    {
        Write-Error -Message "$f -  Unable to find menuItem with name [$Name]"
        break
    }

    $menuItem = $script:menuItems[$menuItem.id]

    if($PSBoundParameters.ContainsKey("DisplayName"))
    {
        $menuItem.DisplayName = "$DisplayName"
    }
    
    if($PSBoundParameters.ContainsKey("Description"))
    {
        $menuItem.Description = "$Description"
    }
    
    if($PSBoundParameters.ContainsKey("ActionScriptblock"))
    {
        $menuItem.ActionScriptblock = $ActionScriptblock
    }

    if($PSBoundParameters.ContainsKey("ConfirmBeforeInvoke"))
    {
        $menuItem.ConfirmBeforeInvoke = $ConfirmBeforeInvoke
    }

}

END
{
    Write-Verbose -Message "$f-  END"
}
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

function Show-Menu
{
[cmdletbinding()]
Param
(
    [int]    $InvokeItem
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
    )
        [pscustomobject]@{
            Text = "$Text"
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
    
    $lineFeed = ""#[System.Environment]::NewLine
    $menuString = ($script:MenuOptions.MenuFillChar * ($maxWith - 2))
    $null = $menuLines.Add((Get-MenuLine -Text $menuString -color $script:MenuOptions.MenuFillColor))

    $menuNameLength = $mainMenu.DisplayName.length
    $menuNameBlanks = (($maxWith - 2) - $menuNameLength) / 2
    $menuName = " " * $menuNameBlanks + $mainMenu.DisplayName
    $menuName += " " * (($maxWith - 1) - $menuName.Length - 1)
    $null = $menuLines.Add((Get-MenuLine -Text $menuName -Color $script:MenuOptions.MenuNameColor))


    #$menuEmptyLine = $script:MenuOptions.MenuFillChar + (" " * 78) + $script:MenuOptions.MenuFillChar #+ $lineFeed
    $menuEmptyLine = (" " * ($maxWith - 2)) #+ $script:MenuOptions.MenuFillChar
    $null = $menuLines.Add((Get-MenuLine -Text $menuEmptyLine -color $script:MenuOptions.MenuFillColor))
    $null = $menuLines.Add((Get-MenuLine -Text $menuEmptyLine -color $script:MenuOptions.MenuFillColor))

    $menuHeadingLength = $script:MenuOptions.Heading.Length
    $menuHeadingBlanks = (($maxWith - 2) - $menuHeadingLength) / 2
    
    $menuHeading = (" " * $menuHeadingBlanks) + $script:MenuOptions.Heading #+ (" " * $menuHeadingBlanks) + $script:MenuOptions.MenuFillChar #+ $lineFeed
    $menuHeading += (" " * (($maxWith - 1) - $menuHeading.length - 1))
    $null = $menuLines.Add((Get-MenuLine -Text $menuHeading -color $script:MenuOptions.HeadingColor))
    $null = $menuLines.Add((Get-MenuLine -Text $menuEmptyLine -color $script:MenuOptions.MenuFillColor))

    $menuSubHeadingLength = $script:MenuOptions.SubHeading.Length
    $menuSubHeadingBlanks = (($maxWith - 2) - $menuSubHeadingLength) / 2    
    $menuSubHeading = (" " * $menuSubHeadingBlanks) + $script:MenuOptions.SubHeading #+ (" " * $menuSubHeadingBlanks) + $script:MenuOptions.MenuFillChar# + $lineFeed
    $menuSubHeading += (" " * (($maxWith - 1) - $menuSubHeading.length - 1))
    $null = $menuLines.Add((Get-MenuLine -Text $menuSubHeading -color $script:MenuOptions.SubHeadingColor))
    $null = $menuLines.Add((Get-MenuLine -Text $menuEmptyLine -color $script:MenuOptions.MenuFillColor))
    $null = $menuLines.Add((Get-MenuLine -Text $menuEmptyLine -color $script:MenuOptions.MenuFillColor))

    $menuString = ($script:MenuOptions.MenuFillChar * ($maxWith - 2))
    $null = $menuLines.Add((Get-MenuLine -Text $menuString -color $script:MenuOptions.MenuFillColor))
    $null = $menuLines.Add((Get-MenuLine -Text $menuEmptyLine -color $script:MenuOptions.MenuFillColor))

    foreach($item in $script:menuItems)
    {
        $menuItemLength = $item.Displayname.length
        #$menuItemBlanks = (70 - $menuItemLength) / 2
        #$menuItem = $script:MenuOptions.MenuFillChar + (" " * $menuItemBlanks) + $item.Displayname + (" " * $menuItemBlanks) + $script:MenuOptions.MenuFillChar #+ $lineFeed
        $menuItem = "  " + "$($item.Id). $($item.DisplayName)"
        $menuitem += " " * (($maxWith - 1) - $menuItem.length - 1)
        $null = $menuLines.Add((Get-MenuLine -Text $menuItem -Color $script:MenuOptions.MenuItemColor))
    }

    $null = $menuLines.Add((Get-MenuLine -Text $menuEmptyLine -color $script:MenuOptions.MenuFillColor))
    $null = $menuLines.Add((Get-MenuLine -Text $menuEmptyLine -color $script:MenuOptions.MenuFillColor))

    $menuFooterLength = $script:MenuOptions.FooterText.Length
    $menuFooterBlanks = (($maxWith - 2) - $menuFooterLength) / 2
    $menuFooter = (" " * $menuFooterBlanks) + $script:MenuOptions.FooterText #+ (" " * $menuFooterBlanks)
    $menuFooter += (" " * (($maxWith - 1) - $menuFooter.length - 1))
    $null = $menuLines.Add((Get-MenuLine -Text $menuFooter -color $script:MenuOptions.FooterTextColor))
    $null = $menuLines.Add((Get-MenuLine -Text $menuEmptyLine -color $script:MenuOptions.MenuFillColor))

    $menuEndString = ($script:MenuOptions.MenuFillChar * ($maxWith - 2)) + $lineFeed
    $null = $menuLines.Add((Get-MenuLine -Text $menuEndString -color $script:MenuOptions.MenuFillColor))
    #$null = $menuLines.Add((Get-MenuLine -Text $menuEmptyLine -color $script:MenuOptions.MenuFillColor))

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

function Test-Invoke1
{
    $F = $MyInvocation.InvocationName
    write-verbose -Message "$f - START" -Verbose
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
        $script:MenuOptions.$key = $PSBoundParameters.$key
    }

    if([string]::IsNullOrEmpty($script:MenuOptions.FooterText))
    {
        
        $script:MenuOptions.FooterText = "$(Get-date) - Running as $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"
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

$function = "" ; Remove-Module -Name tmp -ErrorAction SilentlyContinue
foreach($action in $script:menuItems)
{
    $funcs = New-Object -TypeName System.Collections.ArrayList
    
    $function += "function $($action.id) {$($action.ActionScriptblock.ToString())};"
    Write-Verbose $function -Verbose
    
}

$sb = [scriptblock]::Create($function)
New-Module -Name tmp -ScriptBlock $sb | Import-Module