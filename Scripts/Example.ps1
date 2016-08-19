Remove-Module cliMenu -ErrorAction SilentlyContinue; Import-Module .\CliMenu.psd1

Set-MenuOption -Heading "Helpdesk Inteface System" -SubHeading "LOIS by Firstpoint" -MenuFillChar "#" -MenuFillColor DarkYellow
Set-MenuOption -HeadingColor DarkCyan -MenuNameColor DarkGray -SubHeadingColor Green -FooterTextColor DarkGray
Set-MenuOption -MaxWith 60

$newItem1 = @{
    Name = "WriteHost"
    DisplayName = "Launch Write-Host as a GUI"
    Action = { show-command -Name Write-host }
    DisableConfirm = $true
}

$newMenu = @{
    Name = "Main"
    DisplayName = "Main Menu"
}

# Create a new menu Item
$menuItem = New-MenuItem @newItem1

# Create a new menu (first menu will become the main menu)
$mainMenu = New-Menu @newMenu

# Add menu item to the menu named 'main'
$menuItem | Add-MenuItem -Menu main

$newItem2 = @{
    Name = "GoToSub"
    DisplayName = "Go to submenu"
    Action = { Show-Menu -MenuName SubMenu }
}

# Add a menuitem to the main menu
$mainMenu | New-MenuItem @newItem2 -DisableConfirm

$newItemSubMenu = @{
    Name = "GoToMain"
    DisplayName = "Go to Main Menu"
    Action = { Show-Menu }
}

# Create a new menu (sub-menu) and add a menu-item to it
New-Menu -Name SubMenu -DisplayName "*** SubMenu1 ***" | New-MenuItem @newItemSubMenu -DisableConfirm

clear-host
Show-Menu