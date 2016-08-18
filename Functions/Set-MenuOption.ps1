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