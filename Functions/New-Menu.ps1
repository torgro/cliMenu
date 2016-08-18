function New-Menu
{
<#
.Synopsis
   Create a new Menu
.DESCRIPTION
   You can create as many menus you like, however you may only have one main Menu. The Menu must
   have a name, hence the Name parameter is Mandatory. The first Menu you create will become
   the main Menu even if you do not specify the IsMainMenu switch.
.PARAMETER Name
   Normally you would like to specify a name without space and Camel-case the name.
.EXAMPLE
   C:> New-Menu -Name "MainMenu"
   
   This will create a new Menu with name MainMenu. If this is the first Menu, it will be
   created as a main Menu
.EXAMPLE
   C:> New-Menu -Name "MainMenu" -IsMainMenu
   
   This will create a new Menu with name MainMenu and set is as a main Menu
.EXAMPLE
   C:> New-Menu -Name "sub1" -DisplayName "Sub-Menu for Skype"
   
   This will create a new Menu with name sub1 and DisplayName Sub-Menu for Skype
.NOTES
   NAME: New-Menu
   AUTHOR: Tore Groneng tore@firstpoint.no @toregroneng tore.groneng@gmail.com
   LASTEDIT: Aug 2016
   KEYWORDS: General scripting Controller Menu   
#>
[cmdletbinding()]
[OutputType([PSCustomObject])]
Param
(
    [Parameter(Mandatory)]
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
    Write-Verbose -Message "$f - START"
}

PROCESS
{
    $newMenu = [PSCustomObject]@{
        Name = "$Name"
        DisplayName = "$DisplayName"
        IsMainMenu = $IsMainMenu
        MenuItems = New-Object -TypeName System.Collections.ArrayList
    }

    $currentMainMenu = Get-Menu -MainMenu

    if ($PSBoundParameters.ContainsKey("IsMainMenu"))
    {        
        if ($currentMainMenu)
        {
            Write-Error -Message "$f -  You can only have one Main Menu. Currently [$($currentMainMenu.Name)] is your main menu"    
            break        
        }      
    }

    if (-not $currentMainMenu)
    {
        $newMenu.IsMainMenu = $true
    }

    write-Verbose -Message "Creating menu [$Name]"
    $null = $script:Menus.Add($newMenu)
    $newMenu
}

END
{

}
}