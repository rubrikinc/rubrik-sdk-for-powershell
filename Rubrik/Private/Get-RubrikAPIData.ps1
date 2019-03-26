<#
    Helper function to retrieve API data from Rubrik
#>
function Get-RubrikAPIData($endpoint) {
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
                }
                Result      = 'data'
                Filter      = @{
                    'Name'     = 'name'
                    'SLA'      = 'effectiveSlaDomainName'
                    'Hostname' = 'rootProperties.rootName'
                    'Instance' = 'instanceName'
                }
                Success     = '200'
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
                Result      = 'data'
                Filter      = ''
                Success     = '200'
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
            }
        }
        'Get-RubrikFilesetTemplate'    = @{
            '1.0' = @{
                Description = 'Retrieve summary information for all fileset templates, including: ID and name of the fileset template, fileset template creation timestamp, array of the included filepaths, array of the excluded filepaths.'
                Function    = 'Get-RubrikFilesetTemplate'
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
                Filter      = ''
                Success     = '200'
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
                Filter      = ''
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
                    name                    = 'name'
                }
                Result      = 'data'
                Filter      = ''
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
            }
        }
        'Get-RubrikSnapshot'           = @{
            '1.0' = @{
                Description = 'Retrieve information for all snapshots '
                URI         = @{
                    Fileset = '/api/v1/fileset/{id}/snapshot'
                    MSSQL   = '/api/v1/mssql/db/{id}/snapshot'
                    VMware  = '/api/v1/vmware/vm/{id}/snapshot'
                    HyperV  = '/api/internal/hyperv/vm/{id}/snapshot'
                    ManagedVolume = '/api/internal/managed_volume/{id}/snapshot'
                    Nutanix = '/api/internal/nutanix/vm/{id}/snapshot'
                    VolumeGroup = '/api/internal/volume_group/{id}/snapshot'
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
                }
                Result      = 'data'
                Filter      = @{
                    'Name'     = 'name'
                    'SLA'      = 'configuredSlaDomainName'
                    'Hostname' = 'rootProperties.rootName'
                }
                Success     = '200'
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
                Filter      = ''
                Success     = '200'
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
                }
                Success     = '200'
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
                    name        = 'name'
                    frequencies = @{
                        timeUnit  = 'timeUnit'
                        frequency = 'frequency'
                        retention = 'retention'
                    }
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '201'
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
                Success     = '200'
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
                    dynamicDNSName = "dynamicDNSName"
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
    return $api.$endpoint.$key
} # End of function
