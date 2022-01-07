Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

Describe -Name 'Public/Get-RubrikDatabaseDownloadLink' -Tag 'Public', 'Get-RubrikDatabaseDownloadLink' -Fixture {
    Context -Name 'Validate correct processing of function' -Fixture {
        Mock -CommandName Submit-Request -ModuleName 'Rubrik' -MockWith {
            [pscustomobject]@{
                EventInfo = 'Download link for AdventureWorks'
                Links = 'Thisshouldbefiltered***File_ValidateLink_Thisshouldbefiltered***'
                Date = (Get-Date).AddHours(-1)
            }
        }
        Mock -CommandName Get-RubrikEvent -ModuleName 'Rubrik' -MockWith {
            [pscustomobject]@{
                EventInfo = 'Download link for AdventureWorks'
                Links = 'Thisshouldbefiltered***File_ValidateLink_Thisshouldbefiltered***'
                Date = (Get-Date).AddHours(-1)
                Time = (Get-Date).AddHours(+1)
            }
        }

        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {
            $Global:Header = @{
                Authorization = 'Bearer test-authorization'
            }
        }

        Mock -CommandName Get-RubrikDatabase -Verifiable -ModuleName 'Rubrik' -MockWith {
            $output = @{
                Authorization = 'Bearer test-authorization'
            }
        }

        Mock -CommandName Get-RubrikSnapshot -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                id = 'Bearer test-authorization'
            }
        }

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

        It -Name "Should return the correctly formatted download link based on input" -Test {
            Get-RubrikDatabaseDownloadLink -Server 'test-server' -id 'id' -SnapshotId "Latest" |
                Should -Be 'https://test-server/Download link for AdventureWorks'
        }

        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 1
        Assert-MockCalled -CommandName Get-RubrikEvent -ModuleName 'Rubrik' -Exactly 1
    }

    Context -Name 'Parameter Validation' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {
            $Global:Header = @{
                Authorization = 'Bearer test-authorization'
            }
        }
        It -Name 'Parameter id cannot be $null' -Test {
            { Get-RubrikDatabaseDownloadLink -Verbose -id $null -SnapshotId "id"} |
                Should -Throw "Cannot bind argument to parameter 'id' because it is an empty string."
        }

        It -Name 'Parameter Snapshotid cannot be $null' -Test {
            { Get-RubrikDatabaseDownloadLink -Verbose -id "id" -SnapshotId $null} |
                Should -Throw "Cannot bind argument to parameter 'SnapshotId' because it is an empty string."
        }

    }
}