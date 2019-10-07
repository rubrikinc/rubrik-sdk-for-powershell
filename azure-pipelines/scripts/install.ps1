[string[]]$PowerShellModules = @("Pester", "posh-git", "platyPS", "InvokeBuild")
[string[]]$PackageProviders = @('NuGet', 'PowerShellGet')
[string[]]$ChocolateyPackages = @('calibre')
[string[]]$NodeModules = @('gitbook-cli', 'gitbook-summary')

# Line break for readability in AppVeyor console
Write-Host -Object ''

# Install package providers for PowerShell Modules
ForEach ($Provider in $PackageProviders) {
    If (!(Get-PackageProvider $Provider -ErrorAction SilentlyContinue)) {
        Install-PackageProvider $Provider -Force -ForceBootstrap -Scope CurrentUser
    }
}

# Install the PowerShell Modules
ForEach ($Module in $PowerShellModules) {
    If (!(Get-Module -ListAvailable $Module -ErrorAction SilentlyContinue)) {
        Install-Module $Module -Scope CurrentUser -Force -Repository PSGallery
    }
    Import-Module $Module
}

# Install Chocolatey packages
ForEach ($Package in $ChocolateyPackages) {choco install $Package -y --no-progress}

# Install Node packages
ForEach ($Module in $NodeModules) {npm install -g $Module}