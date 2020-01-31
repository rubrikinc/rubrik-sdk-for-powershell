function Get-RubrikAPIData($endpoint) {
    <#
        .SYNOPSIS
        Helper function to retrieve API data from Rubrik

        .DESCRIPTION
        Function which defines the structure of each cmdlet's API request and response based on the software version the connected Rubrik cluster.
    #>
    $api = @{
        Example                        = @{
            '1.0' = @{
                Description = 'Details about the API endpoint'
                URI         = 'The URI expressed as /api/v#/endpoint'
                Method      = 'Method to use against the endpoint'
                Body        = 'Parameters to use in the body'
                Query       = 'Parameters to use in the URI query'
                Result      = 'If the result content is stored in a higher level key, express it here to be unwrapped in the return'
                Filter      = 'If the result content needs to be filtered based on key names, express them here'
                Success     = 'The expected HTTP status code for a successful call'
            }
        }
        'Connect-Rubrik'               = @{
            '3.0' = @{
                Description = 'Create a new login session'
                URI         = '/api/v1/session'
                Method      = 'Post'
                Body        = ''
                Query       = @{
                    organization_id = 'organization_id'
                }
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Disconnect-Rubrik'            = @{
            '1.0' = @{
                Description = 'Closes a user session and invalidates the session token'
                URI         = '/api/v1/session/{id}'
                Method      = 'Delete'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '204'
            }
        }
        'Export-RubrikDatabase'        = @{
            '1.0' = @{
                Description = 'Export MSSQL Database from Rubrik to Destination Instance.'
                URI         = '/api/v1/mssql/db/{id}/export'
                Method      = 'Post'
                Body        = @{
                    targetInstanceId   = 'targetInstanceId'
                    targetDatabaseName = 'targetDatabaseName'
                    recoveryPoint      = @{
                        lsnPoint = @{lsn='lsn'}
                        timestampMs = 'timestampMs'
                    }
                    finishRecovery     = 'finishRecovery'
                    maxDataStreams     = 'maxDataStreams'
                    targetDataFilePath = 'targetDataFilePath'
                    targetLogFilePath  = 'targetLogFilePath'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'Export-RubrikVM'        = @{
            '1.0' = @{
                Description = 'Export a VMware VM to an existing vSphere environment'
                URI         = '/api/v1/vmware/vm/snapshot/{id}/export'
                Method      = 'Post'
                Body        = @{
                    vmName                  = 'vmName'
                    disableNetwork          = 'disableNetwork'
                    removeNetworkDevices    = 'removeNetworkDevices'
                    powerOn                 = 'powerOn'
                    hostId                  = 'hostId'
                    datastoreId             = 'datastoreId'
                    shouldRecoverTags       = 'shouldRecoverTags'
                    keepMacAddresses        = 'keepMacAddresses'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'Export-RubrikReport'          = @{
            '1.0' = @{
                Description = 'Get the link to a CSV file for a report.'
                URI         = '/api/internal/report/{id}/download_csv'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    timezone_offset = 'timezone_offset'
                }
                Result      = 'data'
                Filter      = ''
                Success     = '200'
            }
            '4.1' = @{
                Description = 'Get the link to a CSV file for a report.'
                URI         = '/api/internal/report/{id}/csv_link'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    timezone_offset = 'timezone_offset'
                }
                Result      = 'data'
                Filter      = ''
                Success     = '200'
            }
        }
        'Export-RubrikVApp'       = @{
            '1.0' = @{
                Description = 'Exports a given snapshot for a vCD vApp'
                URI         = '/api/internal/vcd/vapp/snapshot/{id}/export'
                Method      = 'Post'
                Body        = @{
                    exportMode  = 'exportMode'
                    networksToRestore = [System.Collections.ArrayList]@()
                    vmsToExport = @( 
                        @{
                            name   		= 'name'
                            vcdMoid     = 'vcdMoid'
                            networkConnections = @{
                                nicIndex		= 'nicIndex'
                                addressingMode	= 'addressingMode'
                                ipAddress		= 'ipAddress'
                                isConnected		= 'isConnected'
                                vappNetworkName	= 'vappNetworkName'
                            }
                        }
                    )
                    shouldPowerOnVmsAfterRecovery = 'shouldPowerOnVmsAfterRecovery'
                    newVappParams = @{
                        name     = 'name'
                        orgVdcId = 'orgVdcId'
                    }
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'Export-RubrikVcdTemplate'       = @{
            '1.0' = @{
                Description = 'Exports a given vCD template'
                URI         = '/api/v1/vcd/vapp/template/snapshot/{id}/export'
                Method      = 'Post'
                Body        = @{
                    name            = 'name'
                    catalogId       = 'catalogId'
                    orgVdcId        = 'orgVdcId'
                    storagePolicyId = 'storagePolicyId'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'Get-RubrikAPIToken'         = @{
            '5.0' = @{
                Description = 'Retrieves list of generated API tokens from the Rubrik cluster'
                URI         = '/api/internal/session'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    user_id     = 'user_id'
                }
                Result      = 'data'
                Filter      = @{
                    'tag'               = 'tag'
                    'organizationId'    = 'organizationId'
                }
                Success     = '200'
                ObjectTName = 'Rubrik.APIToken'
            }
        }       
        'Get-RubrikAPIVersion'         = @{
            '1.0' = @{
                Description = 'Retrieves software version of the Rubrik cluster'
                URI         = '/api/v1/cluster/{id}/api_version'
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = 'apiVersion'
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikArchive'         = @{
            '1.0' = @{
                Description = 'Retrieves software version of the Rubrik cluster'
                URI         = '/api/internal/archive/location'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    'ArchiveType'  = 'location_type' 
                }
                Result      = 'data'
                Filter      = @{
                    'name'          = 'name'
                    'id'            = 'id'
                }
                Success     = '200'
                ObjectTName = 'Rubrik.Archive'
            }
        }
        'Get-RubrikAvailabilityGroup' = @{
            '1.0' = @{
                Description = 'Get summary information for Microsoft SQL availability groups'
                URI         = '/api/internal/mssql/availability_group'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    primary_database_id     = 'primary_database_id'
                }
                Result      = 'data'
                Filter      = @{
                    'GroupName'     = 'name'
                    'SLA'      = 'effectiveSlaDomainName'
                    'SLAID'    = 'effectiveSlaDomainId'
                }
                Success     = '200'
                ObjectTName = 'Rubrik.AvailabilityGroup'
            }
        }
        'Get-RubrikClusterInfo'         = @{
            '4.2' = @{
                Description = 'Retrieves advanced settings of the Rubrik cluster'
                URI         = @{
                    BrikCount           = '/api/internal/cluster/me/brik_count'
                    MemoryCapacityInGb  = '/api/internal/cluster/me/memory_capacity'
                    CPUCoresCount       = '/api/internal/node/*/cpu_cores_count'
                    ConnectedToPolaris  = '/api/internal/cluster/me/global_manager'
                    NodeCount           = '/api/internal/cluster/me/node'
                    HasTPM              = '/api/internal/cluster/me/has_tpm'
                    IsEncrypted         = '/api/internal/cluster/me/is_encrypted'
                    IsHardwareEncrypted = '/api/internal/cluster/me/is_hardware_encrypted'
                    IsOnCloud           = '/api/internal/cluster/me/is_on_cloud'
                    IsRegistered        = '/api/internal/cluster/me/is_registered'
                    IsSingleNode        = '/api/internal/cluster/me/is_single_node'
                    Platform            = '/api/internal/cluster/me/platforminfo'
                    GeneralInfo         = '/api/v1/cluster/me'
                    Status              = '/api/internal/cluster/me/system_status'

                }
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
            '5.0' = @{
                Description = 'Retrieves advanced settings of the Rubrik cluster'
                URI         = @{
                    BrikCount           = '/api/internal/cluster/me/brik_count'
                    MemoryCapacityInGb  = '/api/internal/cluster/me/memory_capacity'
                    CPUCoresCount       = '/api/internal/node/*/cpu_cores_count'
                    ConnectedToPolaris  = '/api/internal/cluster/me/global_manager'
                    NodeCount           = '/api/internal/cluster/me/node'
                    HasTPM              = '/api/internal/cluster/me/has_tpm'
                    OnlyAzureSupport    = '/api/internal/cluster/me/is_azure_cloud_only'
                    IsEncrypted         = '/api/internal/cluster/me/is_encrypted'
                    IsHardwareEncrypted = '/api/internal/cluster/me/is_hardware_encrypted'
                    IsOnCloud           = '/api/internal/cluster/me/is_on_cloud'
                    IsRegistered        = '/api/internal/cluster/me/is_registered'
                    IsSingleNode        = '/api/internal/cluster/me/is_single_node'
                    Platform            = '/api/internal/cluster/me/platforminfo'
                    GeneralInfo         = '/api/v1/cluster/me'
                    Status              = '/api/internal/cluster/me/system_status'

                }
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikClusterNetworkInterface'           = @{
            '1.0' = @{
                Description = 'Returns details of the network interfaces configured on nodes within the Rubrik cluster'
                URI         = '/api/internal/cluster/me/network_interface'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    interface = 'interface'
                }
                Result      = 'data'
                Filter      = @{
                    'Node'  = 'node'
                }
                Success     = '200'
            }
        }
        'Get-RubrikClusterStorage'         = @{
            '4.2' = @{
                Description = 'Retrieves advanced settings of the Rubrik cluster'
                URI         = @{
                        StorageOverview         = '/api/internal/stats/system_storage'
                        DiskCapacityInTb        = '/api/internal/cluster/me/disk_capacity'
                        FlashCapacityInTb       = '/api/internal/cluster/me/flash_capacity'
                        CloudStorage            = '/api/internal/stats/cloud_storage'
                        LocalStorageIngested    = '/api/internal/stats/snapshot_storage/ingested'
                        DailyGrowth             = '/api/internal/report/summary/average_local_growth_per_day'
                               }
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
            '5.0' = @{
                Description = 'Retrieves advanced settings of the Rubrik cluster'
                URI         = @{
                        StorageOverview         = '/api/internal/stats/system_storage'
                        DiskCapacityInTb        = '/api/internal/cluster/me/disk_capacity'
                        FlashCapacityInTb       = '/api/internal/cluster/me/flash_capacity'
                        CloudStorage            = '/api/internal/stats/cloud_storage/physical'
                        CloudStorageIngested    = '/api/internal/stats/cloud_storage/ingested'
                        LocalStorageIngested    = '/api/internal/stats/snapshot_storage/ingested'
                        DailyGrowth             = '/api/internal/report/summary/average_local_growth_per_day'
                               }
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikBackupServiceDeployment'           = @{
            '1.0' = @{
                Description = 'Retrieve the global settings for automatic deployment of the Rubrik Backup Service to virtual machines.'
                URI         = '/api/internal/vmware/agent'
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikDatabase'           = @{
            '1.0' = @{
                Description = 'Returns a list of summary information for Microsoft SQL databases.'
                URI         = '/api/v1/mssql/db'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    instance_id             = 'instance_id'
                    effective_sla_domain_id = 'effective_sla_domain_id'
                    primary_cluster_id      = 'primary_cluster_id'
                    is_relic                = 'is_relic'
                    availability_group_id   = 'availability_group_id'
                }
                Result      = 'data'
                Filter      = @{
                    'Name'     = 'name'
                    'SLA'      = 'effectiveSlaDomainName'
                    'Hostname' = 'rootProperties.rootName'
                    'Instance' = 'instanceName'
                    'AvailabilityGroupID' = 'availabilityGroupId'
                }
                Success     = '200'
                ObjectTName = 'Rubrik.MSSQLDatabase'
            }
        }
        'Get-RubrikDatabaseFiles'      = @{
            '1.0' = @{
                Description = 'Returns a list of files for the database.'
                URI         = '/api/internal/mssql/db/{id}/restore_files'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    time = 'time'
                }
                Result      = ''
                Filter      = ''
                Success     = '200'
                ObjectTName = 'Rubrik.MSSQLDatabaseFiles'
            }
        }
        'Get-RubrikDatabaseMount'      = @{
            '1.0' = @{
                Description = 'Retrieve information for all live mounts for databases'
                URI         = '/api/v1/mssql/db/mount'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    source_database_id    = 'source_database_id'
                    source_database_name  = 'source_database_name'
                    target_instance_id    = 'target_instance_id'
                    mounted_database_name = 'mounted_database_name'
                    offset                = 'offset'
                    limit                 = 'limit'
                }
                Result      = 'data'
                Filter      = ''
                Success     = '200'
                ObjectTName = 'Rubrik.MSSQLDatabaseMount'
            }
        }
        'Get-RubrikDatabaseRecoverableRange'           = @{
            '1.0' = @{
                Description = 'Returns a list of summary information for Microsoft SQL databases.'
                URI         = '/api/v1/mssql/db/{id}/recoverable_range'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    before_time = 'before_time'
                    after_time = 'after_time'
                }
                Result      = 'data'
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikDNSSetting'         = @{
            '1.0' = @{
                Description = 'Retrieves DNS settings of the Rubrik cluster'
                URI         = @{
                    DNSServers       = '/api/internal/cluster/me/dns_nameserver'
                    DNSSearchDomain  = '/api/internal/cluster/me/dns_search_domain'
                }
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikEmailSetting'           = @{
            '1.0' = @{
                Description = 'Returns details of the configured email settings within the Rubrik cluster'
                URI         = '/api/internal/smtp_instance'
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = 'data'
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikEvent'               = @{
            '1.0' = @{
                Description = 'Retrieve information for the latest of related events that match the value specified in any of the following categories: type, status, or ID, and limit events by date.'
                URI         = '/api/internal/event'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    limit = 'limit'
                    after_id = 'after_id'
                    event_series_id = 'event_series_id'
                    status = 'status'
                    event_type = 'event_type'
                    object_ids = 'object_ids'
                    object_name = 'object_name'
                    before_date = 'before_date'
                    after_date = 'after_date'
                    object_type = 'object_type'
                    show_only_latest = 'show_only_latest'
                    filter_only_on_latest = 'filter_only_on_latest'
                }
                Result      = 'data'
                Filter      = ''
                Success     = '200'
                ObjectTName = 'Rubrik.Event'
            }
        }
        'Get-RubrikFileset'            = @{
            '1.0' = @{
                Description = 'Retrieve summary information for each fileset. Optionally, filter the retrieved information.'
                URI         = '/api/v1/fileset'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    primary_cluster_id      = 'primary_cluster_id'
                    host_id                 = 'host_id'
                    is_relic                = 'is_relic'
                    effective_sla_domain_id = 'effective_sla_domain_id'
                    template_id             = 'template_id'
                    limit                   = 'limit'
                    offset                  = 'offset'
                    cached                  = 'cached'
                    name                    = 'name'
                    host_name               = 'host_name'
                    share_id                = 'share_id'
                }
                Result      = 'data'
                Filter      = @{
                    'SLA' = 'effectiveSlaDomainName'
                }
                Success     = '200'
                ObjectTName = 'Rubrik.Fileset'
            }
        }
        'Get-RubrikFilesetTemplate'    = @{
            '1.0' = @{
                Description = 'Retrieve summary information for all fileset templates, including: ID and name of the fileset template, fileset template creation timestamp, array of the included filepaths, array of the excluded filepaths.'
                URI         = '/api/v1/fileset_template'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    primary_cluster_id    = 'primary_cluster_id'
                    operating_system_type = 'operating_system_type'
                    name                  = 'name'
                    share_type            = 'share_type'
                }
                Result      = 'data'
                Filter      = ''
                Success     = '200'
                ObjectTName = 'Rubrik.FilesetTemplate'
            }
        }
        'Get-RubrikGuestOsCredential'      = @{
            '1.0' = @{
                Description = 'Returns the known guest os credentials from Rubrik'
                URI         = '/api/internal/vmware/guest_credential'
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = 'data'
                Filter      = @{
                    Username = 'username'
                    Domain = 'domain'
                }
                Success     = '200'
            }
        }
        'Get-RubrikHost'               = @{
            '1.0' = @{
                Description = 'Retrieve summary information for all hosts that are registered with a Rubrik cluster'
                URI         = '/api/v1/host'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    operating_system_type = 'operating_system_type'
                    primary_cluster_id    = 'primary_cluster_id'
                    hostname              = 'hostname'
                    name                  = 'name'
                }
                Result      = 'data'
                Filter      = @{
                    Name            = 'name'
                }
                Success     = '200'
                ObjectTName = 'Rubrik.Host'
            }
        }
        'Get-RubrikHyperVVM'                 = @{
            '1.0' = @{
                Description = 'Get summary of all HyperV VMs'
                URI         = '/api/internal/hyperv/vm'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    is_relic                = 'is_relic'
                    name                    = 'name'
                    effective_sla_domain_id = 'effective_sla_domain_id'
                    sla_assignment          = 'sla_assignment'
                    primary_cluster_id      = 'primary_cluster_id'
                }
                Result      = 'data'
                Filter      = @{
                    'Name' = 'name'
                    'SLA'  = 'effectiveSlaDomainName'
                }
                Success     = '200'
                ObjectTName = 'Rubrik.HyperVVM'
            }
        }
        'Get-RubrikIPMI'              = @{
            '1.0' = @{
                Description = 'Retrieve the configured IPMI settings within the Rubrik Cluster'
                URI         = '/api/internal/cluster/me/ipmi'
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikLDAP'         = @{
            '1.0' = @{
                Description = 'Retrieves all LDAP settings of the Rubrik cluster'
                URI         = '/api/v1/ldap_service'
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = 'data'
                Filter      = @{
                    DomainType = 'domainType'
                    ID = 'id'
                    InitialRefreshStatus = 'initialRefreshStatus'
                    Name = 'name'
                }
                Success     = '200'
                ObjectTName = 'Rubrik.LDAP'
            }
        }
        'Get-RubrikLoginBanner'         = @{
            '5.0' = @{
                Description = 'Retrieves the Login Banner text of the Rubrik Cluster'
                URI         = '/api/internal/cluster/me/login_banner'
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''''
                Success     = '200'
            }
        }
        'Get-RubrikUser'         = @{
            '1.0' = @{
                Description = 'Retrieves settings related to a given user within the Rubrik cluster'
                URI         = '/api/internal/user'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    username = 'username'
                    auth_domain_id = 'auth_domain_id'
                }
                Result      = ''
                Filter      = ''
                Success     = '200'
                ObjectTName = 'Rubrik.User'
            }
        }
        'Get-RubrikUserRole'         = @{
            '1.0' = @{
                Description = 'Retrieves settings related to a given users role and authorization within the Rubrik cluster'
                URI         = '/api/internal/authorization'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    principals = 'principals'
                }
                Result      = 'Data'
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikManagedVolume'           = @{
            '1.0' = @{
                Description = 'Returns a list of summary information for Rubrik Managed Volumes'
                URI         = '/api/internal/managed_volume'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    effective_sla_domain_id = 'effective_sla_domain_id'
                    primary_cluster_id      = 'primary_cluster_id'
                    is_relic                = 'is_relic'
                }
                Result      = 'data'
                Filter      = @{
                    'Name'     = 'name'
                    'SLA'      = 'effectiveSlaDomainName'
                }
                Success     = '200'
                ObjectTName = 'Rubrik.ManagedVolume'
            }
        }
        'Get-RubrikManagedVolumeExport'           = @{
            '1.0' = @{
                Description = 'Returns a list of summary information for Rubrik Managed Volume Exports'
                URI         = '/api/internal/managed_volume/snapshot/export'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    source_managed_volume_id = 'source_managed_volume_id'
                    source_managed_volume_name = 'source_managed_volume_name'
                }
                Result      = 'data'
                Filter      = @{
                    SourceManagedVolumeID = 'SourceManagedVolumeID'
                    SourceManagedVolumeName = 'SourceManagedVolumeName'
                }
                Success     = '200'
            }
        }
        'Get-RubrikMount'              = @{
            '1.0' = @{
                Description = 'Retrieve information for all live mounts'
                URI         = '/api/v1/vmware/vm/snapshot/mount'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    vm_id  = 'vm_id'
                    offset = 'offset'
                    limit  = 'limit'
                }
                Result      = 'data'
                Filter      = @{
                    id = 'id'
                    vmId = 'vmId'    
                }
                Success     = '200'
            }
        }
        'Get-RubrikNASShare'              = @{
            '1.0' = @{
                Description = 'Retrieve information NAS Shares'
                URI         = '/api/internal/host/share'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    host_id  = 'host_id'
                    share_type = 'share_type'
                    primary_cluster_id  = 'primary_cluster_id'
                }
                Result      = 'data'
                Filter      = @{
                    hostName = 'hostName'
                    exportPoint = 'exportPoint'
                }
                Success     = '200'
                ObjectTName = 'Rubrik.NASShare'
            }
        }
        'Get-RubrikNetworkThrottle'              = @{
            '1.0' = @{
                Description = 'Retrieve information network throttling within the Rubrik Cluster'
                URI         = '/api/internal/network_throttle'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    'resource_id' = 'resource_id'
                }
                Result      = 'data'
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikNFSArchive'         = @{
            '1.0' = @{
                Description = 'Retrieves a list of NFS archives from the Rubrik cluster'
                URI         = '/api/internal/archive/nfs'
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = 'data'
                Filter      = @{
                    name = 'definition.Name'
                }
                Success     = '200'
                ObjectTName = 'Rubrik.ArchiveDetailed'
            }
        }
        'Get-RubrikNode'              = @{
            '1.0' = @{
                Description = 'Retrieve information on nodes within the Rubrik Cluster'
                URI         = '/api/internal/cluster/{id}/node'
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = 'data'
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikNotificationSetting'           = @{
            '5.0' = @{
                Description = 'Returns details of the configured notification settings within the Rubrik cluster'
                URI         = '/api/internal/notification_setting'
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = 'data'
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikNTPServer'           = @{
            '1.0' = @{
                Description = 'Returns details of the configured NTP servers within the Rubrik cluster'
                URI         = '/api/internal/cluster/me/ntp_server'
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = 'data'
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikNutanixCluster'                 = @{
            '1.0' = @{
                Description = 'Get summary of all Nutanix Clusters'
                URI         = '/api/internal/nutanix/cluster'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    should_get_status       = 'should_get_status'
                    primary_cluster_id      = 'primary_cluster_id'
                }
                Result      = 'data'
                Filter      = @{
                    'Name' = 'name'
                    'Hostname'  = 'hostname'
                }
                Success     = '200'
                ObjectTName = 'Rubrik.NutanixCluster'
            }
        }
        'Get-RubrikNutanixVM'                 = @{
            '1.0' = @{
                Description = 'Get summary of all Nutanix VMs'
                URI         = '/api/internal/nutanix/vm'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    is_relic                = 'is_relic'
                    name                    = 'name'
                    effective_sla_domain_id = 'effective_sla_domain_id'
                    sla_assignment          = 'sla_assignment'
                    primary_cluster_id      = 'primary_cluster_id'
                }
                Result      = 'data'
                Filter      = @{
                    'Name' = 'name'
                    'SLA'  = 'effectiveSlaDomainName'
                }
                Success     = '200'
                ObjectTName = 'Rubrik.NutanixVM'
            }
        }
        'Get-RubrikObjectStoreArchive'         = @{
            '1.0' = @{
                Description = 'Retrieves a list of object store archives from the Rubrik cluster'
                URI         = '/api/internal/archive/object_store'
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = 'data'
                Filter      = @{
                    name = 'definition.Name'
                }
                Success     = '200'
                ObjectTName = 'Rubrik.ArchiveDetailed'
            }
        }
        'Get-RubrikOracleDB'                = @{
            '1.0' = @{
                Description = 'Get summary of all the Oracle DBs'
                URI         = '/api/internal/oracle/db'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    is_relic                = 'is_relic'
                    is_live_mount           = 'is_live_mount'
                    name                    = 'name'
                    effective_sla_domain_id = 'effective_sla_domain_id'
                    sla_assignment          = 'sla_assignment'
                    primary_cluster_id      = 'primary_cluster_id'
                }
                Result      = 'data'
                Filter      = @{
                    'Name' = 'name'
                    'SLA'  = 'effectiveSlaDomainName'
                }
                Success     = '200'
                ObjectTName = 'Rubrik.OracleDatabase'
            }
        }
        'Get-RubrikOrganization'                 = @{
            '1.0' = @{
                Description = 'Get summary of all Rubrik organizations'
                URI         = '/api/internal/organization'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    is_global                = 'is_global'
                    name                     = 'name'
                }
                Result      = 'data'
                Filter      = @{
                    'name' = 'name'
                }
                Success     = '200'
            }
        }
        'Get-RubrikOrgAuthorization'         = @{
            '1.0' = @{
                Description = 'Gets the current list of explicit authorizations for the organization role'
                URI         = '/api/internal/authorization/role/organization'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    principals = 'principals'
                    organization_id = 'organization_id'
                }
                Result      = 'data'
                Filter      = ''
                Success     = '200'
                ObjectTName = 'Rubrik.OrgAuthorization'
            }
        }
        'Get-RubrikProxySetting'           = @{
            '1.0' = @{
                Description = 'Get Rubrik Node Proxy Configuration'
                URI         = '/api/internal/node_management/proxy_config'
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
                ObjectTName = 'Rubrik.ProxySetting'
            }
        }
        'Get-RubrikQstarArchive'         = @{
            '1.0' = @{
                Description = 'Retrieves a list of Qstar archives from the Rubrik cluster'
                URI         = '/api/internal/archive/qstar'
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = 'data'
                Filter      = @{
                    name = 'definition.Name'
                }
                Success     = '200'
                ObjectTName = 'Rubrik.ArchiveDetailed'
            }
        }
        'Get-RubrikReplicationSource'           = @{
            '1.0' = @{
                Description = 'Get summaries for all replication sources'
                URI         = '/api/internal/replication/source'
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = 'data'
                Filter      = @{
                    sourceClusterName = 'sourceClusterName'
                }
                Success     = '200'
            }
        }
        'Get-RubrikReplicationTarget'           = @{
            '1.0' = @{
                Description = 'Get summaries for all replication targets'
                URI         = '/api/internal/replication/target'
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = 'data'
                Filter      = @{
                    targetClusterName = 'targetClusterName'
                }
                Success     = '200'
            }
        }
        'Get-RubrikReport'             = @{
            '1.0' = @{
                Description = 'Retrieve summary information for each report.'
                URI         = '/api/internal/report'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    report_type = 'report_type'
                    search_text = 'search_text'
                }
                Result      = 'data'
                Filter      = ''
                Success     = '200'
                ObjectTName = 'Rubrik.Report'
            }
            '4.1' = @{
                Description = 'Retrieve summary information for each report.'
                URI         = '/api/internal/report'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    report_type = 'report_type'
                    search_text = 'name'
                }
                Result      = 'data'
                Filter      = ''
                Success     = '200'
                ObjectTName = 'Rubrik.Report'
            }
        }
        'Get-RubrikReportData'         = @{
            '1.0' = @{
                Description = 'Retrieve table data for a specific report'
                URI         = '/api/internal/report/{id}/table'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    search_value      = 'search_value'
                    sla_domain_id     = 'sla_domain_id'
                    task_type         = 'task_type'
                    task_status       = 'task_status'
                    object_type       = 'object_type'
                    compliance_status = 'compliance_status'
                    cluster_location  = 'cluster_location'
                }
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
            '4.1' = @{
                Description = 'Retrieve table data for a specific report'
                URI         = '/api/internal/report/{id}/table'
                Method      = 'Post'
                Body        = @{
                    limit          = 'limit'
                    sortBy         = 'sortBy'
                    sortOrder      = 'sortOrder'
                    search_value   = 'objectName'
                    cursor         = 'cursor'
                    requestFilters = @{
                        sla_domain_id     = 'slaDomain'
                        task_type         = 'taskType'
                        task_status       = 'taskStatus'
                        object_type       = 'objectType'
                        compliance_status = 'complianceStatus'
                        cluster_location  = 'clusterLocation'
                    }
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikRequest'            = @{
            '1.0' = @{
                Description = 'Get details about an async request.'
                URI         = '/api/v1/{type}/request/{id}'
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikScvmm'      = @{
            '1.0' = @{
                Description = 'Returns the known SCVMM servers from Rubrik'
                URI         = '/api/internal/hyperv/scvmm'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    primary_cluster_id = 'primary_cluster_id'
                    sla_assignment      = 'sla_assignment'
                    effective_sla_domain_id = 'effective_sla_domain_id'
                }
                Result      = 'data'
                Filter      = @{
                    'Name' = 'name'
                }
                Success     = '200'
                ObjectTName = 'Rubrik.Scvmm'
            }
        }
        'Get-RubrikSecurityClassification'      = @{
            '1.0' = @{
                Description = 'Returns a the security classification settings from Rubrik'
                URI         = '/api/internal/cluster/me/security_classification'
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikSetting'         = @{
            '1.0' = @{
                Description = 'Retrieves all settings of the Rubrik cluster'
                URI         = '/api/v1/cluster/{id}'
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = 'settings'
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikSLA'                = @{
            '1.0' = @{
                Description = 'Retrieve summary information for all SLA Domains'
                URI         = '/api/v1/sla_domain'
                Method      = 'Get'
                Body        = 'Parameters to use in the body'
                Query       = @{
                    primary_cluster_id = 'primary_cluster_id'
                }
                Result      = 'data'
                Filter      = @{
                    'Name' = 'name'
                }
                Success     = '200'
                ObjectTName = 'Rubrik.SLADomainv1'
            }
            '5.0' = @{
                Description = 'Retrieve summary information for all SLA Domains'
                URI         = '/api/v2/sla_domain'
                Method      = 'Get'
                Body        = 'Parameters to use in the body'
                Query       = @{
                    primary_cluster_id = 'primary_cluster_id'
                }
                Result      = 'data'
                Filter      = @{
                    'Name' = 'name'
                }
                Success     = '200'
                ObjectTName = 'Rubrik.SLADomain'
            }
        }
        'Get-RubrikSmbDomain'              = @{
            '1.0' = @{
                Description = 'Retrieve the configured SMB Domains within the Rubrik Cluster'
                URI         = '/api/internal/smb/domain'
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = 'data'
                Filter      = @{
                    'Name' = 'name'
                }
                Success     = '200'
            }
        }
        'Get-RubrikSmbSecurity'              = @{
            '1.0' = @{
                Description = 'Retrieve the configured SMB security configuration within the Rubrik Cluster'
                URI         = '/api/internal/smb/config'
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikSnapshot'           = @{
            '1.0' = @{
                Description = 'Retrieve information for all snapshots'
                URI         = @{
                    Fileset = '/api/v1/fileset/{id}/snapshot'
                    MSSQL   = '/api/v1/mssql/db/{id}/snapshot'
                    VMware  = '/api/v1/vmware/vm/{id}/snapshot'
                    HyperV  = '/api/internal/hyperv/vm/{id}/snapshot'
                    ManagedVolume = '/api/internal/managed_volume/{id}/snapshot'
                    Nutanix = '/api/internal/nutanix/vm/{id}/snapshot'
                    VolumeGroup = '/api/internal/volume_group/{id}/snapshot'
                    Oracle = '/api/internal/oracle/db/{id}/snapshot'
                    VcdVapp = '/api/internal/vcd/vapp/{id}/snapshot'
                }
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = 'data'
                Filter      = @{
                    'CloudState'       = 'cloudState'
                    'OnDemandSnapshot' = 'isOnDemandSnapshot'
                }
                Success     = '200'
            }
        }
        'Get-RubrikSNMPSetting'           = @{
            '1.0' = @{
                Description = 'Returns details of the configured SNMP settings within the Rubrik cluster'
                URI         = '/api/internal/cluster/me/snmp_configuration'
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikSoftwareVersion'    = @{
            '1.0' = @{
                Description = 'Retrieves software version of the Rubrik cluster'
                URI         = '/api/v1/cluster/{id}/version'
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = 'version'
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikSQLInstance'        = @{
            '1.0' = @{
                Description = 'Returns a list of summary information for Microsoft SQL instances.'
                URI         = '/api/v1/mssql/instance'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    instance_id = 'instance_id'
                    primary_cluster_id = 'primary_cluster_id'
                }
                Result      = 'data'
                Filter      = @{
                    'Name'     = 'name'
                    'SLA'      = 'configuredSlaDomainName'
                    'Hostname' = 'rootProperties.rootName'
                }
                Success     = '200'
                ObjectTName = 'Rubrik.MSSQLInstance'
            }
        }
        'Get-RubrikSupportTunnel'      = @{
            '1.0' = @{
                Description = 'To be used by Admin to check status of the support tunnel.'
                URI         = '/api/internal/node/me/support_tunnel'
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikSyslogServer'              = @{
            '1.0' = @{
                Description = 'Retrieve the configured syslog servers within the Rubrik Cluster'
                URI         = '/api/internal/syslog'
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = 'data'
                Filter      = @{
                    'Name' = 'hostname'
                }
                Success     = '200'
            }
        }
        'Get-RubrikUnmanagedObject'    = @{
            '1.0' = @{
                Description = 'Get summary of all the objects with unmanaged snapshots'
                URI         = '/api/internal/unmanaged_object'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    search_value     = 'search_value'
                    unmanaged_status = 'unmanaged_status'
                    object_type      = 'object_type'
                }
                Result      = 'data'
                Filter      = ''
                Success     = '200'
                ObjectTName = 'Rubrik.UnmanagedObject'
            }
        }
        'Get-RubrikVApp'                 = @{
            '1.0' = @{
                Description = 'Get summary of all the vCD vApps'
                URI         = '/api/internal/vcd/vapp'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    is_relic                = 'is_relic'
                    name                    = 'name'
                    effective_sla_domain_id = 'effective_sla_domain_id'
                    sla_assignment          = 'sla_assignment'
                    primary_cluster_id      = 'primary_cluster_id'
                }
                Result      = 'data'
                Filter      = @{
                    'Name'             = 'name'
                    'SLA'              = 'effectiveSlaDomainName'
                    'SourceObjectId'   = 'effectiveSlaSourceObjectId'
                    'SourceObjectName' = 'effectiveSlaSourceObjectName'
                    'vcdClusterId'     = 'vcdClusterId'
                    'vcdClusterName'   = 'vcdClusterName'
                }
                Success     = '200'
                ObjectTName = 'Rubrik.VCDvApp'
            }
        }
        'Get-RubrikVAppExportOption'                = @{
            '1.0' = @{
                Description = 'Retrieves export options for a vCD vApp'
                URI         = '/api/internal/vcd/vapp/snapshot/{id}/export/options'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    export_mode         = 'export_mode'
                    target_vapp_id      = 'target_vapp_id'
                    target_org_vdc_id   = 'target_org_vdc_id'
                }
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikVAppRecoverOption'                = @{
            '1.0' = @{
                Description = 'Retrieves instant recovery options for a vCD vApp'
                URI         = '/api/internal/vcd/vapp/snapshot/{id}/instant_recover/options'
                Method      = 'Get'
                Body        = ''
                Query       = @{}
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikVcdTemplateExportOption'                = @{
            '1.0' = @{
                Description = 'Retrieves export options for a vCD Template'
                URI         = '/api/v1/vcd/vapp/template/snapshot/{id}/export/options'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    catalog_id  = 'catalog_id'
                    name        = 'name'
                    org_vdc_id  = 'org_vdc_id'
                }
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikVAppSnapshot'                = @{
            '1.0' = @{
                Description = 'Retrieve information of a vCD vApp snapshot'
                URI         = '/api/internal/vcd/vapp/snapshot/{id}'
                Method      = 'Get'
                Body        = ''
                Query           = @{
                    id          = 'id'
                }
                Result      = 'data'
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikVCD'         = @{
            '1.0' = @{
                Description = 'Retrieve summary information for all vCD cluster objects'
                URI         = '/api/internal/vcd/cluster'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    name   = 'name'
                    status = 'status'
                }
                Result      = 'data'
                Filter      =  @{
                    'Hostname' = 'hostname'
                }
                Success     = '200'
                ObjectTName = 'Rubrik.VCDServer'
            }
        }
       'Get-RubrikVCenter'         = @{
            '1.0' = @{
                Description = 'Retrieves all vCenter settings of the Rubrik cluster'
                URI         = '/api/v1/vmware/vcenter'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    primary_cluster_id      = 'primary_cluster_id'
                }
                Result      = 'data'
                Filter      =  @{
                    'Name' = 'name'
                }
                Success     = '200'
                ObjectTName = 'Rubrik.vCenter'
            }
        }
        'Get-RubrikVMwareCluster'         = @{
            '1.0' = @{
                Description = 'Retrieves all VMware Cluster objects known to the Rubrik cluster'
                URI         = '/api/internal/vmware/compute_cluster'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    primary_cluster_id      = 'primary_cluster_id'
                }
                Result      = 'data'
                Filter      =  @{
                    'Name' = 'name'
                }
                Success     = '200'
                ObjectTName = 'Rubrik.VMwareCluster'
            }
            '5.1' = @{
                Description = 'Retrieves all VMware Cluster objects known to the Rubrik cluster'
                URI         = '/api/v1/vmware/compute_cluster'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    primary_cluster_id      = 'primary_cluster_id'
                }
                Result      = 'data'
                Filter      =  @{
                    'Name' = 'name'
                }
                Success     = '200'
                ObjectTName = 'Rubrik.VMwareCluster'
            }
        }
        'Get-RubrikVMwareDatacenter'         = @{
            '1.0' = @{
                Description = 'Retrieves all VMware Datacenter objects known to the Rubrik cluster'
                URI         = '/api/internal/vmware/data_center'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    primary_cluster_id      = 'primary_cluster_id'
                }
                Result      = 'data'
                Filter      =  @{
                    'Name' = 'name'
                }
                Success     = '200'
                ObjectTName = 'Rubrik.VMwareDatacenter'
            }
        }
        'Get-RubrikVMwareDatastore'         = @{
            '1.0' = @{
                Description = 'Retrieves all datastores known to the Rubrik cluster'
                URI         = '/api/internal/vmware/datastore'
                Method      = 'Get'
                Body        = ''
                Query       = @{}
                Result      = 'data'
                Filter      =  @{
                    'Name' = 'name'
                    'dataStoreType' = 'dataStoreType'
                }
                Success     = '200'
                ObjectTName = 'Rubrik.VMwareDatastore'
            }
        }
        'Get-RubrikVMwareHost'         = @{
            '1.0' = @{
                Description = 'Retrieves all ESXi hosts known to the Rubrik cluster'
                URI         = '/api/v1/vmware/host'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    primary_cluster_id      = 'primary_cluster_id'
                }
                Result      = 'data'
                Filter      =  @{
                    'Name' = 'name'
                }
                Success     = '200'
                ObjectTName = 'Rubrik.VMwareHost'
            }
        }
        'Get-RubrikVersion'            = @{
            '1.0' = @{
                Description = 'Retrieve public information about the Rubrik cluster'
                URI         = '/api/v1/cluster/{id}'
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikVM'                 = @{
            '1.0' = @{
                Description = 'Get summary of all the VMs'
                URI         = '/api/v1/vmware/vm'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    is_relic                = 'is_relic'
                    name                    = 'name'
                    effective_sla_domain_id = 'effective_sla_domain_id'
                    sla_assignment          = 'sla_assignment'
                    primary_cluster_id      = 'primary_cluster_id'
                }
                Result      = 'data'
                Filter      = @{
                    'Name' = 'name'
                    'SLA'  = 'effectiveSlaDomainName'
                }
                Success     = '200'
                ObjectTName = 'Rubrik.VMwareVM'
            }
        }
        'Get-RubrikVolumeGroup'                 = @{
            '1.0' = @{
                Description = 'Get summary of all Volume Groups'
                URI         = '/api/internal/volume_group'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    is_relic                = 'is_relic'
                    name                    = 'name'
                    hostname                = 'hostname'
                    effective_sla_domain_id = 'effective_sla_domain_id'
                    sla_assignment          = 'sla_assignment'
                    primary_cluster_id      = 'primary_cluster_id'
                }
                Result      = 'data'
                Filter      = @{
                    'Name' = 'name'
                    'SLA'  = 'effectiveSlaDomainName'
                    'hostname' = 'HostName'
                }
                Success     = '200'
                ObjectTName = 'Rubrik.VolumeGroup'
            }
        }
        'Get-RubrikVolumeGroupMount'                 = @{
            '1.0' = @{
                Description = 'Retrieve information for all Volume mounts'
                URI         = '/api/internal/volume_group/snapshot/mount'
                Method      = 'Get'
                Body        = ''
                Query           = @{
                    id          = 'source_volume_group_id'
                    source_host = 'source_host_name'
                    offset      = 'offset'
                    limit       = 'limit'
                }
                Result      = 'data'
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikVMSnapshot'                = @{
            '1.0' = @{
                Description = 'Retrieve information of a VM snapshot'
                URI         = '/api/v1/vmware/vm/snapshot/{id}'
                Method      = 'Get'
                Body        = ''
                Query           = @{
                    id          = 'id'
                }
                Result      = 'data'
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikHostVolume'               = @{
            '1.0' = @{
                Description = 'Retrieve summary information for all Volume Groups that belong to a Windows host'
                URI         = '/api/internal/host/{id}/volume'
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = 'data'
                Filter      = ''
                Success     = '200'
            }
        }
        'New-RubrikOrganization'      = @{
            '1.0' = @{
                Description = 'Adds an organization to a Rubrik cluster'
                URI         = '/api/internal/organization'
                Method      = 'Post'
                Body        = @{
                    name = "name"
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '201'
            }
        }
        'New-RubrikVCenter'      = @{
            '1.0' = @{
                Description = 'Create VMware vCenter connection'
                URI         = '/api/v1/vmware/vcenter'
                Method      = 'Post'
                Body        = @{
                    hostname = "hostname"
                    username = "username"
                    password = "password"
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'New-RubrikVMDKMount'      = @{
            '1.0' = @{
                Description = 'Create a VMDK mount request with given configuration'
                URI         = '/api/internal/vmware/vm/snapshot/{id}/mount_disks'
                Method      = 'Post'
                Body        = @{
                    targetVmId          = 'targetVmId'
                    vmdkIds             = @{}
                    vlan                    = 'vlan'
                    createNewScsiController = 'createNewScsiController'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'New-RubrikVolumeGroupMount'      = @{
            '1.0' = @{
                Description = 'Create a Volume Group mount request with given configuration'
                URI         = '/api/internal/volume_group/snapshot/{id}/mount'
                Method      = 'Post'
                Body        = @{
                    targetHostId              = 'targetHostId'
                    smbValidUsers             = 'smbValidUsers'
                    volumeConfigs             = @{
                        volumeId              = 'volumeId'
                        mountPointOnHost      = 'mountPointOnHost'
                    }
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'Remove-RubrikVolumeGroupMount'           = @{
            '1.0' = @{
                Description = 'Create a request to delete a mounted Volume Group'
                URI         = '/api/internal/volume_group/snapshot/mount/{id}'
                Method      = 'Delete'
                Body        = ''
                Query       = @{
                    force = 'force'
                }
                Result      = ''
                Filter      = ''
                Success     = '204'
            }
        }
        'New-RubrikAPIToken'      = @{
            '5.0' = @{
                Description = 'Create an API Token'
                URI         = '/api/internal/session'
                Method      = 'Post'
                Body        = ''
                Query       = ''
                Result      = 'session'
                Filter      = ''
                Success     = '200'
            }
        }
        'New-RubrikDatabaseMount'      = @{
            '1.0' = @{
                Description = 'Create a live mount request with given configuration'
                URI         = '/api/v1/mssql/db/{id}/mount'
                Method      = 'Post'
                Body        = @{
                    targetInstanceId    = 'targetInstanceId'
                    mountedDatabaseName = 'mountedDatabaseName'
                    recoveryPoint       = @{
                        timestampMs = 'timestampMs'
                    }
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'New-RubrikFileSet'      = @{
            '1.0' = @{
                Description = 'Create a fileset using an existing template along with a host or share'
                URI         = '/api/v1/fileset'
                Method      = 'Post'
                Body        = @{
                    hostId    = 'hostId'
                    shareId = 'shareId'
                    templateId = 'templateId'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'New-RubrikFileSetTemplate'      = @{
            '1.0' = @{
                Description = 'Create a new fileset template for fileset backups'
                URI         = '/api/v1/fileset_template'
                Method      = 'Post'
                Body        = @{
                    allowBackupNetworkMounts = 'allowBackupNetworkMounts'
                    allowBackupHiddenFoldersInNetworkMounts = 'allowBackupHiddenFoldersInNetworkMounts'
                    useWindowsVss = 'useWindowsVss'
                    name = 'name'
                    includes = 'includes'
                    excludes = 'excludes'
                    exceptions = 'exceptions'
                    operatingSystemType = 'operatingSystemType'
                    shareType = 'shareType'
                    preBackupScript = 'preBackupScript'
                    postBackupScript = 'postBackupScript'
                    backupScriptTimeout = 'backupScriptTimeout'
                    backupScriptErrorHandling = 'backupScriptErrorHandling'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'New-RubrikHost'               = @{
            '1.0' = @{
                Description = 'Register a host'
                URI         = '/api/v1/host'
                Method      = 'Post'
                Body        = @{
                    hostname = 'hostname'
                    hasAgent = 'hasAgent'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '201'
            }
        }
        'New-RubrikLDAP'         = @{
            '1.0' = @{
                Description = 'Creates new LDAP server connection on the Rubrik cluster'
                URI         = '/api/v1/ldap_service'
                Method      = 'Post'
                Body        = @{
                    name = "name"
                    dynamicDnsName = "dynamicDnsName"
                    bindUserName = "bindUserName"
                    bindUserPassword = "bindUserPassword"
                    baseDN = "baseDN"
                    authServers = "authServers"
                    advancedOptions = "advancedOptions"
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'New-RubrikLogBackup'               = @{
            '1.0' = @{
                Description = 'Takes on demand transaction log backup for SQL Server'
                URI         = '/api/v1/mssql/db/{id}/log_backup'
                Method      = 'Post'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'New-RubrikManagedVolume' = @{
            '1.0' = @{
                Description = 'Create a new managed volume'
                URI         = '/api/internal/managed_volume'
                Method      = 'Post'
                Body        = @{
                    name = 'name'
                    numChannels = 'numChannels'
                    subnet = 'subnet'
                    volumeSize =  'volumeSize'
                    applicationTag = 'applicationTag'
                    exportConfig = @{
                        hostPatterns = 'hostPatterns'
                    }
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '201'
            }
        }
        'New-RubrikManagedVolumeExport'        = @{
            '1.0' = @{
                Description = 'Create a Managed Volume export.'
                URI         = '/api/internal/managed_volume/snapshot/{id}/export'
                Method      = 'Post'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'New-RubrikMount'              = @{
            '1.0' = @{
                Description = 'Create a live mount request with given configuration'
                URI         = '/api/v1/vmware/vm/snapshot/{id}/mount'
                Method      = 'Post'
                Body        = @{
                    hostId               = 'hostId'
                    vmName               = 'vmName'
                    dataStoreName        = 'dataStoreName'
                    disableNetwork       = 'disableNetwork'
                    removeNetworkDevices = 'removeNetworkDevices'
                    powerOn              = 'powerOn'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'New-RubrikNASShare'              = @{
            '1.0' = @{
                Description = 'Create a new NAS share on an existing host'
                URI         = '/api/internal/host/share'
                Method      = 'Post'
                Body        = @{
                    hostId      = 'hostId'
                    shareType   = 'shareType'
                    exportPoint = 'exportPoint'
                    username    = 'username'
                    password    = 'password'
                    domain      = 'domain'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'New-RubrikReport'             = @{
            '1.0' = @{
                Description = 'Create a new report by specifying one of the report templates'
                URI         = '/api/internal/report'
                Method      = 'Post'
                Body        = @{
                    name           = 'name'
                    reportTemplate = 'reportTemplate'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '201'
            }
        }
        'New-RubrikSLA'                = @{
            '1.0' = @{
                Description = 'Create a new SLA Domain on a Rubrik cluster by specifying Domain Rules and policies'
                URI         = '/api/v1/sla_domain'
                Method      = 'Post'
                Body        = @{
                    name        = 'name'
                    frequencies = @{
                        timeUnit  = 'timeUnit'
                        frequency = 'frequency'
                        retention = 'retention'
                    }
                    allowedBackupWindows = @{
                        startTimeAttributes = @{
                            minutes   = 'minutes'
                            hour      = 'hour'
                        }
                        durationInHours  = 'durationInHours'
                    }
                    firstFullAllowedBackupWindows = @{
                        startTimeAttributes = @{
                            minutes   = 'minutes'
                            hour      = 'hour'
                            dayOfWeek = 'dayOfWeek'
                        }
                        durationInHours  = 'durationInHours'
                    }
                    localRetentionLimit = 'localRetentionLimit'
                    archivalSpecs       = @{
                        locationId        = 'locationId'
                        archivalThreshold = 'archivalThreshold'
                    }
                    replicationSpecs = @{
                        locationId     = 'locationId'
                        retentionLimit = 'retentionLimit'
                    }    
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '201'
            }
            '5.0' = @{
                Description = 'Create a new SLA Domain on a Rubrik cluster by specifying Domain Rules and policies'
                URI         = '/api/v2/sla_domain'
                Method      = 'Post'
                Body        = @{
                    name             = 'name'
                    showAdvancedUi   = 'showAdvancedUi'
                    frequencies      = @{
                        frequency = 'frequency'
                        retention = 'retention'
                    }
                    advancedUiConfig = @{
                        timeUnit      = 'timeUnit'
                        retentionType = 'retentionType'
                    }
                    allowedBackupWindows = @{
                        startTimeAttributes = @{
                            minutes   = 'minutes'
                            hour      = 'hour'
                        }
                        durationInHours  = 'durationInHours'
                    }
                    firstFullAllowedBackupWindows = @{
                        startTimeAttributes = @{
                            minutes   = 'minutes'
                            hour      = 'hour'
                            dayOfWeek = 'dayOfWeek'
                        }
                        durationInHours  = 'durationInHours'
                    }
                    localRetentionLimit = 'localRetentionLimit'
                    archivalSpecs       = @{
                        locationId        = 'locationId'
                        polarisManagedId  = 'polarisManagedId'
                        archivalThreshold = 'archivalThreshold'
                    }
                    replicationSpecs = @{
                        locationId     = 'locationId'
                        retentionLimit = 'retentionLimit'
                    }    
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '201'
            }
        }
        'New-RubrikUser'             = @{
            '1.0' = @{
                Description = 'Creates a new Rubrik user.'
                URI         = '/api/internal/user'
                Method      = 'Post'
                Body        = @{
                    username            = 'username'
                    password            = 'password'
                    firstName           = 'firstName'
                    lastName            = 'lastName'
                    emailAddress        = 'emailAddress'
                    contactNumber       = 'contactNumber'
                    mfaServerId         = 'mfaServerId'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'New-RubrikSnapshot'           = @{
            '1.0' = @{
                Description = 'Create an on-demand snapshot for the given object ID'
                URI         = @{
                    Fileset = '/api/v1/fileset/{id}/snapshot'
                    MSSQL   = '/api/v1/mssql/db/{id}/snapshot'
                    VMware  = '/api/v1/vmware/vm/{id}/snapshot'
                    VolumeGroup = '/api/internal/volume_group/{id}/snapshot'
                    Oracle = '/api/internal/oracle/db/{id}/snapshot'
                    VcdVapp = '/api/internal/vcd/vapp/{id}/snapshot'
                    Nutanix = '/api/internal/nutanix/vm/{id}/snapshot'
                    HyperV = '/api/internal/hyperv/vm/{id}/snapshot'
                }
                Method      = 'Post'
                Body        = @{
                    forceFullSnapshot = 'forceFullSnapshot'
                    slaId             = 'slaId'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'Protect-RubrikDatabase'       = @{
            '1.0' = @{
                Description = 'Update a Microsoft SQL database with the specified SLA Domain.'
                URI         = '/api/v1/mssql/db/{id}'
                Method      = 'Patch'
                Body        = @{
                    logBackupFrequencyInSeconds = 'logBackupFrequencyInSeconds'
                    logRetentionHours           = 'logRetentionHours'
                    copyOnly                    = 'copyOnly'
                    maxDataStreams              = 'maxDataStreams'
                    configuredSlaDomainId       = 'configuredSlaDomainId'
                }
                Query       = ''
                Result      = 'data'
                Filter      = ''
                Success     = '200'
            }
        }
        'Protect-RubrikFileset'        = @{
            '1.0' = @{
                Description = 'Update a Fileset with the specified SLA Domain.'
                URI         = '/api/v1/fileset/{id}'
                Method      = 'Patch'
                Body        = @{
                    configuredSlaDomainId = 'configuredSlaDomainId'
                }
                Query       = ''
                Result      = 'data'
                Filter      = ''
                Success     = '200'
            }
        }
        'Protect-RubrikHyperVVM'             = @{
            '1.0' = @{
                Description = 'Update a VM with the specified SLA Domain.'
                URI         = '/api/internal/hyperv/vm/{id}'
                Method      = 'Patch'
                Body        = @{
                    configuredSlaDomainId = 'configuredSlaDomainId'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Protect-RubrikNutanixVM'             = @{
            '1.0' = @{
                Description = 'Update a VM with the specified SLA Domain.'
                URI         = '/api/internal/nutanix/vm/{id}'
                Method      = 'Patch'
                Body        = @{
                    configuredSlaDomainId = 'configuredSlaDomainId'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Protect-RubrikTag'            = @{
            '1.0' = @{
                Description = 'Assign managed entities to the specified SLA Domain. The assignment event runs synchronously.'
                URI         = '/api/internal/sla_domain/{id}/assign'
                Method      = 'Post'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '204'
            }
        }
        'Protect-RubrikVApp'             = @{
            '1.0' = @{
                Description = 'Update a vCD vApp with the specified SLA Domain.'
                URI         = '/api/internal/vcd/vapp/{id}'
                Method      = 'Patch'
                Body        = @{
                    configuredSlaDomainId = 'configuredSlaDomainId'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Protect-RubrikVM'             = @{
            '1.0' = @{
                Description = 'Update a VM with the specified SLA Domain.'
                URI         = '/api/v1/vmware/vm/{id}'
                Method      = 'Patch'
                Body        = @{
                    configuredSlaDomainId = 'configuredSlaDomainId'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
                ObjectTName = 'Rubrik.VMwareVM'
            }
        }
        'Protect-RubrikVolumeGroup'             = @{
            '1.0' = @{
                Description = 'Update a Volume Group with the specified SLA Domain.'
                URI         = '/api/internal/volume_group/{id}'
                Method      = 'Patch'
                Body        = @{
                    configuredSlaDomainId = 'configuredSlaDomainId'
                    volumeIdsIncludedInSnapshots = @{}
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
                ObjectTName = 'Rubrik.VolumeGroup'
            }
        }
        'Update-RubrikHost'             = @{
            '1.0' = @{
                Description = 'Refresh the properties of a host object when changes on the host are not seen in the Rubrik web UI.'
                URI         = '/api/v1/host/{id}/refresh'
                Method      = 'Post'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Register-RubrikBackupService'                  = @{
            '1.0' = @{
                Description = 'Register the Rubrik Backup Service.'
                URI         = @{
                    VMware  = '/api/v1/vmware/vm/{id}/register_agent'
                    HyperV  = '/api/internal/hyperv/vm/{id}/register_agent'
                    Nutanix = '/api/internal/nutanix/vm/{id}/register_agent'
                }
                Method      = 'Post'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '204'
            } 
        }
        'Remove-RubrikAPIToken'   = @{
            '5.0' = @{
                Description = 'Deletes session tokens'
                URI         = '/api/internal/session/bulk_delete'
                Method      = 'Post'
                Body        = @{
                    tokenIds = 'tokenIds'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '204'
            }
        }
        'Remove-RubrikDatabaseMount'   = @{
            '1.0' = @{
                Description = 'Create a request to delete a database live mount'
                URI         = '/api/v1/mssql/db/mount/{id}'
                Method      = 'Delete'
                Body        = ''
                Query       = @{
                    force = 'force'
                }
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'Remove-RubrikFileset'         = @{
            '1.0' = @{
                Description = 'Delete a fileset by specifying the fileset ID'
                URI         = '/api/v1/fileset/{id}'
                Method      = 'Delete'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '204'
            }
        }
        'Remove-RubrikHost'            = @{
            '1.0' = @{
                Description = 'Delete host by specifying the host ID'
                URI         = '/api/v1/host/{id}'
                Method      = 'Delete'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '204'
            }
        }
        'Remove-RubrikManagedVolume'            = @{
            '1.0' = @{
                Description = 'Delete a managed volume'
                URI         = '/api/internal/managed_volume/{id}'
                Method      = 'Delete'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '204'
            }
        }
        'Remove-RubrikManagedVolumeExport'            = @{
            '1.0' = @{
                Description = 'Delete a managed volume'
                URI         = '/api/internal/managed_volume/snapshot/export/{id}'
                Method      = 'Delete'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '204'
            }
        }
        'Remove-RubrikMount'           = @{
            '1.0' = @{
                Description = 'Create a request to delete a live mount'
                URI         = '/api/v1/vmware/vm/snapshot/mount/{id}'
                Method      = 'Delete'
                Body        = ''
                Query       = @{
                    force = 'force'
                }
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'Remove-RubrikNASShare'           = @{
            '1.0' = @{
                Description = 'Create a request to delete a NAS share'
                URI         = '/api/internal/host/share/{id}'
                Method      = 'Delete'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'Remove-RubrikProxySetting'              = @{
            '1.0' = @{
                Description = 'Remove Rubrik Node Proxy Configuration'
                URI         = '/api/internal/node_management/proxy_config'
                Method      = 'Delete'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '204'
            }
        }
        'Remove-RubrikOrganization'           = @{
            '1.0' = @{
                Description = 'Remove an organization from a Rubrik cluster'
                URI         = '/api/internal/organization/{id}'
                Method      = 'Delete'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '204'
            }
        }
        'Remove-RubrikOrgAuthorization'         = @{
            '1.0' = @{
                Description = 'Revokes an organization authorization for principal(s)'
                URI         = '/api/internal/authorization/role/organization'
                Method      = 'Delete'
                Body        = @{
                    principals = [System.Collections.ArrayList]@()
                    organizationId = 'organization_id'
                    privileges = @{
                        manageCluster = [System.Collections.ArrayList]@()
                        manageResource = [System.Collections.ArrayList]@()
                        useSla = [System.Collections.ArrayList]@()
                        manageSla = [System.Collections.ArrayList]@()
                    }
                }
                Query       = ''
                Result      = 'data'
                Filter      = ''
                Success     = '200'
            }
        }
        'Remove-RubrikReport'          = @{
            '1.0' = @{
                Description = 'Delete a specific report specified by reportId'
                URI         = '/api/internal/report/{id}'
                Method      = 'Delete'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '204'
            }
        }
        'Remove-RubrikSLA'             = @{
            '1.0' = @{
                Description = 'Delete an SLA Domain from a Rubrik cluster'
                URI         = '/api/v1/sla_domain/{id}'
                Method      = 'Delete'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '204'
            }
            '5.0' = @{
                Description = 'Delete an SLA Domain from a Rubrik cluster'
                URI         = '/api/v2/sla_domain/{id}'
                Method      = 'Delete'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '204'
            }
        }
        'Remove-RubrikVMSnapshot'        = @{
            '1.0' = @{
                Description = 'Removes an expired VM snapshot available for garbage collection'
                URI         = '/api/v1/vmware/vm/snapshot/{id}'
                Method      = 'Delete'
                Body        = ''
                Query       = @{
                    location = 'location'
                }
                Result      = ''
                Success     = '204'
            }
        }
        'Remove-RubrikUnmanagedObject' = @{
            '1.0' = @{
                Description = 'Bulk delete all unmanaged snapshots for the objects specified by objectId/objectType pairings.'
                URI         = '/api/internal/unmanaged_object/snapshot/bulk_delete'
                Method      = 'Post'
                Body        = @{
                    objectDefinitions = @(
                        @{
                            objectId   = 'objectId'
                            objectType = 'objectType'
                        }
                    )
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '204'
            }
        }
        'Remove-RubrikVCenter'         = @{
            '1.0' = @{
                Description = 'Removes a vCenter connection'
                URI         = '/api/v1/vmware/vcenter/{id}'
                Method      = 'Delete'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Restore-RubrikDatabase'       = @{
            '1.0' = @{
                Description = 'Export MSSQL Database from Rubrik to Destination Instance.'
                URI         = '/api/v1/mssql/db/{id}/restore'
                Method      = 'Post'
                Body        = @{
                    recoveryPoint      = @{
                        lsnPoint = @{lsn='lsn'}
                        timestampMs = 'timestampMs'
                    }
                    finishRecovery = 'finishRecovery'
                    maxDataStreams = 'maxDataStreams'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'Restore-RubrikVApp'       = @{
            '1.0' = @{
                Description = 'Restores a given snapshot for a vCD vApp'
                URI         = '/api/internal/vcd/vapp/snapshot/{id}/instant_recover'
                Method      = 'Post'
                Body        = @{
                    vmsToRestore = @{
                        name   		= 'name'
                        vcdMoid     = 'vcdMoid'
                        networkConnections = @{
                            nicIndex		= 'nicIndex'
                            addressingMode	= 'addressingMode'
                            ipAddress		= 'ipAddress'
                            isConnected		= 'isConnected'
                            vappNetworkName	= 'vappNetworkName'
                        }
                    }
                    shouldPowerOnVmsAfterRecovery = 'shouldPowerOnVmsAfterRecovery'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'Set-RubrikAvailabilityGroup'           = @{
            '1.0' = @{
                Description = 'Update a Microsoft SQL availability group.'
                URI         = '/api/internal/mssql/availability_group/{id}'
                Method      = 'Patch'
                Body        = @{
                    logBackupFrequencyInSeconds = 'logBackupFrequencyInSeconds'
                    logRetentionHours           = 'logRetentionHours'
                    copyOnly                    = 'copyOnly'
                    configuredSlaDomainId       = 'configuredSlaDomainId'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Set-RubrikBlackout'           = @{
            '1.0' = @{
                Description = 'Whether to start or stop the global blackout window.'
                URI         = '/api/internal/blackout_window'
                Method      = 'Patch'
                Body        = @{
                    isGlobalBlackoutActive = 'isGlobalBlackoutActive'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Set-RubrikDatabase'           = @{
            '1.0' = @{
                Description = 'Updates Rubrik database settings.'
                URI         = '/api/v1/mssql/db/{id}'
                Method      = 'Patch'
                Body        = @{
                    logBackupFrequencyInSeconds = "logBackupFrequencyInSeconds"
                    logRetentionHours           = "logRetentionHours"
                    copyOnly                    = "copyOnly"
                    maxDataStreams              = "maxDataStreams"
                    configuredSlaDomainId       = "configuredSlaDomainId"
                    preBackupScript             = @{
                        scriptPath              = "scriptPath"
                        timeoutMs               = "timeoutMs"
                        scriptErrorAction       = "scriptErrorAction"
                    }
                    postBackupScript            = @{
                        scriptPath              = "scriptPath"
                        timeoutMs               = "timeoutMs"
                        scriptErrorAction       = "scriptErrorAction"
                    }
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Set-RubrikHyperVVM'                 = @{
            '1.0' = @{
                Description = 'Update VM with specified properties'
                URI         = '/api/internal/hyperv/vm/{id}'
                Method      = 'Patch'
                Body        = @{
                    cloudInstantiationSpec = @{
                        imageRetentionInSeconds = 'imageRetentionInSeconds'
                    }
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Set-RubrikLDAP'         = @{
            '1.0' = @{
                Description = 'Updates all settings of the Rubrik cluster'
                URI         = '/api/v1/ldap_service'
                Method      = 'Patch'
                Body        = @{
                    name = "name"
                    dynamicDnsName = "dynamicDnsName"
                    bindUserName = "bindUserName"
                    bindUserPassword = "bindUserPassword"
                    baseDN = "baseDN"
                    authServers = "authServers"
                    advancedOptions = "advancedOptions"
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Set-RubrikManagedVolume' = @{
            '1.0' = @{
                Description = 'Update a managed volume'
                URI         = '/api/internal/managed_volume'
                Method      = 'Patch'
                Body        = @{
                    name = 'name'
                    volumeSize =  'volumeSize'
                    configuredSlaDomainId = 'configuredSlaDomainId'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '201'
            }
        }
        'Set-RubrikMount'              = @{
            '1.0' = @{
                Description = 'Power given live-mounted vm on/off'
                URI         = '/api/v1/vmware/vm/snapshot/mount/{id}'
                Method      = 'Patch'
                Body        = @{
                    powerStatus = 'powerStatus'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Set-RubrikNASShare'              = @{
            '1.0' = @{
                Description = 'Power given live-mounted vm on/off'
                URI         = '/api/internal/host/share/{id}'
                Method      = 'Patch'
                Body        = @{
                    exportPoint = 'exportPoint'
                    username    = 'username'
                    password    = 'password'
                    domain      = 'domain'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Set-RubrikProxySetting'              = @{
            '1.0' = @{
                Description = 'Remove Rubrik Node Proxy Configuration'
                URI         = '/api/internal/node_management/proxy_config'
                Method      = 'Patch'
                Body        = @{
                    host     = 'host'
                    port     = 'port'
                    protocol = 'protocol'
                    username = 'username'
                    password = 'password'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
                ObjectTName = 'Rubrik.ProxySetting'
            }
        }
        'Set-RubrikNutanixVM'                 = @{
            '1.0' = @{
                Description = 'Update VM with specified properties'
                URI         = '/api/internal/nutanix/vm/{id}'
                Method      = 'Patch'
                Body        = @{
                    snapshotConsistencyMandate = 'snapshotConsistencyMandate'
                    isPaused                 = 'isPaused'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Set-RubrikOrgAuthorization'         = @{
            '1.0' = @{
                Description = 'Grants an organization authorization for principal(s)'
                URI         = '/api/internal/authorization/role/organization'
                Method      = 'Post'
                Body        = @{
                    principals = [System.Collections.ArrayList]@()
                    organizationId = 'organization_id'
                    privileges = @{
                        manageCluster = [System.Collections.ArrayList]@()
                        manageResource = [System.Collections.ArrayList]@()
                        useSla = [System.Collections.ArrayList]@()
                        manageSla = [System.Collections.ArrayList]@()
                    }
                }
                Query       = ''
                Result      = 'data'
                Filter      = ''
                Success     = '200'
            }
        }
        'Set-RubrikReport'             = @{
            '1.0' = @{
                Description = 'Update a specific report. The report''s name, chart parameters, filters and table can be updated. If successful, this will automatically trigger an async job to refresh the report content.'
                URI         = '/api/internal/report/{id}'
                Method      = 'Patch'
                Body        = @{
                    name    = 'name'
                    filters = @{
                        slaDomain        = 'slaDomain'
                        objects          = 'objects'
                        objectType       = 'objectType'
                        objectLocation   = 'objectLocation'
                        clusterLocation  = 'clusterLocation'
                        taskType         = 'taskType'
                        complianceStatus = 'complianceStatus'
                        dateConfig       = @{
                            beforeDate = 'beforeDate'
                            afterDate  = 'afterDate'
                            period     = 'period'
                        }
                    }
                    chart0  = @{
                        id        = 'id'
                        name      = 'name'
                        chartType = 'chartType'
                        attribute = 'attribute'
                        measure   = 'measure'
                    }
                    chart1  = @{
                        id        = 'id'
                        name      = 'name'
                        chartType = 'chartType'
                        attribute = 'attribute'
                        measure   = 'measure'
                    }
                    table   = @{
                        columns = 'columns'
                    }
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Set-RubrikSetting'         = @{
            '1.0' = @{
                Description = 'Updates all settings of the Rubrik cluster'
                URI         = '/api/v1/cluster/{id}'
                Method      = 'Patch'
                Body        = @{
                    name = "name"
                    timezone = "timezone"
                    geolocation = "geolocation"
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Set-RubrikSLA'             = @{
            '1.0' = @{
                Description = 'Update an existing SLA Domain on a Rubrik cluster by specifying Domain Rules and policies'
                URI         = '/api/v1/sla_domain'
                Method      = 'Patch'
                Body        = @{
                    name                 = 'name'
                    frequencies          = @{
                        timeUnit  = 'timeUnit'
                        frequency = 'frequency'
                        retention = 'retention'
                    }
                    allowedBackupWindows = @{
                        startTimeAttributes = @{
                            minutes   = 'minutes'
                            hour      = 'hour'
                        }
                        durationInHours  = 'durationInHours'
                    }
                    firstFullAllowedBackupWindows = @{
                        startTimeAttributes = @{
                            minutes   = 'minutes'
                            hour      = 'hour'
                            dayOfWeek = 'dayOfWeek'
                        }
                        durationInHours  = 'durationInHours'
                    }
                    localRetentionLimit = 'localRetentionLimit'
                    archivalSpecs       = @{
                        locationId        = 'locationId'
                        archivalThreshold = 'archivalThreshold'
                    }
                    replicationSpecs = @{
                        locationId     = 'locationId'
                        retentionLimit = 'retentionLimit'
                    }
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
            '5.0' = @{
                Description = 'Update an existing SLA Domain on a Rubrik cluster by specifying Domain Rules and policies'
                URI         = '/api/v2/sla_domain'
                Method      = 'Patch'
                Body        = @{
                    name             = 'name'
                    showAdvancedUi   = 'showAdvancedUi'
                    frequencies      = @{
                        frequency = 'frequency'
                        retention = 'retention'
                    }
                    advancedUiConfig = @{
                        timeUnit      = 'timeUnit'
                        retentionType = 'retentionType'
                    }
                    allowedBackupWindows = @{
                        startTimeAttributes = @{
                            minutes   = 'minutes'
                            hour      = 'hour'
                        }
                        durationInHours  = 'durationInHours'
                    }
                    firstFullAllowedBackupWindows = @{
                        startTimeAttributes = @{
                            minutes   = 'minutes'
                            hour      = 'hour'
                            dayOfWeek = 'dayOfWeek'
                        }
                        durationInHours  = 'durationInHours'
                    }
                    localRetentionLimit = 'localRetentionLimit'
                    archivalSpecs       = @{
                        locationId        = 'locationId'
                        polarisManagedId  = 'polarisManagedId'
                        archivalThreshold = 'archivalThreshold'
                    }
                    replicationSpecs = @{
                        locationId     = 'locationId'
                        retentionLimit = 'retentionLimit'
                    }
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Set-RubrikSQLInstance'        = @{
            '1.0' = @{
                Description = 'Updates Rubrik database settings.'
                URI         = '/api/v1/mssql/instance/{id}'
                Method      = 'Patch'
                Body        = @{
                    logBackupFrequencyInSeconds = "logBackupFrequencyInSeconds"
                    logRetentionHours           = "logRetentionHours"
                    copyOnly                    = "copyOnly"
                    maxDataStreams              = "maxDataStreams"
                    configuredSlaDomainId       = "configuredSlaDomainId"
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Set-RubrikSupportTunnel'      = @{
            '1.0' = @{
                Description = 'To be used by Admin to open or close a SSH tunnel for support.'
                URI         = '/api/internal/node/me/support_tunnel'
                Method      = 'Patch'
                Body        = @{
                    isTunnelEnabled            = "isTunnelEnabled"
                    inactivityTimeoutInSeconds = "inactivityTimeoutInSeconds"
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Set-RubrikVCD'         = @{
            '1.0' = @{
                Description = 'Updates settings of a vCD connection'
                URI         = '/api/internal/vcd/cluster/{id}'
                Method      = 'Patch'
                Body        = @{
                    hostname              = "hostname"
                    username              = "username"
                    password              = "password"
                    configuredSlaDomainId = "configuredSlaDomainId"
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Set-RubrikUser'             = @{
            '1.0' = @{
                Description = 'Updates a Rubrik user.'
                URI         = '/api/internal/user/{id}'
                Method      = 'Patch'
                Body        = @{
                    password            = 'password'
                    firstName           = 'firstName'
                    lastName            = 'lastName'
                    emailAddress        = 'emailAddress'
                    contactNumber       = 'contactNumber'
                    mfaServerId         = 'mfaServerId'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Set-RubrikUserRole'             = @{
            '1.0' = @{
                Description = 'Updates a Rubrik user role and authorizations.'
                URI         = '/api/internal/authorization/role'
                Method      = 'POST'
                Body        = @{
                    principals      = 'principals'
                    privileges      = @{ }
                }
                Query       = ''
                Result      = 'Data'
                Filter      = ''
                Success     = '200'
            }
        }
        'Set-RubrikVM'                 = @{
            '1.0' = @{
                Description = 'Update VM with specified properties'
                URI         = '/api/v1/vmware/vm/{id}'
                Method      = 'Patch'
                Body        = @{
                    snapshotConsistencyMandate = 'snapshotConsistencyMandate'
                    maxNestedVsphereSnapshots  = 'maxNestedVsphereSnapshots'
                    isVmPaused                 = 'isVmPaused'
                    preBackupScript            = @{
                        scriptPath      = 'scriptPath'
                        timeoutMs       = 'timeoutMs'
                        failureHandling = 'failureHandling'
                    }
                    postSnapScript             = @{
                        scriptPath      = 'scriptPath'
                        timeoutMs       = 'timeoutMs'
                        failureHandling = 'failureHandling'
                    }
                    postBackupScript           = @{
                        scriptPath      = 'scriptPath'
                        timeoutMs       = 'timeoutMs'
                        failureHandling = 'failureHandling'
                    }
                    isArrayIntegrationEnabled  = 'isArrayIntegrationEnabled'
                    cloudInstantiationSpec = @{
                        imageRetentionInSeconds = 'imageRetentionInSeconds'
                    }
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
                ObjectTName = 'Rubrik.VMwareVM'
            }
        }
        'Set-RubrikVCenter'         = @{
            '1.0' = @{
                Description = 'Updates settings of a vCenter connection'
                URI         = '/api/v1/vmware/vcenter/{id}'
                Method      = 'Put'
                Body        = @{
                    hostname = "hostname"
                    username = "username"
                    password = "password"
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Set-RubrikVolumeFilterDriver'      = @{
            '1.0' = @{
                Description = 'Installs or Uninstalls the Rubrik Volume Filter Driver'
                URI         = '/api/internal/host/bulk/volume_filter_driver'
                Method      = 'Post'
                Body        = @{
                    hostIds = 'hostIds'
                    install = 'install'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
            '5.0' = @{
                Description = 'Installs or Uninstalls the Rubrik Volume Filter Driver'
                URI         = '/api/internal/host/bulk/volume_filter_driver'
                Method      = 'Post'
                Body        = @{
                    hostIds = 'hostIds'
                    install = 'install'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Start-RubrikManagedVolumeSnapshot' = @{
            '1.0' = @{
                Description = 'Open a Rubrik Managed Volume for read/write'
                URI         = '/api/internal/managed_volume/{id}/begin_snapshot'
                Method      = 'Post'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '201'
            }
        }
        'Stop-RubrikManagedVolumeSnapshot' = @{
            '1.0' = @{
                Description = 'Close a Rubrik Managed Volume for read/write'
                URI         = '/api/internal/managed_volume/{id}/end_snapshot'
                Method      = 'Post'
                Body        = @{
                    retentionConfig  = @{
                        slaID = 'slaID'
                    }
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '201'
            }
        }
        'Get-RubrikLogShipping' = @{
            '1.0' = @{
                Description = 'Retrieves all log shipping configuration objects. Results can be filtered and sorted'
                URI         = '/api/v1/mssql/db/log_shipping'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    primary_database_id     = 'primary_database_id'
                    primary_database_name   = 'primary_database_name'
                    secondary_database_name = 'secondary_database_name'
                    location                = 'location'
                    status                  = 'status'
                    limit                   = 'limit'
                    offset                  = 'offset'
                    sort_by                 = 'sort_by'
                    sort_order              = 'sort_order'
                }
                Result      = 'data'
                Filter      = ''
                Success     = '200'
                ObjectTName = 'Rubrik.LogShipping'
            }
        }
        'New-RubrikLogShipping' = @{
                '1.0' = @{
                    Description = 'Create a log shipping configuration'
                    URI         = '/api/v1/mssql/db/{id}/log_shipping'
                    Method      = 'Post'
                    Body        = @{
                        state                             = 'state'
                        shouldDisconnectStandbyUsers      = 'shouldDisconnectStandbyUsers'
                        maxDataStreams                    = 'maxDataStreams'
                        targetDatabaseName                = 'targetDatabaseName'
                        targetDataFilePath                = 'targetDataFilePath'
                        targetFilePaths = @{
                            logicalName       = 'logicalName'
                            exportPath        = 'exportPath'
                            newLogicalName    = 'newLogicalName'
                            newFilename       = 'newFilename'
                        }
                        targetInstanceId                  = 'targetInstanceId'
                        targetLogFilePath                 = 'targetLogFilePath'
                    }
                    Result      = ''
                    Filter      = ''
                    Success     = '202'
                }
        }
        'Remove-RubrikLogShipping' = @{
            '1.0' = @{
                Description = 'Delete a specified log shipping configuration'
                URI         = '/api/v1/mssql/db/log_shipping/{id}'
                Method      = 'Delete'
                Body        = ''
                Query       = @{
                    delete_secondary_database = 'delete_secondary_database'
                }
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'Remove-RubrikUser' = @{
            '1.0' = @{
                Description = 'Deletes a specified user from the Rubrik cluster'
                URI         = '/api/internal/user/{id}'
                Method      = 'Delete'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Set-RubrikLogShipping' = @{
            '1.0' = @{
                Description = 'Update a specified log shipping configuration'
                URI         = '/api/v1/mssql/db/log_shipping/{id}'
                Method      = 'Patch'
                Body        = @{
                    state = 'state'
                    shouldDisconnectStandbyUsers = 'shouldDisconnectStandbyUsers'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'Reset-RubrikLogShipping' = @{
            '1.0' = @{
                Description = 'Reseed a secondary database'
                URI         = '/api/v1/mssql/db/log_shipping/{id}/reseed'
                Method      = 'Post'
                Body        = @{
                    state = 'state'
                    shouldDisconnectStandbyUsers = 'shouldDisconnectStandbyUsers'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'Update-RubrikVCenter'         = @{
            '1.0' = @{
                Description = 'Refresh the metadata for the specified vCenter Server'
                URI         = '/api/v1/vmware/vcenter/{id}/refresh'
                Method      = 'Post'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'Update-RubrikVCD'         = @{
            '1.0' = @{
                Description = 'Refresh the metadata for the specified vCD Server'
                URI         = '/api/internal/vcd/cluster/{id}/refresh'
                Method      = 'Post'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'Update-RubrikVMwareVM'         = @{
            '1.0' = @{
                Description = 'Refresh the metadata for the specified VMware VM'
                URI         = '/api/internal/vmware/vcenter/{id}/refresh_vm'
                Method      = 'Post'
                Body        = @{
                    vmMoid = 'vmMoid'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '204'
            }
        }
        'Get-RubrikBootStrap'         = @{
            '1.0' = @{
                Description = 'Status of the bootstrap request'
                URI         = '/api/internal/cluster/{id}/bootstrap'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    request_id    = 'request_id'
                }
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'New-RubrikBootStrap'      = @{
            '1.0' = @{
                Description = 'New Bootstrap Request'
                URI         = '/api/internal/cluster/{id}/bootstrap'
                Method      = 'Post'
                Body        = @{
                    name   = 'name'
                    dnsNameservers = 'dnsNameservers'
                    dnsSearchDomains = 'dnsSearchDomains'
                    ntpServerConfigs      = @{
                        server = 'ntpServerConfigs'
                    }
                    enableSoftwareEncryptionAtRest = 'enableSoftwareEncryptionAtRest'
                    adminUserInfo      = @{
                        emailAddress = 'emailAddress'
                        id = 'id'
                        password = 'password'
                    }
                    #change to a foreach loop and accept object
                    #needs to be depth 3 to work
                    nodeConfigs      = @{
                        node1      = @{
                            managementIpConfig      = @{
                            address = 'address'
                            gateway = 'management_gateway'
                            netmask = 'management_netmask'
                            }
                        }
                    }
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
    } # End of API

    # Determine which version of RCDM is running
    # Note: Disregard for Software and API version; these do not require authentication
    if ($endpoint -eq 'Get-RubrikSoftwareVersion' -or $endpoint -eq 'Get-RubrikAPIVersion') {$key = '1.0'}

    else {
        # Take the first three values (major.minor) and convert to a float
        # If there is no version yet, we're probably connecting to the cluster for the first time (Connect-Rubrik)
        if (!$global:RubrikConnection.version) {
            $ver = [float](Get-RubrikSoftwareVersion -Server $Server).substring(0, 3)
        }
        # If there is a stored version, we'll use that to avoid more traffic to the cluster
        else {
            $ver = [float]$global:RubrikConnection.version.substring(0, 3)
        }
        # Parse through the keys to find a match (less or equal), pick the last one in the case of an array of values
        # Example: We're using RCDM 4.0 and an endpoint has details for 1.0 and 4.0. Both are less/equal to 4.0. We'll want the last value (4.0).
        # Example: We're using RCDM 4.0 and an endpoint has details for 1.0 and 4.1. 4.1 is not less/equal to 4.0, as such, we'll want the only matching value (1.0).
        $key = $api.$endpoint.Keys | Sort-Object | Where-Object {[float]$_ -le $ver} | Select-Object -Last 1
    }

    Write-Verbose -Message "Selected $key API Data for $endpoint"
    # Add the function name to resolve issue #480
    $api.$endpoint.$key.Add('Function',$endpoint) 
    return $api.$endpoint.$key
} # End of function