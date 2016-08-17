function Get-MenuItem
{
[cmdletbinding(DefaultParameterSetName='none')]
Param
(
    [Parameter(ParameterSetName="ByName")]
    [string[]]
    $Name = "*"
    ,
    [Parameter(ValueFromPipeline,ParameterSetName="ById")]
    [int[]]
    $Id 
)

BEGIN
{
    $f = $MyInvocation.InvocationName
    Write-Verbose -Message "$f - START"
}

PROCESS
{
    if (-not $PSBoundParameters.ContainsKey("Name") -and -not $PSBoundParameters.ContainsKey("Id"))
    {
        $script:menuItems
    }

    if ($PSBoundParameters.ContainsKey("Name"))
    {
        foreach ($menuName in $Name)
        {
            $script:menuItems.Where({$_.Name -like $Name})
        }
    }

    if ($PSBoundParameters.ContainsKey("Id"))
    {
        $script:menuItems.Where({$_.Id -in $id})
    }
}

END
{
    Write-Verbose -Message "$f-  END"
}
}