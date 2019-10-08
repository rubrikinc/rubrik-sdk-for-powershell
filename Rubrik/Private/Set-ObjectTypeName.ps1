function Set-ObjectTypeName($typename,$result)
{
    # The Set-ObjectTypeName function is insert TypeNames if they exist
    # $typename = The name of the typename to insert
    # $result = The response content to insert to

    if ($null -ne $result -and $null -ne $typename) {
        # Using ForEach-Object instead of .ForEach as .ForEach doesn't support single results.
        Write-Verbose -Message "Applying $typename TypeName to results"
        $result | ForEach-Object {
            $_.PSObject.TypeNames.Insert(0,$typename)
        }
    }

    return $result
}