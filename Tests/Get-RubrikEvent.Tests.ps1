Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikEvent' -Tag 'Public', 'Get-RubrikEvent' -Fixture {
    #region init
    $global:rubrikConnection = @{
        id      = 'test-id'
        userId  = 'test-userId'
        token   = 'test-token'
        server  = 'test-server'
        header  = @{ 'Authorization' = 'Bearer test-authorization' }
        time    = (Get-Date)
        api     = 'v1'
        version = '5.3.0'
    }
    #endregion

    Context -Name 'Results Filtering' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                'name'                   = 'VirtualMachine01'
                'id'                     = 'VirtualMachine:::11111'
                'eventType'              = 'Replication'
                'time'                   = 'Mon Aug 10 07:12:14 UTC 2019'
            },
            @{
                'name'                   = 'VirtualMachine02'
                'id'                     = 'VirtualMachine:::22222'
                'eventType'              = 'Backup'
                'time'                   = 'Mon Aug 11 07:12:14 UTC 2019'
            },
            @{
                'name'                   = 'VirtualMachine03'
                'id'                     = 'VirtualMachine:::33333'
                'eventType'              = 'CloudNativeSource'
                'time'                   = 'Mon Aug 12 07:12:14 UTC 2019'
            },
            @{
                'name'                   = 'VirtualMachine04'
                'id'                     = 'VirtualMachine:::44444'
                'eventType'              = 'Replication'
                'time'                   = 'Mon Aug 13 07:12:14 UTC 2019'
            },
            @{
                'name'                   = 'VirtualMachine05'
                'id'                     = 'VirtualMachine:::55555'
                'eventType'              = 'Replication'
                'time'                   = 'Mon Aug 14 07:12:14 UTC 2019'
            }
        }
        It -Name 'Should Return count of 5' -Test {
            (Get-RubrikEvent).Count |
                Should -BeExactly 5
        }
        It -Name 'Should not run with Name parameter' -Test {
            {Get-RubrikEvent -Name doesnotexist -ErrorAction Stop} |
                Should -Throw
        }
        It -Name 'Date property should be a datetime object' -Test {
            (Get-RubrikEvent)[1].Date |
                Should -BeOfType DateTime
        }

        It -Name 'Verify switch param - IncludeEventSeries:$true - Switch Param' -Test {
            $Output = & {
                Get-RubrikEvent -Limit 1 -IncludeEventSeries -EventType Backup -Verbose 4>&1
            }
            (-join $Output) | Should -BeLike '*should_include_event_series=true*'
        }
        It -Name 'Verify switch param - IncludeEventSeries:$false - Switch Param' -Test {
            $Output = & {
                Get-RubrikEvent -IncludeEventSeries:$false -Verbose 4>&1
            }
            (-join $Output) | Should -BeLike '*should_include_event_series=false*'
        }
        It -Name 'Verify switch param - No IncludeEventSeries - Switch Param' -Test {
            $Output = & {
                Get-RubrikEvent -Verbose 4>&1
            }
            (-join $Output) | Should -Not -BeLike '*should_include_event_series='
        }

        It -Name 'Verify Status ValidateSet' -Test {
            { Get-RubrikEvent -Status 'NonExistant' } |
                Should -Throw "Cannot validate argument on parameter 'Status'."
        }

        It -Name 'Verify switch param - Descending:$true - Switch Param' -Test {
            $Output = & {
                Get-RubrikEvent -Descending -Verbose 4>&1
            }
            (-join $Output) | Should -BeLike '*order_by_time=desc*'
        }
        It -Name 'Verify switch param - Descending:$false - Switch Param' -Test {
            $Output = & {
                Get-RubrikEvent -Descending:$false -Verbose 4>&1
            }
            (-join $Output) | Should -BeLike '*order_by_time=asc*'
        }
        It -Name 'Verify switch param - No Descending - Switch Param' -Test {
            $Output = & {
                Get-RubrikEvent -Verbose 4>&1
            }
            (-join $Output) | Should -Not -BeLike '*order_by_time='
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 8
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 8
    }
    Context -Name 'EventSeries calling correct cmdlets' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Get-RubrikEventSeries -Verifiable -ModuleName 'Rubrik' -MockWith {
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
        It -Name 'Should call Get-RubrikEventSeries and return count of 2' -Test {
            (Get-RubrikEvent -eventSeriesId '11111').Count |
                Should -BeExactly 2
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 1

    }
}
