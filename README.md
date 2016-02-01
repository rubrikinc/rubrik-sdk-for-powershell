Community PowerShell Module for Rubrik
============================

This is a community project that provides a Windows PowerShell module for managing and monitoring Rubrik's Converged Data Management platform by way of the published RESTful APIs.

# Requirements

The code assumes that you've already deployed at least one Brik into your environment and have completed the initial configuration process. At a minimum, make sure you have installed the following:

1. PowerShell version 4 or newer
2. PowerCLI version 5.8 or newer

# Installation

This repository contains a folder named `Rubrik`. The folder needs to be installed into one of your PowerShell Module Paths.

##### Option 1: Automated Installation

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

# Usage Instructions

To see all of the imported commands, use `Get-Command -Module Rubrik`.

To see help for any single cmdlet, use `Get-Help <cmdlet>` combined with any of the optional parameters: `-Detailed` or `-Examples` or `-Full`

# Future

The community module is not officially supported and should be **used at your own risk**.

A future release will offer API versioning and may also include formal support.

# Contribution

Create a fork of the project into your own repository. Make all your necessary changes and create a pull request with a description on what was added or removed and details explaining the changes in lines of code. If approved, project owners will merge it.

# Licensing

Licensed under the Apache License, Version 2.0 (the “License”); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
