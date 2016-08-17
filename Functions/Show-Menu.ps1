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