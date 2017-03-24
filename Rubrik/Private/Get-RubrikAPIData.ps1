<#
    Helper function to retrieve API data from Rubrik
#>
function Get-RubrikAPIData($endpoint)
{
  $api = @{
    Session                   = @{
      'v1.1' = @{
        URI         = '/api/v1/session'
        Method      = 'Post'
        SuccessCode = '200'
        SuccessMock = '{"userId": "11111111-2222-3333-4444-555555555555","token": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"}'
        FailureCode = '422'
        FailureMock = '{"errorType":"user_error","message":"Incorrect Username/Password","cause":null}'
      }
      'v1.0' = @{
        URI         = '/api/v1/login'
        Body        = @('username', 'password')
        Method      = 'Post'
        SuccessCode = '200'
        SuccessMock = '{"userId": "11111111-2222-3333-4444-555555555555","token": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"}'
        FailureCode = '422'
        FailureMock = '{"errorType":"user_error","message":"Incorrect Username/Password","cause":null}'
      }
      'v0' = @{
        URI         = '/login'
        Body        = @('userId', 'password')
        Method      = 'Post'
        SuccessCode = '200'
        SuccessMock = '{"status":"Success","description":"Successfully logged in","userId":"11111111-2222-3333-4444-555555555555","token":"aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"}'
        FailureCode = '200'
        FailureMock = '{"status": "Failure","description": "Incorrect Username/Password"}'
      }
    }
    VMwareVMGet               = @{
      v1 = @{
        URI         = '/api/v1/vmware/vm'
        Body        = ''
        Params      = @{
          Filter = 'is_relic'
          Search = 'name'
          SLA    = 'effective_sla_domain_id'
        }        
        Method      = 'Get'
        Result      = 'data'
        Filter      = @{
          '$VM' = 'name'
          '$SLA' = 'effectiveSlaDomainName'
        }
        SuccessCode = '200'
        SuccessMock = @"
{
	"hasMore": true,
	"data": [{
		"id": "11111111-2222-3333-4444-555555555555-vm-666666",
		"name": "TEST1",
		"configuredSlaDomainId": "d8a8430c-40de-4cb7-b834-bd0e7de40ed1",
		"configuredSlaDomainName": "Gold",
		"effectiveSlaDomainId": "d8a8430c-40de-4cb7-b834-bd0e7de40ed1",
		"effectiveSlaDomainName": "Gold",
		"isArchived": false,
		"inheritedSlaName": "Gold",
		"slaId": "d8a8430c-40de-4cb7-b834-bd0e7de40ed1",
		"isRelic": true
	}, {
		"id": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-ffffff",
		"name": "TEST2",
		"configuredSlaDomainId": "INHERIT",
		"configuredSlaDomainName": "Inherit",
		"effectiveSlaDomainId": "UNPROTECTED",
		"effectiveSlaDomainName": "Unprotected",
		"isArchived": true,
		"inheritedSlaName": "Unprotected",
		"slaId": "INHERIT",
		"isRelic": false
	}]
}
"@
        FailureCode = ''
        FailureMock = ''
      }
      v0 = @{
        URI         = '/vm'
        Body        = ''
        Params      = @{
          Filter = 'archiveStatusFilterOpt'
          Search = ''
        }
        Method      = 'Get'
        Result      = ''
        Filter      = @{
          '$VM' = 'name'
          '$SLA' = 'effectiveSlaDomainName'
        }        
        SuccessCode = '200'
        SuccessMock = @"
[{
		"id": "11111111-2222-3333-4444-555555555555-vm-666666",
		"name": "TEST1",
		"configuredSlaDomainId": "d8a8430c-40de-4cb7-b834-bd0e7de40ed1",
		"configuredSlaDomainName": "Gold",
		"effectiveSlaDomainId": "d8a8430c-40de-4cb7-b834-bd0e7de40ed1",
		"effectiveSlaDomainName": "Gold",
		"isArchived": false,
		"inheritedSlaName": "Gold",
		"slaId": "d8a8430c-40de-4cb7-b834-bd0e7de40ed1",
		"isRelic": false
	}, {
		"id": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-ffffff",
		"name": "TEST2",
		"configuredSlaDomainId": "INHERIT",
		"configuredSlaDomainName": "Inherit",
		"effectiveSlaDomainId": "UNPROTECTED",
		"effectiveSlaDomainName": "Unprotected",
		"isArchived": true,
		"inheritedSlaName": "Unprotected",
		"slaId": "INHERIT",
		"isRelic": true
	}]
"@
        FailureCode = '500'
        FailureMock = '{"status": "Failure"}'
      }
    }
    VMwareVMSnapshotGet       = @{
      v1 = @{
        URI         = '/api/v1/vmware/vm/{id}/snapshot'
        Method      = 'Get'
        SuccessCode = '200'
        SuccessMock = @"
{
  "hasMore": false,
  "data": [
    {
      "date": "2016-12-05T17:10:17Z",
      "virtualMachineName": "TEST1",
      "id": "11111111-2222-3333-4444-555555555555",
      "consistencyLevel": "CRASH_CONSISTENT"
    },
    {
      "date": "2016-12-05T13:06:35Z",
      "virtualMachineName": "TEST1",
      "id": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
      "consistencyLevel": "CRASH_CONSISTENT"
    }
  ],
  "total": 2
}
"@        
        FailureCode = '404'
        FailureMock = '{"message":"Could not find VirtualMachine with id=11111111-2222-3333-4444-555555555555-vm-6666"}'
      }
      v0 = @{
        URI         = '/snapshot?vm={id}'
        Method      = 'Get'
        SuccessCode = '200'
        SuccessMock = @"
[
    {
      "date": "2016-12-05T17:10:17Z",
      "virtualMachineName": "TEST1",
      "id": "11111111-2222-3333-4444-555555555555",
      "consistencyLevel": "CRASH_CONSISTENT"
    },
    {
      "date": "2016-12-05T13:06:35Z",
      "virtualMachineName": "TEST1",
      "id": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
      "consistencyLevel": "CRASH_CONSISTENT"
    }
]
"@
        FailureCode = ''
        FailureMock = ''
      }
    }
    VMwareVMMountPost         = @{
      v1 = @{
        URI         = '/api/v1/vmware/vm/mount'
        Body        = @{
          snapshotId           = 'snapshotId'
          hostId               = 'hostId'
          vmName               = 'vmName'
          disableNetwork       = 'disableNetwork'
          removeNetworkDevices = 'removeNetworkDevices'
          powerOn              = 'powerOn'
        }
        Method      = 'Post'
        SuccessCode = '202'
        SuccessMock = @"
{
  "requestId": "MOUNT_SNAPSHOT_11111111-2222-3333-4444-555555555555_66666666-7777-8888-9999-000000000000:::0",
  "status": "QUEUED",
  "links": [
    {
      "href": "https://RVM1111111111/api/v1/vmware/vm/request/MOUNT_SNAPSHOT_11111111-2222-3333-4444-555555555555_66666666-7777-8888-9999-000000000000:::0",
      "rel": "self",
      "method": "GET"
    }
  ]
}
"@
        FailureCode = ''
        FailureMock = ''
      }
      v0 = @{
        URI         = '/job/type/mount'
        Body        = @{
          snapshotId           = 'snapshotId'
          hostId               = 'hostId'
          vmName               = 'vmName'
          disableNetwork       = 'disableNetwork'
          removeNetworkDevices = 'removeNetworkDevices'
          powerOn              = 'powerOn'
        }
        Method      = 'Post'
        SuccessCode = '200'
        SuccessMock = @"
{
  "requestId": "MOUNT_SNAPSHOT_11111111-2222-3333-4444-555555555555_66666666-7777-8888-9999-000000000000:::0",
  "status": "QUEUED",
  "links": [
    {
      "href": "https://RVM1111111111/api/v1/vmware/vm/request/MOUNT_SNAPSHOT_11111111-2222-3333-4444-555555555555_66666666-7777-8888-9999-000000000000:::0",
      "rel": "self",
      "method": "GET"
    }
  ]
}
"@
        FailureCode = ''
        FailureMock = ''
      }
    }
    VMwareVMMountGet          = @{
      v1 = @{
        URI         = '/api/v1/vmware/vm/snapshot/mount'
        Params      = @{
          VMID   = 'vm_id'
        }
        Method      = 'Get'
        Result      = 'data'
        SuccessCode = '200'
        SuccessMock = @"
{
  "hasMore": false,
  "data": [
    {
      "id": "11111111-2222-3333-4444-555555555555",
      "snapshotDate": "2016-12-01T23:26:49+0000",
      "sourceVirtualMachineId": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-fff",
      "sourceVirtualMachineName": "TEST1",
      "isReady": 1
    },
    {
      "id": "aaaaaaaa-2222-3333-4444-555555555555",
      "snapshotDate": "2016-12-01T23:26:49+0000",
      "sourceVirtualMachineId": "11111111-bbbb-cccc-dddd-eeeeeeeeeeee-vm-fff",
      "sourceVirtualMachineName": "TEST2",
      "isReady": 1
    }
  ],
  "total": 2
}
"@
        FailureCode = ''
        FailureMock = ''
      }
    }
    VMwareVMMountDelete       = @{
      v1 = @{
        URI         = '/api/v1/vmware/vm/snapshot/mount/{id}'
        Params      = @{
          Force   = 'force'
        }
        Method      = 'Delete'
        SuccessCode = '202'
        SuccessMock = @"
{
  "requestId": "UNMOUNT_SNAPSHOT_11111111-2222-3333-4444-555555555555_66666666-7777-8888-9999-000000000000:::0",
  "status": "QUEUED",
  "links": [
    {
      "href": "https://RVM1111111111/api/v1/vmware/vm/request/UNMOUNT_SNAPSHOT_11111111-2222-3333-4444-555555555555_66666666-7777-8888-9999-000000000000:::0",
      "rel": "self",
      "method": "GET"
    }
  ]
}
"@
        FailureCode = ''
        FailureMock = ''
      }
      v0 = @{
        URI         = '/job/type/unmount'
        Params      = @{
          MountID = 'mountId'
          Force   = 'force'
        }        
        Method      = 'Post'
        SuccessCode = '200'
        SuccessMock = ''
        FailureCode = ''
        FailureMock = ''
      }
    }
    ClusterVersionGet         = @{
      v1 = @{
        URI         = '/api/v1/cluster/{id}/version'
        Params      = @{
          id = 'id'
        }
        Method      = 'Get'
        SuccessCode = '200'
        SuccessMock = '"9.9.9~DA9-99"'
        FailureCode = ''
        FailureMock = ''
      }
      v0 = @{
        URI         = '/system/version'
        Method      = 'Get'
        SuccessCode = '200'
        SuccessMock = '"1.1.1~DA1-11"'
        FailureCode = ''
        FailureMock = ''
      }
    }
    SLADomainGet              = @{
      v1 = @{
        URI         = '/api/v1/sla_domain'
        Method      = 'Get'
        SuccessCode = '200'
        SuccessMock = @"
{
  "hasMore": false,
  "data": [
    {
      "id": "11111111-2222-3333-4444-555555555555",
      "name": "TEST1",
      "numDbs": 11,
      "numFilesets": 11,
      "numLinuxHosts": 11,
      "numVms": 11
    },
    {
      "id": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
      "name": "TEST2",
      "numDbs": 22,
      "numFilesets": 22,
      "numLinuxHosts": 22,
      "numVms": 22
    }
  ],
  "total": 2
}
"@
        FailureCode = ''
        FailureMock = ''
      }
      v0 = @{
        URI         = '/slaDomain'
        Method      = 'Get'
        SuccessCode = '200'
        SuccessMock = @"
[
  {
    "id": "11111111-2222-3333-4444-555555555555",
    "name": "TEST1",
    "numVms": 11,
    "numSnapshots": 11
  },
  {
    "id": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
    "name": "TEST2",
    "numVms": 22,
    "numSnapshots": 22
  }
]
"@
        FailureCode = ''
        FailureMock = ''
      }
    }
    SLADomainDelete           = @{
      v1 = @{
        URI         = '/api/v1/sla_domain/{id}'
        Method      = 'Delete'
        SuccessCode = '204'
        SuccessMock = ''
        FailureCode = ''
        FailureMock = ''
      }
      v0 = @{
        URI         = '/slaDomain/{id}'
        Method      = 'Delete'
        SuccessCode = '200'
        SuccessMock = ''
        FailureCode = ''
        FailureMock = ''
      }
    }
    JobGet                    = @{
      v1 = @{
        URI         = '/api/internal/job/{id}'
        Method      = 'Get'
        SuccessCode = '200'
        SuccessMock = @"
{
    "id":  "CREATE_SNAPSHOT_123456-vm-123:::11",
    "status":  "SUCCEEDED",
    "result":  "abcdef",
    "startTime":  "2016-12-27T06:17:54+0000",
    "endTime":  "2016-12-27T06:25:42+0000",
    "jobType":  "CREATE_SNAPSHOT",
    "nodeId":  "cluster:::RVM151S001111",
    "isDisabled":  false
}
"@
        FailureCode = ''
        FailureMock = ''
      }
      v0 = @{
        URI         = '/job/instance/{id}'
        Method      = 'Get'
        SuccessCode = '200'
        SuccessMock = @"
{
    "id":  "CREATE_SNAPSHOT_123456-vm-123:::11",
    "status":  "SUCCEEDED",
    "result":  "abcdef",
    "startTime":  "2016-12-27T06:17:54+0000",
    "endTime":  "2016-12-27T06:25:42+0000",
    "jobType":  "CREATE_SNAPSHOT",
    "nodeId":  "cluster:::RVM151S001111",
    "isDisabled":  false
}
"@
        FailureCode = ''
        FailureMock = ''
      }
    }
    ReportBackupJobsDetailGet = @{
      v1 = @{
        URI         = '/api/v1/report/backup_jobs/detail?report_type={id}'
        Method      = 'Get'
        SuccessCode = '200'
        SuccessMock = @"
{
   "hasMore":false,
   "data":[
      {
         "objectType":"Mssql",
         "slaDomainId":"123456",
         "durationInMillis":120000,
         "slaDomainName":"Gold",
         "location":"TEST1\\MSSQLSERVER",
         "endTime":"2016-12-26T17:41:51Z",
         "failureDescription":"Rubrik backup service at \u0027TEST1\u0027 returned error: Failed to take database snapshot, Error = VSS_E_BAD_STATE(0x80042301)",
         "scheduledTime":"2016-12-26T17:34:01Z",
         "objectId":"abcdef",
         "status":"Failed",
         "objectName":"DB1",
         "jobType":"Backup",
         "jobId":"MSSQL_DB_BACKUP_123456:::11",
         "startTime":"2016-12-26T17:39:51Z"
      }
   ]
}
"@
        FailureCode = ''
        FailureMock = ''
      }
      v0 = @{
        URI         = '/report/backupJobs/detail'
        Method      = 'Post'
        SuccessCode = '200'
        SuccessMock = ''
        FailureCode = ''
        FailureMock = ''
      }
    }
    VMwareVMBackupPost        = @{
      v1 = @{
        URI         = '/api/v1/vmware/vm/{id}/backup'
        Method      = 'Post'
        SuccessCode = '202'
        SuccessMock = @"
{
    "requestId":  "CREATE_VMWARE_SNAPSHOT_123456:::0",
    "status":  "QUEUED",
    "links":  [
                  {
                      "href":  "https://RVM15BS011111/api/v1/vmware/vm/request/CREATE_VMWARE_SNAPSHOT_123456:::0",
                      "rel":  "self",
                      "method":  "GET"
                  }
              ]
}
"@
        FailureCode = ''
        FailureMock = ''
      }
      v0 = @{
        URI         = '/job/type/backup'
        Method      = 'Post'
        SuccessCode = '200'
        SuccessMock = ''
        FailureCode = ''
        FailureMock = ''
      }
    }
    VMwareVMMountPowerPost    = @{
      v1 = @{
        URI         = '/api/v1/vmware/vm/mount/{id}/power'
        Method      = 'Post'
        Params      = @{
          vmId        = $null
          powerStatus = 'powerStatus'
        }
        SuccessCode = '204'
        SuccessMock = ''
        FailureCode = ''
        FailureMock = ''
      }
      v0 = @{
        URI         = '/vm/power'
        Method      = 'Post'
        Params      = @{
          vmId        = 'vmId'
          powerStatus = 'powerState'
        }        
        SuccessCode = '200'
        SuccessMock = ''
        FailureCode = ''
        FailureMock = ''
      }
    }
    VMwareVMPatch             = @{
      v1 = @{
        URI         = '/api/v1/vmware/vm/{id}'
        Body        = @{
          SLA                        = 'configuredSlaDomainId'
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
        }
        Method      = 'Patch'
        Result      = 'data'
        Filter      = @{
          '$VM'    = 'name'
          '$SLA'   = 'effectiveSlaDomainName'
          '$Host'  = 'hostName'
          '$Cluster' = 'clusterName'
        }        
        SuccessCode = '200'
        SuccessMock = ''
        FailureCode = ''
        FailureMock = ''
      }
      v0 = @{
        URI         = '/vm/{id}'
        Method      = 'Patch'
        Params      = @{
          snapshotConsistencyMandate = 'snapshotConsistencyMandate'
          maxNestedVsphereSnapshots  = 'maxNestedVsphereSnapshots'
        }      
        SuccessCode = '200'
        SuccessMock = ''
        FailureCode = ''
        FailureMock = ''
      }
    }
    SLADomainPost             = @{
      v1 = @{
        URI         = '/api/v1/sla_domain'
        Method      = 'Post'
        Params      = @{
          name        = 'name'
          frequencies = @{
            timeUnit  = 'timeUnit'
            frequency = 'frequency'
            retention = 'retention'
          }
        }
        SuccessCode = '201'
        SuccessMock = ''
        FailureCode = ''
        FailureMock = ''
      }
    }
    VMwareVMRequestGet        = @{
      v1 = @{
        URI         = '/api/v1/vmware/vm/request/{id}'
        Method      = 'Get'
        SuccessCode = '200'
        SuccessMock = ''
        FailureCode = ''
        FailureMock = ''
      }
    }
    MSSQLDBGet                = @{
      v1 = @{
        URI         = '/api/v1/mssql/db'
        Body        = ''
        Params      = @{
          Filter = 'archive_status'
          Search = 'search_value'
        }         
        Method      = 'Get'
        Result      = 'data'
        Filter      = @{
          '$Database' = 'name'
          '$SLA'    = 'effectiveSlaDomainName'
          '$Host'   = 'rootProperties.rootName'
          '$Instance' = 'instanceName'
        }
        SuccessCode = '200'
        SuccessMock = ''
        FailureCode = ''
        FailureMock = ''
      }
    }
    MSSQLDBPatch              = @{
      v1 = @{
        URI         = '/api/v1/mssql/db/{id}'
        Body        = @{
          SLA               = 'configuredSlaDomainId'
          LogBackupSeconds  = 'logBackupFrequencyInSeconds'
          LogRetentionHours = 'logRetentionHours'
          CopyOnly          = 'copyOnly'
          MaxDataStreams    = 'maxDataStreams'
        }    
        Params      = ''    
        Method      = 'Patch'
        Result      = 'data'
        Filter      = @{
          '$Database' = 'name'
          '$SLA'    = 'effectiveSlaDomainName'
          '$Host'   = 'rootProperties.rootName'
          '$Instance' = 'instanceName'
        }
        SuccessCode = '200'
        SuccessMock = ''
        FailureCode = ''
        FailureMock = ''
      } 
    }
    FilesetGet                = @{
      v1 = @{
        URI         = '/api/v1/fileset'
        Body        = ''   
        Params      = @{
          Filter     = 'is_relic'
          Search     = 'name'
          SearchHost = 'host_name'
          SLA        = 'effective_sla_domain_id'
        }     
        Method      = 'Get'
        Result      = 'data'
        Filter      = ''
        SuccessCode = '200'
        SuccessMock = ''
        FailureCode = ''
        FailureMock = ''
      } 
    }
    FilesetPatch              = @{
      v1 = @{
        URI         = '/api/v1/fileset/{id}'
        Body        = @{
          SLA = 'configuredSlaDomainId'
        }
        Params      = ''
        Method      = 'Patch'
        Result      = 'data'
        Filter      = ''
        SuccessCode = '200'
        SuccessMock = ''
        FailureCode = ''
        FailureMock = ''
      } 
    }
  } # End of API
  
  return $api.$endpoint
} # End of function
