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

## Unreleased

### Changed

* Changed how `Set-RubrikNASShare` creates the body object [Issue 614](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/614) and added new unit tests for this function
* Modified `Set-RubrikAvailabilityGroup` and made `-LogRetentionHours` parameters mandatory while removing default value of -1
* Modified private function `Set-ObjectTypeName.ps1` to support the new `ApplyCustomViewDefinitions`.
* Modified module script file `rubrik.psm1` to create options file if it doesn't exist, and update any current options file if it does exist. Also loads any default parameter options into $global:PSDefaultParameterValues
* Modified `Get-RubrikVM`, `Get-RubrikDatabase`, `Get-RubrikFileset`, `Get-RubrikHost`, `Get-RubrikLogShipping`, `Get-RubrikNutanixCluster`, `Get-RubrikOracleDB`, `Get-RubrikReplicationSource`,`Get-RubrikReplicationTarget`, `Get-RubrikScvmm`, `Get-RubrikvApp`, `Get-RubrikVCD`, `Get-RubrikVMwareCluster`, and `Get-RubrikVMwareDatacenter` to call the new `Get-RubrikDetailedResult` function when -DetailedObject is present. `Get-RubrikArchive` was left alone as it uses -DetailedObject differently.
* Modified various md documentation files to reflect work done since last documentation update as per [Issue 616](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/616)
* `New-RubrikFilesetTemplate` now has type data assigned [Issue 611](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/611)
* Removed -Body $body from `Get-RubrikClusterInfo` when it passes variables to Submit-Request as per [Issue 604](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/604)
* Added default parametersets, positional attributes to name parameters, and removed pipeline support from name for the following cmdlets: `Get-RubrikSLA`, `Get-RubrikArchive`, `Get-RubrikClusterNetworkInterface`, `Get-RubrikDatabase`, `Get-RubrikDatabaseMount`, `Get-RubrikFileset`, `Get-RubrikFilesetTemplate`, `Get-RubrikGuestOSCredential`,`Get-RubrikHost`,`Get-RubrikHypervHost`, `Get-RubrikHyperVVM`,`Get-RubrikLogShipping`,`Get-RubrikManagedVolume`,`Get-RubrikNutanixCLuster`,`Get-RubrikNutanixVM`,`Get-RubrikObjectStoreArchive`,`Get-RubrikOracleDB`,`Get-RubrikOrganization`,`Get-RubrikQstarArchive`,`Get-RubrikReplicationSource`,`Get-RubrikReplicationTarget`,`Get-RubrikSQLInstance`, `Get-RubrikScvmm`, `Get-RubrikSmbDomain`, `Get-RubrikUnmanagedObject`, `Get-RubrikUser`, `Get-RubrikvApp`, `Get-RubrikVCD`, `Get-RubrikVMwareCluster`, `Get-RubrikVMwareHost`, `Get-RubrikVMwareDatastore`, and `Get-RubrikVMwareDatacenter`.  This provides a more user friendly experience by allowing users to simply enter `Get-RubrikSLA MySLA` rather than `Get-RubrikSLA -Name MySQL`.  Removing pipeline support from name also ensures that when utilizing pipeline, ID queries are always performed. IE `Get-RubrikSLA MySLA | Get-RubrikSLA ` will first use the basic name filter for the left hand of the pipeline, however the second will pick up the id to perform an id based parameter.
* Removed -Body $body from `Get-RubrikClusterStorage` and `Get-RubrikDNSSetting` when it passes variables to Submit-Request as per [Issue 604](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/604)
* Removed -Body $body from `Get-RubrikClusterInfo` when it passes variables to Submit-Request as per [Issue 604](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/604)
* Added support to `Get-RubrikObject` for ClusterNetworkInterfaces, Event Series, HyperV Hosts, Nodes, Notification Settings, NTP Servers, Nutanix Clusters and SMB Domains
* Added support to `Get-RubrikObject` to support searching by id on an attribute which isn't named `id`
* Fixed how `Disconnect-Rubrik` handles cleaning up `$RubrikConnection(s)` variables
* Modified `Get-RubrikSLA`, `Set-RubrikSLA` and `New-RubrikSLA` to call private function to add a human readable frequency summary field
* Added $rubrikConnections = $null to `Connect-Rubrik.Tests.ps1` in order to allow test to be ran within the same PS session of which it ran previously.
* Added parameters to `New-RubrikvCenter` and `Set-RubrikvCenter` allowing users to send username/password or credential objects to the cmdlets. This allows true scripting of these cmdlets rather than prompting for credentials by default.
* Added -Force parameter and confirmation prompts to `Remove-RubrikUnmanagedObject`. This allows for the deletion of snapshots protected by retention SLAs as per [Issue 314](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/314)
* Modified default behavior for `Export-RubrikVM`, when -PowerOn is not specified it will send `"powerOn": false` to the endpoint [Issue 594](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/594)
* Modified Link for `Protect-RubrikVolumeGroup` to lowercase
* Modified `Remove-RubrikVMSnapshot` to support -Confirm before performing action
* Updated help for all fileset and fileset template related cmdlets as per [Issue 284](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/284)
* Changed example documentation for `New-RubrikDatabaseMount`
* Added `-DetailedObject` parameter to `Get-RubrikLogShipping`
* Updated unit tests for `Get-RubrikLogShipping` to include test for `-DetailedObject` parameter
* Updated `Get-RubrikAPIData` with formatted objecttypes for `New-RubrikSLA` and `Set-RubrikSLA`
* Updated `New-RubrikSLA` and `Set-RubrikSLA` functions to add type names and decorate output similar to `Get-RubrikSLA`
* Error handing in private function `Get-RubrikAPIData`, now displays error when no matching endpoint is found.
* Changed `Get-RubrikEvent`, adding parametersets to isolate eventSeriesId. When cmdlet is called with eventSeriesId the `Get-RubrikEventSeries` cmdlet is now called rather than filtering through a giant, unindexed table. Details in [Issue 580](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/580)

