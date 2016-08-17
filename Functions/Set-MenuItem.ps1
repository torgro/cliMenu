function Set-MenuItem
{
[cmdletbinding()]
Param
(
    [string]
    $Name
    ,
    [string]
    $DisplayName
    ,
    [string]
    $Description
    ,
    [scriptblock]
    $ActionScriptblock
    ,
    [bool]
    $ConfirmBeforeInvoke
)

BEGIN
{
    $f = $MyInvocation.InvocationName
    Write-Verbose -Message "$f - START"
}

PROCESS
{
    $menuItem = $script:menuItems.GetEnumerator().Where({$_.Name -eq "$Name"})

    if ($menuItem)
    {
        foreach ($key in $PSBoundParameters.Keys)
        {
            Write-Verbose -Message "$f -  Setting [$key] to value $($PSBoundParameters.$key)"
            $script:menuItems[$menuItem.id].$key = $PSBoundParameters.$key
        }
    }
    else    
    {
        Write-Error -Message "$f -  Unable to find menuItem with name [$Name]"
    }
}

END
{
    Write-Verbose -Message "$f - END"
}
}