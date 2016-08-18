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