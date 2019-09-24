'Private','Public' | ForEach-Object -Begin {
    $ModuleManifest = Test-ModuleManifest ../Rubrik/Rubrik.psd1
    $ModuleHash = @{
        Version = $ModuleManifest.Version
        Content = '' -as [string]
        ExportedFunctions = "@(`n" +
            "'$((Get-ChildItem -Path '../Rubrik/Public').BaseName -join "','" -replace "(,.*?,.*?,)",'$1
')'" +
            "`n)"
        Path =  Join-path -Path (Get-Location | Split-Path) -ChildPath 'Rubrik'
    }
} -Process {
    [io.directory]::getfiles("$($ModuleHash.Path)/$_") | ForEach-Object {
        $ModuleHash.Content += [io.file]::readalltext($_) + "`n"
    }
} -End {
    $ModuleHash.Content += "`n`nExport-ModuleMember -Function $($ModuleHash.ExportedFunctions)"
    Set-Content -Path "./Rubrik-$($ModuleHash.Version).psm1" -Value $ModuleHash.Content
}