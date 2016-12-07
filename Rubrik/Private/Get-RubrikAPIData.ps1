<#
    Helper function to retrieve API data from Rubrik
#>
function GetRubrikAPIData($endpoint)
{
  $api = @{
    Login               = @{
      v1 = @{
        URI         = '/api/v1/login'
        Body        = @('username', 'password')
        Method      = 'Post'
        SuccessCode = '200'
        SuccessMock = '{"userId": "11111111-2222-3333-4444-555555555555","token": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"}'
        FailureCode = '422'
        FailureMock = '{"errorType":"user_error","message":"Incorrect Username/Password","cause":null}'
      }
      v0 = @{
        URI         = '/login'
        Body        = @('userId', 'password')
        Method      = 'Post'
        SuccessCode = '200'
        SuccessMock = '{"status":"Success","description":"Successfully logged in","userId":"11111111-2222-3333-4444-555555555555","token":"aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"}'
        FailureCode = '200'
        FailureMock = '{"status": "Failure","description": "Incorrect Username/Password"}'
      }
    }
    VMwareVMGet         = @{
      v1 = @{
        URI         = '/api/v1/vmware/vm'
        Body        = ''
        Params      = @{
          Filter = 'archive_status'
          Search = 'search_value'
        }
        Method      = 'Get'
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
    VMwareVMSnapshotGet = @{
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
    VMwareVMMountPost   = @{
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
    VMwareVMMountGet    = @{
      v1 = @{
        URI         = '/api/v1/vmware/vm/mount'
        Method      = 'Get'
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
      v0 = @{
        URI         = '/mount'
        Method      = 'Get'
        SuccessCode = '200'
        SuccessMock = @"
[
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
]
"@
        FailureCode = ''
        FailureMock = ''
      }
    }
    VMwareVMMountDelete = @{
      v1 = @{
        URI         = '/api/v1/vmware/vm/mount'
        Params      = @{
          MountID = 'mount_id'
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
    ClusterVersionGet = @{
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
    SLADomainGet = @{
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
    SLADomainAssignPost = @{
      v1 = @{
        URI         = '/api/v1/sla_domain/{id}/assign_sync'
        Body      = @{
          managedIds = 'managedIds'
        }
        Method      = 'Post'
        SuccessCode = '204'
        SuccessMock = ''
        FailureCode = ''
        FailureMock = ''
      }
      v0 = @{
        URI         = '/slaDomainAssign/{id}'
        Body        = @{
          managedIds = 'managedIds'
        }
        Method      = 'Patch'
        SuccessCode = '200'
        SuccessMock = @"
{
    "statuses":  [
                     {
                         "id":  "VirtualMachine:::11111111-2222-3333-4444-555555555555-vm-66",
                         "status":  "@{status=Success}"
                     },
                     {
                         "id":  "VirtualMachine:::11111111-2222-3333-4444-555555555555-vm-77",
                         "status":  "@{status=Success}"
                     }
                 ],
    "jobs":  [
                 "CALCULATE_EFFECTIVE_SLA_aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee_ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj:::0"
             ]
}
"@
        FailureCode = ''
        FailureMock = ''
      }
    }
    SLADomainDelete = @{
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
  } # End of API
  
  return $api.$endpoint
} # End of function
