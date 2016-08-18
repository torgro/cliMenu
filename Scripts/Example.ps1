Remove-Module cliMenu -ErrorAction SilentlyContinue; Import-Module .\CliMenu.psd1

Set-MenuOption -Heading "Helpdesk Inteface System" -SubHeading "LOIS by Firstpoint" -MenuFillChar "#" -MenuFillColor DarkYellow
Set-MenuOption -HeadingColor DarkCyan -MenuNameColor DarkGray -SubHeadingColor Green -FooterTextColor DarkGray
Set-MenuOption -MaxWith 60

$newItem1 = @{
    Name = "menu0"
    DisplayName = "Launch Write-Host as a GUI"
    Action = { show-command -Name Write-host }
    DisableConfirm = $true
}

New-MenuItem @newItem1

$newItem2 = @{
    Name = "menu1"
    DisplayName = "Go to submenu"
    Action = { Show-Menu -MenuID 1 }
}

New-MenuItem @newItem2 -DisableConfirm

$newItemSub = @{
    Name = "menu1"
    DisplayName = "Go to Main Menu"
    Action = { Show-Menu }
}

New-Menu -Name SubMenu -DisplayName "*** SubMenu1 ***" | New-MenuItem @newItemSub -DisableConfirm

clear-host
Show-Menu