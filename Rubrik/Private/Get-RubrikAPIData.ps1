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
        SuccessMock = '{"id": "11111111-2222-3333-4444-555555555555-vm-666666","configuredSlaDomainName": "Test"}'
        FailureCode = '500'
        FailureMock = '{"status": "Failure"}'
      }
    }
    VMwareVMSnapshotGet = @{
      v1 = @{
        URI         = '/api/v1/vmware/vm/{id}/snapshot'
        Method      = 'Get'
        SuccessCode = '200'
        SuccessMock = ''
        FailureCode = '404'
        FailureMock = '{"message":"Could not find VirtualMachine with id=11111111-2222-3333-4444-555555555555-vm-6666"}'
      }
      v0 = @{
        URI         = '/snapshot?vm={id}'
        Method      = 'Get'
        SuccessCode = '200'
        SuccessMock = ''
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
        SuccessMock = ''
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
        SuccessMock = ''
        FailureCode = ''
        FailureMock = ''
      }
    }
  } # End of API
  
  return $api.$endpoint
} # End of function