### Added

* Added public cmdlets `Get-RubrikModuleOption`,`Set-RubrikModuleOption`,`Get-RubrikModuleDefaultParameter`,`Set-RubrikModuleDefaultParameter`, and `Remove-RubrikModuleDefaultParameter`.  Added Private functions `Set-RubrikDefaultParameterValue.ps1`, `Update-RubrikModuleOption.ps1`, and `Sync-RubrikOptionsFile` to support the creation of customized module options and default parameters as per [Issue 518](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/518)
* Added public cmdlets `Get-RubrikModuleOption`,`Set-RubrikModuleOption`,`Get-RubrikModuleDefaultParameter`,`Set-RubrikModuleDefaultParameter`, and `Remove-RubrikModuleDefaultParameter`.  Added Private functions `Set-RubrikDefaultParameterValues.ps1`, `Update-RubrikModuleOption.ps1`, and `Sync-RubrikOptionsFile` to support the creation of customized module options and default parameters as per [Issue 518](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/518)
* Added new private function `Get-RubrikDetailedResult` to replace duplicated -DetailedObject code.
* Added new function `Remove-RubrikFilesetTemplate` and added assosciated unit test `Remove-RubrikFilesetTemplate.Tests`
* Added unit test for private function `Get-RubrikSLAFrequencySummary`
* Added additional unit tests for `Disconnect-Rubrik` as per [Issue 598](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/598)
* Added private function `Get-RubrikSLAFrequencySummary` to create a human readable summary of an SLAs frequency settings
* Added unit tests for `New-RubrikLDAP`, `Get-RubrikvCenter`, `New-RubrikvCenter`, `Remove-RubrikvCenter`, `Set-RubrikvCenter`, `Get-RubrikSetting`, `Set-RubrikSetting`, and `Remove-RubrikHost` as per [Issue 345](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/345)
* Added new unit tests: `CommentBasedHelp`, `ObjectDefinitions`, `Connect-Rubrik`, `Disconnect-Rubrik`
* Added `Remove-RubrikFilesetSnapshot`, `RemoveRubrikDatabaseSnapshots`, `Remove-RubrikHyperVSnapshot`, `Remove-RubrikManagedVolumeSnapshot`, `Remove-RubrikNutanixVMSnapshot`, and `Remove-RubrikVolumeGroupSnapshot` along with associated unit tests as outlined in [Issue 309](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/309) *NOTE Remove-RubrikDatabaseSnapshots deletes ALL snapshots for a given database - there is currently no endpoint to support the deletion of a single snapshot*
* Added `Suspend-RubrikSLA` and `Resume-RubrikSLA`
* Added `Get-RubrikEventSeries` to now parse the event_series API rather than events as per [Issue 580](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/580)
* Added unit tests to cover `Get-RubrikEventSeries` and changes to `Get-RubrikEvent`

