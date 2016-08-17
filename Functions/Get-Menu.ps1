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