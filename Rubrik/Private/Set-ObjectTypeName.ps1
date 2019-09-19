function Set-ObjectTypeName($typename,$result)
{
    
    if ($null -ne $result -and $null -ne $typename) {
        # Using ForEach-Object instead of .ForEach as .ForEach doesn't support single results.
        Write-Verbose -Message "Applying $typename TypeName to results"
        $result | ForEach-Object {
            $_.PSObject.TypeNames.Insert(0,$typename)
        }
    }

    #$result.ForEach{$_.PSObject.TypeNames.Insert(0,$typename)}
    return $result
}