### Fixed

* Fixed incorrect array in body of `Restore-RubrikDatabase` and added tests to validate new behavior in `Restore-RubrikDatabase.Tests`
* Fixed incorrect array in body of `Export-RubrikDatabase` and added tests to validate new behavior in `Export-RubrikDatabase.Tests`
* Fixed incorrect array in body of `New-RubrikDatabaseMount` and added tests to validate new behavior in `New-RubrikDatabaseMount.Tests`

## [5.0.1](https://github.com/rubrikinc/rubrik-sdk-for-powershell/tree/5.0.1) - 2020-03-05

### Added

* Added `Get-RubrikArchive`, `Get-RubrikBackupServiceDeployment`, `Get-RubrikGuestOsCredential`, `Get-RubrikIPMI`, `Get-RubrikNfsArchive`, `Get-RubrikNutanixCluster`, `Get-RubrikObjectStoreArchive`, `Get-RubrikQstarArchive`, `Get-RubrikReplicationSource`, `Get-RubrikReplicationTarget`, `Get-RubrikScvmm`, `Get-RubrikSecurityClassification`, `Get-RubrikSmbDomain`, `Get-RubrikSmbSecurity`, and `Get-RubrikSyslogServer` cmdlets to retrieve data from a Rubrik cluster for use in the As Built Report module.
* Added QUEUED as a value in the status ValidateSet within Get-RubrikEvent and updated Unit Tests.  Addresses [Issue 539](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/539)
* Added Get-RubrikVMwareDatacenter and Get-RubrikVMwareCluster along with associated Unit Tests. Addresses [Issue 463](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/463)
* Added Object TypeNames for VCD Servers and vCD vApps as specified in [Issue 462](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/462)
* Added DirectArchive switch parameter and associated code to New-RubrikFileSet allowing the isPassthrough attribute to be set to enable NAS Direct Archive. Addresses [Issue 358](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/358)  Updated Unit tests for cmdlets to reflect new parametersets.
* Added Get-RubrikHostVolume and Protect-RubrikHostVolumeGroup.  This addresses cmdlets requested within [Issue 512](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/512).
* Added New-RubrikHyperVVMMount, Get-RubrikHyperVMount and Remove-RubrikHyperVMount addressing [Issue 450](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/450)
* Added support to Get-RubrikRequest for VolumeGroup, Nutanix VMs, EC2 instances, Oracle Databases and VCD vApps as outlined in [Issue 563](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/563)

### Changed

* ValidateSet on Set-RubrikNutanixVM was incorrect. Changed this to the desired values as outlined in [Issue 533](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/533)
* Added null check to results when passing -DetailedObject to Get-RubrikSCVMM. Addresses [Issue 531](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/531)
* Modified New-RubrikSLA in order to support creation of SLAs when used with the pipeline from Get-RubrikSLA as per [Issue 484](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/484)
* Modified ParameterSets on Set-RubrikDatabase to align with logic outlined in [Issue 438](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/438)
* Added more object support to `Get-RubrikObject` as per defined in [Issue 545](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/545) and [Issue 462](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/462)
* Modified Invoke-RubrikRestCall to support the forcing of the body to be a single item array as per defined in [Issue 554](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/554)
* Get-RubrikSnapshot has been changed to convert the current date/time to UTC when using the -Latest parameter. This addresses Issue [535](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/535)
* Restore-RubrikVApp and Export-RubrikVApp has been updated to properly deal with -PowerOn being changed to a switch-type parameter. This addresses issue [536](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/536)
* Export-RubrikVApp has been changed so that it does not request vCD to restore vApp networks if the NICs are removed or unmapped. This addresses issue [537](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/537)

### Fixed

* Documentation links in comment-based help updated to lower case
* Null filter on Get-RubrikSCVMM when using -DetailedObject as per [Issue 556](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/556)
* Fix for RubrikOrgAuthorization API endpoint changed in 5.1 [570](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/568)
* Fixed documentation on Get-RubrikLogshipping [572](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/572)
* Updated New-RubrikBootstrap to address malformed request body and URI. This addresses issue [568](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/568)

