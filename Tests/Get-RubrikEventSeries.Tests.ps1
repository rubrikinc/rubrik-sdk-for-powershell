Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikEventSeries' -Tag 'Public', 'Get-RubrikEventSeries' -Fixture {
    #region init
    $global:rubrikConnection = @{
        id      = 'test-id'
        userId  = 'test-userId'
        token   = 'test-token'
        server  = 'test-server'
        header  = @{ 'Authorization' = 'Bearer test-authorization' }
        time    = (Get-Date)
        api     = 'v1'
        version = '4.0.5'
    }
    #endregion

    Context -Name 'Results Filtering' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                "taskType" = "Backup"
                "objectInfo" =@{
                  "objectId" = "VirtualMachine:::4c0f0c71-1390-4017-9206-f8b16bd7ca8c-vm-102"
                  "objectName" = "WINVM"
                  "objectType" = "VmwareVm"
                }
                "eventSeriesId" = "b7b95048-9c06-4d22-83cc-ff40099cedf4"
                "eventId" = "2020-03-10:14:0:::1583848919749-1138d4df-3060-468a-a7ec-dadf022e2c7f"
                "status" = "Success"
                "eventDate" = "2020-03-10T14:01:59.749Z"
            },
            @{
                "taskType" = "Backup"
                "objectInfo" = @{
                    "objectId"= "VirtualMachine:::4c0f0c71-1390-4017-9206-f8b16bd7ca8c-vm-102"
                    "objectName"= "WINVM2"
                    "objectType"= "VmwareVm"
                }
                "eventSeriesId"= "5027ec0e-175a-475a-823c-4ad6c3f9aa12"
                "eventId"= "2020-03-10:14:0:::1583848919651-12064137-8b4c-404d-afaf-f7c6ff1b0a64"
                "status"= "Scheduled"
                "eventDate"= "2020-03-10T14:01:59.651Z"
            },
            @{
                "taskType"= "Backup"
                "objectInfo"= @{
                    "objectId"= "VirtualMachine:::4c0f0c71-1390-4017-9206-f8b16bd7ca8c-vm-5968"
                    "objectName"= "WINVM3"
                    "objectType"= "VmwareVm"
                }
                "eventSeriesId"= "4bc9289d-6399-46a3-ba0c-51a1e39fe7e3"
                "eventId"= "2020-03-10:13:5:::1583848610181-8a435030-bc69-416e-a344-74db8be413b3"
                "status"= "Success"
                "eventDate"= "2020-03-10T13:56:50.181Z"
            }
        }
        It -Name 'Should Return count of 3' -Test {
            (Get-RubrikEventSeries).Count |
                Should -BeExactly 3
        }
        It -Name 'Verify Status ValidateSet' -Test {
            { Get-RubrikEventSeries -Status 'NonExistant' } |
                Should -Throw "Cannot validate argument on parameter 'Status'."
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 1
    }
    Context -Name 'Results Filtering with ID' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                "taskType"= "Replication"
                "objectId"= "MssqlDatabase:::125af122-5925-4a4f-9d26-7fcf0eae01dc"
                "objectType"= "Mssql"
                "objectName"= "AdventureWorks2016"
                "status"= "Success"
                "startTime"= "2020-03-10T13:46:30.764Z"
                "endTime"= "2020-03-10T13:46:30.678Z"
                "total"= "2"
                "eventDetailList"=
                  @{
                    "id"= "1583847985143-d6920ab4-bf0f-4913-b432-87a704c5c721"
                    "status"= "Running"
                    "time"= "Tue Mar 10 13:46:25 UTC 2020"
                    "objectId"= "125af122-5925-4a4f-9d26-7fcf0eae01dc"
                    "objectType"= "Mssql"
                    "objectName"= "AdventureWorks2016"
                  },
                  @{
                    "id"= "1583847990678-26601933-fe16-493d-9c1c-afec7988a59b"
                    "status"= "Success"
                    "time"= "Tue Mar 10 13:46:30 UTC 2020"
                    "objectId"= "125af122-5925-4a4f-9d26-7fcf0eae01dc"
                    "objectType"= "Mssql"
                    "objectName"= "AdventureWorks2016"
                  }
              }
        }
        It -Name 'Should return 2 events' -Test {
            ((Get-RubrikEventSeries -id '11111').eventDetailList).Count |
                Should -BeExactly 2
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 1
    }
}
