# We're going to add 1 to the revision value since a new commit has been merged to Master
# This means that the major / minor values will be consistent across GitHub and the Gallery
try {
    # This is where the module manifest lives
    $manifestPath = "$env:LocalPath\Rubrik\Rubrik.psd1"

    # Start by importing the manifest to determine the version, then add 1 to the revision
    $manifest = Test-ModuleManifest -Path $manifestPath
    [System.Version]$version = $manifest.Version
    Write-Output "Old Version: $version"

    if ($env:TargetBranch -eq 'master') {
        $WebRequestSplat = @{
            Uri = 'https://raw.githubusercontent.com/rubrikinc/rubrik-sdk-for-powershell/devel/Rubrik/Rubrik.psd1'
            UseBasicParsing = $true
            ErrorAction = 'Stop'
        }
        $version = (Invoke-WebRequest @WebRequestSplat) -split '\n' -match 'ModuleVersion' -replace "\s|'|ModuleVersion|="
        $version = [version][string]$version
        [String]$newVersion = "$($version.Major).$($version.Minor).$($version.Build+1)"
        Write-Output "New Version: $newVersion"
    } else {
        $newVersion = $manifest.Version
    }

    # Update the manifest with the new version value and fix the weird string replace bug
    $functionList = ((Get-ChildItem -Path .\Rubrik\Public).BaseName)
    $formatList = "ObjectDefinitions/$((Get-ChildItem -Path .\Rubrik\ObjectDefinitions).Name)"
    
    $splat = @{
        'Path'              = $manifestPath
        'ModuleVersion'     = $newVersion
        'FormatsToProcess'  = $formatList
        'FunctionsToExport' = $functionList
        'Copyright'         = "(c) 2015-$( (Get-Date).Year ) Rubrik, Inc. All rights reserved."
        'PrivateData'       = @{
            'Tags'       = 'Rubrik','Cloud_Data_Management','CDM','Backup','Recovery','Data_Protection'
            'LicenseUri' = 'https://github.com/rubrikinc/rubrik-sdk-for-powershell/blob/master/LICENSE'
            'ProjectUri' = 'https://github.com/rubrikinc/rubrik-sdk-for-powershell'
            'IconUri'    = 'http://i.imgur.com/Zbdd4Ko.jpg'
        }
    }

    #if ($env:TargetBranch -eq 'devel') {
    if ($true) {
        $WebRequestSplat = @{
            Uri = 'https://raw.githubusercontent.com/rubrikinc/rubrik-sdk-for-powershell/devel/Rubrik/Rubrik.psd1'
            UseBasicParsing = $true
            ErrorAction = 'Stop'
        }
        $prerelease = (Invoke-WebRequest @WebRequestSplat) -split '\n' -match 'Prerelease\s=' -replace "\s|'|Prerelease|="
        (Invoke-WebRequest @WebRequestSplat)
        $prerelease
        $newprerelease = "devel$((($prerelease -replace 'devel') -as [string] -as [int])+1)"

        Write-Output "New Devel Prerelease Version: $newprerelease"
        $Splat.PrivateData.Prerelease = $newprerelease
    }
    
    cat $splat.path
    Update-ModuleManifest @splat
    
    # Fix errors in Manifest
    (Get-Content -Path $manifestPath) -replace 'PSGet_Rubrik', 'Rubrik' | Set-Content -Path $manifestPath
    (Get-Content -Path $manifestPath) -replace 'NewManifest', 'Rubrik' | Set-Content -Path $manifestPath
    
    # Fix FormatsToProcess
    (Get-Content -Path $manifestPath) -replace 'FormatsToProcess = ', "FormatsToProcess = @(`r`n" | Set-Content -Path $manifestPath -Force
    (Get-Content -Path $manifestPath) -replace "'$($formatList[0])'", "$(" "*15)'$($formatList[0])'" | Set-Content -Path $manifestPath -Force
    (Get-Content -Path $manifestPath) -replace "$($formatList[-1])'", "$($formatList[-1])')" | Set-Content -Path $manifestPath -Force
    
    # Fix FunctionsToExport
    (Get-Content -Path $manifestPath) -replace 'FunctionsToExport = ', "FunctionsToExport = @(`r`n" | Set-Content -Path $manifestPath -Force
    $functionlist | ForEach-Object {
        (Get-Content -Path $manifestPath) -replace "'$_',\s?'", "'$_',`r`n$(" "*15)'" | Set-Content -Path $manifestPath -Force
    }
    # Fix first and last function entry
    (Get-Content -Path $manifestPath) -replace "'$($functionList[0])'", "$(" "*15)'$($functionList[0])'" | Set-Content -Path $manifestPath -Force
    (Get-Content -Path $manifestPath) -replace "$($functionList[-1])'", "$($functionList[-1])')" | Set-Content -Path $manifestPath -Force
    
} catch {
    throw $_
}

if ($env:TargetBranch -eq 'master') {
    try {
        # Build a splat containing the required details and make sure to Stop for errors which will trigger the catch
        $PublishSplat = @{
            Path        = "$env:LocalPath\Rubrik"
            NuGetApiKey = $env:GalleryAPIKey
            ErrorAction = 'Stop'
        }
        Publish-Module @PublishSplat
        Write-Host "Rubrik PowerShell Module version $newVersion published to the PowerShell Gallery." -ForegroundColor Cyan
    } catch {
        # Sad panda; it broke
        Write-Warning "Publishing updated $newVersion to the PowerShell Gallery failed."
        throw $_
    }
} elseif ($env:TargetBranch -eq 'devel') {
    try {
        # Build a splat containing the required details and make sure to Stop for errors which will trigger the catch
        $PublishSplat = @{
            Path        = "$env:LocalPath\Rubrik"
            NuGetApiKey = $env:GalleryAPIKey
            ErrorAction = 'Stop'
        }
        Publish-Module @PublishSplat
        Write-Host "Rubrik PowerShell Module version $newVersion (Prelease: $newprerelease) published to the PowerShell Gallery." -ForegroundColor Cyan
    } catch {
        # Sad panda; it broke
        Write-Warning "Publishing updated $newVersion (Prelease: $newprerelease) to the PowerShell Gallery failed."
        throw $_
    }
}