## [5.0.0](https://github.com/rubrikinc/rubrik-sdk-for-powershell/tree/5.0.0) - 2019-11-24

### Added

* Added `UserAgent` parameter to `Connect-Rubrik` that allows specifying additional user-agent information.
* Added `UserAgentHash` parameter to private function `New-UserAgentString` that allows specifying additional user-agent information.
* Added Get-RubrikOrgAuthorization, Set-RubrikOrgAuthorization, Remove-RubrikOrgAuthorization and related tests.
* Added new private function, `New-UserAgentString` and associated unit tests
* Added `Set-RubrikProxySetting` and `Remove-RubrikProxySetting` functions
* Added `Rubrik.ProxySetting.ps1xml` to provide formatting for Get- & `Set-RubrikProxySetting`
* Added unit tests for new functions and additional tests for `Get-RubrikProxySetting`
* Added `-DetailedObject` parameter to `Get-RubrikVolumeGroup`
* Added checks within Get-RubrikReportData to detect a limit value of -1. If detected, the cmdlet will perform recursion until all paginations has occurred.
* Added `-AvailabilityGroupID` and `AvailabilityGroupName` parameters to `Get-RubrikDatabase`
* Added unit tests to validate the new functionality
* Added various cmdlets and respective unit tests to support retrieving information from the Rubrik cluster. Development mainly driven from the As Built Report module.
* New cmdlets are `Get-RubrikClusterInfo`, `Get-RubrikClusterNetworkInterface`, `Get-RubrikClusterStorage`, `Get-RubrikDNSSetting`, `Get-RubrikEmailSetting`, `Get-RubrikLoginBanner`, `Get-RubrikNTPServer`, `Get-RubrikNetworkThrottle`, `Get-RubrikNode`, `Get-RubrikNotificationSetting`, `Get-RubrikProxySetting`, and `GetRubrikSnmpSetting`
* Added documentation in all private functions including synopsis, description, parameter help and examples where appropriate
* Added Add-RubrikOrganization and Remove-RubrikOrganization to add and remove organizations, and associated unit tests
* Added Get-RubrikUserRole and Set-RubrikUserRole in order to get and configure user roles and permissions.
* Added private function Update-RubrikuserRole to handle the addition and removal of permissions for the various roles.
* Functionality created in order to make display of return results for certain objects more user friendly.
* Added private function Set-ObjectTypeName which applies a given TypeName definition to cmdlet results.
* Added ObjectTName parameter within Get-RubrikAPIData to the listed objects below
* Added ps1xml files to a newly created ObjectDefinitions folder definining the listed objects below
* Imported all ps1xml files from within the psd1 manifest for the listed objects below
* TypeName format files created for Rubrik.APIToken, Rubrik.AvailabilityGroup, Rubrik.Event, Rubrik.Fileset, Rubrik.FilesetTemplate, Rubrik.Host, Rubrik.HyperVVM, Rubrik.LDAP, Rubrik.LogShipping, Rubrik.ManagedVolume, Rubrik.MSSQLDatabase, Rubrik.MSSQLDatabaseFiles, Rubrik.MSSQLDatabaseMount, Rubrik.NASShare, Rubrik.NutanixVM, Rubrik.OracleDatabase, Rubrik.Report, RubrikSLADomain, Rubrik.SLADomainv1, Rubrik.UnmanagedObject, Rubrik.User, Rubrik.vCenter, Rubrik.VMwareDatastore, Rubrik.VMwareHost, Rubrik.VMwareVM, and Rubrik.VolumeGroup
* Added cmdlets `Update-RubrikVCD`, `Set-RubrikVCD`, `Restore-RubrikVApp`, `Protect-RubrikVApp`, `Get-RubrikVcdTemplateExportOptions`, `Get-RubrikVCD`, `Get-RubrikVappSnapshot`, `RubrikVAppRecoverOptions`, `Get-RubrikVAppExportOptions`, `Get-RubrikVApp`, `Export-RubrikVCDTemplate`, `Export-RubrikVApp` and related tests
* Added `Get-RubrikUser`, `New-RubrikUser`, `Remove-RubrikUser` and `Set-RubrikUser` and respective unit tests to manage user accounts.
* Created unit test for `Invoke-RubrikRestCall`
* Added -Name parameter to `Set-RubrikManagedVolume`. Name already existed within the body definition in `Get-RubrikAPIData`
* Created `Get-RubrikObject` cmdlet and respective Unit test.
* Created unit tests for `Get-RubrikAvailabilityGroup`, `Get-RubrikOrganization`, `Get-RubrikRequest`, `Get-RubrikUnmanagedObject`, `Remove-RubrikUnmanagedObject`, `Set-RubrikAvailabilityGroup`, and `Sync-RubrikTag`.  `Get-RubrikSnapshot` was already present.
* Created unit tests for both `Get-RubrikBootStrap` and `New-RubrikBootStrap`
* Added unit tests for `New-RubrikLogShipping`, `New-RubrikLogBackup`, `Get-RubrikLogShipping`, `Set-RubrikLogShipping`, `Reset-RubrikLogShipping`, and `Remove-RubrikLogShipping`
* Added `Convert-ApiDateTime` function is used to convert API time strings to date time objects and created associated unit tests to validate behavior of function
* Added new `date` property to `Get-RubrikEvent` output, uses new Convert-APIDateTime function for conversion and added additional unit tests to validate proper date time conversion
* Added `Select-ExactMatch private function
* Added `Get-RubrikFileset` now uses new private function instead of the custom code in the function
* Added parameter sets and improved parameter validation for `Get-RubrikManagedVolume`
* Added parameter to `Get-RubrikSnapshot` `-Latest` parameter to return latest snapshot data
* Added parameter to `Get-RubrikSnapshot` `-Range` to use with `-Date`. This specifies how many days away from the given date to search for the closest matching snapshot. Defaults to one day.
* Added parameter to `Get-RubrikSnapshot` `-ExactMatch` to use with `-Date`. This causes no results to be returned if a matching date isn't found. Otherwise, all snapshots are returned if no match is made.
* Added new `Get-RubrikFileset` parameters `-NameFilter` and `-HostNameFilter` parameters to allow for in-fix matching
* Added new tests for `Get-RubrikFileSet`
* Added ability to `Set-RubrikSLA` configure archival and replication settings
* Added Unit Tests for `Get-RubrikFileset`, `Get-RubrikFilesetTemplate`, `New-RubrikFileset`, `New-RubrikFilesetTemplate`, `Protect-RubrikFileset`, and `Remove-RubrikFileset`
* Added unit tests for `Get-RubrikReport`, `Get-RubrikReportData`, `New-RubrikReport`, and `Remove-RubrikReport`. `Export-RubrikReport` unit test already existed.
* Added `Get-RubrikFileSet` DetailedObject parameter has been added to `Get-RubrikFileSet` function to retrieve all object properties
* Added `New-RubrikSLA` ability to specify allowed backup window settings, both for the first full backup and subsequent incremental backups in `New-RubrikSLA`
* Added ability to `Set-RubrikSLA` specify allowed backup window settings, both for the first full backup and subsequent incremental backups in `Set-RubrikSLA`
* Added Unit Tests for `Get-RubrikMount`, `Set-RubrikMount`, `New-RubrikMount`, `Remove-RubrikMount`, `Set-RubrikBlackout`, `Get-RubrikSupportTunnel`, `Set-RubrikSupportTunnel`, `Get-RubrikVersion`, `Get-RubrikAPIVersion` and `Get-RubrikSoftwareVersion`
* Added filtering abilities in `Get-RubrikAPIData` to support id and vmid filtering in the `Get-RubrikMount` cmdlet
* Added unit tests for `Get-RubrikDatabase`, `Get-RubrikDatabaseFiles`, `Get-RubrikDatabaseMount`, `Get-RubrikDatabaseRecoverableRange`, `New-RubrikDatabaseMount`, `Protect-RubrikDatabase`, `Remove-RubrikDatabaseMount`, `Restore-RubrikDatabase`, `Set-RubrikDatabase`, `Get-RubrikSQLInstance`, `Set-RubrikSQLInstace`
* Added unit tests for `Get-RubrikSLA`, `New-RubrikSLA`, `Remove-RubrikSLA`
* Added new `Register-RubrikBackupService`cmdlet to register the Rubrik Backup Service installed on the specified VM with the Rubrik cluster
* Added new `New-RubrikBootstrap` function to send a Rubrik Bootstrap Request
* Added new `Get-RubrikBootstrap` function that Connects to the Rubrik cluster and retrieves the bootstrap process progress
* Created a templates folder with examples of Rubrik bootstrap
* Added new `Set-RubrikSLA` cmdlet to update an existing SLA Domain.
* Added unit tests for `Get-RubrikManagedVolume`, `Get-RubrikManagedVolumeExport`, `Get-RubrikVolumeGroup`, `Get-RubrikVolumeGroupMount`, `New-RubrikManagedVolume`, `New-RubrikManagedVolumeExport`, `New-RubrikVolumeGroupMount`, `Remove-RubrikManagedVolume`, `Remove-RubrikManagedVolumeExport`, `Remove-RubrikVolumeGroupMount`, `Set-RubrikManagedVolume`, `Start-RubrikManagedVolumeSnapshot`, `Start-RubrikManagedVolumeSnapshot`
* Added global attribute 'authType' to $rubrikconnection to remove reliance on userId.
* Added logic to disconnect to address the deletion of tokens when using token based authentication
* Added unit tests for `Update-RubrikHost` and `Update-RubrikvCenter`
* Added unit tests for `Get-RubrikHyperVVM`, `Get-RubrikNutanixVM`, `Move-RubrikMountVMDK`, `New-RubrikVMDKMount`, `Protect-RubrikHyperVVM`, `Protect-RubrikNutanixVM`, `Protect-RubrikVM`, `Set-RubrikHyperVVM`, `Set-RubrikNutanixVM`, `Set-RubrikVM`
* Added Unit Tests for `Export-RubrikReport` & `Export-RubrikDatabase`
* Added associated unit tests for Sync-`RubrikAnnotation`
* Added unit test for `Get-RubrikHost` cmdlet
* Added `Get-RubrikAPIToken` cmdlet
* Added `New-RubrikAPIToken` cmdlet
* Added `Remove-RubrikAPIToken` cmdlet
* Added `Get-RubrikOracleDB` cmdlet
* Added `Remove-RubrikVMSnapshot` cmdlet
* Added new `Update-RubrikVMwareVM` cmdlet to refresh a single VMware VM's metadata
* Added `Export-RubrikVM` cmdlet. Since the cmdlet requires IDs for both a VMware datastore and a VMware host, 2 other cmdlets were developed, `Get-RubrikVMwareDatastore` and `Get-RubrikVMwareHost` to make the whole process easier.
* Added `Set-RubrikVolumeFilterDriver` cmdlet to support the installation/uninstallation of the Rubrik VFD on registered Windows hosts. `Set-RubrikVolumeFilterDriver` takes an array of string (hostIds) and an installed (true/false) parameter to determine whether to install or uninstall the VFD on the given hosts.
* Added a `DetailedObject` switch (similar to that on `Get-RubrikVM`) to the `Get-RubrikHost` cmdlet in order to grab more information when not querying by hostID.  This allows for more information to be returned by the API (IE hostVfdDriverState, hostVfdEnabled). This way users could query Rubrik hosts by name, check installation status, and pipe id's to the new `Set-RubrikVolumeFilterDriver` cmdlet for VFD installation.
* Added `-ApplicationTag` parameter support to `New-RubrikManagedVolume` so users can specify which application the managed volume will be used for
* Added `-name` parameter to `Get-RubrikOrganization`
* Added Custom User Agent value to HTTP headers in `Connect-Rubrik` function
* Added additional 5 tests to `Get-RubrikVM` to validate parameters sets and validation work as intended
* Added parameter sets and parameter validation to `Get-RubrikVM`
* Added ValidateNullNotEmpty to selected parameters in `Get-RubrikVM`
* Added `-DetailedObject` parameter for `Get-RubrikVM`

### Changed

* Changed the output of the user agent string to display platform information with double-dashed separated key-value pairs.
* The link to `quick-start.md` in the `readme.md` has been updated to a relative link
* The private function `Test-RubrikSLA` had a hard coded local variable
* Renamed Get-RubrikVAppExportOptions to `Get-RubrikVAppExportOption` to use singular nouns
* Renamed Get-RubrikVAppRecoverOptions to `Get-RubrikVAppRecoverOption` to use singular nouns
* Renamed Get-RubrikVcdTemplateExportOptions to `Get-RubrikVcdTemplateExportOption` to use singular nouns
* Changed [parameter type from boolean to switch] for all functions
* Modified private function Submit-Request.ps1 to support adding in success/error information for empty POST, PUT and PATCH responses
* Modified status return code for Remove-RubrikManagedObject
* Changed the output of `$UserAgent` string to provide more detailed information about PowerShell version and platform
* Updated `Get-RubrikProxySetting` to support pipelining and formatted output
* Updated private function `New-BodyString` to support forced upper and lowercase for selected properties
* Changed default display of `Get-RubrikVolumeGroup`
* Changed -Limit parameter in `Get-RubrikReportData`
* Added a new property `Function` to the output of `Get-RubrikAPIData`, this fixes an issue with verbose output
* Migrated boolean parameters to switch parameters in order to provide a more consistent approach across all cmdlets. Cmdlets affected are `Export-RubrikVM`, `Get-RubrikEvent`, `Get-RubrikOrganization`, `New-RubrikHost`, `New-RubrikMount`, `Set-RubrikMount`, `Set-RubrikNutanixVM`, `Set-RubrikSupportTunnel` and `Set-RubrikVM`
* Modified URI list in Get-RubrikAPIData for New-RubrikSnapshot to include support for Nutanix and Hyper-V
* Updated `Get-RubrikSnapshot` to support vCD vApps
* Changed `New-RubrikBootstrap`, enhanced validation of strings and validatescript block
* Changed functionality of `New-RubrikLogShipping.Tests` to use inModuleScope
* Changed `New-RubrikLogShipping` If-statement validation to check based on object instead of string
* Set `IgnoreCase` on state parameter for `Set-RubrikLogShipping` as parameters must be uppercase to process in API call.
* Changed `Test-ReturnFormat` private function Improved detection of empty strings
* Changed `Get-RubrikEvent`, added validation for `time` field, if `time` field does not exist it will not add `date` property
* Changed behavior  of `-Relic` switch, by default now retrieves both relic and non-relics. `-Relic` or `-Relic:$false` in addition to that and added additional unit test
* Changed `Test-DateDifference`, a private function used by `Get-RubrikSnapshot`, to support the `-Range` parameter
* Changed behavior of `Get-RubrikFileSet` parameter `-Name` and `-Hostname` changed to only do an exact match
* Updated `Get-RubrikSQLInstance` parameter help to correctly suggest `local` to be used
* Changed default behavior of `Get-RubrikReportData` updated to reflect default behavior of other parameters, setting limit to maximum amount unless specified
* Changed `readme.md` Removed references to the completed refactor branch
* Changed logic for `Set-RubrikSLA` $AdvancedConfig. It's not required anymore to set this parameter directly when piping from Get-RubrikSLA and advanced configuration was already enabled
* Changed `New-RubrikSLA` support for archival and replication settings to New-RubrikSLA
* Changed `Set-RubrikSLA` Removed unnecessary braces for the frequencies array in the request body when using API v2
* Changed `Connect-Rubrik` Added `Userid` to `RubrikConnection` variable when connecting using an API-token
* Changed  Added ability to specify advanced SLA configuration settings introduced in 5.0 on New-RubrikSLA
* Changed `New-RubrikSLA` `-HourlyFrequency` to take input in days or weeks instead of hours
* Changed `Connect-Rubrik`, added validation step for token, a query is executed against the cluster endpoint to validate the token
* Changed `Submit-Request` output type for http status codes and errors to PSCustomObject
* Changed `Get-RubrikDatabase` added ability to specify -DetailedObject on Get-RubrikDatabase
* Changed Minor updates to parameter configurations of `Get-RubrikHyperVVM`, `Get-RubrikNutanixVM`, `Move-RubrikMountVMDK`, `New-RubrikVMDKMount`, `Protect-RubrikHyperVVM`,`Protect-RubrikNutanixVM`, `Protect-RubrikVM`, `Set-RubrikHyperVVM`, `Set-RubrikNutanixVM`, `Set-RubrikVM` so they pass associated unit tests
* Changed `Get-RubrikDatabase`, parameter now has 3 states -Relic -Relic:$false or not specified
* Changed null output to Out-Null To improve PowerShell 6, and onwards compatibility we have standardized on using | Out-Null
* Changed `New-RubrikSnapshot` documentation, added examples of how to do Full backups of Oracle and MSSQL databases
* Changed `quick-start.md`, added a 4th option for downloading and distributing the Rubrik SDK for PowerShell
* Changed `Sync-RubrikAnnotation`, added -DetailedObject to Get-RubrikVM in order to return the snapshots
* Changed `Sync-RubrikAnnotation`, added a third annotation to store the date of the latest Rubrik snapshot.
* Changed `New-RubrikSnapshot` will now display a warning if -ForceFull is set on any other protected object other than Oracle or SQL databases, this is just a warning and the cmdlet will continue to run, performing an incremental backup.
* Changed `New-RubrikSnapshot cmdlet`, added support for Oracle to `New-RubrikSnapshot`
* Changed `New-RubrikSnapshot cmdlet`, added tests for `New-RubrikSnapshot`
* Updated Invoke-RubrikWebRequest so the HTTP status code returned from the API call is displayed when verbose logging is enabled
* Updated Submit-Request to handle `Delete` API calls differently than other calls. Previously `Delete` operations did not surface any status to the user. With this change, the HTTP response code is checked to verify it matches the expected response. If so, it returns a PSObject with the HTTP code and Status = 'Success'.
* Updated `Move-RubrikMountVMDK` and Test-DateDifference to resolve bugs reported. `Move-RubrikMountVMDK` will try to find the snapshot closest to the date specified, within one day. Any valid PowerShell `datetime` formatted string will be accepted as an input, but greater specificity will lead to a much better chance of matching the intended snapshot.
* Updated `Get-RubrikDatabase`, `Get-RubrikFileset`, `Get-RubrikHyperVVM`, `GetRubrikNutanixVM` and `Get-RubrikVolumeGroup`. Calls to `Test-RubrikSLA` were inadvertently overwriting the `$SLAID` variable, causing the paramater to be ignored.
* Updated Typo in Quickstart Documentation
* Updated example 2 in comment-based help of `Invoke-RubrikRESTCall`

### Fixed

* Resolved bug in `Get-RubrikSnapshot` that caused no snapshots to be returned if the amount of snapshots was larger than one
* Replaced occurrences of _local or `**local**` with local within documentation around the primary_cluster_id.
* Updated the links to point to rubrik.gitbook.io from rubrikinc.gitbook.io
* Replaced occurrences of _local with local within documentation around the primary_cluster_id.
* Fixed the -primary_cluster_id case-sensitivity issues
* Updated behavior of New-QueryString, stop adding ?limit to non-Get calls
* Scoped the ID variable to local within the URI construction of `New-RubrikHost` as it was pulling ID variables set within the global scope and causing errors
* Prevent `Get-RubrikVM` $SLAID parameter value overwrite when it has a value
* Fixed `Get-RubrikSQLInstance` `PrimaryClusterID` had a bug
* Fixed bug `Restore-RubrikDatabase` in example, added additional example
* Fixed `Submit-Request` now populating the $WebResult variable in order to show HTTP Status Codes/Descriptions as well as proper status messages for PowerShell versions prior to 6.
* Fixed `Set-RubrikSLA` the $FirstFullBackupDay variable to be an integer when the value is retrieved from the pipeline with `Get-RubrikSLA`
* Fixed `Get-RubrikEvent`, multiple limit flags were added to the GET query
* Fixed `Get-RubrikSnapshot` no endpoint is available for FileSet snapshots, working has been created
* Fixed `Get-RubrikSnapshot` incorrect endpoint was used for Oracle database in combination Get-RubrikSnapshot
* Fixed `Get-RubrikAPIToken` pwsh 5 bug fixed
* Fixed `Get-RubrikReportData` now correctly returns all data
* Fixed Performance of JSON parsing improved for PowerShell 6 and later
* Fixed `Protect-RubrikTag` modified Protect-RubrikTag in order to ignore relic's when retrieving the vCenter UUID.
* Fixed `Get-RubrikHost`, `Get-RubrikVM`, `Get-RubrikOracleDB`, added formating around $result to convert to an array in order to support `-DetailedObject` with older versions of Powershell
* Resolved bug in `New-RubrikVMDKMount`, thanks @Pierre-PvF
* Fixed `Get-RubrikOrganization` will only return an exact match
* Fixed documentation to fix errors on `Protect-RubrikVM`

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
