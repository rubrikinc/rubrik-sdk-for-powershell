function Set-ObjectTypeName($typename,$result)
{
    Write-Verbose -Message "Applying $typename TypeName to results"
    $result.ForEach{$_.PSObject.TypeNames.Insert(0,$typename)}
    return $result
}