Installation
========================

This repository contains a folder named `Rubrik`_. The folder needs to be installed into one of your PowerShell Module Paths using one of the installation methods outlined in the next section. Common PowerShell module paths include:

1. Current User: ``%USERPROFILE%\Documents\WindowsPowerShell\``
2. All Users: ``%WINDIR%\System32\WindowsPowerShell\v1.0\``

Option 1: Installer Script
------------------------

1. Download the `latest release`_ or any pre-release build to your workstation.
2. Open a Powershell console with the *Run as Administrator* option.
3. Run ``Set-ExecutionPolicy`` using the parameter *RemoteSigned* or *Bypass*.
4. Run the ``Install-Rubrik.ps1`` script in the root of this repository and follow the prompt to install the module into your ``$Home\Documents\WindowsPowerShell\Modules\`` path.
5. At the completion of the installation, the installer will run ``Import-Module Rubrik`` on your behalf.

Option 2: Manual Installation
------------------------

1. Download the `latest release`_ or any pre-release build to your workstation.
2. Copy the contents of the *Rubrik* folder onto your workstation into the PowerShell Module Path ``$Home\Documents\WindowsPowerShell\Modules\`` or ``C:\Program Files\WindowsPowerShell\Modules``
3. Open a Powershell console with the *Run as Administrator* option.
4. Run ``Set-ExecutionPolicy`` using the parameter *RemoteSigned* or *Bypass*.
5. To load the module, use ``Import-Module Rubrik``.

Option 3: PowerShell Gallery
------------------------

1. Ensure you have the `Windows Management Framework 5.0`_ or greater installed.
2. Open a Powershell console with the *Run as Administrator* option.
3. Run ``Set-ExecutionPolicy`` using the parameter *RemoteSigned* or *Bypass*.
4. Run ``Install-Module -Name Rubrik`` to download the module from the PowerShell Gallery. Note that the first time you install from the remote repository it may ask you to first trust the repository.

Once installation is complete, you can validate that the module exists by running ``Get-Module -ListAvailable Rubrik``.

.. _Rubrik: https://github.com/rubrikinc/PowerShell-Module/tree/master/Rubrik
.. _latest release: https://github.com/rubrikinc/PowerShell-Module/releases/latest
.. _Windows Management Framework 5.0: https://www.microsoft.com/en-us/download/details.aspx?id=50395
