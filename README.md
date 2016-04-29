[![Build status](https://ci.appveyor.com/api/projects/status/52cv3jshak2w7624?svg=true)](https://ci.appveyor.com/project/chriswahl/powershell-module)

Community PowerShell Module for Rubrik
============================

This is a community project that provides a Windows PowerShell module for managing and monitoring Rubrik's Converged Data Management fabric by way of published RESTful APIs. If you're looking to perform interactive automation, setting up scheduled tasks, leverage an orchestration engine, or need ad-hoc operations, this module is intended to be valuable to your needs.

# Requirements

The code assumes that you've already deployed at least one Rubrik Brik into your environment and have completed the initial configuration process to form a cluster. At a minimum, make sure you have installed the following:

1. PowerShell version 4+
2. [PowerCLI version 5.8+](http://www.vmware.com/go/powercli)
3. Rubrik version 2.0+
4. (optional) [Windows Management Framework 5.0](https://www.microsoft.com/en-us/download/details.aspx?id=50395)
5. (optional) [Pester](https://github.com/pester/Pester)

# Installation

This repository contains a folder named [`Rubrik`](https://github.com/rubrikinc/PowerShell-Module/tree/readme-work/Rubrik). The folder needs to be installed into one of your PowerShell Module Paths using one of the installation methods outlined in the next section. Common PowerShell module paths include:

1. Current User: `%USERPROFILE%\Documents\WindowsPowerShell\`
2. All Users: `%WINDIR%\System32\WindowsPowerShell\v1.0\`

##### Option 1: Installer Script

1. Download the [latest release](https://github.com/rubrikinc/PowerShell-Module/releases/latest) or any pre-release build to your workstation.
2. Open a Powershell console with the *Run as Administrator* option.
3. Run `Set-ExecutionPolicy` using the parameter `RemoteSigned` or `Bypass`.
2. Run the `Install-Rubrik.ps1` script in the root of this repository and follow the prompt to install the module into your `$Home\Documents\WindowsPowerShell\Modules\` path.
3. At the completion of the installation, the installer will run `Import-Module Rubrik` on your behalf.

##### Option 2: Manual Installation

1. Download the [latest release](https://github.com/rubrikinc/PowerShell-Module/releases/latest) or any pre-release build to your workstation.
2. Copy the contents of the `Rubrik` folder onto your workstation into the PowerShell Module Path `$Home\Documents\WindowsPowerShell\Modules\` or `C:\Program Files\WindowsPowerShell\Modules`
2. Open a Powershell console with the *Run as Administrator* option.
3. Run `Set-ExecutionPolicy` using the parameter `RemoteSigned` or `Bypass`.
5. To load the module, use `Import-Module Rubrik`.

##### Option 3: PowerShell Gallery

1. Ensure you have the [Windows Management Framework 5.0](https://www.microsoft.com/en-us/download/details.aspx?id=50395) or greater installed.
2. Open a Powershell console with the *Run as Administrator* option.
3. Run `Set-ExecutionPolicy` using the parameter `RemoteSigned` or `Bypass`.
4. Run `Install-Module -Name Rubrik` to download the module from the PowerShell Gallery. Note that the first time you install from the remote repository it may ask you to first trust the repository.

Once installation is complete, you can validate that the module exists by running `Get-Module -ListAvailable Rubrik`.

# Usage Instructions

1. To see all of the imported commands, use `Get-Command -Module Rubrik`.
2. To see help for any single cmdlet, use `Get-Help <cmdlet>` combined with any of the optional parameters: `-Detailed` or `-Examples` or `-Full`

##### Connecting to a Rubrik Cluster

To begin using the module, create a connection to a Rubrik cluster and retrieve a token. To do this, use `Connect-Rubrik` with the option of using a `-Credential` object or a combination of a `-Username` string and a `-Password` secure string. If no parameters are passed, the function will prompt for credentials. A successful connection will result in the following message being output: `You are now connected to the Rubrik API`.

To review connection information, list the contents of `$RubrikConnection` to see the header, server, userid, and token details. Note that the token value is valid for the current session only and does expire.

##### Using safe commands to gain comfort

If you're new to PowerShell, it's worth using the `safe` commands - ones that do not alter data - to begin learning how the module works. Here are a few examples:

1. `Get-RubrikMount` - Lists all active Live Mounts and Instant Recoveries known to the cluster.
2. `Get-RubrikSLA` - Lists all SLA Domains.
3. `Get-RubrikTask` - Lists all `daily` or `weekly` tasks executed by the cluster.
4. `Get-RubrikVersion` - Lists the running version.

# Future

The community module is not officially supported and should be **used at your own risk**.

A future release will offer API versioning and may also include formal support.

# Contribution

Create a fork of the project into your own repository. Make all your necessary changes and create a pull request with a description on what was added or removed and details explaining the changes in lines of code. If approved, project owners will merge it.

# Licensing

Licensed under the Apache License, Version 2.0 (the “License”); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
