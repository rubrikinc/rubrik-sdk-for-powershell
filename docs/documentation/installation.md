Installation
========================

This repository contains a folder named [`Rubrik`](https://github.com/rubrikinc/PowerShell-Module/tree/master/Rubrik). The folder needs to be installed into one of your PowerShell Module Paths using one of the installation methods outlined in the next section. To see the full list of available PowerShell Module paths, use ``$env:PSModulePath.split(';')`` in a PowerShell console.

Common PowerShell module paths include:

1. Current User: ``%USERPROFILE%\Documents\WindowsPowerShell\Modules\``
1. All Users: ``%ProgramFiles%\WindowsPowerShell\Modules\``
1. OneDrive: ``$env:OneDrive\Documents\WindowsPowerShell\Modules\``

Option 1: PowerShell Gallery (Recommended)
------------------------

1. Ensure you have the [Windows Management Framework 5.0](https://www.microsoft.com/en-us/download/details.aspx?id=50395) or greater installed.
1. Open a Powershell console with the *Run as Administrator* option.
1. Run ``Set-ExecutionPolicy`` using the parameter *RemoteSigned* or *Bypass*.
1. Run ``Install-Module -Name Rubrik -Scope CurrentUser`` to download the module from the PowerShell Gallery. Note that the first time you install from the remote repository it may ask you to first trust the repository.

Option 2: Installer Script
------------------------

1. Download the [`master branch`](https://github.com/rubrikinc/PowerShell-Module) to your workstation.
1. Open a Powershell console with the *Run as Administrator* option.
1. Run ``Set-ExecutionPolicy`` using the parameter *RemoteSigned* or *Bypass*.
1. Run the ``Install-Rubrik.ps1`` script in the root of this repository and follow the prompts to install, upgrade, or delete your Rubrik Module contents.

Option 3: Manual Installation
------------------------

1. Download the [`master branch`](https://github.com/rubrikinc/PowerShell-Module) to your workstation.
1. Copy the contents of the *Rubrik* folder onto your workstation into the desired PowerShell Module path.
1. Open a Powershell console with the *Run as Administrator* option.
1. Run ``Set-ExecutionPolicy`` using the parameter *RemoteSigned* or *Bypass*.

Once installation is complete, you can validate that the module exists by running ``Get-Module -ListAvailable Rubrik``.

Verification
------------------------

PowerShell will create a folder for each new version of any module you install. It's a good idea to check and see what version(s) you have installed and running in the session. To begin, let's see what versions of the Rubrik Module are installed:

``Get-Module -ListAvailable Rubrik``

The ``-ListAvailable`` switch will pull up all installed versions from any path found in ``$env:PSModulePath``. Check to make sure the version you wanted is installed. You can safely remove old versions, if desired.

To see which version is currently loaded, use:

``Get-Module Rubrik``

If nothing is returned, you need to first load the module by using:

``Import-Module Rubrik``

If you wish to load a specific version, use:

``Import-Module Rubrik -RequiredVersion #.#.#.#``

Where "#.#.#.#" represents the version number.
