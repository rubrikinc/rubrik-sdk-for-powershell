function Set-ObjectTypeName($typename, $result) {
    <#
        .SYNOPSIS
        Assigns an Object TypeName to cmdlet results

        .DESCRIPTION
        In order to better display results for cmdlets returning many objects with many properties TypeName formats may be used.
        This function will assign a TypeName if it exists to a set of returned objects.

        .PARAMETER typename
        The name of the TypeName to insert

        .PARAMETER result
        The response content which recieves the typename.
    #>

    if ($null -ne $result -and $null -ne $typename) {
        if ( $true -eq $Global:rubrikOptions.ModuleOptions.ApplyCustomViewDefinitions) {
            # Using ForEach-Object instead of .ForEach as .ForEach doesn't support single results.
            Write-Verbose -Message "Applying $typename TypeName to results"
            $result | ForEach-Object {
                $_.PSObject.TypeNames.Insert(0, $typename)
            }
        }
    }

    return $result
}