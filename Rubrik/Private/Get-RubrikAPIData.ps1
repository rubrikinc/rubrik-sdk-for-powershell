<#
    Helper function to retrieve API data from Rubrik
#>
function Get-RubrikAPIData($endpoint)
{
  $api = @{
    Example                   = @{
      v1 = @{
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
    'Connect-Rubrik'          = @{
      'v1.1' = @{
        Description = 'Create a new login session'
        URI         = '/api/v1/session'
        Method      = 'Post'
        Body        = ''
        Query       = ''
        Result      = ''
        Filter      = ''
        Success     = '200'
      }
      'v1.0' = @{
        Description = 'Create a new login session'
        URI         = '/api/v1/login'
        Method      = 'Post'
        Body        = @('username', 'password')
        Query       = ''
        Result      = ''
        Filter      = ''
        Success     = '200'
      }
    }
    'Disconnect-Rubrik'                   = @{
      v1 = @{
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
    'Export-RubrikDatabase'      = @{
      v1 = @{
        Description = 'Export MSSQL Database from Rubrik to Destination Instance.'
        URI         = '/api/v1/mssql/db/{id}/export'
        Method      = 'Post'
        Body        = @{
          targetInstanceId   = 'targetInstanceId'
          targetDatabaseName = 'targetDatabaseName'
          recoveryPoint      = @{
                timestampMs  = 'timestampMs'
             }
          finishRecovery     = 'finishRecovery'
          maxDataStreams     = 'maxDataStreams'
        }
        Query       = ''
        Result      = ''
        Filter      = ''
        Success     = '202'
      }
    }
    'Export-RubrikReport'       = @{
      v1 = @{
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
    }
    'Get-RubrikDatabase'      = @{
      v1 = @{
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
          'Name'   = 'name'
          'SLA'    = 'effectiveSlaDomainName'
          'Hostname' = 'rootProperties.rootName'
          'Instance' = 'instanceName'
        }
        Success     = '200'
      }
    }
    'Get-RubrikFileset'       = @{
      v1 = @{
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
        }
        Result      = 'data'
        Filter      = @{
          'SLA' = 'effectiveSlaDomainName'
        }
        Success     = '200'
      }
    }
    'Get-RubrikFilesetTemplate' = @{
      v1 = @{
        Description = 'Retrieve summary information for all fileset templates, including: ID and name of the fileset template, fileset template creation timestamp, array of the included filepaths, array of the excluded filepaths.'
        Function    = 'Get-RubrikFilesetTemplate'
        URI         = '/api/v1/fileset_template'
        Method      = 'Get'
        Body        = ''
        Query       = @{
          primary_cluster_id    = 'primary_cluster_id'
          operating_system_type = 'operating_system_type'
          name                  = 'name'
        }
        Result      = 'data'
        Filter      = ''
        Success     = '200'
      }
    }
    'Get-RubrikMount'         = @{
      v1 = @{
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
    'Get-RubrikReport'       = @{
      v1 = @{
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
    }
    'Get-RubrikRequest'       = @{
      v1 = @{
        Description = 'Get details about a vmware vm related async request'
        URI         = '/api/v1/vmware/vm/request/{id}'
        Method      = 'Get'
        Body        = ''
        Query       = ''
        Result      = ''
        Filter      = ''
        Success     = '200'
      }
    }
    'Get-RubrikSLA'           = @{
      v1 = @{
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
    }
    'Get-RubrikSnapshot'      = @{
      v1 = @{
        Description = 'Retrieve information for all snapshots for a VM'
        URI         = @{
          Fileset = '/api/v1/fileset/{id}/snapshot'
          MSSQL   = '/api/v1/mssql/db/{id}/snapshot'
          VMware  = '/api/v1/vmware/vm/{id}/snapshot'
        }
        Method      = 'Get'
        Body        = ''
        Query       = ''
        Result      = 'data'
        Filter      = @{
          'CloudState'     = 'cloudState'
          'OnDemandSnapshot' = 'isOnDemandSnapshot'
        }
        Success     = '200'
      }
    }
    'Get-RubrikUnmanagedObject' = @{
      v1 = @{
        Description = 'Get summary of all the objects with unmanaged snapshots'
        URI         = '/api/internal/unmanaged_object'
        Method      = 'Get'
        Body        = ''
        Query       = @{
          search_value = 'search_value'
          unmanaged_status = 'unmanaged_status'
          object_type = 'object_type'
        }
        Result      = 'data'
        Filter      = ''
        Success     = '200'
      }
    }
    'Get-RubrikVersion'       = @{
      v1 = @{
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
    'Get-RubrikVM'            = @{
      v1 = @{
        Description = 'Get summary of all the VMs'
        URI         = '/api/v1/vmware/vm'
        Method      = 'Get'
        Body        = ''
        Query       = @{
          is_relic                = 'is_relic'
          name                    = 'name'
          effective_sla_domain_id = 'effective_sla_domain_id'
        }
        Result      = 'data'
        Filter      = @{
          'Name' = 'name'
          'SLA' = 'effectiveSlaDomainName'
        }
        Success     = '200'
      }
    }
    'New-RubrikMount'         = @{
      v1 = @{
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
    'New-RubrikSLA'           = @{
      v1 = @{
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
    }
    'New-RubrikSnapshot'      = @{
      v1 = @{
        Description = 'Create an on-demand snapshot for the given object ID'
        URI         = @{
          Fileset = '/api/v1/fileset/{id}/snapshot'
          MSSQL   = '/api/v1/mssql/db/{id}/snapshot'
          VMware  = '/api/v1/vmware/vm/{id}/snapshot'
        }
        Method      = 'Post'
        Body        = @{
          forceFullSnapshot = 'forceFullSnapshot'
        }
        Query       = ''
        Result      = ''
        Filter      = ''
        Success     = '202'
      }
    }
    'Protect-RubrikDatabase'  = @{
      v1 = @{
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
    'Protect-RubrikFileset'   = @{
      v1 = @{
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
    'Protect-RubrikTag'       = @{
      v1 = @{
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
    'Protect-RubrikVM'        = @{
      v1 = @{
        Description = 'Update a VM with the specified SLA Domain.'
        URI         = '/api/v1/vmware/vm/{id}'
        Method      = 'Patch'
        Body        = @{
          configuredSlaDomainId      = 'configuredSlaDomainId'
        }
        Query       = ''
        Result      = ''
        Filter      = ''
        Success     = '200'
      }
    }
    'Remove-RubrikMount'      = @{
      v1 = @{
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
    'Remove-RubrikReport'      = @{
      v1 = @{
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
    'Remove-RubrikSLA'        = @{
      v1 = @{
        Description = 'Delete an SLA Domain from a Rubrik cluster'
        URI         = '/api/v1/sla_domain/{id}'
        Method      = 'Delete'
        Body        = ''
        Query       = ''
        Result      = ''
        Filter      = ''
        Success     = '204'
      }
    }
    'Remove-RubrikUnmanagedObject'      = @{
      v1 = @{
        Description = 'Bulk delete all unmanaged snapshots for the objects specified by objectId/objectType pairings.'
        URI         = '/api/internal/unmanaged_object/snapshot/bulk_delete'
        Method      = 'Post'
        Body        = @{
          objectDefinitions = @(
            @{
              objectId = 'objectId'
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
    'Set-RubrikBlackout'      = @{
      v1 = @{
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
    'Set-RubrikMount'          = @{
      v1 = @{
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
    'Set-RubrikVM'          = @{
      v1 = @{
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
        }
        Query       = ''
        Result      = ''
        Filter      = ''
        Success     = '200'
      }
    }
  } # End of API

  return $api.$endpoint
} # End of function
