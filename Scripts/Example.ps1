Import-Module .\CliMenu.psd1

Set-MenuOption -Heading "Helpdesk Inteface System" -SubHeading "LOIS by Firstpoint" -MenuFillChar / -MenuFillColor DarkYellow
Set-MenuOption -HeadingColor DarkCyan -MenuNameColor DarkGray -SubHeadingColor Green -FooterTextColor DarkGray

$newItem = @{
    Name = "menu0"
    DisplayName = "Reset user password"
    ActionScriptblock = { show-command -Name Write-host }
}

New-MenuItem @newItem

$newItem = @{
    Name = "menu1"
    DisplayName = "Add a menu Item"
    ActionScriptblock = { Show-Command -Name New-menuItem }
}

New-MenuItem @newItem -ConfirmBeforeInvoke $false
Set-Menu -Name MainMenu -DisplayName "* * *    M a i n    M e n u   * * *"
Clear-Host
Show-Menu