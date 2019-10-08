[string[]]$PowerShellModules = @('posh-git', 'platyPS', 'PowerShellGet')
[string[]]$PackageProviders = @('NuGet', 'PowerShellGet')

# Line break for readability in console
Write-Host -Object ''

# Install package providers for PowerShell Modules
ForEach ($Provider in $PackageProviders) {
    If (!(Get-PackageProvider $Provider -ErrorAction SilentlyContinue)) {
        Install-PackageProvider $Provider -Force -ForceBootstrap -Scope CurrentUser
    }
}

# Install the PowerShell Modules
ForEach ($Module in $PowerShellModules) {
    If (!(Get-Module -ListAvailable $Module -ErrorAction SilentlyContinue) -or $Module -eq 'PowerShellGet') {
        Install-Module $Module -Scope CurrentUser -Force -Repository PSGallery
    }
    
    if ($Module -eq 'PowerShellGet') {
        Remove-Module $Module -Force
    }
    
    Import-Module $Module -Force
}