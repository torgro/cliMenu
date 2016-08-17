remove-module climenu -ErrorAction SilentlyContinue; Import-Module .\CliMenu.psd1

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
    DisplayName = "Go to submenu"
    ActionScriptblock = { Show-Menu -MenuID 1 }
}

New-MenuItem @newItem -ConfirmBeforeInvoke $false

New-Menu -Name SubMenu -DisplayName "*** SubMenu1 ***"

function Write-Console
{
Param(
    [Parameter(Mandatory)]
    $Text
)

Write-Host "OUTPUT: $Text"
}

$newItem = @{
    Name = "sub1"
    DisplayName = "SubMenu action"
    ActionScriptblock = { Write-Console }
}

New-MenuItem @newItem -ParentMenuID 1 -ConfirmBeforeInvoke $false


New-MenuItem @newItem -ConfirmBeforeInvoke $false
Set-Menu -Name MainMenu -DisplayName "* * *    M a i n    M e n u   * * *"
Clear-Host
Show-Menu