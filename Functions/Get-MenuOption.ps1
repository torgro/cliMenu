function Get-MenuOption
{
<#
.Synopsis
   Get a list menu options
.DESCRIPTION
   Returns a PSCustomObject with all menu options. This CmdLet has no parameters
.EXAMPLE
   C:> Get-MenuOption
   
   Returns all menu-items for all menus
.NOTES
   NAME: Get-MenuItem
   AUTHOR: Tore Groneng tore@firstpoint.no @toregroneng tore.groneng@gmail.com
   LASTEDIT: Aug 2016
   KEYWORDS: General scripting Controller Menu   
#>
[cmdletbinding()]
[OutputType([PSCustomObject])]
Param
()
    $script:MenuOptions
}