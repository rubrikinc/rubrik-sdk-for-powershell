# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## Types of changes

* **Added** for new features.
* **Changed** for changes in existing functionality.
* **Deprecated** for soon-to-be removed features.
* **Removed** for now removed features.
* **Fixed** for any bug fixes.
* **Security** in case of vulnerabilities.

## [Unreleased]

## 2019-06-25

### Added [New New-RubrikAPIToken cmdlet]

* Added New-RubrikAPIToken cmdlet to address [316](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/316) and associated unit test.

### Added [New Remove-RubrikAPIToken cmdlet]

* Added Remove-RubrikAPIToken cmdlet to address [316](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/316) and associated unit test.

## 2019-06-20

### Added [New Remove-RubrikVMSnapshot cmdlet]

* Added Remove-RubrikVMSnapshot cmdlet to address [148](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/148) and associated unit test

### Changed [Additional logging and info]

* Updated Invoke-RubrikWebRequest so the HTTP status code returned from the API call is displayed when verbose logging is enabled
* Updated Submit-Request to handle `Delete` API calls differently than other calls. Previously `Delete` operations did not surface any status to the user. With this change, the HTTP response code is checked to verify it matches the expected response. If so, it returns a PSObject with the HTTP code and Status = 'Success'.

## 2019-06-18

### Added [Update-RubrikVMwareVM]

* Added new `Update-RubrikVMwareVM` cmdlet to refresh a single VMware VM's metadata. This addresses issue [305](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/305)

## 2019-06-04

### Added [Resolving Issues]

* Added Export-RubrikVM cmdlet to address [Issue 239](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/239). Since the cmdlet requires IDs for both a VMware datastore and a VMware host, 2 other cmdlets were developed, Get-RubrikVMwareDatastore and Get-RubrikVMwareHost to make the whole process easier.

### Changed [Resolved issues]

* Resolved bug in New-RubrikVMDKMount, thanks @Pierre-PvF

## 2019-06-03

### Added [Resolving issues, new cmdlet]

* Added Set-RubrikVolumeFilterDriver cmdlet to support the installation/uninstallation of the Rubrik VFD on registered Windows hosts as per reported in [Issue 291](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/291).  Set-RubrikVolumeFilterDriver takes an array of string (hostIds) and an installed (true/false) parameter to determine whether to install or uninstall the VFD on the given hosts.

### Added [ DetailedObject Support for Get-RubrikHost ]

* Added a DetailedObject switch (similar to that on Get-RubrikVM) to the Get-RubrikHost cmdlet in order to grab more information when not querying by hostID.  This allows for more information to be returned by the API (IE hostVfdDriverState, hostVfdEnabled). This way users could query Rubrik hosts by name, check installation status, and pipe id's to the new Set-RubrikVolumeFilterDriver cmdlet for VFD installation.

## 2019-05-31

### Added [New-RubrikManagedVolume update]

* Added `-ApplicationTag` parameter support to New-RubrikManagedVolume so users can specify which application the managed volume will be used for. This addresses issue [285](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/285).


## 2019-05-30

### Changed [Resolving issues]

* Updated Move-RubrikMountVMDK and Test-DateDifference to resolve bugs reported in [250](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/250). Move-RubrikMountVMDK will try to find the snapshot closest to the date specified, within one day. Any valid PowerShell `datetime` formatted string will be accepted as an input, but greater specificity will lead to a much better chance of matching the intended snapshot.

## 2019-05-27

### Changed [Added functionality and resolved issues]

* Added -name parameter to Get-RubrikOrganization
* Updated Get-RubrikDatabase, Get-RubrikFileset, Get-RubrikHyperVVM, GetRubrikNutanixVM and Get-RubrikVolumeGroup to address issue [223](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/223). Calls to Test-RubrikSLA were inadvertently overwriting the $SLAID variable, causing the paramater to be ignored.
* Added Custom User Agent value to HTTP headers in Connect-Rubrik function

## 2019-05-22

### Changed [Resolving issues]

 * Get-RubrikOrganization will only return an exact match as per [224](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/224)
 * Updated documentation to fix errors on Protect-RubrikVM entry as per [162](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/162)

## 2019-03-27 [Quickstart Documentation Update]

### Changed

* Updated Typo in Quickstart Documentation

## 2019-03-24 [Parameter validation for Get-RubrikVM]

### Added

* Added parameter sets and parameter validation to Get-RubrikVM
* Added ValidateNullNotEmpty to selected parameters in Get-RubrikVM
* Added additional 5 tests to validate parameters sets and validation work as intended

## 2019-03-17 [Added new functionality and fixed help]

### Added

* Updated example 2 in comment-based help of Invoke-RubrikRESTCall
* Added -DetailedObject parameter for Get-RubrikVM

### Fixed

* Prevent Get-RubrikVM $SLAID parameter value overwrite when it has a value as per [165](https://github.com/rubrikinc/PowerShell-Module/issues/165)

## [4.0.0] - 2017-07-07

### Added

* `Set-RubrikSupportTunnel` - Modifies the configuration of the Support Tunnel.
* `Get-RubrikSupportTunnel` - Checks the status of the Support Tunnel.
* This Changelog - moving forward, related changes will be documented here in an easy to read format for human eyeballs.
* Dynamic documentation creation via GitBook.
* [GitHub Pull Request Template](https://github.com/rubrikinc/PowerShell-Module/pull/135).
* [GitHub Issue Template](https://github.com/rubrikinc/PowerShell-Module/commit/ca0a7fc1864c42162236b4e68af6f44d07f0a164).
* [Invoke-RubrikRESTCall](https://github.com/rubrikinc/PowerShell-Module/pull/118).
* TLS v1.2 support triggered during the usage of `Connect-Rubrik`.
* `Get-RubrikLDAPSettings` - Checks all LDAP server settings
* `Get-RubrikSettings` - Checks cluster settings
* `Get-RubrikVCenter` - Checks all vCenter server settings
* `New-RubrikLDAPSettings` - Creates new LDAP server connection
* `New-RubrikVCenter` - Creates new vCenter server connection
* `Remove-RubrikVCenter` - Removes vCenter server connection
* `Set-RubrikSettings` - Modifes cluster settings
* `Set-RubrikVCenter` - Modifies vCenter server connection settings

### Changed

* Track `user_error` responses in the `Submit-Request` private function
* The `Get-RubrikSnapshot` function supports HyperV VMs.
* Updated API Data for 4.1 against `Get-RubrikReport` and `Get-RubrikReportData`.
* Modified `Get-RubrikAPIData` to use RCDM versions instead of API versions.

### Deprecated

* Dynamic documentation using ReadTheDocs and reStructuredText.
* Removed old session endpoint data from `Connect-Rubrik` used by RCDM versions 1.x and 2.x.
