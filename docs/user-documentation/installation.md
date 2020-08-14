## Note - PowerShell

*The module has been written with PowerShell support in mind. For best performance and compatibility, the most recent release of PowerShell is recommended when using the Rubrik SDK for PowerShell.*

# Installation

This repository contains a folder named [`Rubrik`](https://github.com/rubrikinc/rubrik-sdk-for-powershell/tree/master/Rubrik). The folder needs to be installed into one of your PowerShell Module Paths using one of the installation methods outlined in the next section. To see the full list of available PowerShell Module paths, use `$env:PSModulePath.split(':')` or `$env:PSModulePath.split(';')` on Windows, in a PowerShell console.

Common PowerShell module paths include:

### Windows

1. Current User: `%USERPROFILE%\Documents\PowerShell\Modules\`
2. All Users: `%ProgramFiles%\PowerShell\Modules\`
3. OneDrive: `$env:OneDrive\Documents\PowerShell\Modules\`

### Linux

1. $home/.local/share/powershell/Modules
2. /usr/local/share/powershell/Modules
3. /opt/microsoft/powershell/7/Modules

## Option 1: PowerShell Gallery \(Recommended\)

1. Ensure you have the latest version of [PowerShell](https://aka.ms/pscore6) installed, or [Windows Management Framework 5.0](https://www.microsoft.com/en-us/download/details.aspx?id=50395) or greater installed.
2. Open a PowerShell console with the _Run as Administrator_ option.
3. Run `Set-ExecutionPolicy` using the parameter _RemoteSigned_ or _Bypass_.
4. Run `Install-Module -Name Rubrik -Scope CurrentUser` to download and install the module from the PowerShell Gallery. Note that the first time you install from the PowerShell Gallery repository it may ask you to first trust the repository.

## Option 2: Installer Script

1. Download the [`master branch`](https://github.com/rubrikinc/rubrik-sdk-for-powershell) to your workstation.
2. Open a Powershell console with the _Run as Administrator_ option.
3. Run `Set-ExecutionPolicy` using the parameter _RemoteSigned_ or _Bypass_.
4. Run the `Install-Rubrik.ps1` script in the root of this repository and follow the prompts to install, upgrade, or delete your Rubrik Module contents.

## Option 3: Manual Installation

1. Download the [`master branch`](https://github.com/rubrikinc/rubrik-sdk-for-powershell) to your workstation.
2. Copy the contents of the _Rubrik_ folder onto your workstation into the desired PowerShell Module path.
3. Open a Powershell console with the _Run as Administrator_ option.
4. Run `Set-ExecutionPolicy` using the parameter _RemoteSigned_ or _Bypass_.

Once installation is complete, you can validate that the module exists by running `Get-Module -ListAvailable Rubrik`.

## Options 4: Download Module from PowerShell Gallery for redistribution

1. Navigate to [PowerShell Gallery - Rubrik](https://www.powershellgallery.com/packages/Rubrik)
2. Click Manual Download.
3. Click Download the raw nupkg file.
   1. To directly use the module, the .nupkg file can be extracted on the destination system. Be sure the place the files in PSModulePath to allow for automatic loading.
   2. Alternatively, this file can be imported in a local nupkg repository for further distribution

## Verification

PowerShell will create a folder for each new version of any module you install. It's a good idea to check and see what version\(s\) you have installed and running in the session. To begin, let's see what versions of the Rubrik Module are installed:

`Get-Module -ListAvailable Rubrik`

The `-ListAvailable` switch will pull up all installed versions from any path found in `$env:PSModulePath`. Check to make sure the version you wanted is installed. You can safely remove old versions, if desired.

To see which version is currently loaded, use:

`Get-Module Rubrik`

If nothing is returned, you need to first load the module by using:

`Import-Module Rubrik`

If you wish to load a specific version, use:

`Import-Module Rubrik -RequiredVersion #.#.#`

Where "\#.\#.\#" represents the version number.