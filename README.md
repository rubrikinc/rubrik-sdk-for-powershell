PowerShell Module for Rubrik
============================

This project provides a Windows PowerShell module for managing and monitoring Rubrik's Converged Data Management platform.

# Installation

The code assumes that you've already deployed at least one Brik into your environment and have completed the initial configuration process. Make sure you have PowerShell version 4 or higher installed on your workstation.

##### Option 1:

1. Download the contents of this repository to your workstation.
2. Run the Install-Rubrik script and follow the prompt to install the module into your `$Home` path.

##### Option 2:

1. Download the contents of this repository to your workstation.
2. Copy the contents of the `Rubrik` folder onto your workstation into the path `$Home\Documents\WindowsPowerShell\Modules\`

Launch PowerShell and make sure `Set-ExecutionPolicy` is set to `RemoteSigned` or `Bypass`. To load the module, use `Import-Module Rubrik`.

# Usage Instructions

To see all of the imported commands, use `Get-Command -Module Rubrik`.

# Future

Add more commands!

# Contribution

Create a fork of the project into your own repository. Make all your necessary changes and create a pull request with a description on what was added or removed and details explaining the changes in lines of code. If approved, project owners will merge it.

# Licensing

Licensed under the Apache License, Version 2.0 (the “License”); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
